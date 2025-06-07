local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local Graphics = require(MainStorage.code.server.graphic.Graphics) ---@type Graphics
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler

---@class BuffSpell:Spell
---@field duration number 持续时间
---@field durationIndependent boolean 持续时间独立计算
---@field refreshOnRecast boolean 重复释放刷新时间
---@field useCount number 生效次数
---@field maxStacks number 最大层数
---@field noUpdate boolean 无需更新
---@field durationEffects Graphic[] 特效_持续
local BuffSpell = ClassMgr.Class("BuffSpell", Spell)

---@class ActiveBuff:Class
---@field spell BuffSpell 魔法
---@field param CastParam 参数
---@field duration number 持续时间
---@field durations number[] 持续时间列表
---@field caster Entity 施法者
---@field activeOn Entity 作用目标
---@field disabled boolean 是否禁用
---@field uses number 剩余生效次数
---@field actions table 特效动作
---@field stack number 层数
---@field power number 威力
local ActiveBuff = ClassMgr.Class("ActiveBuff")
BuffSpell.ActiveBuff = ActiveBuff

function ActiveBuff:OnBuffInit()
end

function ActiveBuff:OnRefresh()
end

function ActiveBuff:OnRemoved()
    if self.actions then
        for _, action in ipairs(self.actions) do
            if action then
                action()
            end
        end
    end
end

function ActiveBuff:OnInit(caster, activeOn, spell, param)
    self.caster = caster
    self.activeOn = activeOn
    self.spell = spell
    self.param = param
    self.power = param.power
    self.stack = 1
    
    if spell.durationIndependent then
        self.durations = {spell.duration}
    else
        self.duration = spell.duration
    end
    
    self.uses = spell.useCount
    self.actions = spell:PlayEffect(spell.durationEffects, caster, activeOn, param)
    
    -- 注册定时更新任务
    self:RegisterUpdateTask()
    
    if spell.printInfo then
        print(string.format("%s: Buff初始化 - 目标:%s 威力:%.1f 层数:%d 持续时间:%.1f 剩余次数:%d", 
            spell.spellName, activeOn.name, self.power, self.stack, 
            spell.durationIndependent and spell.duration or self.duration, self.uses))
    end
    
    self:OnBuffInit()
end

function ActiveBuff:RegisterUpdateTask()
    -- 取消已存在的任务
    if self.updateTaskId then
        ServerScheduler.cancel(self.updateTaskId)
        self.updateTaskId = nil
    end
    
    -- 注册新的定时任务
    if self.spell.pulseTime > 0 then
        -- 周期性更新
        self.updateTaskId = ServerScheduler.add(function()
            if not self.disabled then
                self:OnTick(self.spell.pulseTime)
                self:OnPulse()
            end
        end, self.spell.pulseTime, self.spell.pulseTime)  -- 使用pulseTime作为重复间隔
    else
        -- 一次性更新，在持续时间结束时移除
        self.updateTaskId = ServerScheduler.add(function()
            if not self.disabled then
                self:OnTick(self.spell.duration)
                self:SetDisabled(true)
            end
        end, self.spell.duration)
    end
end

function ActiveBuff:OnTick(deltaTime)
    if self.activeOn.isDestroyed then
        self:SetDisabled(true)
        return
    end
    
    if self.spell.durationIndependent then
        for i = #self.durations, 1, -1 do
            local time = self.durations[i]
            time = time - deltaTime
            if time < 0 then
                table.remove(self.durations, i)
                self.stack = self.stack - 1
                if self.stack <= 0 then
                    self:SetDisabled(true)
                else
                    if self.spell.printInfo then
                        print(string.format("%s: Buff层数减少 - 目标:%s 剩余层数:%d", 
                            self.spell.spellName, self.activeOn.name, self.stack))
                    end
                    self:OnRefresh()
                end
            else
                self.durations[i] = time
            end
        end
    else
        self.duration = self.duration - deltaTime
        if self.duration <= 0 then
            self:SetDisabled(true)
        end
    end
end

function ActiveBuff:SetDisabled(disabled)
    if self.spell.printInfo then
        print(string.format("%s: Buff移除 - 目标:%s 原因:%s", 
            self.spell.spellName, self.activeOn.name, disabled and "禁用" or "结束"))
    end
    
    -- 取消定时更新任务
    if self.updateTaskId then
        ServerScheduler.cancel(self.updateTaskId)
        self.updateTaskId = nil
    end
    
    self.disabled = disabled
    self.activeOn.activeBuffs[self.spell.spellName] = nil
    self:OnRemoved()
end

function ActiveBuff:OnPulse()
end

function ActiveBuff:ReduceUse()
    if self.uses > 0 then
        self.uses = self.uses - 1
        if self.uses <= 0 then
            self:SetDisabled(true)
        end
    end
end

function ActiveBuff:CastAgain(param)
    local success = false
    
    if self.spell.refreshOnRecast then
        if self.spell.durationIndependent then
            table.insert(self.durations, self.spell.duration)
        else
            self.duration = self.spell.duration
        end
        success = true
        
        -- 重新注册定时任务
        self:RegisterUpdateTask()
    end
    
    self.power = (param.power + self.power * self.stack) / (self.stack + 1)
    
    if self.stack < self.spell.maxStacks then
        self.stack = self.stack + 1
        success = true
    end
    
    if self.spell.printInfo then
        print(string.format("%s: Buff刷新 - 目标:%s 新威力:%.1f 新层数:%d 持续时间:%.1f", 
            self.spell.spellName, self.activeOn.name, self.power, self.stack,
            self.spell.durationIndependent and self.spell.duration or self.duration))
    end
    
    self:OnRefresh()
    return success
end

function BuffSpell:OnInit(data)
    
    -- 从配置中读取Buff相关属性
    self.duration = data["持续时间"] or 0
    self.durationIndependent = data["持续时间独立计算"] or false
    self.refreshOnRecast = data["重复释放刷新时间"] or true
    self.useCount = data["生效次数"] or 0
    self.maxStacks = data["最大层数"] or 1
    self.noUpdate = data["无需更新"] or false
    self.pulseTime = data["脉冲时间"] or 0
    
    -- 加载持续特效
    self.durationEffects = Graphics.Load(data["特效_持续"])

    if self.printInfo then
        print(string.format("%s: 初始化Buff魔法 - 持续时间:%.1f 独立计算:%s 刷新:%s 生效次数:%d 最大层数:%d 脉冲时间:%.1f", 
            self.spellName, self.duration, tostring(self.durationIndependent), 
            tostring(self.refreshOnRecast), self.useCount, self.maxStacks, self.pulseTime))
    end
end

function BuffSpell:CastReal(caster, target, param)
    if not target.isEntity then return false end
    
    if target.activeBuffs[self.spellName] then
        if self.printInfo then
            print(string.format("%s: 刷新Buff - 施法者:%s 目标:%s", self.spellName, caster.name, target.name))
        end
        return target.activeBuffs[self.spellName]:CastAgain(param)
    else
        if self.printInfo then
            print(string.format("%s: 添加新Buff - 施法者:%s 目标:%s", self.spellName, caster.name, target.name))
        end
        local buff = self:BuildBuff(caster, target, param)
        target.activeBuffs[self.spellName] = buff
        buff:OnRefresh()
        return true
    end
end

function BuffSpell:BuildBuff(caster, target, param)
    return ActiveBuff.New(caster, target, self, param)
end

return BuffSpell
