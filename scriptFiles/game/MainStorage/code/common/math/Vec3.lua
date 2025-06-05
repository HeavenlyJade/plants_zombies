local MainStorage = game:GetService("MainStorage")
local MathDefines = require(MainStorage.code.common.math.MathDefines)

---@class Vec3
local Vec3 = {}

--实例化
---@param x Vector3|Vec3|number[]|number
---@param y? number
---@param z? number
---@return Vec3
function Vec3.new(x, y, z)
    local obj = {}
    if not x then
        return nil
    end
    if type(x) == "table" then
        if x.x then
            obj.x = x.x
            obj.y = x.y
            obj.z = x.z
        else
            obj.x = x[1] or 0
            obj.y = x[2] or 0
            obj.z = x[3] or 0
        end
    elseif type(x) == "number" then
        obj.x = x or 0
        obj.y = y or 0
        obj.z = z or 0
    else
        obj.x = x.x
        obj.y = x.y
        obj.z = x.z
    end
    Vec3.__index = Vec3
    setmetatable(obj, Vec3)
    return obj
end

function Vec3.zero()
    return Vec3.new(0, 0, 0)
end

function Vec3.one()
    return Vec3.new(1, 1, 1)
end

function Vec3.up()
    return Vec3.new(0, 1, 0)
end

function Vec3.down()
    return Vec3.new(0, -1, 0)
end

function Vec3.forward()
    return Vec3.new(0, 0, 1)
end

function Vec3.back()
    return Vec3.new(0, 0, -1)
end

function Vec3.right()
    return Vec3.new(1, 0, 0)
end

function Vec3.left()
    return Vec3.new(-1, 0, 0)
end

--取最小值
function Vec3:Min(rhs)
    local x = math.min(self.x, rhs.x)
    local y = math.min(self.y, rhs.y)
    local z = math.min(self.z, rhs.z)
    return Vec3.new(x, y, z)
end

--取最大值
function Vec3:Max(rhs)
    local x = math.max(self.x, rhs.x)
    local y = math.max(self.y, rhs.y)
    local z = math.max(self.z, rhs.z)
    return Vec3.new(x, y, z)
end

---------------------------------运算符重载-------------------------------
--加
function Vec3.__add(lhs, rhs)
    return Vec3.new(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
end

--减
function Vec3.__sub(lhs, rhs)
    return Vec3.new(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
end

--乘
function Vec3.__mul(lhs, rhs)
    if rhs == nil then
        return Vec3.new(lhs.x, lhs.y, lhs.z)
    end
    if type(lhs) == "number" then
        return Vec3.new(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
    elseif type(rhs) == "number" then
        return Vec3.new(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    else
        return Vec3.new(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
    end
end

--除
function Vec3.__div(lhs, rhs)
    if type(rhs) == "number" then
        return Vec3.new(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    else
        return Vec3.new(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z)
    end
end

--负
function Vec3.__unm(v)
    return Vec3.new(-v.x, -v.y, -v.z)
end

--等于
function Vec3.__eq(lhs, rhs)
    return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z
end

--不等于
function Vec3.__ne(lhs, rhs)
    return lhs.x ~= rhs.x or lhs.y ~= rhs.y or lhs.z ~= rhs.z
end

--小于
function Vec3.__lt(lhs, rhs)
    return lhs.x < rhs.x and lhs.y < rhs.y and lhs.z < rhs.z
end

--小于等于
function Vec3.__le(lhs, rhs)
    return lhs.x <= rhs.x and lhs.y <= rhs.y and lhs.z <= rhs.z
end

--大于
function Vec3.__gt(lhs, rhs)
    return lhs.x > rhs.x and lhs.y > rhs.y and lhs.z > rhs.z
end

--大于等于
function Vec3.__ge(lhs, rhs)
    return lhs.x >= rhs.x and lhs.y >= rhs.y and lhs.z >= rhs.z
end

--字符串
function Vec3.__tostring(v)
    return string.format("(%f, %f, %f)", v.x, v.y, v.z)
end

--取元素
function Vec3.__index(t, k)
    if k == 1 then
        return t.x
    elseif k == 2 then
        return t.y
    elseif k == 3 then
        return t.z
    end
end

--设置元素
function Vec3.__newindex(t, k, v)
    if k == 1 then
        t.x = v
    elseif k == 2 then
        t.y = v
    elseif k == 3 then
        t.z = v
    end
end

---------------------------------运算符重载-------------------------------

--获取长度
function Vec3:Length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vec3:LengthSq()
    return self.x * self.x + self.y * self.y + self.z * self.z
end
function Vec3:Magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vec3:SqrMagnitude()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

--点乘
function Vec3:Dot(rhs)
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
end

--叉乘
function Vec3:Cross(rhs)
    return Vec3.new(self.y * rhs.z - self.z * rhs.y, self.z * rhs.x - self.x * rhs.z, self.x * rhs.y - self.y * rhs.x)
end

--归一化
function Vec3:Normalize()
    local mag = self:Magnitude()
    if mag > 0 then
        self.x = self.x / mag
        self.y = self.y / mag
        self.z = self.z / mag
    end
    return self
end

function Vec3:GetPosition()
    return self
end

function Vec3:GetCenterPosition()
    return self
end

--获取归一化向量
function Vec3:Normalized()
    local mag = self:Magnitude()
    if mag > 0 then
        return Vec3.new(self.x / mag, self.y / mag, self.z / mag)
    end
    return Vec3.new(0, 0, 0)
end

--获取反向向量
function Vec3:Inversed()
    return Vec3.new(-self.x, -self.y, -self.z)
end

--获取垂直向量
function Vec3:Perpendicular()
    local x = self.x
    local y = self.y
    local z = self.z
    if math.abs(x) <= math.abs(y) and math.abs(x) <= math.abs(z) then
        return Vec3.new(0, -z, y)
    elseif math.abs(y) <= math.abs(x) and math.abs(y) <= math.abs(z) then
        return Vec3.new(-z, 0, x)
    else
        return Vec3.new(-y, x, 0)
    end
end

--获取反射向量
function Vec3:Reflect(normal)
    return self - 2 * self:Dot(normal) * normal
end

--获取插值向量
function Vec3:Lerp(to, t)
    return self + (to - self) * t
end

--获取球面插值向量
function Vec3:Slerp(to, t)
    local dot = self:Dot(to)
    dot = math.clamp(dot, -1, 1)
    local theta = math.acos(dot) * t
    local relative = (to - self * dot):Normalized()
    return self * math.cos(theta) + relative * math.sin(theta)
end

--获取切线插值向量
function Vec3:SlerpUnclamped(to, t)
    local dot = self:Dot(to)
    dot = math.clamp(dot, -1, 1)
    local theta = math.acos(dot) * t
    local relative = (to - self * dot):Normalized()
    return self * math.cos(theta) + relative * math.sin(theta)
end

--获取两个向量之间的角度
function Vec3:AngleBetween(to)
    local dot = self:Dot(to)
    return math.acos(dot / (self:Magnitude() * to:Magnitude())) * MathDefines.M_RADTODEG
end

--距离
function Vec3:Distance(to)
    return (self - to):Magnitude()
end

--取反
function Vec3:Negate()
    return Vec3.new(-self.x, -self.y, -self.z)
end

--移动向量
function Vec3:MoveTowards(target, maxDistanceDelta)
    local delta = target - self
    local sqrDelta = delta:SqrMagnitude()
    local sqrDistance = maxDistanceDelta * maxDistanceDelta
    if sqrDelta > sqrDistance then
        local magnitude = math.sqrt(sqrDelta)
        if magnitude > 0 then
            return self + delta / magnitude * maxDistanceDelta
        end
        return target
    end
    return target
end

--求点到线段上的距离
function Vec3:DistanceToLine(startPos, endPos)
    local line = endPos - startPos
    local pointToStart = self - startPos
    local projection = pointToStart:Dot(line) / line:SqrMagnitude()
    if projection < 0 then
        return pointToStart:Magnitude()
    end
    if projection > 1 then
        return (self - endPos):Magnitude()
    end
    local projectionOnLine = startPos + line * projection
    return (self - projectionOnLine):Magnitude()
end
--投影到平面
function Vec3:ProjectOnPlane(planeNormal)
    return self - (self:Dot(planeNormal) * planeNormal)
end

--长度是否为0
function Vec3:IsZero()
    --接近0即可
    local r = 0.01
    return math.abs(self.x) < r and math.abs(self.y) < r and math.abs(self.z) < r
end

--是否有无效值
function Vec3:IsNaN()
    return self.x ~= self.x or self.y ~= self.y or self.z ~= self.z
end

--判断是否相等,接近0即可
function Vec3:Equals(other)
    local r = 0.01
    return math.abs(self.x - other.x) < r and math.abs(self.y - other.y) < r and math.abs(self.z - other.z) < r
end

function Vec3:ToVector3()
    return Vector3.New(self.x, self.y, self.z)
end

--转换成表
function Vec3:ToTable()
    return {self.x, self.y, self.z}
end

--拷贝
function Vec3:Clone()
    return Vec3.new(self.x, self.y, self.z)
end

--围绕Y轴旋转
---@param degrees number 旋转角度
---@return Vec3 旋转后的新向量实例
function Vec3:rotateAroundY(degrees)
    -- 处理90度的倍数情况
    if degrees % 90 == 0 then
        local rotateCount = math.ceil((degrees / 90.0) % 4)
        if rotateCount == 3 then
            return Vec3.new(self.z, self.y, -self.x)
        elseif rotateCount == 2 then
            return Vec3.new(-self.x, self.y, -self.z)
        elseif rotateCount == 1 then
            return Vec3.new(-self.z, self.y, self.x)
        else
            return self:Clone()
        end
    end
    
    -- 处理0度情况
    if degrees == 0 then
        return self:Clone()
    end
    
    -- 处理其他角度
    local rad = math.rad(degrees)
    local cosine = math.cos(rad)
    local sine = math.sin(rad)
    return Vec3.new(
        cosine * self.x - sine * self.z,
        self.y,
        sine * self.x + cosine * self.z
    )
end

return Vec3
