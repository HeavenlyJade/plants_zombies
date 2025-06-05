

local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local BuffSpell = require(MainStorage.code.server.spells.spell_types.BuffSpell) ---@type BuffSpell
local TagTypeConfig = require(MainStorage.code.common.config.TagTypeConfig) ---@type TagTypeConfig

---@class TagBuffSpell:BuffSpell
---@field tagTypes TagType[] 词条类型列表
local TagBuffSpell = ClassMgr.Class("TagBuffSpell", BuffSpell)

---@class TagBuff:ActiveBuff
---@field spell TagBuffSpell 魔法
local TagBuff = ClassMgr.Class("TagBuff", BuffSpell.ActiveBuff)

function TagBuffSpell:OnInit(data)
    BuffSpell.OnInit(self, data)
    
    -- 从配置中读取词条BUFF相关属性并加载词条类型
    self.tagTypes = {}
    for _, tagTypeId in ipairs(data["词条"] or {}) do
        local tagType = TagTypeConfig.Get(tagTypeId)
        if tagType then
            table.insert(self.tagTypes, tagType)
        end
    end
end

function TagBuffSpell:BuildBuff(caster, target, param)
    return TagBuff.New(caster, target, self, param)
end

function TagBuff:OnInit(caster, activeOn, spell, param)
    BuffSpell.ActiveBuff.OnInit(self, caster, activeOn, spell, param)
end

function TagBuff:OnRefresh()
    BuffSpell.ActiveBuff.OnRefresh(self)
    
    -- 为每个词条类型创建装备词条实例并添加到目标
    for _, tagType in ipairs(self.spell.tagTypes) do
        local equippingTag = tagType:FactoryEquipingTag(self.spell.spellName .. "-", self.stack * self.power)
        self.activeOn:AddTagHandler(equippingTag)
    end
end

function TagBuff:OnRemoved()
    BuffSpell.ActiveBuff.OnRemoved(self)
    self.activeOn:ResetStats(self.spell.spellName)
end

return TagBuffSpell