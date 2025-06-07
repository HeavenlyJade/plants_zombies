local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewComponent = require(MainStorage.code.client.ui.ViewComponent) ---@type ViewComponent
local gg = require(MainStorage.code.common.MGlobal) ---@type gg

---@class ViewList : ViewComponent
---@field node UIList
---@field childrens ViewComponent[] 子元素列表
---@field childNameTemplate string|nil 子元素名称模板
---@field onAddElementCb fun(child: SandboxNode): ViewComponent 添加元素时的回调函数
---@field New fun(node: UIComponent|ViewComponent, ui: ViewBase, path: string, onAddElementCb: fun(child: SandboxNode): ViewComponent): ViewList
local ViewList = ClassMgr.Class("ViewList", ViewComponent)


---@param node SandboxNode
---@param ui ViewBase
---@param onAddElementCb fun(child: SandboxNode): ViewComponent
function ViewList:OnInit(node, ui, path, onAddElementCb)
    self.childrens = {} ---@type ViewComponent[]
    self.childNameTemplate = nil
    self.onAddElementCb = onAddElementCb or function(child)
        return ViewComponent.New(child, ui)
    end
    for _, child in pairs(self.node.Children) do
        local childName = child.Name
        local num = childName:match("_([0-9]+)")
        -- print("Init ViewList", path, ui.className, num)
        if num then
            if not self.childNameTemplate then
                local pos = childName:find("_") -- 找到 _ 的位置
                self.childNameTemplate = childName:sub(1, pos)
            end
            local button = self.onAddElementCb(child)
            if button then
                button.path = self.path .. "/" .. child.Name
                local idx = tonumber(num)
                if idx then
                    self.childrens[idx] = button
                    button.index = idx
                end
            end
        end
    end
end

function ViewList:GetToStringParams()
    local d = ViewComponent.GetToStringParams(self)
    d["Child"] = self.childrens
    return d
end

---@param index number
---@return ViewComponent
function ViewList:GetChild(index)
    local child = self.childrens[index]
    if not child then
        self:SetElementSize(index)
        child = self.childrens[index]
    end
    return child
end

function ViewList:HideChildrenFrom(index)
    if #self.childrens > index then
        for i = index + 1, #self.childrens do
            self.childrens[i]:SetVisible(false)
        end
    end
end

---@return number
function ViewList:GetChildCount()
    return #self.childrens
end

---@param size number
function ViewList:SetElementSize(size)
    if size < 0 then
        size = 0
    end
    for i = 1, size do
        if not self.childrens[i] then
            gg.log("SetElementSize", self.path, self.ui.className, self.childrens)
            local child = self.childrens[1].node:Clone()
            child:SetParent(self.node)
            child.Name = self.childNameTemplate .. i
            if self.onAddElementCb then
                local button = self.onAddElementCb(child)
                if button then
                    button.path = self.path .. "/" .. child.Name
                    button.index = i
                    self.childrens[i] = button
                end
            end
        end
        self.childrens[i]:SetVisible(true)
    end
    if #self.childrens > size then
        for i = size + 1, #self.childrens do
			if self.childrens[i] then
				self.childrens[i]:SetVisible(false)
			end
        end
    end
end

return ViewList
