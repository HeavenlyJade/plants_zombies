local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local Modifiers = require(MainStorage.code.common.config_type.modifier.Modifiers) ---@type Modifiers
    
---@class LevelConfig
local LevelConfig = {}
local loaded = false

local function LoadConfig()
    local LevelType = require(MainStorage.code.common.config_type.LevelType) ---@type LevelType
    LevelConfig.config ={
    ["测试关卡"] = LevelType.New({
        ["关卡ID"] = "测试关卡",
        ["前置关卡"] = nil,
        ["关卡波次"] = {
            {
                ["刷新波次"] = {
                    {
                        ["刷新怪物"] = {
                            {
                                ["怪物类型"] = "野人",
                                ["比重"] = 50
                            }
                        },
                        ["持续时间"] = 20,
                        ["数量"] = 10,
                        ["最大数量"] = 20,
                        ["开始时间"] = 10
                    }
                },
                ["属性倍率"] = 1,
                ["给予灵蕴"] = 50,
                ["总计经验"] = 100
            },
            {
                ["刷新波次"] = {
                    {
                        ["刷新怪物"] = {
                            {
                                ["怪物类型"] = "野人",
                                ["比重"] = 50
                            }
                        },
                        ["持续时间"] = 20,
                        ["数量"] = 10,
                        ["最大数量"] = 20,
                        ["开始时间"] = 10
                    }
                },
                ["属性倍率"] = 1,
                ["给予灵蕴"] = 50,
                ["总计经验"] = 100
            }
        },
        ["场景节点"] = {
            {
                ["场景"] = "g0",
                ["路径"] = "副本/峡谷1"
            }
        },
        ["进入位置"] = {
            "出生点/SpawnPos1",
            "出生点/SpawnPos2",
            "出生点/SpawnPos3",
            "出生点/SpawnPos4",
            "出生点/SpawnPos5",
            "出生点/SpawnPos6"
        },
        ["刷怪点"] = {
            "刷怪点/Cube",
            "刷怪点/Cube_copy",
            "刷怪点/Cube_copy_2",
            "刷怪点/Cube_copy_3",
            "刷怪点/Cube_copy_4",
            "刷怪点/Cube_copy_5",
            "刷怪点/Cube_copy_6",
            "刷怪点/Cube_copy_7"
        },
        ["最大玩家数"] = 6,
        ["进入条件"] = Modifiers.New({
            {
                ["目标"] = "自己",
                ["条件类型"] = "HealthCondition",
                ["条件"] = {
                    ["百分比"] = true,
                    ["最小值"] = 0,
                    ["最大值"] = 100
                },
                ["动作"] = "必须"
            }
        }),
        ["描述_2星"] = "生命大于30％",
        ["描述_3星"] = "生命大于70％",
        ["条件_2星"] = {
            {
                ["目标"] = "自己",
                ["条件类型"] = "HealthCondition",
                ["条件"] = {
                    ["百分比"] = true,
                    ["最小值"] = 30,
                    ["最大值"] = 100
                },
                ["动作"] = "必须"
            }
        },
        ["条件_3星"] = {
            {
                ["目标"] = "自己",
                ["条件类型"] = "HealthCondition",
                ["条件"] = {
                    ["百分比"] = true,
                    ["最小值"] = 70,
                    ["最大值"] = 100
                },
                ["动作"] = "必须"
            }
        },
        ["怪物等级"] = 1
    })
}loaded = true
end

---@param level string
---@return LevelType
function LevelConfig.Get(level)
    if not loaded then
        LoadConfig()
    end
    return LevelConfig.config[level]
end

---@return table<string, LevelType>
function LevelConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return LevelConfig.config
end
return LevelConfig