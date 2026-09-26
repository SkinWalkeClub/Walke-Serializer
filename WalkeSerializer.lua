--=============================================================================
--                        Walke Serializer v2.2
--                 I don't think this will need updates
--               unless Roblox adds new properties, classes,
--              or changes existing types in their engine API
--
--            Created ORIGINALLY by Weegee_MLG (Skin Walke Owner)
--=============================================================================

print("\n" ..
"__       __     _ _          \n" ..
"\\ \\     / /_ _| | | _____   \n" ..
" \\ \\ /\\ / / _` | | |/ / _ \\  \n" ..
"  \\ V  V / (_| | |   <   __/  \n" ..
"   \\_/\\_/ \\__,_|_|_|\\_\\___|  \n" ..
"Credits: The Skin Walke Team\n"
)

local ins = table.insert
local cat = table.concat
local fmt = string.format
local flr = math.floor
local huge = math.huge
local clk = os.clock
local pk = string.pack
local sb = string.byte
local sc = string.char
local gp = getproperties
local dec
local ghp
local sscript
do
	local env = (getgenv and getgenv()) or _G or {}
	if type(decompile) == "function" then
		dec = decompile
	elseif type(env.decompile) == "function" then
		dec = env.decompile
	elseif type(env.getscriptsource) == "function" then
		dec = env.getscriptsource
	elseif type(env.decompilescript) == "function" then
		dec = env.decompilescript
	end
	if type(gethiddenproperty) == "function" then
		ghp = gethiddenproperty
	elseif type(env.gethiddenproperty) == "function" then
		ghp = env.gethiddenproperty
	end
	if type(setscriptable) == "function" then
		sscript = setscriptable
	elseif type(env.setscriptable) == "function" then
		sscript = env.setscriptable
	end
end
local CS
pcall(function() CS = game:GetService("CollectionService") end)

local nsi
do
	local genv = (getgenv and getgenv()) or _G or {}
	local stored = rawget(genv, "__WALKE_NSI")
	if stored == nil then
		local f
		if type(saveinstance) == "function" then f = saveinstance
		elseif type(genv.saveinstance) == "function" then f = genv.saveinstance
		elseif type(synsaveinstance) == "function" then f = synsaveinstance
		elseif type(genv.synsaveinstance) == "function" then f = genv.synsaveinstance end
		genv.__WALKE_NSI = f or false
		nsi = f or nil
	elseif stored then
		nsi = stored
	end
end

local function clean(s)
	return (tostring(s):gsub("[%z\1-\8\11\12\14-\31]", ""))
end

local function e(s)
	s = clean(s)
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"))
end

local function cdata(s)
	return "<![CDATA[" .. (clean(s):gsub("]]>", "]]]]><![CDATA[>")) .. "]]>"
end

local function nf(v)
	if v ~= v or v == huge or v == -huge then return "0" end
	return fmt("%.9g", v)
end

local function u8(x)
	x = flr(x * 255 + 0.5)
	if x < 0 then return 0 elseif x > 255 then return 255 end
	return x
end

local function c8(c)
	return 0xFF000000 + u8(c.R) * 65536 + u8(c.G) * 256 + u8(c.B)
end

local b64c = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64(d)
	local r, n, i = {}, #d, 1
	while i <= n do
		local a = sb(d, i)
		local b = sb(d, i + 1)
		local c = sb(d, i + 2)
		local x = b or 0
		local y = c or 0
		local o1 = flr(a / 4)
		local o2 = (a % 4) * 16 + flr(x / 16)
		local o3 = (x % 16) * 4 + flr(y / 64)
		local o4 = y % 64
		r[#r + 1] = b64c:sub(o1 + 1, o1 + 1)
		r[#r + 1] = b64c:sub(o2 + 1, o2 + 1)
		r[#r + 1] = b and b64c:sub(o3 + 1, o3 + 1) or "="
		r[#r + 1] = c and b64c:sub(o4 + 1, o4 + 1) or "="
		i = i + 3
	end
	return cat(r)
end

local ip = {
	BorderSizePixel = true, ZIndex = true, DisplayOrder = true,
	LayoutOrder = true, Segments = true,
}

local cp = {
	MeshId = true, TextureID = true, TextureId = true, Texture = true,
	Image = true, SoundId = true, HatMeshId = true, ClickIcon = true,
	ColorMap = true, NormalMap = true, MetalnessMap = true, RoughnessMap = true,
	CursorIcon = true, MeshContent = true, TextureContent = true,
}

local skipClass = { Terrain = true, Camera = true }

local bl = {
	Parent = true, ClassName = true, className = true, RobloxLocked = true,
	Capabilities = true, UniqueId = true, HistoryId = true,
	AssemblyLinearVelocity = true, AssemblyAngularVelocity = true,
	CenterOfMass = true, Mass = true, ExtentsSize = true,
	ExtentsCFrame = true, LocalTransparencyModifier = true,
}

local pal = { Position = true, Orientation = true, Rotation = true }

local function insertable(o)
	if skipClass[o.ClassName] then return false end
	return true
end

local function content(n, v)
	if v == "" then return fmt('<Content name="%s"><null></null></Content>', n) end
	return fmt('<Content name="%s"><url>%s</url></Content>', n, e(v))
end

local S = {}

S["string"] = function(n, v)
	if cp[n] then return content(n, v) end
	return fmt('<string name="%s">%s</string>', n, e(v))
end

S["boolean"] = function(n, v)
	return fmt('<bool name="%s">%s</bool>', n, tostring(v))
end

S["number"] = function(n, v)
	if ip[n] then return fmt('<int name="%s">%d</int>', n, flr(v)) end
	return fmt('<float name="%s">%s</float>', n, nf(v))
end

S["Vector3"] = function(n, v, _, bp)
	local nm = (bp and n == "Size") and "size" or n
	return fmt('<Vector3 name="%s"><X>%s</X><Y>%s</Y><Z>%s</Z></Vector3>', nm, nf(v.X), nf(v.Y), nf(v.Z))
end

S["Vector2"] = function(n, v)
	return fmt('<Vector2 name="%s"><X>%s</X><Y>%s</Y></Vector2>', n, nf(v.X), nf(v.Y))
end

S["Vector3int16"] = function(n, v)
	return fmt('<Vector3int16 name="%s"><X>%d</X><Y>%d</Y><Z>%d</Z></Vector3int16>', n, v.X, v.Y, v.Z)
end

S["Vector2int16"] = function(n, v)
	return fmt('<Vector2int16 name="%s"><X>%d</X><Y>%d</Y></Vector2int16>', n, v.X, v.Y)
end

S["Color3"] = function(n, v, _, bp)
	if bp and n == "Color" then
		return fmt('<Color3uint8 name="Color3uint8">%d</Color3uint8>', c8(v))
	end
	return fmt('<Color3 name="%s"><R>%s</R><G>%s</G><B>%s</B></Color3>', n, nf(v.R), nf(v.G), nf(v.B))
end

S["CFrame"] = function(n, v)
	local x, y, z, r0, r1, r2, r3, r4, r5, r6, r7, r8 = v:GetComponents()
	return fmt('<CoordinateFrame name="%s"><X>%s</X><Y>%s</Y><Z>%s</Z><R00>%s</R00><R01>%s</R01><R02>%s</R02><R10>%s</R10><R11>%s</R11><R12>%s</R12><R20>%s</R20><R21>%s</R21><R22>%s</R22></CoordinateFrame>', n, nf(x), nf(y), nf(z), nf(r0), nf(r1), nf(r2), nf(r3), nf(r4), nf(r5), nf(r6), nf(r7), nf(r8))
end

S["EnumItem"] = function(n, v)
	return fmt('<token name="%s">%d</token>', n, v.Value)
end

S["UDim"] = function(n, v)
	return fmt('<UDim name="%s"><S>%s</S><O>%d</O></UDim>', n, nf(v.Scale), flr(v.Offset))
end

S["UDim2"] = function(n, v)
	return fmt('<UDim2 name="%s"><XS>%s</XS><XO>%d</XO><YS>%s</YS><YO>%d</YO></UDim2>', n, nf(v.X.Scale), flr(v.X.Offset), nf(v.Y.Scale), flr(v.Y.Offset))
end

S["BrickColor"] = function(n, v)
	return fmt('<int name="%s">%d</int>', n, v.Number)
end

S["NumberRange"] = function(n, v)
	return fmt('<NumberRange name="%s">%s %s </NumberRange>', n, nf(v.Min), nf(v.Max))
end

S["NumberSequence"] = function(n, v)
	local b = {}
	for _, k in ipairs(v.Keypoints) do
		ins(b, nf(k.Time)); ins(b, nf(k.Value)); ins(b, nf(k.Envelope))
	end
	return fmt('<NumberSequence name="%s">%s </NumberSequence>', n, cat(b, " "))
end

S["ColorSequence"] = function(n, v)
	local b = {}
	for _, k in ipairs(v.Keypoints) do
		ins(b, nf(k.Time)); ins(b, nf(k.Value.R)); ins(b, nf(k.Value.G)); ins(b, nf(k.Value.B)); ins(b, "0")
	end
	return fmt('<ColorSequence name="%s">%s </ColorSequence>', n, cat(b, " "))
end

S["Rect"] = function(n, v)
	return fmt('<Rect2D name="%s"><min><X>%s</X><Y>%s</Y></min><max><X>%s</X><Y>%s</Y></max></Rect2D>', n, nf(v.Min.X), nf(v.Min.Y), nf(v.Max.X), nf(v.Max.Y))
end

S["PhysicalProperties"] = function(n, v)
	return fmt('<PhysicalProperties name="%s"><CustomPhysics>true</CustomPhysics><Density>%s</Density><Friction>%s</Friction><Elasticity>%s</Elasticity><FrictionWeight>%s</FrictionWeight><ElasticityWeight>%s</ElasticityWeight></PhysicalProperties>', n, nf(v.Density), nf(v.Friction), nf(v.Elasticity), nf(v.FrictionWeight), nf(v.ElasticityWeight))
end

S["Font"] = function(n, v)
	local fam, w, st = "", 400, "Normal"
	pcall(function() fam = v.Family end)
	pcall(function() w = v.Weight.Value end)
	pcall(function() st = v.Style.Name end)
	return fmt('<Font name="%s"><Family><url>%s</url></Family><Weight>%d</Weight><Style>%s</Style></Font>', n, e(fam), w, e(st))
end

S["Content"] = function(n, v)
	local u = ""
	pcall(function() u = v.Uri or "" end)
	return content(n, u)
end

S["Faces"] = function(n, v)
	local m = 0
	if v.Right then m = m + 1 end
	if v.Top then m = m + 2 end
	if v.Back then m = m + 4 end
	if v.Left then m = m + 8 end
	if v.Bottom then m = m + 16 end
	if v.Front then m = m + 32 end
	return fmt('<Faces name="%s"><faces>%d</faces></Faces>', n, m)
end

S["Axes"] = function(n, v)
	local m = 0
	if v.X then m = m + 1 end
	if v.Y then m = m + 2 end
	if v.Z then m = m + 4 end
	return fmt('<Axes name="%s"><axes>%d</axes></Axes>', n, m)
end

S["Ray"] = function(n, v)
	local o, d = v.Origin, v.Direction
	return fmt('<Ray name="%s"><origin><X>%s</X><Y>%s</Y><Z>%s</Z></origin><direction><X>%s</X><Y>%s</Y><Z>%s</Z></direction></Ray>', n, nf(o.X), nf(o.Y), nf(o.Z), nf(d.X), nf(d.Y), nf(d.Z))
end

S["Instance"] = function(n, v, refs)
	local id = refs[v]
	if id then return fmt('<Ref name="%s">%s</Ref>', n, id) end
	return ""
end

local function encAttr(t, v)
	if t == "string" then return sc(0x02) .. pk("<I4", #v) .. v
	elseif t == "boolean" then return sc(0x03) .. sc(v and 1 or 0)
	elseif t == "number" then return sc(0x06) .. pk("<d", v)
	elseif t == "Vector2" then return sc(0x10) .. pk("<ff", v.X, v.Y)
	elseif t == "Vector3" then return sc(0x11) .. pk("<fff", v.X, v.Y, v.Z)
	elseif t == "Color3" then return sc(0x0F) .. pk("<fff", v.R, v.G, v.B)
	elseif t == "UDim" then return sc(0x09) .. pk("<fi4", v.Scale, v.Offset)
	elseif t == "UDim2" then return sc(0x0A) .. pk("<fi4fi4", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
	elseif t == "NumberRange" then return sc(0x1B) .. pk("<ff", v.Min, v.Max)
	elseif t == "Rect" then return sc(0x1C) .. pk("<ffff", v.Min.X, v.Min.Y, v.Max.X, v.Max.Y)
	elseif t == "BrickColor" then return sc(0x0E) .. pk("<I4", v.Number)
	end
	return nil
end

local function packAttrs(o)
	local ok, a = pcall(function() return o:GetAttributes() end)
	if not ok or type(a) ~= "table" then return "", 0, 0 end
	local names = {}
	for k in pairs(a) do names[#names + 1] = k end
	if #names == 0 then return "", 0, 0 end
	table.sort(names)
	local body, cnt, lost = {}, 0, 0
	for _, k in ipairs(names) do
		local enc = encAttr(typeof(a[k]), a[k])
		if enc then
			cnt = cnt + 1
			body[#body + 1] = pk("<I4", #k) .. k .. enc
		else
			lost = lost + 1
		end
	end
	if cnt == 0 then return "", 0, lost end
	return fmt('<BinaryString name="AttributesSerialize">%s</BinaryString>', b64(pk("<I4", cnt) .. cat(body))), cnt, lost
end

local function packTags(o)
	if not CS then return "", 0 end
	local ok, t = pcall(function() return CS:GetTags(o) end)
	if not ok or type(t) ~= "table" or #t == 0 then return "", 0 end
	table.sort(t)
	return fmt('<BinaryString name="Tags">%s</BinaryString>', b64(cat(t, "\0") .. "\0")), #t
end

local function badSrc(s)
	if type(s) ~= "string" or s == "" then return true end
	local h = s:sub(1, 64):lower()
	return h:find("empty bytecode", 1, true) ~= nil
		or h:find("failed to decompile", 1, true) ~= nil
		or h:find("decompiler error", 1, true) ~= nil
		or h:find("could not decompile", 1, true) ~= nil
end

local function srcOf(o)
	local s = ""
	if dec then pcall(function() s = dec(o) end) end
	if badSrc(s) then
		s = ""
		pcall(function() s = o.Source end)
	end
	if badSrc(s) then return "" end
	return s
end

local reg = {
	{ "Instance", { "Name" } },
	{ "BasePart", { "Size", "CFrame", "Color", "Material", "MaterialVariant", "Transparency", "Reflectance", "Anchored", "CanCollide", "CanTouch", "CanQuery", "Locked", "Massless", "CastShadow", "CollisionGroup", "CustomPhysicalProperties", "PivotOffset" } },
	{ function(o) return o.ClassName == "Part" end, { "Shape" } },
	{ "DataModelMesh", { "Scale", "Offset", "VertexColor" } },
	{ "FileMesh", { "MeshId", "TextureId" } },
	{ "SpecialMesh", { "MeshId", "TextureId", "MeshType" } },
	{ "Decal", { "Texture", "Face", "Color3", "Transparency", "ZIndex" } },
	{ "Texture", { "StudsPerTileU", "StudsPerTileV" } },
	{ "GuiObject", { "Position", "Size", "AnchorPoint", "Rotation", "Visible", "ZIndex", "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "BorderSizePixel", "BorderMode", "ClipsDescendants", "Active", "Selectable", "AutomaticSize", "SizeConstraint", "LayoutOrder" } },
	{ function(o) return o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") end, { "Text", "TextColor3", "TextSize", "TextTransparency", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "RichText", "LineHeight", "Font", "FontFace", "TextStrokeColor3", "TextStrokeTransparency" } },
	{ "TextBox", { "PlaceholderText", "ClearTextOnFocus", "MultiLine" } },
	{ function(o) return o:IsA("ImageLabel") or o:IsA("ImageButton") end, { "Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize", "ScaleType", "SliceCenter", "SliceScale", "ResampleMode", "TileSize" } },
	{ "LayerCollector", { "Enabled" } },
	{ "ScreenGui", { "DisplayOrder", "IgnoreGuiInset" } },
	{ "UICorner", { "CornerRadius" } },
	{ "UIStroke", { "Thickness", "Color", "Transparency", "ApplyStrokeMode", "LineJoinMode", "Enabled" } },
	{ "UIGradient", { "Color", "Transparency", "Offset", "Rotation", "Enabled" } },
	{ "UIPadding", { "PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight" } },
	{ "UIListLayout", { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" } },
	{ "UIGridLayout", { "CellSize", "CellPadding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder", "StartCorner" } },
	{ "UIScale", { "Scale" } },
	{ "UIAspectRatioConstraint", { "AspectRatio", "AspectType", "DominantAxis" } },
	{ "UISizeConstraint", { "MinSize", "MaxSize" } },
	{ "Humanoid", { "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "HipHeight", "DisplayName", "RigType", "AutoRotate" } },
	{ "Camera", { "CFrame", "FieldOfView" } },
	{ "Sound", { "SoundId", "Volume", "PlaybackSpeed", "Looped", "Playing", "TimePosition", "RollOffMaxDistance", "RollOffMinDistance" } },
	{ "Light", { "Brightness", "Color", "Enabled", "Shadows" } },
	{ "PointLight", { "Range" } },
	{ "SpotLight", { "Range", "Angle" } },
	{ "SurfaceLight", { "Range", "Angle" } },
	{ "ParticleEmitter", { "Rate", "Lifetime", "Speed", "SpreadAngle", "Acceleration", "Drag", "LightEmission", "LightInfluence", "EmissionDirection", "RotSpeed", "ZOffset", "Squash", "Texture", "Color", "Transparency", "Size", "Rotation", "Enabled" } },
	{ "Beam", { "Attachment0", "Attachment1", "Texture", "Color", "Transparency", "Width0", "Width1", "FaceCamera", "Segments", "CurveSize0", "CurveSize1", "TextureLength", "TextureSpeed", "LightEmission", "LightInfluence", "Enabled" } },
	{ "Trail", { "Attachment0", "Attachment1", "Texture", "Color", "Transparency", "Lifetime", "FaceCamera", "Enabled" } },
	{ "LuaSourceContainer", { "Enabled", "Disabled", "RunContext", "Source" } },
	{ "JointInstance", { "Part0", "Part1", "C0", "C1", "Enabled" } },
	{ "Attachment", { "CFrame", "Position", "Orientation", "Visible", "Axis", "SecondaryAxis" } },
	{ "Constraint", { "Attachment0", "Attachment1", "Enabled", "Visible", "Color" } },
	{ "RodConstraint", { "Length", "Thickness" } },
	{ "RopeConstraint", { "Length", "Restitution", "Thickness" } },
	{ "SpringConstraint", { "FreeLength", "Stiffness", "Damping" } },
	{ "BallSocketConstraint", { "Radius" } },
	{ "CylindricalConstraint", { "TargetPosition", "TargetVelocity" } },
	{ "HingeConstraint", { "TargetAngle", "TargetAngularVelocity" } },
	{ "AlignPosition", { "Mode", "Position", "MaxForce", "MaxVelocity", "Responsiveness", "ApplyAtCenterOfMass", "RigidityEnabled" } },
	{ "AlignOrientation", { "Mode", "CFrame", "MaxTorque", "MaxAngularVelocity", "Responsiveness", "RigidityEnabled", "PrimaryAxisOnly" } },
	{ "WeldConstraint", { "Part0", "Part1", "Enabled" } },
	{ "NoCollisionConstraint", { "Part0", "Part1", "Enabled" } },
	{ "SurfaceAppearance", { "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap", "AlphaMode" } },
	{ "MeshPart", { "MeshId", "TextureID", "CollisionFidelity", "RenderFidelity", "DoubleSided" } },
	{ "Highlight", { "FillColor", "FillTransparency", "OutlineColor", "OutlineTransparency", "DepthMode", "Enabled", "Adornee" } },
	{ "ProximityPrompt", { "ActionText", "ObjectText", "HoldDuration", "MaxActivationDistance", "Enabled", "RequiresLineOfSight", "KeyboardKeyCode", "GamepadKeyCode", "Style", "Exclusivity", "ClickablePrompt" } },
	{ "ClickDetector", { "MaxActivationDistance", "CursorIcon" } },
	{ "SurfaceGui", { "Adornee", "Face", "CanvasSize", "LightInfluence", "AlwaysOnTop", "Enabled", "PixelsPerStud", "SizingMode", "Brightness" } },
	{ "BillboardGui", { "Adornee", "Size", "StudsOffset", "StudsOffsetWorldSpace", "ExtentsOffset", "AlwaysOnTop", "MaxDistance", "LightInfluence", "Enabled" } },
	{ "Seat", { "Disabled" } },
	{ "VehicleSeat", { "Disabled", "MaxSpeed", "Torque", "TurnSpeed", "HeadsUpDisplay" } },
	{ "SpawnLocation", { "Duration", "Neutral", "AllowTeamChangeOnTouch", "Enabled", "TeamColor" } },
	{ "Team", { "TeamColor", "AutoAssignable" } },
	{ "Tool", { "Grip", "CanBeDropped", "RequiresHandle", "Enabled", "ToolTip", "TextureId", "ManualActivationOnly" } },
	{ "Accessory", { "AttachmentPoint" } },
	{ "Fire", { "Size", "Heat", "Color", "SecondaryColor", "Enabled" } },
	{ "Smoke", { "Size", "Opacity", "RiseVelocity", "Color", "Enabled" } },
	{ "Sparkles", { "SparkleColor", "Enabled" } },
	{ "ViewportFrame", { "LightColor", "LightDirection", "Ambient", "ImageColor3", "ImageTransparency" } },
	{ "Model", { "PrimaryPart", "LevelOfDetail", "ModelStreamingMode" } },
	{ "ValueBase", { "Value" } },
}

local function mt(o, c)
	if type(c) == "function" then return c(o) end
	return o:IsA(c)
end

local function ch(o)
	local ok, r = pcall(function() return o:GetChildren() end)
	if ok then return r end
	return {}
end

local function rd(o, p)
	return o[p]
end

local function propsFor(o, ctx)
	local cn = o.ClassName
	local c = ctx.pc[cn]
	if c then return c end
	local seen, list = {}, {}
	local pa = o:IsA("BasePart") or o:IsA("Attachment")
	local br = o:IsA("BasePart")
	local function use(nm)
		if type(nm) ~= "string" or seen[nm] then return false end
		if bl[nm] then return false end
		if pa and pal[nm] then return false end
		if br and nm == "BrickColor" then return false end
		return true
	end
	if ctx.opt.deep ~= false and gp then
		local pok, pr = pcall(gp, o)
		if pok and type(pr) == "table" then
			for _, p in ipairs(pr) do
				local nm = type(p) == "table" and p.Name or p
				if use(nm) then seen[nm] = true; ins(list, nm) end
			end
		end
	end
	for _, g in ipairs(reg) do
		if mt(o, g[1]) then
			for _, p in ipairs(g[2]) do
				if use(p) then seen[p] = true; ins(list, p) end
			end
		end
	end
	ctx.pc[cn] = list
	return list
end

local function getDef(ctx, cn, p)
	local dc = ctx.dc
	local d = dc[cn]
	if d == nil then
		local ok, i = pcall(Instance.new, cn)
		d = (ok and i) or false
		dc[cn] = d
	end
	if not d then return nil, false end
	local ok, v = pcall(rd, d, p)
	if ok then return v, true end
	return nil, false
end

local function eq(a, b)
	local ok, r = pcall(function() return a == b end)
	return ok and r
end

local function block()
	local b = {}
	local function add(n)
		local ok, s = pcall(function() return game:GetService(n) end)
		if ok and s then b[s] = true end
	end
	add("CoreGui"); add("CorePackages"); add("RobloxPluginGuiService")
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then b[h] = true end
	end
	return b
end

local function archive(u, ctx)
	local id = tostring(u):match("%d+")
	if not id or ctx.dl[id] then return end
	ctx.dl[id] = true
	if not (writefile and game.HttpGet) then return end
	local ok, data = pcall(function() return game:HttpGet("https://assetdelivery.roblox.com/v1/asset/?id=" .. id) end)
	if ok and type(data) == "string" and #data > 0 then
		if not ctx.dlfolder and makefolder then
			pcall(makefolder, "WalkeAssets")
			ctx.dlfolder = true
		end
		pcall(function() writefile("WalkeAssets/" .. id, data) end)
		ctx.st.assets = ctx.st.assets + 1
	end
end

local function ser(v, seen, d)
	local t = type(v)
	if t == "string" then return fmt("%q", v) end
	if t == "number" then
		if v ~= v or v == huge or v == -huge then return "0" end
		return fmt("%.17g", v)
	end
	if t == "boolean" then return tostring(v) end
	if t == "table" then
		if seen[v] or d > 6 then return "nil" end
		seen[v] = true
		local ks = {}
		for k in pairs(v) do
			local kt = type(k)
			if kt == "string" or kt == "number" then ks[#ks + 1] = k end
		end
		table.sort(ks, function(x, y)
			local tx, ty = type(x), type(y)
			if tx ~= ty then return tx < ty end
			return x < y
		end)
		local b = { "{" }
		for _, k in ipairs(ks) do
			local key = type(k) == "string" and "[" .. fmt("%q", k) .. "]" or "[" .. fmt("%.17g", k) .. "]"
			local vs = ser(v[k], seen, d + 1)
			if vs then b[#b + 1] = key .. "=" .. vs .. "," end
		end
		b[#b + 1] = "}"
		seen[v] = nil
		return cat(b)
	end
	return "nil"
end

local function terrainSrc(data)
	return cat({
		'local d="', data, '"\n',
		'local T=workspace.Terrain\n',
		'local mm={} for _,m in ipairs(Enum.Material:GetEnumItems()) do mm[m.Value]=m end\n',
		'local B="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"\n',
		'local iv={} for i=1,#B do iv[B:sub(i,i)]=i-1 end\n',
		'local function dc(s) local r={} local n=#s local i=1 while i<=n do local a=iv[s:sub(i,i)] or 0 local b=iv[s:sub(i+1,i+1)] or 0 local p3=s:sub(i+2,i+2) local p4=s:sub(i+3,i+3) local c=iv[p3] or 0 local e=iv[p4] or 0 r[#r+1]=string.char(a*4+math.floor(b/16)) if p3~="=" and p3~="" then r[#r+1]=string.char((b%16)*16+math.floor(c/4)) end if p4~="=" and p4~="" then r[#r+1]=string.char((c%4)*64+e) end i=i+4 end return table.concat(r) end\n',
		'local raw=dc(d)\n',
		'local o=1\n',
		'local function rn(f) local t={string.unpack(f,raw,o)} o=t[#t] t[#t]=nil return table.unpack(t) end\n',
		'local nc=rn("<I4")\n',
		'for c=1,nc do local ox,oy,oz,sx,sy,sz=rn("<fffHHH") local ms={} local oc={} for xi=1,sx do ms[xi]={} oc[xi]={} for yi=1,sy do ms[xi][yi]={} oc[xi][yi]={} for zi=1,sz do local mv=rn("<H") local ob=string.byte(raw,o) o=o+1 ms[xi][yi][zi]=mm[mv] or Enum.Material.Air oc[xi][yi][zi]=ob/255 end end end local rg=Region3.new(Vector3.new(ox,oy,oz),Vector3.new(ox+sx*4,oy+sy*4,oz+sz*4)) pcall(function() T:WriteVoxels(rg,4,ms,oc) end) end\n',
		'print("Walke terrain restored: "..nc.." chunks")\n',
	})
end

local function terrainItem(ctx, ref)
	local tr
	local ok = pcall(function() tr = workspace.Terrain end)
	if not ok or not tr then return "" end
	local ext
	ok = pcall(function() ext = tr.MaxExtents end)
	if not ok or not ext then return "" end
	local mn, mx = ext.Min, ext.Max
	local x0, y0, z0 = mn.X * 4, mn.Y * 4, mn.Z * 4
	local x1, y1, z1 = mx.X * 4, mx.Y * 4, mx.Z * 4
	if x1 <= x0 or y1 <= y0 or z1 <= z0 then return "" end
	local cap = ctx.opt.terrainCap or 2048
	if (x1 - x0) > cap or (y1 - y0) > cap or (z1 - z0) > cap then
		ins(ctx.st.warns, "terrain extent over cap, skipped (raise opt.terrainCap)")
		return ""
	end
	local step = 128
	local chunks, nc = {}, 0
	local cx = x0
	while cx < x1 do
		local ex = math.min(cx + step, x1)
		local cy = y0
		while cy < y1 do
			local ey = math.min(cy + step, y1)
			local cz = z0
			while cz < z1 do
				local ez = math.min(cz + step, z1)
				local rg = Region3.new(Vector3.new(cx, cy, cz), Vector3.new(ex, ey, ez)):ExpandToGrid(4)
				local rok, ms, oc = pcall(function() return tr:ReadVoxels(rg, 4) end)
				if rok and ms and ms[1] and ms[1][1] then
					local sx, sy, sz = #ms, #ms[1], #ms[1][1]
					local pos, sz3 = rg.CFrame.Position, rg.Size
					local ox, oy, oz = pos.X - sz3.X / 2, pos.Y - sz3.Y / 2, pos.Z - sz3.Z / 2
					local vb, ne = {}, false
					for xi = 1, sx do
						for yi = 1, sy do
							for zi = 1, sz do
								local m = ms[xi][yi][zi]
								local ov = oc[xi][yi][zi] or 0
								if ov > 0 then ne = true end
								vb[#vb + 1] = pk("<H", (m and m.Value) or 0) .. sc(flr(ov * 255 + 0.5))
							end
						end
					end
					if ne then
						nc = nc + 1
						chunks[#chunks + 1] = pk("<fffHHH", ox, oy, oz, sx, sy, sz) .. cat(vb)
					end
				end
				cz = ez
			end
			cy = ey
		end
		cx = ex
	end
	if nc == 0 then return "" end
	local data = b64(pk("<I4", nc) .. cat(chunks))
	return cat({
		fmt('<Item class="Script" referent="%s">', ref),
		'<Properties>',
		S["string"]("Name", "Walke_Terrain_Restorer"),
		fmt('<ProtectedString name="Source">%s</ProtectedString>', cdata(terrainSrc(data))),
		'</Properties></Item>',
	})
end

local function readHidden(o, p, ctx)
	local ok, v = pcall(rd, o, p)
	if ok and type(v) == "string" and #v > 0 then return v end
	if ctx.ghp then
		ok, v = pcall(ctx.ghp, o, p)
		if ok and type(v) == "string" and #v > 0 then return v end
	end
	if ctx.shp then
		local sok = pcall(ctx.shp, o, p, true)
		if sok then
			ok, v = pcall(rd, o, p)
			if ok and type(v) == "string" and #v > 0 then return v end
		end
	end
	return nil
end

local function unionTags(o, ctx)
	local b, geo = {}, false
	local function grab(alts)
		for _, nm in ipairs(alts) do
			local d = readHidden(o, nm, ctx)
			if d and #d >= 8 then
				b[#b + 1] = fmt('<BinaryString name="%s">%s</BinaryString>', nm, b64(d))
				return true
			end
		end
		return false
	end
	if grab({ "MeshData" }) then geo = true end
	if grab({ "PhysicsData", "PhysicalConfigData" }) then geo = true end
	if grab({ "ChildData" }) then geo = true end
	if not geo then return "" end
	if ctx.ghp then
		local ok, isz = pcall(ctx.ghp, o, "InitialSize")
		if ok and typeof(isz) == "Vector3" then
			b[#b + 1] = fmt('<Vector3 name="InitialSize"><X>%s</X><Y>%s</Y><Z>%s</Z></Vector3>', nf(isz.X), nf(isz.Y), nf(isz.Z))
		end
	end
	return cat(b)
end

local function keep(c, ctx)
	if ctx.block[c] then return false end
	if not insertable(c) then return false end
	if ctx.opt.respectArchivable then
		local ok, a = pcall(function() return c.Archivable end)
		if ok and a == false then return false end
	end
	local cn = c.ClassName
	if ctx.ign[cn] then return false end
	if ctx.opt.noScripts and c:IsA("LuaSourceContainer") then return false end
	if ctx.opt.skipInvisible and c:IsA("BasePart") then
		local ok, tr = pcall(function() return c.Transparency end)
		if ok and tr and tr >= 1 then return false end
	end
	return true
end

local function walk(o, ctx, dep)
	if ctx.done[o] then return end
	ctx.done[o] = true
	if ctx.opt.shouldCancel and ctx.opt.shouldCancel() then error("__walke_cancel__", 0) end
	if dep > ctx.maxd then
		ins(ctx.st.warns, "max depth reached, subtree truncated")
		return
	end
	local st = ctx.st
	st.inst = st.inst + 1
	st.items = st.items + 1
	local cn = o.ClassName
	local bp = o:IsA("BasePart")
	local out = ctx.out
	local usolved = false
	local rid = ctx.refs[o]
	if not rid then
		ctx.cnt.n = ctx.cnt.n + 1
		rid = "RBX" .. ctx.cnt.n
		ctx.refs[o] = rid
	end
	ins(out, fmt('<Item class="%s" referent="%s">', cn, rid))
	ins(out, '<Properties>')
	for _, p in ipairs(propsFor(o, ctx)) do
		if p == "Source" then
			local src = srcOf(o)
			if src == "" and ctx.opt.rescue and o:IsA("ModuleScript") then
				local rok, mod = pcall(require, o)
				if rok and type(mod) == "table" then src = "return " .. ser(mod, {}, 0) end
			end
			if src ~= "" then
				ins(out, fmt('<ProtectedString name="Source">%s</ProtectedString>', cdata(src)))
				st.props = st.props + 1
			end
		else
			local ok, v = pcall(rd, o, p)
			if ok and v ~= nil then
				if ctx.opt.assets and cp[p] and typeof(v) == "string" then archive(v, ctx) end
				local skipDef = false
				if ctx.opt.minify ~= false and p ~= "Name" then
					local dv, has = getDef(ctx, cn, p)
					if has and eq(dv, v) then skipDef = true end
				end
				if not skipDef then
					local f = S[typeof(v)]
					if f then
						local xp = f(p, v, ctx.refs, bp)
						if xp and xp ~= "" then
							ins(out, xp)
							st.props = st.props + 1
						end
					else
						local tt = typeof(v)
						st.skip = st.skip + 1
						st.uns[tt] = (st.uns[tt] or 0) + 1
						if ctx.opt.mode == "debug" then local dk = cn .. "." .. p if not ctx.dbg[dk] then ctx.dbg[dk] = true warn("[Walke] skip " .. dk .. " <" .. tt .. ">") end end
						if ctx.opt.mode == "strict" then error("[Walke] unsupported " .. cn .. "." .. p .. " <" .. tt .. ">", 0) end
					end
				end
			elseif not ok then
				st.skip = st.skip + 1
				if ctx.opt.mode == "debug" then local rk = "rf:" .. cn .. "." .. p if not ctx.dbg[rk] then ctx.dbg[rk] = true warn("[Walke] read fail " .. cn .. "." .. p) end end
			end
		end
	end
	if ghp and cn == "MeshPart" then
		local ok, isz = pcall(ghp, o, "InitialSize")
		if ok and typeof(isz) == "Vector3" then
			ins(out, fmt('<Vector3 name="InitialSize"><X>%s</X><Y>%s</Y><Z>%s</Z></Vector3>', nf(isz.X), nf(isz.Y), nf(isz.Z)))
			st.props = st.props + 1
		end
	end
	if ctx.opt.unions and (cn == "UnionOperation" or cn == "NegateOperation") then
		local tg = unionTags(o, ctx)
		if tg ~= "" then
			ins(out, tg)
			st.props = st.props + 1
			st.unions = st.unions + 1
			usolved = true
		end
	end
	if ctx.opt.attributes ~= false then
		local a, ac, al = packAttrs(o)
		if a ~= "" then ins(out, a); st.attrs = st.attrs + ac end
		if al > 0 then st.attrLost = st.attrLost + al end
	end
	if ctx.opt.tags ~= false then
		local tg, tc = packTags(o)
		if tg ~= "" then ins(out, tg); st.tags = st.tags + tc end
	end
	ins(out, '</Properties>')
	for _, c in ipairs(ch(o)) do
		if keep(c, ctx) then walk(c, ctx, dep + 1) end
	end
	ins(out, '</Item>')
	if (cn == "UnionOperation" or cn == "NegateOperation") and not usolved then
		if ctx.opt.holo then
			local ok1, sz = pcall(rd, o, "Size")
			local ok2, cf = pcall(rd, o, "CFrame")
			if ok1 and ok2 and sz and cf then
				ctx.syn = ctx.syn + 1
				ins(out, fmt('<Item class="Part" referent="RBXsyn%d">', ctx.syn))
				ins(out, '<Properties>')
				ins(out, S["string"]("Name", "Walke_MissingUnion_" .. o.Name))
				ins(out, S["Vector3"]("Size", sz, nil, true))
				ins(out, S["CFrame"]("CFrame", cf))
				ins(out, S["Color3"]("Color", Color3.new(1, 0, 0), nil, true))
				ins(out, S["number"]("Transparency", 0.5))
				ins(out, S["boolean"]("Anchored", true))
				ins(out, '</Properties></Item>')
				st.items = st.items + 1
				st.holo = st.holo + 1
			end
		else
			st.csg = st.csg + 1
		end
	end
	if ctx.opt.yield ~= false and clk() - ctx.fs >= 0.014 then
		if ctx.opt.onProgress then pcall(ctx.opt.onProgress, st.inst, st.items) end
		pcall(function() task.wait() end)
		ctx.fs = clk()
	end
end

local function validate(xml, st)
	if xml:sub(1, 7) ~= "<roblox" then return false, "bad root" end
	if xml:sub(-9) ~= "</roblox>" then return false, "unclosed root" end
	local scan = xml:gsub("<!%[CDATA%[.-%]%]>", "")
	local _, o = scan:gsub("<Item ", "")
	local _, c = scan:gsub("</Item>", "")
	if o ~= c then return false, "item tags " .. o .. "/" .. c end
	if o ~= st.items then return false, "item count " .. o .. "/" .. st.items end
	local rs = {}
	for id in scan:gmatch('referent="([^"]+)"') do
		if rs[id] then return false, "duplicate ref " .. id end
		rs[id] = true
	end
	local dang = 0
	for id in scan:gmatch('<Ref name="[^"]-">([^<]+)</Ref>') do
		if not rs[id] then dang = dang + 1 end
	end
	st.dangling = dang
	if dang > 0 then return true, "ok, " .. dang .. " dangling refs (nil in Studio)" end
	return true, "ok"
end

local function report(st, vok, vmsg)
	local sz, n, u = st.bytes, st.bytes, "B"
	if sz >= 1048576 then n, u = sz / 1048576, "MB"
	elseif sz >= 1024 then n, u = sz / 1024, "KB" end
	local ut = 0
	for _ in pairs(st.uns) do ut = ut + 1 end
	print(fmt("[Walke] deep:%s inst:%d items:%d props:%d attrs:%d attrLost:%d tags:%d assets:%d holo:%d unions:%d csg:%d dangling:%d skip:%d unsupported:%d refs:%d warns:%d out:%.1f%s time:%.2fs valid:%s(%s)",
		tostring(st.deep), st.inst, st.items, st.props, st.attrs, st.attrLost, st.tags, st.assets, st.holo, st.unions, st.csg, st.dangling, st.skip, ut, st.refs, #st.warns, n, u, st.time or 0, tostring(vok), tostring(vmsg)))
	if not st.deep then warn("[Walke] getproperties missing on this executor -> registry-only capture (fewer props). full-fidelity needs an executor with getproperties") end
	if st.csg > 0 then warn("[Walke] " .. st.csg .. " CSG unions have no mesh saved (invisible in Studio); use holo=true for red position markers") end
	for _, w in ipairs(st.warns) do warn("[Walke] " .. w) end
end

local function assign(o, refs, cnt, blk)
	if refs[o] then return end
	cnt.n = cnt.n + 1
	refs[o] = "RBX" .. cnt.n
	for _, c in ipairs(ch(o)) do
		if not blk[c] then assign(c, refs, cnt, blk) end
	end
end

local function svc(o)
	local ok, par = pcall(function() return o.Parent end)
	if not ok or not par then return false end
	local ok2, pc = pcall(function() return par.ClassName end)
	return ok2 and pc == "DataModel"
end

local function kidsOf(o, blk)
	local ks = {}
	for _, c in ipairs(ch(o)) do
		if not (blk and blk[c]) then ks[#ks + 1] = c end
	end
	return ks
end

local function normalize(root, blk)
	local ents = {}
	local function add(o)
		local cn = o.ClassName
		if cn == "DataModel" then
			for _, c in ipairs(ch(o)) do
				if not (blk and blk[c]) then
					local nm = "Service"
					pcall(function() nm = c.ClassName end)
					local ks = kidsOf(c, blk)
					if #ks > 0 then ents[#ents + 1] = { folder = nm, kids = ks } end
				end
			end
		elseif svc(o) then
			for _, c in ipairs(kidsOf(o, blk)) do
				ents[#ents + 1] = { inst = c }
			end
		else
			ents[#ents + 1] = { inst = o }
		end
	end
	if typeof(root) == "Instance" then
		add(root)
	elseif type(root) == "table" then
		for _, o in ipairs(root) do
			if typeof(o) == "Instance" then add(o) end
		end
	end
	return ents
end

local M = {}

M.Version = "2.2"
M.Capabilities = {
	deep = gp ~= nil,
	decompile = dec ~= nil,
	attributes = true,
	tags = true,
	validate = true,
	stats = true,
	minify = true,
	blacklist = true,
	adaptiveYield = true,
	terrain = true,
	rescue = true,
	holo = true,
	assets = true,
	progress = true,
	archivableFilter = true,
	meshInitialSize = ghp ~= nil,
	unions = (ghp ~= nil) or (sscript ~= nil),
	native = nsi ~= nil,
	ignoreClasses = true,
	noScripts = true,
	cancellable = true,
	chunkedWrite = true,
	modes = { "safe", "strict", "debug", "silent" },
	datatypes = {
		"string", "boolean", "number", "Vector3", "Vector2", "Vector3int16",
		"Vector2int16", "Color3", "CFrame", "EnumItem", "UDim", "UDim2",
		"BrickColor", "NumberRange", "NumberSequence", "ColorSequence", "Rect",
		"PhysicalProperties", "Font", "Content", "Faces", "Axes", "Ray", "Instance",
	},
}

function M.serialize(root, opt)
	opt = opt or {}
	if opt.mode == nil then opt.mode = "safe" end
	local t0 = clk()
	local ign = {}
	if type(opt.ignore) == "table" then
		for _, c in ipairs(opt.ignore) do ign[c] = true end
	end
	local blk = block()
	local ents = normalize(root, blk)
	local refs, cnt = {}, { n = 0 }
	for _, e in ipairs(ents) do
		if e.inst then
			assign(e.inst, refs, cnt, blk)
		else
			for _, k in ipairs(e.kids) do assign(k, refs, cnt, blk) end
		end
	end
	local st = { inst = 0, items = 0, props = 0, attrs = 0, attrLost = 0, tags = 0, assets = 0, holo = 0, unions = 0, csg = 0, dangling = 0, skip = 0, uns = {}, warns = {}, refs = cnt.n, empty = false, deep = (opt.deep ~= false) and (gp ~= nil) }
	local out = {
		'<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
		'<Meta name="ExplicitAutoJoints">true</Meta>',
		'<External>null</External>',
		'<External>nil</External>',
	}
	local ctx = { refs = refs, cnt = cnt, out = out, st = st, opt = opt, pc = {}, dc = {}, done = {}, dbg = {}, syn = 0, block = blk, ign = ign, maxd = opt.maxDepth or 4000, fs = clk(), dl = {}, ghp = ghp, shp = sscript }
	for _, e in ipairs(ents) do
		if e.inst then
			if keep(e.inst, ctx) then walk(e.inst, ctx, 1) end
		else
			ctx.syn = ctx.syn + 1
			ins(out, fmt('<Item class="Folder" referent="RBXsyn%d">', ctx.syn))
			ins(out, '<Properties>')
			ins(out, S["string"]("Name", e.folder))
			ins(out, '</Properties>')
			st.items = st.items + 1
			for _, k in ipairs(e.kids) do
				if keep(k, ctx) then walk(k, ctx, 2) end
			end
			ins(out, '</Item>')
		end
	end
	if opt.terrain then
		ctx.syn = ctx.syn + 1
		local ti = terrainItem(ctx, "RBXsyn" .. ctx.syn)
		if ti ~= "" then
			ins(out, ti)
			st.items = st.items + 1
		end
	end
	ins(out, '</roblox>')
	st.empty = (st.items == 0)
	for k, d in pairs(ctx.dc) do
		if d then pcall(function() d:Destroy() end) end
		ctx.dc[k] = nil
	end
	local xml = cat(out, "\n")
	st.bytes = #xml
	st.refs = cnt.n
	st.time = clk() - t0
	local vok, vmsg = true, "off"
	if opt.validate ~= false then vok, vmsg = validate(xml, st) end
	if opt.mode ~= "silent" and opt.stats ~= false then report(st, vok, vmsg) end
	return xml, st, vok, vmsg
end

local function tryNative(o, fn, opt)
	if not nsi then return false, "no native saveinstance on this executor" end
	local a = {
		Decompile = true, DecompileTimeout = 10,
		DecompileIgnore = { "Chat", "CoreGui", "CorePackages" },
		NilInstances = false, RemovePlayerCharacters = true, SavePlayers = false,
		MaxThreads = 3, ShowStatus = true, IgnoreDefaultProps = true, IsolateStarterPlayer = true,
	}
	if type(opt.nativeArgs) == "table" then for k, v in pairs(opt.nativeArgs) do a[k] = v end end
	local ok, err = pcall(nsi, o, fn, a)
	if ok then return true end
	local b = { object = o, FilePath = fn, filename = fn }
	for k, v in pairs(a) do b[k] = v end
	local ok2 = pcall(nsi, b)
	if ok2 then return true end
	return false, tostring(err)
end

function M.save(o, fn, opt)
	opt = opt or {}
	if opt.native then
		local nok, nerr = tryNative(o, fn, opt)
		if nok then
			print("Walke handed this save to your executor's native saveinstance (unions and meshes included). Watch its status window, then check your exec workspace folder for " .. tostring(fn))
			return { ok = true, stage = "native" }
		end
		warn("[Walke] native saveinstance failed (" .. tostring(nerr) .. "); using Walke's own serializer instead")
	end
	local xml, st, vok, vmsg
	local ok, err = pcall(function() xml, st, vok, vmsg = M.serialize(o, opt) end)
	if not ok then
		if type(err) == "string" and err:find("__walke_cancel__", 1, true) then
			return { ok = false, stage = "cancelled" }
		end
		warn("Walke Serializer Error:", err)
		return { ok = false, stage = "serialize", err = err }
	end
	if st and st.empty then
		warn("Walke Serializer Error: no valid roots to serialize")
		return { ok = false, stage = "empty", err = "no valid roots", stats = st }
	end
	if opt.validate ~= false and not vok then
		warn("Walke Serializer Error: validation " .. tostring(vmsg))
		return { ok = false, stage = "validate", err = vmsg, xml = xml, stats = st }
	end
	if writefile then
		local wok, werr
		if #xml > 20000000 and appendfile and delfile then
			wok, werr = pcall(function()
				pcall(delfile, fn)
				local n = #xml
				local i = 1
				local first = true
				while i <= n do
					local part = xml:sub(i, i + 4000000 - 1)
					if first then writefile(fn, part) first = false else appendfile(fn, part) end
					i = i + 4000000
				end
			end)
		else
			wok, werr = pcall(function() writefile(fn, xml) end)
		end
		if not wok then
			warn("Walke Serializer Error: could not write " .. tostring(fn))
			return { ok = false, stage = "write", err = werr, xml = xml, stats = st }
		end
		print("Done Walke member, ur " .. fn .. " has been downloaded and set on your exec workspace succesfully, please visit ur workspace folder of your exec, cheers")
	end
	return { ok = true, stage = "done", xml = xml, stats = st }
end

local un = "User"
pcall(function() un = game:GetService("Players").LocalPlayer.Name end)
print("Hello " .. un .. ", thanks for using Walke, enjoy doing anything u want and remember, nothing can stop u, cheers, we have the POWER, please now please now proceed to use walkesave() with the instance that you want and let Walke work for you ;)")

local function safeName(fn)
	fn = tostring(fn):gsub("[/\\]", "_"):gsub("%.%.", "_"):gsub('[<>:"|%?%*%z\1-\31]', "")
	if fn == "" then fn = tostring(game.PlaceId) end
	if fn:sub(-6):lower() ~= ".rbxmx" then fn = fn .. ".rbxmx" end
	return fn
end

local function nameOf(o)
	local nm = ""
	pcall(function() nm = o.Name end)
	if type(nm) ~= "string" or nm == "" or nm == "Workspace" or nm == "Game" then
		nm = tostring(game.PlaceId)
	end
	return nm
end

local function api(o)
	if o == nil then
		return M.save(game, safeName(tostring(game.PlaceId) .. ".rbxmx"), nil)
	end
	local t = typeof(o)
	if t == "Instance" then
		return M.save(o, safeName(nameOf(o) .. ".rbxmx"), nil)
	elseif t == "table" then
		if typeof(o.object) == "Instance" then
			return M.save(o.object, safeName(o.filename or (nameOf(o.object) .. ".rbxmx")), o.options or o)
		elseif typeof(o[1]) == "Instance" then
			return M.save(o, safeName(o.filename or "selection.rbxmx"), o.options)
		end
	end
	warn("Walke Serializer Error: pass an Instance, {Instances}, or {object=inst,...}; got " .. tostring(t))
	return { ok = false, stage = "badarg" }
end

local g = getgenv and getgenv() or _G
g.walkesave = api
if not g.saveinstance then g.saveinstance = api end

return M
