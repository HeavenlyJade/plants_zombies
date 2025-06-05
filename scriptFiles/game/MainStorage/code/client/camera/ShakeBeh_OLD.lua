-- local MainStorage = game:GetService('MainStorage')
-- local gg = require(MainStorage.code.common.MGlobal) ---@type gg
-- local Vec3 = require(MainStorage.code.common.math.Vec3)
-- local Perlin = require(MainStorage.code.common.math.PerlinNoise)
-- local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager

-- ---@class ShakeController
-- local ShakeController = {}

-- --震动数据
-- local ShakeData = {
--     --震动持续时间
--     duration = 1.0,
--     --震动频率
--     frequency = 0.05,
--     --强度
--     strength = 1.0,
--     --旋转参数
--     rotX = 0.0,
--     rotY = 0.0,
--     rotZ = 0.0,
--     --位移参数
--     posX = 0.0,
--     posY = 0.0,
--     posZ = 0.0,
--     --运行状态
--     loop = false,
--     stop = false,
--     stopfade = false,
--     elapsedtime = 0.0,
--     rotDelta = nil,
--     posDelta = nil,
--     randSeed = nil
-- }

-- --静态变量
-- local _shakeDatas = {}
-- local _shaking = false
-- local _shakePosDelta = Vec3.new(0, 0, 0)
-- local _shakeRotDelta = Vec3.new(0, 0, 0)

-- ClientEventManager.Subscribe("ShakeCamera", function(evt)
--     _shakeDatas[evt.name] = evt
--     evt._posShake = evt.posX ~= 0.0 or evt.posY ~= 0.0 or evt.posZ ~= 0.0
--     evt._rotShake = evt.rotX ~= 0.0 or evt.rotY ~= 0.0 or evt.rotZ ~= 0.0
--     gg.log("ShakeController", evt.name, evt)
--     ShakeController.Start(evt.name)
-- end)

-- --震动屏幕
-- function ShakeController.Start(name)
--     if not _shakeDatas[name] then
--         return
--     end
--     _shakeDatas[name].stop = false
--     _shakeDatas[name].loop = false
--     _shakeDatas[name]._times = 0
--     _shakeDatas[name].elapsedtime = 0.0
--     _shakeDatas[name].posDelta = Vec3.new(0, 0, 0)
--     _shakeDatas[name].rotDelta = Vec3.new(0, 0, 0)
--     _shakeDatas[name].randSeed = gg.math.Random(0, 36)
-- end

-- --开始持续震动
-- function ShakeController.StartLoop(name)
--     if not _shakeDatas[name] then
--         return
--     end
--     _shakeDatas[name].stop = false
--     _shakeDatas[name].loop = true
--     _shakeDatas[name].elapsedtime = 0.0
--     _shakeDatas[name].posDelta = Vec3.new(0, 0, 0)
--     _shakeDatas[name].rotDelta = Vec3.new(0, 0, 0)
--     _shakeDatas[name].randSeed = gg.math.Random(0, 36)
-- end

-- --停止持续震动
-- function ShakeController.StopLoop(name)
--     if not _shakeDatas[name] then
--         return
--     end
--     _shakeDatas[name].loop = false
-- end

-- --淡出震动
-- function ShakeController.StopFade(name)
--     if not _shakeDatas[name] then
--         return
--     end
--     _shakeDatas[name].stopfade = true
--     _shakeDatas[name].loop = false
-- end

-- --停止震动
-- function ShakeController.Stop(name)
--     _shakeDatas[name].stop = true
--     _shakeDatas[name].loop = false
-- end

-- --停止全部
-- function ShakeController.StopAll()
--     for name, shakeData in pairs(_shakeDatas) do
--         shakeData.stop = true
--         shakeData.loop = false
--     end
-- end

-- function ShakeController.Update(dt)
--     _shakeRotDelta = Vec3.new(0, 0, 0)
--     _shakePosDelta = Vec3.new(0, 0, 0)

--     _shaking = false
--     for name, shakeData in pairs(_shakeDatas) do
--         if not shakeData.stop then
--             _shaking = true
--             --进行震动
--             ShakeController.Shake(shakeData, dt)
--             _shakePosDelta = _shakePosDelta + shakeData.posDelta
--             _shakeRotDelta = _shakeRotDelta + shakeData.rotDelta
--         end
--     end
-- end

-- --震动屏幕
-- function ShakeController.Shake(shakeData, dt)
--     local function Noise2D(x, y)
--         return Perlin:StaticNoise2D(x, y)
--     end
--     if not shakeData.stop and shakeData.elapsedtime < shakeData.duration then
--         --执行震动
--         shakeData.elapsedtime = shakeData.elapsedtime + dt

--         local progress = shakeData.elapsedtime / shakeData.duration
--         local strength = shakeData.strength * progress -- 线性衰减

--         if shakeData._rotShake then
--             local rx = Noise2D(shakeData.elapsedtime * shakeData.frequency, shakeData.randSeed + 0.0) - 0.5
--             local ry = Noise2D(shakeData.elapsedtime * shakeData.frequency, shakeData.randSeed + 1.0) - 0.5
--             local rz = Noise2D(shakeData.elapsedtime * shakeData.frequency, shakeData.randSeed + 2.0) - 0.5
--             shakeData.rotDelta =
--                 Vec3.new(rx, ry, rz) * Vec3.new(shakeData.rotX, shakeData.rotY, shakeData.rotZ) * strength
--         end
--         if shakeData._posShake then
--             local px = Noise2D(shakeData.elapsedtime * shakeData.frequency, shakeData.randSeed + 3.0) - 0.5
--             local py = Noise2D(shakeData.elapsedtime * shakeData.frequency, shakeData.randSeed + 4.0) - 0.5
--             local pz = Noise2D(shakeData.elapsedtime * shakeData.frequency, shakeData.randSeed + 5.0) - 0.5
--             shakeData.posDelta =
--                 Vec3.new(px, py, pz) * Vec3.new(shakeData.posX, shakeData.posY, shakeData.posZ) * strength
--         end

--         if shakeData.stopfade then
--             shakeData.duration = shakeData.elapsedtime + 1.0
--             shakeData.stopfade = false
--         end
--     elseif shakeData.times then
--         shakeData._times = shakeData._times + 1
--         if shakeData._times >= shakeData.times then
--             shakeData.stop = true
--         else
--             shakeData.elapsedtime = 0.0
--         end
--     else
--         --震动完毕
--         if shakeData.loop then
--             shakeData.stop = false
--             shakeData.elapsedtime = 0.0
--         else
--             shakeData.stop = true
--         end
--     end
-- end

-- --是否正在震动
-- function ShakeController.IsShaking()
--     return _shaking
-- end

-- --获取震动位移
-- ---@return Vec3
-- function ShakeController.GetPosDelta()
--     return _shakePosDelta
-- end

-- --获取震动旋转
-- ---@return Vec3
-- function ShakeController.GetRotDelta()
--     return _shakeRotDelta
-- end

-- return ShakeController
