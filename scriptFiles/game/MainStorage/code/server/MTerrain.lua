--- V109 miniw-haima

local game = game
local script = script
local print = print
local math  = math
local SandboxNode = SandboxNode
local Enum = Enum
local pairs = pairs

local Vector2 = Vector2
local Vector3 = Vector3
local ColorQuad = ColorQuad


local MainStorage = game:GetService("MainStorage")
local gg                = require(MainStorage.code.common.MGlobal)    ---@type gg
--local common_const      = require(MainStorage.code.common.MConst)     ---@type common_const

local Scene   = require(MainStorage.code.server.Scene)           ---@type Scene

local SceneMgr     = game:GetService("SceneMgr")


-- 地形管理
---@class MTerrain
local  MTerrain = {
    create_task_list = {},    --异步任务列表 建立场景
}


--初始化地形
function MTerrain.init()
    MTerrain.initScene0()
    --MTerrain.initG0base()

    --MTerrain.listenDynamicSceneOp()
end



function MTerrain.initScene0()
    gg.log( '初始化大厅地图场景' )

    local scene_name_ = 'g0'
    local gx_ = game.WorkSpace.Ground[ scene_name_ ] or MainStorage.Ground[ scene_name_ ]
    if  gx_ then
        local scene_ = Scene.New( scene_name_, 0 )
        MTerrain.initTeleportBackG0( scene_ )       --初始化回城
        gg.server_scene_list[ scene_name_ ] = scene_
    end

end


--增加一个地表 多个方块复制
function MTerrain.initG0base()
    local base_ = game.WorkSpace.Ground.g0.base
    for xx=-5, 5 do
        for zz=-5, 5 do
            local base_new_ = base_.base_copy:Clone()
            base_new_.Name = 'base_' .. xx .. '_' .. zz
            base_new_.Parent        = base_
            base_new_.LocalPosition = Vector3.New( xx*100, 0, zz*100 )
            base_new_.LocalScale    = Vector3.New( 1, 1, 1 )
        end
    end
end



--初始化传送门
function MTerrain.initTeleportBackG0( scene_ )
    if  scene_.name == 'g0' then
        --客户端实现特效
    else
        --gx到大厅g0的传送门
        local gx_ = scene_:getGX()
        if  gx_ and gx_.tp0 then
            -- 传送门特效
            local expl = SandboxNode.new('DefaultEffect', gx_.tp0 )
            expl.LocalPosition = Vector3.New( 50, 150, 50 );        --位置

            local function touch_func(node, pos, normal)
                local g0_ = game.WorkSpace.Ground.g0
                if  g0_ then
                    if  node.OwnerUin >= 1000 then
                        MTerrain.changeMap( node.OwnerUin, 'g0' )
                    end
                end
            end
            gx_.tp0.Touched:connect( touch_func )

        end
    end
end



--动态场景回调
function MTerrain.listenDynamicSceneOp()
    SceneMgr.DynamicSceneOpResultServer:Connect(function(optype, workspaceid, result, uin)
        gg.log( 'MTerrain DynamicSceneOpResultServer:', optype, workspaceid, result, uin )
        if     optype == 2 and result == 0 then -- 新建场景成功的时候

            if  MTerrain.create_task_list[1] then
                local scene_name_ = MTerrain.create_task_list[1].name
                local gx_ = game.WorkSpace.Ground[ scene_name_ ] or MainStorage.Ground[ scene_name_ ]
                if  gx_ then
                    local scene_ = Scene:new( { name=scene_name_, sceneid=workspaceid } )
                    scene_:initTerrain()                       --克隆地形
                    MTerrain.initTeleportBackG0( scene_ )      --初始化回城
                    gg.server_scene_list[ scene_name_ ] = scene_

                    --如果有uin，开始切换场景
                    local uin_ = MTerrain.create_task_list[1].uin
                    if  uin_ then
                        SceneMgr:DynamicSwitchScene(uin_, workspaceid)
                    end
                end
            end
            table.remove( MTerrain.create_task_list, 1)


        elseif optype == 1 and result == 0 then -- 切换场景成功
            -- 在客户端进行切换

            --[[
            local player_ = gg.server_players_list[ uin ]
            local workspace  = game:GetWorkSpace( workspaceid )
            if  workspace then
                gg.log( "======1=========", workspaceid, player_.pre_scene_name, workspace )
                local pos_
                if  player_.pre_scene_name == 'g0' then
                    --pos_ = scene_:WaitForChild( "SpawnLocation1" ).Position
                    pos_ = Vector3.New( -776, 800, 1000 )
                else
                    pos_ = workspace:WaitForChild( "Ground" ):WaitForChild( player_.pre_scene_name ).Position
                end
                gg.playerTeleportToPostion( player_, pos_, player_.pre_scene_name )
                player_.pre_scene_name = nil
            end
            --]]

        elseif optype == 3 and result == 0 then -- 删除场景得时候

        end
    end)
end





--将玩家转移到新场景
function MTerrain.changeMap( uin_, scene_name_ )
    gg.log( 'call changeMap:', uin_, scene_name_ )

    local player_ = gg.server_players_list[ uin_ ]
	if  player_ then

		local scence_ = gg.server_scene_list[ scene_name_ ]
		if  not scence_ then
            local scene_ = Scene:new( { name=scene_name_, sceneid=0 } )   --都在0号workspace
            scene_:initTerrain()                       --克隆地形
            MTerrain.initTeleportBackG0( scene_ )      --初始化回城
            gg.server_scene_list[ scene_name_ ] = scene_
        end

        --开始跳转
        local  pos_    --必要元素
        if  scene_name_ == 'g0' then
            pos_ = game.WorkSpace:WaitForChild( "SpawnLocation1" ).Position
        else
            pos_ = game.WorkSpace:WaitForChild( "Ground" ):WaitForChild( scene_name_ ).Position
        end
        gg.playerTeleportToPostion( player_, pos_, scene_name_ )

    end
end



--改动workspace的处理方法 ( bak 未使用 )
function MTerrain.changeMap_ChangeWorkSpace( uin_, scene_name_ )
    gg.log( 'call changeMap:', uin_, scene_name_ )

    local player_ = gg.server_players_list[ uin_ ]
    if  player_ then
        --if  player_.scene_name == scene_name_ then
            --gg.log( 'current scene_name not change, abort changeMap.', player_.uin, scene_name_ )
            --return
        --end

        player_.pre_scene_name = scene_name_      --预计改动的场景名

        --是否是切回大厅
        if  scene_name_ == 'g0' then
            gg.network_channel:fireClient( uin_, { cmd='cmd_change_workspace', uin=uin_, sceneid=0 } )   --回城
            return
        end


		local scence_ = gg.server_scene_list[ scene_name_ ]
		if  scence_ then
            --直接跳转
            SceneMgr:DynamicSwitchScene(uin_, scence_.sceneid )
        else
            --建立场景
			local gx_ = game.WorkSpace.Ground[ scene_name_ ] or MainStorage.Ground[ scene_name_ ]
			if  gx_ then
                table.insert( MTerrain.create_task_list, { name=scene_name_, uin=uin_ } )
                SceneMgr:AddDynamicScene()
			end
		end
	end
end


--客户端切换场景成功，通知服务器，重新核对一次
function MTerrain.handleChangeWorkSpaceOk( uin_, sceneId_ )
    if  sceneId_ == 0 then
        local player_ = gg.server_players_list[ uin_ ]
        if  player_ then
            player_:ChangeScene( player_.pre_scene_name )
        end
    end
end


return MTerrain;
