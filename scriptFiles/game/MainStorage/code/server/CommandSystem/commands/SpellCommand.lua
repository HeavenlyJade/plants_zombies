--- 物品相关命令处理器
local MainStorage = game:GetService("MainStorage")
local gg = require(MainStorage.code.common.MGlobal)    ---@type gg
local SpellConfig = require(MainStorage.code.common.config.SpellConfig)  ---@type SpellConfig
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell
local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig
local Graphics = require(MainStorage.code.server.graphic.Graphics) ---@type Graphics
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam


---@class SpellCommand
local SpellCommand = {}

---@param player Player
function SpellCommand.cast(params, player)
    if params["复杂魔法"] and params["复杂魔法"]["魔法"] then
        local spell = SubSpell.New(params["复杂魔法"])
        spell:Cast(player, nil)
    else
        local spell = SpellConfig.Get(params["魔法名"])
        if not spell then
            player:SendChatText("不存在的魔法", params["魔法名"])
            return false
        end
        spell:Cast(player, nil)
    end
    return true
end

---@param player Player
function SpellCommand.skill(params, player)
    local skillType = SkillTypeConfig.Get(params["技能名"])
    if not skillType then
        player:SendChatText("不存在的技能: %s", params["技能名"])
        return false
    end

    local action = params["操作"] or "升级"
    if action == "升级" then
        if player:UpgradeSkill(skillType) then
            player:syncSkillData()
            player:SendChatText("技能操作成功: %s", skillType.name)
            return true
        else
            player:SendChatText("技能操作失败: %s", skillType.name)
            return false
        end
    elseif action == "装备" then
        local slot = params["装备格子"]
        if not slot or slot < 1 then
            player:SendChatText("无效的装备格子: %d", slot)
            return false
        end

        -- 查找玩家是否已拥有该技能
        local foundSkillId = nil
        for skillId, skill in pairs(player.skills) do
            if skill.skillType == skillType then
                foundSkillId = skillId
                break
            end
        end

        if not foundSkillId then
            player:SendChatText("未学习该技能: %s", skillType.name)
            return false
        end

        -- 装备技能
        if player:EquipSkill(foundSkillId, slot) then
            player:SendChatText("技能装备成功: %s", skillType.name)
            return true
        else
            player:SendChatText("技能装备失败: %s", skillType.name)
            return false
        end
    else
        player:SendChatText("未知的操作类型: %s", action)
        return false
    end
end

---@param player Player
function SpellCommand.graphic(params, player)
    local graphics = Graphics.Load(params["特效"])
    if not graphics then return false end
    local actions = {}
    for i, effect in ipairs(graphics) do
        if effect and effect:IsTargeter(nil) then
            effect:PlayAt(player, player, CastParam.New(), actions)
        end
    end
    return true
end

---@param player Player
function SpellCommand.var(params, player)
    local value = tonumber(params["值"])
    if not value then
        player:SendChatText("变量值必须是数字: %s", params["值"])
        return false
    end

    local targetPlayer = player
    if params["玩家"] == "目标" then
        targetPlayer = player.target
        if not targetPlayer then
            player:SendChatText("找不到目标玩家")
            return false
        end
    end

    -- 获取玩家变量
    local vars = targetPlayer.variables
    if not vars then
        player:SendChatText("玩家变量不存在")
        return false
    end

    -- 根据操作类型执行相应的变量修改
    local action = params["操作"] or "增加"
    local varName = params["变量名"]
    local changes = {}
    
    if action == "增加" then
        local oldValue = vars[varName] or 0
        vars[varName] = oldValue + value
        table.insert(changes, string.format("%s的变量[%s]从%d改为%d", player.name, varName, oldValue, vars[varName]))
    elseif action == "减少" then
        local oldValue = vars[varName] or 0
        vars[varName] = oldValue - value
        table.insert(changes, string.format("%s的变量[%s]从%d改为%d", player.name, varName, oldValue, vars[varName]))
    elseif action == "改为" then
        local oldValue = vars[varName] or 0
        vars[varName] = value
        table.insert(changes, string.format("%s的变量[%s]从%d改为%d", player.name, varName, oldValue, vars[varName]))
    elseif action == "全部增加" then
        for k, _ in pairs(vars) do
            if string.find(k, varName) then
                local oldValue = vars[k] or 0
                vars[k] = oldValue + value
                table.insert(changes, string.format("%s的变量[%s]从%d改为%d", player.name, k, oldValue, vars[k]))
            end
        end
    elseif action == "全部减少" then
        for k, _ in pairs(vars) do
            if string.find(k, varName) then
                local oldValue = vars[k] or 0
                vars[k] = oldValue - value
                table.insert(changes, string.format("%s的变量[%s]从%d改为%d", player.name, k, oldValue, vars[k]))
            end
        end
    elseif action == "全部改为" then
        for k, _ in pairs(vars) do
            if string.find(k, varName) then
                local oldValue = vars[k] or 0
                vars[k] = value
                table.insert(changes, string.format("%s的变量[%s]从%d改为%d", player.name, k, oldValue, vars[k]))
            end
        end
    else
        player:SendChatText("未知的操作类型: %s", action)
        return false
    end

    -- 打印变量修改信息
    if #changes > 0 then
        print(table.concat(changes, "\n"))
    end

    -- 同步变量到客户端
    player:SendChatText("变量操作成功")
    return true
end

return SpellCommand