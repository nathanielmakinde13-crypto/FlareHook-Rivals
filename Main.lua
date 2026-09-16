--// FLAREHOOK
--// Full LocalScript
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

local FPS = 0
local SessionStart = os.clock()
local SessionClicks = 0

local CharacterVisible = true
local MovementEnabled = true
local ThirdPersonEnabled = false
local NotificationsEnabled = true
local PanicEnabled = false

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

local HeaderLogo = Create("ImageLabel", {
Name = "HeaderLogo",
BackgroundTransparency = 1,
Image = LOGO_ID,
Position = UDim2.fromOffset(16, 10),
Size = UDim2.fromOffset(38, 38),
ScaleType = Enum.ScaleType.Fit,
ZIndex = 20
}, Header)

Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.fromOffset(62, 7),
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
Position = UDim2.fromOffset(63, 31),
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

return {
Set = function(value)
Update(value, true)
end,

Get = function()
return Enabled
end
}
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

return {
Set = function(value)
SetValue(value, true)
end,

Get = function()
return Value
end
}
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

return {
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

local function CreateTab(name, icon, order)
local Button = Create("TextButton", {
Name = name,
BackgroundColor3 = Color3.fromRGB(15, 15, 18),
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 37),
AutoButtonColor = false,
Text = "",
LayoutOrder = order,
ZIndex = 9
}, TabHolder)

AddCorner(Button, CORNER_RADIUS)

local Icon = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(9, 0),
Size = UDim2.fromOffset(24, 37),
Font = Enum.Font.GothamBold,
Text = icon,
TextColor3 = COLORS.Muted,
TextSize = 13,
ZIndex = 11
}, Button)

local Label = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.fromOffset(39, 0),
Size = UDim2.new(1, -44, 1, 0),
Font = Enum.Font.Fantasy,
Text = name,
TextColor3 = COLORS.Muted,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 11
}, Button)

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
Icon = Icon,
Label = Label,
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
Data.Icon.TextColor3 = COLORS.White
Data.Label.TextColor3 = COLORS.White
Data.Label.Font = Enum.Font.GothamBold
else
Data.Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Data.Icon.TextColor3 = COLORS.Muted
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
RegisterFeature("Script", state)

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
-- VISUALS
--==================================================

CreateSection(
VisualsPage,
"Player Visuals",
"Player highlight and information effects."
)

CreateToggle(
VisualsPage,
"Player Highlights",
"Highlight other players.",
false,
function(state)
RegisterFeature("Player Highlights", state)

for _, OtherPlayer in ipairs(Players:GetPlayers()) do
if OtherPlayer ~= Player then
local Character = OtherPlayer.Character

if Character then
local Highlight = Character:FindFirstChild("FlarehookHighlight")

if state then
if not Highlight then
Highlight = Instance.new("Highlight")
Highlight.Name = "FlarehookHighlight"
Highlight.FillColor = COLORS.Red
Highlight.OutlineColor = COLORS.White
Highlight.FillTransparency = 0.65
Highlight.OutlineTransparency = 0.2
Highlight.Parent = Character
end
elseif Highlight then
Highlight:Destroy()
end
end
end
end
end
)

CreateToggle(
VisualsPage,
"ESP",
"Enable player ESP state.",
false,
function(state)
RegisterFeature("ESP", state)
end
)

CreateToggle(
VisualsPage,
"Name Tags",
"Show player name-tag state.",
false,
function(state)
RegisterFeature("Name Tags", state)
end
)

CreateToggle(
VisualsPage,
"Health Bars",
"Show player health-bar state.",
false,
function(state)
RegisterFeature("Health Bars", state)
end
)

CreateToggle(
VisualsPage,
"Distance Indicators",
"Show player distance information.",
false,
function(state)
RegisterFeature("Distance", state)
end
)

CreateToggle(
VisualsPage,
"Tracers",
"Enable player tracer state.",
false,
function(state)
RegisterFeature("Tracers", state)
end
)

CreateToggle(
VisualsPage,
"Team-Color Indicators",
"Use player team colors for indicators.",
false,
function(state)
RegisterFeature("Team Colors", state)
end
)

CreateSection(
VisualsPage,
"Screen Effects",
"Local interface and visual effects."
)

CreateToggle(
VisualsPage,
"Crosshair",
"Show the custom crosshair.",
false,
function(state)
RegisterFeature("Crosshair", state)

local Crosshair = ScreenGui:FindFirstChild("FlarehookCrosshair")

if state and not Crosshair then
Crosshair = Create("Frame", {
Name = "FlarehookCrosshair",
BackgroundColor3 = COLORS.Red,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(4, 4),
ZIndex = 800
}, ScreenGui)

AddCorner(Crosshair, 2)
end

if Crosshair then
Crosshair.Visible = state
end
end
)

CreateToggle(
VisualsPage,
"Hit-Effect Visuals",
"Enable local hit-effect visual state.",
false,
function(state)
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
"Combat",
"Combat-related interface options."
)

CreateToggle(
CombatPage,
"Aim Assist",
"Toggle the aim-assist feature state.",
false,
function(state)
RegisterFeature("Aim Assist", state)
end
)

CreateToggle(
CombatPage,
"Hitbox",
"Toggle the hitbox feature state.",
false,
function(state)
RegisterFeature("Hitbox", state)
end
)

CreateSlider(
CombatPage,
"Range",
"Adjust the combat range value.",
1,
100,
50,
function(value)
Player:SetAttribute("FlarehookRange", value)
end
)

CreateSlider(
CombatPage,
"Smoothness",
"Adjust targeting smoothness.",
1,
20,
8,
function(value)
Player:SetAttribute("FlarehookSmoothness", value)
end
)

CreateDropdown(
CombatPage,
"Target",
"Choose the target mode.",
{
"Closest",
"Lowest Health",
"Random",
"Crosshair"
},
"Closest",
function(option)
Player:SetAttribute("FlarehookTargetMode", option)
end
)

CreateButton(
CombatPage,
"Reset Combat",
"Reset combat values.",
function()
Player:SetAttribute("FlarehookRange", 50)
Player:SetAttribute("FlarehookSmoothness", 8)
Player:SetAttribute("FlarehookTargetMode", "Closest")

Notify(
"Combat",
"Combat values reset.",
2
)
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
        elseif Blur then
            Blur:Destroy()
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
    function(value)
        Player:SetAttribute("FlarehookToggleKey", value)
    end
)

CreateTextbox(
    SettingsPage,
    "Panic Key",
    "Key used for panic mode.",
    "Insert key...",
    function(value)
        Player:SetAttribute("FlarehookPanicKey", value)
    end
)

CreateSection(
    SettingsPage,
    "Configuration",
    "Save every supported toggle, slider, dropdown and color setting as JSON."
)

local ConfigFolder = "FLAREHOOK"
local ConfigName = "default"
local AutoLoadConfig = false
local ConfigNameBox

local function ConfigPath(name)
    name = tostring(name or ""):gsub("[^%w_%-%s]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        name = "default"
    end
    return ConfigFolder .. "/" .. name .. ".json"
end

local function HasFileApi()
    return isfile and readfile and writefile and delfile
end

local function EnsureConfigFolder()
    if makefolder and isfolder and not isfolder(ConfigFolder) then
        pcall(makefolder, ConfigFolder)
    end
end

local function BuildConfig()
    return {
        -- Interface toggles
        NotificationsEnabled = NotificationsEnabled,
        PanicEnabled = PanicEnabled,
        MovementEnabled = MovementEnabled,
        CharacterVisible = CharacterVisible,
        ThirdPersonEnabled = ThirdPersonEnabled,

        -- Visual toggles
        ESPEnabled = ESPEnabled,
        HighlightsEnabled = HighlightsEnabled,
        NameTagsEnabled = NameTagsEnabled,
        HealthBarsEnabled = HealthBarsEnabled,
        DistanceEnabled = DistanceEnabled,
        TracersEnabled = TracersEnabled,
        TeamColorsEnabled = TeamColorsEnabled,
        CrosshairEnabled = CrosshairEnabled,
        HitEffectsEnabled = HitEffectsEnabled,

        -- Visual sliders / numbers
        CrosshairSize = CrosshairSize,
        CrosshairGap = CrosshairGap,
        CrosshairThickness = CrosshairThickness,

        -- Combat toggles
        AimAssistEnabled = AimAssistEnabled,
        AimbotEnabled = AimbotEnabled,
        TargetLockEnabled = TargetLockEnabled,
        TeamCheckEnabled = TeamCheckEnabled,
        VisibilityCheckEnabled = VisibilityCheckEnabled,
        FOVCircleEnabled = FOVCircleEnabled,
        TriggerbotEnabled = TriggerbotEnabled,
        AutoShootEnabled = AutoShootEnabled,
        RecoilControlEnabled = RecoilControlEnabled,
        HitboxEnabled = HitboxEnabled,

        -- Combat sliders / numbers
        FOVRadius = FOVRadius,
        Prediction = Prediction,
        Smoothing = Smoothing,
        AimAssistSpeed = AimAssistSpeed,
        Range = Range,
        RecoilStrength = RecoilStrength,
        HitboxSize = HitboxSize,

        -- Combat dropdowns
        TargetPriority = TargetPriority,
        TargetPart = TargetPart,

        -- World numbers
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,

        -- UI settings
        BackgroundBlur = BlurToggle and false or false,
        UITransparency = TransparencySlider and 0 or 0,

        -- Colors stored as JSON-friendly numbers
        CrosshairColor = {
            R = CrosshairColor and CrosshairColor.R or 1,
            G = CrosshairColor and CrosshairColor.G or 1,
            B = CrosshairColor and CrosshairColor.B or 1
        }
    }
end

local function ApplyConfig(config)
    if type(config) ~= "table" then
        return false
    end

    local booleanKeys = {
        "NotificationsEnabled", "PanicEnabled", "MovementEnabled",
        "CharacterVisible", "ThirdPersonEnabled",
        "ESPEnabled", "HighlightsEnabled", "NameTagsEnabled",
        "HealthBarsEnabled", "DistanceEnabled", "TracersEnabled",
        "TeamColorsEnabled", "CrosshairEnabled", "HitEffectsEnabled",
        "AimAssistEnabled", "AimbotEnabled", "TargetLockEnabled",
        "TeamCheckEnabled", "VisibilityCheckEnabled", "FOVCircleEnabled",
        "TriggerbotEnabled", "AutoShootEnabled", "RecoilControlEnabled",
        "HitboxEnabled", "GlobalShadows"
    }

    local numberKeys = {
        "CrosshairSize", "CrosshairGap", "CrosshairThickness",
        "FOVRadius", "Prediction", "Smoothing", "AimAssistSpeed",
        "Range", "RecoilStrength", "HitboxSize",
        "Brightness", "ClockTime"
    }

    for _, key in ipairs(booleanKeys) do
        if type(config[key]) == "boolean" then
            if key == "GlobalShadows" then
                Lighting.GlobalShadows = config[key]
            else
                _ENV[key] = config[key]
            end
        end
    end

    for _, key in ipairs(numberKeys) do
        if type(config[key]) == "number" then
            _ENV[key] = config[key]
        end
    end

    if type(config.TargetPriority) == "string" then
        TargetPriority = config.TargetPriority
    end
    if type(config.TargetPart) == "string" then
        TargetPart = config.TargetPart
    end

    if type(config.CrosshairColor) == "table" then
        CrosshairColor = Color3.new(
            math.clamp(tonumber(config.CrosshairColor.R) or 1, 0, 1),
            math.clamp(tonumber(config.CrosshairColor.G) or 1, 0, 1),
            math.clamp(tonumber(config.CrosshairColor.B) or 1, 0, 1)
        )
    end

    if type(config.Brightness) == "number" then
        Lighting.Brightness = config.Brightness
    end
    if type(config.ClockTime) == "number" then
        Lighting.ClockTime = config.ClockTime
    end

    RefreshESP()
    ApplyHitboxes()
    return true
end

local function EncodeConfig()
    return HttpService:JSONEncode(BuildConfig())
end

local function CreateConfig(name)
    if not HasFileApi() then
        Notify("Flarehook", "File APIs are unavailable.", 3)
        return
    end

    EnsureConfigFolder()
    local path = ConfigPath(name)

    if isfile(path) then
        Notify("Flarehook", "Config already exists. Use Overwrite Config.", 3)
        return
    end

    writefile(path, EncodeConfig())
    Notify("Flarehook", "Created config: " .. tostring(name), 3)
end

local function OverwriteConfig(name)
    if not HasFileApi() then
        Notify("Flarehook", "File APIs are unavailable.", 3)
        return
    end

    EnsureConfigFolder()
    writefile(ConfigPath(name), EncodeConfig())
    Notify("Flarehook", "Overwrote config: " .. tostring(name), 3)
end

local function DeleteConfig(name)
    if not HasFileApi() then
        Notify("Flarehook", "File APIs are unavailable.", 3)
        return
    end

    local path = ConfigPath(name)
    if not isfile(path) then
        Notify("Flarehook", "Config does not exist.", 3)
        return
    end

    delfile(path)
    Notify("Flarehook", "Deleted config: " .. tostring(name), 3)
end

local function LoadConfig(name)
    if not HasFileApi() then
        Notify("Flarehook", "File APIs are unavailable.", 3)
        return
    end

    local path = ConfigPath(name)
    if not isfile(path) then
        Notify("Flarehook", "Config does not exist.", 3)
        return
    end

    local ok, config = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if not ok then
        Notify("Flarehook", "Invalid JSON in config.", 3)
        return
    end

    if ApplyConfig(config) then
        Notify("Flarehook", "Loaded config: " .. tostring(name), 3)
    else
        Notify("Flarehook", "Could not apply config.", 3)
    end
end

local function SetAutoload(name)
    if not HasFileApi() then
        Notify("Flarehook", "File APIs are unavailable.", 3)
        return
    end

    EnsureConfigFolder()
    writefile(ConfigFolder .. "/autoload.txt", tostring(name))
    AutoLoadConfig = true
    Notify("Flarehook", "Autoload set to: " .. tostring(name), 3)
end

local function GetAutoload()
    if not HasFileApi() or not isfile(ConfigFolder .. "/autoload.txt") then
        return nil
    end

    local ok, value = pcall(readfile, ConfigFolder .. "/autoload.txt")
    if ok and value and value ~= "" then
        return value
    end
end

ConfigNameBox = CreateTextbox(
    SettingsPage,
    "Config Name",
    "Name used for the JSON config file.",
    "Config name...",
    function(value)
        value = tostring(value or ""):gsub("[^%w_%-%s]", "")
        value = value:gsub("^%s+", ""):gsub("%s+$", "")
        ConfigName = value ~= "" and value or "default"
    end
)

CreateButton(
    SettingsPage,
    "Create Config",
    "Create a new JSON config without overwriting an existing one.",
    function()
        CreateConfig(ConfigName)
    end,
    "CREATE"
)

CreateButton(
    SettingsPage,
    "Overwrite Config",
    "Overwrite the selected config with the current settings.",
    function()
        OverwriteConfig(ConfigName)
    end,
    "SAVE"
)

CreateButton(
    SettingsPage,
    "Load Config",
    "Load the selected JSON config.",
    function()
        LoadConfig(ConfigName)
    end,
    "LOAD"
)

CreateButton(
    SettingsPage,
    "Delete Config",
    "Delete the selected JSON config.",
    function()
        DeleteConfig(ConfigName)
    end,
    "DELETE"
)

CreateToggle(
    SettingsPage,
    "Autoload Config",
    "Automatically load the saved autoload config when the script starts.",
    false,
    function(state)
        AutoLoadConfig = state
    end
)

CreateButton(
    SettingsPage,
    "Set As Autoload",
    "Set the current config name as the startup config.",
    function()
        SetAutoload(ConfigName)
    end,
    "AUTO"
)

CreateButton(
    SettingsPage,
    "Print Config JSON",
    "Encode the current settings using HttpService:JSONEncode and print the JSON.",
    function()
        print(EncodeConfig())
        Notify("Flarehook", "Config JSON printed to console.", 3)
    end,
    "JSON"
)

CreateSection(
    SettingsPage,
    "Theme",
    "Choose an accent color."
)

CreateButton(SettingsPage, "Red", "Set the red accent.", function()
    COLORS.Red = Color3.fromRGB(220, 35, 45)
end, "RED")

CreateButton(SettingsPage, "Crimson", "Set the crimson accent.", function()
    COLORS.Red = Color3.fromRGB(180, 0, 0)
end, "RED")

CreateButton(SettingsPage, "White", "Set the white accent.", function()
    COLORS.Red = Color3.fromRGB(255, 255, 255)
end, "WHITE")

CreateButton(SettingsPage, "Cyan", "Set the cyan accent.", function()
    COLORS.Red = Color3.fromRGB(0, 255, 255)
end, "CYAN")

CreateButton(SettingsPage, "Green", "Set the green accent.", function()
    COLORS.Red = Color3.fromRGB(0, 255, 0)
end, "GREEN")

CreateButton(SettingsPage, "Purple", "Set the purple accent.", function()
    COLORS.Red = Color3.fromRGB(170, 0, 255)
end, "PURPLE")

-- Load autoload only if the user enabled the toggle in this session.
task.defer(function()
    if AutoLoadConfig then
        local autoName = GetAutoload()
        if autoName then
            ConfigName = autoName
            LoadConfig(autoName)
        end
    end
end)

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

if input.KeyCode == Enum.KeyCode.Insert then
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

if input.KeyCode == Enum.KeyCode.P then
PanicEnabled = not PanicEnabled

if PanicEnabled then
for Name in pairs(FeatureStates) do
if Name ~= "Panic" then
FeatureStates[Name] = false
end
end

UpdateStatus()

if NotificationsEnabled then
Notify(
"Flarehook",
"Panic mode enabled.",
2
)
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
Data.Icon.TextColor3 = COLORS.White
Data.Label.TextColor3 = COLORS.White
Data.Label.Font = Enum.Font.GothamBold
else
Data.Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Data.Icon.TextColor3 = COLORS.Muted
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

Player:SetAttribute("FlarehookRange", 50)
Player:SetAttribute("FlarehookSmoothness", 8)
Player:SetAttribute("FlarehookTargetMode", "Closest")
Player:SetAttribute("FlarehookCameraSensitivity", 1)

if Camera then
Camera.FieldOfView = 70
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
