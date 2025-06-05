local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local MobTypeConfig = require(MainStorage.code.common.config.MobTypeConfig)  ---@type MobTypeConfig
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local Modifiers = require(MainStorage.code.common.config_type.modifier.Modifiers) ---@type Modifiers
local WeightedRandomSelector = require(MainStorage.code.common.WeightedRandomSelector) ---@type WeightedRandomSelector
local LevelConfig = require(MainStorage.code.common.config.LevelConfig)  ---@type LevelConfig

---@class SpawningMob:Class
---@field mobType MobType
---@field weight number
local SpawningMob = ClassMgr.Class("SpawningMob")

function SpawningMob:OnInit(data)
    self.mobType = MobTypeConfig.Get(data["怪物类型"])
    self.weight = data["比重"] or 1
end

---@class SpawningWave:Class
---@field mobs SpawningMob[]
---@field duration number
---@field count number
---@field maxCount number
---@field startTime number
---@field selector WeightedRandomSelector
local SpawningWave = ClassMgr.Class("SpawningWave")

function SpawningWave:OnInit(data)
    self.mobs = {}
    for _, mobData in ipairs(data["刷新怪物"] or {}) do
        table.insert(self.mobs, SpawningMob.New(mobData))
    end
    self.duration = data["持续时间"] or 0
    self.count = data["数量"] or 0
    self.maxCount = data["最大数量"] or 0
    self.startTime = data["开始时间"] or 0
    self.selector = WeightedRandomSelector.New(self.mobs, function(mob) return mob.weight end)
    
    -- 计算实际要刷新的怪物数量
    if self.maxCount > 0 then
        self.actualCount = math.floor(self.count + (self.maxCount - self.count) * math.random())
    else
        self.actualCount = self.count
    end
    
    -- 计算每秒刷新的怪物数量
    self.spawnsPerSecond = self.actualCount / self.duration
    self.spawnedCount = 0
end

---@return MobType
function SpawningWave:GetRandomMobType()
    local selected = self.selector:Next()
    if not selected then
        print("Warning: No mob type selected from selector")
        return nil
    end
    return selected.mobType
end

---尝试生成怪物
---@param deltaTime number 距离上次更新的时间间隔
---@param level number 怪物等级
---@param multiplier number 属性倍率
---@param levelInst Level 刷怪点列表
---@return boolean 是否完成生成
---@return Monster[] 生成的怪物实例列表
function SpawningWave:TrySpawn(deltaTime, level, multiplier, levelInst)
    -- 计算这次要生成的怪物数量
    local spawnCountF = deltaTime * self.spawnsPerSecond
    local spawnCount = math.floor(spawnCountF)
    if math.random() < spawnCountF - spawnCount then
        spawnCount = spawnCount + 1
    end
    
    -- 确保不超过剩余数量
    spawnCount = math.min(spawnCount, self.actualCount - self.spawnedCount)
    
    -- 生成怪物
    local spawnedMobs = {} ---@type Mob[]
    for i = 1, spawnCount do
        local mobType = self:GetRandomMobType()
        if mobType then
            -- 随机选择一个刷怪点
            local spawnLoc
            local spawnPoints = levelInst.spawnPoints
            if spawnPoints and #spawnPoints > 0 then
                spawnLoc = spawnPoints[math.random(1, #spawnPoints)].Position
            else
                spawnLoc = Vector3.New(0, 0, 0)
                print("Warning: No spawn points available, using default position")
            end
            local mob = mobType:Spawn(spawnLoc, level, levelInst.scene)
            if mob then
                table.insert(spawnedMobs, mob)
                self.spawnedCount = self.spawnedCount + 1
            end
        end
    end
    
    -- 返回是否完成生成和生成的怪物列表
    return self.spawnedCount >= self.actualCount, spawnedMobs
end

---@class Wave:Class
---@field spawningWaves SpawningWave[]
---@field spaceChance number
---@field spaceSize number
---@field attributeMultiplier number
---@field spiritReward number
---@field totalExp number
---@field healthSum number
---@field waveHealths table<number, number> 每个波次的血量
local Wave = ClassMgr.Class("Wave")

function Wave:OnInit(data)
    self.spawningWaves = {}
    for _, waveData in ipairs(data["刷新波次"] or {}) do
        table.insert(self.spawningWaves, SpawningWave.New(waveData))
    end
    self.attributeMultiplier = data["属性倍率"] or 1
    self.spiritReward = data["给予灵蕴"] or 0
    self.totalExp = data["总计经验"] or 0
    self.healthSum = 0
    self.waveHealths = {} ---@type table<number, number>
end

function Wave:CalculateHealthSum(level)
    if self.healthSum > 0 then
        return -- 已经计算过，直接返回
    end

    self.healthSum = 0
    self.waveHealths = {}

    -- 计算每个波次的血量
    for waveIndex, wave in ipairs(self.spawningWaves) do
        local waveHealth = 0
        local weightSum = 0
        
        -- 计算权重总和
        for _, mob in ipairs(wave.mobs) do
            weightSum = weightSum + mob.weight
        end
        
        -- 计算每个怪物的血量贡献
        for _, mob in ipairs(wave.mobs) do
            local mobHealth = mob.mobType:GetStatAtLevel("生命", level)
            local healthContribution = mobHealth * self.attributeMultiplier * wave.count * mob.weight / weightSum
            waveHealth = waveHealth + healthContribution
        end
        
        -- 缓存这个波次的血量
        self.waveHealths[waveIndex] = waveHealth
        self.healthSum = self.healthSum + waveHealth
    end
end

---获取指定波次的血量
---@param waveIndex number 波次索引
---@return number 波次血量
function Wave:GetWaveHealth(waveIndex)
    if not self.waveHealths[waveIndex] then
        return 0
    end
    return self.waveHealths[waveIndex]
end

---@class LevelType:Class
---@field New fun( data:table ):LevelType
local LevelType = ClassMgr.Class("LevelType")

function LevelType:OnInit(data)
    self.levelId = data["关卡ID"] ---@type string
    self.category = data["分类"] or "" ---@type string
    self.prerequisiteLevel = data["前置关卡"] ---@type LevelType
    self.prerequisiteVars = data["前置变量"] or {} ---@type table<string, number>
    self.deductVars = data["扣除变量"] or {} ---@type table<string, number>
    self.entryPoints = data["进入位置"] or {} ---@type string[]
    self.spawnPoints = data["刷怪点"] or {} ---@type string[]
    self.maxPlayers = data["最大玩家数"] or 1 ---@type number
    self.startPlayers = data["开始玩家"] or self.maxPlayers ---@type number
    self.extraPlayerTime = data["增加额外玩家时间"] or 10 ---@type number
    self.entryConditions = data["进入条件"] or Modifiers.New({}) ---@type Modifiers
    self.twoStarDescription = data["描述_2星"] or "" ---@type string
    self.threeStarDescription = data["描述_3星"] or "" ---@type string
    self.twoStarConditions = data["条件_2星"] or Modifiers.New({}) ---@type Modifiers
    self.threeStarConditions = data["条件_3星"] or Modifiers.New({}) ---@type Modifiers
    self.monsterLevel = data["怪物等级"] or 1 ---@type number
    self.initialSpace = data["初始必加空间"] or false ---@type boolean
    self.level = data["等级"] or 1 ---@type number
    self.initialBagWidth = data["初始背包宽"] or 0 ---@type number
    self.initialBagHeight = data["初始背包高"] or 0 ---@type number

    -- 初始化匹配相关属性
    self.matchQueue = {} ---@type table<string, Player>
    self.playerCount = 0 ---@type number
    self.virtualPlayerCount = 0 ---@type number
    self.virtualPlayerTimer = 0 ---@type number

    -- 加载波次数据
    self.waves = {} ---@type Wave[]
    for _, waveData in ipairs(data["关卡波次"] or {}) do
        table.insert(self.waves, Wave.New(waveData))
    end

    -- 加载奖励数据
    self.rewards = {
        oneStar = data["完成奖励_1星"] or {},
        twoStar = data["完成奖励_2星"] or {},
        threeStar = data["完成奖励_3星"] or {}
    }

    -- 创建关卡实例
    self.levels = {}
    local Level = require(MainStorage.code.server.Scene.Level) ---@type Level
    for _, sceneData in ipairs(data["场景节点"] or {}) do
        local scene = gg.server_scene_list[sceneData["场景"]]
        local path = sceneData["路径"]
        if scene and path then
            local node = scene:Get(path)
        if node then
                table.insert(self.levels, Level.New(self, node, #self.levels + 1, scene))
            else
                print(string.format("Warning: Failed to find scene node at %s/%s", scene, path))
            end
        end
    end
end

--------------------------------------------------
-- 匹配系统相关方法
--------------------------------------------------

---检查是否可以开始游戏
---@return boolean
function LevelType:CanStartGame()
    return self.playerCount + self.virtualPlayerCount >= self.maxPlayers
end

---更新假人计数
function LevelType:UpdateVirtualPlayerCount()
    local currentTime = os.time()
    
    -- 如果真实玩家数达到开始玩家数，且距离上次更新超过额外玩家时间
    if self.playerCount >= self.startPlayers and currentTime - self.virtualPlayerTimer >= self.extraPlayerTime then
        -- 如果真实玩家数+假人数未达到最大玩家数，增加一个假人
        if self.playerCount + self.virtualPlayerCount < self.maxPlayers then
            self.virtualPlayerCount = self.virtualPlayerCount + 1
            self.virtualPlayerTimer = currentTime
            
            -- 通知队列中的玩家
            for _, player in pairs(self.matchQueue) do
                player:SendEvent("MatchProgressUpdate", {
                    currentCount = self.playerCount + self.virtualPlayerCount,
                    totalCount = self.maxPlayers
                })
            end
            
            -- 检查是否可以开始游戏
            if self:CanStartGame() then
                self:StartLevel()
            end
        end
    end
end

---加入匹配队列
---@param player Player
---@return boolean 成功进入
function LevelType:Queue(player)
    -- 如果已经在队列中，直接返回
    if self.matchQueue[player.uin] then
        player:SendChatText("你已经在匹配队列中")
        return false
    end

    local enterParam = self.entryConditions:Check(player, player)
    if enterParam.cancelled then
        player:SendChatText("不满足进入条件")
        return false
    end

    if self.prerequisiteLevel then
        -- TODO: 检查前置关卡是否完成
        -- 这里需要实现前置关卡的检查逻辑
    end

    -- 检查前置变量
    for varName, requiredValue in pairs(self.prerequisiteVars) do
        local currentValue = player:GetVariable(varName) or 0
        if currentValue < requiredValue then
            player:SendChatText(string.format("不满足前置条件: %s 需要 %d", varName, requiredValue))
            return false
        end
    end

    -- 扣除变量
    for varName, deductValue in pairs(self.deductVars) do
        local currentValue = player:GetVariable(varName) or 0
        if currentValue < deductValue then
            player:SendChatText(string.format("资源不足: %s 需要 %d", varName, deductValue))
            return false
        end
        player:AddVariable(varName, -deductValue)
    end

    -- 加入队列
    self.matchQueue[player.uin] = player
    self.playerCount = self.playerCount + 1
    player:SendChatText("已加入匹配队列")
    
    -- 重置假人计数和计时器
    self.virtualPlayerCount = 0
    self.virtualPlayerTimer = os.time()

    -- 通知所有玩家当前匹配进度
    for _, p in pairs(self.matchQueue) do
        p:SendEvent("MatchProgressUpdate", {
            currentCount = self.playerCount,
            totalCount = self.maxPlayers
        })
    end

    -- 检查是否可以开始游戏
    if self:CanStartGame() then
        self:StartLevel()
        return true
    end
    return false
end

---开始关卡
function LevelType:StartLevel()
    -- 找到一个可用的关卡实例
    local availableLevel = nil
    for _, level in ipairs(self.levels) do
        if not level.isActive then
            availableLevel = level
            break
        end
    end

    if not availableLevel then
        -- 如果没有可用的关卡实例，通知所有玩家
        for _, player in pairs(self.matchQueue) do
            player:SendChatText("当前没有可用的关卡实例，请稍后再试")
            player:SendEvent("MatchCancel")
        end
        return
    end

    -- 将队列中的玩家添加到关卡
    for _, player in pairs(self.matchQueue) do
        availableLevel:AddPlayer(player)
    end

    -- 清空匹配队列和假人计数
    self.matchQueue = {}
    self.playerCount = 0
    self.virtualPlayerCount = 0
    self.virtualPlayerTimer = 0

    -- 开始关卡
    availableLevel:Start()

    -- 通知所有玩家
    for _, player in pairs(availableLevel.players) do
        player:SendChatText("匹配成功，关卡开始！")
        player:SendEvent("MatchStart")
    end
end

---从匹配队列中移除
---@param player Player
function LevelType:LeaveQueue(player)
    if self.matchQueue[player.uin] then
        self.matchQueue[player.uin] = nil
        self.playerCount = self.playerCount - 1
        player:SendChatText("已离开匹配队列")
        player:SendEvent("MatchCancel")
        
        -- 如果真实玩家数低于开始玩家数，重置假人计数
        if self.playerCount < self.startPlayers then
            self.virtualPlayerCount = 0
            self.virtualPlayerTimer = os.time()
        end

        -- 通知剩余玩家当前匹配进度
        for _, p in pairs(self.matchQueue) do
            p:SendEvent("MatchProgressUpdate", {
                currentCount = self.playerCount,
                totalCount = self.maxPlayers
            })
        end
    end
end

-- 创建定时器更新所有关卡类型的假人计数
ServerScheduler.add(function()
    for _, levelType in pairs(LevelConfig.GetAll()) do
        levelType:UpdateVirtualPlayerCount()
    end
end, 1, 1)

return LevelType 