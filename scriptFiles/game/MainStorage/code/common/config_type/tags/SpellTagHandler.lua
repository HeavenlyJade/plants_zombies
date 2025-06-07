local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local TagHandler = require(MainStorage.code.common.config_type.tags.TagHandler) ---@type TagHandler
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local Battle = require(MainStorage.code.server.Battle) ---@type Battle
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell

---@class SpellTag : TagHandler
local SpellTag = ClassMgr.Class("SpellTag", TagHandler)

function SpellTag:OnInit(data)
    -- 初始化SpellTag特有属性
    self["影响魔法"] = data["影响魔法"] or {} ---@type string[]
    self["影响魔法关键字"] = data["影响魔法关键字"] or "" ---@type string
    self["威力增加"] = data["威力增加"] or 0 ---@type number
    self["威力增加表达式"] = data["威力增加表达式"] or "" ---@type string
    self["取消"] = data["取消"] or false ---@type boolean
    self["修改数值"] = data["修改数值"] or {} ---@type OverrideValue[]
    self["复写参数"] = data["复写参数"] or {} ---@type OverrideParam[]
    self["释放魔法"] = {}
    if data["释放魔法"] then
        for _, subSpellData in ipairs(data["释放魔法"]) do
            local subSpell = SubSpell.New(subSpellData)
            table.insert(self["释放魔法"], subSpell)
        end
    end
    self["释放魔法继承威力"] = data["释放魔法继承威力"] or false ---@type boolean
end

function SpellTag:CanTriggerReal(caster, target, castParam, param, log)
    local spell = param[1] ---@type Spell
    local spellParam = param[2] ---@type CastParam
    
    -- 检查魔法关键字
    if self["影响魔法关键字"] ~= "" then
        if not string.find(spell.spellName, self["影响魔法关键字"]) then
            if self.printMessage then
                table.insert(log, string.format("%s.%s触发失败：魔法名%s不包含关键字%s", self.m_tagType.id, self.m_tagIndex, spell.spellName, self["影响魔法关键字"]))
            end
            return false
        end
    end
    
    -- 检查影响魔法列表
    if #self["影响魔法"] > 0 then
        local matchFound = false
        for _, spellName in ipairs(self["影响魔法"]) do
            if spellName == spell.spellName then
                matchFound = true
                break
            end
        end
        
        if not matchFound then
            if self.printMessage then
                table.insert(log, string.format("%s.%s触发失败：魔法%s不在影响魔法列表中", self.m_tagType.id, self.m_tagIndex, spell.spellName))
            end
            return false
        end
    end
    
    return true
end

function SpellTag:TriggerReal(caster, target, castParam, param, log)
    local spell = param[1] ---@type Spell
    local spellParam = param[2] ---@type CastParam
    
    -- 处理被释放魔法时的情况，交换施法者和目标
    if self.m_trigger == "被释放魔法时" then
        if not target.isEntity then return false end
        local temp = caster
        caster = target:GetCreature()
        target = temp
        if self.printMessage then
            table.insert(log, string.format("%s.%s：交换攻受位置", self.m_tagType.id, self.m_tagIndex))
        end
    end
    
    -- 处理取消魔法
    if self["取消"] then
        spellParam.cancelled = true
        if self.printMessage then
            table.insert(log, string.format("%s.%s：取消魔法释放", self.m_tagType.id, self.m_tagIndex))
        end
    end
    
    -- 应用威力加成
    spellParam.power = spellParam.power * castParam.power
    
    -- 处理威力增加
    if self["威力增加"] ~= 0 then
        local addPower = self:GetUpgradeValue("威力增加", castParam.power) / 100.0
        spellParam.power = spellParam.power + addPower
        if self.printMessage then
            table.insert(log, string.format("%s.%s：增加%.2f%%威力", self.m_tagType.id, self.m_tagIndex, addPower * 100))
        end
    elseif self["威力增加表达式"] ~= "" then
        local addPower = caster:CalculateValue(self["威力增加表达式"], target:GetCreature(), self.printMessage) * (1 + castParam.power) / 100.0
        spellParam.power = spellParam.power + addPower
        if self.printMessage then
            table.insert(log, string.format("%s.%s：增加%.2f%%威力", self.m_tagType.id, self.m_tagIndex, addPower * 100))
        end
    end
    
    -- 合并castParam中的extraModifiers到spellParam
    for key, modifier in pairs(castParam.extraModifiers) do
        if not spellParam.extraModifiers[key] then
            spellParam.extraModifiers[key] = Battle.New(caster, caster, key)
        end
        spellParam.extraModifiers[key]:AddModifier(self.m_tagType.id, "增加", modifier:GetFinalDamage())
        
        if self.printMessage then
            table.insert(log, string.format("%s.%s：合并修改数值 %s", self.m_tagType.id, self.m_tagIndex, key))
        end
    end
    
    -- 合并castParam中的extraParams到spellParam
    for key, value in pairs(castParam.extraParams) do
        spellParam.extraParams[key] = value
        if self.printMessage then
            table.insert(log, string.format("%s.%s：合并复写参数 %s = %s", self.m_tagType.id, self.m_tagIndex, key, tostring(value)))
        end
    end
    
    -- 处理修改数值
    for _, modifier in ipairs(self["修改数值"]) do
        if modifier.paramName then
            local name
            if not modifier.objectName or modifier.isAlways then
                name = modifier.paramName
            else
                name = string.format("%s.%s", modifier.objectName, modifier.paramName)
            end
            
            if not spellParam.extraModifiers[name] then
                spellParam.extraModifiers[name] = ClassMgr.New("Battle", {caster, caster, name})
            end
            
            spellParam.extraModifiers[name]:AddModifier(
                self.m_tagType.id, 
                modifier.paramValue.addType, 
                modifier.paramValue.multiplier
            )
            
            if self.printMessage then
                table.insert(log, string.format("%s.%s：修改%s的%s为%.2f", 
                    self.m_tagType.id, self.m_tagIndex, 
                    name, modifier.paramValue.addType, modifier.paramValue.multiplier))
            end
        end
    end
    
    -- 处理复写参数
    for _, modifier in ipairs(self["复写参数"]) do
        ---@cast modifier OverrideParam
        if modifier.paramName then
            local name
            if not modifier.objectName then
                name = modifier.paramName
            else
                name = string.format("%s.%s", modifier.objectName, modifier.paramName)
            end
            
            spellParam.extraParams[name] = modifier.value
            if self.printMessage then
                table.insert(log, string.format("%s.%s：复写%s为%s", 
                    self.m_tagType.id, self.m_tagIndex, name, tostring(modifier.value)))
            end
        end
    end
    
    -- 处理额外释放魔法
    if #self["释放魔法"] > 0 then
        local subParam = CastParam.New({
            skipTags = {self.m_tagType.id},
            power = 1.0
        })
        
        if self["释放魔法继承威力"] then
            subParam.power = spellParam.power
        end
        
        for _, subSpell in ipairs(self["释放魔法"]) do
            subSpell:Cast(caster, target, subParam)
            if self.printMessage then
                table.insert(log, string.format("%s.%s：%s=>%s释放子魔法%s", 
                    self.m_tagType.id, self.m_tagIndex, 
                    tostring(caster), tostring(target), subSpell.spellName))
            end
        end
    end
    
    return true
end

return SpellTag