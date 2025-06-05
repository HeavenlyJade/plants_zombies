
local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local Modifiers = require(MainStorage.code.common.config_type.modifier.Modifiers) ---@type Modifiers

--- 挂机点配置文件
---@class AfkSpotConfig
local AfkSpotConfig = {}
local loaded = false

local function LoadConfig()
    AfkSpotConfig.config ={
}loaded = true
end

function AfkSpotConfig.Get(AfkSpotName)
    if not loaded then
        LoadConfig()
    end
    return AfkSpotConfig.config[AfkSpotName]
end

function AfkSpotConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return AfkSpotConfig.config
end
return AfkSpotConfig