local MainCards = {}

function MainCards:SetSkillLevelOnCardFrame(cardsGuiInstance, cardFrame, skill)
    local skillInst = cardsGuiInstance.ServerSkills[skill.name]
    local severSkill = cardsGuiInstance.ServerSkills[skill.name]
    local skillLevel = 0
    if severSkill then
        skillLevel = severSkill.level
    elseif skillInst then
        skillLevel = skillInst.level
    end
    local descNode = cardFrame["等级"]
    if descNode then
        local maxLevel = skill.maxLevel or 1
        descNode.Title = string.format("%d/%d", skillLevel, maxLevel)
    end
end

function MainCards:RegisterSkillCardButton(cardsGuiInstance, cardFrame, skill, lane, position)
    local ViewButton = require(game:GetService("MainStorage").code.client.ui.ViewButton)
    local SkillTypeConfig = require(game:GetService("MainStorage").code.common.config.SkillTypeConfig)
    local viewButton = ViewButton.New(cardFrame, cardsGuiInstance, nil, "卡框背景")
    viewButton.extraParams = {
        skillId = skill.name,
        lane = lane,
        position = position
    }
    viewButton.clickCb = function(ui, button)
        local skillId = button.extraParams.skillId
        local skill = SkillTypeConfig.Get(skillId)
        local skillInst = cardsGuiInstance.ServerSkills[skillId]
        local skillLevel = 0
        local attributeButton = cardsGuiInstance.attributeButton.node
        if skillInst then
            skillLevel = skillInst.level
        end
        local nameNode = attributeButton["卡片名字"]
        if nameNode then
            nameNode.Title = skill.displayName
        end
        -- 更新技能描述
        local descNode = attributeButton["卡片介绍"]
        if descNode then
            descNode.Title = skill.description
        end
        local descPreTitleNode = attributeButton["列表_强化前"]["强化标题"]
        local descPostTitleNode =attributeButton["列表_强化后"]["强化标题"]
        local descPreNode = attributeButton["列表_强化前"]["属性_1"]
        local descPostNode = attributeButton["列表_强化后"]["属性_1"]

        descPreTitleNode.Title = string.format("等级 %d/%d", skillLevel, skill.maxLevel)
        local descPre = {}
        for _, tag in pairs(skill.passiveTags) do
            table.insert(descPre, tag:GetDescription(skillLevel))
        end
        descPreNode.Title = table.concat(descPre, "\n")
        if skillLevel < skill.maxLevel then
            descPostTitleNode.Title = string.format("等级 %d/%d", skillLevel+1, skill.maxLevel)
            local descPost = {}
            for _, tag in pairs(skill.passiveTags) do
                table.insert(descPost, tag:GetDescription(skillLevel+1))
            end
            descPostNode.Title = table.concat(descPost, "\n")
        end
        local curCardSkillData = cardsGuiInstance.ServerSkills[skillId]
        ---@ type SkillType
        local curSkillType =  SkillTypeConfig.Get(skillId)
        local prerequisite = curSkillType.prerequisite
        local existsPrerequisite = true
        for i, preSkillType in ipairs(prerequisite) do
            if not cardsGuiInstance.ServerSkills[preSkillType.name] then
                existsPrerequisite = false
                break
            end
        end
        local skillLevel = 0
        if curCardSkillData or existsPrerequisite then
            cardsGuiInstance.EquipmentSkillsButton:SetTouchEnable(true)
            if curCardSkillData then
                skillLevel = curCardSkillData.level
            end
            local maxLevel = skill.maxLevel
            local levelNode = cardFrame["等级"]
            if skillLevel ==maxLevel then
                cardsGuiInstance.confirmPointsButton:SetTouchEnable(false)
            else
                cardsGuiInstance.confirmPointsButton:SetTouchEnable(true)
            end
            if levelNode then
                gg.log("设置技能等级",string.format("%d/%d", skillLevel, maxLevel))
                levelNode.Title = string.format("%d/%d", skillLevel, maxLevel)
            end
        else 
            cardsGuiInstance.confirmPointsButton:SetTouchEnable(false)
            cardsGuiInstance.EquipmentSkillsButton:SetTouchEnable(false)
        end
        cardsGuiInstance.currentMCardButtonName = button
    end

    -- 设置图标
    if skill.icon and skill.icon ~= "" then
        local iconNode = cardFrame["卡框背景"]["图标"]
        if iconNode then
            iconNode.Icon = skill.icon
        end
    end

    -- 设置技能名称
    local nameNode = cardFrame["技能名"]
    if nameNode then
        nameNode.Title = skill.displayName
    end
    -- 设置技能等级
    MainCards:SetSkillLevelOnCardFrame(cardsGuiInstance, cardFrame, skill)
    cardsGuiInstance.mainCardButtondict[skill.name] = viewButton
    return viewButton
end

function MainCards:CloneMainCardButtons(cardsGuiInstance, skillMainTrees)
    local ViewButton = require(game:GetService("MainStorage").code.client.ui.ViewButton)
    local ListTemplate = cardsGuiInstance:Get('框体/主卡/选择列表/列表', require(game:GetService("MainStorage").code.client.ui.ViewList))
    local index = 1
    for skillName, rootNode in pairs(skillMainTrees) do
        local skillType = rootNode.data
        local mainSkillName = skillType.name
        local child = ListTemplate:GetChild(index)
        child.extraParams["skillId"] = mainSkillName
        child.node.Name = skillType.name 
        if skillType.icon and skillType.icon ~= "" then
            local iconNode = child.node['图标']
            if iconNode then
                iconNode.Icon = skillType.icon
            end
        end
        MainCards:mainCardButton(cardsGuiInstance, child.node, mainSkillName)
        index = index + 1
    end
end

function MainCards:mainCardButton(cardsGuiInstance, childNode, SkillName)
    local ViewButton = require(game:GetService("MainStorage").code.client.ui.ViewButton)
    local clonedButton = ViewButton.New(childNode, cardsGuiInstance, nil, "卡框背景")
    clonedButton.extraParams = {skillId = SkillName}
    cardsGuiInstance.skillButtons[SkillName] = clonedButton
    clonedButton.clickCb = function(ui, button)
        local SkillName = button.extraParams["skillId"]
        local currentList = cardsGuiInstance.skillLists[SkillName]
        if currentList then
            for name, vlist in pairs(cardsGuiInstance.skillLists) do
                vlist:SetVisible(name == SkillName)
            end
        end
    end
    return clonedButton
end

function MainCards:CloneVerticalListsForSkillTrees(cardsGuiInstance, skillMainTrees)
    local ViewList = require(game:GetService("MainStorage").code.client.ui.ViewList)
    local verticalListTemplate = cardsGuiInstance:Get("框体/主卡/加点框/纵列表", ViewList)
    if not verticalListTemplate or not verticalListTemplate.node then
        return
    end
    for mainSkillName, skillTree in pairs(skillMainTrees) do
        local clonedVerticalList = verticalListTemplate.node:Clone()
        clonedVerticalList.Name = mainSkillName
        clonedVerticalList.Parent = verticalListTemplate.node.Parent
        clonedVerticalList.Visible = false
        local mainCardFrame = clonedVerticalList["主卡框"]
        local mainCardNode = skillTree.data
        if mainCardFrame then
            MainCards:RegisterSkillCardButton(cardsGuiInstance, mainCardFrame, mainCardNode, 0, 2)
        end
        local listTemplate = clonedVerticalList["列表_1"]
        if not listTemplate then return end
        -- 下面的DAG算法和UI渲染逻辑直接照搬
        -- ... 省略，直接复制CardsGui.lua对应部分 ...
        -- 这里建议直接复制CardsGui:CloneVerticalListsForSkillTrees的实现
        -- 并将self全部替换为cardsGuiInstance，辅助函数也用MainCards:调用
        -- ...
    end
    if verticalListTemplate and verticalListTemplate.node then
        verticalListTemplate.node:Destroy()
    end
end

function MainCards:LoadMainCardsAndClone(cardsGuiInstance)
    local SkillTypeUtils = require(game:GetService("MainStorage").code.common.conf_utils.SkillTypeUtils)
    local skillMainTrees = SkillTypeUtils.lastForest
    if not skillMainTrees then
        skillMainTrees = SkillTypeUtils.BuildSkillForest(0)
        SkillTypeUtils.lastForest = skillMainTrees
    end
    MainCards:CloneVerticalListsForSkillTrees(cardsGuiInstance, skillMainTrees)
end

return MainCards
