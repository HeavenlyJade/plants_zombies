local MainStorage = game:GetService('MainStorage')
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local Vec3 = require(MainStorage.code.common.math.Vec3)
local Vec2 = require(MainStorage.code.common.math.Vec2)
local Perlin = require(MainStorage.code.common.math.PerlinNoise)
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager
local ClientScheduler = require(MainStorage.code.client.ClientScheduler)

local shaking = {}

-- 震动模式定义
local ShakeModes = {
    SINE = "震荡",      -- 正弦波震动
    PERLIN = "柏林噪声",  -- 柏林噪声震动
    RANDOM = "随机",  -- 随机震动
    -- 可以在这里添加更多模式
}

-- 衰减模式定义
local DropStyles = {
    LINEAR = "线性",      -- 线性衰减
    QUADRATIC = "二次方",  -- 二次方衰减（先快后慢）
    CUBIC = "三次方",     -- 三次方衰减（先快后慢）
    INV_QUADRATIC = "反二次方", -- 反二次方衰减（先慢后快）
    INV_CUBIC = "反三次方",    -- 反三次方衰减（先慢后快）
}

-- 衰减模式实现
local DropStyleImplementations = {
    [DropStyles.LINEAR] = function(progress)
        return 1 - progress
    end,
    
    [DropStyles.QUADRATIC] = function(progress)
        return (1 - progress) * (1 - progress)
    end,
    
    [DropStyles.CUBIC] = function(progress)
        return (1 - progress) * (1 - progress) * (1 - progress)
    end,
    
    [DropStyles.INV_QUADRATIC] = function(progress)
        return 1 - (progress * progress)
    end,
    
    [DropStyles.INV_CUBIC] = function(progress)
        return 1 - (progress * progress * progress)
    end,
}

-- 震动模式实现
local ShakeModeImplementations = {
    [ShakeModes.SINE] = function(elapsed, frequency, strength)
        return math.sin(elapsed * frequency * math.pi * 2) * strength
    end,
    
    [ShakeModes.PERLIN] = function(elapsed, frequency, strength)
        return (Perlin.Noise2D(elapsed * frequency, 0) - 0.5) * 2 * strength
    end,
    
    [ShakeModes.RANDOM] = function(elapsed, frequency, strength)
        return (math.random() - 0.5) * 2 * strength
    end,
}

---@class ShakeAnim:Class
local ShakeAnim = ClassMgr.Class("ShakeAnim")

function ShakeAnim:OnInit(data)
    self.startTime = os.clock()
    self.duration = data.dura
    self.frequency = data.frequency or 10
    self.mode = data.mode or ShakeModes.SINE
    self.drop = data.drop or DropStyles.LINEAR
    self.initialPosShake = Vector3.New(data.posShake[1], data.posShake[2], data.posShake[3])
    self.initialRotShake = Vector2.New(data.rotShake[1], data.rotShake[2])
    self.posShake = Vector3.New(0,0,0)
    self.rotShake = Vector2.New(0,0)
    self.initialStrength = data.strength or 1
    
    -- 获取震动模式实现
    local shakeFunction = ShakeModeImplementations[self.mode]
    if not shakeFunction then
        warn("Unknown shake mode:", self.mode, "falling back to sine mode")
        shakeFunction = ShakeModeImplementations[ShakeModes.SINE]
    end
    
    -- 获取衰减模式实现
    local dropFunction = DropStyleImplementations[self.drop]
    if not dropFunction then
        warn("Unknown drop style:", self.drop, "falling back to linear")
        dropFunction = DropStyleImplementations[DropStyles.LINEAR]
    end
    
    -- 使用ClientScheduler注册更新任务
    self.taskId = ClientScheduler.add(function()
        local elapsed = os.clock() - self.startTime
        if elapsed >= self.duration then
            -- 移除震动动画
            for i, shake in ipairs(shaking) do
                if shake == self then
                    table.remove(shaking, i)
                    break
                end
            end
            return
        end
        
        -- 计算当前强度（使用选定的衰减模式）
        local progress = elapsed / self.duration
        local currentStrength = self.initialStrength * dropFunction(progress)
        
        -- 使用选定的震动模式计算震动值
        local shakeValue = shakeFunction(elapsed, self.frequency, currentStrength)
        print("shakeValue", shakeValue, currentStrength)
        
        -- 更新震动值
        self.posShake = self.initialPosShake * shakeValue
        self.rotShake = self.initialRotShake * shakeValue
    end, 0, 1/30) -- 每帧更新一次（30fps）
end

function ShakeAnim:OnDestroy()
    if self.taskId then
        ClientScheduler.cancel(self.taskId)
        self.taskId = nil
    end
end

---@class ShakeController
local ShakeController = {}

-- 添加新的震动模式
function ShakeController.AddShakeMode(modeName, implementation)
    if ShakeModes[modeName] then
        warn("Shake mode already exists:", modeName)
        return
    end
    ShakeModes[modeName] = modeName
    ShakeModeImplementations[modeName] = implementation
end

-- 添加新的衰减模式
function ShakeController.AddDropStyle(styleName, implementation)
    if DropStyles[styleName] then
        warn("Drop style already exists:", styleName)
        return
    end
    DropStyles[styleName] = styleName
    DropStyleImplementations[styleName] = implementation
end

ClientEventManager.Subscribe("ShakeCamera", function(evt)
    table.insert(shaking, ShakeAnim.New(evt))
end)

local _shakeRotDelta = Vec2.new(0, 0)
local _shakePosDelta = Vec3.new(0, 0, 0)

--是否正在震动
function ShakeController.IsShaking()
    return #shaking > 0
end

--获取震动位移
---@return Vec3
function ShakeController.GetPosDelta()
    _shakePosDelta = Vec3.new(0, 0, 0)
    for name, shakeData in pairs(shaking) do
        _shakePosDelta = _shakePosDelta + shakeData.posShake
    end
    return _shakePosDelta
end

--获取震动旋转
---@return Vec2
function ShakeController.GetRotDelta()
    _shakeRotDelta = Vec2.new(0, 0)
    for name, shakeData in pairs(shaking) do
        _shakeRotDelta = _shakeRotDelta + shakeData.rotShake
    end
    return _shakeRotDelta
end

return ShakeController
