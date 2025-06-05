--- 任务相关命令处理器
--- V109 miniw-haima 修改版

local MainStorage = game:GetService("MainStorage")
local gg = require(MainStorage.code.common.MGlobal)    ---@type gg
local QuestConfig = require(MainStorage.code.common.config.QuestConfig)


---@class QuestCommand
local QuestCommand = {}

---@param player Player
function QuestCommand.main(params, player)
    if params["动作"] == "刷新" then
        local keyword
        if params["刷新类型"] == "关键词" then
            keyword = params["关键词"]
        else
            keyword = params["刷新类型"]
        end
        player:RefreshQuest(keyword)
        return true
    end
    if params["动作"] == "事件" then
        player:ProcessQuestEvent(params["事件名"], params["推进数量"] or 1)
        return true
    end

    local quest = QuestConfig.Get(params["任务"]) ---@type Quest
    if not quest then
        player:SendChatText("任务不存在: %s", params["任务"])
        return false
    end

    if params["动作"] == "领取" then
        -- 检查是否已接受或完成
        if quest:Has(player) then
            player:SendChatText("你已经接受或完成了该任务")
            return false
        end
        
        -- 尝试接受任务
        if quest:Accept(player) then
            player:SendChatText("成功接受任务: %s", quest.name)
            return true
        else
            player:SendChatText("无法接受任务: %s", quest.name)
            return false
        end
        
    elseif params["动作"] == "放弃" then
        -- 检查是否已接受该任务
        if not player.quests[quest.name] then
            player:SendChatText("你未接受该任务")
            return false
        end
        
        -- 移除任务
        player.quests[quest.name] = nil
        player.acceptedQuestIds[quest.name] = nil
        player:UpdateQuestsData()
        player:SendChatText("已放弃任务: %s", quest.name)
        return true
        
    elseif params["动作"] == "增加进度" then
        -- 检查是否已接受该任务
        if not player.quests[quest.name] then
            player:SendChatText("你未接受该任务")
            return false
        end
        
        local count = tonumber(params["数量"]) or 1
        player.quests[quest.name]:AddProgress(count)
        player:UpdateQuestsData()
        player:SendChatText("任务进度已更新: %s", quest.name)
        return true
        
    elseif params["动作"] == "设置进度" then
        -- 检查是否已接受该任务
        if not player.quests[quest.name] then
            player:SendChatText("你未接受该任务")
            return false
        end
        
        local count = tonumber(params["数量"]) or 0
        player.quests[quest.name]:SetProgress(count)
        player:UpdateQuestsData()
        player:SendChatText("任务进度已设置: %s", quest.name)
        return true
        
    elseif params["动作"] == "完成" then
        -- 检查是否已接受该任务
        if not player.quests[quest.name] then
            player:SendChatText("你未接受该任务")
            return false
        end
        
        -- 尝试完成任务
        if player.quests[quest.name]:Finish() then
            player:SendChatText("任务已完成: %s", quest.name)
            return true
        else
            player:SendChatText("无法完成任务: %s", quest.name)
            return false
        end
    end
    
    return false
end

return QuestCommand