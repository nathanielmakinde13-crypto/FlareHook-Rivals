--// FLAREHOOK
--// Full LocalScript | Edited in-place with requested features
--// 8 Tabs | Square Controls | Red/Black
--// Main / Player / Visuals / World / Combat / Misc / Settings / Credits
--// Logo decal: 1688841862

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--==================================================
-- CONFIG
--==================================================

local LOGO_ID = "rbxassetid://1688841862"
local CLICK_SOUND_ID = "rbxassetid://6042053626"

local MAIN_SIZE = UDim2.fromOffset(780, 480)
local UI_SCALE = 0.90

-- More-square controls
local CORNER_RADIUS = 3

local COLORS = {
Black = Color3.fromRGB(8, 8, 10),
Dark = Color3.fromRGB(12, 12, 15),

Panel = Color3.fromRGB(17, 17, 21),
Panel2 = Color3.fromRGB(21, 21, 26),
Panel3 = Color3.fromRGB(26, 26, 31),

Red = Color3.fromRGB(220, 35, 45),
RedHover = Color3.fromRGB(245, 48, 58),
RedDark = Color3.fromRGB(135, 22, 29),

White = Color3.fromRGB(245, 245, 247),
Text = Color3.fromRGB(220, 220, 225),
Muted = Color3.fromRGB(140, 140, 150),

Border = Color3.fromRGB(40, 40, 47),
NeutralButton = Color3.fromRGB(31, 31, 36),
NeutralHover = Color3.fromRGB(42, 42, 48)
}

--==================================================
-- STATE
--==================================================

local CurrentTab = "Main"
local UIOpen = true
local Minimized = false

local DropdownOpen = nil
local AccentObjects = {}

local Pages = {}
local Tabs = {}
local DropdownUpdaters = {}

local FeatureStates = {}

-- Persistent configuration state
local ConfigFolder = "Flarehook"
local ConfigName = "default"
local ConfigAutoload = false
local ConfigControls = {}

local FPS = 0
local SessionStart = os.clock()
local SessionClicks = 0

local CharacterVisible = true
local MovementEnabled = true
local ThirdPersonEnabled = false
local NotificationsEnabled = true
local PanicEnabled = false

local MainScriptEnabled = true

-- Visual settings
local ESPEnabled = false
local NameTagsEnabled = false
local HealthBarsEnabled = false
local DistanceEnabled = false
local TracersEnabled = false
local TeamColorsEnabled = false
local HitEffectsEnabled = false

-- Combat settings
local AimAssistEnabled = false
local AimbotEnabled = false
local TriggerbotEnabled = false
local HitboxEnabled = false
local AutoShootEnabled = false
local TeamCheckEnabled = true
local VisibilityCheckEnabled = true
local TargetLockEnabled = false
local RecoilControlEnabled = false
local FOVCircleEnabled = false

local TargetPriority = "Closest to Crosshair"
local TargetPartName = "Head"
local PredictionAmount = 0
local AimFOV = 120
local AimSmoothing = 0.35 -- 0 = snap, 1 = very slow
local AimAssistSmoothing = 0.18 -- intentionally faster than smoothing 1
local HitboxSize = 8
local RecoilStrength = 0

local CrosshairColor = COLORS.Red
local CrosshairSize = 4
local CrosshairThickness = 2
local CrosshairGap = 5

local ESPColor = COLORS.Red
local HitEffectColor = COLORS.Red

local ToggleKey = Enum.KeyCode.Insert
local PanicKey = Enum.KeyCode.P

--==================================================
-- UTILITY
--==================================================

local function Create(className, properties, parent)
local object = Instance.new(className)

for property, value in pairs(properties or {}) do
object[property] = value
end

object.Parent = parent

return object
end

local function AddCorner(object, radius)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, radius or CORNER_RADIUS)
corner.Parent = object

return corner
end

local function AddStroke(object, color, transparency, thickness)
local stroke = Instance.new("UIStroke")
stroke.Color = color or COLORS.Border
stroke.Transparency = transparency or 0
stroke.Thickness = thickness or 1
stroke.Parent = object

return stroke
end

local function AddPadding(object, left, right, top, bottom)
local padding = Instance.new("UIPadding")

padding.PaddingLeft = UDim.new(0, left or 0)
padding.PaddingRight = UDim.new(0, right or 0)
padding.PaddingTop = UDim.new(0, top or 0)
padding.PaddingBottom = UDim.new(0, bottom or 0)

padding.Parent = object

return padding
end

local function Tween(object, duration, properties, style, direction)
local tween = TweenService:Create(
object,
TweenInfo.new(
duration or 0.15,
style or Enum.EasingStyle.Quad,
direction or Enum.EasingDirection.Out
),
properties
)

tween:Play()

return tween
end

local function ClickSound()
local sound = Instance.new("Sound")
sound.SoundId = CLICK_SOUND_ID
sound.Volume = 0.3
sound.Parent = SoundService

sound:Play()

task.delay(2, function()
if sound then
sound:Destroy()
end
end)
end

local function RegisterAccent(object, property)
table.insert(AccentObjects, {
Object = object,
Property = property
})

object[property] = COLORS.Red
end

local function RefreshAccents()
for _, data in ipairs(AccentObjects) do
if data.Object and data.Object.Parent then
pcall(function()
data.Object[data.Property] = COLORS.Red
end)
end
end
end

local function GetCharacter()
return Player.Character
end

local function GetHumanoid()
local Character = GetCharacter()

if Character then
return Character:FindFirstChildOfClass("Humanoid")
end
end

local function GetRoot()
local Character = GetCharacter()

if Character then
return Character:FindFirstChild("HumanoidRootPart")
end
end

local function SetCharacterTransparency(value)
local Character = GetCharacter()

if not Character then
return
end

for _, Object in ipairs(Character:GetDescendants()) do
if Object:IsA("BasePart") then
Object.LocalTransparencyModifier = value
elseif Object:IsA("Decal") then
Object.Transparency = value
end
end
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Create("ScreenGui", {
Name = "Flarehook",
ResetOnSpawn = false,
IgnoreGuiInset = true,
DisplayOrder = 999,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

--==================================================
-- DROPDOWN OVERLAY
--==================================================

local DropdownOverlay = Create("Frame", {
Name = "DropdownOverlay",
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2.fromScale(0, 0),
Size = UDim2.fromScale(1, 1),
ZIndex = 1000,
ClipsDescendants = false
}, ScreenGui)

--==================================================
-- NOTIFICATIONS
--==================================================

local NotificationHolder = Create("Frame", {
Name = "Notifications",
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 1),
Position = UDim2.new(1, -16, 1, -16),
Size = UDim2.fromOffset(300, 400),
ZIndex = 900
}, ScreenGui)

local NotificationLayout = Create("UIListLayout", {
FillDirection = Enum.FillDirection.Vertical,
HorizontalAlignment = Enum.HorizontalAlignment.Right,
VerticalAlignment = Enum.VerticalAlignment.Bottom,
Padding = UDim.new(0, 7)
}, NotificationHolder)

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Create("Frame", {
Name = "Main",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Size = MAIN_SIZE,
BackgroundColor3 = COLORS.Black,
BorderSizePixel = 0,
ClipsDescendants = true
}, ScreenGui)

AddCorner(Main, CORNER_RADIUS)
AddStroke(Main, COLORS.Border, 0.1, 1)

Create("UIScale", {
Scale = UI_SCALE
}, Main)

--==================================================
-- HEADER
--==================================================

local Header = Create("Frame", {
Name = "Header",
BackgroundColor3 = COLORS.Panel,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 58),
ZIndex = 10
}, Main)

AddCorner(Header, CORNER_RADIUS)

Create("Frame", {
BackgroundColor3 = COLORS.Panel,
BorderSizePixel = 0,
Position = UDim2.new(0, 0, 1, -8),
Size = UDim2.new(1, 0, 0, 8),
ZIndex = 10
}, Header)

local HeaderAccent = Create("Frame", {
BackgroundColor3 = COLORS.Red,
BorderSizePixel = 0,
Position = UDim2.fromOffset(0, 0),
Size = UDim2.new(1, 0, 0, 2),
ZIndex = 15
}, Header)

RegisterAccent(HeaderAccent, "BackgroundColor3")

Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.fromOffset(16, 7),
Size = UDim2.fromOffset(300, 25),
Font = Enum.Font.GothamBold,
Text = "FLAREHOOK",
TextColor3 = COLORS.White,
TextSize = 19,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 20
}, Header)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(17, 31),
Size = UDim2.fromOffset(300, 17),
Font = Enum.Font.Fantasy,
Text = "Advanced interface",
TextColor3 = COLORS.Muted,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 20
}, Header)

--==================================================
-- MINIMIZE
--==================================================

local MinimizeButton = Create("TextButton", {
Name = "Minimize",
BackgroundColor3 = COLORS.NeutralButton,
BorderSizePixel = 0,
Position = UDim2.new(1, -52, 0, 14),
Size = UDim2.fromOffset(28, 28),
AutoButtonColor = false,
Font = Enum.Font.GothamBold,
Text = "-",
TextColor3 = COLORS.Text,
TextSize = 17,
ZIndex = 30
}, Header)

AddCorner(MinimizeButton, CORNER_RADIUS)
AddStroke(MinimizeButton, COLORS.Border, 0.2, 1)

MinimizeButton.MouseEnter:Connect(function()
Tween(MinimizeButton, 0.12, {
BackgroundColor3 = COLORS.NeutralHover
})
end)

MinimizeButton.MouseLeave:Connect(function()
Tween(MinimizeButton, 0.12, {
BackgroundColor3 = COLORS.NeutralButton
})
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Create("Frame", {
Name = "Sidebar",
BackgroundColor3 = COLORS.Dark,
BorderSizePixel = 0,
Position = UDim2.fromOffset(0, 58),
Size = UDim2.new(0, 170, 1, -58),
ZIndex = 5
}, Main)

Create("Frame", {
BackgroundColor3 = COLORS.Border,
BorderSizePixel = 0,
Position = UDim2.new(1, -1, 0, 0),
Size = UDim2.new(0, 1, 1, 0),
ZIndex = 8
}, Sidebar)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(15, 12),
Size = UDim2.new(1, -30, 0, 22),
Font = Enum.Font.GothamBold,
Text = "MENU",
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 8
}, Sidebar)

--==================================================
-- SEARCH
--==================================================

local SearchHolder = Create("Frame", {
BackgroundColor3 = COLORS.Panel,
BorderSizePixel = 0,
Position = UDim2.fromOffset(11, 40),
Size = UDim2.new(1, -22, 0, 30),
ZIndex = 8
}, Sidebar)

AddCorner(SearchHolder, CORNER_RADIUS)
AddStroke(SearchHolder, COLORS.Border, 0.2, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(7, 0),
Size = UDim2.fromOffset(20, 30),
Font = Enum.Font.GothamBold,
Text = "âŒ•",
TextColor3 = COLORS.Muted,
TextSize = 16,
ZIndex = 9
}, SearchHolder)

local SearchBox = Create("TextBox", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(27, 0),
Size = UDim2.new(1, -32, 1, 0),
Font = Enum.Font.Fantasy,
PlaceholderText = "Search...",
PlaceholderColor3 = COLORS.Muted,
Text = "",
TextColor3 = COLORS.Text,
TextSize = 11,
ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 9
}, SearchHolder)

--==================================================
-- TABS
--==================================================

local TabHolder = Create("ScrollingFrame", {
Name = "Tabs",
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2.fromOffset(10, 80),
Size = UDim2.new(1, -20, 1, -90),
CanvasSize = UDim2.fromOffset(0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 2,
ScrollBarImageColor3 = COLORS.Red,
ScrollBarImageTransparency = 0.2,
ScrollingDirection = Enum.ScrollingDirection.Y,
ZIndex = 8
}, Sidebar)

local TabLayout = Create("UIListLayout", {
FillDirection = Enum.FillDirection.Vertical,
HorizontalAlignment = Enum.HorizontalAlignment.Center,
VerticalAlignment = Enum.VerticalAlignment.Top,
Padding = UDim.new(0, 5)
}, TabHolder)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
Name = "Content",
BackgroundColor3 = COLORS.Dark,
BorderSizePixel = 0,
Position = UDim2.fromOffset(170, 58),
Size = UDim2.new(1, -170, 1, -58),
ZIndex = 4
}, Main)

local PageHolder = Create("Frame", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 11),
Size = UDim2.new(1, -28, 1, -22),
ZIndex = 5
}, Content)

--==================================================
-- OPEN / CLOSE
--==================================================

local ToggleButton = Create("TextButton", {
Name = "OpenClose",
AnchorPoint = Vector2.new(1, 1),
Position = UDim2.new(1, -16, 1, -16),
Size = UDim2.fromOffset(82, 34),
BackgroundColor3 = COLORS.NeutralButton,
BorderSizePixel = 0,
AutoButtonColor = false,
Font = Enum.Font.GothamBold,
Text = "Close",
TextColor3 = COLORS.White,
TextSize = 11,
ZIndex = 950
}, ScreenGui)

AddCorner(ToggleButton, CORNER_RADIUS)
AddStroke(ToggleButton, COLORS.Border, 0.15, 1)

--==================================================
-- DRAGGING
--==================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

Dragging = true
DragStart = input.Position
StartPosition = Main.Position

input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
Dragging = false
end
end)
end
end)

UserInputService.InputChanged:Connect(function(input)
if Dragging and (
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
) then

local Delta = input.Position - DragStart

Main.Position = UDim2.new(
StartPosition.X.Scale,
StartPosition.X.Offset + Delta.X,
StartPosition.Y.Scale,
StartPosition.Y.Offset + Delta.Y
)
end
end)

--==================================================
-- PAGE CREATION
--==================================================

local function CreatePage(name)
local Page = Create("ScrollingFrame", {
Name = name,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2.fromOffset(0, 0),
Size = UDim2.new(1, 0, 1, 0),
CanvasSize = UDim2.fromOffset(0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 4,
ScrollBarImageColor3 = COLORS.Red,
ScrollBarImageTransparency = 0.15,
ScrollingDirection = Enum.ScrollingDirection.Y,
ScrollingEnabled = true,
ClipsDescendants = true,
Visible = false,
ZIndex = 6
}, PageHolder)

RegisterAccent(Page, "ScrollBarImageColor3")

AddPadding(Page, 1, 9, 1, 18)

local Layout = Create("UIListLayout", {
FillDirection = Enum.FillDirection.Vertical,
HorizontalAlignment = Enum.HorizontalAlignment.Left,
VerticalAlignment = Enum.VerticalAlignment.Top,
Padding = UDim.new(0, 8),
SortOrder = Enum.SortOrder.LayoutOrder
}, Page)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
Page.CanvasSize = UDim2.fromOffset(
0,
Layout.AbsoluteContentSize.Y + 24
)
end)

Pages[name] = Page

return Page
end

local MainPage = CreatePage("Main")
local PlayerPage = CreatePage("Player")
local VisualsPage = CreatePage("Visuals")
local WorldPage = CreatePage("World")
local CombatPage = CreatePage("Combat")
local MiscPage = CreatePage("Misc")
local SettingsPage = CreatePage("Settings")
local CreditsPage = CreatePage("Credits")

--==================================================
-- SECTION
--==================================================

local function CreateSection(parent, title, description)
local Section = Create("Frame", {
BackgroundColor3 = COLORS.Panel,
BorderSizePixel = 0,
Size = UDim2.new(1, -2, 0, 48),
ZIndex = 8
}, parent)

AddCorner(Section, CORNER_RADIUS)
AddStroke(Section, COLORS.Border, 0.2, 1)

local Accent = Create("Frame", {
BackgroundColor3 = COLORS.Red,
BorderSizePixel = 0,
Position = UDim2.fromOffset(0, 10),
Size = UDim2.fromOffset(3, 28),
ZIndex = 10
}, Section)

AddCorner(Accent, 1)
RegisterAccent(Accent, "BackgroundColor3")

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(13, 7),
Size = UDim2.new(1, -25, 0, 19),
Font = Enum.Font.GothamBold,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Section)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(13, 26),
Size = UDim2.new(1, -25, 0, 16),
Font = Enum.Font.Fantasy,
Text = description or "",
TextColor3 = COLORS.Muted,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Section)

return Section
end

--==================================================
-- TOGGLE
--==================================================

local function CreateToggle(parent, title, description, default, callback)
local Holder = Create("Frame", {
BackgroundColor3 = COLORS.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -2, 0, 58),
ZIndex = 8
}, parent)

AddCorner(Holder, CORNER_RADIUS)
AddStroke(Holder, COLORS.Border, 0.25, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 8),
Size = UDim2.new(1, -100, 0, 20),
Font = Enum.Font.Fantasy,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 29),
Size = UDim2.new(1, -100, 0, 17),
Font = Enum.Font.Fantasy,
Text = description or "",
TextColor3 = COLORS.Muted,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

-- Square toggle
local Switch = Create("TextButton", {
BackgroundColor3 = Color3.fromRGB(42, 42, 48),
BorderSizePixel = 0,
Position = UDim2.new(1, -60, 0.5, -11),
Size = UDim2.fromOffset(46, 22),
AutoButtonColor = false,
Text = "",
ZIndex = 12
}, Holder)

AddCorner(Switch, 3)
AddStroke(Switch, COLORS.Border, 0.15, 1)

local Indicator = Create("Frame", {
BackgroundColor3 = Color3.fromRGB(165, 165, 170),
BorderSizePixel = 0,
Position = UDim2.fromOffset(3, 3),
Size = UDim2.fromOffset(16, 16),
ZIndex = 13
}, Switch)

AddCorner(Indicator, 2)

local Enabled = default == true

local function Update(value, fireCallback)
Enabled = value

if Enabled then
Tween(Switch, 0.15, {
BackgroundColor3 = COLORS.RedDark
})

Tween(Indicator, 0.15, {
Position = UDim2.new(1, -19, 0, 3),
BackgroundColor3 = COLORS.White
})
else
Tween(Switch, 0.15, {
BackgroundColor3 = Color3.fromRGB(42, 42, 48)
})

Tween(Indicator, 0.15, {
Position = UDim2.fromOffset(3, 3),
BackgroundColor3 = Color3.fromRGB(165, 165, 170)
})
end

if fireCallback ~= false and callback then
callback(Enabled)
end
end

Switch.MouseButton1Click:Connect(function()
ClickSound()
SessionClicks += 1
Update(not Enabled, true)
end)

Update(Enabled, false)

local Control = {
Type = "Toggle",
Name = title,
Set = function(value)
Update(value == true, true)
end,

Get = function()
return Enabled
end
}

ConfigControls[title] = Control

return Control
end

--==================================================
-- SLIDER
--==================================================

local function CreateSlider(parent, title, description, min, max, default, callback)
local Holder = Create("Frame", {
BackgroundColor3 = COLORS.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -2, 0, 70),
ZIndex = 8
}, parent)

AddCorner(Holder, CORNER_RADIUS)
AddStroke(Holder, COLORS.Border, 0.25, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 8),
Size = UDim2.new(1, -100, 0, 19),
Font = Enum.Font.Fantasy,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

local ValueLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(1, -75, 0, 8),
Size = UDim2.fromOffset(60, 19),
Font = Enum.Font.GothamBold,
Text = tostring(default),
TextColor3 = COLORS.Red,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Right,
ZIndex = 10
}, Holder)

RegisterAccent(ValueLabel, "TextColor3")

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 27),
Size = UDim2.new(1, -28, 0, 16),
Font = Enum.Font.Fantasy,
Text = description or "",
TextColor3 = COLORS.Muted,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

-- Square slider track
local Bar = Create("Frame", {
BackgroundColor3 = Color3.fromRGB(38, 38, 44),
BorderSizePixel = 0,
Position = UDim2.fromOffset(14, 52),
Size = UDim2.new(1, -28, 0, 6),
ZIndex = 11
}, Holder)

AddCorner(Bar, 2)
AddStroke(Bar, COLORS.Border, 0.35, 1)

local Fill = Create("Frame", {
BackgroundColor3 = COLORS.Red,
BorderSizePixel = 0,
Size = UDim2.fromScale(0, 1),
ZIndex = 12
}, Bar)

AddCorner(Fill, 2)
RegisterAccent(Fill, "BackgroundColor3")

local Knob = Create("Frame", {
BackgroundColor3 = COLORS.White,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0, 0.5),
Size = UDim2.fromOffset(10, 10),
ZIndex = 13
}, Bar)

AddCorner(Knob, 2)

local Value = math.clamp(default, min, max)
local SliderDragging = false

local function SetValue(value, fireCallback)
Value = math.clamp(value, min, max)

local Percent = (Value - min) / (max - min)

Fill.Size = UDim2.fromScale(Percent, 1)
Knob.Position = UDim2.fromScale(Percent, 0.5)

ValueLabel.Text = tostring(Value)

if fireCallback ~= false and callback then
callback(Value)
end
end

local function SetFromMouse(x)
local Percent = math.clamp(
(x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
0,
1
)

local NewValue = min + ((max - min) * Percent)

SetValue(math.floor(NewValue + 0.5), true)
end

Bar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

SliderDragging = true
ClickSound()
SetFromMouse(input.Position.X)
end
end)

UserInputService.InputChanged:Connect(function(input)
if SliderDragging and (
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
) then

SetFromMouse(input.Position.X)
end
end)

UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

SliderDragging = false
end
end)

SetValue(Value, false)

local Control = {
Type = "Slider",
Name = title,
Set = function(value)
if type(value) == "number" then
SetValue(value, true)
end
end,

Get = function()
return Value
end
}

ConfigControls[title] = Control

return Control
end

--==================================================
-- BUTTON
--==================================================

local function CreateButton(parent, title, description, callback, buttonText)
local Holder = Create("Frame", {
BackgroundColor3 = COLORS.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -2, 0, 56),
ZIndex = 8
}, parent)

AddCorner(Holder, CORNER_RADIUS)
AddStroke(Holder, COLORS.Border, 0.25, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 8),
Size = UDim2.new(1, -145, 0, 20),
Font = Enum.Font.Fantasy,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 29),
Size = UDim2.new(1, -145, 0, 17),
Font = Enum.Font.Fantasy,
Text = description or "",
TextColor3 = COLORS.Muted,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

local Button = Create("TextButton", {
BackgroundColor3 = COLORS.Red,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(100, 30),
AutoButtonColor = false,
Font = Enum.Font.GothamBold,
Text = buttonText or "EXECUTE",
TextColor3 = COLORS.White,
TextSize = 10,
ZIndex = 12
}, Holder)

AddCorner(Button, CORNER_RADIUS)
RegisterAccent(Button, "BackgroundColor3")

Button.MouseEnter:Connect(function()
Tween(Button, 0.12, {
BackgroundColor3 = COLORS.RedHover
})
end)

Button.MouseLeave:Connect(function()
Tween(Button, 0.12, {
BackgroundColor3 = COLORS.Red
})
end)

Button.MouseButton1Click:Connect(function()
ClickSound()
SessionClicks += 1

if callback then
callback()
end
end)

return Button
end

--==================================================
-- DROPDOWN
--==================================================

local function CloseDropdown()
if DropdownOpen then
DropdownOpen.Visible = false
DropdownOpen = nil
end
end

local function CreateDropdown(parent, title, description, options, default, callback)
local Holder = Create("Frame", {
BackgroundColor3 = COLORS.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -2, 0, 62),
ZIndex = 8
}, parent)

AddCorner(Holder, CORNER_RADIUS)
AddStroke(Holder, COLORS.Border, 0.25, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 8),
Size = UDim2.new(1, -190, 0, 20),
Font = Enum.Font.Fantasy,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 29),
Size = UDim2.new(1, -190, 0, 17),
Font = Enum.Font.Fantasy,
Text = description or "",
TextColor3 = COLORS.Muted,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

local Select = Create("TextButton", {
BackgroundColor3 = COLORS.Panel3,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(145, 32),
AutoButtonColor = false,
Font = Enum.Font.Fantasy,
Text = tostring(default),
TextColor3 = COLORS.Text,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 12
}, Holder)

AddCorner(Select, CORNER_RADIUS)
AddStroke(Select, COLORS.Border, 0.15, 1)
AddPadding(Select, 10, 25, 0, 0)

Create("TextLabel", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.fromOffset(16, 16),
Font = Enum.Font.GothamBold,
Text = "â–¼",
TextColor3 = COLORS.Muted,
TextSize = 8,
ZIndex = 13
}, Select)

local Popup = Create("Frame", {
Name = "DropdownPopup",
BackgroundColor3 = Color3.fromRGB(14, 14, 18),
BorderSizePixel = 0,
Visible = false,
Size = UDim2.fromOffset(145, 100),
ZIndex = 1001,
ClipsDescendants = false
}, DropdownOverlay)

AddCorner(Popup, CORNER_RADIUS)
AddStroke(Popup, COLORS.Border, 0.05, 1)
AddPadding(Popup, 4, 4, 4, 4)

local PopupLayout = Create("UIListLayout", {
FillDirection = Enum.FillDirection.Vertical,
HorizontalAlignment = Enum.HorizontalAlignment.Center,
VerticalAlignment = Enum.VerticalAlignment.Top,
Padding = UDim.new(0, 2)
}, Popup)

local Selected = default

local function UpdatePosition()
if not Popup.Visible then
return
end

local AbsolutePosition = Select.AbsolutePosition
local AbsoluteSize = Select.AbsoluteSize

local PopupHeight = PopupLayout.AbsoluteContentSize.Y + 8
local ViewportSize = DropdownOverlay.AbsoluteSize

local X = AbsolutePosition.X
local Y = AbsolutePosition.Y + AbsoluteSize.Y + 4

Popup.Size = UDim2.fromOffset(
AbsoluteSize.X,
PopupHeight
)

if Y + PopupHeight > ViewportSize.Y - 5 then
Y = AbsolutePosition.Y - PopupHeight - 4
end

if X + AbsoluteSize.X > ViewportSize.X - 5 then
X = ViewportSize.X - AbsoluteSize.X - 5
end

if X < 5 then
X = 5
end

Popup.Position = UDim2.fromOffset(X, Y)
end

local function Choose(option)
Selected = option
Select.Text = tostring(option)

CloseDropdown()
ClickSound()
SessionClicks += 1

if callback then
callback(option)
end
end

for _, option in ipairs(options) do
local OptionButton = Create("TextButton", {
BackgroundColor3 = Color3.fromRGB(21, 21, 26),
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 28),
AutoButtonColor = false,
Font = Enum.Font.Fantasy,
Text = tostring(option),
TextColor3 = COLORS.Text,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 1002
}, Popup)

AddCorner(OptionButton, CORNER_RADIUS)
AddPadding(OptionButton, 8, 5, 0, 0)

OptionButton.MouseEnter:Connect(function()
OptionButton.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
end)

OptionButton.MouseLeave:Connect(function()
OptionButton.BackgroundColor3 = Color3.fromRGB(21, 21, 26)
end)

OptionButton.MouseButton1Click:Connect(function()
Choose(option)
end)
end

Select.MouseButton1Click:Connect(function()
if Popup.Visible then
CloseDropdown()
else
CloseDropdown()

Popup.Visible = true
DropdownOpen = Popup

UpdatePosition()
ClickSound()
end
end)

table.insert(DropdownUpdaters, UpdatePosition)

local Control = {
Type = "Dropdown",
Name = title,
Set = function(value)
for _, option in ipairs(options) do
if option == value then
Choose(value)
return
end
end
end,

Get = function()
return Selected
end
}

ConfigControls[title] = Control

return Control
end

--==================================================
-- TEXTBOX
--==================================================

local function CreateTextbox(parent, title, description, placeholder, callback)
local Holder = Create("Frame", {
BackgroundColor3 = COLORS.Panel2,
BorderSizePixel = 0,
Size = UDim2.new(1, -2, 0, 62),
ZIndex = 8
}, parent)

AddCorner(Holder, CORNER_RADIUS)
AddStroke(Holder, COLORS.Border, 0.25, 1)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 8),
Size = UDim2.new(1, -210, 0, 20),
Font = Enum.Font.Fantasy,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 29),
Size = UDim2.new(1, -210, 0, 17),
Font = Enum.Font.Fantasy,
Text = description or "",
TextColor3 = COLORS.Muted,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 10
}, Holder)

local Box = Create("TextBox", {
BackgroundColor3 = COLORS.Panel3,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(170, 32),
Font = Enum.Font.Fantasy,
PlaceholderText = placeholder or "Enter text...",
PlaceholderColor3 = COLORS.Muted,
Text = "",
TextColor3 = COLORS.White,
TextSize = 11,
ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 12
}, Holder)

AddCorner(Box, CORNER_RADIUS)
AddStroke(Box, COLORS.Border, 0.15, 1)
AddPadding(Box, 9, 9, 0, 0)

Box.FocusLost:Connect(function()
if callback then
callback(Box.Text)
end
end)

return Box
end

--==================================================
-- NOTIFY
--==================================================

local function Notify(title, message, duration)
if not NotificationsEnabled then
return
end

duration = duration or 3

local Notification = Create("Frame", {
BackgroundColor3 = COLORS.Panel,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.fromOffset(285, 68),
ZIndex = 901
}, NotificationHolder)

AddCorner(Notification, CORNER_RADIUS)
AddStroke(Notification, COLORS.Border, 0.1, 1)

local Accent = Create("Frame", {
BackgroundColor3 = COLORS.Red,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.fromOffset(3, 68),
ZIndex = 902
}, Notification)

AddCorner(Accent, 1)
RegisterAccent(Accent, "BackgroundColor3")

local TitleLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 9),
Size = UDim2.new(1, -25, 0, 20),
Font = Enum.Font.GothamBold,
Text = title,
TextColor3 = COLORS.White,
TextSize = 13,
TextTransparency = 1,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 903
}, Notification)

local MessageLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(14, 30),
Size = UDim2.new(1, -25, 0, 28),
Font = Enum.Font.Fantasy,
Text = message,
TextColor3 = COLORS.Muted,
TextSize = 10,
TextWrapped = true,
TextTransparency = 1,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 903
}, Notification)

Tween(Notification, 0.2, {
BackgroundTransparency = 0
})

Tween(Accent, 0.2, {
BackgroundTransparency = 0
})

Tween(TitleLabel, 0.2, {
TextTransparency = 0
})

Tween(MessageLabel, 0.2, {
TextTransparency = 0
})

task.delay(duration, function()
if not Notification.Parent then
return
end

Tween(Notification, 0.2, {
BackgroundTransparency = 1
})

Tween(Accent, 0.2, {
BackgroundTransparency = 1
})

Tween(TitleLabel, 0.2, {
TextTransparency = 1
})

Tween(MessageLabel, 0.2, {
TextTransparency = 1
})

task.wait(0.25)

if Notification then
Notification:Destroy()
end
end)
end

--==================================================
-- FEATURE STATUS
--==================================================

local StatusLabel = Create("TextLabel", {
Name = "FeatureStatus",
BackgroundColor3 = COLORS.Panel,
BackgroundTransparency = 0.05,
BorderSizePixel = 0,
Position = UDim2.fromOffset(10, 10),
Size = UDim2.fromOffset(160, 28),
Font = Enum.Font.GothamBold,
Text = "STATUS: READY",
TextColor3 = COLORS.Red,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Center,
Visible = true,
ZIndex = 700
}, ScreenGui)

AddCorner(StatusLabel, CORNER_RADIUS)
AddStroke(StatusLabel, COLORS.Border, 0.15, 1)

local function UpdateStatus()
local Count = 0

for _, State in pairs(FeatureStates) do
if State then
Count += 1
end
end

StatusLabel.Text = "ACTIVE: " .. tostring(Count)
end

local function RegisterFeature(name, value)
FeatureStates[name] = value
UpdateStatus()
end

--==================================================
-- TAB
--==================================================

local function CreateTab(name, order)
local Button = Create("TextButton", {
Name = name,
BackgroundColor3 = Color3.fromRGB(15, 15, 18),
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 37),
AutoButtonColor = false,
Text = name,
LayoutOrder = order,
Font = Enum.Font.Fantasy,
TextColor3 = COLORS.Muted,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 9
}, TabHolder)

AddCorner(Button, CORNER_RADIUS)
AddPadding(Button, 14, 8, 0, 0)

local Indicator = Create("Frame", {
BackgroundColor3 = COLORS.Red,
BorderSizePixel = 0,
Position = UDim2.fromOffset(0, 7),
Size = UDim2.fromOffset(3, 23),
Visible = false,
ZIndex = 12
}, Button)

AddCorner(Indicator, 1)
RegisterAccent(Indicator, "BackgroundColor3")

Tabs[name] = {
Button = Button,
Label = Button,
Indicator = Indicator
}

Button.MouseEnter:Connect(function()
if CurrentTab ~= name then
Tween(Button, 0.12, {
BackgroundColor3 = Color3.fromRGB(21, 21, 25)
})
end
end)

Button.MouseLeave:Connect(function()
if CurrentTab ~= name then
Tween(Button, 0.12, {
BackgroundColor3 = Color3.fromRGB(15, 15, 18)
})
end
end)

Button.MouseButton1Click:Connect(function()
ClickSound()
SessionClicks += 1
CurrentTab = name

for TabName, Data in pairs(Tabs) do
local Active = TabName == name
Data.Indicator.Visible = Active

if Active then
Data.Button.BackgroundColor3 = Color3.fromRGB(29, 20, 23)
Data.Label.TextColor3 = COLORS.White
Data.Label.Font = Enum.Font.GothamBold
else
Data.Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Data.Label.TextColor3 = COLORS.Muted
Data.Label.Font = Enum.Font.Fantasy
end
end

for PageName, Page in pairs(Pages) do
Page.Visible = PageName == name
end
end)

return Button
end

--==================================================
-- CREATE ALL TABS
--==================================================

CreateTab("Main", 1)
CreateTab("Player", 2)
CreateTab("Visuals", 3)
CreateTab("World", 4)
CreateTab("Combat", 5)
CreateTab("Misc", 6)
CreateTab("Settings", 7)
CreateTab("Credits", 8)

--==================================================
-- MAIN
--==================================================

CreateSection(
MainPage,
"Main",
"Basic features, status and general controls."
)

local MainEnabled = CreateToggle(
MainPage,
"Script Enable",
"Enable or disable the main feature system.",
true,
function(state)
MainScriptEnabled = state
RegisterFeature("Script", state)

if not state then
ClearAllRuntimeFeatures()
end

if state then
	Notify("Flarehook", "Feature system enabled.", 2)
else
	Notify("Flarehook", "Feature system disabled.", 2)
end
end
)

local PanicToggle = CreateToggle(
MainPage,
"Panic / Disable All",
"Quickly disable active Flarehook features.",
false,
function(state)
PanicEnabled = state
RegisterFeature("Panic", state)

if state then
for Name in pairs(FeatureStates) do
if Name ~= "Panic" and Name ~= "Script" then
FeatureStates[Name] = false
end
end

UpdateStatus()
Notify("Flarehook", "All feature states disabled.", 2)
end
end
)

CreateSection(
MainPage,
"Status",
"Current session and feature information."
)

CreateToggle(
MainPage,
"Feature Status Display",
"Show the active feature counter.",
true,
function(state)
StatusLabel.Visible = state
end
)

CreateToggle(
MainPage,
"Notifications",
"Enable Flarehook notifications.",
true,
function(state)
NotificationsEnabled = state
end
)

CreateToggle(
MainPage,
"Performance / FPS",
"Show the current frame-rate counter.",
false,
function(state)
local FPSLabel = ScreenGui:FindFirstChild("FPSDisplay")

if state and not FPSLabel then
FPSLabel = Create("TextLabel", {
Name = "FPSDisplay",
BackgroundColor3 = COLORS.Panel,
BorderSizePixel = 0,
Position = UDim2.fromOffset(10, 44),
Size = UDim2.fromOffset(160, 26),
Font = Enum.Font.GothamBold,
Text = "FPS: --",
TextColor3 = COLORS.Text,
TextSize = 10,
ZIndex = 700
}, ScreenGui)

AddCorner(FPSLabel, CORNER_RADIUS)
AddStroke(FPSLabel, COLORS.Border, 0.15, 1)
end

if FPSLabel then
FPSLabel.Visible = state
end
end
)

CreateSection(
MainPage,
"Information",
"Server, player and session statistics."
)

CreateButton(
MainPage,
"Server Information",
"Display the current server details.",
function()
local PlaceId = game.PlaceId
local JobId = game.JobId

Notify(
"Server",
"Place: " .. tostring(PlaceId) ..
" | Job: " .. string.sub(tostring(JobId), 1, 12),
4
)
end,
"VIEW"
)

CreateButton(
MainPage,
"Player Information",
"Display your local player information.",
function()
local Character = GetCharacter()
local Humanoid = GetHumanoid()

local Health = Humanoid and math.floor(Humanoid.Health) or 0
local MaxHealth = Humanoid and math.floor(Humanoid.MaxHealth) or 0

Notify(
"Player",
"Name: " .. Player.Name ..
" | UserId: " .. tostring(Player.UserId) ..
" | HP: " .. Health .. "/" .. MaxHealth,
4
)
end,
"VIEW"
)

CreateButton(
MainPage,
"Session Statistics",
"Display session time and UI interactions.",
function()
local Seconds = math.floor(os.clock() - SessionStart)

Notify(
"Session",
"Time: " .. tostring(Seconds) ..
"s | UI clicks: " .. tostring(SessionClicks),
4
)
end,
"VIEW"
)

--==================================================
-- PLAYER
--==================================================

CreateSection(
PlayerPage,
"Movement",
"Character movement settings."
)

local WalkSpeedSlider = CreateSlider(
PlayerPage,
"Walk Speed",
"Set the humanoid walking speed.",
1,
100,
16,
function(value)
local Humanoid = GetHumanoid()

if Humanoid and MovementEnabled then
Humanoid.WalkSpeed = value
end

RegisterFeature("Walk Speed", value ~= 16)
end
)

local JumpPowerSlider = CreateSlider(
PlayerPage,
"Jump Power",
"Set the humanoid jump power.",
1,
150,
50,
function(value)
local Humanoid = GetHumanoid()

if Humanoid and MovementEnabled then
Humanoid.UseJumpPower = true
Humanoid.JumpPower = value
end

RegisterFeature("Jump Power", value ~= 50)
end
)

local MovementToggle = CreateToggle(
PlayerPage,
"Movement",
"Enable or disable custom movement settings.",
true,
function(state)
MovementEnabled = state
RegisterFeature("Movement", state)

local Humanoid = GetHumanoid()

if Humanoid then
if state then
Humanoid.WalkSpeed = WalkSpeedSlider.Get()
Humanoid.UseJumpPower = true
Humanoid.JumpPower = JumpPowerSlider.Get()
else
Humanoid.WalkSpeed = 16
Humanoid.UseJumpPower = true
Humanoid.JumpPower = 50
end
end
end
)

CreateSlider(
PlayerPage,
"FOV",
"Adjust the local camera field of view.",
40,
120,
70,
function(value)
if Camera then
Camera.FieldOfView = value
end
end
)

CreateSlider(
PlayerPage,
"Camera Sensitivity",
"Adjust mouse camera sensitivity.",
1,
100,
50,
function(value)
-- Roblox camera sensitivity is controlled by the player's
-- mouse settings; this stores the desired UI value.
Player:SetAttribute("FlarehookCameraSensitivity", value / 50)
end
)

CreateToggle(
PlayerPage,
"Third-Person Camera",
"Switch between first and third person.",
false,
function(state)
ThirdPersonEnabled = state
RegisterFeature("Third Person", state)

if state then
Player.CameraMode = Enum.CameraMode.Classic
Player.CameraMinZoomDistance = 5
Player.CameraMaxZoomDistance = 12
else
Player.CameraMode = Enum.CameraMode.Classic
Player.CameraMinZoomDistance = 0.5
Player.CameraMaxZoomDistance = 0.5
end
end
)

CreateSection(
PlayerPage,
"Character",
"Character visibility and reset controls."
)

CreateButton(
PlayerPage,
"Character Reset",
"Reset your current character.",
function()
local Humanoid = GetHumanoid()

if Humanoid then
Humanoid.Health = 0
end
end,
"RESET"
)

CreateToggle(
PlayerPage,
"Character Visibility",
"Toggle local character visibility.",
true,
function(state)
CharacterVisible = state

if state then
SetCharacterTransparency(0)
else
SetCharacterTransparency(1)
end

RegisterFeature("Character Visibility", state)
end
)


--==================================================
-- RUNTIME FEATURE HELPERS
--==================================================

local RuntimeFolder = Create("Folder", {
	Name = "FlarehookRuntime"
}, ScreenGui)

local ESPObjects = {}
local HitboxOriginals = {}
local TargetLockedPlayer = nil
local LastShot = 0
local LastHitEffect = 0

local function IsAlive(player)
	if not player or player == Player then
		return false
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	return character ~= nil and humanoid ~= nil and humanoid.Health > 0 and root ~= nil
end

local function IsTeammate(player)
	if not TeamCheckEnabled then
		return false
	end

	return player.Team ~= nil and Player.Team ~= nil and player.Team == Player.Team
end

local function GetTargetPart(player)
	if not IsAlive(player) then
		return nil
	end

	local character = player.Character
	return character:FindFirstChild(TargetPartName)
		or character:FindFirstChild("Head")
		or character:FindFirstChild("HumanoidRootPart")
end

local function HasLineOfSight(part)
	if not VisibilityCheckEnabled or not part then
		return true
	end

	local origin = Camera.CFrame.Position
	local direction = part.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Player.Character, RuntimeFolder}

	local result = workspace:Raycast(origin, direction, params)
	return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function GetPredictedPosition(part)
	if not part then
		return nil
	end

	local velocity = part.AssemblyLinearVelocity
	return part.Position + velocity * PredictionAmount
end

local function GetScreenDistance(worldPosition)
	local screenPoint, onScreen = Camera:WorldToViewportPoint(worldPosition)
	if not onScreen then
		return math.huge, screenPoint
	end

	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local point = Vector2.new(screenPoint.X, screenPoint.Y)

	return (point - center).Magnitude, screenPoint
end

local function GetTarget()
	local bestPlayer = nil
	local bestScore = math.huge
	local closestDistance = math.huge

	if TargetLockEnabled and TargetLockedPlayer and IsAlive(TargetLockedPlayer)
		and not IsTeammate(TargetLockedPlayer) then
		local lockedPart = GetTargetPart(TargetLockedPlayer)
		if lockedPart and HasLineOfSight(lockedPart) then
			return TargetLockedPlayer, lockedPart
		end
	end

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if IsAlive(otherPlayer) and not IsTeammate(otherPlayer) then
			local part = GetTargetPart(otherPlayer)
			if part and HasLineOfSight(part) then
				local distance = (part.Position - Camera.CFrame.Position).Magnitude
				local screenDistance = GetScreenDistance(part.Position)

				if distance <= (Player:GetAttribute("FlarehookRange") or 100) then
					local score

					if TargetPriority == "Lowest Health" then
						local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
						score = humanoid and humanoid.Health or math.huge
					elseif TargetPriority == "Closest to Player" then
						score = distance
					elseif TargetPriority == "Closest to Crosshair" then
						score = screenDistance
					else
						score = screenDistance
					end

					if TargetPriority == "Closest to Crosshair" and screenDistance > AimFOV then
						continue
					end

					if score < bestScore then
						bestScore = score
						bestPlayer = otherPlayer
						closestDistance = distance
					end
				end
			end
		end
	end

	if bestPlayer and TargetLockEnabled then
		TargetLockedPlayer = bestPlayer
	end

	return bestPlayer, bestPlayer and GetTargetPart(bestPlayer)
end

local function ClearTargetLock()
	TargetLockedPlayer = nil
end

local function AimAt(part, smoothing)
	if not part or not Camera then
		return
	end

	local predicted = GetPredictedPosition(part)
	if not predicted then
		return
	end

	local desired = CFrame.lookAt(Camera.CFrame.Position, predicted)
	local alpha = math.clamp(smoothing, 0, 1)

	-- 0 = instant snap, 1 = slow.
	if alpha <= 0 then
		Camera.CFrame = desired
	else
		Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
	end
end

local function GetEquippedTool()
	local character = Player.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Tool")
end

local function FireCurrentTool()
	local tool = GetEquippedTool()
	if not tool then
		return false
	end

	local now = os.clock()
	if now - LastShot < 0.08 then
		return false
	end

	LastShot = now
	tool:Activate()
	return true
end

local function MakeCrosshair()
	local old = ScreenGui:FindFirstChild("FlarehookCrosshair")
	if old then
		old:Destroy()
	end

	local holder = Create("Frame", {
		Name = "FlarehookCrosshair",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(80, 80),
		ZIndex = 800
	}, ScreenGui)

	local circle = Create("Frame", {
		Name = "Circle",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(CrosshairSize * 2 + CrosshairGap * 2, CrosshairSize * 2 + CrosshairGap * 2),
		ZIndex = 801
	}, holder)

	AddCorner(circle, 100)
	local stroke = AddStroke(circle, CrosshairColor, 0, CrosshairThickness)
	stroke.Name = "CrosshairStroke"

	local dot = Create("Frame", {
		Name = "Dot",
		BackgroundColor3 = CrosshairColor,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(CrosshairSize, CrosshairSize),
		ZIndex = 802
	}, holder)

	AddCorner(dot, 100)

	return holder
end

local function ClearESP(player)
	local data = ESPObjects[player]
	if not data then
		return
	end

	for _, object in pairs(data) do
		if typeof(object) == "Instance" and object.Parent then
			object:Destroy()
		end
	end

	ESPObjects[player] = nil
end

local function BuildESP(player)
	if player == Player or not IsAlive(player) then
		return
	end

	ClearESP(player)

	local character = player.Character
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not head or not root or not humanoid then
		return
	end

	local billboard = Create("BillboardGui", {
		Name = "FlarehookESP",
		Adornee = head,
		Size = UDim2.fromOffset(190, 70),
		StudsOffset = Vector3.new(0, 2.8, 0),
		AlwaysOnTop = true,
		Enabled = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, RuntimeFolder)

	local nameLabel = Create("TextLabel", {
		Name = "Name",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Font = Enum.Font.GothamBold,
		Text = player.DisplayName ~= "" and player.DisplayName or player.Name,
		TextColor3 = ESPColor,
		TextSize = 13,
		TextStrokeTransparency = 0.5,
		Visible = NameTagsEnabled or ESPEnabled
	}, billboard)

	local healthBack = Create("Frame", {
		Name = "HealthBack",
		BackgroundColor3 = Color3.fromRGB(30, 30, 34),
		BorderSizePixel = 0,
		Position = UDim2.new(0.1, 0, 0, 25),
		Size = UDim2.new(0.8, 0, 0, 7),
		Visible = HealthBarsEnabled or ESPEnabled
	}, billboard)
	AddCorner(healthBack, 2)

	local healthFill = Create("Frame", {
		Name = "Health",
		BackgroundColor3 = ESPColor,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1)
	}, healthBack)
	AddCorner(healthFill, 2)

	local distanceLabel = Create("TextLabel", {
		Name = "Distance",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.Fantasy,
		TextColor3 = COLORS.Text,
		TextSize = 10,
		TextStrokeTransparency = 0.6,
		Visible = DistanceEnabled or ESPEnabled
	}, billboard)

	local tracer = Create("Frame", {
		Name = "Tracer",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = ESPColor,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(2, 100),
		Visible = false,
		ZIndex = 790
	}, ScreenGui)

	ESPObjects[player] = {
		Billboard = billboard,
		Name = nameLabel,
		HealthBack = healthBack,
		Health = healthFill,
		Distance = distanceLabel,
		Tracer = tracer,
	}
end

local function RefreshESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Player then
			if ESPEnabled or NameTagsEnabled or HealthBarsEnabled or DistanceEnabled or TracersEnabled then
				BuildESP(player)
			else
				ClearESP(player)
			end
		end
	end
end

local function ApplyHitboxes()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Player and IsAlive(player) and not IsTeammate(player) then
			local head = player.Character:FindFirstChild("Head")
			if head then
				if HitboxEnabled then
					if not HitboxOriginals[head] then
						HitboxOriginals[head] = {
							Size = head.Size,
							Transparency = head.Transparency,
							CanCollide = head.CanCollide
						}
					end

					head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
					head.Transparency = math.max(head.Transparency, 0.5)
					head.CanCollide = false
				elseif HitboxOriginals[head] then
					local original = HitboxOriginals[head]
					head.Size = original.Size
					head.Transparency = original.Transparency
					head.CanCollide = original.CanCollide
					HitboxOriginals[head] = nil
				end
			end
		end
	end
end

local function ClearAllRuntimeFeatures()
	AimAssistEnabled = false
	AimbotEnabled = false
	TriggerbotEnabled = false
	HitboxEnabled = false
	AutoShootEnabled = false
	FOVCircleEnabled = false
	TargetLockEnabled = false
	RecoilControlEnabled = false
	ESPEnabled = false
	NameTagsEnabled = false
	HealthBarsEnabled = false
	DistanceEnabled = false
	TracersEnabled = false
	TeamColorsEnabled = false
	HitEffectsEnabled = false
	ClearTargetLock()

	for player in pairs(ESPObjects) do
		ClearESP(player)
	end

	for part, original in pairs(HitboxOriginals) do
		if part and part.Parent then
			part.Size = original.Size
			part.Transparency = original.Transparency
			part.CanCollide = original.CanCollide
		end
		HitboxOriginals[part] = nil
	end

	local crosshair = ScreenGui:FindFirstChild("FlarehookCrosshair")
	if crosshair then
		crosshair.Visible = false
	end
end

--==================================================
-- VISUALS
--==================================================

CreateSection(
	VisualsPage,
	"Player Visuals",
	"ESP, names, health, distance, tracers and team colors."
)

CreateToggle(
	VisualsPage,
	"ESP",
	"Enable the full player ESP package.",
	false,
	function(state)
		ESPEnabled = state
		RegisterFeature("ESP", state)
		RefreshESP()
	end
)

CreateToggle(
	VisualsPage,
	"Player Highlights",
	"Highlight other players.",
	false,
	function(state)
		RegisterFeature("Player Highlights", state)

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= Player and otherPlayer.Character then
				local highlight = otherPlayer.Character:FindFirstChild("FlarehookHighlight")

				if state then
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "FlarehookHighlight"
						highlight.FillColor = TeamColorsEnabled and (otherPlayer.TeamColor.Color or COLORS.Red) or ESPColor
						highlight.OutlineColor = COLORS.White
						highlight.FillTransparency = 0.65
						highlight.OutlineTransparency = 0.2
						highlight.Parent = otherPlayer.Character
					end
				elseif highlight then
					highlight:Destroy()
				end
			end
		end
	end
)

CreateToggle(
	VisualsPage,
	"Name Tags",
	"Show player names above characters.",
	false,
	function(state)
		NameTagsEnabled = state
		RegisterFeature("Name Tags", state)
		RefreshESP()
	end
)

CreateToggle(
	VisualsPage,
	"Health Bars",
	"Show health bars above characters.",
	false,
	function(state)
		HealthBarsEnabled = state
		RegisterFeature("Health Bars", state)
		RefreshESP()
	end
)

CreateToggle(
	VisualsPage,
	"Distance",
	"Show the distance to each player.",
	false,
	function(state)
		DistanceEnabled = state
		RegisterFeature("Distance", state)
		RefreshESP()
	end
)

CreateToggle(
	VisualsPage,
	"Tracers",
	"Draw lines from the screen center to players.",
	false,
	function(state)
		TracersEnabled = state
		RegisterFeature("Tracers", state)
		RefreshESP()
	end
)

CreateToggle(
	VisualsPage,
	"Team Colors",
	"Use each player's team color in ESP.",
	false,
	function(state)
		TeamColorsEnabled = state
		RegisterFeature("Team Colors", state)
		RefreshESP()
	end
)

CreateSection(
	VisualsPage,
	"Crosshair",
	"Custom circle crosshair controls."
)

CreateToggle(
	VisualsPage,
	"Crosshair",
	"Show the actual circular crosshair.",
	false,
	function(state)
		RegisterFeature("Crosshair", state)

		local crosshair = ScreenGui:FindFirstChild("FlarehookCrosshair")
		if not crosshair then
			crosshair = MakeCrosshair()
		end

		crosshair.Visible = state
	end
)

CreateSlider(
	VisualsPage,
	"Crosshair Size",
	"Adjust the center-dot size.",
	1,
	12,
	4,
	function(value)
		CrosshairSize = value
		local crosshair = ScreenGui:FindFirstChild("FlarehookCrosshair")
		if crosshair then
			local dot = crosshair:FindFirstChild("Dot")
			local circle = crosshair:FindFirstChild("Circle")
			if dot then dot.Size = UDim2.fromOffset(value, value) end
			if circle then circle.Size = UDim2.fromOffset(value * 2 + CrosshairGap * 2, value * 2 + CrosshairGap * 2) end
		end
	end
)

CreateSlider(
	VisualsPage,
	"Crosshair Gap",
	"Adjust the gap around the center dot.",
	0,
	20,
	5,
	function(value)
		CrosshairGap = value
		local crosshair = ScreenGui:FindFirstChild("FlarehookCrosshair")
		if crosshair then
			local circle = crosshair:FindFirstChild("Circle")
			if circle then circle.Size = UDim2.fromOffset(CrosshairSize * 2 + value * 2, CrosshairSize * 2 + value * 2) end
		end
	end
)

CreateSlider(
	VisualsPage,
	"Crosshair Thickness",
	"Adjust the circle outline thickness.",
	1,
	6,
	2,
	function(value)
		CrosshairThickness = value
		local crosshair = ScreenGui:FindFirstChild("FlarehookCrosshair")
		if crosshair then
			local circle = crosshair:FindFirstChild("Circle")
			local stroke = circle and circle:FindFirstChild("CrosshairStroke")
			if stroke then stroke.Thickness = value end
		end
	end
)

CreateToggle(
	VisualsPage,
	"Hit-Effect Visuals",
	"Create a local screen flash when a hit is detected by your game.",
	false,
	function(state)
		HitEffectsEnabled = state
		RegisterFeature("Hit Effects", state)
	end
)

--==================================================
-- WORLD
--==================================================

CreateSection(
WorldPage,
"World / Lighting",
"Environment-related settings."
)

CreateToggle(
WorldPage,
"World / Lighting Effects",
"Enable local lighting modifications.",
false,
function(state)
RegisterFeature("World Lighting", state)

if state then
Lighting:SetAttribute("FlarehookLighting", true)
else
Lighting:SetAttribute("FlarehookLighting", false)
end
end
)

local BrightnessSlider = CreateSlider(
WorldPage,
"Brightness",
"Adjust local lighting brightness.",
0,
10,
math.floor(Lighting.Brightness),
function(value)
Lighting.Brightness = value
end
)

local ClockSlider = CreateSlider(
WorldPage,
"Clock Time",
"Adjust local world time.",
0,
24,
math.floor(Lighting.ClockTime),
function(value)
Lighting.ClockTime = value
end
)

CreateDropdown(
WorldPage,
"Technology",
"Select a lighting technology preset.",
{
"Default",
"ShadowMap",
"Future",
"Compatibility"
},
"Default",
function(option)
local Map = {
Default = Enum.Technology.ShadowMap,
ShadowMap = Enum.Technology.ShadowMap,
Future = Enum.Technology.Future,
Compatibility = Enum.Technology.Compatibility
}

if Map[option] then
Lighting.Technology = Map[option]
end
end
)

CreateToggle(
WorldPage,
"Global Shadows",
"Toggle global lighting shadows.",
true,
function(state)
Lighting.GlobalShadows = state
end
)

CreateToggle(
WorldPage,
"Ambient Effect",
"Apply a darker local ambient effect.",
false,
function(state)
if state then
Lighting.Ambient = Color3.fromRGB(80, 80, 85)
Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 75)
else
Lighting.Ambient = Color3.fromRGB(0, 0, 0)
Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
end
end
)

--==================================================
-- COMBAT
--==================================================

CreateSection(
	CombatPage,
	"Aiming",
	"Targeting controls for your own game's combat system."
)

CreateToggle(
	CombatPage,
	"Aim Assist",
	"Smoothly moves the camera toward the selected target.",
	false,
	function(state)
		AimAssistEnabled = state
		RegisterFeature("Aim Assist", state)
	end
)

CreateToggle(
	CombatPage,
	"Aimbot",
	"Automatically aims at the selected target.",
	false,
	function(state)
		AimbotEnabled = state
		RegisterFeature("Aimbot", state)
	end
)

CreateToggle(
	CombatPage,
	"Target Lock",
	"Keep the current target until it becomes invalid.",
	false,
	function(state)
		TargetLockEnabled = state
		RegisterFeature("Target Lock", state)
		if not state then
			ClearTargetLock()
		end
	end
)

CreateToggle(
	CombatPage,
	"Team Check",
	"Ignore teammates when selecting targets.",
	true,
	function(state)
		TeamCheckEnabled = state
	end
)

CreateToggle(
	CombatPage,
	"Visibility Check",
	"Only target players that are visible from the camera.",
	true,
	function(state)
		VisibilityCheckEnabled = state
	end
)

CreateSlider(
	CombatPage,
	"FOV Circle",
	"Set the targeting radius in screen pixels.",
	20,
	500,
	120,
	function(value)
		AimFOV = value
		Player:SetAttribute("FlarehookAimFOV", value)
	end
)

CreateToggle(
	CombatPage,
	"FOV Circle Display",
	"Show the targeting circle around the crosshair.",
	false,
	function(state)
		FOVCircleEnabled = state
		RegisterFeature("FOV Circle", state)

		local circle = ScreenGui:FindFirstChild("FlarehookFOVCircle")
		if not circle then
			circle = Create("Frame", {
				Name = "FlarehookFOVCircle",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(AimFOV * 2, AimFOV * 2),
				ZIndex = 799
			}, ScreenGui)
			AddCorner(circle, 1000)
			AddStroke(circle, COLORS.Red, 0.15, 1)
		end

		circle.Visible = state
	end
)

CreateDropdown(
	CombatPage,
	"Target Priority",
	"Choose how targets are prioritized.",
	{
		"Closest to Crosshair",
		"Closest to Player",
		"Lowest Health"
	},
	"Closest to Crosshair",
	function(option)
		TargetPriority = option
		Player:SetAttribute("FlarehookTargetPriority", option)
		ClearTargetLock()
	end
)

CreateDropdown(
	CombatPage,
	"Target Part",
	"Choose which body part is aimed at.",
	{
		"Head",
		"HumanoidRootPart"
	},
	"Head",
	function(option)
		TargetPartName = option
	end
)

CreateSlider(
	CombatPage,
	"Prediction",
	"Lead moving targets by their current velocity.",
	0,
	1,
	0,
	function(value)
		PredictionAmount = value / 10
		Player:SetAttribute("FlarehookPrediction", PredictionAmount)
	end
)

CreateSlider(
	CombatPage,
	"Smoothing",
	"0 snaps instantly; 1 is very slow.",
	0,
	100,
	35,
	function(value)
		AimSmoothing = value / 100
		Player:SetAttribute("FlarehookSmoothness", AimSmoothing)
	end
)

CreateSlider(
	CombatPage,
	"Aim Assist Speed",
	"Aim Assist is intentionally faster than maximum smoothing.",
	1,
	100,
	18,
	function(value)
		AimAssistSmoothing = value / 100
	end
)

CreateSlider(
	CombatPage,
	"Range",
	"Maximum target distance.",
	1,
	500,
	100,
	function(value)
		Player:SetAttribute("FlarehookRange", value)
	end
)

CreateSection(
	CombatPage,
	"Shooting",
	"Tool-based firing controls."
)

CreateToggle(
	CombatPage,
	"Triggerbot",
	"Fire the equipped Tool when the crosshair is over a target.",
	false,
	function(state)
		TriggerbotEnabled = state
		RegisterFeature("Triggerbot", state)
	end
)

CreateToggle(
	CombatPage,
	"Auto Shoot",
	"Fire the equipped Tool while a target is selected.",
	false,
	function(state)
		AutoShootEnabled = state
		RegisterFeature("Auto Shoot", state)
	end
)

CreateToggle(
	CombatPage,
	"Recoil Control",
	"Apply local camera compensation after firing.",
	false,
	function(state)
		RecoilControlEnabled = state
		RegisterFeature("Recoil Control", state)
	end
)

CreateSlider(
	CombatPage,
	"Recoil Strength",
	"Local camera recoil compensation amount.",
	0,
	100,
	0,
	function(value)
		RecoilStrength = value
	end
)

CreateSection(
	CombatPage,
	"Hitbox",
	"Local hitbox visualization/expansion for testing your own game."
)

CreateToggle(
	CombatPage,
	"Hitbox Expansion",
	"Expand target head hitboxes locally for testing.",
	false,
	function(state)
		HitboxEnabled = state
		RegisterFeature("Hitbox Expansion", state)
		ApplyHitboxes()
	end
)

CreateSlider(
	CombatPage,
	"Hitbox Size",
	"Size used by local test hitboxes.",
	2,
	20,
	8,
	function(value)
		HitboxSize = value
		if HitboxEnabled then
			ApplyHitboxes()
		end
	end
)

CreateButton(
	CombatPage,
	"Reset Combat",
	"Reset combat values.",
	function()
		AimFOV = 120
		AimSmoothing = 0.35
		AimAssistSmoothing = 0.18
		PredictionAmount = 0
		HitboxSize = 8
		RecoilStrength = 0
		TargetPriority = "Closest to Crosshair"
		TargetPartName = "Head"
		ClearTargetLock()

		Player:SetAttribute("FlarehookRange", 100)
		Player:SetAttribute("FlarehookSmoothness", 0.35)
		Player:SetAttribute("FlarehookTargetPriority", TargetPriority)
		Player:SetAttribute("FlarehookPrediction", PredictionAmount)

		Notify("Combat", "Combat values reset.", 2)
	end,
	"RESET"
)

--==================================================
-- MISC
--==================================================

CreateSection(
MiscPage,
"Miscellaneous",
"General utility options."
)

CreateToggle(
MiscPage,
"Auto Notifications",
"Allow automatic interface messages.",
true,
function(state)
NotificationsEnabled = state
end
)

CreateButton(
MiscPage,
"Refresh Interface",
"Refresh accent and interface elements.",
function()
RefreshAccents()

Notify(
"Flarehook",
"Interface refreshed.",
2
)
end,
"REFRESH"
)

CreateButton(
MiscPage,
"Recenter Window",
"Move the interface back to the center.",
function()
Main.Position = UDim2.fromScale(0.5, 0.5)

Notify(
"Flarehook",
"Window recentered.",
2
)
end,
"RECENTER"
)

CreateButton(
MiscPage,
"Test Notification",
"Test the notification system.",
function()
Notify(
"Flarehook",
"Notification system is working.",
3
)
end,
"TEST"
)

--==================================================
-- SETTINGS
--==================================================

CreateSection(
SettingsPage,
"Interface",
"UI, display and configuration settings."
)

local BlurToggle = CreateToggle(
SettingsPage,
"Background Blur",
"Toggle the background blur effect.",
false,
function(state)
local Blur = Lighting:FindFirstChild("FlarehookBlur")

if state then
if not Blur then
Blur = Instance.new("BlurEffect")
Blur.Name = "FlarehookBlur"
Blur.Size = 10
Blur.Parent = Lighting
end
else
if Blur then
Blur:Destroy()
end
end
end
)

local TransparencySlider = CreateSlider(
SettingsPage,
"UI Transparency",
"Adjust the main window transparency.",
0,
50,
0,
function(value)
Main.BackgroundTransparency = value / 100
end
)

CreateToggle(
SettingsPage,
"UI Animations",
"Toggle interface animation state.",
true,
function(state)
Player:SetAttribute("FlarehookAnimations", state)
end
)

CreateSection(
SettingsPage,
"Keybinds",
"Keyboard controls for the interface."
)

CreateTextbox(
SettingsPage,
"Toggle Key",
"Key used to open and close the interface.",
"Insert key...",
function(text)
	local key = Enum.KeyCode[string.upper(string.gsub(text, "%s+", ""))]
	if key then
		ToggleKey = key
		Player:SetAttribute("FlarehookToggleKey", key.Name)
		Notify("Settings", "Toggle key set to " .. key.Name .. ".", 2)
	else
		Notify("Settings", "Invalid toggle key.", 2)
	end
end
)

CreateTextbox(
SettingsPage,
"Panic Key",
"Key used for panic mode.",
"Insert key...",
function(text)
	local key = Enum.KeyCode[string.upper(string.gsub(text, "%s+", ""))]
	if key then
		PanicKey = key
		Player:SetAttribute("FlarehookPanicKey", key.Name)
		Notify("Settings", "Panic key set to " .. key.Name .. ".", 2)
	else
		Notify("Settings", "Invalid panic key.", 2)
	end
end
)

CreateSection(
SettingsPage,
"Configuration",
"Save, load and manage your Flarehook settings."
)

local ConfigNameBox = CreateTextbox(
SettingsPage,
"Config Name",
"Name used for saving and loading a configuration.",
"default",
function(text)
text = tostring(text or "")
text = string.gsub(text, "[^%w_%-%s]", "")
text = string.gsub(text, "^%s+", "")
text = string.gsub(text, "%s+$", "")
if text ~= "" then
ConfigName = text
end
end
)

local AutoloadToggle = CreateToggle(
SettingsPage,
"Autoload Config",
"Automatically load the selected config when the script starts.",
false,
function(state)
ConfigAutoload = state
if type(isfile) == "function" and type(writefile) == "function" and type(makefolder) == "function" then
pcall(makefolder, "Flarehook")
if state then
pcall(writefile, "Flarehook/autoload.txt", ConfigName)
elseif isfile("Flarehook/autoload.txt") and type(delfile) == "function" then
pcall(delfile, "Flarehook/autoload.txt")
end
end
end
)

local function ConfigCanUseFiles()
return type(isfile) == "function"
and type(readfile) == "function"
and type(writefile) == "function"
and type(delfile) == "function"
and type(makefolder) == "function"
end

local function ConfigFile(name)
return "Flarehook/" .. tostring(name) .. ".json"
end

local function BuildConfig()
local Data = {
ConfigName = ConfigName,
Toggles = {},
Sliders = {},
Dropdowns = {}
}

for Name, Control in pairs(ConfigControls) do
local ok, value = pcall(Control.Get)
if ok then
if Control.Type == "Toggle" then
Data.Toggles[Name] = value == true
elseif Control.Type == "Slider" then
Data.Sliders[Name] = tonumber(value) or 0
elseif Control.Type == "Dropdown" then
Data.Dropdowns[Name] = tostring(value)
end
end
end

Data.Keybinds = {
ToggleKey = ToggleKey.Name,
PanicKey = PanicKey.Name
}

return Data
end

local function ApplyConfig(Data)
if type(Data) ~= "table" then
return false
end

for Name, Value in pairs(Data.Toggles or {}) do
local Control = ConfigControls[Name]
if Control and Control.Type == "Toggle" and type(Value) == "boolean" then
Control.Set(Value)
end
end

for Name, Value in pairs(Data.Sliders or {}) do
local Control = ConfigControls[Name]
if Control and Control.Type == "Slider" and type(Value) == "number" then
Control.Set(Value)
end
end

for Name, Value in pairs(Data.Dropdowns or {}) do
local Control = ConfigControls[Name]
if Control and Control.Type == "Dropdown" and type(Value) == "string" then
Control.Set(Value)
end
end

if type(Data.Keybinds) == "table" then
local Toggle = Data.Keybinds.ToggleKey
local Panic = Data.Keybinds.PanicKey
if type(Toggle) == "string" and Enum.KeyCode[Toggle] then
ToggleKey = Enum.KeyCode[Toggle]
Player:SetAttribute("FlarehookToggleKey", Toggle)
end
if type(Panic) == "string" and Enum.KeyCode[Panic] then
PanicKey = Enum.KeyCode[Panic]
Player:SetAttribute("FlarehookPanicKey", Panic)
end
end

if type(Data.ConfigName) == "string" and Data.ConfigName ~= "" then
ConfigName = Data.ConfigName
ConfigNameBox.Text = ConfigName
end

return true
end

local function SaveConfig(name, overwrite)
if not ConfigCanUseFiles() then
Notify("Config", "File APIs are unavailable in this environment.", 3)
return false
end

name = tostring(name or ConfigName)
name = string.gsub(name, "[^%w_%-%s]", "")
name = string.gsub(name, "^%s+", "")
name = string.gsub(name, "%s+$", "")

if name == "" then
Notify("Config", "Enter a config name first.", 2)
return false
end

pcall(makefolder, "Flarehook")
local Path = ConfigFile(name)

if isfile(Path) and not overwrite then
Notify("Config", "Config already exists. Use Overwrite.", 3)
return false
end

ConfigName = name
ConfigNameBox.Text = name

local ok, Json = pcall(function()
return HttpService:JSONEncode(BuildConfig())
end)
if not ok then
Notify("Config", "Failed to encode config JSON.", 3)
return false
end

local success = pcall(writefile, Path, Json)
if not success then
Notify("Config", "Failed to write config.", 3)
return false
end

Notify("Config", (overwrite and "Overwrote " or "Created ") .. name .. ".", 2)
return true
end

local function LoadConfig(name, silent)
if not ConfigCanUseFiles() then
if not silent then Notify("Config", "File APIs are unavailable in this environment.", 3) end
return false
end

name = tostring(name or ConfigName)
local Path = ConfigFile(name)
if not isfile(Path) then
if not silent then Notify("Config", "Config not found: " .. name, 3) end
return false
end

local okRead, Raw = pcall(readfile, Path)
if not okRead then
if not silent then Notify("Config", "Failed to read config.", 3) end
return false
end

local okDecode, Data = pcall(function()
return HttpService:JSONDecode(Raw)
end)
if not okDecode then
if not silent then Notify("Config", "Invalid JSON in config.", 3) end
return false
end

if not ApplyConfig(Data) then
if not silent then Notify("Config", "Failed to apply config.", 3) end
return false
end

ConfigName = name
ConfigNameBox.Text = name

if not silent then Notify("Config", "Loaded " .. name .. ".", 2) end
return true
end

CreateButton(
SettingsPage,
"Create Config",
"Create a new JSON config without overwriting an existing file.",
function()
SaveConfig(ConfigName, false)
end,
"CREATE"
)

CreateButton(
SettingsPage,
"Overwrite Config",
"Overwrite the selected config with the current UI values.",
function()
SaveConfig(ConfigName, true)
end,
"OVERWRITE"
)

CreateButton(
SettingsPage,
"Load Config",
"Load the selected JSON config and apply its saved values.",
function()
LoadConfig(ConfigName, false)
end,
"LOAD"
)

CreateButton(
SettingsPage,
"Delete Config",
"Delete the selected config file.",
function()
if not ConfigCanUseFiles() then
Notify("Config", "File APIs are unavailable in this environment.", 3)
return
end
local Path = ConfigFile(ConfigName)
if isfile(Path) then
local ok = pcall(delfile, Path)
Notify("Config", ok and ("Deleted " .. ConfigName .. ".") or "Failed to delete config.", 2)
else
Notify("Config", "Config not found: " .. ConfigName, 2)
end
end,
"DELETE"
)

CreateButton(
SettingsPage,
"Set As Autoload",
"Save the selected config name as the startup config and enable autoload.",
function()
if not ConfigCanUseFiles() then
Notify("Config", "File APIs are unavailable in this environment.", 3)
return
end
pcall(makefolder, "Flarehook")
if not isfile(ConfigFile(ConfigName)) then
Notify("Config", "Create or save this config before setting autoload.", 3)
return
end
pcall(writefile, "Flarehook/autoload.txt", ConfigName)
ConfigAutoload = true
AutoloadToggle.Set(true)
Notify("Config", ConfigName .. " set as autoload.", 2)
end,
"SET"
)

CreateButton(
SettingsPage,
"Print Config JSON",
"Encode the current settings with HttpService and print the JSON string.",
function()
local ok, Json = pcall(function()
return HttpService:JSONEncode(BuildConfig())
end)
if ok then
print(Json)
Notify("Config", "Current JSON printed to the console.", 2)
else
Notify("Config", "Failed to encode JSON.", 2)
end
end,
"PRINT"
)

CreateSection(
SettingsPage,
"Reset UI",
"Restore the default interface settings."
)

CreateButton(
SettingsPage,
"Reset UI",
"Restore the default interface settings.",
function()
Main.BackgroundTransparency = 0
TransparencySlider.Set(0)
BlurToggle.Set(false)
Main.Position = UDim2.fromScale(0.5, 0.5)
Notify("Flarehook", "Interface reset.", 2)
end,
"RESET"
)

--==================================================
-- CREDITS
--==================================================

CreateSection(
CreditsPage,
"Flarehook",
"Script and interface information."
)

CreateTextbox(
CreditsPage,
"Author",
"Interface author information.",
"Author...",
function(text)
Player:SetAttribute("FlarehookAuthor", text)
end
)

CreateSection(
CreditsPage,
"Version",
"Current interface version."
)

CreateButton(
CreditsPage,
"Version",
"Flarehook interface release.",
function()
Notify(
"Flarehook",
"Version 2.0 | Advanced interface",
3
)
end,
"INFO"
)

CreateButton(
CreditsPage,
"Credits",
"View the current script credits.",
function()
Notify(
"Credits",
"Flarehook UI | Red/Black interface | v2.0",
4
)
end,
"VIEW"
)

--==================================================
-- SEARCH
--==================================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
local Search = string.lower(SearchBox.Text)

for Name, Data in pairs(Tabs) do
local Visible = Search == ""
or string.find(
string.lower(Name),
Search,
1,
true
) ~= nil

Data.Button.Visible = Visible
end
end)

--==================================================
-- MINIMIZE
--==================================================

MinimizeButton.MouseButton1Click:Connect(function()
ClickSound()
SessionClicks += 1

Minimized = not Minimized

if Minimized then
Main.Size = UDim2.fromOffset(780, 58)
MinimizeButton.Text = "+"

Sidebar.Visible = false
Content.Visible = false
else
Main.Size = MAIN_SIZE
MinimizeButton.Text = "-"

Sidebar.Visible = true
Content.Visible = true
end
end)

--==================================================
-- OPEN / CLOSE
--==================================================

ToggleButton.MouseEnter:Connect(function()
Tween(ToggleButton, 0.12, {
BackgroundColor3 = COLORS.NeutralHover
})
end)

ToggleButton.MouseLeave:Connect(function()
Tween(ToggleButton, 0.12, {
BackgroundColor3 = COLORS.NeutralButton
})
end)

ToggleButton.MouseButton1Click:Connect(function()
ClickSound()
SessionClicks += 1

UIOpen = not UIOpen

if UIOpen then
Main.Visible = true
ToggleButton.Text = "Close"
else
CloseDropdown()

Main.Visible = false
ToggleButton.Text = "Open"
end
end)

--==================================================
-- KEYBINDS
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then
return
end

if input.KeyCode == ToggleKey then
UIOpen = not UIOpen

if UIOpen then
Main.Visible = true
ToggleButton.Text = "Close"
else
CloseDropdown()

Main.Visible = false
ToggleButton.Text = "Open"
end
end

if input.KeyCode == PanicKey then
	PanicEnabled = not PanicEnabled
	RegisterFeature("Panic", PanicEnabled)

	if PanicEnabled then
		ClearAllRuntimeFeatures()
		UpdateStatus()

		if NotificationsEnabled then
			Notify("Flarehook", "Panic mode enabled.", 2)
		end
	else
		if NotificationsEnabled then
			Notify("Flarehook", "Panic mode disabled.", 2)
		end
	end
end
end)

--==================================================
-- CHARACTER RESPAWN HANDLING
--==================================================

Player.CharacterAdded:Connect(function(Character)
task.wait(0.25)

if not CharacterVisible then
SetCharacterTransparency(1)
end

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

if Humanoid and MovementEnabled then
Humanoid.WalkSpeed = WalkSpeedSlider.Get()
Humanoid.UseJumpPower = true
Humanoid.JumpPower = JumpPowerSlider.Get()
end

if ThirdPersonEnabled then
Player.CameraMinZoomDistance = 5
Player.CameraMaxZoomDistance = 12
end

task.wait(0.15)
RefreshESP()
if HitboxEnabled then
	ApplyHitboxes()
end
end)


--==================================================
-- FEATURE RUNTIME
--==================================================

RunService.RenderStepped:Connect(function()
	if not MainScriptEnabled or PanicEnabled then
		return
	end

	-- Keep the FOV circle synced with the configured value.
	local fovCircle = ScreenGui:FindFirstChild("FlarehookFOVCircle")
	if fovCircle then
		fovCircle.Size = UDim2.fromOffset(AimFOV * 2, AimFOV * 2)
	end

	-- Update ESP.
	for player, data in pairs(ESPObjects) do
		if not IsAlive(player) then
			ClearESP(player)
		elseif data then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if root and humanoid then
				local distance = (root.Position - Camera.CFrame.Position).Magnitude
				local healthPercent = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)

				data.Name.Visible = NameTagsEnabled or ESPEnabled
				data.HealthBack.Visible = HealthBarsEnabled or ESPEnabled
				data.Distance.Visible = DistanceEnabled or ESPEnabled
				data.Tracer.Visible = TracersEnabled

				data.Name.TextColor3 = TeamColorsEnabled and player.TeamColor.Color or ESPColor
				data.Health.BackgroundColor3 = TeamColorsEnabled and player.TeamColor.Color or ESPColor
				data.Health.Size = UDim2.fromScale(healthPercent, 1)
				data.Distance.Text = math.floor(distance) .. " studs"

				local screenPoint, onScreen = Camera:WorldToViewportPoint(root.Position)
				if onScreen and TracersEnabled then
					local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
					local endpoint = Vector2.new(screenPoint.X, screenPoint.Y)
					local delta = endpoint - center

					data.Tracer.Position = UDim2.fromOffset(center.X, center.Y)
					data.Tracer.Size = UDim2.fromOffset(2, math.max(delta.Magnitude, 1))
					data.Tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X)) + 90
					data.Tracer.BackgroundColor3 = TeamColorsEnabled and player.TeamColor.Color or ESPColor
				end
			end
		end
	end

	-- Apply local test hitboxes.
	if HitboxEnabled then
		ApplyHitboxes()
	end

	-- Targeting.
	if AimAssistEnabled or AimbotEnabled or TriggerbotEnabled or AutoShootEnabled then
		local target, part = GetTarget()

		if target and part then
			if AimbotEnabled then
				AimAt(part, AimSmoothing)
			elseif AimAssistEnabled then
				AimAt(part, AimAssistSmoothing)
			end

			if TriggerbotEnabled then
				local screenDistance = GetScreenDistance(part.Position)
				if screenDistance <= math.max(6, CrosshairSize + 4) then
					FireCurrentTool()
				end
			end

			if AutoShootEnabled then
				FireCurrentTool()
			end
		else
			if not TargetLockEnabled then
				ClearTargetLock()
			end
		end
	end

	-- Lightweight local recoil compensation hook.
	if RecoilControlEnabled and RecoilStrength > 0 then
		local recoil = math.rad(RecoilStrength / 1000)
		Camera.CFrame = Camera.CFrame * CFrame.Angles(-recoil, 0, 0)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ClearESP(player)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.25)
		RefreshESP()
		if HitboxEnabled then
			ApplyHitboxes()
		end
	end)
end)

--==================================================
-- FPS
--==================================================

local FPSAccumulator = 0
local FPSFrames = 0

RunService.RenderStepped:Connect(function(DeltaTime)
FPSAccumulator += DeltaTime
FPSFrames += 1

if FPSAccumulator >= 1 then
FPS = FPSFrames / FPSAccumulator

FPSAccumulator = 0
FPSFrames = 0

local FPSLabel = ScreenGui:FindFirstChild("FPSDisplay")

if FPSLabel then
FPSLabel.Text = "FPS: " .. tostring(math.floor(FPS))
end
end
end)

--==================================================
-- DROPDOWN POSITION UPDATES
--==================================================

RunService.RenderStepped:Connect(function()
for _, UpdatePosition in ipairs(DropdownUpdaters) do
pcall(UpdatePosition)
end
end)

--==================================================
-- INITIAL TAB
--==================================================

CurrentTab = "Main"

for Name, Data in pairs(Tabs) do
local Active = Name == "Main"

Data.Indicator.Visible = Active

if Active then
Data.Button.BackgroundColor3 = Color3.fromRGB(29, 20, 23)
Data.Label.TextColor3 = COLORS.White
Data.Label.Font = Enum.Font.GothamBold
else
Data.Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Data.Label.TextColor3 = COLORS.Muted
end
end

for Name, Page in pairs(Pages) do
Page.Visible = Name == "Main"
end

--==================================================
-- DEFAULT VALUES
--==================================================

RegisterFeature("Script", true)
RegisterFeature("Panic", false)

Player:SetAttribute("FlarehookRange", 100)
Player:SetAttribute("FlarehookSmoothness", 0.35)
Player:SetAttribute("FlarehookTargetPriority", "Closest to Crosshair")
Player:SetAttribute("FlarehookPrediction", 0)
Player:SetAttribute("FlarehookCameraSensitivity", 1)
Player:SetAttribute("FlarehookToggleKey", ToggleKey.Name)
Player:SetAttribute("FlarehookPanicKey", PanicKey.Name)

if Camera then
Camera.FieldOfView = 70
end

--==================================================
-- AUTOLOAD CONFIG
--==================================================

if ConfigCanUseFiles() and isfile("Flarehook/autoload.txt") then
local ok, SavedName = pcall(readfile, "Flarehook/autoload.txt")
if ok and type(SavedName) == "string" and SavedName ~= "" then
SavedName = string.gsub(SavedName, "[^%w_%-%s]", "")
ConfigName = SavedName
ConfigNameBox.Text = ConfigName
ConfigAutoload = true
AutoloadToggle.Set(true)
task.defer(function()
LoadConfig(ConfigName, true)
end)
end
end

--==================================================
-- REFRESH ACCENTS
--==================================================

RefreshAccents()

--==================================================
-- INTRO
--==================================================

Main.Size = UDim2.fromOffset(740, 450)

task.wait()

Tween(
Main,
0.35,
{
Size = MAIN_SIZE
},
Enum.EasingStyle.Quint
)

task.delay(0.4, function()
Notify(
"Flarehook",
"Interface loaded successfully.",
3
)
end)
