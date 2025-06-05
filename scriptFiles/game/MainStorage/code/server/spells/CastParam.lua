local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
---@class CastParam:Class
---@field New fun( ...:table ):CastParam
local CastParam = ClassMgr.Class("CastParam")

function CastParam:OnInit(...)
    local data = ... or {}
    self.power = data.power or 1.0 ---@type number
    self.cancelled = data.cancelled or false ---@type boolean
    self.realTarget = data.realTarget ---@type Entity
    self.skipTags = data.skipTags or {} ---@type table<string, boolean>
    self.extraModifiers = data.extraModifiers or {} ---@type table<string, Battle>
    self.extraParams = data.extraParams or {} ---@type table<string, any>
    self.dynamicTags = data.dynamicTags ---@type table<string, EquipingTag[]>|nil
    self.lookDirection = nil --仅限主动释放技能： 释放时玩家的摄像机朝向
end

function CastParam:Clone()
    local cloned = CastParam.New({
        power = self.power,
        cancelled = self.cancelled,
        realTarget = self.realTarget,
        skipTags = gg.clone(self.skipTags),
        extraModifiers = gg.clone(self.extraModifiers),
        extraParams = gg.clone(self.extraParams),
        dynamicTags = self.dynamicTags and gg.clone(self.dynamicTags) or nil
    })
    return cloned
end

---@param spell Spell
---@param v string
---@param def number
---@return number
function CastParam:GetValue(spell, v, def)
    return self:GetValueByName(spell.spellName, v, def)
end

---@param name string
---@param v string
---@param previousValue number
---@return number
function CastParam:GetValueByName(name, v, previousValue)
    previousValue = self:GetParamByName(name, v, previousValue)
    local adder1 = 0.0
    local adder2 = 0.0
    
    local value = self.extraModifiers[name .. "." .. v]
    if value then
        adder1 = value:GetFinalDamage(previousValue) - previousValue
    end
    
    value = self.extraModifiers[v]
    if value then
        adder2 = value:GetFinalDamage(previousValue) - previousValue
    end
    
    return previousValue + adder1 + adder2
end

---@generic T
---@param spell Spell
---@param v string
---@param def T
---@return T
function CastParam:GetParam(spell, v, def)
    return self:GetParamByName(spell.spellName, v, def)
end

---@generic T
---@param name string
---@param v string
---@param def T
---@return T
function CastParam:GetParamByName(name, v, def)
    -- gg.log("GetParamByName", name, v, def)
    local value = self.extraParams[name .. "." .. v] or self.extraParams[v]
    -- gg.log("GetParamByName", name, value, self.extraParams, self.extraParams[name .. "." .. v], self.extraParams[v])
    if value == nil then
        return def
    end
    
    return value
end

return CastParam