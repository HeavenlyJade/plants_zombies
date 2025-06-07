--- 技能相关命令处理器
--- V109 miniw-haima

local MainStorage = game:GetService("MainStorage")
local gg = require(MainStorage.code.common.MGlobal)    ---@type gg
local cloudDataMgr = require(MainStorage.code.server.MCloudDataMgr)  ---@type MCloudDataMgr
local Skill = require(MainStorage.code.server.spells.Skill) ---@type Skill
local SkillEventConfig = require(MainStorage.code.common.event_conf.event_skill) ---@type SkillEventConfig
local SkillCommon = require(MainStorage.code.server.spells.SkillCommon) ---@type SkillCommon
---@class SkillCommands
local SkillCommands = {}


---@param params table
---@param player Player
function SkillCommands.unlock(params, player)
    local skillName = params["skillName"]
    local level = params["level"] or 1

    -- 使用SkillCommon的验证方法
    local skillType, errorCode = SkillCommon.ValidateSkillLearn(player, skillName)

    if errorCode ~= SkillEventConfig.ERROR_CODES.SUCCESS then
        local errorMsg = SkillCommon.FormatErrorMessage(
            "技能解锁失败: " .. SkillEventConfig.GetErrorMessage(errorCode),
            player,
            skillName
        )
        SkillCommon.SendMessageAndLog(player, errorMsg, true)
        return
    end

    -- 创建技能实例
    local skill = SkillCommon.CreateSkillInstance(player, skillName, level)
    if not skill then
        local errorMsg = SkillCommon.FormatErrorMessage("技能创建失败", player, skillName)
        SkillCommon.SendMessageAndLog(player, errorMsg, true)
        return
    end

    -- 成功消息
    local successMsg = SkillCommon.FormatSuccessMessage("技能解锁成功", player, skillName)
    SkillCommon.SendMessageAndLog(player, successMsg, false)

    -- 发送响应到客户端
    local responseData = {
        skillName = skillName,
        level = skill.level,
        slot = skill.equipSlot
    }
    gg.network_channel:fireClient(player.uin, {
        cmd = SkillEventConfig.RESPONSE.LEARN,
        data = responseData
    })
end

---@param params table
---@param player Player
function SkillCommands.destroy(params, player)
    local skillName = params["skillName"]

    -- 使用SkillCommon的验证方法
    local skillType, skillInstance, errorCode = SkillCommon.ValidateSkillAndPlayer(player, skillName)

    if errorCode ~= SkillEventConfig.ERROR_CODES.SUCCESS then
        local errorMsg = SkillCommon.FormatErrorMessage(
            "销毁技能失败: " .. SkillEventConfig.GetErrorMessage(errorCode),
            player,
            skillName
        )
        SkillCommon.SendMessageAndLog(player, errorMsg, true)
        return
    end

    gg.log("开始销毁技能: " .. skillName .. "，玩家:" .. player.name)

    -- 执行销毁逻辑
    local destroyResult = SkillCommon.PerformSkillDestroy(player, skillName)

    if destroyResult.success then
        -- 保存玩家数据
        player:saveSkillConfig()
        -- 同步最新的技能数据到客户端
        player:syncSkillData()

        local successMsg = SkillCommon.FormatSuccessMessage(
            "技能销毁成功，同时销毁的技能: " .. table.concat(destroyResult.destroyedSkills, ", "),
            player,
            skillName
        )
        SkillCommon.SendMessageAndLog(player, successMsg, false)
    else
        local errorMsg = SkillCommon.FormatErrorMessage(
            "技能销毁失败: " .. SkillEventConfig.GetErrorMessage(destroyResult.errorCode),
            player,
            skillName
        )
        SkillCommon.SendMessageAndLog(player, errorMsg, true)
    end
end


function SkillCommands.afk(params, player)
    local action = params["操作"] or "进入挂机"
    if action == "进入挂机" then
        player:SendEvent("AfkSpotUpdate", {enter = true})
        player:EnterBattle()
    elseif action == "离开挂机" then
        player:SendEvent("AfkSpotUpdate", {enter = false})
        player:ExitBattle()
    end
end

-- --装载配置的文件的技能
function SkillCommands.main(params, player)
    gg.log("技能命令处理",params)
    local uin = params["ID"]
    local player = gg.getPlayerByUin(uin)
    local skillName = params["技能"]
    local level = params["等级"]
    local optype = params["类型"]

    if not player then
        gg.log("玩家不存在: " .. uin)
        return false
    end

    if optype == "解锁" then
        local args = {skillName = skillName, level = level}
        SkillCommands.unlock(args, player)
    elseif optype == "销毁" then
        local args = {skillName = skillName}
        SkillCommands.destroy(args, player)
    -- elseif optype == "装载" then
    --     player:LoadingConfSkills(args)
    end
    return true
end



return SkillCommands
