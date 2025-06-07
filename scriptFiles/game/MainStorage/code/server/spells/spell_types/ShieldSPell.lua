local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local Battle = require(MainStorage.code.server.Battle) ---@type Battle

---@class ShieldSpell:Spell
---@field baseShield number 基础护盾
---@field baseMultiplier number 基础倍率
---@field damageAmplifiers DamageAmplifier[] 基于释放者的属性增加护盾
---@field targetDamageAmplifiers DamageAmplifier[] 基于目标的属性增加护盾
local ShieldSpell = ClassMgr.Class("ShieldSpell", Spell)

function ShieldSpell:OnInit(data)
    self.baseShield = data.baseShield or 0
    self.baseMultiplier = data.baseMultiplier or 1
    self.damageAmplifiers = data.damageAmplifiers or {}
    self.targetDamageAmplifiers = data.targetDamageAmplifiers or {}
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function ShieldSpell:CastReal(caster, target, param)
    if not target.isEntity then return false end
    
    local battle = Battle.New(caster, target, self.spellName, nil)
    local damage = param:GetValue(self, "基础护盾", self.baseShield)
    local multiplier = param:GetValue(self, "基础倍率", self.baseMultiplier) * param.power
    
    if self.baseShield > 0 then
        battle:AddModifier("BASE", "增加", self.baseShield * multiplier)
    end
    
    -- 处理释放者属性增盾
    if #self.damageAmplifiers > 0 then
        for _, amplifier in ipairs(self.damageAmplifiers) do
            local modifier = amplifier:GetModifier(caster, damage, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    -- 处理目标属性增盾
    if #self.targetDamageAmplifiers > 0 then
        for _, amplifier in ipairs(self.targetDamageAmplifiers) do
            local modifier = amplifier:GetModifier(target, damage, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    -- 打印护盾信息
    if self.printInfo then
        local log = {}
        table.insert(log, string.format("=== %s 护盾构成 ===", self.spellName))
        
        table.insert(log, "基础护盾修饰器:")
        for _, modifier in ipairs(battle:GetBaseModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, "倍率修饰器:")
        for _, modifier in ipairs(battle:GetMultiplyModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, "最终倍率修饰器:")
        for _, modifier in ipairs(battle:GetFinalMultiplyModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, string.format("最终护盾: %s", battle:GetFinalDamage()))
        table.insert(log, "=====================")
        
        print(table.concat(log, "\n"))
    end
    
    target:AddShield(battle:GetFinalDamage(), self.spellName)
    self:PlayEffect(self.castEffects, caster, target, param)
    
    return true
end

return ShieldSpell 