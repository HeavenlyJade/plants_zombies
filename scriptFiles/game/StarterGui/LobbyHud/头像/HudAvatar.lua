local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local Players = game:GetService('Players')
local ClientEventManager= require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager
local ClientScheduler = require(MainStorage.code.client.ClientScheduler)

---@class HudAvatar:ViewBase
local HudAvatar = ClassMgr.Class("HudAvatar", ViewBase)

local uiConfig = {
    uiName = "HudAvatar",
    layer = 0,
    hideOnInit = false,
}

function HudAvatar:OnInit(node, config)
    self.selectingCard = 0
    local localPlayer = game:GetService("Players").LocalPlayer
    self:Get("名字背景/玩家名").node.Title = localPlayer.Nickname
    self:Get("名字背景/UID").node.Title = tostring(localPlayer.UserId)
    self.questList = self:Get("头像背景/任务列表", ViewList, function (node)
        local button = ViewButton.New(node, self)
        button.clickCb = function (ui, button)
            gg.network_channel:FireServer({
                cmd = "ClickQuest",
                name = button.extraParams.questId,
            })
        end
        return button
    end)
    self:Get("头像背景/任务按钮", ViewButton).clickCb = function (ui, viewButton)
        self.questList:SetVisible(not self.questList.node.Enabled)
    end
    
    ClientEventManager.Subscribe("UpdateQuestsData", function(evt)
        local evt = evt ---@type QuestsUpdate
        self.questList:SetElementSize(#evt.quests)
        for i, child in ipairs(evt.quests) do
            local ele = self.questList:GetChild(i) ---@cast ele ViewButton
            ele.extraParams = {
                questId = child.name
            }
            ele:Get("任务标题").node.Title = child.description
            ele:Get("任务数量").node.Title = string.format("%d/%d", child.count, child.countMax)
        end
    end)
    
    ClientEventManager.Subscribe("NavigateTo", function(data)
        local stopRange = data.range ^ 2
        local vec = Vector3.New(data.pos[1], data.pos[2], data.pos[3])
        self.targetPos = vec
        Players.LocalPlayer.Character:NavigateTo(vec)
        
        -- 取消之前的检查任务（如果存在）
        if self.navigationCheckTaskId then
            ClientScheduler.cancel(self.navigationCheckTaskId)
        end
        
        -- 创建新的检查任务
        self.navigationCheckTaskId = ClientScheduler.add(function()
            local character = Players.LocalPlayer.Character ---@type MiniPlayer
            if not character then return end
            
            local currentPos = character.Position
            local distance = gg.vec.DistanceSq3(currentPos, self.targetPos)
            
            if distance <= stopRange then
                character:StopNavigate()
                gg.network_channel:FireServer({
                    cmd = "NavigateReached"
                })
                -- 取消检查任务
                ClientScheduler.cancel(self.navigationCheckTaskId)
                self.navigationCheckTaskId = nil
                self.targetPos = nil
            end
        end, 0, 1) -- 每秒检查一次
    end)
end

return HudAvatar.New(script.Parent, uiConfig)
