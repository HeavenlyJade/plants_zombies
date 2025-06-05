local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList

local ClientEventManager= require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager
local Item = require(MainStorage.code.server.bag.Item) ---@type Item
local gg = require(MainStorage.code.common.MGlobal)   ---@type gg


local uiConfig = {
    uiName = "UIBag",
    layer = 1,
    hideOnInit = true,
}

---@class UiBag:ViewBase
local UiBag = ClassMgr.Class("UiBag", ViewBase)

---@override
function UiBag:OnInit(node, config)
    ViewBase.OnInit(self, node, config)
    
    self.items = {} ---@type table<number, table<number, Item>>
    
    ClientEventManager.Subscribe("SyncInventoryItems", function(evt)
        local evt = evt ---@type SyncInventoryItems
        for slot, itemData in pairs(evt.items) do
            if not self.items[slot.c] then
                self.items[slot.c] = {}
            end
            local item = Item.New()
            item:Load(itemData)
            self.items[slot.c][slot.s] = item
        end
    end)
end

---@param slot Slot
---@return Item
function UiBag:GetItem(slot)
    return self.items[slot.c][slot.s]
end

return UiBag.New(script.Parent, uiConfig)