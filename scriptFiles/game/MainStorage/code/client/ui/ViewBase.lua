local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ClientScheduler = require(MainStorage.code.client.ClientScheduler) ---@type ClientScheduler
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager

local displayingUI = {}
local allUI = {}

---@class ViewConfig
---@field uiName string 界面名称
---@field hideOnInit boolean 是否在初始化时隐藏
---@field layer number 0=主界面Hud， >1=GUI界面。 GUI在打开时关闭其他同layer的GUI

---@class ViewBase:Class
---@field New fun(node: SandboxNode, config: ViewConfig): ViewBase
---@field GetUI fun(name: string): ViewBase
local ViewBase = ClassMgr.Class("ViewBase")

ViewBase.UiBag = nil ---@type UiBag
ViewBase.UIConfirm = nil ---@type UIConfirm

---@generic T : ViewBase
---@param name string
---@return T
function ViewBase.GetUI(name)
    return allUI[name]
end

---@generic T : ViewComponent
---@param path string 组件路径
---@param type? T 组件类型
---@param ... any 额外参数
---@return T
function ViewBase:Get(path, type, ...)
    local cacheKey = path
    if self.componentCache[cacheKey] then
        return self.componentCache[cacheKey]
    end

    local node = self.node
    local fullPath = ""
    local lastPart = ""
    for part in path:gmatch("[^/]+") do -- 用/分割字符串
        if part ~= "" then
            lastPart = part
            if not node then
                gg.log(string.format("UI[%s]获取路径[%s]失败: 在[%s]处节点不存在", self.className, path,
                    fullPath))
                return nil
            end
            node = node[part]
            if fullPath == "" then
                fullPath = part
            else
                fullPath = fullPath .. "/" .. part
            end
        end
    end

    if not node then
        gg.log(string.format("UI[%s]获取路径[%s]失败: 最终节点[%s]不存在", self.className, path, lastPart))
        return nil
    end

    if not type then
        local ViewComponent = require(MainStorage.code.client.ui.ViewComponent) ---@type ViewComponent
        type = ViewComponent
    end
    ---@cast type ViewComponent
    local component = type.New(node, self, fullPath, ...)

    -- Cache the component
    self.componentCache[cacheKey] = component
    return component
end

---@param node SandboxNode
---@param config ViewConfig
function ViewBase:OnInit(node, config)
    self.componentCache = {}
    self.node = node ---@type SandboxNode
    self.hideOnInit = config.hideOnInit == nil and true or config.hideOnInit
    self.layer = config.layer == nil and 1 or config.layer
    self.displaying = false
    self.isOnTop = false
    allUI[self.className] = self
    ViewBase[self.className] = self

    if self.hideOnInit then
        self:Close()
    else
        self:Open()
    end
end

function ViewBase:GetScreenSize()
    local evt = {}
    ClientEventManager.Publish("GetScreenSize", evt)
    return evt.size
end

function ViewBase:SetVisible(visible)
    self.node.Enabled = visible
    self.node.Visible = visible
end

function ViewBase:Close()
    self:SetVisible(false)
    if displayingUI[self.layer] == self then
        displayingUI[self.layer] = nil
    end
    if self.isOnTop then
        local maxLayer = 1
        for layer, _ in pairs(displayingUI) do
            if layer > maxLayer then
                maxLayer = layer
            end
        end
        if displayingUI[maxLayer] then
            local topUI = displayingUI[maxLayer]
            topUI:SetVisible(true)
            topUI.isOnTop = true
        end
    end
    self.displaying = false
end

function ViewBase:Open()
    self.displaying = true
    self:SetVisible(true)
    if self.layer > 0 then
        if displayingUI[self.layer] then
            local oldUI = displayingUI[self.layer]
            if oldUI ~= self then
                oldUI.isOnTop = false
                oldUI:Close()
            end
        end
        self.isOnTop = true
        for i = 1, self.layer do
            if displayingUI[i] then
                displayingUI[i].isOnTop = false
                displayingUI[i].node.Enabled = false
            end
        end
        displayingUI[self.layer] = self
    end
end

function ViewBase:OnHide()

end

return ViewBase
