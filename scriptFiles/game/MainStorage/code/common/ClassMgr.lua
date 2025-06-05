

if  _G.ClassMgr then
	--print( 'use cache ClassMgr' )
	return _G.ClassMgr
end

---@class ClassMgr        对class父子继承类的封装
local ClassMgr = {}
_G.ClassMgr = ClassMgr

function ClassMgr.Clone(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local newObject = {}
		lookup_table[object] = newObject
		for key, value in pairs(object) do
			newObject[_copy(key)] = _copy(value)
		end
		return setmetatable(newObject, getmetatable(object))
	end
	return _copy(object)
end

local s_register_class = {}
function ClassMgr.GetRegisterClass( classname )
	return s_register_class[classname]
end

function ClassMgr.RegisterClass( classname, cls)
	assert(s_register_class[classname] == nil, string.format("classname[%s]is exist", classname))
	s_register_class[classname] = cls
end

---@class Class
---@field className string 类名
---@field ToString fun(self:Class) : string
---@field GetToStringParams fun(self:Class) : table{number, any}
---@field New fun(...: any): any 返回本类的实例
---@field Is fun(self:Class, className: string): boolean 判断实例是否继承自指定类名
local Class = {}

function ClassMgr.Is(inst, className)
    if type(inst) == "table" then
        return inst.Is and inst:Is(className)
    end
	return false
end

---@generic T : Class
---@param name string 类名
---@param ... Class 父类
---@return T 返回类定义
function ClassMgr.Class( name, ...)
	local cls = nil
	local super = ...

	if super then
		cls = ClassMgr.Clone(super)
		cls.super = super
	else
		cls = { OnInit = function() end, Destroy = function() end}
	end

	cls.__index = cls
	cls.className = name
	cls.ToString = function (instance)
		local gg              = require(game:GetService("MainStorage").code.common.MGlobal) ---@type gg
		local paramsStr = {}
		if instance.GetToStringParams then
			local params = instance:GetToStringParams()
			for k, param in pairs(params) do
				if type(param) == "table" and param.className then
					paramsStr[k] = param:ToString()
				else
					paramsStr[k] = gg.table2str(param)
				end
			end
		end
		return instance.className .. gg.table2str(paramsStr)
	end

	cls.Is = function(instance, className)
		local current = instance
		while current do
			if current.className == className then
				return true
			end
			current = current.super
		end
		return false
	end

	local create = nil
	create = function(instance, c, ...)
		if c.super and create then
            create(instance, c.super, ...)
        end
		instance.className = name
        if c.OnInit then
            c.OnInit(instance, ...)
        end
	end

	function cls.New(...)
        local instance = setmetatable({}, cls)
        create(instance, cls, ...)
        return instance
    end

    ClassMgr.RegisterClass(name, cls)

    return cls
end

function math.clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end

	return value
end

return ClassMgr