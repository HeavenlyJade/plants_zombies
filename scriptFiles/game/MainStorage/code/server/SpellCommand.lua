-- Variable operation command
---@param cmd VariableCommand
---@param player Player
---@param target Player
---@param param CastParam
function SpellCommand:OnVariableCommand(cmd, player, target, param)
    local value = tonumber(cmd.value)
    if not value then
        print("Variable value must be a number")
        return
    end

    local targetPlayer = target
    if cmd.target == "self" then
        targetPlayer = player
    elseif cmd.target == "target" then
        targetPlayer = target
    end

    if not targetPlayer then
        print("Target player not found")
        return
    end

    -- Get player variables
    local vars = targetPlayer:GetVars()
    if not vars then
        print("Player variables do not exist")
        return
    end

    -- Execute variable modification based on operation type
    if cmd.action == "add" then
        vars[cmd.varName] = (vars[cmd.varName] or 0) + value
    elseif cmd.action == "subtract" then
        vars[cmd.varName] = (vars[cmd.varName] or 0) - value
    elseif cmd.action == "set" then
        vars[cmd.varName] = value
    elseif cmd.action == "addAll" then
        for varName, _ in pairs(vars) do
            vars[varName] = (vars[varName] or 0) + value
        end
    elseif cmd.action == "subtractAll" then
        for varName, _ in pairs(vars) do
            vars[varName] = (vars[varName] or 0) - value
        end
    elseif cmd.action == "setAll" then
        for varName, _ in pairs(vars) do
            vars[varName] = value
        end
    end

    -- Sync variables to client
    targetPlayer:SendEvent("VarsUpdate", vars)
end

-- Add VariableCommand handling to OnCommand function
function SpellCommand:OnCommand(cmd, player, target, param)
    if cmd.cmd == "var" then
        self:OnVariableCommand(cmd, player, target, param)
        return
    end
    -- ... existing code ...
end 