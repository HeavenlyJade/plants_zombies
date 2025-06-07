local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local Modifiers = require(MainStorage.code.common.config_type.modifier.Modifiers) ---@type Modifiers


---@class NpcData
---@field 名字 string
---@field 场景 string
---@field 节点 string
---@field 互动条件 table
---@field 互动指令 string[]

--- NPC配置文件
---@class NpcConfig
local NpcConfig = {}
local loaded = false

local function LoadConfig()
    NpcConfig.config ={
    ["抵御僵尸"] = {
        ["名字"] = "抵御僵尸",
        ["场景"] = "g0",
        ["节点名"] = "抵御僵尸",
        ["额外互动距离"] = {
            400,
            400
        },
        ["互动指令"] = {
            [[level {"关卡":"测试关卡","无需匹配直接开始":true}]]
        },
        ["额外距离"] = {
            0,
            0
        }
    },
    ["铁匠铺"] = {
        ["名字"] = "铁匠铺",
        ["场景"] = "g0",
        ["节点名"] = "铁匠铺",
        ["额外互动距离"] = {
            400,
            400
        },
        ["互动条件"] = Modifiers.New({
            {
                ["目标"] = "目标",
                ["条件类型"] = "ChanceCondition",
                ["条件"] = {
                    ["最小值"] = 20
                },
                ["动作"] = "必须"
            }
        }),
        ["互动指令"] = {
            [[title {"信息":"嘿，你好！"}]]
        },
        ["额外距离"] = {
            0,
            0
        }
    }
}loaded = true
end

---@param npcName string
---@return Npc
function NpcConfig.Get(npcName)
    if not loaded then
        LoadConfig()
    end
    return NpcConfig.config[npcName]
end

---@return Npc[]
function NpcConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return NpcConfig.config
end
return NpcConfig
