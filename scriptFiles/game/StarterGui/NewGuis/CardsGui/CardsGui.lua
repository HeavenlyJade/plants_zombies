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

--[[
=== 新主卡生成逻辑说明 ===

1. 初始化阶段（OnInit）：
   - LoadMainCardConfig(): 从配置中加载所有可能的主卡技能
   - InitializeMainCardButtons(): 预生成所有主卡按钮，默认为禁用状态（灰色/不可点击）
   - LoadMainCardsAndClone(): 预生成所有主卡对应的技能树

2. 服务端数据同步阶段（HandleSkillSync）：
   - BindMainCardButtonsWithServerData(): 根据服务端返回的技能数据激活对应按钮
   - 激活的按钮变为可点击状态，恢复正常颜色
   - 绑定点击事件，可以展开对应的技能树

3. 动态排序显示：
   - SortAndUpdateMainCardLayout(): 对按钮进行排序
   - 第一优先级：服务端返回的已激活技能（排在前面）
   - 第二优先级：配置中存在但未激活的技能（排在后面）
   - 实时重新排列UI元素位置

4. 新技能动态添加（HandleNewSkillAdd）：
   - 如果是配置中已存在的技能：激活对应的预生成按钮
   - 如果是配置中不存在的技能：动态创建新的按钮和技能树
   - 自动触发重新排序

5. 数据结构：
   - mainCardButtonConfig: 存储所有配置的主卡信息
   - mainCardButtonStates: 存储每个按钮的状态（位置、激活状态、服务端数据等）
   - activatedMainCards: 已激活的主卡列表（用于排序）
   - configMainCards: 配置中的主卡列表（用于排序）

--]]

local uiConfig = {
    uiName = "CardsGui",
    layer = 3,
    hideOnInit = true,
    qualityList = {"UR", "SSR", "SR", "R", "N","ALL"},
    qualityListMap = {["品质_5"]="N", ["品质_4"]="R", ["品质_3"]="SR", ["品质_2"]="SSR", ["品质_1"]="UR",["品质_6"]="ALL" },
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
    self.mainCardUnEquipButton = self:Get("框体/主卡属性/主卡_卸下", ViewButton) ---@type ViewButton
    self.SubcardEnhancementButton = self:Get("框体/副卡属性/副卡_强化", ViewButton) ---@type ViewButton
    self.SubcardAllEnhancementButton = self:Get("框体/副卡属性/副卡一键强化", ViewButton) ---@type ViewButton
    self.SubcardEquipButton = self:Get("框体/副卡属性/副卡_装备", ViewButton) ---@type ViewButton
    self.SubcardUnEquipButton = self:Get("框体/副卡属性/副卡_卸下", ViewButton) ---@type ViewButton


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

    -- === 新增的主卡管理数据结构 ===
    self.mainCardButtonConfig = {} ---@type table<string, table> -- 存储所有配置的主卡信息
    self.mainCardButtonStates = {} ---@type table<string, table> -- 存储按钮状态和位置信息
    -- 格式: {skillName = {button = ViewButton, position = number, activated = boolean, serverData = table, configData = table}}
    self.configMainCards = {} ---@type string[] -- 配置中的主卡列表（排序用）

    -- 当前点击主卡技能树的按钮
    ---@type ViewButton
    self.currentMCardButtonName = nil
    self.currentSubCardButtonName = nil
    -- 当前显示的卡片类型 ("主卡" 或 "副卡")
    self.currentCardType = "主卡"

    -- === 副卡管理数据结构（参考主卡逻辑）===
    self.subCardButtonConfig = {} ---@type table<string, table> -- 存储所有配置的副卡信息
    self.subCardButtonStates = {} ---@type table<string, table> -- 存储副卡按钮状态
    -- 格式: {skillName = {button = ViewButton, position = number, serverUnlocked = boolean, serverData = table, configData = table}}
    self.configSubCards = {} ---@type string[] -- 配置中的副卡列表（排序用）
    self.closeButton.clickCb = function ()
        self:Close()
    end

    self:RegisterMainCardFunctionButtons()
    self:RegisterCardButtons()
    -- 设置默认显示主卡
    self:SwitchToCardType(self.currentCardType)

    -- === 新的主卡初始化流程 ===
    self:LoadMainCardConfig()
    self:InitializeMainCardButtons()
    self:LoadMainCardsAndClone()

    -- === 新的副卡初始化流程 ===
    self:LoadSubCardConfig()
    self:InitializeSubCardButtons()

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

    -- 监听技能装备响应
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.EQUIP, function(data)
        self:OnSkillEquipResponse(data)
    end)

    -- 监听技能卸下响应
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.UNEQUIP, function(data)
        self:OnSkillUnequipResponse(data)
    end)

    -- 初始化研究装备按钮状态（默认隐藏）
    self:InitializeFunctionButtonsVisibility()
end

-- === 新增方法：加载主卡配置 ===
function CardsGui:LoadMainCardConfig()
    -- gg.log("开始加载主卡配置")

    -- 强制重新构建技能森林以确保使用最新的修复逻辑
    local skillMainTrees = SkillTypeUtils.BuildSkillForest(0)
    SkillTypeUtils.lastForest = skillMainTrees

    -- 存储配置数据
    for skillName, rootNode in pairs(skillMainTrees) do
        local skillType = rootNode.data
        self.mainCardButtonConfig[skillName] = {
            skillType = skillType,
            rootNode = rootNode
        }
        table.insert(self.configMainCards, skillName)

        -- 初始化按钮状态
        self.mainCardButtonStates[skillName] = {
            button = nil,
            position = #self.configMainCards,
            serverUnlocked = false,  -- 是否在服务端解锁
            isEquipped = false,      -- 是否已装备 (新增)
            equipSlot = 0,          -- 装备槽位 (新增)
            serverData = nil,
            configData = skillType
        }
    end

end

-- === 新增方法：初始化所有主卡按钮（禁用状态）===
function CardsGui:InitializeMainCardButtons()
    -- gg.log("开始初始化主卡按钮")

    local ListTemplate = self:Get('框体/主卡/选择列表/列表', ViewList) ---@type ViewList

    local index = 1
    for _, skillName in ipairs(self.configMainCards) do
        local skillConfig = self.mainCardButtonConfig[skillName]
        local skillType = skillConfig.skillType

        local child = ListTemplate:GetChild(index)
        child.extraParams = child.extraParams or {}
        child.extraParams["skillId"] = skillName
        child.node.Name = skillType.name

        -- 设置图标
        if skillType.icon and skillType.icon ~= "" then
            local iconNode = child.node['图标']
            if iconNode then
                iconNode.Icon = skillType.icon
            end
        end

        -- 创建按钮并直接绑定事件（所有按钮都可点击）
        local button = ViewButton.New(child.node, self, nil, "卡框背景")
        button.extraParams = {skillId = skillName}
        button:SetTouchEnable(true) -- 可点击

        -- 手动设置为灰色（未解锁状态）
        button.img.Grayed = true

        button.clickCb = function(ui, button)
            local skillId = button.extraParams["skillId"]
            self:ShowSkillTree(skillId)

            -- 点击主卡选择按钮时显示属性面板（如果技能树有内容的话）
            if self.skillLists[skillId] then
                self.attributeButton:SetVisible(true)
            end
        end

        -- 存储按钮引用
        self.skillButtons[skillName] = button
        self.mainCardButtonStates[skillName].button = button
        self.mainCardButtonStates[skillName].position = index

        index = index + 1
    end


    -- 调试：立即检查初始化后的按钮状态
end

-- === 新增方法：初始化功能按钮可见性 ===
function CardsGui:InitializeFunctionButtonsVisibility()
    -- 主卡属性面板默认隐藏（只有点击具体主卡时才显示）
    self.attributeButton:SetVisible(false)

    -- 副卡属性面板默认隐藏（只有点击具体副卡时才显示）
    self.subCardAttributeButton:SetVisible(false)

    -- 主卡功能按钮默认隐藏
    self.confirmPointsButton:SetVisible(false)
    self.EquipmentSkillsButton:SetVisible(false)

    if self.mainCardUnEquipButton then
        self.mainCardUnEquipButton:SetVisible(false)
    end

    -- 副卡所有功能按钮默认隐藏
    self.SubcardEnhancementButton:SetVisible(false)

    if self.SubcardAllEnhancementButton then
        self.SubcardAllEnhancementButton:SetVisible(false)
    end

    if self.SubcardEquipButton then
        self.SubcardEquipButton:SetVisible(false)
    end

    if self.SubcardUnEquipButton then
        self.SubcardUnEquipButton:SetVisible(false)
    end

    gg.log("功能按钮初始化完成，主卡和副卡属性面板默认隐藏")
end


-- === 新增方法：更新主卡装备状态 ===
function CardsGui:UpdateMainCardEquipStatus(skillName, serverData)
    local buttonState = self.mainCardButtonStates[skillName]
    if buttonState and serverData then
        local equipSlot = serverData.slot or 0
        buttonState.isEquipped = equipSlot > 0
        buttonState.equipSlot = equipSlot

        -- gg.log("更新主卡装备状态:", skillName, "槽位:", equipSlot, "已装备:", buttonState.isEquipped)
    end
end

-- === 新增方法：设置主卡装备视觉效果 ===
function CardsGui:SetMainCardEquippedVisual(skillName, isEquipped)
    local buttonState = self.mainCardButtonStates[skillName]
    if not buttonState or not buttonState.button then
        return
    end

    local button = buttonState.button

    if isEquipped then
        -- 已装备：添加特殊视觉效果（例如边框发光、角标等）
        -- 这里可以根据UI设计添加具体的视觉效果
        -- 例如：设置特殊的边框颜色、添加装备角标等

        -- 示例：可以通过修改按钮的某个子节点来显示装备状态
        local equipMark = button.node:FindFirstChild("装备标记")
        if equipMark then
            equipMark.Visible = true
        end

        -- gg.log("设置主卡装备视觉效果:", skillName, "已装备")
    else
        -- 未装备：清除特殊视觉效果
        local equipMark = button.node:FindFirstChild("装备标记")
        if equipMark then
            equipMark.Visible = false
        end

        -- gg.log("清除主卡装备视觉效果:", skillName, "未装备")
    end
end

-- === 新增工具方法：检查主卡是否已装备 ===
function CardsGui:IsMainCardEquipped(skillName)
    local buttonState = self.mainCardButtonStates[skillName]
    return buttonState and buttonState.isEquipped or false
end

-- === 新增工具方法：获取主卡装备槽位 ===
function CardsGui:GetMainCardEquipSlot(skillName)
    local buttonState = self.mainCardButtonStates[skillName]
    return buttonState and buttonState.equipSlot or 0
end

-- === 修改方法：处理服务端主卡数据（支持装备状态）===
function CardsGui:ProcessServerMainCardData(serverSkillMainTrees)
    -- gg.log("开始处理服务端主卡数据")

    -- 首先确保所有主卡按钮的灰色状态正确
    for _, skillName in ipairs(self.configMainCards) do
        local buttonState = self.mainCardButtonStates[skillName]
        if buttonState and buttonState.button then
            -- 检查是否在服务端数据中
            if serverSkillMainTrees[skillName] then
                -- 标记为服务端已解锁
                buttonState.serverUnlocked = true
                buttonState.serverData = serverSkillMainTrees[skillName]

                -- 更新装备状态
                self:UpdateMainCardEquipStatus(skillName, self.ServerSkills[skillName])

                -- 恢复按钮正常颜色（已解锁）
                buttonState.button.img.Grayed = false

                -- 设置装备状态的视觉反馈
                self:SetMainCardEquippedVisual(skillName, buttonState.isEquipped)

                -- gg.log("✅ 主卡已解锁，恢复正常颜色:", skillName, "已装备:", buttonState.isEquipped)
            else
                -- 确保未解锁的主卡保持灰色
                buttonState.serverUnlocked = false
                buttonState.isEquipped = false
                buttonState.equipSlot = 0
                buttonState.serverData = nil
                buttonState.button.img.Grayed = true

                -- 清除装备视觉效果
                self:SetMainCardEquippedVisual(skillName, false)

                -- gg.log("⚫ 主卡未解锁，保持灰色:", skillName)
            end
        end
    end

    -- gg.log("服务端主卡数据处理完成")

    -- 重新排序主卡按钮：已装备 > 已解锁未装备 > 未解锁
    self:SortAndUpdateMainCardLayout()

end

-- === 新增方法：排序和更新主卡布局 ===
function CardsGui:SortAndUpdateMainCardLayout()
    -- gg.log("开始重新排序主卡按钮")

    -- 使用table.sort进行排序：已解锁的排在前面
    local sortedCards = {}
    for _, skillName in ipairs(self.configMainCards) do
        table.insert(sortedCards, skillName)
    end

    table.sort(sortedCards, function(a, b)
        local aState = self.mainCardButtonStates[a]
        local bState = self.mainCardButtonStates[b]

        local aEquipped = aState and aState.isEquipped or false
        local bEquipped = bState and bState.isEquipped or false
        local aUnlocked = aState and aState.serverUnlocked or false
        local bUnlocked = bState and bState.serverUnlocked or false

        -- 第一优先级：已装备
        if aEquipped and not bEquipped then
            return true
        elseif not aEquipped and bEquipped then
            return false
        -- 第二优先级：已解锁但未装备
        elseif aUnlocked and not bUnlocked then
            return true
        elseif not aUnlocked and bUnlocked then
            return false
        else
            -- 同级保持原顺序
            return false
        end
    end)

    -- 统计并输出排序结果
    local equippedCount = 0
    local unlockedCount = 0
    local lockedCount = 0
    for _, skillName in ipairs(sortedCards) do
        local buttonState = self.mainCardButtonStates[skillName]
        if buttonState then
            if buttonState.isEquipped then
                equippedCount = equippedCount + 1
            elseif buttonState.serverUnlocked then
                unlockedCount = unlockedCount + 1
            else
                lockedCount = lockedCount + 1
            end
        end
    end

    -- gg.log("排序结果: 已装备", equippedCount, "个, 已解锁未装备", unlockedCount, "个, 未解锁", lockedCount, "个")

    -- 重新创建按钮而不是移动现有按钮（避免LayoutOrder错误）
    self:RecreateMainCardButtonsInOrder(sortedCards)

    -- 更新配置列表的顺序（保持数据一致性）
    self.configMainCards = sortedCards

    -- gg.log("主卡按钮重新排序完成")
end

-- === 新增方法：按顺序重新创建主卡按钮 ===
function CardsGui:RecreateMainCardButtonsInOrder(sortedCards)
    -- gg.log("按新顺序重新创建主卡按钮")

    local ListTemplate = self:Get('框体/主卡/选择列表/列表', ViewList) ---@type ViewList
    if not ListTemplate then
        -- gg.log("错误：找不到主卡列表模板")
        return
    end

    -- 保存所有按钮的数据
    local buttonData = {}
    for _, skillName in ipairs(sortedCards) do
        local buttonState = self.mainCardButtonStates[skillName]
        if buttonState then
            buttonData[skillName] = {
                skillType = buttonState.configData,
                serverUnlocked = buttonState.serverUnlocked,
                isEquipped = buttonState.isEquipped,
                equipSlot = buttonState.equipSlot,
                serverData = buttonState.serverData
            }
        end
    end

    -- 清除现有的按钮引用（但不销毁节点，让ViewList管理）
    self.skillButtons = {}

    -- 按新顺序重新创建按钮
    for newIndex, skillName in ipairs(sortedCards) do
        local data = buttonData[skillName]
        if data and data.skillType then
            local skillType = data.skillType

            -- 获取对应位置的列表项
            local child = ListTemplate:GetChild(newIndex)
            if child then
                -- 更新节点属性
                child.extraParams = child.extraParams or {}
                child.extraParams["skillId"] = skillName
                child.node.Name = skillType.name

                -- 设置图标
                if skillType.icon and skillType.icon ~= "" then
                    local iconNode = child.node['图标']
                    if iconNode then
                        iconNode.Icon = skillType.icon
                    end
                end

                -- 创建新的按钮
                local button = ViewButton.New(child.node, self, nil, "卡框背景")
                button.extraParams = {skillId = skillName}
                button:SetTouchEnable(true) -- 可点击

                -- 设置灰色状态和装备视觉效果
                if data.serverUnlocked then
                    button.img.Grayed = false  -- 已解锁：正常颜色

                    -- 设置装备状态的视觉反馈
                    self:SetMainCardEquippedVisual(skillName, data.isEquipped)

                    -- gg.log("重新创建已解锁按钮:", skillName, "位置:", newIndex, "已装备:", data.isEquipped)
                else
                    button.img.Grayed = true   -- 未解锁：灰色

                    -- 清除装备视觉效果
                    self:SetMainCardEquippedVisual(skillName, false)

                    -- gg.log("重新创建未解锁按钮:", skillName, "位置:", newIndex)
                end

                -- 绑定点击事件
                button.clickCb = function(ui, button)
                    local skillId = button.extraParams["skillId"]
                    self:ShowSkillTree(skillId)
                end

                -- 更新存储
                self.skillButtons[skillName] = button
                self.mainCardButtonStates[skillName].button = button
                self.mainCardButtonStates[skillName].position = newIndex

                -- gg.log(string.format("重新创建按钮: %s -> 位置 %d (解锁: %s)",
                --     skillName, newIndex, tostring(data.serverUnlocked)))
            else
                -- gg.log("警告：无法获取位置", newIndex, "的列表项")
            end
        end
    end

    -- gg.log("主卡按钮重新创建完成")
end

-- 注册主卡功能按钮事件
function CardsGui:RegisterMainCardFunctionButtons()
    self.confirmPointsButton.clickCb = function (ui, button)
        local skillName = self.currentMCardButtonName.extraParams["skillId"]
        -- gg.log("主卡_研究发送升级了请求",skillName)
        gg.network_channel:FireServer({
            cmd = SkillEventConfig.REQUEST.UPGRADE,
            skillName = skillName
        })
    end
    self.EquipmentSkillsButton.clickCb = function (ui, button)
        -- gg.log("主卡_装备发送了装备的请求")
        gg.network_channel:FireServer({
            cmd = SkillEventConfig.REQUEST.EQUIP,
            skillName = self.currentMCardButtonName.extraParams["skillId"],

        })
    end

    if self.mainCardUnEquipButton then
        self.mainCardUnEquipButton.clickCb = function(ui, button)
            -- gg.log("主卡_卸下发送了请求")
            local skillName = self.currentMCardButtonName.extraParams["skillId"]
            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.UNEQUIP,
                skillName = skillName
            })
        end
    end
    if self.SubcardEnhancementButton then
        self.SubcardEnhancementButton.clickCb = function(ui, button)
            -- gg.log("副卡_强化发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]

            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.UPGRADE,
                skillName = skillName
            })
        end
    end
    if self.SubcardAllEnhancementButton then
        self.SubcardAllEnhancementButton.clickCb = function(ui, button)
            -- gg.log("副卡一键强化发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]

            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.UPGRADE_ALL,
                skillName = skillName

            })
        end
    end
    if self.SubcardEquipButton then
        self.SubcardEquipButton.clickCb = function(ui, button)
            -- gg.log("副卡_装备发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]
            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.EQUIP,
                skillName = skillName
            })
        end
    end

    if self.SubcardUnEquipButton then
        self.SubcardUnEquipButton.clickCb = function(ui, button)
            -- gg.log("副卡_卸下发送了请求")
            local skillName = self.currentSubCardButtonName.extraParams["skillId"]
            gg.network_channel:FireServer({
                cmd = SkillEventConfig.REQUEST.UNEQUIP,
                skillName = skillName
            })
        end
    end
end
-- 处理技能同步数据
function CardsGui:HandleSkillSync(data)
    -- gg.log("CardsGui获取来自服务端的技能数据", data)
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

    self:ProcessServerMainCardData(serverSkillMainTrees)
    self:ProcessServerSubCardData(serverSubskillDic)

    -- 更新所有技能按钮的灰色状态
    self:UpdateAllSkillButtonsGrayState()

    -- 更新主卡按钮状态（解锁状态和装备状态）
    self:UpdateMainCardButtonStates()

    -- 重新排序主卡布局（考虑解锁和装备状态的变化）
    self:SortAndUpdateMainCardLayout()

    -- 调试：输出技能列表状态
    -- self:DebugPrintSkillListsStatus()
end

function CardsGui:UpdateSkillTreeNodeDisplay(skillName)
    local skillTreeButton = self.mainCardButtondict[skillName]

    local skillType = SkillTypeConfig.Get(skillName)
    if skillTreeButton and skillTreeButton.node then
        self:SetSkillLevelOnCardFrame(skillTreeButton.node, skillType)

        -- 更新按钮的灰色状态
        local serverSkill = self.ServerSkills[skillName]
        if serverSkill then
            -- 技能已解锁：恢复正常颜色
            skillTreeButton.img.Grayed = false
            -- gg.log("技能解锁，恢复正常颜色:", skillName)
        else
            -- 技能未解锁：设置为灰色
            skillTreeButton.img.Grayed = true
            -- gg.log("技能未解锁，设置为灰色:", skillName)
        end
    end

end

function CardsGui:UpdateSubCardTreeNodeDisplay(skillName)
    local skillTreeButton = self.subCardButtondict[skillName]
    local skillType = SkillTypeConfig.Get(skillName)
    if skillTreeButton and skillTreeButton.node then
        self:SetSkillLevelSubCardFrame(skillTreeButton.node, skillType)
    end
end

-- === 新增方法：更新所有技能按钮的灰色状态 ===
function CardsGui:UpdateAllSkillButtonsGrayState()
    -- gg.log("开始更新所有技能按钮的灰色状态")

    -- 更新所有已创建的技能树按钮
    for skillName, skillButton in pairs(self.mainCardButtondict) do
        local serverSkill = self.ServerSkills[skillName]
        if serverSkill then
            -- 技能已解锁：恢复正常颜色
            skillButton.img.Grayed = false
            -- gg.log("✅ 技能已解锁，设为正常:", skillName)
        else
            -- 技能未解锁：设置为灰色
            skillButton.img.Grayed = true
            -- gg.log("⚫ 技能未解锁，设为灰色:", skillName)
        end
    end

    -- gg.log("技能按钮灰色状态更新完成")
end

-- === 新增方法：更新主卡按钮状态 ===
function CardsGui:UpdateMainCardButtonStates()
    gg.log("开始更新主卡按钮状态...")

    -- 遍历所有主卡按钮状态
    for skillName, buttonState in pairs(self.mainCardButtonStates) do
        local serverSkill = self.ServerSkills[skillName]

        -- 更新解锁状态
        buttonState.serverUnlocked = (serverSkill ~= nil)

        if serverSkill then
            -- 技能已解锁：更新装备状态和服务端数据
            buttonState.serverData = serverSkill
            self:UpdateMainCardEquipStatus(skillName, serverSkill)

            -- 更新按钮的灰色状态（如果按钮存在）
            if buttonState.button then
                buttonState.button.img.Grayed = false
            end

            gg.log("主卡状态已更新:", skillName, "解锁=true, 装备槽=" .. (serverSkill.slot or 0))
        else
            -- 技能未解锁：重置状态
            buttonState.serverData = nil
            buttonState.isEquipped = false
            buttonState.equipSlot = 0

            -- 更新按钮的灰色状态（如果按钮存在）
            if buttonState.button then
                buttonState.button.img.Grayed = true
            end

            gg.log("主卡状态已重置:", skillName, "解锁=false")
        end
    end

    gg.log("主卡按钮状态更新完成")
end


--- 处理技能学习/升级响应
function CardsGui:OnSkillLearnUpgradeResponse(response)
    -- gg.log("收到技能学习/升级响应", response)
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
        -- 副卡升级：更新副卡显示和按钮状态
        self:UpdateSubCardTreeNodeDisplay(skillName)

        -- 如果当前选中的是这个副卡，更新属性面板
        if self.currentSubCardButtonName and
           self.currentSubCardButtonName.extraParams.skillId == skillName then
            local buttonState = self.subCardButtonStates[skillName]
            local serverData = buttonState and buttonState.serverData
            local skillLevel = serverData and serverData.level or 0

            -- 重新更新属性面板（会自动处理按钮显示逻辑）
            self:UpdateSubCardAttributePanel(skillType, skillLevel, serverData)
        end

        -- gg.log("副卡升级完成，更新显示:", skillName, "新等级:", serverlevel)
    elseif skillType.skillType==0  then
        -- 主卡升级：更新主卡技能树显示和装备状态
        self:UpdateSkillTreeNodeDisplay(skillName)

        -- 检查并更新主卡装备状态
        local buttonState = self.mainCardButtonStates[skillName]
        if buttonState then
            local oldEquipped = buttonState.isEquipped
            self:UpdateMainCardEquipStatus(skillName, self.ServerSkills[skillName])

            -- 如果装备状态发生变化，重新排序
            if oldEquipped ~= buttonState.isEquipped then
                -- gg.log("主卡装备状态变化，触发重新排序:", skillName, "原状态:", oldEquipped, "新状态:", buttonState.isEquipped)
                self:SortAndUpdateMainCardLayout()
            end
        end
    end

    -- self:UpdateSkillDisplay()
end

-- === 新增方法：处理技能装备响应 ===
function CardsGui:OnSkillEquipResponse(response)
    -- gg.log("收到技能装备响应", response)
    local data = response.data
    local skillName = data.skillName
    local slot = data.slot

    -- 更新服务端技能数据
    local skillData = self.ServerSkills[skillName]
    if skillData then
        skillData.slot = slot
    else
        self.ServerSkills[skillName] = {
            level = data.level or 1,
            slot = slot,
            skill = skillName
        }
    end

    -- === 新增：处理原有装备技能的自动卸下 ===
    local originalSkillName = self.equippedSkills[slot]
    if originalSkillName and originalSkillName ~= skillName then
        -- 原有技能存在且不是当前技能，需要卸下
        gg.log("检测到槽位", slot, "原有技能:", originalSkillName, "将被新技能", skillName, "替换")

        -- 更新原有技能的服务端数据
        local originalSkillData = self.ServerSkills[originalSkillName]
        if originalSkillData then
            originalSkillData.slot = 0  -- 设置为未装备状态
        end

        -- 获取原有技能类型并更新其状态
        local originalSkillType = SkillTypeConfig.Get(originalSkillName)
        if originalSkillType and originalSkillType.skillType == 0 then
            -- 原有主卡：更新装备状态
            local originalButtonState = self.mainCardButtonStates[originalSkillName]
            if originalButtonState then
                self:UpdateMainCardEquipStatus(originalSkillName, originalSkillData)
                self:SetMainCardEquippedVisual(originalSkillName, false)
                gg.log("原有主卡技能状态已更新为未装备:", originalSkillName)
            end
        end
    end

    -- 更新装备槽数据（覆盖原有技能）
    self.equippedSkills[slot] = skillName

    -- 获取技能类型
    local skillType = SkillTypeConfig.Get(skillName)
    if skillType then
        if skillType.skillType == 0 then
            -- 主卡装备：更新主卡装备状态和重新排序
            local buttonState = self.mainCardButtonStates[skillName]
            if buttonState then
                self:UpdateMainCardEquipStatus(skillName, skillData)
                self:SetMainCardEquippedVisual(skillName, true)
                -- 无论是否有原有技能，都重新排序以确保所有按钮状态正确
                self:SortAndUpdateMainCardLayout()
                gg.log("主卡装备完成，界面重新排序:", skillName, "槽位:", slot)
            end

            -- 如果当前选中的是这个主卡，更新装备/卸下按钮显示
            if self.currentMCardButtonName and
               self.currentMCardButtonName.extraParams.skillId == skillName then
                -- 装备后：显示卸下按钮，隐藏装备按钮
                self.mainCardUnEquipButton:SetVisible(true)
                self.EquipmentSkillsButton:SetVisible(false)
                self.mainCardUnEquipButton:SetTouchEnable(true)

                -- gg.log("更新当前选中主卡的按钮状态: 显示卸下按钮")
            end

            -- gg.log("主卡装备完成，重新排序:", skillName, "槽位:", slot)
        elseif skillType.skillType == 1 then
            -- 副卡装备：更新副卡显示
            self:UpdateSubCardTreeNodeDisplay(skillName)

            -- 如果当前选中的是这个副卡，更新属性面板
            if self.currentSubCardButtonName and
               self.currentSubCardButtonName.extraParams.skillId == skillName then
                local buttonState = self.subCardButtonStates[skillName]
                if buttonState then
                    buttonState.serverData = skillData
                    buttonState.button.extraParams.serverData = skillData
                end

                local skillLevel = skillData and skillData.level or 0
                self:UpdateSubCardAttributePanel(skillType, skillLevel, skillData)
            end
            -- gg.log("副卡装备完成，更新显示:", skillName, "槽位:", slot)
        end
    end
end

-- === 新增方法：处理技能卸下响应 ===
function CardsGui:OnSkillUnequipResponse(response)
    -- gg.log("收到技能卸下响应", response)
    local data = response.data
    local skillName = data.skillName
    local oldSlot = nil

    -- 从装备槽中移除
    for slot, equippedSkillName in pairs(self.equippedSkills) do
        if equippedSkillName == skillName then
            oldSlot = slot
            self.equippedSkills[slot] = nil
            break
        end
    end

    -- 更新服务端技能数据
    local skillData = self.ServerSkills[skillName]
    if skillData then
        skillData.slot = 0  -- 卸下后槽位为0
    end

    -- 获取技能类型
    local skillType = SkillTypeConfig.Get(skillName)
    if skillType then
        if skillType.skillType == 0 then
            -- 主卡卸下：更新主卡装备状态和重新排序
            local buttonState = self.mainCardButtonStates[skillName]
            if buttonState then
                self:UpdateMainCardEquipStatus(skillName, skillData)
                self:SetMainCardEquippedVisual(skillName, false)
                self:SortAndUpdateMainCardLayout()
            end

            -- 如果当前选中的是这个主卡，更新装备/卸下按钮显示
            if self.currentMCardButtonName and
               self.currentMCardButtonName.extraParams.skillId == skillName then
                -- 卸下后：显示装备按钮，隐藏卸下按钮
                self.EquipmentSkillsButton:SetVisible(true)
                self.mainCardUnEquipButton:SetVisible(false)
                self.EquipmentSkillsButton:SetTouchEnable(true)

                -- gg.log("更新当前选中主卡的按钮状态: 显示装备按钮")
            end

            -- gg.log("主卡卸下完成，重新排序:", skillName, "原槽位:", oldSlot)
        elseif skillType.skillType == 1 then
            -- 副卡卸下：更新副卡显示
            self:UpdateSubCardTreeNodeDisplay(skillName)

            -- 如果当前选中的是这个副卡，更新属性面板
            if self.currentSubCardButtonName and
               self.currentSubCardButtonName.extraParams.skillId == skillName then
                local buttonState = self.subCardButtonStates[skillName]
                if buttonState then
                    buttonState.serverData = skillData
                    buttonState.button.extraParams.serverData = skillData
                end

                local skillLevel = skillData and skillData.level or 0
                self:UpdateSubCardAttributePanel(skillType, skillLevel, skillData)
            end
            -- gg.log("副卡卸下完成，更新显示:", skillName, "原槽位:", oldSlot)
        end
    end
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

    -- 如果切换到副卡，默认显示ALL品质的副卡列表（但保持选中状态）
    if cardType == "副卡" then
        -- 默认显示ALL品质的副卡列表
        self:ShowSubCardQuality("ALL")
    end

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
        -- 注意：主卡属性面板初始隐藏，只有点击具体主卡时才显示
        if showMain then
            -- 如果之前有选中的主卡，保持属性面板显示状态
            if self.currentMCardButtonName then
                self.attributeButton:SetVisible(true)
            else
                self.attributeButton:SetVisible(false)
            end
        else
            self.attributeButton:SetVisible(false)
        end
        self.subCardComponent:SetVisible(not showMain)
    end
    if self.subCardComponent then
        local showSub = (cardType == "副卡")
        self.subCardComponent:SetVisible(showSub)

        -- 副卡属性面板处理：类似主卡逻辑
        if showSub then
            -- 如果之前有选中的副卡，保持属性面板显示状态
            if self.currentSubCardButtonName then
                self.subCardAttributeButton:SetVisible(true)
            else
                self.subCardAttributeButton:SetVisible(false)
            end
            -- 切换到副卡时隐藏主卡属性面板
            self.attributeButton:SetVisible(false)
        else
            self.subCardAttributeButton:SetVisible(false)
        end
    end
end



-- 获取当前卡片类型
function CardsGui:GetCurrentCardType()
    return self.currentCardType
end

-- === 新增方法：显示指定品质的副卡列表 ===
function CardsGui:ShowSubCardQuality(quality)
    if self.subQualityLists then
        for q, listNode in pairs(self.subQualityLists) do
            listNode:SetVisible(q == quality)
        end
        gg.log("切换到副卡品质:", quality)
    end
end

-- === 修改：读取主卡数据并克隆节点（适配新逻辑）===
function CardsGui:LoadMainCardsAndClone()
    -- 主卡按钮的生成已经在 InitializeMainCardButtons 中完成

    local skillMainTrees = SkillTypeUtils.lastForest
    if not skillMainTrees then
        skillMainTrees = SkillTypeUtils.BuildSkillForest(0)
        SkillTypeUtils.lastForest = skillMainTrees
    end

    -- 使用美化的打印函数显示技能树结构
    SkillTypeUtils.PrintSkillForest(skillMainTrees)

    -- 克隆技能树纵列表（为所有配置的主卡预生成技能树）
    self:CloneVerticalListsForSkillTrees(skillMainTrees)

    -- gg.log("主卡技能树预生成完成")
end

-- === 新增工具方法：检查主卡是否在服务端解锁 ===
function CardsGui:IsMainCardServerUnlocked(skillName)
    local buttonState = self.mainCardButtonStates[skillName]
    return buttonState and buttonState.serverUnlocked or false
end

-- === 新增工具方法：获取服务端已解锁的主卡列表 ===
function CardsGui:GetServerUnlockedMainCards()
    local unlockedCards = {}
    for _, skillName in ipairs(self.configMainCards) do
        local buttonState = self.mainCardButtonStates[skillName]
        if buttonState and buttonState.serverUnlocked then
            table.insert(unlockedCards, skillName)
        end
    end
    return unlockedCards
end




-- 注册技能卡片的ViewButton
function CardsGui:RegisterSkillCardButton(cardFrame, skill, lane, position)
    local viewButton = ViewButton.New(cardFrame, self, nil, "卡框背景")
    viewButton.extraParams = {
        skillId = skill.name,
        lane = lane,
        position = position
    }

    -- 检查技能是否在服务端数据中存在，设置初始灰色状态
    local serverSkill = self.ServerSkills[skill.name]
    if not serverSkill then
        -- 未解锁技能：设置为灰色
        viewButton.img.Grayed = true
        gg.log("设置技能为灰色状态:", skill.name)
    else
        -- 已解锁技能：正常颜色
        viewButton.img.Grayed = false
        gg.log("设置技能为正常状态:", skill.name)
    end
    viewButton.clickCb = function(ui, button)
        local skillId = button.extraParams.skillId
        local skill = SkillTypeConfig.Get(skillId)
        local skillInst = self.ServerSkills[skillId]
        local skillLevel = 0

        -- 点击主卡技能时显示属性面板
        self.attributeButton:SetVisible(true)

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

        -- === 新逻辑：检查前置技能和服务端数据 ===
        local existsPrerequisite = true
        gg.log("prerequisite",prerequisite)
        gg.log("self.ServerSkills",self.ServerSkills)

        for i, preSkillType in ipairs(prerequisite) do
            if not self.ServerSkills[preSkillType.name] then
                existsPrerequisite = false
                break
            end
        end

        local skillLevel = 0
        local canResearchOrEquip = false

        -- 修改逻辑：当前技能存在 OR 所有父类技能都存在 就可以研究
        if curCardSkillData then
            -- 当前技能已存在：可以研究升级和装备
            skillLevel = curCardSkillData.level
            canResearchOrEquip = true
            gg.log("✅ 技能已存在，可研究装备:", skillId, "等级:", skillLevel)
        elseif existsPrerequisite then
            -- 当前技能不存在，但所有前置技能都存在：可以研究学习
            skillLevel = 0
            canResearchOrEquip = true
            gg.log("✅ 前置技能满足，可研究学习:", skillId, "前置技能数量:", #prerequisite)
        else
            gg.log("❌ 技能不可研究:", skillId, "缺少前置技能或服务端数据")
        end

        -- 设置研究装备按钮状态
        if canResearchOrEquip then
            -- 显示研究按钮
            self.confirmPointsButton:SetVisible(true)

            if curCardSkillData then
                -- 技能已存在：显示装备相关按钮
                local isEquipped = curCardSkillData.slot and curCardSkillData.slot > 0 or false

                if isEquipped then
                    -- 已装备：显示卸下按钮，隐藏装备按钮
                    self.mainCardUnEquipButton:SetVisible(true)
                    self.EquipmentSkillsButton:SetVisible(false)
                    self.mainCardUnEquipButton:SetTouchEnable(true)

                    gg.log("主卡已装备，显示卸下按钮:", skillId, "槽位:", curCardSkillData.slot)
                else
                    -- 未装备：显示装备按钮，隐藏卸下按钮
                    self.EquipmentSkillsButton:SetVisible(true)
                    self.mainCardUnEquipButton:SetVisible(false)
                    self.EquipmentSkillsButton:SetTouchEnable(true)

                    gg.log("主卡未装备，显示装备按钮:", skillId)
                end
            else
                -- 技能未学会：隐藏装备相关按钮
                self.EquipmentSkillsButton:SetVisible(false)
                self.mainCardUnEquipButton:SetVisible(false)

                gg.log("技能未学会，隐藏装备按钮:", skillId)
            end

            local maxLevel = skill.maxLevel
            local levelNode = cardFrame["等级"]

            -- 研究按钮：未满级可研究
            if skillLevel < maxLevel then
                self.confirmPointsButton:SetTouchEnable(true)
            else
                self.confirmPointsButton:SetTouchEnable(false)
            end

            if levelNode then
                gg.log("设置技能等级", string.format("%d/%d", skillLevel, maxLevel))
                levelNode.Title = string.format("%d/%d", skillLevel, maxLevel)
            end
        else
            -- 服务端无数据：隐藏所有功能按钮
            self.confirmPointsButton:SetVisible(false)
            self.EquipmentSkillsButton:SetVisible(false)
            self.mainCardUnEquipButton:SetVisible(false)

            -- 显示等级0
            local levelNode = cardFrame["等级"]
            if levelNode then
                levelNode.Title = string.format("0/%d", skill.maxLevel or 1)
            end
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

-- === 旧方法：动态生成副卡列表（已废弃，改用新的预加载+激活模式）===
-- 动态生成副卡列表
---@params   SubskillList 副卡列表
--[[
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
--]]

function CardsGui:BindQualityButtonEvents()
    local qualityListMap = uiConfig.qualityListMap or {}
    for btnName, quality in pairs(qualityListMap) do
        local qualityBtn = self:Get("品质列表/"  .. btnName, ViewButton)
        if qualityBtn then
            qualityBtn.clickCb = function()
                if self.currentCardType == "副卡" or self.currentCardType == "sub" then
                    -- 切换品质时清除当前选中的副卡状态，隐藏属性面板
                    self.currentSubCardButtonName = nil
                    self.subCardAttributeButton:SetVisible(false)

                    -- 使用新的显示方法
                    self:ShowSubCardQuality(quality)

                    gg.log("切换副卡品质:", quality, "属性面板已隐藏")
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
        if skillLevel < skill.maxLevel then
            self.SubcardEnhancementButton:SetVisible(true)
            self.SubcardEnhancementButton:SetTouchEnable(true)
        else
            self.SubcardEnhancementButton:SetVisible(false)
        end
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

    -- 更新技能按钮的灰色状态（新获得的技能应该不是灰色）
    if self.mainCardButtondict[skillName] then
        self.mainCardButtondict[skillName].img.Grayed = false
        gg.log("新获得技能，设置为正常颜色:", skillName)
    end

    gg.log("新技能添加完成", skillName, "等级:", skillLevel, "槽位:", skillSlot)
end

-- === 修改：添加新的主卡技能（适配新逻辑）===
function CardsGui:AddNewMainCardSkill(skillName, skillType, skillData)
    gg.log("添加新主卡技能", skillName)

    -- 检查按钮状态
    local buttonState = self.mainCardButtonStates[skillName]
    if not buttonState then
        gg.log("未找到主卡配置，这是一个新技能", skillName)
        -- 如果是配置中不存在的新技能，需要动态添加
        self:AddDynamicMainCardSkill(skillName, skillType, skillData)
        -- 重新排序
        self:SortAndUpdateMainCardLayout()
        return
    end

    if buttonState.serverUnlocked then
        gg.log("主卡技能已解锁，跳过处理", skillName)
        return
    end

    -- 标记为服务端已解锁
    buttonState.serverUnlocked = true
    buttonState.serverData = skillData

    -- 更新装备状态
    self:UpdateMainCardEquipStatus(skillName, skillData)

    -- 恢复按钮正常颜色
    if buttonState.button then
        buttonState.button.img.Grayed = false

        -- 设置装备状态的视觉反馈
        self:SetMainCardEquippedVisual(skillName, buttonState.isEquipped)
    end

    -- 创建对应的技能树（如果还没有）
    if not self.skillLists[skillName] then
        self:CreateSkillTreeForNewMainCard(skillName, skillType)
    end

    -- 重新排序主卡按钮
    self:SortAndUpdateMainCardLayout()

    gg.log("主卡技能服务端数据更新完成", skillName)
end

-- === 新增：动态添加配置中不存在的主卡技能 ===
function CardsGui:AddDynamicMainCardSkill(skillName, skillType, skillData)
    gg.log("动态添加新主卡技能", skillName)

    -- 添加到配置中
    self.mainCardButtonConfig[skillName] = {
        skillType = skillType,
        rootNode = nil  -- 动态技能可能没有完整的技能树
    }

    -- 获取选择列表
    local ListTemplate = self:Get('框体/主卡/选择列表/列表', ViewList) ---@type ViewList

    -- 计算新的位置（在配置列表的末尾）
    local newPosition = #self.configMainCards + 1
    local child = ListTemplate:GetChild(newPosition)

    if child then
        child.extraParams = child.extraParams or {}
        child.extraParams["skillId"] = skillName
        child.node.Name = skillType.name

        -- 设置图标
        if skillType.icon and skillType.icon ~= "" then
            local iconNode = child.node['图标']
            if iconNode then
                iconNode.Icon = skillType.icon
            end
        end

        -- 创建激活状态的按钮（动态添加的技能默认已解锁）
        local button = ViewButton.New(child.node, self, nil, "卡框背景")
        button.extraParams = {skillId = skillName}
        button:SetTouchEnable(true, false) -- 可点击，不自动变灰

        -- 动态添加的技能默认为正常颜色（已解锁）
        button.img.Grayed = false

        -- 绑定点击事件
        button.clickCb = function(ui, button)
            local skillId = button.extraParams["skillId"]
            gg.log("🔍 主卡按钮点击调试信息:")
            gg.log("  - 点击的技能ID:", skillId)
            gg.log("  - 技能列表总数:", self:GetSkillListsCount())
            gg.log("  - 当前技能列表存在:", self.skillLists[skillId] ~= nil)

            -- 调试：打印所有技能列表的名称
            gg.log("  - 所有技能列表:")
            for name, vlist in pairs(self.skillLists) do
                gg.log("    * ", name, "可见:", vlist.node and vlist.node.Visible or "unknown")
            end

            local currentList = self.skillLists[skillId]
            if currentList then
                -- 隐藏所有其他技能树
                for name, vlist in pairs(self.skillLists) do
                    if name ~= skillId then
                        vlist:SetVisible(false)
                    end
                end
                -- 显示当前技能树
                currentList:SetVisible(true)

                -- 点击主卡选择按钮时显示属性面板
                self.attributeButton:SetVisible(true)
            else
                gg.log("  - ❌ 未找到对应技能树，技能ID:", skillId)
                gg.log("  - 🔧 尝试重新创建技能树...")
                -- 尝试重新创建技能树
                local skillType = SkillTypeConfig.Get(skillId)
                if skillType then
                    self:CreateSkillTreeForNewMainCard(skillId, skillType)
                    -- 创建成功后显示属性面板
                    if self.skillLists[skillId] then
                        self.attributeButton:SetVisible(true)
                    end
                    gg.log("  - ✅ 技能树重新创建完成")
                else
                    gg.log("  - ❌ 无法获取技能配置:", skillId)
                end
            end
        end

        -- 存储按钮状态
        self.skillButtons[skillName] = button
        self.mainCardButtonStates[skillName] = {
            button = button,
            position = newPosition,
            serverUnlocked = true,
            isEquipped = skillData.slot and skillData.slot > 0 or false,
            equipSlot = skillData.slot or 0,
            serverData = skillData,
            configData = skillType
        }

        -- 添加到配置列表
        table.insert(self.configMainCards, skillName)

        -- 创建技能树
        self:CreateSkillTreeForNewMainCard(skillName, skillType)

        gg.log("动态主卡技能创建完成", skillName)
    else
        gg.log("无法获取新的列表项，列表可能已满")
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

-- === 修改：添加新的副卡技能（适配新逻辑）===
function CardsGui:AddNewSubCardSkill(skillName, skillType, skillData)
    gg.log("添加新副卡技能", skillName, skillType.quality)

    -- 检查按钮状态
    local buttonState = self.subCardButtonStates[skillName]
    if not buttonState then
        gg.log("未找到副卡配置，这是一个新技能", skillName)
        -- 如果是配置中不存在的新技能，需要动态添加
        self:AddDynamicSubCardSkill(skillName, skillType, skillData)
        return
    end

    if buttonState.serverUnlocked then
        gg.log("副卡技能已解锁，跳过处理", skillName)
        return
    end

    -- 标记为服务端已解锁
    buttonState.serverUnlocked = true
    buttonState.serverData = skillData

    -- 恢复按钮正常颜色
    if buttonState.button then
        buttonState.button.img.Grayed = false
        buttonState.button.extraParams.serverData = skillData
    end

    -- 重新排序副卡按钮
    self:SortAndUpdateSubCardLayout()

    gg.log("副卡技能服务端数据更新完成", skillName)
end

-- === 新增：动态添加配置中不存在的副卡技能 ===
function CardsGui:AddDynamicSubCardSkill(skillName, skillType, skillData)
    gg.log("动态添加新副卡技能", skillName)

    local quality = skillType.quality or "N"

    -- 添加到配置中
    self.subCardButtonConfig[skillName] = {
        skillType = skillType
    }
    table.insert(self.configSubCards, skillName)

    -- 初始化按钮状态（动态添加的技能默认已解锁）
    self.subCardButtonStates[skillName] = {
        button = nil,
        position = 0, -- 稍后会重新计算
        serverUnlocked = true,
        serverData = skillData,
        configData = skillType
    }

    -- === 先检查原品质列表是否存在 ===
    local qualityList = self.subQualityLists[quality]
    if not qualityList then
        gg.log("找不到对应品质的副卡列表", quality)
        return
    end

    -- === 准备要更新的品质列表 ===
    local qualitiesToUpdate = {quality}  -- 添加到原品质列表
    if quality ~= "ALL" and self.subQualityLists["ALL"] then
        table.insert(qualitiesToUpdate, "ALL")  -- 也添加到ALL列表（如果存在）
    end

    -- 获取副卡模板
    local subCardTemplate = self:Get('框体/副卡/副卡列/副卡列表/副卡槽_1', ViewButton)
    if not subCardTemplate or not subCardTemplate.node then
        gg.log("找不到副卡模板")
        return
    end
    local existingSubCard = subCardTemplate.node

    -- === 为每个相关品质列表创建副卡按钮 ===
    for _, qualityToUpdate in ipairs(qualitiesToUpdate) do
        local currentQualityList = self.subQualityLists[qualityToUpdate]
        if currentQualityList then
            -- 克隆新的副卡节点
            local clonedNode = existingSubCard:Clone()
            clonedNode.Name = skillType.name .. "_" .. qualityToUpdate  -- 添加品质后缀避免重名
            clonedNode.Parent = currentQualityList.node
            clonedNode.Visible = true

            -- 设置副卡UI
            self:SetSkillLevelSubCardFrame(clonedNode, skillType)

            -- 创建按钮（动态添加的技能默认为正常颜色）
            local subCardButton = ViewButton.New(clonedNode, self, nil, "图标底图")
            subCardButton.extraParams = {
                skillId = skillName,
                serverData = skillData
            }
            subCardButton:SetTouchEnable(true)
            subCardButton.img.Grayed = false  -- 动态添加的技能默认已解锁

            -- 绑定点击事件
            subCardButton.clickCb = function(ui, button)
                local skillId = button.extraParams.skillId
                local skill = SkillTypeConfig.Get(skillId)
                local buttonState = self.subCardButtonStates[skillId]
                local serverData = buttonState and buttonState.serverData
                local skillLevel = serverData and serverData.level or 0

                -- 更新副卡属性面板
                self:UpdateSubCardAttributePanel(skill, skillLevel, serverData)
                self.currentSubCardButtonName = button
            end

            -- 如果是原品质，存储按钮引用
            if qualityToUpdate == quality then
                self.subCardButtondict[skillName] = subCardButton
                self.subCardButtonStates[skillName].button = subCardButton
            end

            -- 更新列表的LineCount
            local currentCount = currentQualityList.node.LineCount or 0
            currentQualityList.node.LineCount = currentCount + 1

            gg.log("动态副卡技能创建完成", skillName, "品质:", qualityToUpdate)
        end
    end

    gg.log("动态副卡技能全部创建完成", skillName)
end

-- === 新增调试方法：获取技能列表数量 ===
function CardsGui:GetSkillListsCount()
    local count = 0
    for _ in pairs(self.skillLists) do
        count = count + 1
    end
    return count
end

-- === 新增调试方法：打印所有技能列表状态 ===
function CardsGui:DebugPrintSkillListsStatus()
    gg.log("=== 技能列表状态调试 ===")
    gg.log("技能列表总数:", self:GetSkillListsCount())
    gg.log("配置主卡数:", #self.configMainCards)

    gg.log("=== 主卡按钮状态 ===")
    for i, skillName in ipairs(self.configMainCards) do
        local buttonState = self.mainCardButtonStates[skillName]
        if buttonState then
            gg.log(i, ":", skillName, "服务端解锁:", buttonState.serverUnlocked, "技能树存在:", self.skillLists[skillName] ~= nil)
        end
    end

    gg.log("=== 所有技能列表详情 ===")
    for name, vlist in pairs(self.skillLists) do
        local visible = vlist.node and vlist.node.Visible or "unknown"
        gg.log("技能树:", name, "可见:", visible, "节点存在:", vlist.node ~= nil)
    end
    gg.log("=== 调试结束 ===")
end

-- === 修复方法：确保技能树正确创建 ===
function CardsGui:EnsureSkillTreeExists(skillName)
    if not self.skillLists[skillName] then
        gg.log("技能树不存在，尝试创建:", skillName)
        local skillType = SkillTypeConfig.Get(skillName)
        if skillType then
            self:CreateSkillTreeForNewMainCard(skillName, skillType)
            return self.skillLists[skillName] ~= nil
        else
            gg.log("无法获取技能配置:", skillName)
            return false
        end
    end
    return true
end

-- === 新增方法：显示技能树 ===
function CardsGui:ShowSkillTree(skillName)

    -- 确保技能树存在
    if not self.skillLists[skillName] then
        local skillType = SkillTypeConfig.Get(skillName)
        if skillType then
            self:CreateSkillTreeForNewMainCard(skillName, skillType)
        else
            return
        end
    end

    local currentList = self.skillLists[skillName]
    if currentList then
        -- 隐藏所有其他技能树
        for name, vlist in pairs(self.skillLists) do
            if name ~= skillName then
                vlist:SetVisible(false)
            end
        end
        -- 显示当前技能树
        currentList:SetVisible(true)
    else
    end
end

-- === 新增方法：加载副卡配置 ===
function CardsGui:LoadSubCardConfig()
    gg.log("开始加载副卡配置")

    local allSkills = SkillTypeConfig.GetAll()

    -- 遍历所有技能，找到副卡入口技能
    for skillName, skillType in pairs(allSkills) do
        if skillType.skillType == 1 and skillType.isEntrySkill then
            -- 存储配置数据
            self.subCardButtonConfig[skillName] = {
                skillType = skillType
            }
            table.insert(self.configSubCards, skillName)

            -- 初始化按钮状态
            self.subCardButtonStates[skillName] = {
                button = nil,
                position = #self.configSubCards,
                serverUnlocked = false,  -- 是否在服务端解锁
                serverData = nil,
                configData = skillType
            }
        end
    end

    gg.log("副卡配置加载完成，共", #self.configSubCards, "个副卡")
end

-- === 新增方法：初始化所有副卡按钮（置灰状态）===
function CardsGui:InitializeSubCardButtons()
    gg.log("开始初始化副卡按钮")

    local qualityList = uiConfig.qualityList or {"UR", "SSR", "SR", "R", "N", "ALL"}

    -- 按品级分组副卡
    local subCardsByQuality = {}
    for _, quality in ipairs(qualityList) do
        subCardsByQuality[quality] = {}
    end

    -- 分类配置的副卡
    for _, skillName in ipairs(self.configSubCards) do
        local skillConfig = self.subCardButtonConfig[skillName]
        local skillType = skillConfig.skillType
        local quality = skillType.quality or "N"

        -- 将副卡添加到对应品质列表
        if subCardsByQuality[quality] then
            table.insert(subCardsByQuality[quality], skillName)
        end

        -- === 新增：将所有副卡都添加到ALL列表 ===
        if subCardsByQuality["ALL"] then
            table.insert(subCardsByQuality["ALL"], skillName)
        end
    end

    -- 获取副卡列表模板
    local subListTemplate = self:Get('框体/副卡/副卡列/副卡列表', ViewList) ---@type ViewList

    -- 克隆各品级的副卡列表
    for _, quality in ipairs(qualityList) do
        local listClone = subListTemplate.node:Clone()
        local qualityName = "副卡列表_" .. quality
        listClone.Name = qualityName
        listClone.Parent = subListTemplate.node.Parent
        listClone.Visible = false

        -- 设置LineCount为该品质副卡总数（包括未解锁的）
        local count = #subCardsByQuality[quality]
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
    local subCardTemplate = self:Get('框体/副卡/副卡列/副卡列表/副卡槽_1', ViewButton)
    if subCardTemplate and subCardTemplate.node then
        existingSubCard = subCardTemplate.node
    end

    if not existingSubCard then
        gg.log("错误：找不到副卡模板")
        return
    end

    -- 为每个品级生成对应的副卡按钮（置灰状态）
    for _, quality in ipairs(qualityList) do
        local qualitySkills = subCardsByQuality[quality]
        local listNode = self.subQualityLists[quality]

        if listNode then
            for index, skillName in ipairs(qualitySkills) do
                local skillConfig = self.subCardButtonConfig[skillName]
                local skillType = skillConfig.skillType

                -- 克隆副卡节点
                local clonedNode = existingSubCard:Clone()
                clonedNode.Name = skillType.name
                clonedNode.Parent = listNode.node
                clonedNode.Visible = true

                -- 设置副卡UI
                self:SetSkillLevelSubCardFrame(clonedNode, skillType)

                -- 创建按钮（灰色状态）
                local subCardButton = ViewButton.New(clonedNode, self, nil, "图标底图")
                subCardButton.extraParams = {
                    skillId = skillName,
                    serverData = nil  -- 初始无服务端数据
                }
                subCardButton:SetTouchEnable(true) -- 可点击

                -- 设置为灰色（未解锁状态）
                subCardButton.img.Grayed = true

                -- 绑定点击事件
                subCardButton.clickCb = function(ui, button)
                    local skillId = button.extraParams.skillId
                    local skill = SkillTypeConfig.Get(skillId)
                    local buttonState = self.subCardButtonStates[skillId]
                    local serverData = buttonState and buttonState.serverData
                    local skillLevel = serverData and serverData.level or 0

                    -- 更新副卡属性面板
                    self:UpdateSubCardAttributePanel(skill, skillLevel, serverData)
                    self.currentSubCardButtonName = button
                end

                -- 存储按钮引用
                self.subCardButtondict[skillName] = subCardButton
                self.subCardButtonStates[skillName].button = subCardButton
                self.subCardButtonStates[skillName].position = index

                gg.log("初始化副卡按钮", skillName, "品级", quality, "位置", index)
            end
        end
    end

    -- 隐藏模板
    subListTemplate.node.Visible = false

    -- 默认显示ALL品质（初始化完成后）
    self:ShowSubCardQuality("ALL")

    gg.log("副卡按钮初始化完成，所有按钮都可点击，默认显示ALL品质")
end

-- === 新增方法：更新副卡属性面板 ===
function CardsGui:UpdateSubCardAttributePanel(skill, skillLevel, serverData)
    -- 点击副卡时显示属性面板
    self.subCardAttributeButton:SetVisible(true)

    local attributeButton = self.subCardAttributeButton.node

    -- 更新副卡名称
    local nameNode = attributeButton["卡片名字"]
    if nameNode then
        nameNode.Title = skill.displayName or skill.name
    end

    -- 更新副卡描述
    local descNode = attributeButton["卡片介绍"]
    if descNode then
        descNode.Title = skill.description or "暂无描述"
    end

    -- 更新强化前后属性
    local descPreTitleNode = attributeButton["列表_强化前"]["强化标题"]
    local descPostTitleNode = attributeButton["列表_强化后"]["强化标题"]
    local descPreNode = attributeButton["列表_强化前"]["属性_1"]
    local descPostNode = attributeButton["列表_强化后"]["属性_1"]

    descPreTitleNode.Title = string.format("等级 %d/%d", skillLevel, skill.maxLevel or 1)

    -- 显示当前等级属性
    local descPre = {}
    if skill.passiveTags then
        for _, tag in pairs(skill.passiveTags) do
            table.insert(descPre, tag:GetDescription(skillLevel))
        end
    end
    descPreNode.Title = table.concat(descPre, "\n")

    -- 显示下一等级属性或满级提示
    if skillLevel < (skill.maxLevel or 1) then
        descPostTitleNode.Title = string.format("等级 %d/%d", skillLevel+1, skill.maxLevel or 1)
        local descPost = {}
        if skill.passiveTags then
            for _, tag in pairs(skill.passiveTags) do
                table.insert(descPost, tag:GetDescription(skillLevel+1))
            end
        end
        descPostNode.Title = table.concat(descPost, "\n")
    else
        descPostTitleNode.Title = "已满级"
        descPostNode.Title = ""
    end

    -- 设置功能按钮状态
    if serverData then
        -- 有服务端数据：根据等级和装备状态决定按钮显示
        local maxLevel = skill.maxLevel or 1
        local isMaxLevel = skillLevel >= maxLevel
        local isEquipped = serverData.slot and serverData.slot > 0 or false

        if not isMaxLevel then
            -- 未满级：显示强化和一键强化按钮
            self.SubcardEnhancementButton:SetVisible(true)
            self.SubcardEnhancementButton:SetTouchEnable(true)

            if self.SubcardAllEnhancementButton then
                self.SubcardAllEnhancementButton:SetVisible(true)
                self.SubcardAllEnhancementButton:SetTouchEnable(true)
            end

            -- gg.log("副卡未满级，显示强化相关按钮:", skill.name, "等级:", skillLevel, "/", maxLevel)
        else
            -- 已满级：隐藏强化和一键强化按钮
            self.SubcardEnhancementButton:SetVisible(false)

            if self.SubcardAllEnhancementButton then
                self.SubcardAllEnhancementButton:SetVisible(false)
            end

            -- gg.log("副卡已满级，隐藏强化按钮:", skill.name, "等级:", skillLevel, "/", maxLevel)
        end

        -- 根据装备状态显示装备/卸下按钮
        if isEquipped then
            -- 已装备：显示卸下按钮，隐藏装备按钮
            if self.SubcardEquipButton then
                self.SubcardEquipButton:SetVisible(false)
            end

            if self.SubcardUnEquipButton then
                self.SubcardUnEquipButton:SetVisible(true)
                self.SubcardUnEquipButton:SetTouchEnable(true)
            end

            gg.log("副卡已装备，显示卸下按钮:", skill.name, "槽位:", serverData.slot)
        else
            -- 未装备：显示装备按钮，隐藏卸下按钮
            if self.SubcardEquipButton then
                self.SubcardEquipButton:SetVisible(true)
                self.SubcardEquipButton:SetTouchEnable(true)
            end

            if self.SubcardUnEquipButton then
                self.SubcardUnEquipButton:SetVisible(false)
            end

            gg.log("副卡未装备，显示装备按钮:", skill.name)
        end
    else
        -- 无服务端数据：隐藏所有功能按钮
        self.SubcardEnhancementButton:SetVisible(false)

        if self.SubcardAllEnhancementButton then
            self.SubcardAllEnhancementButton:SetVisible(false)
        end

        if self.SubcardEquipButton then
            self.SubcardEquipButton:SetVisible(false)
        end

        if self.SubcardUnEquipButton then
            self.SubcardUnEquipButton:SetVisible(false)
        end

        gg.log("副卡无服务端数据，隐藏所有功能按钮:", skill.name)
    end
end

-- === 新增方法：处理服务端副卡数据 ===
function CardsGui:ProcessServerSubCardData(serverSubskillDic)
    gg.log("开始处理服务端副卡数据")

    -- 处理所有配置的副卡，更新解锁状态
    for _, skillName in ipairs(self.configSubCards) do
        local buttonState = self.subCardButtonStates[skillName]
        if buttonState and buttonState.button then
            -- 检查是否在服务端数据中
            if serverSubskillDic[skillName] then
                local serverData = serverSubskillDic[skillName].serverdata

                -- 标记为服务端已解锁
                buttonState.serverUnlocked = true
                buttonState.serverData = serverData

                -- 恢复按钮正常颜色（已解锁）
                buttonState.button.img.Grayed = false

                -- 更新按钮的服务端数据
                buttonState.button.extraParams.serverData = serverData

                gg.log("✅ 副卡已解锁，恢复正常颜色:", skillName, "等级:", serverData.level or 0)
            else
                -- 确保未解锁的副卡保持灰色
                buttonState.serverUnlocked = false
                buttonState.serverData = nil
                buttonState.button.img.Grayed = true
                buttonState.button.extraParams.serverData = nil

                gg.log("⚫ 副卡未解锁，保持灰色:", skillName)
            end
        end
    end

    -- 重新排序副卡按钮：已解锁的在前，未解锁的在后
    self:SortAndUpdateSubCardLayout()

    gg.log("服务端副卡数据处理完成")
end

-- === 新增方法：排序和更新副卡布局 ===
function CardsGui:SortAndUpdateSubCardLayout()
    gg.log("开始重新排序副卡按钮")

    local qualityList = uiConfig.qualityList or {"UR", "SSR", "SR", "R", "N", "ALL"}

    -- 按品级分别排序
    for _, quality in ipairs(qualityList) do
        -- 获取该品级的副卡
        local qualityCards = {}

        if quality == "ALL" then
            -- ALL品质：包含所有副卡
            for _, skillName in ipairs(self.configSubCards) do
                table.insert(qualityCards, skillName)
            end
        else
            -- 其他品质：只包含对应品质的副卡
            for _, skillName in ipairs(self.configSubCards) do
                local buttonState = self.subCardButtonStates[skillName]
                if buttonState and buttonState.configData and buttonState.configData.quality == quality then
                    table.insert(qualityCards, skillName)
                end
            end
        end

        if #qualityCards > 0 then
            -- 使用table.sort进行排序：已解锁的排在前面
            table.sort(qualityCards, function(a, b)
                local aState = self.subCardButtonStates[a]
                local bState = self.subCardButtonStates[b]
                local aUnlocked = aState and aState.serverUnlocked or false
                local bUnlocked = bState and bState.serverUnlocked or false

                -- 已解锁的排在前面
                if aUnlocked and not bUnlocked then
                    return true
                elseif not aUnlocked and bUnlocked then
                    return false
                else
                    -- 同样状态的保持原有顺序
                    return false
                end
            end)

            -- 重新创建该品级的副卡按钮
            self:RecreateSubCardButtonsInOrder(quality, qualityCards)
        end
    end

    gg.log("副卡按钮重新排序完成")
end

-- === 新增方法：按顺序重新创建副卡按钮 ===
function CardsGui:RecreateSubCardButtonsInOrder(quality, sortedCards)
    local listNode = self.subQualityLists[quality]
    if not listNode then return end

    -- 获取副卡模板
    local subCardTemplate = self:Get('框体/副卡/副卡列/副卡列表/副卡槽_1', ViewButton)
    if not subCardTemplate or not subCardTemplate.node then
        gg.log("错误：找不到副卡模板")
        return
    end
    local existingSubCard = subCardTemplate.node

    -- 清除该品级列表中的现有节点（除了模板）
    for _, child in ipairs(listNode.node.Children) do
        if not string.find(child.Name, "副卡槽_1") then
            child:Destroy()
        end
    end

    -- 保存按钮数据
    local buttonData = {}
    for _, skillName in ipairs(sortedCards) do
        local buttonState = self.subCardButtonStates[skillName]
        if buttonState then
            buttonData[skillName] = {
                skillType = buttonState.configData,
                serverUnlocked = buttonState.serverUnlocked,
                serverData = buttonState.serverData
            }
        end
    end

    -- 按新顺序重新创建按钮
    for newIndex, skillName in ipairs(sortedCards) do
        local data = buttonData[skillName]
        if data and data.skillType then
            local skillType = data.skillType

            -- 克隆副卡节点
            local clonedNode = existingSubCard:Clone()
            clonedNode.Name = skillType.name
            clonedNode.Parent = listNode.node
            clonedNode.Visible = true

            -- 设置副卡UI
            self:SetSkillLevelSubCardFrame(clonedNode, skillType)

            -- 创建新的按钮
            local subCardButton = ViewButton.New(clonedNode, self, nil, "图标底图")
            subCardButton.extraParams = {
                skillId = skillName,
                serverData = data.serverData
            }
            subCardButton:SetTouchEnable(true)

            -- 设置灰色状态
            if data.serverUnlocked then
                subCardButton.img.Grayed = false  -- 已解锁：正常颜色
                gg.log("重新创建已解锁副卡:", skillName, "品级:", quality, "位置:", newIndex)
            else
                subCardButton.img.Grayed = true   -- 未解锁：灰色
                gg.log("重新创建未解锁副卡:", skillName, "品级:", quality, "位置:", newIndex)
            end

            -- 绑定点击事件
            subCardButton.clickCb = function(ui, button)
                local skillId = button.extraParams.skillId
                local skill = SkillTypeConfig.Get(skillId)
                local buttonState = self.subCardButtonStates[skillId]
                local serverData = buttonState and buttonState.serverData
                local skillLevel = serverData and serverData.level or 0

                -- 更新副卡属性面板
                self:UpdateSubCardAttributePanel(skill, skillLevel, serverData)
                self.currentSubCardButtonName = button
            end

            -- 更新存储
            self.subCardButtondict[skillName] = subCardButton
            self.subCardButtonStates[skillName].button = subCardButton
            self.subCardButtonStates[skillName].position = newIndex
        end
    end

    gg.log("品级", quality, "副卡按钮重新创建完成")
end

-- === 新增调试方法：检查副卡按钮状态 ===
function CardsGui:DebugSubCardButtonsState()
    gg.log("=== 副卡功能按钮状态调试 ===")

    -- 检查强化按钮
    local enhanceVisible = self.SubcardEnhancementButton and self.SubcardEnhancementButton.node.Visible or false
    gg.log("强化按钮可见:", enhanceVisible)

    -- 检查一键强化按钮
    if self.SubcardAllEnhancementButton then
        local allEnhanceVisible = self.SubcardAllEnhancementButton.node.Visible or false
        gg.log("一键强化按钮可见:", allEnhanceVisible)
    else
        gg.log("一键强化按钮: 不存在")
    end

    -- 检查装备按钮
    if self.SubcardEquipButton then
        local equipVisible = self.SubcardEquipButton.node.Visible or false
        gg.log("装备按钮可见:", equipVisible)
    else
        gg.log("装备按钮: 不存在")
    end

    -- 检查卸下按钮
    if self.SubcardUnEquipButton then
        local unequipVisible = self.SubcardUnEquipButton.node.Visible or false
        gg.log("卸下按钮可见:", unequipVisible)
    else
        gg.log("卸下按钮: 不存在")
    end

    -- 检查当前选中的副卡信息
    if self.currentSubCardButtonName then
        local skillId = self.currentSubCardButtonName.extraParams.skillId
        local buttonState = self.subCardButtonStates[skillId]
        local serverData = buttonState and buttonState.serverData
        local skillLevel = serverData and serverData.level or 0
        local skillType = SkillTypeConfig.Get(skillId)
        local maxLevel = skillType and skillType.maxLevel or 1

        gg.log("当前选中副卡:", skillId)
        gg.log("  - 等级:", skillLevel, "/", maxLevel)
        gg.log("  - 是否满级:", skillLevel >= maxLevel)
        gg.log("  - 有服务端数据:", serverData ~= nil)
    else
        gg.log("当前选中副卡: 无")
    end

    gg.log("=== 副卡按钮状态调试结束 ===")
end

return CardsGui.New(script.Parent, uiConfig)

