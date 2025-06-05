--- V109 miniw-haima

local game     = game
local pairs    = pairs
local ipairs   = ipairs
local type     = type
local SandboxNode = SandboxNode
local Vector2  = Vector2
local Vector3  = Vector3
local ColorQuad = ColorQuad
local Enum = Enum
local wait = wait
local math = math
local os   = os


local MainStorage = game:GetService("MainStorage")
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
local common_const      = require(MainStorage.code.common.MConst)     ---@type common_const
local Player       = require(MainStorage.code.server.entity_types.Player)          ---@type Player
local MTerrain      = require(MainStorage.code.server.MTerrain)         ---@type MTerrain
local bagMgr        = require(MainStorage.code.server.bag.BagMgr)          ---@type BagMgr
local cloudDataMgr  = require(MainStorage.code.server.MCloudDataMgr)    ---@type MCloudDataMgr
local ServerEventManager = require(MainStorage.code.server.event.ServerEventManager) ---@type ServerEventManager
local ServerScheduler = require(MainStorage.code.server.ServerScheduler) ---@type ServerScheduler
-- 总入口
---@class MainServer
local MainServer = {};
local initFinished = false;
local waitingPlayers = {} -- 存储等待初始化的玩家


function MainServer.start_server()
    math.randomseed(os.time() + os.clock())
    gg.uuid_start = gg.rand_int_between(100000, 999999)
    MainServer.register_player_in_out()   --玩家进出游戏

    gg.log('主服务器开始初始化');
    MainServer.initModule()
    MTerrain.init()                       --地形管理
    MainServer.createNetworkChannel()     --建立网络通道
    wait(1)                               --云服务器启动配置文件下载和解析繁忙，稍微等待
    MainServer.bind_update_tick()         --开始tick
    initFinished = true

    -- 处理等待中的玩家
    for _, player in ipairs(waitingPlayers) do
        MainServer.player_enter_game(player)
    end
    waitingPlayers = {} -- 清空等待列表
end


function MainServer.initModule()
    local CommandManager = require(MainStorage.code.server.CommandSystem.MCommandManager) ---@type CommandManager
    local cloudMailData = require(MainStorage.code.server.cloudData.cloudMailData) ---@type CloudMailData
    local SkillEventManager = require(MainStorage.code.server.spells.SkillEventManager) ---@type SkillEventManager

    gg.CommandManager = CommandManager    -- 挂载到全局gg对象上以便全局访问
    gg.cloudMailData = cloudMailData:Init()
    SkillEventManager.Init()

end

-- --设置碰撞组
-- function MainServer.SetCollisionGroup()
--     --设置碰撞组
--     local WS = game:GetService("PhysXService")
--     WS:SetCollideInfo(0, 0, false)   --玩家不与玩家碰撞
--     WS:SetCollideInfo(1, 1, false)   --怪物不与怪物碰撞
--     WS:SetCollideInfo(0, 1, false)   --玩家不与怪物碰撞
-- end

--注册玩家进游戏和出游戏消息
function MainServer.register_player_in_out()
    local players = game:GetService("Players")

    players.PlayerAdded:Connect(function(player)
        gg.log('====PlayerAdded', player.UserId)
        if initFinished then
            MainServer.player_enter_game(player)
        else
            table.insert(waitingPlayers, player)
            gg.log('====PlayerAdded to waiting list', player.UserId)
        end
    end)

    players.PlayerRemoving:Connect(function(player)
        gg.log('====PlayerRemoving', player.UserId)
        -- 如果玩家在等待列表中，需要移除
        for i, waitingPlayer in ipairs(waitingPlayers) do
            if waitingPlayer.UserId == player.UserId then
                table.remove(waitingPlayers, i)
                break
            end
        end
        MainServer.player_leave_game(player)
    end)
end

--玩家进入游戏，数据加载
function MainServer.player_enter_game(player)
    gg.network_channel:fireClient(player.UserId, {cmd = "cmd_update_player_ui",{}})
    player.DefaultDie = false   --取消默认死亡

    local uin_ = player.UserId
    if gg.server_players_list[uin_] then
        gg.log('WAINING, Same uin enter game:', uin_)

        --强制离开游戏
        if gg.server_players_list[uin_] then
            gg.server_players_list[uin_]:Save()
        end
    end

    local actor_ = player.Character
    actor_.CollideGroupID = 4
    actor_.Movespeed = 800
    -- actor_.ModelId = 'sandboxSysId://entity/130034/body.omod'    --默认渔民女
    -- actor_:AddAttribute("model_type", Enum.AttributeType.String)
    -- actor_:SetAttribute("model_type", "player")

    --加载数据 1 玩家历史等级经验值
    local ret1_, cloud_player_data_ = cloudDataMgr.ReadPlayerData(uin_)
    if ret1_ == 0 then
        gg.log('clould_player_data ok:', uin_, cloud_player_data_)
        gg.network_channel:fireClient(uin_, { cmd="cmd_client_show_msg", txt='加载玩家等级数据成功' })     --飘字
    else
        gg.log('clould_player_data fail:', uin_, cloud_player_data_)
        gg.network_channel:fireClient(uin_, { cmd="cmd_client_show_msg", txt='加载玩家等级数据失败，请退出游戏后重试' })    --飘字
        return   --加载数据网络层失败
    end

    -- 玩家信息初始化
    local player_ = Player.New({
        position = Vector3.New(600, 400, -3400),      --(617,292,-3419)
        uin=uin_,
        id=1,
        nickname=player.Nickname,
        npc_type=common_const.NPC_TYPE.PLAYER,
        level = cloud_player_data_.level,
        exp = cloud_player_data_.exp,
    })
    player_.variables = cloud_player_data_.vars or {}

    --加载数据 2 玩家历史装备数据
    local ret2_, cloud_player_bag_ = cloudDataMgr.ReadPlayerBag(player_)
    if ret2_ == 0 then
        gg.log('cloud_player_bag ok:', uin_)
        player_:SendHoverText('加载玩家背包数据成功')
        bagMgr.setPlayerBagData(uin_, cloud_player_bag_)
    else
        gg.log('cloud_player_bag fail:', uin_)
        player_:SendHoverText('加载玩家背包数据失败，请退出游戏后重试')
        return     --加载背包数据失败
    end

    cloudDataMgr.ReadGameTaskData(player_)
    local mail_player_data_ = gg.cloudMailData:OnPlayerLogin(uin_)
    player_.bag = cloud_player_bag_
    player_.mail = mail_player_data_
    gg.server_players_list[uin_] = player_
    gg.server_players_name_list[player.Nickname] = player_

    actor_.Size = Vector3.New(120, 160, 120)      --碰撞盒子的大小
    actor_.Center = Vector3.New(0, 80, 0)      --盒子中心位置

    player_:setGameActor(actor_)     --player
    actor_.CollideGroupID = 4
    player_:ChangeScene('g0')       --默认g0大厅

    player_:setPlayerNetStat(common_const.PLAYER_NET_STAT.LOGIN_IN)    --player_net_stat login ok

    player_:initSkillData()                 --- 加载玩家技能
    player_:RefreshStats()               --重生 --刷新战斗属性
    player_:SetHealth(player_.maxHealth)
    player_:UpdateHud()
end

--玩家离开游戏
function MainServer.player_leave_game(player)
    gg.log("player_leave_game====", player.UserId, player.Name, player.Nickname)
    local uin_ = player.UserId

    if gg.server_players_list[uin_] then
        gg.server_players_list[uin_]:Save()
    end
    gg.server_players_name_list[player.Name] = nil
    gg.server_players_list[uin_] = nil
end

--建立网络通道
function MainServer.createNetworkChannel()
    --begin listen
    gg.network_channel = MainStorage:WaitForChild("NetworkChannel")
    gg.network_channel.OnServerNotify:Connect(MainServer.OnServerNotify)
    gg.log('服务端的网络通道建立完成')

end

--消息回调 (优化版本，使用命令表和错误处理)
function MainServer.OnServerNotify(uin_, args)
    -- 参数校验
    if type(args) ~= 'table' then return end
    if not args.cmd then return end

    local player_ = gg.getPlayerByUin(uin_)
    args.player = player_
    ServerEventManager.Publish(args.cmd, args)
    return

end

--开启update
function MainServer.bind_update_tick()
    -- 一个定时器, 实现tick update
    local timer = SandboxNode.New("Timer", game.WorkSpace)
    timer.LocalSyncFlag = Enum.NodeSyncLocalFlag.DISABLE

    timer.Name = 'timer_server'
    timer.Delay = 0.1      -- 延迟多少秒开始
    timer.Loop = true      -- 是否循环
    timer.Interval = 0.03   -- 循环间隔多少秒 (1秒=20帧)
    timer.Callback = MainServer.update
    timer:Start()     -- 启动定时器
    gg.timer = timer;
end

--定时器update
function MainServer.update()
    gg.tick = gg.tick + 1

    --更新场景
    for _, scene_ in pairs(gg.server_scene_list) do
        scene_:update()
    end
    ServerScheduler.tick = gg.tick  -- 对于服务器端
    ServerScheduler.update()  -- 对于服务器端
end

return MainServer;
