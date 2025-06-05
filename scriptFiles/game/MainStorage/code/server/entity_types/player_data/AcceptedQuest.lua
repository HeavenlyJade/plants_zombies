local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ItemTypeConfig = require(MainStorage.code.common.config.ItemTypeConfig) ---@type ItemTypeConfig

---@class AcceptedQuest:Class
local AcceptedQuest = ClassMgr.Class("AcceptedQuest")

---@param quest Quest
---@param player Player
function AcceptedQuest:OnInit(quest, player)
    self.quest = quest ---@type Quest
    self.player = player ---@type Player
    self.progress = 0
end

---@return boolean
function AcceptedQuest:IsCompleted()
    return self:GetProgress() >= self.quest.completionCount
end

function AcceptedQuest:GetToStringParams()
    return {
        name = self.quest.name,
        count = self:GetProgress()
    }
end

---@param amount number
function AcceptedQuest:AddProgress(amount)
    if self:IsCompleted() or self.quest.questType ~= "无类型" then
        return
    end
    self.progress = math.min(self.progress + amount, self.quest.completionCount)
end

---@param amount number
function AcceptedQuest:SetProgress(amount)
    if self:IsCompleted() or self.quest.questType ~= "无类型" then
        return
    end
    self.progress = math.min(amount, self.quest.completionCount)
end

function AcceptedQuest:GetProgress()
    if self.quest.questType == "物品" then
        return self.player.bag:GetItemAmount(self.quest.requiredItem)
    elseif self.quest.questType == "变量" then
        return self.player:GetVariable(self.quest.questVariable)
    else
        return self.progress
    end
end

function AcceptedQuest:Finish()
    -- 检查是否已完成
    if not self:IsCompleted() then
        return false
    end
    
    -- 发放完成奖励
    if self.quest.completionRewards then
        for itemId, amount in pairs(self.quest.completionRewards) do
            local item = ItemTypeConfig.Get(itemId):ToItem(amount)
            self.player.bag:AddItem(item)
        end
    end

    if self.quest.completionCommands then
        self.player:ExecuteCommands(self.quest.completionCommands)
    end
    
    -- 发放邮件奖励
    if self.quest.mailRewards then
        local mailData = {
            title = self.quest.name .. "奖励",
            content = "恭喜完成" .. self.quest.name,
            attachments = self.quest.mailRewards,  -- 直接使用 {itemId = amount} 格式的奖励
            sender = "系统",
            sender_type = "system",
            sender_id = 0
        }
        local CloudMailData = require(MainStorage.code.server.cloundData.CloudMailData)  ---@type CloudMailData
        CloudMailData:AddPlayerMail(self.player.uin, mailData)
    end
    
    -- 自动领取下一任务
    if self.quest.nextQuest then
        local nextQuest = require(MainStorage.code.common.config.QuestConfig).Get(self.quest.nextQuest)
        if nextQuest then
            nextQuest:Accept(self.player)
        end
    end
    
    -- 从玩家任务列表中移除
    self.player.quests[self.quest.name] = nil
    self.player.acceptedQuestIds[self.quest.name] = 1 -- 标记为已完成
    
    -- 同步到客户端
    self.player:UpdateQuestsData()
    return true
end

---@return SerializedQuest
function AcceptedQuest:GetQuestDesc()
    local title = self.quest.shortDesc
    local progress = self:GetProgress()
    return {
        name = self.quest.name,
        description = title,
        count = progress,
        countMax = self.quest.completionCount
    }
end

return AcceptedQuest