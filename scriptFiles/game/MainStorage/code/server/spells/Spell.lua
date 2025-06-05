local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local gg = require(MainStorage.code.common.MGlobal)            ---@type gg
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell
local Graphics = require(MainStorage.code.server.graphic.Graphics) ---@type Graphics
local ServerEventManager = require(MainStorage.code.server.event.ServerEventManager) ---@type ServerEventManager



---@class Spell:Class
---@field spellName string 魔法名
---@field printInfo boolean 打印信息
---@field comment string 注释
---@field cooldown number 冷却
---@field cooldownSpeed number 冷却加速
---@field targetCooldown number 各目标冷却
---@field targetCooldownRate number 各目标冷却倍率
---@field basePower number 基础威力
---@field castOnSelf boolean 释放给自己
---@field delay number 延迟
---@field selfConditions Modifier[] 自身条件
---@field targetConditions Modifier[] 目标条件
---@field subSpells SubSpell[] 子魔法
---@field preCastEffects Graphic[] 特效_前摇释放
---@field preTargetEffects Graphic[] 特效_前摇目标
---@field castEffects Graphic[] 特效_释放
---@field targetEffects Graphic[] 特效_目标
---@field widthScale number 宽度倍率
---@field heightScale number 高度倍率
---@field sizeScale number 尺寸倍率
---@field New fun( data:table ):Spell
local Spell = ClassMgr.Class("Spell")

function Spell.Load( data )
    local node = MainStorage.code.server.spells.spell_types[data["类型"]]
    if not node then
        gg.log("不存在的魔法类型", data["魔法名"], data["类型"], MainStorage.code.server.spells.spell_types)
        return nil
    end
    local class = require(node)
    return class.New(data)
end

function Spell:OnInit( data )
    -- 从配置中读取基础属性
    self.spellName = data["魔法名"] or ""
    self.printInfo = data["打印信息"] or false
    self.comment = data["注释"] or ""
    self.chance = data["几率"] or 0
    self.cooldown = data["冷却"] or 0
    self.cooldownSpeed = data["冷却加速"] or 1
    self.targetCooldown = data["各目标冷却"] or 0
    self.targetCooldownRate = data["各目标冷却倍率"] or 0
    self.basePower = data["基础威力"] or 1
    self.castOnSelf = data["释放给自己"] or false
    self.delay = data["延迟"] or 0
    self.widthScale = data["宽度倍率"] or 1
    self.heightScale = data["高度倍率"] or 1
    self.sizeScale = data["尺寸倍率"] or 1
    self.targetConditions = data["释放条件"] ---@type Modifiers
    self.requireTarget = data["必须要目标"]
    if self.requireTarget == nil then
        self.requireTarget = true
    end

    -- 初始化子魔法数组
    self.subSpells = {}
    if data["子魔法"] then
        for _, subSpellData in ipairs(data["子魔法"]) do
            local subSpell = SubSpell.New(subSpellData)
            table.insert(self.subSpells, subSpell)
        end
    end

    -- 加载特效
    self.preCastEffects = Graphics.Load(data["特效_前摇"])
    self.castEffects = Graphics.Load(data["特效_释放"])
end


function Spell:GetName(target)
    if not target then
        return "[无目标]"
    elseif type(target) == "userdata" then
        return tostring(target)
    elseif target.Is and target:Is("Entity") then
        return target.name
    else
        return tostring(target)
    end
end

--- 执行魔法
---@param caster Entity 施法者
---@param target Entity|Vector3|Vec3|nil 目标
---@param param? CastParam 参数
---@return boolean 是否成功释放
function Spell:Cast(caster, target, param)
    if not param then
        param = CastParam.New()
    end
    param.realTarget = target

    if not caster then
        return false
    end
    if not target then
        if self.castOnSelf then
            target = caster
        else
            if self.requireTarget then
                -- 获取施法者面前的敌人
                local casterPos = caster:GetPosition()
                local ret_table = caster.scene:OverlapSphereEntity(casterPos, 5000, caster:GetEnemyGroup(), nil)
                for _, hit in pairs(ret_table) do
                    if hit ~= caster then
                        target = hit
                        break
                    end
                end
                if not target then
                    print(self.spellName .. ": 找不到目标")
                    return false
                end
            end
        end
    end

    param.power = param.power * param:GetValue(self, "基础威力", self.basePower)

    local log = {}
    if not self:CanCast(caster, target, param, log) then
        if self.printInfo then
            print(table.concat(log, "\n"))
        end
        return false
    end

    -- 广播魔法释放事件
    local castEvent = {
        caster = caster,
        target = target,
        spell = self,
        param = param,
        cancelled = false
    }
    ServerEventManager.Publish("SpellCastEvent", castEvent)
    
    -- 如果事件被取消，则释放失败
    if castEvent.cancelled then
        if self.printInfo then
            log[#log + 1] = string.format("%s：魔法释放被取消", self.spellName)
            print(table.concat(log, "\n"))
        end
        return false
    end

    caster:TriggerTags("castSpell", target, param, self, param)
    if param.cancelled then
        if self.printInfo then
            log[#log + 1] = string.format("%s：词条【释放魔法时】被取消", self.spellName)
            print(table.concat(log, "\n"))
        end
        return false
    end

    if target and self:IsEntity(target) then
        target:TriggerTags("beCastSpell", caster, param, param)
    end
    if param.cancelled then
        if self.printInfo then
            log[#log + 1] = string.format("%s：词条【被释放魔法时】被取消", self.spellName)
            print(table.concat(log, "\n"))
        end
        return false
    end

    if param:GetParam(self, "释放给自己", self.castOnSelf) then
        target = caster
    end

    local cd = param:GetValue(self, "冷却", self.cooldown)
    if cd > 0 then
        cd = cd / param:GetValue(self, "冷却加速", self.cooldownSpeed)
        caster:SetCooldown(self.spellName, cd)
        if self.printInfo then
            log[#log + 1] = string.format("%s：设置冷却%.1f秒", self.spellName, cd)
        end
    end

    local targetCd = param:GetValue(self, "各目标冷却", self.targetCooldown)
    if targetCd > 0 and target and target.isEntity then
        caster:SetCooldown(self.spellName, targetCd, target:GetEntity())
        if self.printInfo then
            log[#log + 1] = string.format("%s：设置对该目标冷却%.1f秒", self.spellName, targetCd)
        end
    end

    self:PlayEffect(self.preCastEffects, caster, param.realTarget, param)

    table.insert(log, string.format("%s: %s对%s释放通过, 威力%s", self.spellName, caster.name, self:GetName(target), param.power))
    local delay = param:GetValue(self, "延迟", self.delay)
    if delay > 0 then
        if self.printInfo then
            log[#log + 1] = string.format("%s：延迟%.1f秒后释放", self.spellName, delay)
            print(table.concat(log, "\n"))
        end
        ServerScheduler.Add(function()
            self:PlayEffect(self.castEffects, caster, target, param)
            self:CastReal(caster, target, param)
        end, delay)
        return true
    else
        if self.printInfo and #log > 0 then
            print(table.concat(log, "\n"))
        end
        self:PlayEffect(self.castEffects, caster, target, param)
        return self:CastReal(caster, target, param)
    end
end

--- 播放特效
---@param effects Graphic[] 特效数组
---@param playFrom Entity|Vector3 播放起点
---@param playAt Entity|Vector3 播放终点
---@param param CastParam 参数
---@param targetMode? string
---@return Action[] 特效动作数组
function Spell:PlayEffect(effects, playFrom, playAt, param, targetMode)
    if not effects then return nil end
    local actions = {}
    for i, effect in ipairs(effects) do
        if effect and effect:IsTargeter(targetMode) then
            effect:PlayAt(playFrom, playAt, param, actions)
        end
    end
    return actions
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity|Vector3 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function Spell:CastReal(caster, target, param)
    return true
end

function Spell:GetPosition(target)
    if type(target) == "userdata" then
        return gg.Vec3.new(target)
    else
        if type(target) == "table" and target.Is and target:Is("Entity") then
            return gg.Vec3.new(target:GetPosition())
        else
            return target
        end
    end
end

function Spell:IsEntity(target)
    if type(target) == "table" and target.Is and target:Is("Entity") then
        return true
    end
    return false
end

--- 检查是否可以释放魔法
---@param caster Entity 施法者
---@param target Entity|Vector3 目标
---@param param CastParam 参数
---@param log? string[] 日志数组
---@param checkCd? boolean 是否检查冷却 
---@return boolean 是否可以释放
function Spell:CanCast(caster, target, param, log, checkCd)
    if not param then
        param = CastParam.New()
    end
    if checkCd == nil then
        checkCd = true
    end
    if checkCd then
        if  self.cooldown > 0 and caster:IsCoolingdown(self.spellName) then
            if log then
                log[#log + 1] = string.format("%s：冷却中", self.spellName)
            end
            return false
        end

        if  self.targetCooldown > 0 and self:IsEntity(target) and caster:IsCoolingdown(self.spellName, target) then
            if log then
                log[#log + 1] = string.format("%s：对该目标冷却中", self.spellName)
            end
            return false
        end
        if self.chance > 0 then
            local randomValue = math.random() * 100
            if randomValue > self.chance then
                if log then
                    log[#log + 1] = string.format("%s：释放几率未触发 (%.1f%% > %.1f%%)", self.spellName, randomValue, self.chance)
                end
                return false
            end
        end
    end

    if self.targetConditions then
        for i, item in ipairs(self.targetConditions.modifiers) do
            local stop = item:Check(caster, target, param)
            if stop then break end
            if param.cancelled then
                if self.printInfo then 
                    table.insert(log, string.format("%s释放失败：第%d个自身条件不满足 条件=%s", self.spellName, i+1, item.condition.condition))
                end
                break
            end
        end
    end

    if param.cancelled then
        if log then
            log[#log + 1] = string.format("%s：目标条件不满足", self.spellName)
        end
        return false
    end

    return true
end

return Spell
