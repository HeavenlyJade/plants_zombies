local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local gg = require(MainStorage.code.common.MGlobal) ---@type gg
local common_const = require(MainStorage.code.common.MConst) ---@type common_const
local NpcConfig = require(MainStorage.code.common.config.NpcConfig) ---@type NpcConfig
local AfkSpotConfig = require(MainStorage.code.common.config.AfkSpotConfig) ---@type AfkSpotConfig
local TriggerZoneConfig = require(MainStorage.code.common.config.TriggerZoneConfig) ---@type TriggerZoneConfig
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
local Entity = require(MainStorage.code.server.entity_types.Entity) ---@type Entity

local Monster = require(MainStorage.code.server.entity_types.Monster) ---@type Monster
local Npc = require(MainStorage.code.server.entity_types.Npc) ---@type Npc
local AfkSpot = require(MainStorage.code.server.entity_types.AfkSpot) ---@type AfkSpot
local TriggerZone = require(MainStorage.code.server.entity_types.TriggerZone) ---@type TriggerZone


local BagMgr = require(MainStorage.code.server.bag.BagMgr) ---@type BagMgr

-- 场景类：单个场景实例  g0(入口大厅)
---@class Scene
---@field sceneId number 场景ID
---@field info table 场景信息
---@field name string 场景名称
---@field players table<number, Player> 玩家列表
---@field monsters table<string, Monster> 怪物列表
---@field npcs table<string, Npc> NPC列表
---@field monster_spawns table<string, {count: number, config: table}> 刷怪点管理
---@field drop_boxs table<string, any> 掉落物品列表
---@field scene_config table 当前地图的节点scene刷怪配置
---@field npc_spawn_config table 当前地图的NPC刷新点
---@field tick number 总tick值(递增)
---@field node SandboxNode
local _M = ClassMgr.Class("Scene")

---初始化场景中的NPC
function _M:initNpcs()
    local all_npcs = NpcConfig.GetAll()
    for npc_name, npc_data in pairs(all_npcs) do
        if npc_data["场景"] == self.name then
            local sceneNode = self.node["NPC"]
            gg.log("--服务端NPC面板数据", npc_name, npc_data["场景"], self.name, self.node["NPC"],
                sceneNode[npc_data["节点名"]])
            if sceneNode and sceneNode[npc_data["节点名"]] then
                local actor = sceneNode[npc_data["节点名"]]
                local npc = Npc.New(npc_data, actor)
                self.node2Entity[actor] = npc
                self.npcs[npc.uuid] = npc
                npc:ChangeScene(self)
            end
        end
    end
end

---@return SandboxNode
function _M:Get(path)
    local node = self.node
    local lastPart = ""
    for part in path:gmatch("[^/]+") do -- 用/分割字符串
        if part ~= "" then
            lastPart = part
            if not node then
                gg.log(string.format("场景[%s]获取路径[%s]失败: 在[%s]处节点不存在", self.name, path, lastPart))
                return nil
            end
            node = node[part]
        end
    end
    return node
end

---初始化场景中的挂机点
function _M:initAfkSpots()
    local all_afk_spots = AfkSpotConfig.GetAll()
    gg.log("初始化挂机点", all_afk_spots)
    for afk_name, afk_data in pairs(all_afk_spots) do
        if afk_data["场景"] == self.name then
            local sceneNode = self.node["挂机点"]
            if sceneNode then
                for _, node_name in ipairs(afk_data["节点名"]) do
                    if sceneNode[node_name] then
                        local actor = sceneNode[node_name]
                        local afk_spot = AfkSpot.New(afk_data, actor)
                        afk_spot.scene = self
                        self.node2Entity[actor] = afk_spot
                        self.npcs[afk_spot.uuid] = afk_spot
                        afk_spot:ChangeScene(self)
                    end
                end
            end
        end
    end
    local all_afk_spots = TriggerZoneConfig.GetAll()
    gg.log("初始化挂机点", all_afk_spots)
    for afk_name, afk_data in pairs(all_afk_spots) do
        if afk_data["场景"] == self.name then
            local sceneNode = self.node["挂机点"]
            if sceneNode then
                for _, node_name in ipairs(afk_data["节点名"]) do
                    if sceneNode[node_name] then
                        local actor = sceneNode[node_name]
                        local afk_spot = TriggerZone.New(afk_data, actor)
                        afk_spot.scene = self
                        self.node2Entity[actor] = afk_spot
                        self.npcs[afk_spot.uuid] = afk_spot
                        afk_spot:ChangeScene(self)
                    end
                end
            end
        end
    end
end

---创建新的场景实例
---@param info_ table 场景信息
function _M:OnInit(name, sceneId)
    self.name = name
    self.sceneId = sceneId
    self.players = {} -- 玩家列表  [uin  = Player]
    self.monsters = {} -- 怪物列表  [uuid = Monster]
    self.npcs = {} -- NPC列表
    self.monster_spawns = {} -- 刷怪点管理   [ spawn_name = { count, config } ]
    self.npc_spawns = {}
    self.drop_boxs = {} -- 掉落物品列表
    self.uuid2Entity = {}
    self.node2Entity = {}

    self.tick = 0 -- 总tick值(递增)

    self.scene_config = nil -- 当前地图的节点scene刷怪配置,
    self.npc_spawn_config = {} -- 当前地图的NPC刷新点
    self.node = game.WorkSpace["Ground"][name]
    self.sceneZone = self.node["场景区域"] ---@type TriggerBox
    self.sceneZone.Touched:Connect(function (node)
        print("EnterScene", node)
        if node then
            local entity = Entity.node2Entity[node] ---@type Entity
            if entity then
                entity:ChangeScene(self)
            end
        end
    end)

    self:initNpcs() -- Initialize NPCs after scene creation
    self:initAfkSpots() -- Initialize AfkSpots after scene creation

    -- 创建NPC更新定时任务
    self.npcUpdateTaskId = ServerScheduler.add(function()
        self:update_npcs()
    end, 0, 0.1) -- 立即开始，每秒执行一次
end

---更新所有NPC
function _M:update_npcs()
    for _, npc in pairs(self.npcs) do
        npc:update_npc()
    end
end

function _M:OverlapSphere(center, radius, filterGroup, filterFunc)
    local results = game:GetService('WorldService'):OverlapSphere(radius,
        Vector3.New(center.x, center.y, center.z), false, filterGroup)
    local retActors = {}
    for _, v in ipairs(results) do
        local obj = v.obj
        table.insert(retActors, obj)
        if filterFunc then
            filterFunc(obj)
        end
    end
    return retActors
end

function _M:OverlapSphereEntity(center, radius, filterGroup, filterFunc)
    local nodes = self:OverlapSphere(center, radius, filterGroup, filterFunc)
    local retEntities = {}
    for _, node in ipairs(nodes) do
        local entity = self.node2Entity[node]
        if entity then
            table.insert(retEntities, entity)
        end
    end
    return retEntities
end

function _M:OverlapBox(center, extent, angle, filterGroup, filterFunc)
    local results = game:GetService('WorldService'):OverlapBox(Vector3.New(extent.x, extent.y, extent.z),
        Vector3.New(center.x, center.y, center.z), Vector3.New(angle.x, angle.y, angle.z), false, filterGroup)
    local retActors = {}
    for _, v in ipairs(results) do
        local obj = v.obj
        table.insert(retActors, obj)
        if filterFunc then
            filterFunc(obj)
        end
    end
    return retActors
end

function _M:OverlapBoxEntity(center, extent, angle, filterGroup, filterFunc)
    local nodes = self:OverlapBox(center, extent, angle, filterGroup, filterFunc)
    local retEntities = {}
    for _, node in ipairs(nodes) do
        local entity = self.node2Entity[node]
        if entity then
            table.insert(retEntities, entity)
        end
    end
    return retEntities
end

-- function _M:SelectCylinderTargets(center, radius, height, filterGroup, filterFunc)
--     if radius == 0 or height == 0 then
--         return {}
--     end
--     local cylinderFilter = function(entity)
--         -- 判断是否在半径内，忽略y坐标
--         local centerPos = center
--         print("target", entity)
--         local targetPos = entity:GetPosition()
--         centerPos.y = 0
--         targetPos.y = 0
--         local distance = (centerPos - targetPos).length
--         if distance > radius then
--             return false
--         end
--         if filterFunc then
--             return filterFunc(entity)
--         end
--         return true
--     end
--     local halfHeight = height / 2
--     local results = self:OverlapBoxEntity(Vector3.New(center.x, center.y + halfHeight, center.z),
--         Vector3.New(radius, halfHeight, radius), Vector3.New(0, 0, 0), filterGroup, cylinderFilter)
--     return results
-- end

---初始化地形
function _M:initTerrain()
    local ground_name_ = self.name

    local workspace = game:GetWorkSpace(self.sceneId)
    -- gg.log( 'GetWorkSpace1', workspace )

    if self.sceneId == 0 then
        -- game.WorkSpace
    else
        local environment_ = workspace:WaitForChild('Environment')
        -- gg.log( 'environment_1', environment_ )
        workspace.Environment:Destroy() -- 删除旧地形

        -- 克隆新地形
        local workspace0 = game:GetWorkSpace(0)
        environment_ = workspace0:WaitForChild('Environment'):Clone()
        environment_.Parent = workspace

        if not workspace.Ground then
            local ground_ = SandboxNode.new('SandboxNode', workspace)
            ground_.Name = 'Ground'

            gg.log('GetWorkSpace2', ground_)
        end
    end

    local gx_ = workspace.Ground[ground_name_]
    if not gx_ then
        -- 移动 ground
        if MainStorage.Ground[ground_name_] then
            MainStorage.Ground[ground_name_].Parent = workspace.Ground
            gx_ = workspace.Ground[ground_name_]
        end
    end

    if gx_ then
        if gx_.Visible == false then
            gx_.Visible = true
        end
        -- gx_.Position = Vector3.New(0,0,0)    --坐标改到中心点
    else
        gg.log('scene not exist:', ground_name_)
    end
end

---玩家离开场景
---@param uin_ number 玩家ID
function _M:player_leave(uin_)
    if self.players[uin_] then
        self.players[uin_] = nil
    end
end

---玩家进入场景
---@param uin_ number 玩家ID
function _M:player_enter(uin_)
    if self.players[uin_] then
        -- 已经存在
    else
        local player_ = gg.server_players_list[uin_]
        if player_ then
            self.players[uin_] = player_
        end
    end
end

---获得本场景的workspace
---@return Workspace 工作空间
function _M:GetWorkSpace()
    return game:GetWorkSpace(self.sceneId)
end

---获得场景里的主建筑物gx
---@return SandboxNode|nil 主建筑物节点
function _M:getGX()
    if not self.sceneId then
        gg.log('no sceneId:', self)
        return
    end

    local ws_ = game:GetWorkSpace(self.sceneId)
    if ws_ then
        return ws_.Ground[self.name]
    end
    return nil
end

---按照名字获得功能点的坐标  传送点:'tp0'  怪物出生点:'monster_spawn'
---@param node_name_ string 节点名称
---@return Vector3
function _M:getFunctionPosXYZByName(node_name_)
    local gx_node_ = self:getGX()
    if gx_node_ then
        local node_ = gx_node_[node_name_]
        if node_ then
            return node_.Position.x, node_.Position.y, node_.Position.z
        end
    end
    return 0, 0, 0
end

---直接获得坐标
---@param node_name_ string 节点名称
---@return Vector3|nil 位置向量
function _M:getFunctionPosByName(node_name_)
    local gx_node_ = self:getGX()
    if gx_node_ then
        local node_ = gx_node_[node_name_]
        if node_ then
            return node_.Position
        end
    end
    return nil
end

---通知目标丢失
---@param uuid_ string 怪物UUID
function _M:InfoTargetLost(uuid_)
    -- for uin_, player_ in pairs(self.players) do
    --     if player_.target and player_.target.uuid == uuid_ then
    --         local info_ = {
    --             cmd = 'cmd_sync_target_info',
    --             show = 0,
    --             v = 'lost'
    --         }
    --         gg.network_channel:fireClient(uin_, info_)
    --     end
    -- end
end

---增加一个掉落物箱
---@param item_ table 物品信息
function _M:addDrop(item_)
    item_.tick = gg.tick -- 记录tick
    self.drop_boxs[item_.uuid] = item_
end

---判断物品是否被拾取
function _M:check_drop()
    if not next(self.drop_boxs) then
        return
    end
    -- OwnerUin
    for box_uuid_, box_info_ in pairs(self.drop_boxs) do
        local pos1_ = box_info_.model.Position
        for uin_, player_ in pairs(self.players) do
            local pos2_ = player_:GetPosition()
            if not gg.fast_out_distance(pos1_, pos2_, 200) and box_info_.player_uin == uin_ then
                local player_data_ = BagMgr.GetPlayerBag(uin_)
                local drop_re = player_data_:GiveItem(box_info_)
                gg.log("玩家拾取物品和结果", box_info_, drop_re, uin_)

                if drop_re == 0 then
                    BagMgr.s2c_PlayerBagItems(uin_, {}) -- 刷新玩家背包数据
                    self.drop_boxs[box_uuid_] = nil
                    box_info_.model:Destroy()
                    break
                end
            end
        end
    end
end

---检查玩家是否离开太远
function _M:check_player_alive()
    for _, player_ in pairs(self.players) do
        local gx_node_ = self:getGX()
        local pos1_ = gx_node_.Position
        local pos2_ = player_:GetPosition()
        if gg.fast_out_distance(pos1_, pos2_, 12800) then
            gg.log('player out range', self.name)
            player_.actor.Position = Vector3.New(pos1_.x + gg.rand_int_both(200), pos1_.y + 200 + gg.rand_int(200),
                pos1_.z + gg.rand_int_both(200))
        end
    end
end

---查找附近的一个目标
---@param pos2_ Vector3 目标位置
---@return Player|nil 找到的玩家
function _M:tryGetTarget(pos2_)
    for _, player_ in pairs(self.players) do
        local pos1_ = player_:GetPosition()
        if gg.fast_out_distance(pos1_, pos2_, 2400) == false then
            return player_
        end
    end
    return nil
end

---每一帧更新
function _M:update()
    if next(self.players) == nil then
        return -- 场景内没有玩家
    end
    self.tick = self.tick + 1

    -- 更新每一个玩家
    for _, player_ in pairs(self.players) do
        player_:update_player()
    end
    -- 更新每一个怪物
    for _, monster_ in pairs(self.monsters) do
        monster_:update_monster()
    end

    -- 慢update
    local mod_ = self.tick % 11
    if mod_ == 3 then
        self:check_player_alive()
    -- elseif mod_ == 4 then
    --     self:check_drop()
    end
end

---场景销毁时清理
function _M:OnDestroy()
    -- 取消NPC更新定时任务
    if self.npcUpdateTaskId then
        ServerScheduler.cancel(self.npcUpdateTaskId)
        self.npcUpdateTaskId = nil
    end
end

return _M
