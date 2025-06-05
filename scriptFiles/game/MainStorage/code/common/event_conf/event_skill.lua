--- 技能事件配置文件
--- 包含所有技能系统相关的事件名称、错误码和错误消息定义
--- V109 miniw-haima

---@class SkillEventConfig
local SkillEventConfig = {}

--[[
===================================
事件定义部分
===================================
]]

-- 客户端请求事件
SkillEventConfig.REQUEST = {
    GET_LIST = "SkillRequest_GetList",
    LEARN = "SkillRequest_Learn",
    UPGRADE = "SkillRequest_Upgrade",
    EQUIP = "SkillRequest_Equip",
    UNEQUIP = "SkillRequest_Unequip",
    GET_DETAIL = "SkillRequest_GetDetail",
    GET_AVAILABLE = "SkillRequest_GetAvailable"
}

-- 服务器响应事件
SkillEventConfig.RESPONSE = {
    LIST = "SkillResponse_List",
    LEARN = "SkillResponse_LearnUpgrade",
    EQUIP = "SkillResponse_Equip",
    UNEQUIP = "SkillResponse_Unequip",
    DETAIL = "SkillResponse_Detail",
    AVAILABLE = "SkillResponse_Available",
    ERROR = "SkillResponse_Error",
    UPGRADE = "SkillResponse_Upgrade",
    SYNC_SKILLS = "SyncPlayerSkills"

}

-- 服务器通知事件
SkillEventConfig.NOTIFY = {
    SKILL_UNLOCKED = "SkillNotify_Unlocked"
}


--[[
===================================
错误码和错误消息定义
===================================
]]

-- 错误码定义
SkillEventConfig.ERROR_CODES = {
    SUCCESS = 0,
    PLAYER_NOT_FOUND = 1,
    SKILL_NOT_FOUND = 2,
    SKILL_ALREADY_LEARNED = 3,
    SKILL_NOT_LEARNED = 4,
    MAX_LEVEL_REACHED = 5,
    INSUFFICIENT_RESOURCES = 6,
    INVALID_SLOT = 7,
    SLOT_OCCUPIED = 8,
    SKILL_NOT_AVAILABLE = 9,
    PERMISSION_DENIED = 10,
    INVALID_PARAMETERS = 11,
    SKILL_NOT_OWNED = 12,
    UPGRADE_FAILED = 13
}

-- 错误消息映射
SkillEventConfig.ERROR_MESSAGES = {
    [SkillEventConfig.ERROR_CODES.SUCCESS] = "操作成功",
    [SkillEventConfig.ERROR_CODES.PLAYER_NOT_FOUND] = "玩家不存在",
    [SkillEventConfig.ERROR_CODES.SKILL_NOT_FOUND] = "技能不存在",
    [SkillEventConfig.ERROR_CODES.SKILL_ALREADY_LEARNED] = "技能已学会",
    [SkillEventConfig.ERROR_CODES.SKILL_NOT_LEARNED] = "尚未学会该技能",
    [SkillEventConfig.ERROR_CODES.MAX_LEVEL_REACHED] = "技能已达最大等级",
    [SkillEventConfig.ERROR_CODES.INSUFFICIENT_RESOURCES] = "资源不足",
    [SkillEventConfig.ERROR_CODES.INVALID_SLOT] = "无效的装备槽位",
    [SkillEventConfig.ERROR_CODES.SLOT_OCCUPIED] = "装备槽位已被占用",
    [SkillEventConfig.ERROR_CODES.SKILL_NOT_AVAILABLE] = "技能不可学习",
    [SkillEventConfig.ERROR_CODES.PERMISSION_DENIED] = "权限不足",
    [SkillEventConfig.ERROR_CODES.INVALID_PARAMETERS] = "参数无效",
    [SkillEventConfig.ERROR_CODES.SKILL_NOT_OWNED] = "技能不属于玩家",
    [SkillEventConfig.ERROR_CODES.UPGRADE_FAILED] = "升级失败"
}

--[[
===================================
配置辅助函数
===================================
]]

--- 获取错误消息
---@param errorCode number 错误码
---@return string 错误消息
function SkillEventConfig.GetErrorMessage(errorCode)
    return SkillEventConfig.ERROR_MESSAGES[errorCode] or "未知错误"
end

--- 检查事件名称是否有效
---@param eventName string 事件名称
---@return boolean 是否有效
function SkillEventConfig.IsValidRequestEvent(eventName)
    for _, event in pairs(SkillEventConfig.REQUEST) do
        if event == eventName then
            return true
        end
    end
    return false
end

--- 检查响应事件名称是否有效
---@param eventName string 事件名称
---@return boolean 是否有效
function SkillEventConfig.IsValidResponseEvent(eventName)
    for _, event in pairs(SkillEventConfig.RESPONSE) do
        if event == eventName then
            return true
        end
    end
    return false
end

--- 获取所有请求事件列表
---@return table 请求事件列表
function SkillEventConfig.GetAllRequestEvents()
    local events = {}
    for _, event in pairs(SkillEventConfig.REQUEST) do
        table.insert(events, event)
    end
    return events
end

--- 获取所有响应事件列表
---@return table 响应事件列表
function SkillEventConfig.GetAllResponseEvents()
    local events = {}
    for _, event in pairs(SkillEventConfig.RESPONSE) do
        table.insert(events, event)
    end
    return events
end

return SkillEventConfig
