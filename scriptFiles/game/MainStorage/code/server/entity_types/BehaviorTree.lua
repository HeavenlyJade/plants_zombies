local MainStorage = game:GetService("MainStorage")
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Vector3 = Vector3
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler

---@class MobBehavior:Class
---@field CanEnter fun(self:MobBehavior, entity:Entity, behavior:table):boolean
---@field OnEnter fun(self:MobBehavior, entity:Entity)
---@field Update fun(self:MobBehavior, entity:Entity)
---@field CanExit fun(self:MobBehavior, entity:Entity):boolean
---@field OnExit fun(self:MobBehavior, entity:Entity)
local MobBehavior = ClassMgr.Class("MobBehavior")

function MobBehavior:OnInit()
    ---@param self MobBehavior
    ---@param entity Monster
    ---@return boolean
    self.CanEnter = function(self, entity) return true end

    ---@param self MobBehavior
    ---@param entity Monster
    self.OnEnter = function(self, entity) end

    ---@param self MobBehavior
    ---@param entity Monster
    self.Update = function(self, entity) end

    ---@param self MobBehavior
    ---@param entity Monster
    ---@return boolean
    self.CanExit = function(self, entity) return true end

    ---@param self MobBehavior
    ---@param entity Monster
    self.OnExit = function(self, entity) end
end

-- 静止状态
---@class IdleBehavior:MobBehavior
local IdleBehavior = ClassMgr.Class("IdleBehavior", MobBehavior)

function IdleBehavior:OnInit()
    ---@param self IdleBehavior
    ---@param entity Monster
    ---@return boolean
    self.CanEnter = function(self, entity)
        return true -- 空闲状态总是可以进入
    end
    
    ---@param self IdleBehavior
    ---@param entity Monster
    self.OnEnter = function(self, entity)
        entity:Freeze(0) -- 取消之前的冻结
    end
    
    ---@param self IdleBehavior
    ---@param entity Monster
    self.Update = function(self, entity)
        -- 空闲状态下不需要特殊更新
    end
    
    ---@param self IdleBehavior
    ---@param entity Monster
    ---@return boolean
    self.CanExit = function(self, entity)
        return true -- 空闲状态总是可以退出
    end
    
    ---@param self IdleBehavior
    ---@param entity Monster
    self.OnExit = function(self, entity)
        entity.actor:StopNavigate()
    end
end

-- 随机移动状态
---@class WanderBehavior:MobBehavior
local WanderBehavior = ClassMgr.Class("WanderBehavior", MobBehavior)

function WanderBehavior:OnInit()
    ---@param self WanderBehavior
    ---@param entity Monster
    ---@param behavior table
    ---@return boolean
    self.CanEnter = function(self, entity, behavior)
        return behavior and behavior["类型"] == "随机移动" and gg.rand_int(100) < (behavior["几率"] or 100)
    end
    
    ---@param self WanderBehavior
    ---@param entity Monster
    self.OnEnter = function(self, entity)
        local behavior = entity:GetCurrentBehavior()
        local range = behavior["距离"] or 5
        
        -- 计算随机位置
        local randomOffset = Vector3.New(
            gg.rand_int_both(range),
            0,
            gg.rand_int_both(range)
        )
        
        -- 如果需要在出生点附近
        if behavior["保持在出生点附近"] then
            randomOffset = gg.vec.Add3(entity.spawnPos, randomOffset.x, randomOffset.y, randomOffset.z)
        else
            randomOffset = gg.vec.Add3(entity:GetPosition(), randomOffset.x, randomOffset.y, randomOffset.z)
        end ---@cast randomOffset Vector3
        entity.actor.Movespeed = entity:GetStat("速度")
        -- print("NavigateTo", randomOffset)
        entity.actor:NavigateTo(randomOffset)
    end
    
    ---@param self WanderBehavior
    ---@param entity Monster
    self.Update = function(self, entity)
        -- 检查是否到达目标位置
        if entity.actor.NoPath then
            entity:SetCurrentBehavior(nil)
        end
    end
    
    ---@param self WanderBehavior
    ---@param entity Monster
    ---@return boolean
    self.CanExit = function(self, entity)
        return entity.actor.NoPath
    end
    
    ---@param self WanderBehavior
    ---@param entity Monster
    self.OnExit = function(self, entity)
        entity.actor:StopNavigate()
    end
end

-- 近战攻击状态
---@class MeleeBehavior:MobBehavior
local MeleeBehavior = ClassMgr.Class("MeleeBehavior", MobBehavior)

function MeleeBehavior:OnInit()
    ---@param self MeleeBehavior
    ---@param entity Monster
    ---@param behavior table
    ---@return boolean
    self.CanEnter = function(self, entity, behavior)
        if not entity.target or not entity.target:CanBeTargeted() then 
            local searchRadius = behavior["主动索敌"]
            if searchRadius and searchRadius > 0 then
                entity:TryFindTarget(searchRadius) 
                if not entity.target or not entity.target:CanBeTargeted() then
                    return false
                end
            else
                return false
            end
        end
        -- 检查距离
        local escapeRange = behavior["脱战距离"] or 0
        if escapeRange > 0 then
            local distanceSq = gg.vec.DistanceSq3(entity:GetPosition(), entity.target:GetPosition())
            return distanceSq <= escapeRange ^ 2
        end
        return true
    end
    
    ---@param self MeleeBehavior
    ---@param entity Monster
    self.OnEnter = function(self, entity)
        -- 进入战斗状态
        entity.attackTimer = 0
        entity.isAttacking = false
        entity.skillCheckCounter = 0 -- 初始化技能检查计数器
    end
    
    ---@param self MeleeBehavior
    ---@param entity Monster
    self.Update = function(self, entity)
        if not entity.target or not entity.target:CanBeTargeted() then
            entity:SetCurrentBehavior(nil)
            return
        end
        -- 检查并释放待释放的技能
        if #entity.pendingSkills > 0 then
            entity.actor:LookAt(entity.target:GetPosition(), true)
            local skill = table.remove(entity.pendingSkills, 1)
            skill:CastSkill(entity, entity.target)
            return
        end

        -- 每30帧检查一次技能
        entity.skillCheckCounter = (entity.skillCheckCounter or 0) + 1
        if entity.skillCheckCounter >= 30 then
            entity.skillCheckCounter = 0
            
            local periodicSkills = entity.mobType:GetSkillsByTiming("周期")
            if periodicSkills then
                for _, skill in ipairs(periodicSkills) do
                    if skill:CanCast(entity, entity.target) then
                        table.insert(entity.pendingSkills, skill)
                        return
                    end
                end
            end
        end
        
        local behavior = entity:GetCurrentBehavior()
        local targetPos = entity.target:GetPosition()
        local distanceSq = gg.vec.DistanceSq3(entity:GetPosition(), targetPos)
        
        -- 如果距离太远，退出战斗
        local escapeRange = behavior["脱战距离"] or 0
        if escapeRange > 0 and distanceSq > escapeRange ^ 2 then
            entity:SetCurrentBehavior(nil)
            return
        end
        
        -- 计算实际攻击距离（实体大小 + 额外攻击距离）
        local attackRange = entity:GetSize().x + (entity.mobType.data["额外攻击距离"] or 0)
        local attackRangeSq = attackRange * attackRange
        -- print("attackRange", attackRange, math.sqrt(distanceSq))
        -- 在攻击范围内
        if distanceSq <= attackRangeSq then
            entity.actor:StopNavigate()
            -- 开始攻击
            entity.isAttacking = true
            
            -- 如果配置了攻击时静止
            if entity.mobType.data["攻击时静止"] then
                entity.actor:StopNavigate()
            end
            
            -- 延迟执行攻击
            entity.modelPlayer:OnAttack()
            local attackDelay = (entity.mobType.data["攻击时点"] or 0) * entity:GetAttackDuration()
            if attackDelay > 0 then
                ServerScheduler.add(function()
                    if entity.isAttacking then -- 再次检查是否仍在攻击状态
                        -- entity:Attack(entity.target, entity:GetStat("攻击"), "melee_attack")
                    end
                end, attackDelay)
            else
                -- entity:Attack(entity.target, entity:GetStat("攻击"), "melee_attack")
            end

            entity:Freeze(entity:GetAttackDuration())
            ServerScheduler.add(function()
                entity.isAttacking = false
            end, entity:GetAttackDuration())
        else
            -- 不在攻击范围内，移动接近目标
            entity.actor.Movespeed = entity:GetStat("速度")
            -- print("Navigate MELEE", targetPos)
            entity.actor:NavigateTo(targetPos)
        end
    end
    
    ---@param self MeleeBehavior
    ---@param entity Monster
    ---@return boolean
    self.CanExit = function(self, entity)
        if not entity.target or not entity.target:CanBeTargeted() then
            entity:SetTarget(nil)
             return true
        end
        
        local behavior = entity:GetCurrentBehavior()
        local escapeRange = behavior["脱战距离"] or 0
        if escapeRange > 0 then
            local distanceSq = gg.vec.DistanceSq3(entity:GetPosition(), entity.target:GetPosition())
            return distanceSq > escapeRange ^ 2
        end
        return false
    end
    
    ---@param self MeleeBehavior
    ---@param entity Monster
    self.OnExit = function(self, entity)
        entity.actor:StopNavigate()
        entity.isAttacking = false
    end
end

-- 创建行为实例

return {
    ["静止"] = IdleBehavior.New(),
    ["随机移动"] = WanderBehavior.New(),
    ["近战攻击"] = MeleeBehavior.New()
} 