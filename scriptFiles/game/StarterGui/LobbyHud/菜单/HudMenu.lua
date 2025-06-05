local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local ClientScheduler = require(MainStorage.code.client.ClientScheduler) ---@type ClientScheduler
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig
local TweenService = game:GetService("TweenService")

local ClientEventManager= require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager

---@class HudMenu:ViewBase
local HudMenu = ClassMgr.Class("HudMenu", ViewBase)

local uiConfig = {
    uiName = "HudMenu",
    layer = 0,
    hideOnInit = false,
}

---@class MoneyAddPool
---@field pool UITextLabel[] 对象池
---@field template UITextLabel 模板对象
local MoneyAddPool = {
    pool = {},
    template = nil
}

--- 从对象池获取一个文本标签
---@return UITextLabel
function MoneyAddPool:Get()
    local label = table.remove(self.pool)
    if not label then
        -- 如果对象池为空，创建新对象
        label = self.template:Clone()
        label.Parent = self.template.Parent
    end
    return label
end

--- 将文本标签放回对象池
---@param label UITextLabel
function MoneyAddPool:Return(label)
    label.Visible = false
    label.Scale = Vector2.New(1, 1)
    table.insert(self.pool, label)
end

function OnMoneyClick(ui, viewButton)
end

---@param viewButton ViewButton
function HudMenu:RegisterMenuButton(viewButton)
    if not viewButton then return end
    gg.log("菜单按钮初始化", viewButton.node.Name)
    viewButton:SetTouchEnable(true)
    -- 设置新的点击回调
    viewButton.clickCb = function(ui, button)
        gg.log("菜单按钮点击", button.node.Name)
        if button.node.Name == "活动" then
            gg.log("活动按钮点击")
        elseif button.node.Name == "卡包" then
            gg.log("卡包按钮点击")
            ViewBase["CardsGui"]:Open()
        end
        -- 发送菜单点击事件到服务器
        gg.network_channel:FireServer({
            cmd = "MenuClicked",
            buttonName = button.node.Name
        })
    end
end

function HudMenu:OnInit(node, config)
    gg.log("菜单按钮HudMenu初始化")
    ViewBase.OnInit(self, node, config)
    self.selectingCard = 0
    -- 初始化对象池
    MoneyAddPool.template = self:Get("货币增加").node ---@type UITextLabel
    MoneyAddPool.template.Visible = false
    
    self:RegisterMenuButton(self:Get("活动", ViewButton))
    self:RegisterMenuButton(self:Get("图鉴", ViewButton))
    self:RegisterMenuButton(self:Get("卡包", ViewButton))
    self:Get("菜单/菜单按钮", ViewList, function(n)
        local button = ViewButton.New(n, self)
        self:RegisterMenuButton(button)
        return button
    end) ---@type ViewList<ViewButton>

    self.moneyButtonList = self:Get("货币/货币", ViewList, function(n)
        local button = ViewButton.New(n, self)
        button.clickCb = OnMoneyClick
        return button
    end) ---@type ViewList<ViewButton>

    ClientEventManager.Subscribe("SyncInventoryItems", function(evt)
        local evt = evt ---@type SyncInventoryItems
        -- 更新货币显示
        if evt.moneys then
            for idx, money in ipairs(evt.moneys) do
                local button = self.moneyButtonList:GetChild(idx)
                if button then
                    local node = button:Get("Text").node ---@cast node UITextLabel
                    -- 检查是否有货币增加
                    if self.lastMoneyValues and self.lastMoneyValues[idx] and money.a > self.lastMoneyValues[idx] then
                        -- 从对象池获取文本标签
                        local moneyAdd = MoneyAddPool:Get()
                        -- 设置增加值的显示
                        moneyAdd.Title = "+" .. tostring(money.a - self.lastMoneyValues[idx])
                        -- 设置初始位置（屏幕中央）
                        moneyAdd.Scale = Vector2.New(2, 2)
                        local screenSize = self:GetScreenSize()
                        -- 添加±20%的随机浮动
                        local randomOffsetX = (math.random() * 0.4 - 0.2) * screenSize.x
                        local randomOffsetY = (math.random() * 0.4 - 0.2) * screenSize.y
                        moneyAdd.Position = Vector2.New(
                            screenSize.x/2 + randomOffsetX,
                            screenSize.y/2 + randomOffsetY
                        )
                        moneyAdd.Visible = true
                        -- 创建动画
                        local tweenInfo = TweenInfo.New(1, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                        local tween = TweenService:Create(moneyAdd, tweenInfo, {
                            Position = node:GetGlobalPos(),
                            Scale = Vector2.New(1, 1)
                        })
                        tween:Play()
                        tween.Completed:Connect(function()
                            -- 动画完成后将对象放回对象池
                            MoneyAddPool:Return(moneyAdd)
                        end)
                    end
                    node.Title = tostring(money.a)
                end
            end
            -- 保存当前货币值用于下次比较
            self.lastMoneyValues = {}
            for idx, money in ipairs(evt.moneys) do
                self.lastMoneyValues[idx] = money.a
            end
        end
    end)

end

return HudMenu.New(script.Parent, uiConfig)
