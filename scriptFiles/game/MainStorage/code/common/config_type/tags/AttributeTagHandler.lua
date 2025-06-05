local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local TagHandler = require(MainStorage.code.common.config_type.tags.TagHandler) ---@type TagHandler
local DamageAmplifier = require(MainStorage.code.common.config_type.modifier.DamageAmplifier) ---@type DamageAmplifier
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam

---@class AttributeTag : TagHandler
local AttributeTag = ClassMgr.Class("AttributeTag", TagHandler)

function AttributeTag:OnInit(data)
    -- 初始化父类
    TagHandler.OnInit(self, data)
    
    -- 初始化AttributeTag特有属性
    self["属性"] = data["属性"] or "" ---@type string
    self["增加"] = data["增加"] or 0 ---@type number
    self["百分比"] = data["百分比"] or false ---@type boolean
    self["属性增伤"] = DamageAmplifier.Load(data["属性增伤"]) ---@type DamageAmplifier[]
    self["目标属性增伤"] = DamageAmplifier.Load(data["目标属性增伤"]) ---@type DamageAmplifier[]
    
    -- 设置触发类型
    self.m_trigger = self["属性"]
end

function AttributeTag:TriggerReal(caster, target, castParam, param, log)
    local battle = param ---@type Battle
    
    -- 处理基础属性增加
    if self["增加"] ~= 0 then
        local amount = self:GetUpgradeValue("增加", castParam.power)
        local modifyType = self["百分比"] and "倍率" or "增加"
        battle:AddModifier(self.m_tagType.id, modifyType, amount)
        
        if self.printMessage then
            table.insert(log, string.format("%s.%s：%s增加%.2f%s", self.m_tagType.id, self.m_tagIndex, self["百分比"] and "百分比" or "固定值", amount, self["属性"]))
        end
    end
    
    -- 处理基于自身属性的增伤
    if self["属性增伤"] then
        for _, item in ipairs(self["属性增伤"]) do
            local modifier = item:GetModifier(caster, 0, 1 + castParam.power, castParam)
            if modifier then
                local modifierName = string.format("%s_自身_%s", self.m_tagType.id, item.statType)
                battle:AddModifier(modifierName, modifier.modifierType, modifier.amount)
                
                if self.printMessage then
                    table.insert(log, string.format("%s.%s：基于自身%s=%.2f增加%s", self.m_tagType.id, self.m_tagIndex, item.statType, modifier.amount, self["属性"]))
                end
            end
        end
    end
    
    -- 处理基于目标属性的增伤
    if self["目标属性增伤"] then
        for _, item in ipairs(self["目标属性增伤"]) do
            local modifier = item:GetModifier(target:GetCreature(), 0, 1 + castParam.power, castParam)
            if modifier then
                local modifierName = string.format("%s_目标_%s", self.m_tagType.id, item.statType)
                battle:AddModifier(modifierName, modifier.modifierType, modifier.amount)
                
                if self.printMessage then
                    table.insert(log, string.format("%s.%s：基于目标%s=%.2f增加%s", self.m_tagType.id, self.m_tagIndex, item.statType, modifier.amount, self["属性"]))
                end
            end
        end
    end
    
    return true
end

return AttributeTag