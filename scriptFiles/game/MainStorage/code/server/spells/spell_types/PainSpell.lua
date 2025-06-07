local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local Battle            = require(MainStorage.code.server.Battle)    ---@type Battle
local gg = require(MainStorage.code.common.MGlobal)    ---@type gg
local DamageAmplifier = require(MainStorage.code.common.config_type.modifier.DamageAmplifier) ---@type DamageAmplifier


---@class PainSpell:Spell
---@field baseDamage number 基础伤害
---@field baseMultiplier number 基础倍率
---@field extraStats table<string, number> 额外属性
---@field elementType string 元素类型
---@field damageAmplifier DamageAmplifier[] 基于释放者的属性增加伤害
---@field targetDamageAmplifier DamageAmplifier[] 基于目标的属性增加伤害
local PainSpell = ClassMgr.Class("PainSpell", Spell)

function PainSpell:OnInit(data)
    self.baseDamage = data["基础伤害"] or 0
    self.baseMultiplier = data["基础倍率"] or 1
    self.extraStats = data["额外属性"] or {}
    self.elementType = data["元素类型"] or "无"
    self.damageAmplifier = DamageAmplifier.Load(data["属性增伤"]) ---@type DamageAmplifier[]
    self.targetDamageAmplifier = DamageAmplifier.Load(data["目标属性增伤"]) ---@type DamageAmplifier[]
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function PainSpell:CastReal(caster, target, param)
    if not target.isEntity then return false end
    
    local damage = param:GetValue(self, "基础伤害", self.baseDamage)
    local multiplier = param:GetValue(self, "基础倍率", self.baseMultiplier) * param.power
    
    -- 添加临时属性
    if next(self.extraStats) then
        for statName, statValue in pairs(self.extraStats) do
            caster:AddStat(statName, statValue, "TEMP")
        end
    end
    
    local battle = Battle.New(caster, target, self.spellName, nil)
    battle.skipTags = param.skipTags
    battle.elementType = self.elementType
    
    if damage > 0 then
        battle:AddModifier("BASE", "增加", damage * multiplier)
    end
    
    -- 处理释放者属性增伤
    gg.log("self.damageAmplifier", self.spellName, self.damageAmplifier)
    if self.damageAmplifier then
        for _, amplifier in ipairs(self.damageAmplifier) do
            local modifier = amplifier:GetModifier(caster, damage, multiplier, param)
            gg.log("属性增伤", modifier)
            if modifier then
                battle:AddModifier(modifier.source, modifier.modifierType, modifier.amount)
            end
        end
    end
    
    
    -- 处理目标属性增伤
    if self.targetDamageAmplifier then
        for _, amplifier in ipairs(self.targetDamageAmplifier) do
            local modifier = amplifier:GetModifier(target, damage, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    local attackBattle = caster:Attack(target, battle:GetFinalDamage(), self.spellName)
    
    -- 打印伤害信息
    if self.printInfo then
        local log = {}
        table.insert(log, string.format("=== %s 伤害构成 ===", self.spellName))
        
        table.insert(log, "基础伤害修饰器:")
        for _, modifier in ipairs(attackBattle:GetBaseModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, "倍率修饰器:")
        for _, modifier in ipairs(attackBattle:GetMultiplyModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, "最终倍率修饰器:")
        for _, modifier in ipairs(attackBattle:GetFinalMultiplyModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, string.format("最终伤害: %s", attackBattle:GetFinalDamage()))
        table.insert(log, "=====================")
        
        print(table.concat(log, "\n"))
    end
    
    -- 重置临时属性
    if next(self.extraStats) then
        caster:ResetStats("TEMP")
    end
    
    self:PlayEffect(self.castEffects, caster, target, param)
    
    return true
end

return PainSpell
