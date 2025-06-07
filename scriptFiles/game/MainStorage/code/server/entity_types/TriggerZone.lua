--- nnpc

local setmetatable = setmetatable
local SandboxNode  = SandboxNode
local Vector3      = Vector3
local ColorQuad    = ColorQuad
local game         = game


local MainStorage        = game:GetService("MainStorage")
local gg                 = require(MainStorage.code.common.MGlobal) ---@type gg
local common_config      = require(MainStorage.code.common.MConfig) ---@type common_config
local common_const       = require(MainStorage.code.common.MConst) ---@type common_const
local ClassMgr           = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Modifiers          = require(MainStorage.code.common.config_type.modifier.Modifiers) ---@type Modifiers
local Entity             = require(MainStorage.code.server.entity_types.Entity) ---@type Entity
local ServerEventManager = require(MainStorage.code.server.event.ServerEventManager) ---@type ServerEventManager
local ServerScheduler    = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler

---@class TriggerZone:Entity    --NPC类 (单个Npc) (管理NPC状态)
---@field New fun(TriggerZone: TriggerZone, actor: SandboxNode):TriggerZone
---@field npc_config any
local _M = ClassMgr.Class('TriggerZone', Entity) --父类Entity


---@param TriggerZone TriggerZone
---@param actor Actor
function _M:OnInit(TriggerZone, actor)
    self.spawnPos          = actor.LocalPosition
    self.actor             = actor ---@type TriggerBox
    local trigger = actor
    self.name              = TriggerZone["名字"]
    self.interactCondition = Modifiers.New(TriggerZone["触发条件"])
    self.pendingLeavePlayers = {} -- 存储待移除的玩家
    
    -- 处理指令字符串，将单引号替换为双引号
    local function processCommands(commands)
        if not commands then return nil end
        local processed = {}
        for i, cmd in ipairs(commands) do
            if type(cmd) == "string" then
                processed[i] = cmd:gsub("'", '"')
            else
                processed[i] = cmd
            end
        end
        return processed
    end
    
    self.enterCommands     = processCommands(TriggerZone["进入指令"])
    self.leaveCommands     = processCommands(TriggerZone["离开指令"])
    self.periodicCommands  = processCommands(TriggerZone["定时指令"])
    self.periodicInterval  = TriggerZone["定时间隔"] or 1  -- 默认1秒
    self.periodicTimer     = 0
    self.target            = nil
    self.playersInZone     = {}  -- 记录在区域内的玩家

    -- 监听触发器被触碰
    trigger.Touched:Connect(function(node)
        if node and node.UserId then
            local player = gg.getPlayerByUin(node.UserId)
            if player then
                -- 如果玩家在待移除列表中，不做任何事
                if self.pendingLeavePlayers[player.uuid] then
                    self.pendingLeavePlayers[player.uuid] = nil
                    return
                end
                -- 只有当玩家不在区域内时才执行进入逻辑
                if not self.playersInZone[player.uuid] then
                    -- 执行进入指令
                    if self.enterCommands then
                        player:ExecuteCommands(self.enterCommands)
                    end
                    -- 记录玩家进入
                    self.playersInZone[player.uuid] = player
                end
            end
        end
    end)

    -- 监听触发器触碰结束
    trigger.TouchEnded:Connect(function(node)
        if node and node.UserId then
            local player = gg.getPlayerByUin(node.UserId)
            if player then
                -- 将玩家加入待移除列表
                self.pendingLeavePlayers[player.uuid] = player
                -- 使用ServerScheduler延迟0.1秒后检查并移除玩家
                local taskKey = "trigger_zone_leave_" .. player.uuid
                ServerScheduler.add(function()
                    -- 如果玩家仍在待移除列表中（说明期间没有重新触发Touched）
                    if self.pendingLeavePlayers[player.uuid] then
                        -- 执行离开指令
                        if self.leaveCommands then
                            player:ExecuteCommands(self.leaveCommands)
                        end
                        -- 移除玩家记录
                        self.playersInZone[player.uuid] = nil
                        self.pendingLeavePlayers[player.uuid] = nil
                    end
                end, 0.1, 0, taskKey)
            end
        end
    end)
    self:createTitle()
end

_M.GenerateUUID = function(self)
    print("GenerateUUID NPC")
    self.uuid = gg.create_uuid('u_Zone')
end

---更新NPC状态
function _M:update_npc()
    -- 处理定时指令
    if self.periodicCommands and next(self.playersInZone) then
        self.periodicTimer = self.periodicTimer + 1
        if self.periodicTimer >= self.periodicInterval * 10 then  -- 假设update是每0.1秒调用一次
            self.periodicTimer = 0
            -- 对区域内的所有玩家执行定时指令
            for _, player in pairs(self.playersInZone) do
                player:ExecuteCommands(self.periodicCommands)
            end
        end
    end
end

---@protected
function _M:DestroyObject()
end

return _M;
