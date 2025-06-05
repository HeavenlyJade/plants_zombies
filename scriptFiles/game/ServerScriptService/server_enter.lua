
--------------------------------------------------

--- Description：服务器代码入口
--- 服务器启动的时候，会自动加载此代码并执行，再加载其他代码模块 (v109)
--------------------------------------------------

print("Server Side enter begin")

local MainStorage = game:GetService("MainStorage")
local code = MainStorage:WaitForChild('code')
local common = code:WaitForChild('common')
common:WaitForChild('ClassMgr' )

local server = code:WaitForChild('server')

local MainServer = require(server.MServerMain) ---@type MainServer
MainServer.start_server()
print("服务器加载完成")
