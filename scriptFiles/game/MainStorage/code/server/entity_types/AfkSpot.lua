local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Npc = require(MainStorage.code.server.entity_types.Npc) ---@type Npc
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell
local gg = require(MainStorage.code.common.MGlobal) ---@type gg

---@class AfkSpot:Npc
---@field interval number 间隔时间
---@field spells table 定时释放魔法列表
---@field lastCastTime number 上次释放时间
---@field activePlayers table<Player, number> 当前激活的玩家及其定时器ID
---@field isOccupied boolean 是否已被占用
local AfkSpot = ClassMgr.Class("AfkSpot", Npc)

---处理玩家进入触发器
---@param player Player 玩家
function AfkSpot:OnPlayerTouched(player)
    if self.isOccupied then
        return
    end
    Npc.OnPlayerTouched(self, player)
end

function AfkSpot:OnInit(data, actor)
    self.autoInteract = data["自动互动"] or false
    self.interval = data["间隔时间"] or 10
    self.subSpells = {}
    if data["定时释放魔法"] then
        for _, subSpellData in ipairs(data["定时释放魔法"]) do
            local subSpell = SubSpell.New(subSpellData)
            table.insert(self.subSpells, subSpell)
        end
    end
    self.lastCastTime = 0
    self.activePlayers = {}
    self.isOccupied = false
    
    self:SubscribeEvent("ExitAfkSpot", function (evt)
        if evt.player then
            self:OnPlayerExit(evt.player)
        end
    end)
end

--- 检查是否可以进入挂机点
---@param player Player 玩家
---@return boolean 是否可以进入
function AfkSpot:CanEnter(player)
    if self.isOccupied then
        return false
    end
    if not self.interactCondition then return true end
    local param = self.interactCondition:Check(player, self)
    return not param.cancelled
end

--- 玩家进入挂机点
---@param player Player 玩家
function AfkSpot:OnPlayerEnter(player)
    self.isOccupied = true
    player:SetMoveable(false)
    -- 发送挂机收益事件给客户端
    player:SendEvent("AfkSpotEntered", {
        rewardsPerSecond = player:GetVariable("每秒收益_"..self.name),
        interval = self.interval
    })
    
    -- 开始定时释放魔法
    self:StartSpellTimer(player)
end

--- 玩家退出挂机点
---@param player Player 玩家
function AfkSpot:OnPlayerExit(player)
    -- 停止该玩家的定时器
    local timerId = self.activePlayers[player]
    if timerId then
        ServerScheduler.cancel(timerId)
        self.activePlayers[player] = nil
        player:SetMoveable(true)
        self.isOccupied = false
    end
end

--- 开始定时释放魔法
---@param player Player 玩家
function AfkSpot:StartSpellTimer(player)
    -- 停止之前的定时器
    local oldTimerId = self.activePlayers[player]
    if oldTimerId then
        ServerScheduler.cancel(oldTimerId)
    end
    
    -- 创建新的定时器
    local timerId = ServerScheduler.add(function()
        self:CastSpells(player)
    end, 0, self.interval) -- 立即开始，每隔interval秒执行一次
    
    -- 保存定时器ID
    self.activePlayers[player] = timerId
end

--- 释放魔法
---@param player Player 玩家
function AfkSpot:CastSpells(player)
    for _, subSpell in ipairs(self.subSpells) do
        subSpell:Cast(player, player)
    end
end

--- 处理NPC交互
---@param player Player 玩家
function AfkSpot:HandleInteraction(player)
    -- 先调用父类的交互处理
    Npc.HandleInteraction(self, player)
    
    -- 检查是否可以进入挂机点
    if self:CanEnter(player) then
        self:OnPlayerEnter(player)
    end
end

--- 更新NPC状态
function AfkSpot:update_npc()
    -- 检查所有激活的玩家是否离开范围
    local pos = self.actor.Position
    for player, _ in pairs(self.activePlayers) do
        local playerPos = player:GetPosition()
        if gg.fast_out_distance(pos, playerPos, 200) then
            self:OnPlayerExit(player)
        end
    end
    -- Npc.update_npc(self)
end

return AfkSpot 