
local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg

--- TriggerZone配置文件
---@class TriggerZoneConfig
local TriggerZoneConfig = {}
local loaded = false

local function LoadConfig()
    TriggerZoneConfig.config ={
    ["主城1挂机点"] = {
        ["名字"] = "主城1挂机点",
        ["场景"] = "g0",
        ["节点名"] = {
            "guaji1"
        },
        ["定时间隔"] = 2,
        ["定时指令"] = {
            "cast {'复杂魔法':{'魔法':'挂机获得阳光','复写参数':[{'objectName':'挂机获得阳光','paramName':'基础数量','value':10}]}}"
        },
        ["进入指令"] = {
            "afk {}"
        },
        ["离开指令"] = {
            "afk {'操作':'离开挂机'}"
        }
    }
}loaded = true
end

---@param Name string
function TriggerZoneConfig.Get(Name)
    if not loaded then
        LoadConfig()
    end
    return TriggerZoneConfig.config[Name]
end

function TriggerZoneConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return TriggerZoneConfig.config
end
return TriggerZoneConfig
