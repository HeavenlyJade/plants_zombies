local MainStorage     = game:GetService("MainStorage")
local ClientEventManager = require(MainStorage.code.client.event.ClientEventManager) ---@type ClientEventManager

local ScreenSizeImage = script.Parent ---@cast ScreenSizeImage UIImage
ClientEventManager.Subscribe("GetScreenSize", function (evt)
    evt.size = ScreenSizeImage.Size
end)