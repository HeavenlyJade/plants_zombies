local MainStorage = game:GetService('MainStorage')
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClassMgr      = require(MainStorage.code.common.ClassMgr)    ---@type ClassMgr
local EquipingTag     = require(MainStorage.code.common.config_type.tags.EquipingTag)    ---@type EquipingTag



-- 词条类型定义
---@class TagType
---@field New fun( data:table ):TagType
local TagType = ClassMgr.Class("TagType")
function TagType:OnInit(data)
    self.data = data
    self.id = data["名字"]
    self.maxLevel = data["最高等级"]
    -- self.description = data["描述"]
    self.description = data["详细属性"]
    self.functions = {}
    for _, tagHandler in ipairs(data["功能"]) do
        local tagHandlerClass = require(MainStorage.code.common.config_type.tags[tagHandler["类型"]])
        table.insert(self.functions, tagHandlerClass.New(tagHandler))
    end
end

function TagType:GetDescription(level)
    if not self.description or self.description == "" then
        return ""
    end
    
    local result = self.description
    
    -- 处理 [数字:每级增加倍率] 格式
    result = string.gsub(result, "%[(%d+):([%d%.]+)%]", function(baseValue, perLevel)
        baseValue = tonumber(baseValue)
        perLevel = tonumber(perLevel)
        local finalValue = baseValue * (1 + (level - 1) * perLevel)
        return string.format("%.1f", finalValue)
    end)
    
    -- 处理 [词条序号.属性.数组索引] 格式
    result = string.gsub(result, "%[(%d+)%.([^%.]+)%.(%d+)%]", function(index, fieldName, arrayIndex)
        index = tonumber(index)
        arrayIndex = tonumber(arrayIndex) -- Convert to 0-based index
        if index > 0 and index <= #self.functions then
            local handler = self.functions[index]
            gg.log("result ", result, handler, fieldName, arrayIndex)
            
            -- 处理修改数值
            if fieldName == "修改数值" and handler["修改数值"] and handler["修改数值"][arrayIndex] then
                local modifier = handler["修改数值"][arrayIndex]
                gg.log("修改数值", modifier, modifier.paramValue)
                if modifier and modifier.paramValue then
                    local finalRate = modifier.paramValue["倍率"] * handler:GetUpgradeValue("修改数值倍率", level, 1)
                    if modifier.paramValue.attributeType and modifier.paramValue.attributeType.name then
                        return string.format("%.1f%s", finalRate, modifier.paramValue.attributeType.name)
                    else
                        return string.format("%.1f", finalRate)
                    end
                end
            end
            
            -- 处理属性增伤
            if fieldName == "属性增伤" and handler["属性增伤"] and handler["属性增伤"][arrayIndex] then
                local element = handler["属性增伤"][arrayIndex]
                if element then
                    local finalRate = element.multiplier * handler:GetUpgradeValue("属性增伤倍率", level, 1)
                    if element.statType then
                        return string.format("%.1f%s", finalRate, element.statType)
                    else
                        return string.format("%.1f", finalRate)
                    end
                end
            end
        end
        return ""
    end)
    
    -- 处理 [词条序号.属性] 格式
    result = string.gsub(result, "%[(%d+)%.([^%]]+)%]", function(index, fieldName)
        index = tonumber(index)
        gg.log("result ", result, index, fieldName)
        if index > 0 and index <= #self.functions then
            local handler = self.functions[index]
            local value = handler[fieldName]
            if type(value) == "number" then
                -- 应用升级值增加
                local finalValue = handler:GetUpgradeValue(fieldName, level)
                return string.format("%.1f", finalValue)
            end
            return tostring(value or "")
        end
        return ""
    end)
    
    return result
end

function TagType:FactoryEquipingTag(prefix, level)
    prefix = prefix or "MISC-"
    level = level or 1.0
    
    local equipingTag = EquipingTag.New()
    equipingTag.level = level
    equipingTag.id = prefix .. self.id
    equipingTag.tagType = self
    equipingTag.handlers = {}
    
    for _, tagHandler in ipairs(self.functions) do
        tagHandler.m_tagType = self
        local key = tagHandler.m_trigger
        if not equipingTag.handlers[key] then
            equipingTag.handlers[key] = {}
        end
        table.insert(equipingTag.handlers[key], tagHandler)
    end
    
    return equipingTag
end

return TagType