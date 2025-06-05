local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg

---@class Graphic:Class
local Graphic = ClassMgr.Class("Graphic")

-- 从模板创建新的特效对象
local function CreateParticle(particleName)
    if particleName == "" then
        return nil, nil
    end
    local node = MainStorage
    local fullPath = ""
    local lastPart = ""
    
    -- 遍历路径的每一部分
    for part in particleName:gmatch("[^/]+") do
        if part ~= "" then
            lastPart = part
            if not node then
                return nil
            end
            node = node[part]
            if fullPath == "" then
                fullPath = part
            else
                fullPath = fullPath .. "/" .. part
            end
        end
    end
    
    if not node then
        return nil, nil
    end
    
    return node:Clone(), node
end

function Graphic:OnInit( data )
    self.offset = gg.Vec3.new(data["偏移"]) or gg.Vec3.zero()
    self.targeter = data["目标"]
    self.targeterPath = data["目标场景名"]
    self.delay = data["延迟"] or 0
    self.duration = data["持续时间"] or 0
    self.repeatCount = data["重复次数"] or 1
    self.repeatDelay = data["重复延迟"] or 0
    self.autoPlay = self.targeter == "目标" or self.targeter == "自己" or self.targeter == "场景"
end

function Graphic:IsTargeter(targeter)
    if self.autoPlay then
        if targeter then
        return false
        end
    else
        if targeter ~= self.targeter then
            return false
        end
    end
    return true
end

function Graphic:GetTarget(caster, target)
    if self.targeter == "目标" then
        return target
    elseif self.targeter == "自己" then
        return caster
    elseif self.targeter == "场景" then
        local scene = target.scene ---@type Scene
        return scene.node2Entity[scene:Get(self.targeterPath)]
    end
    return target
end

---@param caster Entity
---@param target Entity
---@param param CastParam
---@param actions table
function Graphic:PlayAt(caster, target, param, actions)
    local c
    if self.autoPlay then
        c = self:GetTarget(caster, target)
    else
        c = target
    end
    if self.delay > 0 then
        ServerScheduler.add(function ()
            self:PlayAtReal(caster, c, param, actions)
        end, self.delay)
    else
        self:PlayAtReal(caster, c, param, actions)
    end
end

---@param caster Entity
---@param target Entity
---@param param CastParam
---@param actions table
function Graphic:PlayAtReal(caster, target, param, actions)
    local isCancelled = false
    local currentRepeat = 0
    
    local function addCancelFunction(effect, repeatIndex)
        local effectCancel = function()
            if effect.Enabled then
                effect.Enabled = false
                effect:Destroy()
            end
        end
        table.insert(actions, effectCancel)
        return effectCancel
    end
    
    local function playEffect()
        if isCancelled then 
            return 
        end
        
        -- 创建并设置效果对象
        local effect = self:CreateEffect(target, caster.scene)
        if not effect then 
            return 
        end
        
        -- 添加取消函数
        local effectCancel = addCancelFunction(effect, currentRepeat + 1)
        
        currentRepeat = currentRepeat + 1
        
        -- 设置持续时间
        if self.duration > 0 then
            ServerScheduler.add(function()
                if not isCancelled then
                    effectCancel()
                end
            end, self.duration)
        end
        
        -- 设置下一次重复
        if currentRepeat < self.repeatCount and self.repeatDelay > 0 then
            ServerScheduler.add(playEffect, self.repeatDelay)
        end
    end
    
    -- 启动第一次播放
    playEffect()
end

-- 子类需要实现的抽象方法
function Graphic:GetType()
    return "Graphic"
end

function Graphic:GetName()
    return "Unknown"
end

function Graphic:CreateEffect(target, scene)
    return nil
end

---@class ParticleGraphic:Graphic
local ParticleGraphic = ClassMgr.Class("ParticleGraphic", Graphic)
function ParticleGraphic:OnInit( data )
    Graphic.OnInit(self, data)
    self.particleName = data["特效对象"]
    self.particleAssetId = data["特效资产"] or nil
    self.boundToEntity = data["绑定实体"] or false
    self.boundToBone = data["绑定挂点"] or nil
end

function ParticleGraphic:GetType()
    return "特效"
end

function ParticleGraphic:GetName()
    return self.particleName
end

function ParticleGraphic:CreateEffect(target, scene)
    local container
    if self.boundToEntity and target.isEntity then
        container = target.actor
    else
        container = game.WorkSpace["Ground"][scene.name]["世界特效"]
    end
    
    if not container then
        return nil
    end
    
    local fx, previous = CreateParticle(self.particleName)
    if not fx or not previous then return nil end
    
    fx:SetParent(container)
    if not self.boundToEntity then
        fx.Position = (self.offset + target:GetCenterPosition()):ToVector3()
    else
        fx.LocalPosition = previous.LocalPosition
        fx.LocalEuler = previous.LocalEuler
    end
    fx.Enabled = true
    
    return fx
end

---@class AnimationGraphic:Graphic
local AnimationGraphic = ClassMgr.Class("AnimationGraphic", Graphic)
function AnimationGraphic:OnInit( data )
    Graphic.OnInit(self, data)
    self.animationName = data["播放动画"]
    self.playbackSpeed = data["播放速度"]
end

function AnimationGraphic:PlayAtReal(caster, target, param)
    gg.log("Play AnimationGraphic", target, self.animationName)
    if target.modelPlayer then
        target.modelPlayer:SwitchState(self.animationName, self.playbackSpeed)
    end
end

---@class CameraShakeGraphic:Graphic
local CameraShakeGraphic = ClassMgr.Class("CameraShakeGraphic", Graphic)

function CameraShakeGraphic:OnInit( data )
    Graphic.OnInit(self, data)
    self.rotation = data["旋转"] ---@type Vector2
    self.position = data["位移"] ---@type Vector3
    self.tweenStyle = data["动画风格"]
    self.dropStyle = data["衰减风格"]
    self.frequency = data["频率"]
end

function CameraShakeGraphic:PlayAtReal(caster, target, param)
    if target.isPlayer then
        gg.network_channel:fireClient(target.uin, {
            cmd = "ShakeCamera",
            dura = self.duration,
            rotShake = self.rotation,
            posShake = self.position,
            mode = self.tweenStyle,
            drop = self.dropStyle,
            frequency = self.frequency
        })
    end
end

---@class ModelGraphic:Graphic
local ModelGraphic = ClassMgr.Class("ModelGraphic", Graphic)
function ModelGraphic:OnInit( data )
    Graphic.OnInit(self, data)
    self.modelName = data["模型对象"]
    self.stateMachine = data["模型状态机"]
    self.animationName = data["播放动画"]
    self.boundToEntity = data["绑定实体"] or false
    self.boundToBone = data["绑定挂点"] or nil
end

function ModelGraphic:GetType()
    return "模型"
end

function ModelGraphic:GetName()
    return self.modelName
end

function ModelGraphic:CreateEffect(target, scene)
    local container
    if self.boundToEntity and target.isEntity then
        container = target.actor
    else
        container = game.WorkSpace["Ground"][scene.name]["世界特效"]
    end
    
    if not container then
        return nil
    end
    
    local model, previous = CreateParticle(self.modelName)
    if not model or not previous then return nil end
    
    model:SetParent(container)
    if not self.boundToEntity then
        model.LocalPosition = target:GetPosition()
    else
        model.LocalPosition = previous.LocalPosition
        model.LocalEuler = previous.LocalEuler
    end
    model.Enabled = true
    
    -- 播放动画
    if self.animationName and self.animationName ~= "" then
        local modelPlayer = model.Animator
        if modelPlayer then
            modelPlayer:Play(self.animationName, 0, 0)
        end
    end
    
    return model
end

---@class Graphics
---@field ParticleGraphic ParticleGraphic
---@field AnimationGraphic AnimationGraphic
---@field CameraShakeGraphic CameraShakeGraphic
---@field ModelGraphic ModelGraphic
local loaders = {
    ParticleGraphic = ParticleGraphic,
    AnimationGraphic = AnimationGraphic,
    CameraShakeGraphic = CameraShakeGraphic,
    ModelGraphic = ModelGraphic,
}

--- 加载特效配置
---@param effectsData table[]|nil 特效配置数组
---@return Graphic[] 特效实例数组
local function Load(effectsData)
    if not effectsData then return {} end
    
    local effects = {}
    for _, effectData in ipairs(effectsData) do
        if effectData["_type"] then
            local effectClass = loaders[effectData["_type"]]
            if effectClass then
                local effect = effectClass.New(effectData)
                table.insert(effects, effect)
            end
        end
    end
    return effects
end

loaders["Load"] = Load
return loaders