
local MainStorage = game:GetService('MainStorage')
local ClassMgr      = require(MainStorage.code.common.ClassMgr)    ---@type ClassMgr


---@class Condition
local Condition = ClassMgr.Class("Condition")
function Condition:Check(modifier, caster, target)
    return true
end

---@class BetweenCondition:Condition
local BetweenCondition = ClassMgr.Class("BetweenCondition", Condition)
function BetweenCondition:OnInit(data)
    self.minValue = data["最小值"] or 0
    self.maxValue = data["最大值"] or 100
end
function BetweenCondition:CheckAmount(modifier, amount)
    return amount >= self.minValue and amount <= self.maxValue
end

---@class HealthCondition:BetweenCondition
local HealthCondition = ClassMgr.Class("HealthCondition", BetweenCondition)
function HealthCondition:OnInit(data)
    BetweenCondition.OnInit(self, data)
    self.isPercentage = data["百分比"] == nil and true or data["百分比"]
end
function HealthCondition:Check(modifier, caster, target)
    if target == nil or not target.isEntity then return false end
    local amount
    local creature = target ---@cast creature Entity
    if self.isPercentage then
        amount = 100 * creature.health / target:GetStat("Health")
    else
        amount = creature.health
    end
    gg.log("HealthCondition", amount, self.minValue, self.maxValue)
    return self:CheckAmount(modifier, amount)
end

---@class VariableCondition:BetweenCondition
local VariableCondition = ClassMgr.Class("VariableCondition", BetweenCondition)
function VariableCondition:OnInit(data)
    BetweenCondition.OnInit(self, data)
    self.name = data["名字"]
end
function VariableCondition:Check(modifier, caster, target)
    if not target.isEntity then return false end
    local creature = target ---@cast creature Entity
    local amount = creature:GetVariable(self.name)
    return self:CheckAmount(modifier, amount)
end

---@class StatCondition:BetweenCondition
local StatCondition = ClassMgr.Class("StatCondition", BetweenCondition)
function StatCondition:OnInit(data)
    BetweenCondition.OnInit(self, data)
    self.name = data["名字"]
end
function StatCondition:Check(modifier, caster, target)
    local amount = target:GetStat(self.name)
    return self:CheckAmount(modifier, amount)
end

---@class PositionCondition:BetweenCondition
local PositionCondition = ClassMgr.Class("PositionCondition", BetweenCondition)
function PositionCondition:Check(modifier, caster, target)
    error("InvalidImplementationException")
end

---@class ChanceCondition:Condition
local ChanceCondition = ClassMgr.Class("ChanceCondition", Condition)
function ChanceCondition:OnInit(data)
    self.minValue = data["最小值"] or 0
end
function ChanceCondition:Check(modifier, caster, target)
    if self.minValue >= 100 then return true end
    return math.random() < self.minValue / 100.0
end

---@class BuffActiveCondition:BetweenCondition
local BuffActiveCondition = ClassMgr.Class("BuffActiveCondition", BetweenCondition)
function BuffActiveCondition:OnInit(data)
    BetweenCondition.OnInit(self, data)
    self.buffKeyword = data["Buff关键字"]
end
function BuffActiveCondition:Check(modifier, caster, target)
    if not target.isEntity then return false end
    local creature = target ---@cast creature Entity
    
    if self.buffKeyword == nil or self.buffKeyword == "" then
        local totalStacks = 0
        for _, buff in pairs(creature.activeBuffs) do
            totalStacks = totalStacks + buff.stack
        end
        return self:CheckAmount(modifier, totalStacks)
    end

    local stacks = 0
    for _, buff in pairs(creature.activeBuffs) do
        if string.find(buff.spell.spellName, self.buffKeyword) then
            stacks = stacks + buff.stack
        end
    end
    return self:CheckAmount(modifier, stacks)
end

---@class TagLevelCondition:BetweenCondition
local TagLevelCondition = ClassMgr.Class("TagLevelCondition", BetweenCondition)
function TagLevelCondition:OnInit(data)
    BetweenCondition.OnInit(self, data)
    self.tagName = data["词条名"]
end
function TagLevelCondition:Check(modifier, caster, target)
    if target == nil or not target.isEntity then return false end
    local targetCreature = target ---@cast creature Entity
    print(string.format("TagLevelCondition %s %s %s", targetCreature.name, self.tagName, table.concat(targetCreature.tagIds, ",")))
    local tag = targetCreature:GetTag(self.tagName)
    if tag ~= nil then
        print(string.format("TagLevelCondition %s %d", self.tagName, tag.level))
        return self:CheckAmount(modifier, tag.level)
    end
    return false
end

---@class ShieldCondition:BetweenCondition
local ShieldCondition = ClassMgr.Class("ShieldCondition", BetweenCondition)
function ShieldCondition:OnInit(data)
    BetweenCondition.OnInit(self, data)
    self.isPercentage = data["百分比"] == nil and true or data["百分比"]
end
function ShieldCondition:Check(modifier, caster, target)
    if target == nil or not target.isEntity then return false end
    local amount
    local creature = target ---@cast creature Entity
    if self.isPercentage then
        amount = 100 * creature.shield / target:GetStat("Health")
    else
        amount = creature.shield
    end
    return self:CheckAmount(modifier, amount)
end

return {
    CONDITION = CONDITION,
    Condition = Condition,
    BetweenCondition = BetweenCondition,
    HealthCondition = HealthCondition,
    VariableCondition = VariableCondition,
    StatCondition = StatCondition,
    PositionCondition = PositionCondition,
    ChanceCondition = ChanceCondition,
    BuffActiveCondition = BuffActiveCondition,
    TagLevelCondition = TagLevelCondition,
    ShieldCondition = ShieldCondition
}