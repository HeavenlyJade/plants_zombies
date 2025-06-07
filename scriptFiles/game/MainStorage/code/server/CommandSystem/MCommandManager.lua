
local MainStorage = game:GetService("MainStorage")
local gg = require(MainStorage.code.common.MGlobal)    ---@type gg
-- local CommandParser = require(MainStorage.code.server.CommandSystem.parsers.MCommandParser)  ---@type CommandParser
-- local ConditionParser = require(MainStorage.code.server.CommandSystem.parsers.MConditionParser) ---@type ConditionParser
local ItemCommands = require(MainStorage.code.server.CommandSystem.commands.MItemCommands)   ---@type ItemCommands
local MiscCommands = require(MainStorage.code.server.CommandSystem.commands.MiscCommand)   ---@type MiscCommand
local MobCommand = require(MainStorage.code.server.CommandSystem.commands.MobCommand)   ---@type MobCommand
local SpellCommand = require(MainStorage.code.server.CommandSystem.commands.SpellCommand)   ---@type SpellCommand
local StatCommand = require(MainStorage.code.server.CommandSystem.commands.StatCommand)   ---@type StatCommand
local QuestCommand = require(MainStorage.code.server.CommandSystem.commands.QuestCommands)   ---@type QuestCommand
local LevelCommand = require(MainStorage.code.server.CommandSystem.commands.LevelCommand)   ---@type LevelCommand
local MailCommand = require(MainStorage.code.server.CommandSystem.commands.MailCommand) ---@type MailCommand
local SkillCommands = require(MainStorage.code.server.CommandSystem.commands.MSkillCommands)     ---@type SkillCommands

-- local QuestCommands = require(MainStorage.code.server.CommandSystem.commands.MQuestCommands)     ---@type QuestCommands
-- local PlayerCommands = require(MainStorage.code.server.CommandSystem.commands.MPlayerCommands)   ---@type PlayerCommands
-- local SystemCommands = require(MainStorage.code.server.CommandSystem.commands.MSystemCommands)   ---@type SystemCommands
local json = require(MainStorage.code.common.json)
local ServerEventManager = require(MainStorage.code.server.event.ServerEventManager) ---@type ServerEventManager


---@class CommandManager
local CommandManager = {}

-- 所有指令处理器 (使用多级嵌套结构)
CommandManager.handlers = {
    -- 物品相关
    ["give"] = ItemCommands.give,
    ["invsee"] = ItemCommands.invsee,
    ["focusOn"] = SpellCommand.focusOn,
    ["clear"] = ItemCommands.clear,
    ["title"] = MiscCommands.title,
    ["spawnMob"] = MobCommand.spawnMob,
    ["cast"] = SpellCommand.cast,
    ["skill"] = SpellCommand.skill,
    ["showStat"] = StatCommand.showStat,
    ["quest"] = QuestCommand.main,
    ["level"] = LevelCommand.enter,
    ["var"] = SpellCommand.var,
    ["afk"] = SkillCommands.afk,
    ["graphic"] = SpellCommand.graphic,
       -- 邮件相关命令
    ["mail"] = MailCommand.main,
        -- 玩家技能相关命令
    -- 装载默认的配置技能
    ["loadSkill"] = SkillCommands.main,
    -- ["装备"] = {},

    -- -- 玩家属性相关
    -- ["等级"] = {},
    -- ["经验"] = {},
    -- ["属性"] = {},
    -- ["金币"] = {},
    -- ["声望"] = {},

    -- -- 任务相关
    -- ["任务"] = {},

    -- -- 技能相关
    -- ["技能"] = {},
    -- ["武魂"] = {},

    -- -- 系统相关
    -- ["事件"] = {},
    -- ["地图"] = {}
}

ServerEventManager.Subscribe("ClientExecuteCommand", function(evt)
    CommandManager.ExecuteCommand(evt.command, evt.player)
end)

function CommandManager.ExecuteCommand(commandStr, player)
    if not commandStr or commandStr == "" then return false end

    -- 1. 分割命令和参数
    local command, jsonStr = commandStr:match("^(%S+)%s+(.+)$")
    if not command then
        gg.log("命令格式错误: " .. commandStr)
        return false
    end

    -- 2. 查找命令处理器
    local handler = CommandManager.handlers[command]
    if not handler then
        gg.log("未知命令: " .. command)
        return false
    end

    -- 3. 解析JSON参数
    local params = json.decode(jsonStr)
    if params["在线"] == "不在线" then
        --- 用来处理玩家不在线的情况
        --- 获取玩家
   
    elseif params["玩家"] then
        player = gg.getLivingByName(params["玩家"])
        if not player then
            gg.log("玩家不存在: " .. params["玩家"])
            return false
        end
    end
    gg.log("执行指令", player, command, params)
    -- 5. 调用处理器
    local success, result = pcall(handler, params, player)
    if not success then
        gg.log("命令执行错误: " .. command .. ", " .. tostring(result))
        return false
    end

    return result
end



return CommandManager
