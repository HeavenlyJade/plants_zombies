
---@class Vec2
local Vec2 = {}

--实例化
---@param x Vector2|Vec2|number[]|number
---@param y? number
---@return Vec2
function Vec2.new(x, y)
    local obj = {}
    if not x then
        return nil
    end
    if type(x) == "table" then
        if x.x then
            obj.x = x.x
            obj.y = x.y
        else
            obj.x = x[1] or 0
            obj.y = x[2] or 0
        end
    elseif type(x) == "number" then
        obj.x = x or 0
        obj.y = y or 0
    else
        obj.x = x.x
        obj.y = x.y
    end
    Vec2.__index = Vec2
    setmetatable(obj, Vec2)
    return obj
end

function Vec2.zero()
    return Vec2.new(0, 0)
end

function Vec2.one()
    return Vec2.new(1, 1)
end
---------------------------------运算符重载-------------------------------
--加
function Vec2.__add(lhs, rhs)
    return Vec2.new(lhs.x + rhs.x, lhs.y + rhs.y)
end

--减
function Vec2.__sub(lhs, rhs)
    return Vec2.new(lhs.x - rhs.x, lhs.y - rhs.y)
end

--乘
function Vec2.__mul(lhs, rhs)
    if type(lhs) == "number" then
        return Vec2.new(lhs * rhs.x, lhs * rhs.y)
    elseif type(rhs) == "number" then
        return Vec2.new(lhs.x * rhs, lhs.y * rhs)
    else
        return Vec2.new(lhs.x * rhs.x, lhs.y * rhs.y)
    end
end

--除
function Vec2.__div(lhs, rhs)
    if type(rhs) == "number" then
        return Vec2.new(lhs.x / rhs, lhs.y / rhs)
    else
        return Vec2.new(lhs.x / rhs.x, lhs.y / rhs.y)
    end
end

--负
function Vec2.__unm(v)
    return Vec2.new(-v.x, -v.y)
end

--等于
function Vec2.__eq(lhs, rhs)
    return lhs.x == rhs.x and lhs.y == rhs.y
end

--不等于
function Vec2.__ne(lhs, rhs)
    return lhs.x ~= rhs.x or lhs.y ~= rhs.y
end

--小于
function Vec2.__lt(lhs, rhs)
    return lhs.x < rhs.x and lhs.y < rhs.y
end

--小于等于
function Vec2.__le(lhs, rhs)
    return lhs.x <= rhs.x and lhs.y <= rhs.y
end

--大于
function Vec2.__gt(lhs, rhs)
    return lhs.x > rhs.x and lhs.y > rhs.y
end

--大于等于
function Vec2.__ge(lhs, rhs)
    return lhs.x >= rhs.x and lhs.y >= rhs.y
end

--转换为字符串
function Vec2:__tostring()
    return string.format("(%f, %f)", self.x, self.y)
end

---------------------------------方法-----------------------------------

--计算长度
function Vec2:Length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

--取最小值
function Vec2:Min(rhs)
    local x = math.min(self.x, rhs.x)
    local y = math.min(self.y, rhs.y)
    return Vec2.new(x, y)
end

--取最大值
function Vec2:Max(rhs)
    local x = math.max(self.x, rhs.x)
    local y = math.max(self.y, rhs.y)
    return Vec2.new(x, y)
end

--转换Vec3
function Vec2:ToVec3()
    local Vec3 = GFModuleScript("CommonModule.Math.Vec3")
    return Vec3.new(self.x, 0, self.y)
end

--插值
function Vec2:Lerp(rhs, t)
    return Vec2.new(self.x + (rhs.x - self.x) * t, self.y + (rhs.y - self.y) * t)
end

--归一化
function Vec2:Normalize()
    local len = self:Length()
    if len > 0 then
        self.x = self.x / len
        self.y = self.y / len
    end
end

function Vec2:Normalized()
    local len = self:Length()
    if len > 0 then
        return Vec2.new(self.x / len, self.y / len)
    end
    return Vec2.new(0, 0)
end

--点乘
function Vec2:Dot(v2)
    return self.x * v2.x + self.y * v2.y
end

--叉乘
function Vec2:Cross(v2)
    return self.x * v2.y - self.y * v2.x
end

--距离
function Vec2:Distance(v2)
    return (self - v2):Length()
end

--角度
function Vec2:Angle(v2)
    local dot = self:Dot(v2)
    local len1 = self:Length()
    local len2 = v2:Length()
    local cos = dot / (len1 * len2)
    return math.acos(cos)
end

--旋转
function Vec2:Rotate(v, angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return Vec2.new(v.x * cos - v.y * sin, v.x * sin + v.y * cos)
end

--获取反向向量
function Vec2:Inversed()
    return Vec2.new(-self.x, -self.y)
end

--获取垂直向量
function Vec2:Perpendicular()
    return Vec2.new(-self.y, self.x)
end

--获取反射向量
function Vec2:Reflect(normal)
    return self - 2 * self:Dot(normal) * normal
end


--拷贝
function Vec2:Clone()
    return Vec2.new(self.x, self.y)
end

return Vec2