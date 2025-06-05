local MainStorage = game:GetService("MainStorage")

local gg = require(MainStorage.code.common.MGlobal) ---@type gg

---@class ClientEventManager
local ClientEventManager = {
    _eventDictionary = {} -- @type table<string, ClientEventListener[]>
}
---@class CEvent
---@field __class Class 事件类型

---@class S2CEvent : CEvent

---@class ClientEventListener
local ClientEventListener = {
    cb = nil,      -- @type fun(evt: table)
    priority = 10   -- @type integer
}

--- 订阅事件
---@param eventType string 事件类型
---@param listener fun(evt: table) 事件回调函数
---@param ... number 优先级，默认为10
function ClientEventManager.Subscribe(eventType, listener, ...)
    -- 参数验证
    if not eventType then
        gg.log("错误：eventType 不能为 nil",eventType,listener)
        return
    end

    if not listener then
        gg.log("错误：listener 不能为 nil")
        return
    end

    -- 确保 _eventDictionary 不为 nil
    if not ClientEventManager._eventDictionary then
        ClientEventManager._eventDictionary = {}
    end

    local priority = ... or 10
    local l = {
        cb = listener,
        priority = priority
    }

    if not ClientEventManager._eventDictionary[eventType] then
        ClientEventManager._eventDictionary[eventType] = {}
    end
    table.insert(ClientEventManager._eventDictionary[eventType], l)
    -- 按优先级排序
    table.sort(ClientEventManager._eventDictionary[eventType], function(a, b)
        return a.priority < b.priority
    end)
end

-- -- 监听怪物死亡事件
-- ClientEventManager.Subscribe("MobDeadEvent", function(evt)
--     ---@type MobDeadEvent
--     local mobDeadEvent = evt
--     mobDeadEvent.
--     print("怪物死亡:", mobDeadEvent.mob)
-- end)
-- -- 监听战斗前事件
-- ClientEventManager.Subscribe("PreBattleEvent", function(evt)
--     ---@type PreBattleEvent
--     local preBattleEvent = evt
--     print("战斗开始:", preBattleEvent.battle)
-- end)


--- 取消订阅事件
---@param eventType string 事件类型
---@param listener fun(evt: table) 要取消的事件回调函数
function ClientEventManager.Unsubscribe(eventType, listener)
    if ClientEventManager._eventDictionary[eventType] then
        local list = ClientEventManager._eventDictionary[eventType]
        for i = #list, 1, -1 do
            if list[i].cb == listener then
                table.remove(list, i)
            end
        end
    end
end

--- 发布事件
---@param eventType string 事件类型
---@param eventData table 事件数据
function ClientEventManager.Publish(eventType, eventData)
    eventData.__class = eventType

    if ClientEventManager._eventDictionary[eventType] then
        for _, item in ipairs(ClientEventManager._eventDictionary[eventType]) do
            local success, err = pcall(item.cb, eventData)
            if not success then
                gg.log(string.format("事件执行失败 %s\n%s", err, debug.traceback()))
            end
        end
    end
end

return ClientEventManager
