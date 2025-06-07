local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local MobType = require(MainStorage.code.common.config_type.MobType) ---@type MobType
local MobTypeConfig = require(MainStorage.code.common.config.MobTypeConfig)  ---@type MobTypeConfig
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local Graphics = require(MainStorage.code.server.graphic.Graphics) ---@type Graphics
local ServerEventManager = require(MainStorage.code.server.event.ServerEventManager) ---@type ServerEventManager

---@class SummonSpell:Spell
---@field mobTypeName string 怪物类型名称
---@field summonRadius number 召唤范围
---@field summonAtTargetPos boolean 是否在目标位置召唤
---@field maxCount number 最大召唤数量
---@field inheritLevel boolean 是否继承施法者等级
---@field duration number 召唤物持续时间
---@field summonerSummons table<Entity, Entity[]> 召唤者与其召唤物的映射表
local SummonSpell = ClassMgr.Class("SummonSpell", Spell)

function SummonSpell:OnInit(data)
    self.summonAtTargetPos = data["召唤在目标位置"] ---@type boolean
    self.mobTypeName = data["怪物类型"] or ""
    self.maxCount = data["最大数量"] or 1
    self.summonRadius = data["召唤范围"] or 100
    self.inheritLevel = data["继承等级"]
    self.duration = data["持续时间"]
    self.summonerSummons = {}  -- 初始化召唤者-召唤物映射表
    self.projectileEffects = Graphics.Load(data["特效_召唤物"])

    -- 订阅怪物死亡事件
    ServerEventManager.Subscribe("MobDeadEvent", function(event)
        self:OnMobDead(event.mob)
    end)

    -- 订阅战斗后事件
    ServerEventManager.Subscribe("PostBattleEvent", function(event)
        self:OnPostBattle(event.battle)
    end)
end

--- 处理怪物死亡事件
---@param mob Monster 死亡的怪物
function SummonSpell:OnMobDead(mob)
    -- 遍历所有召唤者
    for summoner, summons in pairs(self.summonerSummons) do
        -- 检查死亡的怪物是否是召唤物
        for i, summoned in ipairs(summons) do
            if summoned == mob then
                -- 从列表中移除
                table.remove(summons, i)
                -- 如果召唤者没有召唤物了，清理表项
                if #summons == 0 then
                    self.summonerSummons[summoner] = nil
                end
                return
            end
        end
    end
end

--- 处理战斗后事件
---@param battle Battle 战斗实例
function SummonSpell:OnPostBattle(battle)
    -- 检查是否是主人的战斗
    local attacker = battle.attacker
    local summons = self.summonerSummons[attacker]
    if not summons then return end

    -- 如果主人有目标，让没有目标的召唤物攻击该目标
    local target = battle.victim

    -- 遍历主人的所有召唤物
    for _, summon in ipairs(summons) do
        if summon and summon.isEntity and not summon.target then
            summon:SetTarget(target)
        end
    end
end

--- 获取召唤者的召唤物数量
---@param summoner Entity 召唤者
---@return number 召唤物数量
function SummonSpell:GetSummonCount(summoner)
    if not self.summonerSummons[summoner] then
        return 0
    end
    return #self.summonerSummons[summoner]
end

--- 添加召唤物到召唤者列表
---@param summoner Entity 召唤者
---@param summoned Entity 召唤物
function SummonSpell:AddSummon(summoner, summoned)
    if not self.summonerSummons[summoner] then
        self.summonerSummons[summoner] = {}
    end
    table.insert(self.summonerSummons[summoner], summoned)

    -- 如果设置了持续时间，添加定时销毁
    if self.duration and self.duration > 0 then
        ServerScheduler.add(function()
            if summoned and summoned.isEntity then
                summoned:DestroyObject()
            end
        end, self.duration)
    end
end

--- 从召唤者列表中移除召唤物
---@param summoner Entity 召唤者
---@param summoned Entity 召唤物
function SummonSpell:RemoveSummon(summoner, summoned)
    if not self.summonerSummons[summoner] then
        return
    end
    for i, summon in ipairs(self.summonerSummons[summoner]) do
        if summon == summoned then
            table.remove(self.summonerSummons[summoner], i)
            break
        end
    end
    -- 如果召唤者没有召唤物了，清理表项
    if #self.summonerSummons[summoner] == 0 then
        self.summonerSummons[summoner] = nil
    end
end

--- 清理召唤者的所有召唤物
---@param summoner Entity 召唤者
function SummonSpell:ClearSummons(summoner)
    if not self.summonerSummons[summoner] then
        return
    end
    for _, summoned in ipairs(self.summonerSummons[summoner]) do
        if summoned and summoned.isEntity then
            summoned:DestroyObject()
        end
    end
    self.summonerSummons[summoner] = nil
end

--- 检查是否可以释放魔法
---@param caster Entity 施法者
---@param target Entity|Vector3 目标
---@param param CastParam 参数
---@param log string[] 日志数组
---@return boolean 是否可以释放
function SummonSpell:CanCast(caster, target, param, log)
    -- 检查是否达到最大召唤数量
    if self:GetSummonCount(caster) >= self.maxCount then
        if log then
            log[#log + 1] = string.format("%s：已达到最大召唤数量 %d", self.spellName, self.maxCount)
        end
        return false
    end
    -- 首先调用父类的检查
    if not Spell.CanCast(self, caster, target, param, log) then
        return false
    end
    return true
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity|Vector3 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function SummonSpell:CastReal(caster, target, param)
    -- 检查是否超过最大召唤数量
    if self:GetSummonCount(caster) >= self.maxCount then
        gg.log("[INFO] SummonSpell: 已达到最大召唤数量", self.maxCount)
        return false
    end

    -- 获取怪物类型
    local mobType = MobTypeConfig.Get(self.mobTypeName)
    if not mobType then
        gg.log("[ERROR] SummonSpell: 找不到怪物类型", self.mobTypeName)
        return false
    end

    -- 获取召唤位置
    local position
    if self.summonAtTargetPos and target then
        position = self:GetPosition(target)
    else
        position = caster:GetPosition()
    end

    -- 获取召唤参数
    local radius = param:GetValue(self, "召唤范围", self.summonRadius)
    local level = self.inheritLevel and caster.level or param:GetValue(self, "召唤等级", 1)

    -- 执行召唤
    local angle = math.random() * math.pi * 2
    local distance = math.random() * radius
    local offset = Vector3.New(
        math.cos(angle) * distance,
        0,
        math.sin(angle) * distance
    )
    local spawnPos = position + offset

    -- 延迟召唤
    local summoned = mobType:Spawn(spawnPos, level, caster.scene)
    if summoned then
        summoned:SetOwner(caster)
        self:AddSummon(caster, summoned)
    end
    self:PlayEffect(self.projectileEffects, caster, target, param)

    return true
end

return SummonSpell 