
local MainStorage = game:GetService('MainStorage')
local ClassMgr      = require(MainStorage.code.common.ClassMgr)    ---@type ClassMgr
local Modifier = require(MainStorage.code.common.config_type.modifier.Modifier)
local gg = require(MainStorage.code.common.MGlobal)            ---@type gg
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam


---@class Modifiers:Class
---@field New fun( data: table[] ):Modifiers
local _M = ClassMgr.Class("Modifiers")

function _M:OnInit(data)
    self.modifiers = {}
    if not data then
        return
    end
    for _, condition in ipairs(data) do
        table.insert(self.modifiers, Modifier.New(condition))
    end
end


---@param caster Entity 用于比较的另一个实体
---@param target Entity 实际检查的目标实体
---@param param? CastParam 释放参数，若不填则新建一个
---@return CastParam 最终的参数
function _M:Check(caster, target, param)
    if not param then
        param = CastParam.New()
    end
    for _, modifier in ipairs(self.modifiers) do
        if modifier:Check(caster, target, param) then
            break
        end
    end
    return param
end

return _M