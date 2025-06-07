local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.code.client.ui.ViewBase) ---@type ViewBase
local ViewList = require(MainStorage.code.client.ui.ViewList) ---@type ViewList
local ViewButton = require(MainStorage.code.client.ui.ViewButton) ---@type ViewButton
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local CameraController = require(MainStorage.code.client.camera.CameraController) ---@type CameraController
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager
local ClientScheduler = require(MainStorage.code.client.ClientScheduler) ---@type ClientScheduler
local SkillEventConfig = require(MainStorage.code.common.event_conf.event_skill) ---@type SkillEventConfig


local tweenInfo = TweenInfo.New(0.2, Enum.EasingStyle.Linear)
local TweenService = game:GetService('TweenService')



---@class HudCards:ViewBase
local HudCards = ClassMgr.Class("HudCards", ViewBase)

local uiConfig = {
    uiName = "HudCards",
    layer = 0,
    hideOnInit = false,
}

-- 缓存技能数据
---@type table<string, Skill>
local skills = {}
---@type table<number, string>
local equippedSkills = {}
-- 施法相关变量
local lastCastTimes = {}  -- 记录每个技能的释放时间
local updateTaskId = nil


function HudCards:SetFov(fov)
    if self.cameraTween then
        self.cameraTween:Destroy()
    end
    self.cameraTween = TweenService:Create(game.WorkSpace.CurrentCamera, tweenInfo, {FieldOfView = fov})
    self.cameraTween:Play()
end

-- 更新冷却显示
function HudCards:UpdateCooldownDisplay()
    -- 更新主卡冷却显示
    if self.mainCardButton then
        for slotId, skill in pairs(self.mainCardData) do
            local currentTime = os.clock()
            local lastCastTime = lastCastTimes[skill.skillId]
            if lastCastTime and skill.cooldownCache > 0 then
                local elapsedTime = currentTime - lastCastTime
                local remainingTime = math.max(0, skill.cooldownCache - elapsedTime)
                local fillAmount = remainingTime / skill.cooldownCache

                -- 更新主卡冷却显示
                if self.mainCardButton.node["冷却条"] then
                    self.mainCardButton.node["冷却条"].FillAmount = fillAmount
                end

                -- 检查是否在冷却中
                local isOnCooldown = remainingTime > 0
                self.mainCardButton:SetTouchEnable(not isOnCooldown, false)
                if isOnCooldown then
                    if self.mainCardButton.node["卡片框"] then
                        self.mainCardButton.node["卡片框"].FillColor = ColorQuad.New(150, 150, 150, 255)
                    end
                else
                    if self.mainCardButton.node["卡片框"] then
                        self.mainCardButton.node["卡片框"].FillColor = ColorQuad.New(255, 255, 255, 255)
                    end
                end
            end
            break -- 只有一个主卡
        end
    end

    -- 更新副卡冷却显示
    if not self.cardsList then return end

    -- 获取排序后的槽位列表
    local subCardSlots = {}
    for slotId, skill in pairs(self.subCardData) do
        table.insert(subCardSlots, slotId)
    end
    table.sort(subCardSlots)

    -- 遍历所有副卡
    for i, slotId in ipairs(subCardSlots) do
        local card = self.cardsList:GetChild(i) ---@type ViewButton
        local skill = self.subCardData[slotId]

        if skill then
            local currentTime = os.clock()
            local lastCastTime = lastCastTimes[skill.skillId]
            if lastCastTime and skill.cooldownCache > 0 then
                local elapsedTime = currentTime - lastCastTime
                local remainingTime = math.max(0, skill.cooldownCache - elapsedTime)
                local fillAmount = remainingTime / skill.cooldownCache
                -- 更新冷却显示
                if card.node["冷却条"] then
                    card.node["冷却条"].FillAmount = fillAmount
                end

                -- 检查是否在冷却中
                local isOnCooldown = remainingTime > 0
                card:SetTouchEnable(not isOnCooldown, false)
                if isOnCooldown then
                    if card.node["卡片框"] then
                        card.node["卡片框"].FillColor = ColorQuad.New(150, 150, 150, 255)
                    end
                else
                    if card.node["卡片框"] then
                        card.node["卡片框"].FillColor = ColorQuad.New(255, 255, 255, 255)
                    end
                end
            end
        end
    end
end

-- 处理技能同步事件

---@param data SyncPlayerSkillsData
function HudCards:OnSyncPlayerSkills(data)
    if not data or not data.skillData then return end
    gg.log("获取来自服务端的技能数据111", data)
    if not data or not data.skillData then return end
    local skillDataDic = data.skillData.skills
    -- 清空现有技能数据
    skills = {}
    equippedSkills = {}
    lastCastTimes = {}  -- 清空冷却时间记录

    -- 清空卡片数据
    self.mainCardData = {}
    self.subCardData = {}

    -- 反序列化技能数据
    for skillId, skillData in pairs(data.skillData.skills) do
        local Skill = require(MainStorage.code.server.spells.Skill) ---@type Skill
        local skill = Skill.New(nil, skillData) ---@type Skill
        skills[skillId] = skill

        -- 获取技能类型配置
        local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig
        local skillType = SkillTypeConfig.Get(skillId)
        self.selectedSkill[skillId] = skill
        gg.log("data",skillType,skill)
        if skillType then
            -- 根据技能分类和槽位分别存储
            if skillType.skillType == 0 then
                -- 主卡技能：slot不等于0且是主卡类型
                if skill.equipSlot and skill.equipSlot ~= 0 then
                    self.mainCardData[skill.equipSlot] = skill
                    gg.log("存储主卡技能:", skillId, "槽位:", skill.equipSlot)
                end
            elseif skillType.skillType == 1 then
                -- 副卡技能：slot不等于0且是副卡类型
                if skill.equipSlot and skill.equipSlot ~= 0 then
                    self.subCardData[skill.equipSlot] = skill
                    gg.log("存储副卡技能:", skillId, "槽位:", skill.equipSlot)
                end
            end
        end

        -- 记录已装备的技能（保持原有逻辑）
        if skill.skillType.activeSpell then
            equippedSkills[skill.equipSlot] = skillId
        end
    end
    -- 更新卡片列表显示
    self:UpdateCardsDisplay()

    gg.log("已同步技能数据:", skills, equippedSkills)
    gg.log("主卡数据:", self.mainCardData)
    gg.log("副卡数据:", self.subCardData)
end

-- 处理技能冷却更新事件
---@param data {cmd: string, skillId: string, cooldown: number}
function HudCards:OnEquipSkillCooldownUpdate(data)
    if not data or not data.skillId or not data.cooldown then
        gg.log("Invalid cooldown update data:", data)
        return
    end

    local skill = skills[data.skillId]
    if not skill then
        gg.log("Skill not found for cooldown update:", data.skillId)
        return
    end

    skill.cooldownCache = data.cooldown
end

-- 处理技能可释放状态更新事件
---@param data {cmd: string, castabilityData: table<string, boolean>}
function HudCards:OnUpdateSkillCastability(data)
    if not data or not data.castabilityData then return end

    -- 更新主卡可释放状态
    if self.mainCardButton then
        for slotId, skill in pairs(self.mainCardData) do
            local canCast = data.castabilityData[skill.skillId]
            if canCast ~= nil then
                self.mainCardButton:SetTouchEnable(canCast)
            end
            break -- 只有一个主卡
        end
    end

    -- 更新副卡可释放状态
    if not self.cardsList then return end

    -- 获取排序后的槽位列表
    local subCardSlots = {}
    for slotId, skill in pairs(self.subCardData) do
        table.insert(subCardSlots, slotId)
    end
    table.sort(subCardSlots)

    -- 遍历所有副卡
    for i, slotId in ipairs(subCardSlots) do
        local card = self.cardsList:GetChild(i) ---@type ViewButton
        local skill = self.subCardData[slotId]

        if skill then
            local canCast = data.castabilityData[skill.skillId]
            if canCast ~= nil then
                card:SetTouchEnable(canCast)
            end
        end
    end
end

function HudCards:UpdateCardsDisplay()
    -- 更新主卡显示
    self:UpdateMainCardDisplay()

    -- 更新副卡显示
    self:UpdateSubCardDisplay()
end

-- 更新主卡显示
function HudCards:UpdateMainCardDisplay()
    if not self.mainCardButton then return end

    -- 查找主卡数据（主卡槽位通常是1000）
    local mainCardSkill = nil
    local mainCardSlot = nil
    for slotId, skill in pairs(self.mainCardData) do
        mainCardSkill = skill
        mainCardSlot = slotId
        break -- 取第一个主卡（目前只有一个主卡槽位）
    end

    if mainCardSkill and mainCardSkill.skillType then
        -- 更新主卡按钮显示
        local cardName = mainCardSkill.skillName
        self.mainCardButton.node["框体"]["Text"].Title = cardName

        -- 绑定主卡长按卸下事件
        self.mainCardButton.longPressCb = function(ui, button)
            gg.log("长按主卡，发送卸下装备请求:", mainCardSkill.skillName)
            self:SendUnequipRequest(mainCardSkill.skillName)
        end
        
        -- 绑定主卡点击事件
        self.mainCardButton.clickCb = function(ui, button)
            -- 检查技能是否在冷却中
            local currentTime = os.clock()
            local lastCastTime = lastCastTimes[mainCardSkill.skillId]
            if lastCastTime and mainCardSkill.cooldownCache > 0 then
                local elapsedTime = currentTime - lastCastTime
                local remainingTime = math.max(0, mainCardSkill.cooldownCache - elapsedTime)
                if remainingTime > 0 then
                    return -- 在冷却中，不处理点击事件
                end
            end

            -- 释放主卡技能
            local direction = CameraController.GetForward()
            local targetPos = CameraController.RaytraceScene({1})
            lastCastTimes[mainCardSkill.skillId] = os.clock()
            gg.network_channel:FireServer({
                cmd = "CastSpell",
                skill = mainCardSkill.skillId,
                targetPos = targetPos,
                direction = direction
            })
            gg.log("释放主卡技能:", mainCardSkill.skillName)
        end

        gg.log("更新主卡显示:", mainCardSkill.skillName, "等级:", mainCardSkill.level)
    else
        self.mainCardButton.node["框体"]["Text"].Title = "未装备"
        -- 清除事件绑定
        self.mainCardButton.clickCb = nil
        self.mainCardButton.longPressCb = nil
        gg.log("更新主卡显示:")
        if self.mainCardButton.node["Title"] then
            self.mainCardButton.node["Title"].Title = "未装备"
        end
        if self.mainCardButton.node["Text"] then
            self.mainCardButton.node["Text"].Title = ""
        end
        gg.log("主卡未装备")
    end
end

-- 更新副卡显示
function HudCards:UpdateSubCardDisplay()
    if not self.cardsList then return end

    -- 直接从self.subCardData获取槽位列表并排序
    local subCardSlots = {}
    for slotId, skill in pairs(self.subCardData) do
        table.insert(subCardSlots, slotId)
    end
    table.sort(subCardSlots) -- 按槽位ID排序

    -- 设置副卡列表大小
    self.cardsList:SetElementSize(#subCardSlots)

    -- 直接遍历self.subCardData更新显示
    for i, slotId in ipairs(subCardSlots) do
        local card = self.cardsList:GetChild(i) ---@type ViewButton
        local skill = self.subCardData[slotId]
        card.node.Name = skill.skillName

        if skill and skill.skillType then
            -- 有技能时显示技能信息
            card.node["名字"].Title = skill.skillType.displayName or skill.skillName
            card.node["等级"].Title = tostring(skill.level)
            local icon = skill.skillType.icon
            if icon and icon ~= "" then
                card.node["图标"].Icon = icon
            end
            gg.log("更新副卡显示 槽位" .. slotId .. ":", skill.skillName, "等级:", skill.level)
        end
    end

    -- 重新绑定副卡事件
    self:RebindSubCardEvents()
end

-- 重新绑定副卡事件（基于新的subCardData）
function HudCards:RebindSubCardEvents()
    if not self.cardsList then return end

    -- 获取排序后的槽位列表
    local subCardSlots = {}
    for slotId, skill in pairs(self.subCardData) do
        table.insert(subCardSlots, slotId)
    end
    table.sort(subCardSlots)

    -- 为每个副卡按钮重新绑定事件
    for i, slotId in ipairs(subCardSlots) do
        local card = self.cardsList:GetChild(i) ---@type ViewButton
        ---@type Skill
        local skill = self.subCardData[slotId]
        gg.log("重新绑定副卡事件",subCardSlots,slotId,skill )

        if skill then
            -- 设置长按卸下装备功能
            card.longPressCb = function(ui, btn)
                gg.log("长按副卡，发送卸下装备请求:", skill.skillName)
                self:SendUnequipRequest(skill.skillName)
            end
            
            -- 设置触摸回调
            card.touchBeginCb = function(ui, btn, vector2)
                -- 检查技能是否在冷却中
                local currentTime = os.clock()
                local lastCastTime = lastCastTimes[skill.skillName]
                if lastCastTime and skill.cooldownCache > 0 then
                    local elapsedTime = currentTime - lastCastTime
                    local remainingTime = math.max(0, skill.cooldownCache - elapsedTime)
                    if remainingTime > 0 then
                        return -- 在冷却中，不处理触摸事件
                    end
                end

                local postProcessing = game.WorkSpace["Environment"].PostProcessing
                postProcessing.ChromaticAberrationIntensity = 0.5
                postProcessing.ChromaticAberrationStartOffset = 0.9
                postProcessing.ChromaticAberrationIterationStep = 5
                postProcessing.ChromaticAberrationIterationSamples = 4

                self:SetFov(30)
                self.touchBeginPos = vector2
                self.selectedCardSlot = slotId -- 改为使用slotId
                self.selectedSkill = skill -- 直接存储技能对象
            end

            card.touchEndCb = function(ui, btn)
                -- 检查技能是否在冷却中
                local currentTime = os.clock()
                local lastCastTime = lastCastTimes[skill.skillName]
                if lastCastTime and skill.cooldownCache > 0 then
                    local elapsedTime = currentTime - lastCastTime
                    local remainingTime = math.max(0, skill.cooldownCache - elapsedTime)
                    if remainingTime > 0 then
                        return -- 在冷却中，不处理触摸事件
                    end
                end

                local postProcessing = game.WorkSpace["Environment"].PostProcessing
                postProcessing.ChromaticAberrationIntensity = 1
                postProcessing.ChromaticAberrationStartOffset = 0.4
                postProcessing.ChromaticAberrationIterationStep = 0.0
                postProcessing.ChromaticAberrationIterationSamples = 1

                self:SetFov(75)

                -- 发送技能释放事件（使用新的数据结构）
                if self.selectedSkill then

                    local skillName = skill.skillName
                    gg.log("释放副卡技能:",self.selectedSkill,skillName,self.selectedSkill[skillName])
                    local direction = CameraController.GetForward()
                    local targetPos = CameraController.RaytraceScene({1})
                    lastCastTimes[skillName] = os.clock()
                    gg.network_channel:FireServer({
                        cmd = "CastSpell",
                        skill = skill,
                        targetPos = targetPos,
                        direction = direction
                    })
                    gg.log("释放副卡技能:", self.selectedSkill[skillName])
                end
            end

            card.touchMoveCb = function(ui, btn, vector2)
                -- 检查技能是否在冷却中
                local currentTime = os.clock()
                local lastCastTime = lastCastTimes[skill.skillName]
                if lastCastTime and skill.cooldownCache > 0 then
                    local elapsedTime = currentTime - lastCastTime
                    local remainingTime = math.max(0, skill.cooldownCache - elapsedTime)
                    if remainingTime > 0 then
                        return -- 在冷却中，不处理触摸事件
                    end
                end

                if not self.touchBeginPos then return end

                -- 计算移动的距离
                local moveDistance = vector2 - self.touchBeginPos
                -- 更新按下的位置
                self.touchBeginPos = vector2

                -- 移动相机
                CameraController.InputMove(
                    moveDistance.x,
                    moveDistance.y
                )
            end
        end
    end
end

function HudCards:OnDestroy()
    if updateTaskId then
        ClientScheduler.cancel(updateTaskId)
        updateTaskId = nil
    end
end

function HudCards:RegisterEventFunction()
    gg.log("self.CardpackButton",self.CardpackButton)

    if self.CardpackButton then
        self.CardpackButton.clickCb = function (ui, button)
            gg.log(ViewBase["CardsGui"],"点击事件")
            ViewBase["CardsGui"]:Open()
        end
    end

end
function HudCards:OnInit(node, config)
    self.mainCardButton =  self:Get("主卡按钮", ViewButton) ---@type ViewButton
    self.CardpackButton = self:Get("卡包", ViewButton) ---@type ViewButton
    self.mainCardData = {} ---@type <string, Skill>
    self.subCardData = {} ---@type <number, Skill>
    self.selectedSkill ={} ---@type <string, Skill>
    -- 注册技能同步事件监听
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.SYNC_SKILLS, function(data)
        self:OnSyncPlayerSkills(data)
    end)

    -- 注册技能冷却更新事件监听
    ClientEventManager.Subscribe("EquipSkillCooldownUpdate", function(data)
        self:OnEquipSkillCooldownUpdate(data)
    end)

    -- 注册技能可释放状态更新事件监听
    ClientEventManager.Subscribe("UpdateSkillCastability", function(data)
        self:OnUpdateSkillCastability(data)
    end)

    -- 注册卸下装备响应事件监听
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.UNEQUIP, function(data)
        self:OnUnequipSkillResponse(data)
    end)

    -- 注册装备技能响应事件监听
    ClientEventManager.Subscribe(SkillEventConfig.RESPONSE.EQUIP, function(data)
        self:OnEquipSkillResponse(data)
    end)

    -- 创建冷却更新任务
    updateTaskId = ClientScheduler.add(function()
        self:UpdateCooldownDisplay()
    end, 0, 0.2)

    self.cardsList = self:Get("副卡列表", ViewList, function(n)
        local button = ViewButton.New(n, self)
        gg.log("副卡列表", button, button.node.Name)
        -- 注意：具体的事件绑定由RebindSubCardEvents方法在数据同步后动态绑定
        return button
    end) ---@type ViewList<ViewButton>
    self:RegisterEventFunction()
    
    -- ClientScheduler.add(function ()
    --     gg.log("HudMenu:OnInit", ViewBase.GetUI("ForceClickHud"), self:Get("卡包", ViewButton))
    --     ViewBase.GetUI("ForceClickHud"):FocusOnNode(self:Get("卡包", ViewButton).node)
    -- end, 1)
end

-- === 新增：发送卸下装备请求 ===
---@param skillName string 要卸下的技能名称
function HudCards:SendUnequipRequest(skillName)
    gg.log("发送卸下装备请求:", skillName)
    gg.network_channel:FireServer({
        cmd = SkillEventConfig.REQUEST.UNEQUIP,
        skillName = skillName
    })
end

-- === 新增：处理装备技能响应 ===
---@param data table 装备技能响应数据 {skillName: string, slot: number}
function HudCards:OnEquipSkillResponse(data)
    if not data or not data.data then
        gg.log("装备技能响应数据无效:", data)
        return
    end
    
    local responseData = data.data
    local skillName = responseData.skillName
    local slot = responseData.slot
    
    gg.log("收到装备技能响应:", skillName, "槽位:", slot)
    
    -- 获取技能对象
    local skill = skills[skillName]
    if not skill then
        gg.log("未找到技能对象:", skillName)
        return
    end
    
    -- 更新技能装备槽位
    skill.equipSlot = slot
    
    -- 获取技能类型配置
    local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig
    local skillType = SkillTypeConfig.Get(skillName)
    
    if skillType then
        -- 根据技能类型更新对应的数据结构
        if skillType.skillType == 0 then
            -- 主卡技能
            self.mainCardData[slot] = skill
            gg.log("装备主卡技能:", skillName, "槽位:", slot)
        elseif skillType.skillType == 1 then
            -- 副卡技能
            self.subCardData[slot] = skill
            gg.log("装备副卡技能:", skillName, "槽位:", slot)
        end
        
        -- 更新装备技能列表
        equippedSkills[slot] = skillName
    end
    
    -- 重新更新卡片显示
    self:UpdateCardsDisplay()
    
    gg.log("装备技能处理完成:", skillName, "槽位:", slot)
end

-- === 新增：处理卸下装备响应 ===
---@param data table 卸下装备响应数据 {skillName: string, slot: number, level: number}
function HudCards:OnUnequipSkillResponse(data)
    if not data or not data.data then
        gg.log("卸下装备响应数据无效:", data)
        return
    end
    
    local responseData = data.data
    local skillName = responseData.skillName
    local oldSlot = nil
    
    gg.log("收到卸下装备响应:", skillName, "新槽位:", responseData.slot)
    
    -- 从主卡数据中移除
    for slotId, skill in pairs(self.mainCardData) do
        if skill.skillName == skillName then
            oldSlot = slotId
            self.mainCardData[slotId] = nil
            gg.log("从主卡数据中移除技能:", skillName, "原槽位:", slotId)
            break
        end
    end
    
    -- 从副卡数据中移除
    if not oldSlot then
        for slotId, skill in pairs(self.subCardData) do
            if skill.skillName == skillName then
                oldSlot = slotId
                self.subCardData[slotId] = nil
                gg.log("从副卡数据中移除技能:", skillName, "原槽位:", slotId)
                break
            end
        end
    end
    
    -- 更新本地技能数据
    if skills[skillName] then
        skills[skillName].equipSlot = 0  -- 卸下后槽位为0
        gg.log("更新本地技能装备槽位:", skillName, "新槽位: 0")
    end
    
    -- 从装备技能列表中移除
    if oldSlot and equippedSkills[oldSlot] == skillName then
        equippedSkills[oldSlot] = nil
        gg.log("从装备技能列表中移除:", skillName, "槽位:", oldSlot)
    end
    
    -- 重新更新卡片显示（让UpdateCardsDisplay统一处理界面更新）
    self:UpdateCardsDisplay()
    
    gg.log("卸下装备处理完成:", skillName, "原槽位:", oldSlot)
end



return HudCards.New(script.Parent, uiConfig)
