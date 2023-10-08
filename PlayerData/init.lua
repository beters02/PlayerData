--[[
    The main shared PlayerData module, (a combination of clientPlayerData, serverPlayerData, playerStats)
    Initialized on Require, must be initialized on Client and Server

    PlayerData.Stats will be ClientReadOnly
]]
local RunService = game:GetService("RunService")
if RunService:IsClient() then
    return require(script:WaitForChild("Client"))
end

local DataStore2 = require(script:WaitForChild("DataStore2"))
local Strings = require(script:WaitForChild("Strings"))
local Default = require(script:WaitForChild("Shared"))
local RemoteFunction = script:WaitForChild("Events").RemoteFunction
local RemoteEvent = script.Events.RemoteEvent

local PlayerData = {}
PlayerData._storecache = {}
PlayerData._def, PlayerData._defOpt = Default.def, Default.defVar

--@summary Get PlayerData
function PlayerData:Get(player: Player)
    return _compareToDefault(player, _getDataSafe(player, true))
end

--@summary Get PlayerData without checking for missing keys
function PlayerData:GetAsync(player: Player)
    return _getDataSafe(player)
end

--@summary Get the value of a specific key from PlayerData
function PlayerData:GetKey(player, key)
    return PlayerData:GetAsync(player)[key]
end

--@summary Get the key of a value from the PlayerData path
function PlayerData:GetPath(player, path) -- path: options.primaryFire
    return Strings.convertPathToInstance(path, PlayerData:Get(player))
end

--@summary Set the PlayerData from a new PlayerData
function PlayerData:Set(player, new, save, wasClientRequest)
    local store = _getStoreSafe(player)
    if wasClientRequest then
        _verifyIncoming(new)
    end
    store:Set(new)
    if save then
        store:Save()
    end
    RemoteEvent:FireClient(player, "SetAsync", new)
    return new
end

--@summary Set a specific key of the PlayerData
function PlayerData:SetKey(player, key, new)
    local playerdata = PlayerData:GetAsync(player)
    playerdata[key] = new
    return PlayerData:Set(player, playerdata)
end

--@summary Set the key of a value from the PlayerData path
function PlayerData:SetPath(player, path, new)
    local playerdata = PlayerData:GetAsync(player)
    Strings.doActionViaPath(path, playerdata, function(gotTableParent, key)
        gotTableParent[key] = new
    end)
    return PlayerData:Set(player, playerdata)
end

--@summary Save the PlayerData
function PlayerData:Save(player)
    _getStoreSafe(player):Save()
end

function PlayerData:ClearPlayerCache(player)
    PlayerData._storecache[player.Name] = nil
end

--@private
--[[Private Module Functions]]
function _serverInvoke(player, action, ...)
    if not PlayerData[action] then
        return false
    end

    return PlayerData[action](PlayerData, player, ..., true)
end

function _serverPlayerAdded(player)
    PlayerData:Get(player)
end

function _serverPlayerRemoving(player)
    task.delay(3, function()
        PlayerData:ClearPlayerCache(player)
    end)
end

function _getStoreSafe(player)
    local store = PlayerData._storecache[player.Name]
    if not store then
        store = DataStore2("PlayerData", player)
        assert(store, "Could not get DataStore")
        PlayerData._storecache[player.Name] = store
    end
    return store
end

function _getDataSafe(player, getTable)
    local store = _getStoreSafe(player)
    local data = (getTable and store.GetTable or store.Get)(store, PlayerData._def)
    assert(data, "Could not get playerdata. PlayerDataSetKey")
    return data
end

function _hardCopy(variant: any)
    local copy
    if type(variant) ~= "table" then
        copy = variant
    else
        copy = {}
        for i,v in pairs(variant) do
            copy[i]=v
        end
    end
    return copy
end

function _verifyIncoming(new)
    local _rep = false
    for i, _ in pairs(new) do
        if PlayerData._defOpt[i] then
            _rep = PlayerData:GetKey(i)
            new[i] = _hardCopy(_rep)
        end
    end
end

--@private
--[[Default Player Data]]

local function compareRecurse(start, defloc)
    local changed = false
    for i, v in pairs(defloc) do
        if not start[i] then
            start[i] = v
            changed = true
        end
        if type(v) == "table" then
            compareRecurse(start[i], defloc[i])
        end
    end
    return changed
end

function _compareToDefault(player, playerData)
    local changed = compareRecurse(playerData, PlayerData._def)
    if changed then
        PlayerData:Set(player, playerData)
        print("Updated PlayerData during Get!")
    end
    return playerData, changed
end


--@run
--[[Script Start]]
RemoteFunction.OnServerInvoke = _serverInvoke

return PlayerData