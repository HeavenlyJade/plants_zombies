
local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg

--- 动画配置文件
---@class AnimationConfig
local AnimationConfig = {}
local loaded = false

local function LoadConfig()
    AnimationConfig.config ={
    ["僵尸"] = {
        ["初始状态"] = "idle",
        ["状态"] = {
            ["idle"] = {
                ["播放模式"] = "循环",
                ["切换"] = {
                    ["attack"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "攻击时",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    },
                    ["walk"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "无",
                        ["已播放完成"] = false,
                        ["移动中"] = true,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            },
            ["attack"] = {
                ["播放模式"] = "单次",
                ["动画持续时间"] = 1,
                ["切换"] = {
                    ["idle"] = {
                        ["混合时间"] = 0.3,
                        ["时机"] = "无",
                        ["已播放完成"] = true,
                        ["移动中"] = false,
                        ["静止中"] = true,
                        ["跳跃中"] = false
                    },
                    ["walk"] = {
                        ["混合时间"] = 0.3,
                        ["时机"] = "无",
                        ["已播放完成"] = true,
                        ["移动中"] = true,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            },
            ["walk"] = {
                ["播放模式"] = "循环",
                ["切换"] = {
                    ["idle"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "无",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = true,
                        ["跳跃中"] = false
                    },
                    ["attack"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "攻击时",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            }
        }
    },
    ["卡片"] = {
        ["初始状态"] = "idle",
        ["状态"] = {
            ["idle"] = {
                ["播放模式"] = "循环",
                ["切换"] = {
                    ["attack"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "攻击时",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    },
                    ["walk"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "无",
                        ["已播放完成"] = false,
                        ["移动中"] = true,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            },
            ["attack"] = {
                ["播放模式"] = "单次",
                ["动画持续时间"] = 1,
                ["切换"] = {
                    ["idle"] = {
                        ["混合时间"] = 0,
                        ["时机"] = "无",
                        ["已播放完成"] = true,
                        ["移动中"] = false,
                        ["静止中"] = true,
                        ["跳跃中"] = false
                    },
                    ["walk"] = {
                        ["混合时间"] = 0,
                        ["时机"] = "无",
                        ["已播放完成"] = true,
                        ["移动中"] = true,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            },
            ["walk"] = {
                ["播放模式"] = "循环",
                ["切换"] = {
                    ["idle"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "无",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = true,
                        ["跳跃中"] = false
                    },
                    ["attack"] = {
                        ["混合时间"] = 0.4,
                        ["时机"] = "攻击时",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            }
        }
    },
    ["植物"] = {
        ["初始状态"] = "idle",
        ["状态"] = {
            ["idle"] = {
                ["播放模式"] = "循环",
                ["切换"] = {
                    ["attack"] = {
                        ["混合时间"] = 0.1,
                        ["时机"] = "攻击时",
                        ["已播放完成"] = false,
                        ["移动中"] = false,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            },
            ["attack"] = {
                ["播放模式"] = "单次",
                ["动画持续时间"] = 0.5,
                ["切换"] = {
                    ["idle"] = {
                        ["混合时间"] = 0,
                        ["时机"] = "无",
                        ["已播放完成"] = true,
                        ["移动中"] = false,
                        ["静止中"] = false,
                        ["跳跃中"] = false
                    }
                }
            }
        }
    }
}loaded = true
end

---@return Animation
function AnimationConfig.Get(name)
    if not loaded then
        LoadConfig()
    end
    return AnimationConfig.config[name]
end

---@return Animation[]
function AnimationConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return AnimationConfig.config
end
return AnimationConfig
