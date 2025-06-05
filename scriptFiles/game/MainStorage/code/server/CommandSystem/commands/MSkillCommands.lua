--- 技能相关命令处理器
--- V109 miniw-haima

local MainStorage = game:GetService("MainStorage")
local gg = require(MainStorage.code.common.MGlobal)    ---@type gg
local cloudDataMgr = require(MainStorage.code.server.MCloudDataMgr)  ---@type MCloudDataMgr
local Skill = require(MainStorage.code.server.spells.Skill) ---@type Skill
local SkillEventConfig = require(MainStorage.code.common.event_conf.event_skill) ---@type SkillEventConfig
---@class SkillCommands
local SkillCommands = {}


---@param params table
---@param player Player
function SkillCommands.unlock(params, player)

    local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig
    local allSkills = SkillTypeConfig.GetAll()
    local skillName = params["skillName"]
    local level = params["level"]
    local skillType = allSkills[skillName]
    if not skillType then
        local test  ="解锁的技能配置不存在: " .. skillName.."玩家:"..player.name
        gg.log(test)
        player:SendChatText(test)
        return
    end
    local skill_ins = player.skills[skillName]
    if skill_ins then
        local test= "解锁的技能已存在: " .. skillName.."玩家:"..player.name
        gg.log(test)
        player:SendChatText(test)
        return
    end
    local skillData = { skill = skillName,level = level}
    local skill = Skill.New(player, skillData)
    player.skills[skillName] = skill
    player:saveSkillConfig()
    local test = "技能解锁成功: " .. skillName.."玩家:"..player.name
    gg.log(test)
    player:SendChatText(test)
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
    gg.log("装载默认的配置技能",params)
    local uin = params["ID"]
    local player = gg.getPlayerByUin(uin)
    local skillName = params["技能"]
    local level = params["等级"]
    local optype = params["类型"]
    if not player then
        gg.log("玩家不存在: " .. uin)
        return false
    end
    local args = {skillName = skillName,level = level}
    if optype == "解锁" then
        SkillCommands.unlock(args,player)
    -- elseif optype == "装载" then
    --     player:LoadingConfSkills(args)
    end
    return true
end



return SkillCommands
