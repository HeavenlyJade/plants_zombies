local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClientEventManager= require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager


---@class AfkHud:ViewBase
local AfkHud = ClassMgr.Class("AfkHud", ViewBase)

local uiConfig = {
    uiName = "AfkHud",
    layer = 0,
    hideOnInit = true,
}

function AfkHud:OnInit(node, config)
    self.gainSpeed = self:Get("挂机底图/获取速度") ---@type ViewComponent
    
    -- 用于跟踪阳光变化
    self.lastSunlight = 0
    self.lastUpdateTime = 0
    self.sunlightPerSecond = 0

    -- 监听挂机点进入事件
    ClientEventManager.Subscribe("AfkSpotUpdate", function(data)
        if data.enter then
            self.lastUpdateTime = 0
            self.gainSpeed.node.Title = "挂机中..."
            self:Open()
        else
            self:Close()
        end
    end)

    -- 监听阳光变化事件
    ClientEventManager.Subscribe("SyncInventoryItems", function(evt)
        if not evt.moneys or not self.displaying then return end
        
        -- 找到阳光货币（第二个货币）
        local sunlight = 0
        for _, money in ipairs(evt.moneys) do
            if money.it == "阳光" then
                sunlight = money.a
                break
            end
        end
        
        local currentTime = os.time()
        
        -- 计算每秒增速
        if self.lastUpdateTime > 0 then
            local timeDiff = currentTime - self.lastUpdateTime
            if timeDiff > 0 then
                local sunlightDiff = sunlight - self.lastSunlight
                self.sunlightPerSecond = sunlightDiff / timeDiff
                -- 更新显示
                self.gainSpeed.node.Title = string.format("+%.1f/秒", self.sunlightPerSecond)
            end
        end
        
        -- 更新上次的值
        self.lastSunlight = sunlight
        self.lastUpdateTime = currentTime
    end)
end

function AfkHud:Open()
    ViewBase.Open(self)
    ViewBase.GetUI("HudInteract"):Close()
end


function AfkHud:Close()
    ViewBase.Close(self)
    ViewBase.GetUI("HudInteract"):Open()
    -- 重置数据
    self.lastSunlight = 0
    self.lastUpdateTime = 0
    self.sunlightPerSecond = 0
end


return AfkHud.New(script.Parent, uiConfig)