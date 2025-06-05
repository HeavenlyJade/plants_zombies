
local MainStorage = game:GetService('MainStorage')
local ClassMgr      = require(MainStorage.code.common.ClassMgr)    ---@type ClassMgr
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell
local Condition = require(MainStorage.code.common.config_type.modifier.Condition) ---@type Condition
local gg = require(MainStorage.code.common.MGlobal)            ---@type gg

---@class Modifier
local _M = ClassMgr.Class("Modifier")

function _M:OnInit(data)
    -- 处理条件
    if data["条件"] then
        local conditionType = data["条件类型"] or "Variable"
        local conditionClass = Condition[conditionType]
        if conditionClass then
            self.condition = conditionClass.New(data["条件"])
        end
    end
    
    -- 设置其他属性
    self.targeter = data["目标"]
    self.targeterPath = data["目标场景名"]
    self.compareTo = data["比较对象"]
    self.compareToPath = data["比较对象场景名"]
    self.invert = data["反转"] or false
    self.action = data["动作"] or "必须"
    self.amount = data["数量"] or nil
    self.subSpell = data["魔法"]
    if self.subSpell then
        self.subSpell = SubSpell.New(self.subSpell)
    end
    self.overrideParams = data["复写参数"] or {}
    self.modifyValues = data["修改数值"] or {}
end

function _M:GetTarget(caster, target, targeter, targeterPath)
    if not targeter or targeter == "目标" then
        return target
    elseif targeter == "自己" then
        return caster
    else
        print("targeter", targeter)
        if not targeterPath then
            return target
        end
        local scene = target.scene ---@type Scene
        return scene.node2Entity[scene:Get(targeterPath)]
    end
end

function _M:Check(caster, target, param)
    local success = true
    local c = self:GetTarget(caster, target, self.compareTo, self.compareToPath)
    local t = self:GetTarget(caster, target, self.targeter, self.targeterPath)
    if self.condition ~= nil then
        success = self.condition:Check(self, c, t)
    end
    local stop = false
    if self.invert then success = not success end
    
    if self.action == "必须" then
        if not success then param.cancelled = true end
    elseif self.action == "拒绝" then
        if success then param.cancelled = true end
    elseif self.action == "停止" then
        if success then stop = true end
    elseif self.action == "继续" then
        if not success then stop = true end
    elseif self.action == "威力增加" then
        if success then param.power = param.power + gg.ProcessFormula(self.amount, caster, target) end
    elseif self.action == "威力乘以" then
        if success then param.power = param.power * gg.ProcessFormula(self.amount, caster, target) end
    elseif self.action == "释放" then
        if success and self.subSpell then
            self.subSpell:Cast(c, t, param)
        end
    elseif self.action == "改为释放" then
        if success and self.subSpell then
            self.subSpell:Cast(c, t, param)
            param.cancelled = true
        end
    end
    return stop
end

return _M