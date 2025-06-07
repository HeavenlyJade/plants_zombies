local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local RunService = game.RunService
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local Graphics = require(MainStorage.code.server.graphic.Graphics) ---@type Graphics
local Vec3 = require(MainStorage.code.common.math.Vec3) ---@type Vec3
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell

---@class ProjectileSpell:Spell
---@field projectileModel string 飞弹模型名称
---@field speed number 飞行速度
---@field canHitSameTarget boolean 可重复击中同一目标
---@field hitInterval number 击中间隔
---@field maxHits number 最大命中次数
---@field scatterCount number 散射次数
---@field scatterAngle number 散射角度
---@field scatterDelay number 散射延迟
---@field spawnAtCaster boolean 是否在施法者位置生成
---@field activeProjectiles table<number, ProjectileItem> 正在活动的飞弹
---@field projectileCount number 飞弹数量
---@field projectileID number 飞弹ID
---@field duration number 飞弹持续时间
---@field canPassThroughTerrain boolean 是否可以穿过地形
---@field projectilePool table<Actor> 飞弹对象池
---@field maxPoolSize number 对象池最大大小
---@field initialAngleOffset Vec2 初始角度修改
---@field gravity number 重力
---@field trackingSpeed number 追踪目标速度
local ProjectileSpell = ClassMgr.Class("ProjectileSpell", Spell)

---@class ProjectileItem
---@field actor Actor 飞弹Actor
---@field caster Entity 施法者
---@field direction Vec3 飞行方向
---@field baseDirection Vec3 基础方向
---@field size Vec3
---@field param CastParam 参数
---@field hitTargets table<Entity, boolean> 已命中目标
---@field lastHitTimes table<Entity, number> 上次命中时间
---@field remainingHits number 剩余命中次数
---@field moveConnection SBXConnection 移动更新连接
---@field velocity Vec3 当前速度
---@field destroyCount number 销毁计数
---@field target Entity|nil 追踪目标
---@field startTime number 飞弹生成时间
---@field updateCount number 更新计数
local ProjectileItem = {}

function ProjectileSpell:OnInit(data)
    self.projectileModel = data["飞弹模型"] or "飞弹"
    self.canHitSameTarget = data["可重复碰撞同一目标"] or false
    self.hitInterval = data["对同一目标生效间隔"] or -1
    self.maxHits = data["生效次数"] or -1
    self.scatterCount = data["散射次数"] or 1
    self.scatterAngle = data["散射角度"] or 0
    self.scatterDelay = data["散射延迟"] or 0
    self.spawnAtCaster = data["生成于自己位置"] or false
    self.duration = data["持续时间"] or 5
    self.canPassThroughTerrain = data["穿过地形"]
    self.projectileEffects = Graphics.Load(data["特效_飞弹"])
    self.activeProjectiles = {}
    self.projectileCount = 0
    self.projectileID = 0
    self.projectilePool = {}
    self.maxPoolSize = data["对象池大小"] or 20
    
    self.subSpellsOnEnd = {} ---@type SubSpell[]
    if data["结束子魔法"] then
        for _, subSpellData in ipairs(data["结束子魔法"]) do
            local subSpell = SubSpell.New(subSpellData)
            table.insert(self.subSpellsOnEnd, subSpell)
        end
    end
    -- 新增配置项
    self.speed = data["速度"] or 500
    self.gravity = data["重力"] or 0
    self.trackingSpeed = data["追踪目标速度"] or 0
    self.initialAngleOffset = gg.Vec2.new(data["初始角度修改"] or {0, 0})
end

--- 生成唯一ID
---@return number
function ProjectileSpell:GenerateId()
    self.projectileID = self.projectileID + 1
    return self.projectileID
end

--- 从对象池获取飞弹Actor
---@return Actor|nil
function ProjectileSpell:GetProjectileFromPool()
    if #self.projectilePool > 0 then
        return table.remove(self.projectilePool)
    end
    return nil
end

--- 将飞弹Actor返回对象池
---@param actor Actor
function ProjectileSpell:ReturnProjectileToPool(actor)
    if #self.projectilePool < self.maxPoolSize then
        actor.Visible = false
        actor.Enabled = false
        table.insert(self.projectilePool, actor)
    else
        actor:Destroy()
    end
end

--- 生成飞弹
---@param position Vec3 生成位置
---@param direction Vec3 飞行方向
---@param baseDirection Vec3 基础方向
---@param caster Entity 施法者
---@param param CastParam 参数
---@param delay number 延迟时间
function ProjectileSpell:SpawnProjectile(position, direction, baseDirection, caster, param, delay)
    if delay and delay > 0 then
        ServerScheduler.add(function()
            self:CreateProjectile(position, direction, baseDirection, caster, param)
        end, delay)
    else
        self:CreateProjectile(position, direction, baseDirection, caster, param)
    end
end

--- 创建飞弹
---@param position Vec3 生成位置
---@param direction Vec3 飞行方向
---@param baseDirection Vec3 基础方向
---@param caster Entity 施法者
---@param param CastParam 参数
function ProjectileSpell:CreateProjectile(position, direction, baseDirection, caster, param)
    -- 从对象池获取或创建新的飞弹Actor
    local actor = self:GetProjectileFromPool()
    if not actor then
        local originalActor = MainStorage["飞弹"][self.projectileModel] ---@type Actor
        if not originalActor and game.WorkSpace["飞弹"] then
            originalActor = game.WorkSpace["飞弹"][self.projectileModel] ---@type Actor
        end
        if not originalActor then
            if self.printInfo then
                print(string.format("%s: 飞弹模型不存在 - %s", self.spellName, self.projectileModel))
            end
            return
        end
        actor = originalActor:Clone()
        if self.printInfo then
            print(string.format("%s: 创建新的飞弹Actor", self.spellName))
        end
    else
        if self.printInfo then
            print(string.format("%s: 从对象池获取飞弹Actor", self.spellName))
        end
    end
    
    actor.Parent = caster.scene.node["世界特效"]
    actor.Enabled = true
    actor.Visible = false  -- 初始设置为不可见
    actor.CollideGroupID = 9
    
    if self.initialAngleOffset.x ~= 0 then
        direction.y = direction.y + self.initialAngleOffset.x / 90
    end
    if self.initialAngleOffset.y ~= 0 then
        direction = direction:rotateAroundY(self.initialAngleOffset.y)
    end
    local item = {
        actor = actor,
        caster = caster,
        direction = direction,
        baseDirection = Vec3.new(baseDirection),
        param = param,
        hitTargets = {},
        lastHitTimes = {},
        remainingHits = param:GetValue(self, "生效次数", self.maxHits),
        startTime = os.time(),
        size = Vec3.new(actor.Size) * Vec3.new(actor.LocalScale),
        updateCount = 0,  -- 添加更新计数器
        velocity = direction * self.speed,  -- 初始速度
        target = param.realTarget  -- 保存追踪目标
    }
    local pos = position + Vec3.new(0, -item.size.y/2, 0)
    actor.Position = pos:ToVector3()

    -- 注册飞弹
    local id = self:GenerateId()
    self.activeProjectiles[id] = item
    self.projectileCount = self.projectileCount + 1
    
    -- 设置移动更新
    item.moveConnection = RunService.Stepped:Connect(function()
        self:UpdateProjectile(id)
    end)
end

--- 更新飞弹
---@param id number 飞弹ID
function ProjectileSpell:UpdateProjectile(id)
    local item = self.activeProjectiles[id] ---@type ProjectileItem
    if not item then return end
    
    -- 应用重力
    if self.gravity ~= 0 then
        item.velocity = item.velocity + Vec3.new(0, -self.gravity, 0)
    end
    
    -- 应用追踪
    if self.trackingSpeed > 0 and item.target and (not self:IsEntity(item.target) or item.target:CanBeTargeted()) then
        local targetPos = Vec3.new(item.target:GetPosition())
        local currentPos = Vec3.new(item.actor.Position)
        local toTarget = (targetPos - currentPos):Normalized()
        item.velocity = item.velocity + toTarget * self.trackingSpeed
        if self.printInfo and item.updateCount % 60 == 0 then
            print(string.format("%s: 飞弹正在追踪目标，当前速度: %.1f", self.spellName, item.velocity:Length()))
        end
    end
    
    -- 更新位置
    local newPosition = Vec3.new(item.actor.Position) + item.velocity * (1/60)  -- 假设60FPS
    item.actor.Position = newPosition:ToVector3()
    
    -- 更新方向
    if not item.velocity:IsZero() then
        local velocity = item.velocity
        local pitch = math.deg(math.atan2(velocity.y, math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z)))
        local yaw = math.deg(math.atan2(velocity.x, velocity.z))
        item.actor.LocalEuler = Vec3.new(pitch, yaw, 0):ToVector3()
    end
    
    -- 延迟两次更新后设置为可见
    item.updateCount = item.updateCount + 1
    if item.updateCount >= 5 then
        item.actor.Visible = true
    end
    
    -- 如果设置了销毁计数，则递减计数并在计数为0时销毁
    if item.destroyCount then
        item.destroyCount = item.destroyCount - 1
        if item.destroyCount <= 0 then
            self:DestroyProjectile(id)
            self:PlayEffect(self.castEffects, item.caster, newPosition, item.param, "触发点")
        end
        return
    end
    
    -- 检查碰撞
    local hitTargets = item.caster.scene:OverlapBoxEntity(
        Vec3.new(item.actor.Position) + Vec3.new(0, item.size.y / 2, 0):ToVector3(),
        item.size:ToVector3(),
        item.actor.LocalEuler,
        item.caster:GetEnemyGroup()
    )
    if hitTargets and #hitTargets > 0 then
        -- 计算每个目标到飞弹起始位置的距离
        local targetDistances = {}
        local startPos = Vec3.new(item.actor.Position)
        for _, target in ipairs(hitTargets) do
            if target ~= item.caster then
                local targetPos = Vec3.new(target:GetPosition())
                local distance = (targetPos - startPos):Length()
                table.insert(targetDistances, {
                    target = target,
                    distance = distance
                })
            end
        end
        
        -- 按距离排序
        table.sort(targetDistances, function(a, b)
            return a.distance < b.distance
        end)
        
        -- 只处理最近的 remainingHits 个目标
        local hitsProcessed = 0
        for _, targetData in ipairs(targetDistances) do
            if hitsProcessed >= item.remainingHits then
                break
            end
            self:HandleProjectileHit(id, targetData.target)
            hitsProcessed = hitsProcessed + 1
        end
    end
    
    -- 检查地形碰撞
    if not self.canPassThroughTerrain then
        local hitGround = item.caster.scene:OverlapBox(
            Vec3.new(item.actor.Position) + Vec3.new(0, item.size.y / 2, 0):ToVector3(),
            Vec3.new(20, 20, 20):ToVector3(),
            item.actor.LocalEuler,
            {1}
        )
        if hitGround and #hitGround > 0 then
            item.destroyCount = 3  -- 地形碰撞也延迟三次更新后销毁
        end
    end
    
    -- 检查持续时间
    if self.duration > 0 then
        if item.startTime and os.time() - item.startTime >= self.duration then
            item.destroyCount = 3  -- 超时也延迟三次更新后销毁
        end
    end
end

--- 处理飞弹碰撞
---@param id number 飞弹ID
---@param target Entity 碰撞目标
function ProjectileSpell:HandleProjectileHit(id, target)
    local item = self.activeProjectiles[id]
    if not item then return end
    
    -- 检查是否可以命中目标
    if not self:CanHitTarget(item, target) then
        if self.printInfo then
            print(string.format("%s: 飞弹无法命中目标 %s (已命中或冷却中)", self.spellName, target.name))
        end
        return
    end
    
    if self.printInfo then
        print(string.format("%s: 飞弹命中目标 %s", self.spellName, target.name))
    end
    
    -- 执行子魔法
    if #self.subSpells > 0 then
        for _, subSpell in ipairs(self.subSpells) do
            subSpell:Cast(item.caster, target, item.param)
        end
    end
    self:PlayEffect(self.castEffects, item.caster, target, item.param, "击中目标")
    
    -- 更新命中记录
    item.hitTargets[target] = true
    item.lastHitTimes[target] = os.time()
    
    -- 检查是否需要销毁飞弹
    if item.remainingHits > 0 then
        item.remainingHits = item.remainingHits - 1
        if item.remainingHits == 0 then
            item.destroyCount = 5  -- 设置需要三次更新后再销毁
        end
    end
end

--- 检查是否可以命中目标
---@param item ProjectileItem 飞弹项
---@param target Entity 目标
---@return boolean 是否可以命中
function ProjectileSpell:CanHitTarget(item, target)
    -- 检查是否已经击中过这个目标
    if not self.canHitSameTarget and item.hitTargets[target] then
        -- 如果有设置生效间隔，检查是否已经过了间隔时间
        if self.hitInterval > 0 then
            local lastHitTime = item.lastHitTimes[target]
            if lastHitTime and os.time() - lastHitTime >= self.hitInterval then
                return true
            end
        end
        return false
    end
    return true
end

--- 销毁飞弹
---@param id number 飞弹ID
function ProjectileSpell:DestroyProjectile(id)
    local item = self.activeProjectiles[id]
    if not item then return end

    if self.printInfo then
        print(string.format("%s: 销毁飞弹，剩余飞弹数: %d", self.spellName, self.projectileCount - 1))
    end

    -- 在飞弹消失位置释放结束子魔法
    if #self.subSpellsOnEnd > 0 then
        local finalPosition = Vec3.new(item.actor.Position)
        for _, subSpell in ipairs(self.subSpellsOnEnd) do
            subSpell:Cast(item.caster, finalPosition, item.param)
        end
        if self.printInfo then
            print(string.format("%s: 释放结束子魔法", self.spellName))
        end
    end

    if item.moveConnection then
        item.moveConnection:Disconnect()
    end
    if item.actor then
        self:ReturnProjectileToPool(item.actor)
    end
    self.activeProjectiles[id] = nil
    self.projectileCount = self.projectileCount - 1
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function ProjectileSpell:CastReal(caster, target, param)
    if self.printInfo then
        print(string.format([[
%s: 开始释放飞弹魔法
- 施法者: %s
- 目标: %s]], 
            self.spellName, caster.name, target and target.name or "无"))
    end

    -- 确定生成位置
    local position
    if self.spawnAtCaster then
        position = caster:GetCenterPosition()
        if self.printInfo then
            print(string.format("%s: 在施法者位置生成飞弹", self.spellName))
        end
    else
        if not target then
            if self.printInfo then
                print(string.format("%s: 没有目标，无法生成飞弹", self.spellName))
            end
            return false
        end
        position = target:GetCenterPosition()
        if self.printInfo then
            print(string.format("%s: 在目标位置生成飞弹", self.spellName))
        end
    end

    local baseDirection
    if not target then
        if param.lookDirection then
            baseDirection = param.lookDirection
        else
            baseDirection = caster:GetDirection()
        end
    else
        baseDirection = (self:GetPosition(target) - self:GetPosition(caster)):Normalize()
    end
    param.realTarget = target
    
    -- 获取散射参数
    local shootCount = param:GetValue(self, "散射次数", self.scatterCount)
    local shootAngle = param:GetValue(self, "散射角度", self.scatterAngle)
    local shootDelay = param:GetValue(self, "散射延迟", self.scatterDelay)
    
    -- 如果只有一发，直接生成
    if shootCount <= 1 then
        self:SpawnProjectile(Vec3.new(position), Vec3.new(baseDirection), Vec3.new(baseDirection), caster, param, 0)
        return true
    end
    
    -- 计算散射角度
    local totalAngle = shootAngle
    local angleStep
    local startAngle
    
    if shootCount % 2 == 0 and shootAngle > 0 then
        -- 偶数情况：从中心向两边散开
        angleStep = totalAngle / (shootCount - 1)
        startAngle = -totalAngle / 2
    else
        -- 奇数情况：中心对齐
        angleStep = totalAngle / math.max(1, shootCount - 1)
        startAngle = -totalAngle / 2
    end
    
    -- 生成所有散射
    for i = 1, shootCount do
        local currentAngle = startAngle + (angleStep * (i - 1))
        local angleRad = math.rad(currentAngle)
        local currentDirection = Vec3.new(
            baseDirection.x * math.cos(angleRad) - baseDirection.z * math.sin(angleRad),
            baseDirection.y,
            baseDirection.x * math.sin(angleRad) + baseDirection.z * math.cos(angleRad)
        )
        local delay = shootDelay * (i - 1)
        self:SpawnProjectile(Vec3.new(position), currentDirection, Vec3.new(baseDirection), caster, param, delay)
    end
    
    return true
end

return ProjectileSpell 