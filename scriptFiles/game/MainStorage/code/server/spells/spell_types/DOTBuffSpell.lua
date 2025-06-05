

local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local BuffSpell = require(MainStorage.code.server.spells.spell_types.BuffSpell) ---@type BuffSpell
local Battle = require(MainStorage.code.server.Battle) ---@type Battle
local DamageAmplifier = require(MainStorage.code.common.config_type.modifier.DamageAmplifier) ---@type DamageAmplifier

---@class DOTBuffSpell:BuffSpell
---@field baseDamage number 基础伤害
---@field baseMultiplier number 基础倍率
---@field extraStats table<string, number> 额外属性
---@field damageAmplifiers DamageAmplifier[] 属性增伤
---@field targetDamageAmplifiers DamageAmplifier[] 目标属性增伤
---@field pulseTime number 脉冲时间
local DOTBuffSpell = ClassMgr.Class("DOTBuffSpell", BuffSpell)

---@class DOTBuff:ActiveBuff
---@field spell DOTBuffSpell 魔法
---@field damagePerSecond number 每秒伤害
---@field isCrit boolean 是否暴击
local DOTBuff = ClassMgr.Class("DOTBuff", BuffSpell.ActiveBuff)

function DOTBuffSpell:OnInit(data)
    BuffSpell.OnInit(self, data)
    
    -- 从配置中读取DOT相关属性
    self.baseDamage = data["基础伤害"] or 0
    self.baseMultiplier = data["基础倍率"] or 1
    self.extraStats = data["额外属性"] or {}
    self.damageAmplifier = DamageAmplifier.Load(data["属性增伤"]) ---@type DamageAmplifier[]
    self.targetDamageAmplifier = DamageAmplifier.Load(data["目标属性增伤"]) ---@type DamageAmplifier[]
    self.pulseTime = data["脉冲时间"] or 0
end

function DOTBuffSpell:BuildBuff(caster, target, param)
    return DOTBuff.New(caster, target, self, param)
end

function DOTBuffSpell:GetDamage(caster, target, power, param)
    if target.isDestroyed then return nil end
    
    local damage = param:GetValue(self, "基础伤害", self.baseDamage)
    local multiplier = param:GetValue(self, "基础倍率", self.baseMultiplier) * power
    
    -- 应用额外属性
    if next(self.extraStats) then
        for statName, statValue in pairs(self.extraStats) do
            caster:AddStat(statName, statValue, "TEMP")
        end
    end
    
    local battle = Battle.New(caster, target, self.spellName)
    
    -- 添加基础伤害
    if self.baseDamage > 0 then
        battle:AddModifier("BASE", "增加", damage * multiplier)
    end
    
    -- 添加属性增伤
    if self.damageAmplifiers then
        for _, amplifier in ipairs(self.damageAmplifiers) do
            local modifier = amplifier:GetModifier(caster, damage, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    -- 添加目标属性增伤
    if self.targetDamageAmplifiers then
        for _, amplifier in ipairs(self.targetDamageAmplifiers) do
            local modifier = amplifier:GetModifier(target, damage, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    battle:CalculateBattle()
    return battle
end

function DOTBuff:OnInit(caster, activeOn, spell, param)
    BuffSpell.ActiveBuff.OnInit(self, caster, activeOn, spell, param)
    self.maxPulseTime = spell.pulseTime
end

function DOTBuff:OnRefresh()
    BuffSpell.ActiveBuff.OnRefresh(self)
    
    local battle = self.spell:GetDamage(self.caster, self.activeOn, self.power * self.stack, self.param)
    if not battle then
        self:SetDisabled(true)
        return
    end
    
    self.damagePerSecond = battle:GetFinalDamage() / (self.spell.duration / self.spell.pulseTime)
    self.isCrit = battle.isCrit

    if self.spell.printInfo then
        print(string.format("%s: DOT伤害更新 - 目标:%s 每秒伤害:%.1f 是否暴击:%s", 
            self.spell.spellName, self.activeOn.name, self.damagePerSecond, tostring(self.isCrit)))
    end
end

function DOTBuff:OnRemoved()
    BuffSpell.ActiveBuff.OnRemoved(self)
    self.activeOn:ResetStats(self.spell.spellName)
end

function DOTBuff:OnPulse()
    BuffSpell.ActiveBuff.OnPulse(self)
    self.activeOn:Hurt(self.damagePerSecond, self.caster, self.isCrit)
    
    if self.spell.printInfo then
        print(string.format("%s: DOT造成伤害 - 目标:%s 伤害:%.1f 是否暴击:%s", 
            self.spell.spellName, self.activeOn.name, self.damagePerSecond, tostring(self.isCrit)))
    end
end

return DOTBuffSpell