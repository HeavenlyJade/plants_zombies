local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager

---@class ForceClickHud:ViewBase
local ForceClickHud = ClassMgr.Class("ForceClickHud", ViewBase)

local uiConfig = {
    uiName = "ForceClickHud",
    layer = 20,
    hideOnInit = true
}

function ForceClickHud:OnInit(node, config)
    ViewBase.OnInit(self, node, config)
    self.up = self:Get("上").node
    self.down = self:Get("下").node
    self.left = self:Get("左").node
    self.right = self:Get("右").node
end

---@param node UIComponent
function ForceClickHud:FocusOnNode(node)
    gg.log("FocusOnNode", node)
    local pos = node:GetGlobalPos()
    local size = node.Size

    self.up.Position = Vector2.New(pos.x - self.up.Size.x / 2, pos.y - self.up.Size.y)
    self.down.Position = Vector2.New(pos.x - self.down.Size.x / 2, pos.y + size.y)
    self.left.Position = Vector2.New(pos.x - self.down.Size.x, pos.y)
    self.right.Position = Vector2.New(pos.x + size.x, pos.y)
    self:Open()
end

return ForceClickHud.New(script.Parent, uiConfig)
