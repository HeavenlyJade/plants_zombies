

local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local BuffSpell = require(MainStorage.code.server.spells.spell_types.BuffSpell) ---@type BuffSpell

---@class AttributeBuffSpell:BuffSpell
---@field statType string 属性类型
---@field statValue number 属性值
---@field isPercentage boolean 百分比
local AttributeBuffSpell = ClassMgr.Class("AttributeBuffSpell", BuffSpell)

---@class AttrBuff:ActiveBuff
---@field spell AttributeBuffSpell 魔法
local AttrBuff = ClassMgr.Class("AttrBuff", BuffSpell.ActiveBuff)

function AttributeBuffSpell:OnInit(data)
    
    -- 从配置中读取属性BUFF相关属性
    self.statType = data["属性类型"]
    self.statValue = data["属性值"] or 0
    self.isPercentage = data["百分比"] or true
end

function AttributeBuffSpell:BuildBuff(caster, target, param)
    return AttrBuff.New(caster, target, self, param)
end

function AttrBuff:OnInit(caster, activeOn, spell, param)
    BuffSpell.ActiveBuff.OnInit(self, caster, activeOn, spell, param)
end

function AttrBuff:OnRefresh()
    BuffSpell.ActiveBuff.OnRefresh(self)
    
    local amount = self.spell.statValue * self.stack * self.power
    
    if self.spell.isPercentage then
        -- 获取基础属性值（BASE、EQUIP、CHIP）
        local baseValue = self.activeOn:GetStat(self.spell.statType, {"BASE", "EQUIP", "CHIP"}, true, self.param)
        amount = amount * baseValue / 100
    end
    
    -- 重置之前的属性加成
    self.activeOn:ResetStats(self.spell.spellName)
    -- 添加新的属性加成
    self.activeOn:AddStat(self.spell.statType, amount, self.spell.spellName)
end

function AttrBuff:OnRemoved()
    BuffSpell.ActiveBuff.OnRemoved(self)
    self.activeOn:ResetStats(self.spell.spellName)
end

return AttributeBuffSpell