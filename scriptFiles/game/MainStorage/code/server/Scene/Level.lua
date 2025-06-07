local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local LevelType = require(MainStorage.code.common.config_type.LevelType) ---@type LevelType
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local ServerEventManager = require(MainStorage.code.server.event.ServerEventManager) ---@type ServerEventManager

---@class Level
---@field New fun( levelType:LevelType, scene:Scene, index:number ):Level
local Level = ClassMgr.Class("Level")

---@param levelType LevelType
function Level:OnInit(levelType, scene, index)
    self.scene = scene ---@type Scene
    local sceneNode = scene.node
    self.levelType = levelType
    -- 玩家进入点
    self.entries = {} ---@type Transform[]
    for _, entryPath in ipairs(levelType.entryPoints) do
        local node = gg.GetChild(sceneNode, entryPath) ---@cast node Transform
        if node then
            table.insert(self.entries, node)
        end
    end
    -- 怪物刷新点
    self.spawnPoints = {} ---@type Transform[]
    for _, spawnPath in ipairs(levelType.spawnPoints) do
        local node = gg.GetChild(sceneNode, spawnPath) ---@cast node Transform
        if node then
            table.insert(self.spawnPoints, node)
        end
    end
    
    -- 运行时状态
    self.players = {} ---@type table<string, Player>
    self.playerOriginalPositions = {} ---@type table<string, {position:Vector3, euler:Vector3}>
    self.isActive = false
    self.startTime = 0
    self.endTime = 0
    self.currentStars = 0

    -- 波次相关
    self.currentWave = nil ---@type Wave
    self.allWaves = {} ---@type Wave[]
    self.spawningWaves = {} ---@type SpawningWave[]
    self.notSpawningWaves = {} ---@type SpawningWave[]
    self.waveStartTime = 0
    self.timeElapsed = 0
    self.waveCount = 0
    self.mobCount = {} ---@type table<string, number>
    self.updateTask = nil ---@type number

    -- 怪物相关
    self.activeMobs = {} ---@type table<string, Monster>
    self.currentWaveHealth = 0 ---@type number
    self.remainingWaveHealth = 0 ---@type number
    
    -- 监听怪物死亡事件
    ServerEventManager.Subscribe("MobDeadEvent", function(data)
        if data.mob and self.activeMobs[data.mob.uuid] then
            -- 扣除怪物生命值
            local mobHealth = data.mob:GetStat("生命")
            self.remainingWaveHealth = math.max(0, self.remainingWaveHealth - mobHealth)
            
            -- 计算并同步剩余生命百分比
            local healthPercent = self.currentWaveHealth > 0 and (self.remainingWaveHealth / self.currentWaveHealth) or 0
            for _, player in pairs(self.players) do
                player:SendEvent("WaveHealthUpdate", {
                    waveIndex = self.waveCount,
                    healthPercent = healthPercent
                })
            end
            
            self.activeMobs[data.mob.uuid] = nil
            
            -- 检查波次是否结束
            if #self.spawningWaves == 0 and #self.notSpawningWaves == 0 then
                self:OnWaveEnd()
            end
        end
    end)
end

---开始关卡
function Level:Start()
    if self.isActive then return end
    self.isActive = true
    self.startTime = os.time()
    self.currentStars = 0

    -- 计算所有波次的生命值
    local waveHealths = {} ---@type table<number, number>
    local totalHealth = 0
    for _, wave in ipairs(self.levelType.waves) do
        wave:CalculateHealthSum(self.levelType.monsterLevel)
        table.insert(waveHealths, wave.healthSum)
        totalHealth = totalHealth + wave.healthSum
    end

    -- 将玩家传送到进入点
    local playerIndex = 1
    for _, player in pairs(self.players) do
        -- 保存玩家原始位置
        if player.actor then
            self.playerOriginalPositions[player.uin] = {
                position = player.actor.Position,
                euler = player.actor.Euler
            }
        end
        
        -- 获取进入点位置
        local entryPoint = self.entries[playerIndex]
        if not entryPoint then
            playerIndex = 1
            -- 如果没有足够的进入点，循环使用
            entryPoint = self.entries[playerIndex]
        end
        
        -- 传送玩家
        if player.actor and entryPoint then
            player.actor.Position = entryPoint.Position
            player.actor.Euler = entryPoint.Euler
            player:SetCameraView(entryPoint.Euler)
            player:SendChatText("已传送到进入点")
            player:EnterBattle()
        end
        
        -- 发送战斗开始事件
        player:SendEvent("BattleStartEvent", {
            levelId = self.levelType.levelId,
            waveHealths = waveHealths,
            totalHealth = totalHealth
        })
        
        playerIndex = playerIndex + 1
    end

    -- 初始化波次
    self:InitializeWaves()
    -- 开始第一波
    self:StartWave()
    -- 启动更新任务
    self:StartUpdateTask()
end

---初始化波次
function Level:InitializeWaves()
    self.allWaves = self.levelType.waves
    self.waveCount = 0
    self.mobCount = {}
end

---开始波次
function Level:StartWave()
    if #self.allWaves == 0 then
        self:OnLevelComplete()
        return
    end

    self.waveStartTime = os.time()
    self.timeElapsed = self.waveStartTime
    self.currentWave = table.remove(self.allWaves, 1)
    self.waveCount = self.waveCount + 1

    -- 计算当前波次的总生命值
    self.currentWave:CalculateHealthSum(self.levelType.monsterLevel)
    self.currentWaveHealth = self.currentWave.healthSum
    self.remainingWaveHealth = self.currentWaveHealth

    -- 初始化未开始的刷怪波次
    self.notSpawningWaves = {}
    for _, wave in ipairs(self.currentWave.spawningWaves) do
        table.insert(self.notSpawningWaves, wave)
    end

    -- 通知玩家波次开始和初始血量
    for _, player in pairs(self.players) do
        player:SendChatText(string.format("Wave %d started!", self.waveCount))
        player:SendEvent("WaveHealthUpdate", {
            waveIndex = self.waveCount,
            healthPercent = 1.0
        })
    end
end

---启动更新任务
function Level:StartUpdateTask()
    if self.updateTask then
        ServerScheduler.cancel(self.updateTask)
    end

    self.updateTask = ServerScheduler.add(function()
        self:Update()
    end, 0, 1.0) -- 立即开始，每秒执行一次
end

---更新关卡状态
function Level:Update()
    if not self.isActive or not self.currentWave then return end
    local newTimeElapsed = os.time() - self.waveStartTime

    -- 检查是否需要开始新的刷怪波次
    for i = #self.notSpawningWaves, 1, -1 do
        local wave = self.notSpawningWaves[i]
        if wave.startTime < newTimeElapsed then
            table.insert(self.spawningWaves, wave)
            table.remove(self.notSpawningWaves, i)
        end
    end

    -- 更新所有正在进行的刷怪波次
    for i = #self.spawningWaves, 1, -1 do
        local wave = self.spawningWaves[i]
        local isComplete, spawnedMobs = wave:TrySpawn(newTimeElapsed - self.timeElapsed, self.levelType.monsterLevel, self.currentWave.attributeMultiplier, self)
        
        -- 处理生成的怪物
        for _, mob in ipairs(spawnedMobs) do
            -- 缓存怪物实例
            self.activeMobs[mob.uuid] = mob
            
            -- 随机选择一个玩家作为目标
            local players = {}
            for _, player in pairs(self.players) do
                table.insert(players, player)
            end
            if #players > 0 then
                local randomPlayer = players[math.random(1, #players)]
                mob:SetTarget(randomPlayer)
            end
        end
        
        if isComplete then
            table.remove(self.spawningWaves, i)
        end
    end

    self.timeElapsed = newTimeElapsed
end

---波次结束
function Level:OnWaveEnd()
    -- 发放奖励
    for _, player in pairs(self.players) do
        player:AddStat("Spirit", self.currentWave.spiritReward)
    end

    -- 通知玩家
    for _, player in pairs(self.players) do
        player:SendChatText(string.format("Wave %d completed!", self.waveCount))
    end

    -- 开始下一波
    self:StartWave()
end

---关卡完成
function Level:OnLevelComplete()
    -- 计算星级
    local star = 1
    -- if self.levelType.twoStarConditions then
    --     local param = self.levelType.twoStarConditions:Check()
    --     if param.cancelled then star = star + 1 end
    -- else
    --     star = star + 1
    -- end

    -- if self.levelType.threeStarConditions then
    --     local param = CastParam.New()
    --     for _, condition in ipairs(self.levelType.threeStarConditions) do
    --         local stop = condition:Check(self.players[1], self.players[1], param)
    --         if stop then break end
    --     end
    --     if param.cancelled then star = star + 1 end
    -- else
    --     star = star + 1
    -- end

    -- -- 通知服务器
    -- gg.network_channel:fireServer("level", "finish", {
    --     id = self.levelType.levelId,
    --     stars = star,
    --     mobCount = self.mobCount
    -- })

    -- 结束关卡
    self:End(true)
end

---结束关卡
---@param success boolean 是否成功完成
function Level:End(success)
    if not self.isActive then return end
    self.isActive = false
    self.endTime = os.time()
    
    if self.updateTask then
        ServerScheduler.cancel(self.updateTask)
        self.updateTask = nil
    end

    -- 传送玩家回原始位置
    for _, player in pairs(self.players) do
        local originalPos = self.playerOriginalPositions[player.uin]
        if player.actor and originalPos then
            player.actor.Position = originalPos.position
            player.actor.Euler = originalPos.euler
            player:SetCameraView(originalPos.euler)
            player:ExitBattle()
            player:SendChatText("已传送回原位置")
        end
    end

    self:Cleanup()
    for _, player in pairs(self.players) do
        player:SendEvent("BattleEndEvent", {
            levelId = self.levelType.levelId,
            success = success,
            stars = self.currentStars,
            duration = self.endTime - self.startTime
        })
        player:SendChatText(success and "Level completed!" or "Level failed!")
    end
end

---清理场景
function Level:Cleanup()
    -- 清理所有怪物
    for _, mob in pairs(self.activeMobs) do
        mob:DestroyObject()
    end
    self.activeMobs = {}
    
    -- 清理掉落物
    -- TODO: 实现掉落物清理
end

---添加玩家
---@param player Player
function Level:AddPlayer(player)
    if #self.players >= self.levelType.maxPlayers then
        return false
    end
    self.players[player.uin] = player
    return true
end

---移除玩家
---@param player Player
function Level:RemovePlayer(player)
    self.players[player.uin] = nil
end

---检查是否满足进入条件
---@param player Player
---@return boolean
function Level:CheckEntryConditions(player)
    local castParam = self.levelType.entryConditions:Check(player, player)
    return not castParam.cancelled
end

---检查是否满足星级条件
---@param starLevel number 1-3星
---@return boolean
function Level:CheckStarConditions(starLevel)
    -- TODO: 实现星级条件检查
    return false
end

return Level