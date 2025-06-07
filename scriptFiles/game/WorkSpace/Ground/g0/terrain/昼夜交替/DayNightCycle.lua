local MainStorage = game:GetService('MainStorage')
local Scene                = require(MainStorage.code.server.Scene)    ---@type Scene
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local MobTypeConfig = require(MainStorage.code.common.config.MobTypeConfig)  ---@type MobTypeConfig
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler

local sunMoon = script.Parent ---@type Transform
local maxMult = 2.5
local baseSunDist = sunMoon["山坡太阳"].LocalPosition.y
local baseMoonDist = sunMoon["山坡月亮"].LocalPosition.y

-- 根据时间计算太阳/月亮的位置
local function updateSunMoonPosition()
    -- 将时间转换为0-360度的角度
    -- 0点对应0度，12点对应180度，24点对应360度
    local angle = (Scene.worldTime / 24.0) * 360.0
    sunMoon.Euler = Vector3.New(0, 0, angle)
    
    -- 使用正弦函数计算mult，在0/180度时为1，在90/270度时为maxMult
    -- 将角度转换为弧度，使用cos而不是sin，这样90和270度时达到最大值
    local rad = math.rad(angle - 90)
    local mult = 1 + (maxMult - 1) * (math.abs(math.cos(rad)))
    
    sunMoon["山坡太阳"].LocalPosition = Vector3.New(0, baseSunDist * mult, 0)
    sunMoon["山坡月亮"].LocalPosition = Vector3.New(0, baseMoonDist * mult, 0)
end

-- 每秒更新一次位置
ServerScheduler.add(updateSunMoonPosition, 0, 1)