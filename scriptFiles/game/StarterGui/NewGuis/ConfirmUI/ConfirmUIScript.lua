local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList

local ClientEventManager= require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager
local gg = require(MainStorage.code.common.MGlobal)   ---@type gg


local uiConfig = {
    uiName = "UIConfirm",
    layer = 3,
    hideOnInit = false,
}

---@class UIConfirm:ViewBase
local UIConfirm = ClassMgr.Class("UIConfirm", ViewBase)

---@override
function UIConfirm:OnInit(node, config)
    self.title = self:Get("ui/title/title_text") ---@type UITextLabel
    self.content = self:Get("ui/content") ---@type UITextLabel
    self.confirmBtn = self:Get("ui/b_confirm") ---@type ViewButton
    self.confirmBtn.Click:Connect(function(node, isClick, vector2)
        print("confirmBtn", isClick)
        if self.confirmCallback then
            self.confirmCallback()
        end
        self:Close()
    end)
    self.cancelBtn = self:Get("ui/b_cancel") ---@type ViewButton
    self.cancelBtn.Click:Connect(function(node, isClick, vector2)
        print("cancelBtn", isClick)
        if self.cancelCallback then
            self.cancelCallback()
        end
        self:Close()
    end)
    self.confirmCallback = nil ---@type function
    self.cancelCallback = nil ---@type function
end

function UIConfirm:Display(title, content, confirmCallback, cancelCallback)
    self.title.Title = title
    self.content.Title = content
    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
end

return UIConfirm.New(script.Parent, uiConfig)