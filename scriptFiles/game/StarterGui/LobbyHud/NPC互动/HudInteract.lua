local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager

---@class HudInteract:ViewBase
local HudInteract = ClassMgr.Class("HudInteract", ViewBase)

local uiConfig = {
    uiName = "HudInteract",
    layer = 0,
    hideOnInit = false, -- 初始隐藏，当玩家靠近NPC时显示
}

---@param viewButton ViewButton
local function OnInteractClick(ui, viewButton)
    local button = viewButton ---@cast button ViewButton
    local option = ui.currentOptions[button.index]
    if option then
        -- 发送交互请求到服务器
        gg.network_channel:FireServer({
            cmd = "InteractWithNpc",
            npcId = option.npcId
        })
    end
end

function HudInteract:OnInit(node, config)
    self.currentOptions = {} -- 存储当前可交互的NPC选项

    -- 添加日志以确认节点状态
    gg.log("HudInteract初始化 - 节点:", node, "交互列表:", node:FindFirstChild("交互列表"))

    -- 初始化交互列表
    self.interactList = self:Get("交互列表", ViewList, function(n)
        local button = ViewButton.New(n, self)
        button.clickCb = OnInteractClick
        return button
    end)

    -- 检查交互列表是否成功初始化
    if not self.interactList then
        gg.log("错误: 交互列表初始化失败!")
        return
    end

    -- 先隐藏交互界面
    self:HideInteract()

    -- 确保UI完全初始化后再订阅事件（可以使用延迟）
    wait(0.1) -- 延迟一小段时间确保UI组件已完全准备好

    -- 监听NPC交互更新事件
    ClientEventManager.Subscribe("NPCInteractionUpdate", function(evt)
        local evt = evt ---@type NPCInteractionUpdate
        if evt and evt.interactOptions and #evt.interactOptions > 0 then
            self:ShowInteract(evt.interactOptions)
        else
            self:HideInteract()
        end
    end)
end

---显示交互界面
---@param interactOptions NPCInteractionOption[] 交互选项列表
function HudInteract:ShowInteract(interactOptions)
    -- 保存当前选项
    gg.log("显示交互界面", interactOptions)
    self.currentOptions = interactOptions
    -- 设置交互选项数量
    self.interactList:SetElementSize(#interactOptions)
    gg.log("设置交互选项数量", #interactOptions)
    -- 更新交互选项
    for i, option in ipairs(interactOptions) do
        local button = self.interactList:GetChild(i) ---@cast button ViewButton
        gg.log("更新交互选项", i, option,button)
        button:Get("Text").node.Title = option.npcName
        if option.icon then
            button:Get("图标").node.Icon = option.icon 
        end
        button.index = i
    end
end

---隐藏交互界面
function HudInteract:HideInteract()
    self.currentOptions = {} -- 清空当前选项
    self.interactList:SetElementSize(0)
end

return HudInteract.New(script.Parent, uiConfig)
