local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local ViewComponent = require(MainStorage.code.client.ui.ViewComponent) ---@type ViewComponent
local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager
local SkillTypeUtils = require(MainStorage.code.common.conf_utils.SkillTypeUtils) ---@type SkillTypeUtils
local SkillEventConfig = require(MainStorage.code.common.event_conf.event_skill) ---@type SkillEventConfig

--local MainCards = require(MainStorage.code.client.ui.CardsGui.MainCards)

local gg = require(MainStorage.code.common.MGlobal)   ---@type gg

local uiConfig = {
    uiName = "CardsGui",
    layer = 3,
    hideOnInit = true,
    qualityList = {"UR", "SSR", "SR", "R", "N"},
    qualityListMap = {["品质_5"]="N", ["品质_4"]="R", ["品质_3"]="SR", ["品质_2"]="SSR", ["品质_1"]="UR"},
    mianCard ="主卡",
    Subcard = "副卡"
}

---@class CardsGui:ViewBase
local CardsGui = ClassMgr.Class("CardsGui", ViewBase)
-- 注册主卡/副卡按钮事件
function CardsGui:RegisterCardButtons()
    -- 主卡按钮点击事件
    if self.mainCardButton then
        self.mainCardButton:SetTouchEnable(true)
        self.mainCardButton.clickCb = function(ui, button)
            self:SwitchToCardType("主卡")
        end
    else
    end
    -- 副卡按钮点击事件
    if self.subCardButton then
        self.subCardButton:SetTouchEnable(true)
        self.subCardButton.clickCb = function(ui, button)
            self:SwitchToCardType("副卡")
        end
    else
    end
end


---@override
function CardsGui:OnInit(node, config)
    ViewBase.OnInit(self, node, config)
    self.qualityList = self:Get("品质列表", ViewList) ---@type ViewList
    self.mainCardButton = self:Get("框体/标题/卡片/主卡", ViewButton) ---@type ViewButton
    self.subCardButton = self:Get("框体/标题/卡片/副卡", ViewButton) ---@type ViewButton
    self.closeButton = self:Get("框体/关闭", ViewButton) ---@type ViewButton
    self.attributeButton = self:Get("框体/主卡属性", ViewComponent) ---@type ViewComponent
    self.subCardAttributeButton = self:Get("框体/副卡属性", ViewComponent) ---@type ViewComponent
    self.mainCardComponent = self:Get("框体/主卡", ViewComponent) ---@type ViewComponent
    self.subCardComponent = self:Get("框体/副卡", ViewComponent) ---@type ViewComponent
    self.confirmPointsButton = self:Get("框体/主卡属性/主卡_研究", ViewButton) ---@type ViewButton
    self.EquipmentSkillsButton = self:Get("框体/主卡属性/主卡_装备", ViewButton) ---@type ViewButton

    self.SubcardEnhancementButton = self:Get("框体/副卡属性/副卡_强化", ViewButton) ---@type ViewButton
    self.SubcardAllEnhancementButton = self:Get("框体/副卡属性/副卡一键强化", ViewButton) ---@type ViewButton
    self.SubcardEquipButton = self:Get("框体/副卡属性/副卡_装备", ViewButton) ---@type ViewButton


    self.selectionList = self:Get("框体/主卡/选择列表", ViewList) ---@type ViewList
    self.mainCardFrame = self:Get("框体/主卡/加点框/纵列表/主卡框", ViewButton) ---@type ViewButton
    self.skillButtons = {} ---@type table<string, ViewButton> -- 主卡按钮框
    self.skillLists = {} ---@type table<string, ViewList>     -- 主卡技能树列表
    self.mainCardButtondict = {} ---@type table<string, ViewButton> -- 主卡技能树的按钮
    self.subCardButtondict = {} ---@type table<string, ViewButton> -- 副卡技能的按钮
    self.subQualityLists ={} ---@type table<string, ViewList> -- 副卡品级列表
    self.mainQualityLists = {} ---@type table<string, ViewList> -- 主卡品质列表 UR:Viewlist

    self.qualityListMap = {} ---@type table<string, string> -- 构建反射的品质按钮名->品质名字典
    -- 玩家的装备槽数据数据
    self.equippedSkills = {} ---@type table<number, string>
    --- 玩家来自服务器的当前是技能数据
    self.ServerSkills = {} ---@type table<string, table>
    -- 当前点击主卡技能树的按钮
    ---@type ViewButton
    self.currentMCardButtonName = nil
    self.currentSubCardButtonName = nil
    -- 当前显示的卡片类型 ("主卡" 或 "副卡")
    self.currentCardType = "主卡"
    self.closeButton.clickCb = function ()
        self:Close()
    end

    self:RegisterMainCardFunctionButtons()
    self:RegisterCardButtons()
    -- 设置默认显示主卡
    self:SwitchToCardType(self.currentCardType)
    self:LoadMainCardsAndClone()
    self:BindQualityButtonEvents()
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.SYNC_SKILLS, function(data)
        self:HandleSkillSync(data)
    end)

    -- 监听技能升级响应
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.UPGRADE, function(data)
        self:OnSkillLearnUpgradeResponse(data)
    end)

    -- 监听单个新技能添加事件
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.LEARN, function(data)
        self:HandleNewSkillAdd(data)
    end)
end

-- 注册主卡功能按钮事件
function CardsGui:RegisterMainCardFunctionButtons()
    self.confirmPointsButton.clickCb = function (ui, button)
        local skillName = self.currentMCardButtonName.extraParams["skillId"]
        gg.log("主卡_研究发送升级了请求",skillName)
        gg.network_channel:FireServer({
            cmd = SkillEventConfig.REQUEST.UPGRADE,
            skillName = skillName
        })
    end
    self.EquipmentSkillsButton.clickCb = function (ui, button)
        gg.log("主卡_装备发送了装备的请求")
        gg.network_channel:FireServer({
            cmd = SkillEventConfig.REQUEST.EQUIP,
            skillName = self.currentMCardButtonName.extraParams["skillId"],

        })
    end
    if self.SubcardEnhancementButton then
        self.SubcardEnhancementButton.clickCb = function(ui, button)
            gg.log("副卡_强化发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]

            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.UPGRADE,
                skillName = skillName
            })
        end
    end
    if self.SubcardAllEnhancementButton then
        self.SubcardAllEnhancementButton.clickCb = function(ui, button)
            gg.log("副卡一键强化发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]

            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.EQUIP,
                skillName = skillName

            })
        end
    end
    if self.SubcardEquipButton then
        self.SubcardEquipButton.clickCb = function(ui, button)
            gg.log("副卡_装备发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]
            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.EQUIP,
                skillName = skillName
            })
        end
    end
end
-- 处理技能同步数据
function CardsGui:HandleSkillSync(data)
    gg.log("CardsGui获取来自服务端的技能数据", data)
    if not data or not data.skillData then return end
    local skillDataDic = data.skillData.skills

    self.ServerSkills = {}
    self.equippedSkills = {}
    local serverSkillMainTrees = {} ---@type table<string, table>
    local serverSubskillDic = {} ---@type table<string, table>
    -- 反序列化技能数据
    for skillName, skillData in pairs(skillDataDic) do
        -- 创建技能对象
        self.ServerSkills[skillName] = skillData
        -- 记录已装备的技能
        if skillData.slot > 0 then
            self.equippedSkills[skillData.slot] = skillName
        end

        local skillType = SkillTypeConfig.Get(skillName)
        if skillType and skillType.isEntrySkill and skillType.skillType==0 then
            serverSkillMainTrees[skillName] = {data=skillType}
        elseif skillType and skillType.isEntrySkill and  skillType.skillType==1 then
            serverSubskillDic[skillName] = {data=skillType,serverdata=skillData}
        end
        --- 更新技能树的节点显示
        self:UpdateSkillTreeNodeDisplay(skillName)
    end
    -- 更新UI显示
    --- self:UpdateSkillDisplay()
    --- 创建主卡的按钮
    self:CloneMainCardButtons(serverSkillMainTrees)
    self:LoadSubCardsAndClone(serverSubskillDic)
end

function CardsGui:UpdateSkillTreeNodeDisplay(skillName)
    local skillTreeButton = self.mainCardButtondict[skillName]

    local skillType = SkillTypeConfig.Get(skillName)
    if skillTreeButton and skillTreeButton.node then
        self:SetSkillLevelOnCardFrame(skillTreeButton.node, skillType)
    end

end

function CardsGui:UpdateSubCardTreeNodeDisplay(skillName)
    local skillTreeButton = self.subCardButtondict[skillName]
    local skillType = SkillTypeConfig.Get(skillName)
    if skillTreeButton and skillTreeButton.node then
        self:SetSkillLevelSubCardFrame(skillTreeButton.node, skillType)
    end
end


--- 处理技能学习/升级响应
function CardsGui:OnSkillLearnUpgradeResponse(response)
    gg.log("收到技能学习/升级响应", response)
    local data = response.data
    local skillName = data.skillName
    local serverlevel = data.level
    local serverslot = data.slot
    local skillData = self.ServerSkills[skillName]
    if skillData then
        skillData.level = serverlevel
        skillData.slot = serverslot
    else
        self.ServerSkills[skillName] = {
            level = serverlevel,
            slot = serverslot,
            skill =skillName
        }
    end
    local skillType = SkillTypeConfig.Get(skillName)
    if skillType.skillType==1 then
        self.SubcardEnhancementButton:SetTouchEnable(true)
        self.SubcardAllEnhancementButton:SetTouchEnable(true)
    elseif skillType.skillType==0  then
        self:UpdateSkillTreeNodeDisplay(skillName)
    end

    -- self:UpdateSkillDisplay()
end

function CardsGui:Display(title, content, confirmCallback, cancelCallback)
    self.qualityList.Title = title
    self.mainCardButton.Title = content
    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
end

-- ========== 卡片切换功能 ==========

-- 切换到指定的卡片类型
function CardsGui:SwitchToCardType(cardType)
    self.currentCardType = cardType
    self:UpdateCardDisplay(cardType)
    -- 根据卡片类型显示/隐藏品质列表
    if self.qualityList then
        self.qualityList:SetVisible(cardType == "副卡")
    end
end

-- 更新指定卡片类型的显示
function CardsGui:UpdateCardDisplay(cardType)
    if self.mainCardComponent then
        local showMain = (cardType == "主卡")
        self.mainCardComponent:SetVisible(showMain)
        self.attributeButton:SetVisible(showMain)
        self.subCardComponent:SetVisible(not showMain)
    end
    if self.subCardComponent then
        local showSub = (cardType == "副卡")
        self.subCardComponent:SetVisible(showSub)
        self.subCardAttributeButton:SetVisible(showSub)
        self.attributeButton:SetVisible(not showSub)
    end
end



-- 获取当前卡片类型
function CardsGui:GetCurrentCardType()
    return self.currentCardType
end

-- 读取主卡数据并克隆节点
function CardsGui:LoadMainCardsAndClone()
    ---@type SkillTreeNode[]
    --local skillMainTrees = SkillTypeUtils.BuildSkillForest(0)
    local skillMainTrees = SkillTypeUtils.lastForest
    if not skillMainTrees then
        skillMainTrees = SkillTypeUtils.BuildSkillForest(0)
        SkillTypeUtils.lastForest = skillMainTrees
    end
    -- 使用美化的打印函数显示技能树结构
    ---SkillTypeUtils.PrintSkillForest(skillMainTrees)
    -- 克隆技能树纵列表
    self:CloneVerticalListsForSkillTrees(skillMainTrees)
    -- 克隆主卡选择按钮 使用而是在服务器返回的数据后绑定
    --self:CloneMainCardButtons(skillMainTrees)
end


function CardsGui:CloneMainCardButtons(skillMainTrees)

    local mainCardButton = function(childNode  ,SkillName)
        --由于不希望"发光"相应点击,真正的按钮是 按钮/卡框背景
        gg.log("克隆主卡按钮",childNode.Name,SkillName)
        local clonedButton = ViewButton.New(childNode, self, nil, "卡框背景")
        clonedButton.extraParams = {skillId = SkillName}
        self.skillButtons[SkillName] = clonedButton
        clonedButton.clickCb = function(ui, button)
            local SkillName = button.extraParams["skillId"]
            local currentList = self.skillLists[SkillName]
            if currentList then
                for name, vlist in pairs(self.skillLists) do
                    vlist:SetVisible(name == SkillName)
                end
            end
        end
        return clonedButton
    end

    local ListTemplate = self:Get('框体/主卡/选择列表/列表', ViewList) ---@type ViewList

    -- 生成品质的viewlist
    -- local qualityList = uiConfig.qualityList
    -- local qualityListMap = uiConfig.qualityListMap
    -- for _, quality in ipairs(qualityList) do
    --     local listClone = ListTemplate.node:Clone()
    --     listClone.Name =quality
    --     listClone.Parent = ListTemplate.node.Parent
    --     local viewListObj = ViewList.New(listClone, self, "框体/主卡/选择列表/列表" .. quality)
    --     self.mainQualityLists[quality] = viewListObj
    -- end
    local index = 1
    -- local qualityIndexMap = {}
    -- for _, quality in ipairs(qualityList) do
    --     qualityIndexMap[quality] = 1
    -- end
    for skillName, rootNode in pairs(skillMainTrees) do
        gg.log("skillName",skillName,rootNode.data)
        local skillType = rootNode.data
        local mainSkillName = skillType.name
        local quality = skillType.quality or "N"
        -- local QulityListNode = self.mainQualityLists[quality]
        -- local curIndex = qualityIndexMap[quality]
        -- qualityIndexMap[quality] = curIndex + 1
        local child = ListTemplate:GetChild(index)

        child.extraParams["skillId"] = mainSkillName
        child.node.Name = skillType.name
        if skillType.icon and skillType.icon ~= "" then
            local iconNode = child.node['图标']
            if iconNode then
                iconNode.Icon = skillType.icon
            end
        end
        gg.log("模板克隆的孩子节点",child)

        mainCardButton(child.node,mainSkillName)
        index = index + 1
    end
    gg.log("skillButtons",self.skillButtons)
end

-- 注册技能卡片的ViewButton
function CardsGui:RegisterSkillCardButton(cardFrame, skill, lane, position)
    local viewButton = ViewButton.New(cardFrame, self, nil, "卡框背景")
    viewButton.extraParams = {
        skillId = skill.name,
        lane = lane,
        position = position
    }
    viewButton.clickCb = function(ui, button)
        local skillId = button.extraParams.skillId
        local skill = SkillTypeConfig.Get(skillId)
        local skillInst = self.ServerSkills[skillId]
        local skillLevel = 0
        local attributeButton = self.attributeButton.node
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
        local curCardSkillData = self.ServerSkills[skillId]
        ---@ type SkillType
        local curSkillType =  SkillTypeConfig.Get(skillId)
        local prerequisite = curSkillType.prerequisite
        local existsPrerequisite = true
        for i, preSkillType in ipairs(prerequisite) do
            if not self.ServerSkills[preSkillType.name] then
                existsPrerequisite = false
                break
            end
        end
        local skillLevel = 0
        if curCardSkillData or existsPrerequisite then
            self.EquipmentSkillsButton:SetTouchEnable(true)
            if curCardSkillData then
                skillLevel = curCardSkillData.level
            end
            local maxLevel = skill.maxLevel
            local levelNode = cardFrame["等级"]
            if skillLevel ==maxLevel then
                self.confirmPointsButton:SetTouchEnable(false)
            else
                self.confirmPointsButton:SetTouchEnable(true)
            end
            if levelNode then
                gg.log("设置技能等级",string.format("%d/%d", skillLevel, maxLevel))
                levelNode.Title = string.format("%d/%d", skillLevel, maxLevel)
            end
        else
            self.confirmPointsButton:SetTouchEnable(false)
            self.EquipmentSkillsButton:SetTouchEnable(false)
        end
        self.currentMCardButtonName = button
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
        -- gg.log("设置技能名称:", nameNode,nameNode.Title, skill.displayName,skill)
        nameNode.Title = skill.displayName
    end
    -- 设置技能等级

    self:SetSkillLevelOnCardFrame(cardFrame, skill)
    self.mainCardButtondict[skill.name] = viewButton
    return viewButton
end

function CardsGui:SetSkillLevelOnCardFrame(cardFrame, skill)
    local severSkill = self.ServerSkills[skill.name]
    local skillLevel = 0
    if severSkill then
        skillLevel = severSkill.level
    end
    local descNode = cardFrame["等级"]
    if descNode then
        local maxLevel = skill.maxLevel or 1
        descNode.Title = string.format("%d/%d", skillLevel, maxLevel)
    end
end

function CardsGui:SetSkillLevelSubCardFrame(cardFrame, skill)
    local severSkill = self.ServerSkills[skill.name]
    local skillLevel = 0
    if severSkill then
        skillLevel = severSkill.level
    end

    -- 设置技能等级
    local levelNode = cardFrame["强化等级"]
    if levelNode then
        levelNode.Title = "强化等级:" .. skillLevel
    end

    -- 设置图标
    if skill.icon and skill.icon ~= "" then
        local iconNode = cardFrame["图标"]
        if iconNode then
            iconNode.Icon = skill.icon
        end
    end

    -- 设置技能名称
    local nameNode = cardFrame["副卡名字"]
    if nameNode then
        nameNode.Title = skill.name
    end

    -- 设置new标识的可见性
    local newnode = cardFrame["new"]
    if newnode then
        newnode.Visible = false
    end
end

-- 为技能树克隆纵列表
function CardsGui:CloneVerticalListsForSkillTrees(skillMainTrees)
    local verticalListTemplate = self:Get("框体/主卡/加点框/纵列表", ViewList)
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
            self:RegisterSkillCardButton(mainCardFrame, mainCardNode, 0, 2)
        end

        local listTemplate = clonedVerticalList["列表_1"]
        if not listTemplate then return end

        -- ===== 修复后的DAG处理算法 =====
        local nodeDepth = {}         -- 节点深度
        local nodePositions = {}     -- 节点位置
        local layers = {}            -- 按深度分组的节点
        local layerNodes = {}        -- 存储每层的节点和位置信息
        local parentMap = {}         -- 父节点映射
        local processed = {}         -- 标记已处理的节点，防止重复处理

        -- 初始化根节点
        nodeDepth[skillTree] = 0
        nodePositions[skillTree] = 2
        layers[0] = {skillTree}
        layerNodes[0] = {{node = skillTree, position = 2}}
        processed[skillTree] = true  -- 标记根节点已处理

        -- 添加根节点的所有直接子节点到队列
        local queue = {}
        for _, child in ipairs(skillTree.children) do
           if not processed[child] then  -- 只添加未处理的节点
               table.insert(queue, child)
               parentMap[child] = {skillTree}
               processed[child] = true   -- 立即标记为已处理，防止重复入队
           else
               -- 如果子节点已经处理过，只更新其父节点关系
               parentMap[child] = parentMap[child] or {}
               table.insert(parentMap[child], skillTree)
           end
        end

        -- BFS遍历所有节点
        while #queue > 0 do
           local node = table.remove(queue, 1)
           local parents = parentMap[node] or {}

           -- 计算节点深度 = 所有父节点最大深度+1
           local maxParentDepth = -1
           for _, parent in ipairs(parents) do
               if nodeDepth[parent] and nodeDepth[parent] > maxParentDepth then
                   maxParentDepth = nodeDepth[parent]
               end
           end
           local depth = maxParentDepth + 1
           nodeDepth[node] = depth

           -- 添加到层级（每个节点只添加一次）
           layers[depth] = layers[depth] or {}
           table.insert(layers[depth], node)

           -- 初始化当前层的节点位置表
           layerNodes[depth] = layerNodes[depth] or {}

           -- ===== 改进的位置分配算法 =====
           -- 1. 收集所有父节点位置
           local parentPositions = {}
           for _, parent in ipairs(parents) do
               if nodePositions[parent] then
                   table.insert(parentPositions, nodePositions[parent])
               end
           end
           -- 2. 计算理想位置（父节点位置的中位数）
           table.sort(parentPositions)
           local medianPos = parentPositions[math.ceil(#parentPositions/2)] or 2
           -- 3. 检查同层是否已有相同位置的节点
           local targetPos = medianPos
           local positionTaken = {}
           for _, existingItem in ipairs(layerNodes[depth]) do
               positionTaken[existingItem.position] = true
           end
           -- 4. 优化的特殊处理：根据当前层节点数量进行位置分配
           local currentLayerNodes = layerNodes[depth] or {}
           local currentLayerCount = #currentLayerNodes

           if currentLayerCount == 0 then
               -- 当前层的第一个节点，放在中间位置2
               targetPos = 2
           elseif currentLayerCount == 1 then
               -- 当前层已有一个节点，这是第二个节点
               local firstNodePos = currentLayerNodes[1].position
               if firstNodePos == 2 then
                   -- 第一个节点在中间，将其调整到位置1，当前节点设为位置3
                   currentLayerNodes[1].position = 1
                   nodePositions[currentLayerNodes[1].node] = 1
                   targetPos = 3
               else
                   -- 第一个节点不在中间，根据其位置决定当前节点位置
                   if firstNodePos == 1 then
                       targetPos = 3  -- 第一个在左，当前放右
                   else -- firstNodePos == 3
                       targetPos = 1  -- 第一个在右，当前放左
                   end
               end
           else
               -- 当前层已有两个或更多节点，使用原来的位置分配逻辑
               if positionTaken[targetPos] then
                   local candidatePositions = {}
                   for pos = 1, 3 do
                       if not positionTaken[pos] then
                           table.insert(candidatePositions, pos)
                       end
                   end
                   if #candidatePositions > 0 then
                       table.sort(candidatePositions, function(a, b)
                           return math.abs(a - medianPos) < math.abs(b - medianPos)
                       end)
                       targetPos = candidatePositions[1]
                   end
               end
           end
           -- 5. 分配最终位置
           nodePositions[node] = targetPos
           -- 存储当前节点到层节点表
           table.insert(layerNodes[depth], {node = node, position = targetPos})

           -- ===== 处理子节点（防止重复） =====
           for _, child in ipairs(node.children) do
               if not processed[child] then
                   -- 子节点未处理过，加入队列
                   table.insert(queue, child)
                   parentMap[child] = {node}
                   processed[child] = true  -- 立即标记为已处理
               else
                   -- 子节点已处理过，只更新父节点关系
                   parentMap[child] = parentMap[child] or {}
                   table.insert(parentMap[child], node)
               end
           end
        end

        -- ===== 渲染UI层级 =====
        local maxDepth = 0
        for depth in pairs(layers) do
            if depth > maxDepth then maxDepth = depth end
        end

        -- 打印层节点信息（调试用）
        local hierarchyInfo = string.format("技能树层级信息: %s\n", mainSkillName)
        for depth = 0, maxDepth do
            if layerNodes[depth] then
                hierarchyInfo = hierarchyInfo .. string.format("深度 %d: ", depth)
                for _, item in ipairs(layerNodes[depth]) do
                    hierarchyInfo = hierarchyInfo .. string.format("%s [%s] (位置 %d), ", item.node.data.name, tostring(item.node), item.position)
                end
                hierarchyInfo = hierarchyInfo .. "\n"
            end
        end
        gg.log(hierarchyInfo)

        for depth = 0, maxDepth do
            if layers[depth] then
                if depth == 0 then
                    -- 根节点已在主卡框处理
                else
                    local clonedList = listTemplate:Clone()
                    clonedList.Name = "列表_" .. depth
                    clonedList.Parent = clonedVerticalList

                    -- 初始化所有卡框为不可见
                    for i = 1, 3 do
                        local cardFrame = clonedList["卡框_" .. i]
                        if cardFrame then cardFrame.Visible = false end
                    end

                    -- 使用 layerNodes 表来渲染节点
                    for _, item in ipairs(layerNodes[depth] or {}) do
                        local node = item.node
                        local position = item.position

                        if position and position >= 1 and position <= 3 then
                            local cardFrame = clonedList["卡框_" .. position]
                            if cardFrame then
                                cardFrame.Visible = true
                                cardFrame.Name = node.data.name
                                self:RegisterSkillCardButton(cardFrame, node.data, depth, position)

                                -- ===== 箭头处理逻辑 =====
                                -- 获取所有箭头元素
                                local upRightArrow = cardFrame["上右"]
                                local downRightArrow = cardFrame["下右"]
                                local rightArrow = cardFrame["箭头右"]

                                -- 初始化所有箭头为不可见
                                if upRightArrow then upRightArrow.Visible = false end
                                if downRightArrow then downRightArrow.Visible = false end
                                if rightArrow then rightArrow.Visible = false end

                                -- 如果没有子节点，不需要显示箭头
                                if #node.children == 0 then

                                    -- 这里直接用空语句代替即可
                                else
                                    -- 获取直接子节点的位置
                                    local childPositions = {}
                                    for _, child in ipairs(node.children) do
                                        if layerNodes[depth + 1] then
                                            for _, childItem in ipairs(layerNodes[depth + 1]) do
                                                if childItem.node == child then
                                                    table.insert(childPositions, childItem.position)
                                                    break
                                                end
                                            end
                                        end
                                    end

                                    -- 根据当前节点位置和子节点位置显示箭头
                                    for _, childPos in ipairs(childPositions) do
                                        if position == 1 then -- 当前节点在左边
                                            if childPos == 1 then
                                                if rightArrow then rightArrow.Visible = true end
                                            elseif childPos == 2 then
                                                if downRightArrow then downRightArrow.Visible = true end
                                            else -- childPos == 3
                                                if downRightArrow then downRightArrow.Visible = true end
                                            end
                                        elseif position == 2 then -- 当前节点在中间
                                            if childPos == 1 then
                                                if upRightArrow then upRightArrow.Visible = true end
                                            elseif childPos == 2 then
                                                if rightArrow then rightArrow.Visible = true end
                                            else -- childPos == 3
                                                if downRightArrow then downRightArrow.Visible = true end
                                            end
                                        else -- position == 3 当前节点在右边
                                            if childPos == 1 then
                                                if upRightArrow then upRightArrow.Visible = true end
                                            elseif childPos == 2 then
                                                if upRightArrow then upRightArrow.Visible = true end
                                            else -- childPos == 3
                                                if rightArrow then rightArrow.Visible = true end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        listTemplate:Destroy()
        local verticalList = ViewList.New(clonedVerticalList, self, "框体/主卡/加点框/" .. mainSkillName)
        self.skillLists[mainSkillName] = verticalList
    end

    if verticalListTemplate and verticalListTemplate.node then
        verticalListTemplate.node:Destroy()
    end
end

-- 动态生成副卡列表
---@params   SubskillList 副卡列表
function CardsGui:LoadSubCardsAndClone(serverSubskillDic)
    gg.log("副卡的技能数据SubskillList",serverSubskillDic)
    local qualityList = uiConfig.qualityList or {"UR", "SSR", "SR", "R", "N"}
    local subListTemplate = self:Get('框体/副卡/副卡列/副卡列表', ViewList) ---@type ViewList

    local subSkillsByQuality = {}
    for _, quality in ipairs(qualityList) do
        subSkillsByQuality[quality] = {}
    end

    -- 分类统计
    for name, skilldic in pairs(serverSubskillDic) do
        local skill = skilldic.data
        if skill.skillType == 1 and skill.isEntrySkill then
            local quality = skill.quality or "N"
            if subSkillsByQuality[quality] then
                table.insert(subSkillsByQuality[quality], skill)
            end
        end
    end
    -- 克隆副卡品级列表
    for _, quality in ipairs(qualityList) do
        local listClone = subListTemplate.node:Clone()
        local qualityName = "副卡列表_" .. quality
        listClone.Name = qualityName
        listClone.Parent = subListTemplate.node.Parent
        listClone.Visible = false
        -- 设置LineCount为该品质副卡数量
        local count = #subSkillsByQuality[quality]
        listClone.LineCount = count > 0 and count or 1
        self.subQualityLists[quality] = ViewList.New(listClone, self, "框体/副卡/副卡列/" .. qualityName)
        -- 清空模板下的副卡槽
        for _, child in ipairs(listClone.Children) do
            if string.find(child.Name, "副卡槽") then
                child:Destroy()
            end
        end
    end

    -- 获取副卡模板
    local existingSubCard = nil
    -- 直接使用固定的副卡模板路径，而不是从qualityList中查找
    local subCardTemplate = self:Get('框体/副卡/副卡列/副卡列表/副卡槽_1', ViewButton)
    if subCardTemplate and subCardTemplate.node then
        existingSubCard = subCardTemplate.node
    end

    if not existingSubCard then return end
    -- 遍历副卡数据，按品级分组
    for name, skilldic in pairs(serverSubskillDic) do
        local skill = skilldic.data
        local serverdata = skilldic.serverdata
        gg.log("serverdata",serverdata)
        if skill.skillType == 1 and skill.isEntrySkill then
            local quality = skill.quality
            local listNode = self.subQualityLists[quality]
            if listNode then
                local clonedNode = existingSubCard:Clone()
                clonedNode.Name = skill.name
                clonedNode.Parent = listNode.node
                clonedNode.Visible = true
                -- 使用统一的UI设置函数
                self:SetSkillLevelSubCardFrame(clonedNode, skill)
                local subCardButton = self:RegisterSubCardButton(clonedNode, skill, serverdata)
                self.subCardButtondict[skill.name] = subCardButton
            end
        end
    end
    subListTemplate.node.Visible =false
    print("副卡全部生成完毕，模板已销毁")
end

function CardsGui:BindQualityButtonEvents()
    local qualityListMap = uiConfig.qualityListMap or {}
    for btnName, quality in pairs(qualityListMap) do
        local qualityBtn = self:Get("品质列表/"  .. btnName, ViewButton)
        if qualityBtn then
            qualityBtn.clickCb = function()
                if self.currentCardType == "副卡" or self.currentCardType == "sub" then
                    -- 副卡品级列表显示
                    if self.subQualityLists then
                        for q, listNode in pairs(self.subQualityLists) do
                            listNode:SetVisible(q == quality)
                        end
                    end
                end
            end
        end
    end
end

-- 注册副卡技能卡片的ViewButton（简化版）
function CardsGui:RegisterSubCardButton(cardFrame, skill, serverData)
    gg.log("RegisterSubCardButton",cardFrame, skill, serverData)
    local viewButton = ViewButton.New(cardFrame, self, nil, "图标底图")
    viewButton.extraParams = {
        skillId = skill.name,
        serverData = serverData
    }

    viewButton.clickCb = function(ui, button)
        local skillId = button.extraParams.skillId
        local skill = SkillTypeConfig.Get(skillId)
        local serverData = button.extraParams.serverData
        local skillLevel = serverData and serverData.level or 0
        -- 更新副卡属性面板
        local attributeButton = self.subCardAttributeButton.node
        local nameNode = attributeButton["卡片名字"]
        if nameNode then
            nameNode.Title = skill.displayName
        end

        local descNode = attributeButton["卡片介绍"]
        if descNode then
            descNode.Title = skill.description
        end

        -- 更新强化前后属性
        local descPreTitleNode = attributeButton["列表_强化前"]["强化标题"]
        local descPostTitleNode = attributeButton["列表_强化后"]["强化标题"]
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
        else
            descPostTitleNode.Title = "已满级"
            descPostNode.Title = ""
        end
        -- 设置按钮状态
        self.SubcardEnhancementButton:SetTouchEnable(skillLevel < skill.maxLevel)
        self.currentSubCardButtonName = viewButton
    end

    return viewButton
end

-- 处理单个新技能添加
function CardsGui:HandleNewSkillAdd(data)
    gg.log("收到新技能添加数据", data)
    if not data or not data.data then
        gg.log("新技能数据格式错误 - 缺少data字段")
        return
    end

    local responseData = data.data
    local skillName = responseData.skillName
    local skillLevel = responseData.level or 0
    local skillSlot = responseData.slot or 0

    if not skillName then
        gg.log("新技能数据格式错误 - 缺少skillName")
        return
    end

    -- 构建技能数据
    local skillData = {
        level = skillLevel,
        slot = skillSlot,
        skill = skillName
    }

    -- 更新服务端技能数据
    self.ServerSkills[skillName] = skillData

    -- 记录已装备的技能
    if skillSlot > 0 then
        self.equippedSkills[skillSlot] = skillName
    end

    -- 获取技能配置
    local skillType = SkillTypeConfig.Get(skillName)
    if not skillType or not skillType.isEntrySkill then
        gg.log("技能不是入口技能，跳过UI生成", skillName)
        return
    end

    -- 根据技能类型生成对应的卡片
    if skillType.skillType == 0 then
        -- 主卡技能
        self:AddNewMainCardSkill(skillName, skillType, skillData)
    elseif skillType.skillType == 1 then
        -- 副卡技能
        self:AddNewSubCardSkill(skillName, skillType, skillData)
    end


    gg.log("新技能添加完成", skillName, "等级:", skillLevel, "槽位:", skillSlot)
end

-- 添加新的主卡技能
function CardsGui:AddNewMainCardSkill(skillName, skillType, skillData)
    gg.log("添加新主卡技能", skillName)

    -- 检查是否已经存在该技能按钮
    if self.skillButtons[skillName] then
        gg.log("主卡技能按钮已存在，跳过创建", skillName)
        return
    end

    -- 获取选择列表模板
    local selectionList = self.selectionList
    if not selectionList then
        gg.log("找不到主卡选择列表")
        return
    end

    -- 计算新的索引位置
    local existingCount = 0
    for _ in pairs(self.skillButtons) do
        existingCount = existingCount + 1
    end
    local newIndex = existingCount + 1

    -- 创建新的主卡选择按钮
    local newChild = selectionList:GetChild(newIndex)
    if newChild then
        newChild.extraParams = newChild.extraParams or {}
        newChild.extraParams["skillId"] = skillName
        newChild.node.Name = skillType.name

        -- 设置图标
        if skillType.icon and skillType.icon ~= "" then
            local iconNode = newChild.node['图标']
            if iconNode then
                iconNode.Icon = skillType.icon
            end
        end

        -- 创建按钮事件
        local clonedButton = ViewButton.New(newChild.node, self, nil, "卡框背景")
        clonedButton.extraParams = {skillId = skillName}
        self.skillButtons[skillName] = clonedButton

        clonedButton.clickCb = function(ui, button)
            local skillId = button.extraParams["skillId"]
            local currentList = self.skillLists[skillId]
            if currentList then
                for name, vlist in pairs(self.skillLists) do
                    vlist:SetVisible(name == skillId)
                end
            end
        end

        -- 创建对应的技能树
        self:CreateSkillTreeForNewMainCard(skillName, skillType)

        gg.log("新主卡技能按钮创建完成", skillName)
    else
        gg.log("无法获取新的列表项，可能需要扩展列表")
    end
end

-- 为新主卡创建技能树
function CardsGui:CreateSkillTreeForNewMainCard(skillName, skillType)
    -- 构建单个技能的技能树
    local skillTree = SkillTypeUtils.BuildSingleSkillTree(skillName)
    if not skillTree then
        gg.log("无法构建技能树", skillName)
        return
    end

    -- 获取纵列表模板
    local verticalListParent = self:Get("框体/主卡/加点框", ViewComponent)
    if not verticalListParent then
        gg.log("找不到纵列表父节点")
        return
    end

    -- 创建新的纵列表
    local firstVerticalList = nil
    for name, vlist in pairs(self.skillLists) do
        firstVerticalList = vlist.node
        break
    end

    if firstVerticalList then
        local clonedVerticalList = firstVerticalList:Clone()
        clonedVerticalList.Name = skillName
        clonedVerticalList.Parent = verticalListParent.node
        clonedVerticalList.Visible = false

        -- 设置主卡框
        local mainCardFrame = clonedVerticalList["主卡框"]
        if mainCardFrame then
            self:RegisterSkillCardButton(mainCardFrame, skillType, 0, 2)
        end

        -- 清理并重新创建技能树层级
        self:CloneSkillTreeLevelsForSingleTree(clonedVerticalList, skillTree)

        -- 注册到技能列表
        local verticalList = ViewList.New(clonedVerticalList, self, "框体/主卡/加点框/" .. skillName)
        self.skillLists[skillName] = verticalList

        gg.log("新主卡技能树创建完成", skillName)
    end
end

-- 为单个技能树克隆层级（简化版本）
function CardsGui:CloneSkillTreeLevelsForSingleTree(verticalListNode, skillTree)
    -- 清理现有的列表项（除了主卡框）
    for _, child in ipairs(verticalListNode:GetChildren()) do
        if string.find(child.Name, "列表_") then
            child:Destroy()
        end
    end

    -- 使用简化的层级处理（这里可以复用原有的DAG算法逻辑）
    -- 为了简化，我们先实现一个基础版本
    local listTemplate = verticalListNode:FindFirstChild("列表_1")
    if not listTemplate then
        gg.log("找不到列表模板")
        return
    end

    -- 这里可以复用原有的CloneVerticalListsForSkillTrees中的DAG算法
    -- 暂时使用简化版本处理单个技能树
    gg.log("单个技能树层级创建完成")
end

-- 添加新的副卡技能
function CardsGui:AddNewSubCardSkill(skillName, skillType, skillData)
    gg.log("添加新副卡技能", skillName, skillType.quality)

    -- 检查是否已经存在该技能按钮
    if self.subCardButtondict[skillName] then
        gg.log("副卡技能按钮已存在，跳过创建", skillName)
        return
    end

    local quality = skillType.quality or "N"
    local qualityList = self.subQualityLists[quality]

    if not qualityList then
        gg.log("找不到对应品质的副卡列表", quality)
        return
    end

    -- 获取副卡模板
    local existingSubCard = nil
    -- 直接使用固定的副卡模板路径，而不是从qualityList中查找
    local subCardTemplate = self:Get('框体/副卡/副卡列/副卡列表/副卡槽_1', ViewButton)
    if subCardTemplate and subCardTemplate.node then
        existingSubCard = subCardTemplate.node
    end

    if existingSubCard then
        -- 克隆新的副卡节点
        local clonedNode = existingSubCard:Clone()
        clonedNode.Name = skillType.name
        clonedNode.Parent = qualityList.node
        clonedNode.Visible = true

        -- 设置副卡UI
        self:SetSkillLevelSubCardFrame(clonedNode, skillType)

        -- 注册副卡按钮
        local subCardButton = self:RegisterSubCardButton(clonedNode, skillType, skillData)
        self.subCardButtondict[skillName] = subCardButton

        -- 更新列表的LineCount
        local currentCount = qualityList.node.LineCount or 0
        qualityList.node.LineCount = currentCount + 1

        gg.log("新副卡技能创建完成", skillName)
    else
        gg.log("找不到副卡模板")
    end
end

return CardsGui.New(script.Parent, uiConfig)

