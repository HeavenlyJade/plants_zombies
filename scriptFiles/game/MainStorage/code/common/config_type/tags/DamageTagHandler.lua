local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local TagHandler = require(MainStorage.code.common.config_type.tags.TagHandler) ---@type TagHandler
local DamageAmplifier = require(MainStorage.code.common.config_type.modifier.DamageAmplifier) ---@type DamageAmplifier
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell


---@class DamageTag : TagHandler
local DamageTag = ClassMgr.Class("DamageTag", TagHandler)

function DamageTag:OnInit(data)
    self["影响魔法"] = data["影响魔法"] or {} ---@type string[]
    self["影响魔法关键字"] = data["影响魔法关键字"] or "" ---@type string
    self["即将击杀"] = data["即将击杀"] or false ---@type boolean
    self["要求元素类型"] = data["要求元素类型"] or "无" ---@type string
    self["增伤"] = data["增伤"] or 0 ---@type number
    self["增加暴击率"] = data["增加暴击率"] or 0 ---@type number
    self["增加暴击伤害"] = data["增加暴击伤害"] or 0 ---@type number
    self["属性增伤"] = DamageAmplifier.Load(data["属性增伤"]) ---@type DamageAmplifier[]
    self["目标属性增伤"] = DamageAmplifier.Load(data["目标属性增伤"]) ---@type DamageAmplifier[]
    self["释放魔法"] = {}
    if data["释放魔法"] then
        for _, subSpellData in ipairs(data["释放魔法"]) do
            local subSpell = SubSpell.New(subSpellData)
            table.insert(self["释放魔法"], subSpell)
        end
    end
    self["释放魔法继承威力"] = data["释放魔法继承威力"] or false ---@type boolean
    self["释放魔法威力增加"] = data["释放魔法威力增加"] or .0 ---@type number
end

function DamageTag:CanTriggerReal(caster, target, castParam, param, log)
    local battle = param ---@type Battle
    
    if battle.skipTags and battle.skipTags[self.m_tagType.id] then
        return false
    end
    
    if self["要求元素类型"] ~= "无" and battle.elementType ~= self["要求元素类型"] then
        return false
    end
    
    if self["即将击杀"] then
        if target:GetCreature().health > battle:GetFinalDamage() then
            return false
        end
    end
    
    if self["影响魔法关键字"] ~= "" then
        if not string.find(battle.source, self["影响魔法关键字"]) then
            if self.printMessage then 
                table.insert(log, string.format("%s.%s触发失败：魔法名%s不包含关键字%s", self.m_tagType.id, self.m_tagIndex, battle.source, self["影响魔法关键字"]))
            end
            return false
        end
    end
    
    if #self["影响魔法"] > 0 then
        local matchFound = false
        for _, spell in ipairs(self["影响魔法"]) do
            if spell == battle.source then
                matchFound = true
                break
            end
        end
        
        if not matchFound then
            local spellNames = {}
            for _, spell in ipairs(self["影响魔法"]) do
                table.insert(spellNames, spell)
            end
            
            if self.printMessage then 
                table.insert(log, string.format("%s.%s触发失败：魔法%s不匹配目标魔法%s", self.m_tagType.id, self.m_tagIndex, battle.source, table.concat(spellNames, ", ")))
            end
            return false
        end
    end
    
    return true
end

function DamageTag:TriggerReal(caster, target, castParam, param, log)
    local battle = param ---@type Battle
    
    -- 处理被攻击时的情况，交换施法者和目标
    if string.find(self.m_trigger, "Attacked") then
        if not target.isEntity then return false end
        local temp = caster
        caster = target:GetCreature()
        target = temp
    end
    
    local baseDamage = battle:GetFinalDamage()
    
    -- 处理增伤效果
    if self["增伤"] ~= 0 then
        local damage = self:GetUpgradeValue("增伤", castParam.power)
        battle:AddModifier(self.m_tagIndex, "倍率", damage)
        if self.printMessage then 
            table.insert(log, string.format("%s.%s：增加%.2f%%伤害", 
                self.m_tagType.id, self.m_tagIndex, damage))
        end
    end
    
    -- 处理暴击率增加
    if self["增加暴击率"] ~= 0 then
        local damage = self:GetUpgradeValue("增加暴击率", castParam.power)
        battle.critChance = battle.critChance + damage
        if self.printMessage then 
            table.insert(log, string.format("%s.%s：增加%.2f%%暴击率", 
                self.m_tagType.id, self.m_tagIndex, damage))
        end
    end
    
    -- 处理暴击伤害增加
    if self["增加暴击伤害"] ~= 0 then
        local damage = self:GetUpgradeValue("增加暴击伤害", castParam.power)
        battle.critDamage = battle.critDamage + damage
        if self.printMessage then 
            table.insert(log, string.format("%s.%s：增加%.2f%%暴击伤害", 
                self.m_tagType.id, self.m_tagIndex, damage))
        end
    end
    
    -- 处理基于自身属性的增伤
    if self["属性增伤"] then
        for _, item in ipairs(self["属性增伤"]) do
            local modifier = item:GetModifier(caster, baseDamage, 1, castParam)
            if modifier then
                battle:AddDamageModifier(modifier)
                if self.printMessage then 
                    local addType = item.addType == "增加" and "加算" or "乘算"
                    table.insert(log, string.format("%s.%s：基于自身%s=%.2f%s伤害", 
                        self.m_tagType.id, self.m_tagIndex, item.statType, modifier.amount, addType))
                end
            end
        end
    end
    
    -- 处理基于目标属性的增伤
    if self["目标属性增伤"] then
        for _, item in ipairs(self["目标属性增伤"]) do
            local modifier = item:GetModifier(target:GetCreature(), baseDamage, 1, castParam)
            if modifier then
                battle:AddDamageModifier(modifier)
                if self.printMessage then 
                    local addType = item.addType == "增加" and "加算" or "乘算"
                    table.insert(log, string.format("%s.%s：基于目标%s=%.2f%s伤害", 
                        self.m_tagType.id, self.m_tagIndex, item.statType, modifier.amount, addType))
                end
            end
        end
    end
    
    -- 处理额外释放魔法
    if #self["释放魔法"] > 0 then
        local subParam = CastParam.New({
            skipTags = {self.m_tagType.id},
            power = 1+self:GetUpgradeValue("释放魔法威力增加", castParam.power)
        })
        if self["释放魔法继承威力"] then
            subParam.power = subParam.power * battle:GetFinalDamage()
            if self.printMessage then 
                table.insert(log, string.format("%s.%s：子魔法继承威力=%.2f", self.m_tagType.id, self.m_tagIndex, subParam.power))
            end
        end
        
        for _, subSpell in ipairs(self["释放魔法"]) do
            subSpell:Cast(caster, target, subParam and gg.clone(subParam))
            if self.printMessage then 
                table.insert(log, string.format("%s.%s：释放子魔法", self.m_tagType.id, self.m_tagIndex))
            end
        end
    end
    
    return true
end

-- AttackTag子类
local AttackTag = ClassMgr.Class("AttackTag", DamageTag)
function AttackTag:OnInit(data)
    self.m_trigger = self["优先级"] > 10 and "攻击时（判断暴击后）" or "攻击时"
end

-- AttackedTag子类
local AttackedTag = ClassMgr.Class("AttackedTag", DamageTag)
function AttackedTag:OnInit(data)
    self.m_trigger = self["优先级"] > 10 and "被攻击时（判断暴击后）" or "被攻击时"
end

return DamageTag