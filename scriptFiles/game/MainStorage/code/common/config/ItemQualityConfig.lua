local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg

---@class ItemQuality:Class
---@field New fun( data:table ):ItemQuality
local ItemQuality= ClassMgr.Class("ItemQuality")

function ItemQuality:onInit(data)
    self.name = data["名字"]
    self.multiplier = data["倍率"] ---@type number
    self.weight = data["比重"] ---@type number
    self.priority = data["优先级"] or 0 ---@type number
end

--- 物品品质配置文件
---@class ItemQualityConfig
local ItemQualityConfig = {}
local loaded = false

local function LoadConfig()
    ItemQualityConfig.config ={
    ["普通"] = ItemQuality.New({
        ["名字"] = "普通",
        ["倍率"] = 1,
        ["优先级"] = 0
    })
}loaded = true
end

---@param itemQuality string
---@return ItemQuality
function ItemQualityConfig.Get(itemQuality)
    if not loaded then
        LoadConfig()
    end
    return ItemQualityConfig.config[itemQuality]
end

---@return ItemType[]
function ItemQualityConfig.GetAll()
    if not loaded then
        LoadConfig()
    end
    return ItemQualityConfig.config
end

---@return ItemQuality 随机品质
function ItemQualityConfig:GetRandomQuality()
    if not loaded then
        LoadConfig()
    end
    if #self.config == 0 then
        return nil
    end
    local totalWeight = 0
    local qualities = {}
    
    -- Calculate total weight and build quality list
    for _, quality in pairs(self.config) do
        if type(quality) == "table" then
            totalWeight = totalWeight + quality.weight
            table.insert(qualities, quality)
        end
    end

    -- Get random number between 0 and total weight
    local random = math.random() * totalWeight
    local currentWeight = 0

    -- Find quality based on random weight
    for _, quality in ipairs(qualities) do
        currentWeight = currentWeight + quality.weight
        if random <= currentWeight then
            return quality
        end
    end

    -- Fallback to first quality if none found
    return qualities[1]
end

return ItemQualityConfig
