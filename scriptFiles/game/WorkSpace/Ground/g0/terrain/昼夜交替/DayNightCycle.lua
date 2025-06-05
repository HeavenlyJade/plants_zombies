local MainStorage = game:GetService('MainStorage')
local Environment = game:GetService("WorkSpace")["Environment"] ---@type Environment
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local MobTypeConfig = require(MainStorage.code.common.config.MobTypeConfig)  ---@type MobTypeConfig
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler

local sunMoon = script.Parent ---@type Transform
local rotateSpeed = Vector3.New(0,0,1)
ServerScheduler.add(function ()
    sunMoon.Euler = sunMoon.Euler + rotateSpeed
    -- Environment.TimeHour = 24.0 * (sunMoon.Euler.z % 360) / 360.0
end, 1, 1)