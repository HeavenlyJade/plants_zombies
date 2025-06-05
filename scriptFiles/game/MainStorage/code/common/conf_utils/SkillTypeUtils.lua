local MainStorage = game:GetService('MainStorage')
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local SkillTypeConfig = require(MainStorage.code.common.config.SkillTypeConfig) ---@type SkillTypeConfig

---@class SkillTreeNode
---@field name string                -- 技能名称
---@field data table                 -- 技能配置（SkillTypeConfig里的内容）
---@field children SkillTreeNode[]   -- 子节点（下一技能）
---@field parents SkillTreeNode[]    -- 父节点（前置技能）

---@class SkillTypeUtils
local SkillTypeUtils = {
    nodeCache = {},  ---@type SkillTreeNode[]
    forest = {}, ---@type table<string, SkillTreeNode> -- 节点缓存
    lastForest = nil, ---@type table<string, SkillTreeNode> -- 最近一次构建的技能森林

}

-- 工具函数：判断表中是否包含某元素
local function table_contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

-- 建立父子双向连接
local function LinkNodes(parent, child)
    if not table_contains(parent.children, child) then
        table.insert(parent.children, child)
    end
    if not table_contains(child.parents, parent) then
        table.insert(child.parents, parent)
       
    end
end

--- 构建技能森林（DAG结构，拓扑排序）
---@param skillCategory number 技能分类 (0=主卡, 1=副卡)
---@return table<string, SkillTreeNode>  -- 返回的主卡技能树
function SkillTypeUtils.BuildSkillForest(skillCategory)
    -- 清空缓存
    SkillTypeUtils.nodeCache = {}
    SkillTypeUtils.forest = {}
    local nodeCache = {} ---@type SkillTreeNode[]
    local forest = {} ---@type table<string, SkillTreeNode> --

    -- 1. 先为所有技能创建节点
    local allSkills = SkillTypeConfig.GetAll()
    for skillName, skillType in pairs(allSkills) do
        if skillType.skillType == skillCategory then
            nodeCache[skillName] = {
                name = skillName,
                data = skillType,
                children = {},
                parents = {}
            }
        end
    end
    -- 2. 建立所有父子关系
    for skillName, node in pairs(nodeCache) do
        local skillType = node.data
        if skillType.nextSkills then
            for _, nextSkill in ipairs(skillType.nextSkills) do
                local childNode = nodeCache[nextSkill.name]
                if childNode then
                    LinkNodes(node, childNode)
                end
            end
        end
    end
    -- 3. 找到真正的根节点（只在开始时入度为0的节点）
    local rootNodes = {}
    for name, node in pairs(nodeCache) do
        if #node.parents == 0 then
            table.insert(rootNodes, node)
            if node.data.isEntrySkill then
                forest[node.name] = node -- 只有真正的根节点才加入forest
            end
        end
    end

    -- 4. 使用拓扑排序验证图结构的正确性（可选）
    local inDegree = {}
    for name, node in pairs(nodeCache) do
        inDegree[node] = #node.parents
    end

    local queue = {}
    local visited = {}

    -- 将根节点加入队列
    for _, rootNode in ipairs(rootNodes) do
        table.insert(queue, rootNode)
        visited[rootNode] = true
    end

    -- 拓扑排序（用于验证，不用于构建forest）
    while #queue > 0 do
        local node = table.remove(queue, 1)
        for _, child in ipairs(node.children) do
            inDegree[child] = inDegree[child] - 1
            if inDegree[child] == 0 and not visited[child] then
                visited[child] = true
                table.insert(queue, child)
            end
        end
    end
    -- 5. 检查孤立节点（未被遍历到的），但只有入口技能才能作为根节点
    for name, node in pairs(nodeCache) do
        if not visited[node] then
            -- 只有入口技能才能作为技能树根节点
            if node.data.isEntrySkill then
                forest[node.name] = node
                gg.log("⚠️ 发现未连接的入口技能作为独立技能树:", node.name)
            else
                gg.log("⚠️ 发现循环依赖的非入口技能:", node.name, "父节点数:", #node.parents)
            end
        end
    end
    return forest
end

--- 打印技能森林结构，并验证父子连接
---@param forest table<string, SkillTreeNode>  -- 返回的主卡技能树 技能森林
function SkillTypeUtils.PrintSkillForest(forest)
    gg.log("===== 技能森林结构 =====")
    gg.log(string.format("森林包含 %d 棵技能树", (forest and (type(forest)=="table") and (function() local c=0; for _ in pairs(forest) do c=c+1 end; return c end)()) or 0))
    local printedNodes = {}
    -- 检查父子连接一致性
    local function verifyConnections(node)
        for _, parent in ipairs(node.parents) do
            if not table_contains(parent.children, node) then
                gg.log(string.format("⚠️ 连接错误: %s 声称 %s 是父节点，但父节点没有此子节点", node.name, parent.name))
            end
        end
        for _, child in ipairs(node.children) do
            if not table_contains(child.parents, node) then
                gg.log(string.format("⚠️ 连接错误: %s 声称 %s 是子节点，但子节点没有此父节点", node.name, child.name))
            end
        end
    end
    -- 递归打印节点及其子树
    local function printNode(node, depth, isLast)
        local indent = ""
        if depth > 0 then
            indent = string.rep("│   ", depth - 1) .. (isLast and "└── " or "├── ")
        end
        if printedNodes[node] then
            gg.log(indent .. node.name .. " -> [已打印]")
            return
        end
        printedNodes[node] = true
        verifyConnections(node)
        local parentNames = {}
        for _, parent in ipairs(node.parents) do
            table.insert(parentNames, parent.name)
        end
        local childNames = {}
        for _, child in ipairs(node.children) do
            table.insert(childNames, child.name)
        end
        local info = string.format("%s%s", indent, node.name)
        if #parentNames > 0 then
            info = info .. string.format(" (父节点: %s)", table.concat(parentNames, ", "))
        end
        if #childNames > 0 then
            info = info .. string.format(" (子节点: %s)", table.concat(childNames, ", "))
        end
        if node.data.isEntrySkill then
            info = info .. " 🚪"
        end
        gg.log(info)
        for i, child in ipairs(node.children) do
            printNode(child, depth + 1, i == #node.children)
        end
    end
    local idx = 1
    for name, tree in pairs(forest) do
        gg.log(string.format("\n🌳 技能树 %d - 根节点: %s", idx, tree.name))
        printNode(tree, 0, true)
        idx = idx + 1
    end
    -- 检查并打印孤立节点
    local orphanNodes = {}
    for name, node in pairs(SkillTypeUtils.nodeCache) do
        local isInTree = false
        for _, tree in pairs(forest) do
            local function checkNode(current)
                if current == node then return true end
                for _, child in ipairs(current.children) do
                    if checkNode(child) then return true end
                end
                return false
            end
            if checkNode(tree) then
                isInTree = true
                break
            end
        end
        if not isInTree then
            table.insert(orphanNodes, node)
        end
    end
    if #orphanNodes > 0 then
        gg.log("\n⚠️ 警告：发现孤立节点（不在任何技能树中）")
        for _, node in ipairs(orphanNodes) do
            gg.log(string.format("  - %s", node.name))
        end
    end
end

--- 获取技能树的最大深度
---@param node SkillTreeNode 技能树根节点
---@return number 最大深度
function SkillTypeUtils.GetSkillTreeMaxDepth(node)
    if not node or not node.children or #node.children == 0 then
        return 1
    end
    local maxDepth = 0
    for _, child in ipairs(node.children) do
        local childDepth = SkillTypeUtils.GetSkillTreeMaxDepth(child)
        if childDepth > maxDepth then
            maxDepth = childDepth
        end
    end
    return maxDepth + 1
end

-- 在模块返回前重新构建技能森林
SkillTypeUtils.lastForest = SkillTypeUtils.BuildSkillForest(0)
return SkillTypeUtils