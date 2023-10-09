# PlayerData
Uses DataStore2 and Remotes to allow for a Client Stored Cache of the player's PlayerData.
PlayerData Keys can be set to clientReadOnly which will make the Server verify that those keys are not set.

PlayerData is automatically grabbed from DataStore upon Client init,
and any changes made to the PlayerData on the server will be automatically replicated to the client.

Initialize by requiring the module on Server and Client.

## Server

#### Get the player's PlayerData
```lua
PlayerData:Get(player: Player)
```

#### Set the PlayerData table
```lua
PlayerData:Set(player: Player, new: PlayerData)
```

#### Set the table of a PlayerData Key
```lua
PlayerData:SetKey(player: Player, key: string, new: table)
```

#### Set the Variable of a PlayerData table's key via path
```lua
PlayerData:SetPath(player: Player, path: string, new: any)

--ex.
PlayerData:SetPath(player, "options.FOV", 90)
```

#### Save the PlayerData to the DataStore
```lua
PlayerData:Save(player)
```

## Client

#### Get the player's Client PlayerData Cache
```lua
PlayerData:Get()
```

#### Set the PlayerData table
```lua
PlayerData:Set(new: PlayerData)
```

#### Set the table of a PlayerData Key
```lua
PlayerData:SetKey(key: string, new: table)
```

#### Set the Variable of a PlayerData table's key via path
```lua
PlayerData:SetPath(path: string, new: any)

--ex.
PlayerData:SetPath("options.FOV", 90)
```

#### Save the Client PlayerData Cache to the Server Cache
```lua
PlayerData:Save()
```

## Todo
- Make ChangedKey/ChangedPathValue fire whenever its parent changed is fired.
(KeyPathValue Changed fires its parent KeyChanged)
(KeyChanged Fires its parent Changed)