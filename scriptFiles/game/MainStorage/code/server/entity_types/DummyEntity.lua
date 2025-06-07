local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Entity = require(MainStorage.code.server.entity_types.Entity) ---@type Entity

---@class DummyEntity:Entity
local DummyEntity = ClassMgr.Class("DummyEntity", Entity)

---@param actor Actor
function DummyEntity:OnInit(actor)
    self:setGameActor(actor)
end

return DummyEntity
