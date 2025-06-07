local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local Lottery      = require(MainStorage.code.server.shop.Lottery)    ---@type Lottery

--- 抽奖配置文件
---@class LotteryConfig
local LotteryConfig = {}
local loaded = false

local function LoadConfig()
    LotteryConfig.config ={
    ["副卡奖池"] = Lottery.New({
        ["奖池名"] = "副卡奖池",
        ["普通品级概率"] = 0,
        ["稀有品级概率"] = 0,
        ["史诗品级概率"] = 0,
        ["传说品级概率"] = 0,
        ["神话品级概率"] = 0,
        ["稀有保底次数"] = 0,
        ["史诗保底次数"] = 0,
        ["传说保底次数"] = 0,
        ["神话保底次数"] = 0,
        ["稀有品级"] = {
            {
                ["itemType"] = "地刺碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 5
            },
            {
                ["itemType"] = "坚果碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 5
            },
            {
                ["itemType"] = "椰子炮碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 5
            },
            {
                ["itemType"] = "樱桃炸弹碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 5
            },
            {
                ["itemType"] = "豌豆射手碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 5
            }
        },
        ["史诗品级"] = {
            {
                ["itemType"] = "仙人掌碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            },
            {
                ["itemType"] = "火爆辣椒碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            },
            {
                ["itemType"] = "白菜拳手碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            },
            {
                ["itemType"] = "辣椒投手碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            },
            {
                ["itemType"] = "钢铁地刺碎片",
                ["weight"] = 20,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            }
        },
        ["传说品级"] = {
            {
                ["itemType"] = "星星果碎片",
                ["weight"] = 30,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            },
            {
                ["itemType"] = "窝瓜碎片",
                ["weight"] = 30,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            },
            {
                ["itemType"] = "魅惑菇碎片",
                ["weight"] = 30,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 1
            }
        }
    }),
    ["普通宝石"] = Lottery.New({
        ["奖池名"] = "普通宝石",
        ["普通品级概率"] = 50,
        ["稀有品级概率"] = 20,
        ["史诗品级概率"] = 10,
        ["传说品级概率"] = 0.5,
        ["神话品级概率"] = 0,
        ["稀有保底次数"] = 0,
        ["史诗保底次数"] = 0,
        ["传说保底次数"] = 30,
        ["神话保底次数"] = 0,
        ["普通品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["稀有品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["史诗品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["传说品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        }
    }),
    ["神锋现世"] = Lottery.New({
        ["奖池名"] = "神锋现世",
        ["普通品级概率"] = 50,
        ["稀有品级概率"] = 20,
        ["史诗品级概率"] = 10,
        ["传说品级概率"] = 0.5,
        ["神话品级概率"] = 0,
        ["稀有保底次数"] = 0,
        ["史诗保底次数"] = 0,
        ["传说保底次数"] = 30,
        ["神话保底次数"] = 0,
        ["普通品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["稀有品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["史诗品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["传说品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        }
    }),
    ["试手寻锋"] = Lottery.New({
        ["奖池名"] = "试手寻锋",
        ["普通品级概率"] = 50,
        ["稀有品级概率"] = 20,
        ["史诗品级概率"] = 10,
        ["传说品级概率"] = 0.5,
        ["神话品级概率"] = 0,
        ["稀有保底次数"] = 0,
        ["史诗保底次数"] = 0,
        ["传说保底次数"] = 30,
        ["神话保底次数"] = 0,
        ["普通品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["稀有品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["史诗品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        },
        ["传说品级"] = {
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            },
            {
                ["itemType"] = nil,
                ["weight"] = 10,
                ["itemCountMin"] = 1,
                ["itemCountMax"] = 10
            }
        }
    })
}loaded = true
end

---@param lotteryName string
---@return Lottery
function LotteryConfig.Get(lotteryName)
    if not loaded then
        LoadConfig()
    end
    return LotteryConfig.config[lotteryName]
end

---@return Lottery[]
function LotteryConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return LotteryConfig.config
end
return LotteryConfig
