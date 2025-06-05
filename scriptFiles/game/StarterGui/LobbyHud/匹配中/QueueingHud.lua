local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClientEventManager= require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager


---@class QueueingHud:ViewBase
local QueueingHud = ClassMgr.Class("QueueingHud", ViewBase)

local uiConfig = {
    uiName = "QueueingHud",
    layer = 0,
    hideOnInit = true,
}

function QueueingHud:OnInit(node, config)
    ViewBase.OnInit(self, node, config)
    local exitButton = self:Get("匹配底图/退出按钮", ViewButton)
    self.matchProgress = self:Get("匹配底图/匹配进度") ---@type ViewComponent
    
    -- 监听匹配进度更新
    ClientEventManager.Subscribe("MatchProgressUpdate", function(data)
        if data.currentCount and data.totalCount then
            self.matchProgress.node.Title = string.format("匹配中: %d/%d", data.currentCount, data.totalCount)
            -- 当收到匹配进度更新时，确保UI是打开的
            self:Open()
        end
    end)

    -- 监听匹配开始事件
    ClientEventManager.Subscribe("MatchStart", function()
        -- 匹配开始时关闭UI
        self:Close()
    end)

    -- 监听匹配取消事件
    ClientEventManager.Subscribe("MatchCancel", function()
        -- 匹配取消时关闭UI
        self:Close()
    end)
    
    exitButton.clickCb = function (ui, button)
        -- 发送退出匹配请求到服务器
        gg.network_channel:FireServer({
            cmd = "LeaveQueue"
        })
        -- 关闭UI
        self:Close()
    end
end

return QueueingHud.New(script.Parent, uiConfig)