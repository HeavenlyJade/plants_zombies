
local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local Modifiers = require(MainStorage.code.common.config_type.modifier.Modifiers) ---@type Modifiers

--- 挂机点配置文件
---@class AfkSpotConfig
local AfkSpotConfig = {}
local loaded = false

local function LoadConfig()
    AfkSpotConfig.config ={
    ["主城1花园"] = {
        ["名字"] = "主城1花园",
        ["场景"] = "g0",
        ["节点名"] = {
            "副卡挂机",
            "副卡挂机_copy",
            "副卡挂机_copy_2",
            "副卡挂机_copy_3",
            "副卡挂机_copy_4",
            "副卡挂机_copy_5",
            "副卡挂机_copy_6",
            "副卡挂机_copy_7",
            "副卡挂机_copy_8",
            "副卡挂机_copy_9",
            "副卡挂机_copy_10",
            "副卡挂机_copy_11",
            "副卡挂机_copy_12",
            "副卡挂机_copy_13",
            "副卡挂机_copy_14",
            "副卡挂机_copy_15",
            "副卡挂机_copy_16",
            "副卡挂机_copy_17",
            "副卡挂机_copy_18",
            "副卡挂机_copy_19"
        },
        ["间隔时间"] = 0
    }
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