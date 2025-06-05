local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local gg = require(MainStorage.code.common.MGlobal)            ---@type gg
local Graphics = require(MainStorage.code.server.graphic.Graphics) ---@type Graphics

---@enum CollisionType
local CollisionType = {
    CIRCLE = "圆形",
    RECTANGLE = "方形",
    ELLIPSE = "椭圆形"
}

---@class PulsingAOE:Class
---@field spell AOESpell
---@field caster Entity
---@field target Entity
---@field location Vector3
---@field param CastParam
---@field hitCreatures table<Entity, boolean>
---@field lastPulseTime number
---@field actions function[]
local PulsingAOE = ClassMgr.Class("PulsingAOE")

function PulsingAOE:OnInit(spell, caster, target, location, param)
    self.spell = spell
    self.caster = caster
    self.target = target
    self.location = location
    self.param = param
    self.lastPulseTime = 0
    self.hitCreatures = {}
    self.actions = self.spell:PlayEffect(self.spell.persistentEffects, caster, target, param)
    if self.spell.printInfo then
        gg.log(string.format("%s: 创建持续效果 位置[%.1f, %.1f, %.1f] 取消回调", 
            self.spell.spellName, location.x, location.y, location.z), self.actions)
    end
end

function PulsingAOE:Start()
    -- 立即执行一次
    self:ExecutePulse()
    
    -- 设置定时器进行周期性检测
    self.timer = ServerScheduler.add(
        function()
            -- 检查是否应该停止
            if not self.caster then
                if self.spell.printInfo then
                    print(string.format("%s: 施法者消失，停止持续效果", self.spell.spellName))
                end
                self:OnComplete() -- 确保在施法者消失时也清理特效
                return
            end

            self:ExecutePulse()
        end,
        0, -- Start immediately
        self.spell.hitInterval -- Execute every hitInterval seconds
    )

    -- 设置持续时间结束时的清理
    if self.spell.duration > 0 then
        if self.spell.printInfo then
            print(string.format("%s: 设置持续效果结束时间[%.1f]秒", self.spell.spellName, self.spell.duration))
        end
        ServerScheduler.add(function()
            if self.spell.printInfo then
                print(string.format("%s: 持续效果时间到，停止效果", self.spell.spellName))
            end
            self:OnComplete()
        end, self.spell.duration)
    end
end

function PulsingAOE:OnComplete()
    -- 清理特效
    if self.actions then
        if self.spell.printInfo then
            gg.log(string.format("%s: 清理持续效果特效", self.spell.spellName), self.actions)
        end
        for _, action in ipairs(self.actions) do
            gg.log("action", action)
            if action then
                action()
            end
        end
    end
    
    -- Cancel the scheduler task
    if self.timer then
        if self.spell.printInfo then
            print(string.format("%s: 取消持续效果定时器", self.spell.spellName))
        end
        ServerScheduler.cancel(self.timer)
        self.timer = nil
    end
end

function PulsingAOE:ExecutePulse()
    if not self.caster then return end

    local hitTarget = self.spell:GetHitTargets(self.location, self.caster, self.param)
    if hitTarget then
        -- 如果不允许重复击中且已经击中过，则跳过
        if not self.spell.canHitSameTarget and self.hitCreatures[hitTarget] then
            if self.spell.printInfo then
                print(string.format("%s: 目标[%s]已被击中，跳过", self.spell.spellName, hitTarget.name))
            end
            return
        end
        self.hitCreatures[hitTarget] = true
        if #self.spell.subSpells > 0 then
            if self.spell.printInfo then
                print(string.format("%s: 持续效果击中目标[%s]，执行[%d]个子魔法", 
                    self.spell.spellName, hitTarget.name, #self.spell.subSpells))
            end
            for _, subSpell in ipairs(self.spell.subSpells) do
                local castSuccessed = subSpell:Cast(self.caster, hitTarget, self.param)
                if self.spell.printInfo then
                    print(string.format("%s: 子魔法[%s]执行[%s]", 
                        self.spell.spellName, 
                        subSpell.spellName, 
                        castSuccessed and "成功" or "失败"))
                end
            end
            self.spell:PlayEffect(self.spell.castEffects, self.caster, hitTarget, self.param, "击中目标")
        end
    else
        if self.spell.printInfo then
            print(string.format("%s: 持续效果未命中目标", self.spell.spellName))
        end
    end
    self.spell:PlayEffect(self.spell.castEffects, self.caster, self.location, self.param, "触发点")
end

---@class AOESpell:Spell
---@field duration number 持续时间
---@field canHitSameTarget boolean 可重复击中同一目标
---@field hitInterval number 击中间隔
---@field persistentEffects Graphic[] 特效_持续
---@field collisionType CollisionType 范围形状
---@field circleRadius number 圆形半径
---@field rectangleSize Vec3 方形长宽旋转
---@field ellipseMajorAxis number 椭圆长轴
---@field ellipseMinorAxis number 椭圆短轴
---@field ellipseRotation number 椭圆旋转
---@field offset Vec3 偏移
---@field aoeItemCount number AOE效果数量
---@field effectID number 效果ID
local AOESpell = ClassMgr.Class("AOESpell", Spell)

function AOESpell:OnInit(data)
    Spell.OnInit(self, data)
    self.duration = data["持续时间"] or 0
    self.canHitSameTarget = data["可重复击中同一目标"] or false
    self.hitInterval = data["击中间隔"] or 1
    self.persistentEffects = Graphics.Load(data["特效_持续"] or {})
    self.collisionType = data["范围形状"] or CollisionType.CIRCLE
    self.circleRadius = data["圆形半径"] or 0
    self.rectangleSize = gg.Vec3.new(data["方形长宽旋转"])
    self.ellipseMajorAxis = data["椭圆长轴"] or 0
    self.ellipseMinorAxis = data["椭圆短轴"] or 0
    self.ellipseRotation = data["椭圆旋转"] or 0
    self.offset = gg.Vec3.new(data["偏移"])
    
    self.aoeItems = {}
    self.aoeItemCount = 0
    self.effectID = 0
end

--- 获取命中目标
---@param loc Vector3 位置
---@param caster Entity 施法者
---@param param CastParam 参数
---@param log table 日志表
---@return Entity[]|nil 命中的目标列表
function AOESpell:GetHitTargets(loc, caster, param, log)
    local sizeScale = param:GetValue(self, "尺寸倍率", 1)
    local widthScale = param:GetValue(self, "宽度倍率", 1)
    local heightScale = param:GetValue(self, "高度倍率", 1)
    
    if self.printInfo then
        table.insert(log, string.format("%s: 检测范围形状[%s]", self.spellName, self.collisionType))
    end
    
    if self.collisionType == CollisionType.CIRCLE then
        local radius = self.circleRadius * widthScale * sizeScale
        if self.printInfo then
            table.insert(log, string.format("%s: 圆形半径[%.1f]", self.spellName, radius))
        end
        if radius == 0 then
            -- 点检测
            local hitTargets = caster.scene:OverlapSphereEntity(loc, 0.1, caster:GetEnemyGroup())
            if self.printInfo then
                table.insert(log, string.format("%s: 点检测命中[%d]个目标", self.spellName, hitTargets and #hitTargets or 0))
            end
            return hitTargets
        else
            local hitTargets = caster.scene:OverlapSphereEntity(loc, radius, caster:GetEnemyGroup())
            if self.printInfo then
                table.insert(log, string.format("%s: 圆形检测命中[%d]个目标", self.spellName, hitTargets and #hitTargets or 0))
            end
            return hitTargets
        end
    elseif self.collisionType == CollisionType.RECTANGLE then
        local scaleX = self.rectangleSize.X * widthScale * sizeScale
        local scaleY = self.rectangleSize.Y * heightScale * sizeScale
        local scaleZ = self.rectangleSize.Z * sizeScale
        local size = Vector3.New(scaleX, scaleY, scaleZ)
        if self.printInfo then
            table.insert(log, string.format("%s: 矩形尺寸[%.1f, %.1f, %.1f]", self.spellName, scaleX, scaleY, scaleZ))
        end
        local hitTargets = caster.scene:OverlapBoxEntity(loc, size, Vector3.zero, caster:GetEnemyGroup())
        if self.printInfo then
            table.insert(log, string.format("%s: 矩形检测命中[%d]个目标", self.spellName, hitTargets and #hitTargets or 0))
        end
        return hitTargets
    elseif self.collisionType == CollisionType.ELLIPSE then
        local maxRadius = math.max(self.ellipseMajorAxis, self.ellipseMinorAxis) * widthScale * sizeScale
        if self.printInfo then
            table.insert(log, string.format("%s: 椭圆长轴[%.1f] 短轴[%.1f] 旋转[%.1f]", 
                self.spellName, 
                self.ellipseMajorAxis * widthScale * sizeScale,
                self.ellipseMinorAxis * heightScale * sizeScale,
                self.ellipseRotation))
        end
        local hitTargets = caster.scene:OverlapSphereEntity(loc, maxRadius, caster:GetEnemyGroup())
        if hitTargets then
            local validTargets = {}
            for _, target in ipairs(hitTargets) do
                if self:IsPointInEllipse(target:GetPosition(), loc,
                    self.ellipseMajorAxis * widthScale * sizeScale,
                    self.ellipseMinorAxis * heightScale * sizeScale,
                    self.ellipseRotation) then
                    table.insert(validTargets, target)
                end
            end
            if self.printInfo then
                table.insert(log, string.format("%s: 椭圆检测命中[%d]个目标", self.spellName, #validTargets))
            end
            return #validTargets > 0 and validTargets or nil
        end
        if self.printInfo then
            table.insert(log, string.format("%s: 椭圆检测未命中目标", self.spellName))
        end
    end
    
    return nil
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function AOESpell:CastReal(caster, target, param)
    local log = {}
    local loc = target:GetPosition()
    if self.printInfo then
        table.insert(log, string.format("%s: 目标位置[%.1f, %.1f, %.1f]", self.spellName, loc.x, loc.y, loc.z))
    end
    
    if not self.offset:IsZero() then
        local target = param.realTarget or target
        local direction = (target:GetPosition() - caster:GetPosition()):Normalize()
        local rightDir = gg.Vec3.right
        loc = loc + direction * self.offset.x + rightDir * self.offset.y
        if self.printInfo then
            table.insert(log, string.format("%s: 应用偏移[%.1f, %.1f, %.1f]", self.spellName, self.offset.x, self.offset.y, self.offset.z))
            table.insert(log, string.format("%s: 最终位置[%.1f, %.1f, %.1f]", self.spellName, loc.x, loc.y, loc.z))
        end
    end
    self:PlayEffect(self.castEffects, caster, loc, param)
    
    if self.duration > 0 then
        if self.printInfo then
            table.insert(log, string.format("%s: 创建持续效果[%.1f]秒", self.spellName, self.duration))
        end
        local aoe = PulsingAOE.New(self, caster, target, loc, param)
        aoe:Start()
        if self.printInfo and #log > 0 then
            print(table.concat(log, "\n"))
        end
        return true
    end
    
    self:PlayEffect(self.castEffects, caster, loc, param, "触发点")
    -- 单次执行的情况
    local hitTargets = self:GetHitTargets(loc, caster, param, log)
    if hitTargets and #hitTargets > 0 then
        local anySucceed = false
        if #self.subSpells > 0 then
            if self.printInfo then
                table.insert(log, string.format("%s: 命中[%d]个目标，执行[%d]个子魔法", 
                    self.spellName, #hitTargets, #self.subSpells))
            end
            for _, hitTarget in ipairs(hitTargets) do
                if self.printInfo then
                    table.insert(log, string.format("%s: 对目标[%s]执行子魔法",
                        self.spellName, hitTarget.name))
                end
                for _, subSpell in ipairs(self.subSpells) do
                    local castSuccessed = subSpell:Cast(caster, hitTarget, param)
                    anySucceed = anySucceed or castSuccessed
                    if self.printInfo then
                        table.insert(log, string.format("%s: 子魔法[%s]执行[%s]", 
                            self.spellName, 
                            subSpell.spellName, 
                            castSuccessed and "成功" or "失败"))
                    end
                end
                self:PlayEffect(self.castEffects, caster, hitTarget, param, "击中目标")
            end
        end
        if self.printInfo and #log > 0 then
            print(table.concat(log, "\n"))
        end
        return anySucceed
    end
    
    if self.printInfo then
        table.insert(log, string.format("%s: 未命中目标", self.spellName))
        if #log > 0 then
            print(table.concat(log, "\n"))
        end
    end
    return false
end

--- 检查点是否在椭圆内
---@param point Vector3 要检查的点
---@param center Vector3 椭圆中心
---@param a number 长轴
---@param b number 短轴
---@param angle number 旋转角度（度）
---@return boolean 是否在椭圆内
function AOESpell:IsPointInEllipse(point, center, a, b, angle)
    -- 将点转换到椭圆的局部坐标系
    local angleRad = angle * math.pi / 180
    local cosAngle = math.cos(angleRad)
    local sinAngle = math.sin(angleRad)
    
    -- 将点转换到椭圆中心坐标系
    local translated = point - center
    
    -- 旋转到椭圆的主轴方向
    local x = translated.x * cosAngle + translated.y * sinAngle
    local y = -translated.x * sinAngle + translated.y * cosAngle
    
    -- 检查点是否在椭圆内
    return (x * x) / (a * a) + (y * y) / (b * b) <= 1
end

return AOESpell