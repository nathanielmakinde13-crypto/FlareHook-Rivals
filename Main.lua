local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local HttpService = game:GetService("HttpService")

local AutoSavedOutfit = nil

local SETTINGS_FILE = "FlareHookSettings.json"
local OUTFITS_FILE = "FlareHookOutfits.json"

local Settings = {
AutoLoad = true
}

local SavedOutfits = {}

if isfile and isfile(SETTINGS_FILE) then
pcall(function()
Settings = HttpService:JSONDecode(readfile(SETTINGS_FILE))
end)
end

if isfile and isfile(OUTFITS_FILE) then
pcall(function()
SavedOutfits = HttpService:JSONDecode(readfile(OUTFITS_FILE))
end)
end

local function SaveSettings()
if writefile then
writefile(SETTINGS_FILE,HttpService:JSONEncode(Settings))
end
end

local function SaveOutfits()
if writefile then
writefile(OUTFITS_FILE,HttpService:JSONEncode(SavedOutfits))
end
end

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "FlareHook"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 700, 0, 360)
frame.Position = UDim2.new(0.5, -350, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = true
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 44)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
title.Text = "FlareHook"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local titlePadding = Instance.new("UIPadding", title)
titlePadding.PaddingLeft = UDim.new(0, 12)

local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 44, 1, 0)
closeBtn.Position = UDim2.new(1, -44, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = title

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(0.55,0,0,30)
searchBar.Position = UDim2.new(0.15, 0, 0, 50)
searchBar.PlaceholderText = "Search catalog items..."
searchBar.Text = ""
searchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
searchBar.Font = Enum.Font.Gotham
searchBar.TextSize = 14
searchBar.Parent = frame

local searchCorner = Instance.new("UICorner", searchBar)
searchCorner.CornerRadius = UDim.new(0, 6)

local clearSearchBtn = Instance.new("TextButton")
clearSearchBtn.Text = "✖"
clearSearchBtn.Size = UDim2.new(0, 30, 0, 30)
clearSearchBtn.Position = UDim2.new(0.85, -30, 0, 50)
clearSearchBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
clearSearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearSearchBtn.Font = Enum.Font.GothamBold
clearSearchBtn.TextSize = 16
clearSearchBtn.Parent = frame

local clearSearchCorner = Instance.new("UICorner", clearSearchBtn)
clearSearchCorner.CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.72,0,1,-132)
scroll.Position = UDim2.new(0.27,0,0,128)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local wearingFrame = Instance.new("Frame")
wearingFrame.Size = UDim2.new(0.24,0,1,-132)
wearingFrame.Position = UDim2.new(0.01,0,0,128)
wearingFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
wearingFrame.Parent = frame
Instance.new("UICorner",wearingFrame)

local wearingTitle = Instance.new("TextLabel")
wearingTitle.Size = UDim2.new(1,0,0,30)
wearingTitle.BackgroundTransparency = 1
wearingTitle.Text = "Wearing"
wearingTitle.Font = Enum.Font.GothamBold
wearingTitle.TextSize = 18
wearingTitle.TextColor3 = Color3.new(1,1,1)
wearingTitle.Parent = wearingFrame

local wearingScroll = Instance.new("ScrollingFrame")
wearingScroll.Size = UDim2.new(1,-10,1,-35)
wearingScroll.Position = UDim2.new(0,5,0,30)
wearingScroll.BackgroundTransparency = 1
wearingScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
wearingScroll.ScrollBarThickness = 5
wearingScroll.Parent = wearingFrame

local wearingLayout = Instance.new("UIListLayout")
wearingLayout.Padding = UDim.new(0,5)
wearingLayout.Parent = wearingScroll

local bundleFrame = Instance.new("Frame")
bundleFrame.Size = UDim2.new(0,250,0,300)
bundleFrame.Position = UDim2.new(.5,-125,.5,-150)
bundleFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
bundleFrame.Visible = false
bundleFrame.Parent = gui
Instance.new("UICorner",bundleFrame)

local bundleClose = Instance.new("TextButton")
bundleClose.Size = UDim2.new(0,28,0,28)
bundleClose.Position = UDim2.new(1,-33,0,3)
bundleClose.BackgroundColor3 = Color3.fromRGB(200,0,0)
bundleClose.Text = "X"
bundleClose.TextColor3 = Color3.new(1,1,1)
bundleClose.Font = Enum.Font.GothamBold
bundleClose.TextSize = 16
bundleClose.Parent = bundleFrame

Instance.new("UICorner",bundleClose).CornerRadius = UDim.new(0,6)

bundleClose.MouseButton1Click:Connect(function()
bundleFrame.Visible = false
end)

local bundleTitle = Instance.new("TextLabel")
bundleTitle.Size = UDim2.new(1,0,0,30)
bundleTitle.BackgroundTransparency = 1
bundleTitle.TextColor3 = Color3.new(1,1,1)
bundleTitle.Font = Enum.Font.GothamBold
bundleTitle.TextSize = 18
bundleTitle.Parent = bundleFrame

local bundleScroll = Instance.new("ScrollingFrame")
bundleScroll.Size = UDim2.new(1,-10,1,-40)
bundleScroll.Position = UDim2.new(0,5,0,35)
bundleScroll.BackgroundTransparency = 1
bundleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
bundleScroll.ScrollBarThickness = 5
bundleScroll.Parent = bundleFrame

local bundleLayout = Instance.new("UIListLayout")
bundleLayout.Padding = UDim.new(0,5)
bundleLayout.Parent = bundleScroll

local categoryScroll = Instance.new("ScrollingFrame")
categoryScroll.Size = UDim2.new(0.98,0,0,36)
categoryScroll.Position = UDim2.new(0.01,0,0,86)
categoryScroll.BackgroundTransparency = 1
categoryScroll.ScrollBarThickness = 4
categoryScroll.ScrollingDirection = Enum.ScrollingDirection.X
categoryScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
categoryScroll.CanvasSize = UDim2.new()
categoryScroll.Parent = frame

local categoryLayout = Instance.new("UIListLayout")
categoryLayout.FillDirection = Enum.FillDirection.Horizontal
categoryLayout.Padding = UDim.new(0,6)
categoryLayout.Parent = categoryScroll

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0,100,0,120)
layout.CellPadding = UDim2.new(0,5,0,5)
layout.Parent = scroll

local bodyFrame = Instance.new("Frame")
bodyFrame.Size = UDim2.new(0.72,0,1,-132)
bodyFrame.Position = UDim2.new(0.27,0,0,128)
bodyFrame.BackgroundTransparency = 1
bodyFrame.Visible = false
bodyFrame.Parent = frame

local bodyScroll = Instance.new("ScrollingFrame")
bodyScroll.Size = UDim2.new(1,0,1,-40)
bodyScroll.BackgroundTransparency = 1
bodyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
bodyScroll.ScrollBarThickness = 6
bodyScroll.Parent = bodyFrame

local bodyGrid = Instance.new("UIGridLayout")
bodyGrid.CellSize = UDim2.new(0,50,0,50)
bodyGrid.CellPadding = UDim2.new(0,5,0,5)
bodyGrid.Parent = bodyScroll

local rgbBox = Instance.new("TextBox")
rgbBox.Size = UDim2.new(1,0,0,30)
rgbBox.Position = UDim2.new(0,0,1,-30)
rgbBox.PlaceholderText = "255,255,255"
rgbBox.BackgroundColor3 = Color3.fromRGB(28,28,28)
rgbBox.TextColor3 = Color3.new(1,1,1)
rgbBox.Font = Enum.Font.Gotham
rgbBox.TextSize = 16
rgbBox.Parent = bodyFrame

Instance.new("UICorner",rgbBox)

local catalogPages
local loadMore
local AutoSaveOutfit
local updateWearing
local currentQuery = ""
local currentAssetType = Enum.AvatarAssetType.Shirt
local loading = false

local BundlesContainer = game:GetObjects(getcustomasset("RBundles.rbxmx"))[1]

local BodyColors = {
Color3.fromRGB(255,205,148),
Color3.fromRGB(255,220,177),
Color3.fromRGB(255,235,205),
Color3.fromRGB(242,215,180),
Color3.fromRGB(224,172,105),
Color3.fromRGB(198,134,66),
Color3.fromRGB(161,110,74),
Color3.fromRGB(120,82,45),
Color3.fromRGB(90,60,40),
Color3.fromRGB(60,40,30),

Color3.fromRGB(255,255,255),
Color3.fromRGB(220,220,220),
Color3.fromRGB(170,170,170),
Color3.fromRGB(100,100,100),
Color3.fromRGB(0,0,0),

Color3.fromRGB(255,0,0),
Color3.fromRGB(255,128,128),
Color3.fromRGB(255,128,0),
Color3.fromRGB(255,255,0),
Color3.fromRGB(128,255,0),
Color3.fromRGB(0,255,0),
Color3.fromRGB(0,255,128),
Color3.fromRGB(0,255,255),
Color3.fromRGB(0,170,255),
Color3.fromRGB(0,0,255),
Color3.fromRGB(128,0,255),
Color3.fromRGB(255,0,255),
Color3.fromRGB(255,0,128),

Color3.fromRGB(139,69,19),
Color3.fromRGB(210,180,140),
Color3.fromRGB(128,64,0),
Color3.fromRGB(64,32,0),

Color3.fromRGB(242,243,243),
Color3.fromRGB(161,165,162),
Color3.fromRGB(249,233,153),
Color3.fromRGB(215,197,154),
Color3.fromRGB(194,218,184),
Color3.fromRGB(232,186,200),
Color3.fromRGB(128,187,219),
Color3.fromRGB(203,132,66),
Color3.fromRGB(204,142,105),
Color3.fromRGB(196,40,28),
Color3.fromRGB(196,112,160),
Color3.fromRGB(13,105,172),
Color3.fromRGB(245,205,48),
Color3.fromRGB(98,71,50),
Color3.fromRGB(27,42,53),
Color3.fromRGB(109,110,108),
Color3.fromRGB(40,127,71),
Color3.fromRGB(161,196,140),
Color3.fromRGB(243,207,155),
Color3.fromRGB(75,151,75),
Color3.fromRGB(160,95,53),
Color3.fromRGB(193,202,222),
Color3.fromRGB(236,236,236),
Color3.fromRGB(205,84,75),
Color3.fromRGB(193,223,240),
Color3.fromRGB(123,182,232),
Color3.fromRGB(247,241,141),
Color3.fromRGB(180,210,228),
Color3.fromRGB(217,133,108),
Color3.fromRGB(132,182,141),
Color3.fromRGB(248,241,132),
Color3.fromRGB(236,232,222),
Color3.fromRGB(238,196,182),
Color3.fromRGB(218,134,122),
Color3.fromRGB(110,153,202),
Color3.fromRGB(199,193,183),
Color3.fromRGB(107,50,124),
Color3.fromRGB(226,155,64),
Color3.fromRGB(218,133,65),
Color3.fromRGB(0,143,156),
Color3.fromRGB(104,92,67),
Color3.fromRGB(67,84,147),
Color3.fromRGB(191,183,177),
Color3.fromRGB(104,116,172),
Color3.fromRGB(229,173,200),
Color3.fromRGB(199,210,60),
Color3.fromRGB(85,165,175),
Color3.fromRGB(183,215,213),
Color3.fromRGB(164,189,71),
Color3.fromRGB(217,228,167),
Color3.fromRGB(231,172,88),
Color3.fromRGB(211,111,76),
Color3.fromRGB(146,57,120),
Color3.fromRGB(234,184,146),
Color3.fromRGB(165,165,203),
Color3.fromRGB(220,188,129),
Color3.fromRGB(174,122,89),
Color3.fromRGB(156,163,168),
Color3.fromRGB(213,115,61),
Color3.fromRGB(216,221,86),
Color3.fromRGB(116,134,157),
Color3.fromRGB(135,124,144),
Color3.fromRGB(224,152,100),
Color3.fromRGB(149,138,115),
Color3.fromRGB(32,58,86),
}

local originalHeadMesh

task.spawn(function()
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

local mesh = head:FindFirstChildOfClass("SpecialMesh")
if mesh then
originalHeadMesh = mesh:Clone()
end
end)

local function tryOn(item)

local character = player.Character or player.CharacterAdded:Wait()

local function AlreadyEquipped()

for _,v in ipairs(character:GetChildren()) do
if v:GetAttribute("CatalogId") == item.Id then
return true
end
end

local head = character:FindFirstChild("Head")

if head then
local mesh = head:FindFirstChildOfClass("SpecialMesh")
if mesh and mesh:GetAttribute("DisplayName") == item.Name then
return true
end
end

return false
end

if AlreadyEquipped() then
return
end

if item.AssetType == "Shirt" then

for _,v in ipairs(character:GetChildren()) do
if v:IsA("Shirt") then
v:Destroy()
end
end

local shirt = game:GetObjects("rbxassetid://"..item.Id)[1]
shirt:SetAttribute("DisplayName", item.Name)
shirt.Parent = character
shirt:SetAttribute("CatalogId",item.Id)
updateWearing()
AutoSaveOutfit()

elseif item.AssetType == "Pants" then

for _,v in ipairs(character:GetChildren()) do
if v:IsA("Pants") then
v:Destroy()
end
end

local pants = game:GetObjects("rbxassetid://"..item.Id)[1]
pants:SetAttribute("DisplayName", item.Name)
pants.Parent = character
pants:SetAttribute("CatalogId",item.Id)
updateWearing()
AutoSaveOutfit()

elseif item.AssetType == "TShirt" then

for _,v in ipairs(character:GetChildren()) do
if v:IsA("ShirtGraphic") then
v:Destroy()
end
end

local shirtGraphic = game:GetObjects("rbxassetid://"..item.Id)[1]
shirtGraphic:SetAttribute("DisplayName", item.Name)
shirtGraphic.Parent = character
shirtGraphic:SetAttribute("CatalogId",item.Id)
updateWearing()
AutoSaveOutfit()

elseif item.AssetType == "Hat" or string.find(item.AssetType, "Accessory") then

local success,accessory = pcall(function()
return game:GetObjects("rbxassetid://"..item.Id)[1]
end)

if success and accessory then

accessory.Parent = character
accessory:SetAttribute("CatalogId",item.Id)

accessory:SetAttribute("DisplayName", item.Name)

updateWearing()
AutoSaveOutfit()

local handle = accessory:FindFirstChild("Handle")

if handle then

local accessoryAttachment = handle:FindFirstChildWhichIsA("Attachment")

if accessoryAttachment then

local characterAttachment = character:FindFirstChild(accessoryAttachment.Name, true)

if characterAttachment then

handle.CFrame = characterAttachment.WorldCFrame
* accessoryAttachment.CFrame:Inverse()

local weld = Instance.new("WeldConstraint")
weld.Part0 = handle
weld.Part1 = characterAttachment.Parent
weld.Parent = handle

end

else

local head = character:FindFirstChild("Head")

if head then

handle.CFrame = head.CFrame

local weld = Instance.new("Weld")
weld.Part0 = handle
weld.Part1 = head
weld.Parent = handle

end
end

handle.Anchored = false
handle.CanCollide = false
end

updateWearing()
AutoSaveOutfit()

end

elseif item.AssetType == Enum.AvatarAssetType.Face then

local head = character:FindFirstChild("Head")

if head then

local old = head:FindFirstChild("face")

if old then
old:Destroy()
end

local decal = Instance.new("Decal")
decal.Name = "face"
decal.Texture = "rbxassetid://"..item.Id
decal.Parent = head

end

end
end

local function equipBundleMesh(mesh)

local character = player.Character or player.CharacterAdded:Wait()

if mesh:IsA("CharacterMesh") then

for _,v in ipairs(character:GetChildren()) do
if v:IsA("CharacterMesh") and v.BodyPart == mesh.BodyPart then
v:Destroy()
end
end

local clone = mesh:Clone()
clone:SetAttribute("DisplayName", mesh.Name)
clone:SetAttribute("BundleName", mesh.Parent.Name)
clone.Parent = character

updateWearing()
AutoSaveOutfit()

elseif mesh:IsA("SpecialMesh") then

local head = character:FindFirstChild("Head")

if head then

local old = head:FindFirstChildOfClass("SpecialMesh")

if old then
old:Destroy()
end

local clone = mesh:Clone()
clone:SetAttribute("DisplayName", mesh.Name)
clone:SetAttribute("BundleName", mesh.Parent.Name)
clone.Parent = head

updateWearing()
AutoSaveOutfit()

end
end

updateWearing()
AutoSaveOutfit()

end

updateWearing = function()

local character = player.Character
if not character then
return
end

for _,v in ipairs(wearingScroll:GetChildren()) do
if v:IsA("Frame") then
v:Destroy()
end
end

local function addRow(instance,name)

local row = Instance.new("Frame")
row.Size = UDim2.new(1,-5,0,32)
row.BackgroundColor3 = Color3.fromRGB(28,28,28)
row.Parent = wearingScroll

Instance.new("UICorner",row)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(.65,0,1,0)
label.BackgroundTransparency = 1
label.Text = name
label.TextScaled = true
label.TextColor3 = Color3.new(1,1,1)
label.Parent = row

local remove = Instance.new("TextButton")
remove.Size = UDim2.new(.35,-5,.8,0)
remove.Position = UDim2.new(.65,2,.1,0)
remove.Text = "Take Off"
remove.Font = Enum.Font.GothamBold
remove.TextScaled = true
remove.BackgroundColor3 = Color3.fromRGB(180,0,0)
remove.TextColor3 = Color3.new(1,1,1)
remove.Parent = row

Instance.new("UICorner",remove)

remove.MouseButton1Click:Connect(function()

if instance:IsA("Accessory") then

instance:Destroy()

elseif instance:IsA("Shirt") then

instance:Destroy()

elseif instance:IsA("Pants") then

instance:Destroy()

elseif instance:IsA("ShirtGraphic") then

instance:Destroy()

elseif instance:IsA("CharacterMesh") then

instance:Destroy()

elseif instance:IsA("SpecialMesh") and instance ~= originalHeadMesh then

local head = character:FindFirstChild("Head")

if head then

instance:Destroy()

if originalHeadMesh then
originalHeadMesh:Clone().Parent = head
end

end

end

updateWearing()
AutoSaveOutfit()

end)

end

for _,v in ipairs(character:GetChildren()) do

if v:IsA("Accessory") then
addRow(v, v:GetAttribute("DisplayName") or v.Name)

elseif v:IsA("Shirt") then
addRow(v, v:GetAttribute("DisplayName") or v.Name)

elseif v:IsA("Pants") then
addRow(v, v:GetAttribute("DisplayName") or v.Name)

elseif v:IsA("ShirtGraphic") then
addRow(v, v:GetAttribute("DisplayName") or v.Name)

elseif v:IsA("CharacterMesh") then
addRow(v, v:GetAttribute("DisplayName") or v.Name)

end

end

local head = character:FindFirstChild("Head")

if head then

local mesh = head:FindFirstChildOfClass("SpecialMesh")

if mesh and (not originalHeadMesh or mesh.MeshId ~= originalHeadMesh.MeshId) then
addRow(mesh, mesh:GetAttribute("DisplayName") or "Head")
end

end

end

local function GetCurrentOutfit()

local character = player.Character
if not character then
return nil
end

local data = {
Accessories = {},
Clothes = {},
Meshes = {},
BodyColors = {}
}

for _,v in ipairs(character:GetChildren()) do

if v:IsA("Accessory") then

table.insert(data.Accessories,{
Id = tonumber(v:GetAttribute("CatalogId")),
Name = v:GetAttribute("DisplayName")
})

elseif v:IsA("Shirt") then

data.Clothes.Shirt = tonumber(v:GetAttribute("CatalogId"))

elseif v:IsA("Pants") then

data.Clothes.Pants = tonumber(v:GetAttribute("CatalogId"))

elseif v:IsA("ShirtGraphic") then

data.Clothes.TShirt = tonumber(v:GetAttribute("CatalogId"))

elseif v:IsA("CharacterMesh") then

table.insert(data.Meshes,{
Bundle = v:GetAttribute("BundleName"),
Name = v.Name,
BodyPart = v.BodyPart.Name
})

end

end

for _,part in ipairs(character:GetChildren()) do

if part:IsA("BasePart") then
data.BodyColors[part.Name] = {
part.Color.R,
part.Color.G,
part.Color.B
}
end

end

local head=character:FindFirstChild("Head")

if head then
local mesh=head:FindFirstChildOfClass("SpecialMesh")

if mesh and mesh~=originalHeadMesh then
data.HeadMesh = {
MeshId = mesh.MeshId,
TextureId = mesh.TextureId,
Scale = {mesh.Scale.X,mesh.Scale.Y,mesh.Scale.Z},
Offset = {mesh.Offset.X,mesh.Offset.Y,mesh.Offset.Z},
VertexColor = {
mesh.VertexColor.X,
mesh.VertexColor.Y,
mesh.VertexColor.Z
}
}
end
end

return data

end

AutoSaveOutfit = function()
if Settings.AutoLoad then
AutoSavedOutfit = GetCurrentOutfit()
end
end

local function LoadSavedOutfit(data)

local character = player.Character or player.CharacterAdded:Wait()

for _,v in ipairs(character:GetChildren()) do
if v:IsA("Accessory")
or v:IsA("Shirt")
or v:IsA("Pants")
or v:IsA("ShirtGraphic")
or v:IsA("CharacterMesh") then
v:Destroy()
end
end

local head = character:FindFirstChild("Head")
if head then
local mesh = head:FindFirstChildOfClass("SpecialMesh")
if mesh then
mesh:Destroy()
end

if originalHeadMesh then
originalHeadMesh:Clone().Parent = head
end
end

if data.Clothes.Shirt then
tryOn({
Id = data.Clothes.Shirt,
Name = "Shirt",
AssetType = "Shirt"
})
end

if data.Clothes.Pants then
tryOn({
Id = data.Clothes.Pants,
Name = "Pants",
AssetType = "Pants"
})
end

if data.Clothes.TShirt then
tryOn({
Id = data.Clothes.TShirt,
Name = "T-Shirt",
AssetType = "TShirt"
})
end

for _,acc in ipairs(data.Accessories) do
if acc.Id then
tryOn({
Id = acc.Id,
Name = acc.Name,
AssetType = "Hat"
})
end
end

if data.BodyColors then
for partName,color in pairs(data.BodyColors) do

local part = character:FindFirstChild(partName)

if part then
part.Color = Color3.new(color[1],color[2],color[3])
end

end
end

if data.Meshes then
for _,meshInfo in ipairs(data.Meshes) do

local folder = BundlesContainer:FindFirstChild(meshInfo.Bundle)

if folder then
for _,mesh in ipairs(folder:GetChildren()) do
if mesh:IsA("CharacterMesh")
and mesh.Name == meshInfo.Name
and mesh.BodyPart.Name == meshInfo.BodyPart then
equipBundleMesh(mesh)
break
end
end
end

end
end

if data.HeadMesh then
local head = character:FindFirstChild("Head")

if head then
local old = head:FindFirstChildOfClass("SpecialMesh")
if old then
old:Destroy()
end

local mesh = Instance.new("SpecialMesh")
mesh.MeshId = data.HeadMesh.MeshId
mesh.TextureId = data.HeadMesh.TextureId
mesh.Scale = Vector3.new(unpack(data.HeadMesh.Scale))
mesh.Offset = Vector3.new(unpack(data.HeadMesh.Offset))
mesh.VertexColor = Vector3.new(unpack(data.HeadMesh.VertexColor))
mesh.Parent = head
end
end

updateWearing()
AutoSaveOutfit()

end

local function openBundle(folder)

bundleFrame.Visible = true
bundleTitle.Text = folder.Name

for _,v in ipairs(bundleScroll:GetChildren()) do
if v:IsA("TextButton") then
v:Destroy()
end
end

for _,mesh in ipairs(folder:GetChildren()) do

local button = Instance.new("TextButton")
button.Size = UDim2.new(1,-5,0,35)
button.BackgroundColor3 = Color3.fromRGB(28,28,28)
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Text = mesh.Name
button.Parent = bundleScroll

Instance.new("UICorner",button)

button.MouseButton1Click:Connect(function()
equipBundleMesh(mesh)
end)

end

end

local function addItem(item)
local button = Instance.new("ImageButton")
button.Size = UDim2.new(0,100,0,120)
button.BackgroundColor3 = Color3.fromRGB(28,28,28)
button.Parent = scroll
local imgCorner = Instance.new("UICorner", button)
imgCorner.CornerRadius = UDim.new(0,8)

local image = Instance.new("ImageLabel")
image.Size = UDim2.new(1,-10,0,90)
image.Position = UDim2.new(0,5,0,5)
image.BackgroundTransparency = 1
image.Image = "rbxthumb://type=Asset&id="..item.Id.."&w=150&h=150"
image.Parent = button
local imageCorner = Instance.new("UICorner", image)
imageCorner.CornerRadius = UDim.new(0,8)

local text = Instance.new("TextLabel")
text.Name = "name"
text.Size = UDim2.new(1,-4,0,20)
text.Position = UDim2.new(0,2,1,-22)
text.BackgroundTransparency = 1
text.TextScaled = true
text.TextColor3 = Color3.new(1,1,1)
text.Text = item.Name
text.Parent = button
local textCorner = Instance.new("UICorner", text)
textCorner.CornerRadius = UDim.new(0,6)

button.MouseButton1Click:Connect(function()

local tryBtn = Instance.new("TextButton")
tryBtn.Size = UDim2.new(1,0,0,25)
tryBtn.Position = UDim2.new(0,0,0,95)
tryBtn.BackgroundColor3 = Color3.fromRGB(210,0,0)
tryBtn.TextColor3 = Color3.new(1,1,1)
tryBtn.Font = Enum.Font.GothamBold
tryBtn.TextSize = 14
tryBtn.Text = "Try On"
tryBtn.Parent = button

Instance.new("UICorner",tryBtn).CornerRadius = UDim.new(0,6)

task.delay(5,function()
if tryBtn then
tryBtn:Destroy()
end
end)

tryBtn.MouseButton1Click:Connect(function()
tryOn(item)
end)

end)

end

local function addCategoryButton(text, assetType)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0,90,1,0)
button.BackgroundColor3 = Color3.fromRGB(28,28,28)
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Text = text
button.Parent = categoryScroll

Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)

button.MouseButton1Click:Connect(function()
currentAssetType = assetType
loadMore(true)
end)
end

local function updateSearch()
scroll.CanvasSize = UDim2.new(0,0,0,0)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end)

for _, child in ipairs(scroll:GetChildren()) do
if child:IsA("ImageButton") then
local name = child:FindFirstChild("name") or child:FindFirstChild("TextLabel")
local matches = true
if name and name.Text:lower():find(searchBar.Text:lower()) == nil then
matches = false
end
child.Visible = matches
end
end
end

local function clearItems()
for _,v in ipairs(scroll:GetChildren()) do
if v:IsA("GuiObject") and not v:IsA("UIGridLayout") then
v:Destroy()
end
end

scroll.CanvasPosition = Vector2.zero
end

local SelectedBodyPart = "All"

local Parts = {
"All",
"Head",
"Torso",
"Left Arm",
"Right Arm",
"Left Leg",
"Right Leg"
}

local partSelector = Instance.new("TextButton")
partSelector.Size = UDim2.new(0,120,0,30)
partSelector.Position = UDim2.new(0,570,0,50)
partSelector.BackgroundColor3 = Color3.fromRGB(28,28,28)
partSelector.Text = "All"
partSelector.TextColor3 = Color3.new(1,1,1)
partSelector.Parent = frame

Instance.new("UICorner",partSelector)

partSelector.Visible = false

local index = 1

partSelector.MouseButton1Click:Connect(function()
index += 1
if index > #Parts then
index = 1
end

SelectedBodyPart = Parts[index]
partSelector.Text = Parts[index]
end)

loadMore = function(reset)
if loading then
return
end

loading = true

if reset then
clearItems()

scroll.Visible = true
bodyFrame.Visible = false
partSelector.Visible = false

if currentAssetType == "Body" then

scroll.Visible = false
bodyFrame.Visible = true
partSelector.Visible = true

for _,v in ipairs(bodyScroll:GetChildren()) do
if v:IsA("TextButton") then
v:Destroy()
end
end

local function Apply(color)

local character = player.Character
if not character then
return
end

local Groups = {
["Head"] = {"Head"},
["Torso"] = {"UpperTorso","LowerTorso"},
["Left Arm"] = {"LeftUpperArm","LeftLowerArm","LeftHand"},
["Right Arm"] = {"RightUpperArm","RightLowerArm","RightHand"},
["Left Leg"] = {"LeftUpperLeg","LeftLowerLeg","LeftFoot"},
["Right Leg"] = {"RightUpperLeg","RightLowerLeg","RightFoot"},
}

if character:FindFirstChild("UpperTorso") then

if SelectedBodyPart == "All" then

for _,parts in pairs(Groups) do
for _,name in ipairs(parts) do
local p = character:FindFirstChild(name)
if p then
p.Color = color
end
end
end

else

for _,name in ipairs(Groups[SelectedBodyPart] or {}) do
local p = character:FindFirstChild(name)
if p then
p.Color = color
end
end

end

else

if SelectedBodyPart == "All" then

for _,name in ipairs({
"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"
}) do
local p = character:FindFirstChild(name)
if p then
p.Color = color
end
end

else

local p = character:FindFirstChild(SelectedBodyPart)
if p then
p.Color = color
end

end

end

AutoSaveOutfit()
end

for _,color in ipairs(BodyColors) do

local b = Instance.new("TextButton")
b.Size = UDim2.new(0,50,0,50)
b.BackgroundColor3 = color
b.Text = ""
b.Parent = bodyScroll

Instance.new("UICorner",b)

b.MouseButton1Click:Connect(function()
Apply(color)
end)

end

loading = false
return

rgbBox.FocusLost:Connect(function(enter)

if not enter then
return
end

local r,g,b = rgbBox.Text:match("(%d+),(%d+),(%d+)")

if r then
r = math.clamp(tonumber(r),0,255)
g = math.clamp(tonumber(g),0,255)
b = math.clamp(tonumber(b),0,255)

local color = Color3.fromRGB(r,g,b)

local character = player.Character

if SelectedBodyPart == "All" then

for _,name in ipairs({
"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"
}) do
local part = character:FindFirstChild(name)
if part then
part.Color = color
end
end

else

local part = character:FindFirstChild(SelectedBodyPart)
if part then
part.Color = color
end

end

end

end)

end

if currentAssetType == "Outfits" then

clearItems()
scroll.CanvasPosition = Vector2.zero

local save = Instance.new("TextButton")
save.Size = UDim2.new(0,220,0,40)
save.BackgroundColor3 = Color3.fromRGB(28,28,28)
save.Text = "Save Current Outfit"
save.TextColor3 = Color3.new(1,1,1)
save.Font = Enum.Font.GothamBold
save.TextSize = 16
save.Parent = scroll

Instance.new("UICorner",save)

save.MouseButton1Click:Connect(function()

table.insert(SavedOutfits,{
Name = "Outfit "..#SavedOutfits + 1,
Data = GetCurrentOutfit()
})

SaveOutfits()
loadMore(true)

end)

for i,outfit in ipairs(SavedOutfits) do

local row = Instance.new("Frame")
row.Size = UDim2.new(0,260,0,40)
row.BackgroundColor3 = Color3.fromRGB(28,28,28)
row.Parent = scroll
Instance.new("UICorner",row)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(.6,0,1,0)
label.BackgroundTransparency = 1
label.Text = outfit.Name
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.GothamBold
label.TextSize = 15
label.Parent = row

row.Size = UDim2.new(0,260,0,75)

label.Size = UDim2.new(1,-10,0,28)
label.Position = UDim2.new(0,5,0,3)
label.TextXAlignment = Enum.TextXAlignment.Center

local equip = Instance.new("TextButton")
equip.Size = UDim2.new(.45,-5,0,30)
equip.Position = UDim2.new(0.03,0,0,38)
equip.BackgroundColor3 = Color3.fromRGB(210,0,0)
equip.Text = "Equip"
equip.TextColor3 = Color3.new(1,1,1)
equip.Font = Enum.Font.GothamBold
equip.TextSize = 14
equip.Parent = row
Instance.new("UICorner",equip)

local delete = Instance.new("TextButton")
delete.Size = UDim2.new(.45,-5,0,30)
delete.Position = UDim2.new(.52,0,0,38)
delete.BackgroundColor3 = Color3.fromRGB(180,0,0)
delete.Text = "Delete"
delete.TextColor3 = Color3.new(1,1,1)
delete.Font = Enum.Font.GothamBold
delete.TextSize = 14
delete.Parent = row
Instance.new("UICorner",delete)

equip.MouseButton1Click:Connect(function()
LoadSavedOutfit(outfit.Data)
end)

delete.MouseButton1Click:Connect(function()
table.remove(SavedOutfits,i)
SaveOutfits()
loadMore(true)
end)

end

loading = false
return
end

if currentAssetType == "Settings" then

clearItems()
scroll.CanvasPosition = Vector2.zero

local container = Instance.new("Frame")
container.Size = UDim2.new(1,0,0,50)
container.BackgroundTransparency = 1
container.Parent = scroll

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0,160,0,35)
label.Position = UDim2.new(0,10,0,5)
label.BackgroundTransparency = 1
label.Text = "Auto Char Load"
label.TextXAlignment = Enum.TextXAlignment.Left
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.TextColor3 = Color3.new(1,1,1)
label.Parent = container

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0,32,0,32)
toggle.Position = UDim2.new(0,180,0,7)
toggle.BackgroundColor3 = Color3.fromRGB(28,28,28)
toggle.Text = Settings.AutoLoad and "✓" or ""
toggle.TextColor3 = Color3.fromRGB(255,0,0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 22
toggle.Parent = container

Instance.new("UICorner",toggle)

toggle.MouseButton1Click:Connect(function()

Settings.AutoLoad = not Settings.AutoLoad

toggle.Text = Settings.AutoLoad and "✓" or ""

SaveSettings()

end)

scroll.CanvasSize = UDim2.new(0,0,0,60)

loading = false
return
end

if currentAssetType == "Bundles" then

clearItems()

for _,folder in ipairs(BundlesContainer:GetChildren()) do

local fakeItem = {
Name = folder.Name,
Id = 0,
Folder = folder
}

local button = Instance.new("ImageButton")
button.Size = UDim2.new(0,100,0,120)
button.BackgroundColor3 = Color3.fromRGB(28,28,28)
button.Parent = scroll

Instance.new("UICorner",button).CornerRadius = UDim.new(0,8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,1,0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Text = folder.Name
label.TextColor3 = Color3.new(1,1,1)
label.Parent = button

button.MouseButton1Click:Connect(function()
openBundle(folder)
end)

end

loading = false
return

end

local params = CatalogSearchParams.new()
params.SearchKeyword = currentQuery
params.AssetTypes = {currentAssetType}

catalogPages = AvatarEditorService:SearchCatalog(params)
else
if catalogPages then
pcall(function()
catalogPages:AdvanceToNextPageAsync()
end)
end
end

if not catalogPages then
loading = false
return
end

local items = catalogPages:GetCurrentPage()

for _, item in ipairs(items) do
addItem(item)
end

scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)

loading = false
end

currentQuery = ""
loadMore(true)
updateWearing()
AutoSaveOutfit()

addCategoryButton("Shirts",Enum.AvatarAssetType.Shirt)
addCategoryButton("Pants",Enum.AvatarAssetType.Pants)
addCategoryButton("T-Shirts",Enum.AvatarAssetType.TShirt)
addCategoryButton("Hair",Enum.AvatarAssetType.HairAccessory)
addCategoryButton("Face",Enum.AvatarAssetType.FaceAccessory)
addCategoryButton("Neck",Enum.AvatarAssetType.NeckAccessory)
addCategoryButton("Shoulder",Enum.AvatarAssetType.ShoulderAccessory)
addCategoryButton("Front",Enum.AvatarAssetType.FrontAccessory)
addCategoryButton("Back",Enum.AvatarAssetType.BackAccessory)
addCategoryButton("Waist",Enum.AvatarAssetType.WaistAccessory)
addCategoryButton("Hat",Enum.AvatarAssetType.Hat)
addCategoryButton("Bundles","Bundles")
addCategoryButton("Body","Body")
addCategoryButton("Outfits","Outfits")
addCategoryButton("Settings","Settings")

scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
if loading then
return
end

if scroll.CanvasPosition.Y >= scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y - 150 then
loadMore(false)
end
end)

local searchThread = 0

searchBar:GetPropertyChangedSignal("Text"):Connect(function()

searchThread += 1
local id = searchThread

task.wait(0.4)

if id ~= searchThread then
return
end

currentQuery = searchBar.Text
loadMore(true)

end)

clearSearchBtn.MouseButton1Click:Connect(function()
searchBar.Text = ""
end)

-- Window dragging and window controls.
local dragging, dragInput, dragStart, startPos

local function update(input)
local delta = input.Position - dragStart

frame.Position = UDim2.new(
startPos.X.Scale,
startPos.X.Offset + delta.X,
startPos.Y.Scale,
startPos.Y.Offset + delta.Y
)
end

title.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

dragging = true
dragStart = input.Position
startPos = frame.Position

input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)

end
end)

title.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch then

dragInput = input

end
end)

UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
update(input)
end
end)

local normalSize = UDim2.new(0,700,0,360)
local normalPosition = UDim2.new(0.5,-350,0.5,-180)

local maximized = false
local minimized = false

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0,44,1,0)
minimizeBtn.Position = UDim2.new(1,-132,0,0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.Parent = title

local maximizeBtn = Instance.new("TextButton")
maximizeBtn.Size = UDim2.new(0,44,1,0)
maximizeBtn.Position = UDim2.new(1,-88,0,0)
maximizeBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
maximizeBtn.Text = "□"
maximizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.TextSize = 18
maximizeBtn.Parent = title

local function styleWindowButton(button, hoverColor)

Instance.new("UICorner",button).CornerRadius = UDim.new(0,4)

button.MouseEnter:Connect(function()
button.BackgroundColor3 = hoverColor
end)

button.MouseLeave:Connect(function()
button.BackgroundColor3 = Color3.fromRGB(28,28,28)
end)

end

styleWindowButton(minimizeBtn,Color3.fromRGB(45,0,0))
styleWindowButton(maximizeBtn,Color3.fromRGB(45,0,0))
styleWindowButton(closeBtn,Color3.fromRGB(180,0,0))

minimizeBtn.MouseButton1Click:Connect(function()

minimized = true

frame.Visible = false

minimizeBtn.Visible = false
maximizeBtn.Visible = false
closeBtn.Visible = false

restoreBtn.Visible = true

end)

closeBtn.MouseButton1Click:Connect(function()
gui:Destroy()
end)

maximizeBtn.MouseButton1Click:Connect(function()

if maximized then

maximized = false

frame.Size = normalSize
frame.Position = normalPosition

maximizeBtn.Text = "□"

else

normalSize = frame.Size
normalPosition = frame.Position

maximized = true

frame.Size = UDim2.new(1,-20,1,-20)
frame.Position = UDim2.new(0,10,0,10)

maximizeBtn.Text = "❐"

end

end)

local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0,110,0,42)
restoreBtn.Position = UDim2.new(0,20,1,-62)
restoreBtn.BackgroundColor3 = Color3.fromRGB(10,10,10)
restoreBtn.Text = "FlareHook"
restoreBtn.TextColor3 = Color3.fromRGB(255,255,255)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 14
restoreBtn.Visible = false
restoreBtn.Parent = gui

Instance.new("UICorner",restoreBtn).CornerRadius = UDim.new(0,8)

restoreBtn.MouseEnter:Connect(function()
restoreBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
end)

restoreBtn.MouseLeave:Connect(function()
restoreBtn.BackgroundColor3 = Color3.fromRGB(10,10,10)
end)

restoreBtn.MouseButton1Click:Connect(function()

minimized = false

frame.Visible = true

minimizeBtn.Visible = true
maximizeBtn.Visible = true
closeBtn.Visible = true

restoreBtn.Visible = false

end)

local draggingRestore, dragInputRestore, dragStartRestore, startPosRestore

local function updateRestore(input)

local delta = input.Position - dragStartRestore

restoreBtn.Position = UDim2.new(
startPosRestore.X.Scale,
startPosRestore.X.Offset + delta.X,
startPosRestore.Y.Scale,
startPosRestore.Y.Offset + delta.Y
)

end

restoreBtn.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

draggingRestore = true
dragStartRestore = input.Position
startPosRestore = restoreBtn.Position

input.Changed:Connect(function()

if input.UserInputState == Enum.UserInputState.End then
draggingRestore = false
end

end)

end

end)

restoreBtn.InputChanged:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch then

dragInputRestore = input

end

end)

UserInputService.InputChanged:Connect(function(input)

if input == dragInputRestore and draggingRestore then
updateRestore(input)
end

end)

player.CharacterAdded:Connect(function(character)

character:WaitForChild("Humanoid")

task.wait(0.2)

local head = character:FindFirstChild("Head")

if head then
local mesh = head:FindFirstChildOfClass("SpecialMesh")
originalHeadMesh = mesh and mesh:Clone() or nil
end

updateWearing()

if Settings.AutoLoad and AutoSavedOutfit then
task.wait(1)
LoadSavedOutfit(AutoSavedOutfit)
end

end)

gui.Enabled = true

local function loadOutfitOne()

local character = player.Character or player.CharacterAdded:Wait()

character:WaitForChild("Humanoid")

task.wait(1)

if SavedOutfits[1] and SavedOutfits[1].Data then

LoadSavedOutfit(SavedOutfits[1].Data)

else

warn("[FlareHook] Outfit 1 was not found.")

end

end

task.spawn(loadOutfitOne)

-- Reapply Outfit 1 on respawn.
player.CharacterAdded:Connect(function(character)

character:WaitForChild("Humanoid")

task.wait(1)

if SavedOutfits[1] and SavedOutfits[1].Data then
LoadSavedOutfit(SavedOutfits[1].Data)
end

end)
