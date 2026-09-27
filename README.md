<p align="center">
  <img src="https://media.discordapp.net/attachments/1490759185129017486/1553531866290851941/walkeserializer.gif?ex=6ab996cc&is=6ab8454c&hm=b000cd0d13e26504408fe4b839b82446553155818a15989a0d6b86700e3bfebc&=&width=512&height=219" width="600" alt="Walke Serializer">
</p>

# Walke Serializer v2.2
**Presented by The Skin Walke Team and it's Owner**

This is not another saveinstance clone, Nuh uh, like most serializers dump whatever they can read and hope Studio opens the file, Walke was built to produce a file that actually loads, keeps what matters, and tells you EXACTLY what it saved and what it couldn't

## What it does
Walke takes any Instance, a list of Instances, or the entire game and writes it to a `.rbxmx` file in your executor's workspace folder, ready to open in Roblox Studio.

## Why it's more than a serializer, I needed to clarify this 😭✌️
- **Validated output** - every file is checked before it's written: root tags, balanced items, duplicate referents, dangling references. A broken file is never saved silently
- **Full property capture** - It reads every exposed property through `getproperties`, backed by a built in registry of 60+ class definitions
- **Minified** - properties equal to the class default are dropped. Smaller files, faster loads
- **Attributes and Tags** - preserved in Roblox native binary format
- **Scripts** - decompiled when your executor supports it. `rescue` rebuilds ModuleScripts that return data tables
- **Terrain** - voxel data is packed into a restorer script that rebuilds the terrain in Studio
- **Unions** - Walke pulls CSG geometry from hidden properties when the executor allows it, use native for full engine level unions, or holo to mark where they are (sounds like I exaggerate in engine level, but i'm not actually this is open source so go ahead and check and skid whatever u want lol)
- **Assets** - optional download of meshes, textures, images and sounds
- **Built for big games** - adaptive yielding so your client doesn't freeze, chunked writes for files over 20 MB
- **Full report** - every save prints instances, properties, attributes, tags, skipped and unsupported props, size, time and validation result

## Commands
Load the script (Or just get in the .lua file directly from this repository)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SkinWalkeClub/Walke-Serializer/main/WalkeSerializer.lua"))()
```
then use `walkesave`. It's also registered as `saveinstance` if your executor doesn't already have one.
```lua
walkesave()                              -- well this is the whole game, saved as <PlaceId>.rbxmx
walkesave(workspace.Map)                 -- one instance, saved as <Name>.rbxmx
walkesave({ workspace.A, workspace.B })  -- several instances, saved as selection.rbxmx
walkesave({ object = workspace.Map, filename = "Map", terrain = true })  -- with options!!!! (u can modify this to your liking, that's why I present the options down there)
```
Options go in the same table as `object`, or under `options = { ... }`.

## Options
```
mode              "safe" (default) | "strict" | "debug" | "silent"
deep              false = registry properties only
minify            false = keep default-valued properties
validate          false = skip output validation
stats             false = no console report
attributes        false = skip attributes
tags              false = skip CollectionService tags
terrain           true  = include terrain restorer script
terrainCap        max terrain size per axis in studs (default 2048)
unions            true  = recover CSG union geometry
holo              true  = red marker parts for unsaved unions
assets            true  = download assets to WalkeAssets/
rescue            true  = rebuild undecompilable ModuleScripts
noScripts         true  = skip all scripts
skipInvisible     true  = skip parts with Transparency 1
respectArchivable true  = skip instances with Archivable off
ignore            { "ClassName", ... } classes to skip
maxDepth          max hierarchy depth (default 4000)
yield             false = no yielding (faster, may freeze)
onProgress        function(instances, items)
shouldCancel      function() return true to cancel
native            true  = hand the whole save to your executor own saveinstance (best unions/meshes)
nativeArgs        { ... } = overrides passed to that native saver
```
**Modes:** `safe` skips unsupported properties quietly, `strict` errors on the first one, `debug` warns on every skip, `silent` prints nothing.

## Module API
The script returns a module table. Store it when you load the script (`local Walke = <what the script returns>`) to use these:
```lua
Walke.serialize(root, options)           -- returns xml, stats, valid, message (no file written)
Walke.save(root, "file.rbxmx", options)  -- returns { ok, stage, xml, stats, err }
Walke.Version                            -- Obviously the actual version which is 2.2
Walke.Capabilities                       -- what your executor supports (very important)
```

## Executor Requirements
**Required:** `writefile`
**Recommended:**
- `getproperties` - full property capture. Without it only registry properties are saved.
- `decompile` - script source
- `gethiddenproperty` or `setscriptable` - unions and MeshPart InitialSize
- `appendfile` + `delfile` - files over 20 MB
- `game:HttpGet` + `makefolder` - asset download

Check `Walke.Capabilities` to see what your executor supports.

## Limits
- ServerScriptService and ServerStorage never reach the client, literally no client side tool can save them, (Walke included and this goes for YOU jaydog)
- Scripts are only as good as your executor decompiler
- Without hidden property access, unions save with no geometry, so use `holo` to mark them
- Terrain is rebuilt by running the injected restorer script in Studio. Terrain larger than terrainCap per axis is skipped.
- Attribute types outside string, bool, number, Vector2/3, Color3, UDim/UDim2, NumberRange, Rect and BrickColor are dropped and counted as `attrLost`
- References to instances outside the save become nil
- Terrain, Camera and CoreGui are excluded from the tree

Created by **Weegee_MLG** on discord
Credits: **The Skin Walke Team <3**
Any Problems or errors please report it on our discord server or this repository

https://discord.gg/cKSWynhPm5
