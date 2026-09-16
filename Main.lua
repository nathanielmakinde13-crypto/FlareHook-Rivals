--// FLAREHOOK
--// LocalScript - intended for your own Roblox experience
--// Version: 2.0.0
--// Red / Black UI
--// Includes:
--// Main, Player, Visuals, World, Combat, Misc, Settings, Credits
--// Functional ESP / Highlights / Nametags / Health / Distance / Tracers
--// Color wheel
--// FOV circle
--// Aim Assist / Aimbot / Triggerbot / Auto Shoot
--// Hitbox Expansion / Targeting / Prediction / Team & Visibility checks
--// Smoothing: 0 = snap, 1 = slow
--// Aim Assist uses a fixed softer movement than max Aimbot smoothing

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--==================================================
-- CONFIG
--==================================================

local VERSION = "2.0.0"

local Theme = {
	Main = Color3.fromRGB(185, 20, 28),
	MainDark = Color3.fromRGB(110, 10, 16),
	Background = Color3.fromRGB(12, 12, 14),
	Panel = Color3.fromRGB(18, 18, 21),
	Panel2 = Color3.fromRGB(24, 24, 28),
	Border = Color3.fromRGB(48, 48, 54),
	Text = Color3.fromRGB(240, 240, 242),
	SubText = Color3.fromRGB(145, 145, 152),
	White = Color3.fromRGB(255, 255, 255),
}

local FeatureColor = Color3.fromRGB(255, 45, 50)

local FeatureStates = {}
local FeatureControls = {}

local ScriptEnabled = true
local NotificationsEnabled = true
local PanicBusy = false

local SessionStart = os.clock()

local Original = {
	WalkSpeed = nil,
	JumpPower = nil,
	JumpHeight = nil,
	FOV = nil,
	CameraSensitivity = UserInputService.MouseDeltaSensitivity,
	CameraMode = LocalPlayer.CameraMode,
	Lighting = {},
}

local CrosshairSettings = {
	Enabled = true,
	Size = 8,
	Gap = 5,
	Thickness = 2,
	Style = "Plus",
	Color = FeatureColor,
}

local VisualSettings = {
	ESP = false,
	Highlights = false,
	NameTags = false,
	HealthBars = false,
	Distance = false,
	Tracers = false,
	TeamColor = true,
	HitEffect = false,
}

local WorldSettings = {
	Fullbright = false,
	NoFog = false,
	Bloom = false,
	ColorCorrection = false,
}

local CombatSettings = {
	AimAssist = false,
	Aimbot = false,
	Triggerbot = false,
	HitboxExpansion = false,
	AutoShoot = false,

	TargetSelection = "Players",
	TargetPriority = "Crosshair",
	Prediction = 0.12,

	FOV = 150,
	TeamCheck = true,
	VisibilityCheck = true,

	Smoothing = 0,
	TargetLock = false,
	RecoilControl = false,
}

--==================================================
-- HELPERS
--==================================================

local function GetCharacter(player)
	return player and player.Character
end

local function GetHumanoid(character)
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(character)
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
end

local function IsAlive(player)
	local character = GetCharacter(player)
	local humanoid = GetHumanoid(character)

	return character
		and humanoid
		and humanoid.Health > 0
end

local function GetAimPart(character)
	if not character then
		return nil
	end

	return character:FindFirstChild("Head")
		or character:FindFirstChild("UpperTorso")
		or GetRoot(character)
end

local function TeamColor(player)
	if player and player.TeamColor then
		return player.TeamColor.Color
	end

	return FeatureColor
end

local function AddCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 4)
	corner.Parent = object
	return corner
end

local function AddStroke(object, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Border
	stroke.Thickness = thickness or 1
	stroke.Parent = object
	return stroke
end

local function Tween(object, properties, duration)
	local info = TweenInfo.new(
		duration or 0.15,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	TweenService:Create(object, info, properties):Play()
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FLAREHOOK"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.fromOffset(820, 520)
MainFrame.Position = UDim2.new(0.5, -410, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
AddCorner(MainFrame, 4)
AddStroke(MainFrame, Theme.Border)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.BackgroundColor3 = Theme.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
AddCorner(TopBar, 4)

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.fromOffset(38, 38)
Logo.Position = UDim2.fromOffset(10, 10)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://1688841862"
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(58, 8)
Title.Size = UDim2.fromOffset(300, 24)
Title.Font = Enum.Font.GothamBold
Title.Text = "FLAREHOOK"
Title.TextColor3 = Theme.Text
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.fromOffset(58, 30)
VersionLabel.Size = UDim2.fromOffset(300, 18)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.Text = "v" .. VERSION .. "  •  LOCAL"
VersionLabel.TextColor3 = Theme.SubText
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(34, 34)
CloseButton.Position = UDim2.new(1, -44, 0, 12)
CloseButton.BackgroundColor3 = Theme.Panel2
CloseButton.Text = "×"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 22
CloseButton.TextColor3 = Theme.Text
CloseButton.AutoButtonColor = false
CloseButton.Parent = TopBar
AddCorner(CloseButton, 4)

CloseButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(180, 452)
Sidebar.Position = UDim2.fromOffset(0, 58)
Sidebar.BackgroundColor3 = Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -20, 0, 34)
SearchBox.Position = UDim2.fromOffset(10, 10)
SearchBox.BackgroundColor3 = Theme.Panel2
SearchBox.PlaceholderText = "Search..."
SearchBox.Text = ""
SearchBox.TextColor3 = Theme.Text
SearchBox.PlaceholderColor3 = Theme.SubText
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Sidebar
AddCorner(SearchBox, 4)
AddStroke(SearchBox)

local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Size = UDim2.new(1, -20, 1, -58)
TabHolder.Position = UDim2.fromOffset(10, 50)
TabHolder.BackgroundTransparency = 1
TabHolder.BorderSizePixel = 0
TabHolder.ScrollBarThickness = 2
TabHolder.CanvasSize = UDim2.new()
TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabHolder.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabHolder

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -180, 1, -58)
Content.Position = UDim2.fromOffset(180, 58)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

--==================================================
-- PAGES
--==================================================

local Pages = {}

local function CreatePage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, -20, 1, -20)
	page.Position = UDim2.fromOffset(10, 10)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.CanvasSize = UDim2.new()
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	Pages[name] = page

	return page
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
-- TAB SYSTEM
--==================================================

local Tabs = {}
local CurrentTab = "Main"

local TabIcons = {
	Main = "⌂",
	Player = "♙",
	Visuals = "◉",
	World = "◆",
	Combat = "⚔",
	Misc = "✦",
	Settings = "⚙",
	Credits = "★",
}

local function SelectTab(name)
	CurrentTab = name

	for tabName, button in pairs(Tabs) do
		local selected = tabName == name

		button.BackgroundColor3 = selected
			and Theme.MainDark
			or Theme.Panel

		button.Icon.TextColor3 = selected
			and Theme.White
			or Theme.SubText

		button.Label.TextColor3 = selected
			and Theme.Text
			or Theme.SubText
	end

	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end
end

for index, name in ipairs({
	"Main",
	"Player",
	"Visuals",
	"World",
	"Combat",
	"Misc",
	"Settings",
	"Credits",
}) do
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 38)
	button.BackgroundColor3 = Theme.Panel
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.LayoutOrder = index
	button.Parent = TabHolder
	AddCorner(button, 4)

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromOffset(28, 38)
	icon.Position = UDim2.fromOffset(5, 0)
	icon.Font = Enum.Font.GothamBold
	icon.Text = TabIcons[name]
	icon.TextSize = 16
	icon.TextColor3 = Theme.SubText
	icon.Parent = button

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(38, 0)
	label.Size = UDim2.new(1, -43, 1, 0)
	label.Font = Enum.Font.GothamMedium
	label.Text = name
	label.TextSize = 12
	label.TextColor3 = Theme.SubText
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	button.Icon = icon
	button.Label = label

	button.MouseButton1Click:Connect(function()
		SelectTab(name)
	end)

	Tabs[name] = button
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local search = SearchBox.Text:lower()

	for name, button in pairs(Tabs) do
		button.Visible = search == "" or name:lower():find(search, 1, true) ~= nil
	end
end)

--==================================================
-- UI COMPONENTS
--==================================================

local function CreateSection(parent, title, description)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -4, 0, 42)
	section.BackgroundColor3 = Theme.Panel
	section.BorderSizePixel = 0
	section.Parent = parent
	AddCorner(section, 4)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(12, 5)
	titleLabel.Size = UDim2.new(1, -24, 0, 17)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = section

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 22)
	descLabel.Size = UDim2.new(1, -24, 0, 15)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description or ""
	descLabel.TextColor3 = Theme.SubText
	descLabel.TextSize = 9
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = section

	return section
end

local function CreateRow(parent, height)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -4, 0, height or 46)
	row.BackgroundColor3 = Theme.Panel
	row.BorderSizePixel = 0
	row.Parent = parent
	AddCorner(row, 4)
	return row
end

local function CreateLabel(row, title, description)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(12, 6)
	titleLabel.Size = UDim2.new(1, -150, 0, 18)
	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 12
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = row

	if description then
		local desc = Instance.new("TextLabel")
		desc.BackgroundTransparency = 1
		desc.Position = UDim2.fromOffset(12, 24)
		desc.Size = UDim2.new(1, -150, 0, 15)
		desc.Font = Enum.Font.Gotham
		desc.Text = description
		desc.TextColor3 = Theme.SubText
		desc.TextSize = 9
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Parent = row
	end
end

local function CreateToggle(parent, title, description, default, callback, featureName)
	local row = CreateRow(parent, 46)
	CreateLabel(row, title, description)

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.fromOffset(40, 22)
	switch.Position = UDim2.new(1, -52, 0.5, -11)
	switch.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
	switch.BorderSizePixel = 0
	switch.Text = ""
	switch.AutoButtonColor = false
	switch.Parent = row
	AddCorner(switch, 4)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Theme.SubText
	knob.BorderSizePixel = 0
	knob.Parent = switch
	AddCorner(knob, 3)

	local state = default == true

	local function Set(value, silent)
		state = value == true

		switch.BackgroundColor3 = state
			and FeatureColor
			or Color3.fromRGB(38, 38, 42)

		knob.BackgroundColor3 = state
			and Theme.White
			or Theme.SubText

		knob.Position = state
			and UDim2.fromOffset(21, 3)
			or UDim2.fromOffset(3, 3)

		if featureName then
			FeatureStates[featureName] = state
		end

		if callback and not silent then
			callback(state)
		end
	end

	switch.MouseButton1Click:Connect(function()
		Set(not state)
	end)

	local control = {
		Set = Set,
		Get = function()
			return state
		end,
		Row = row,
	}

	if featureName then
		FeatureControls[featureName] = control
	end

	Set(state, true)

	return control
end

local function CreateSlider(parent, title, description, min, max, default, callback)
	local row = CreateRow(parent, 58)
	CreateLabel(row, title, description)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 190, 0, 6)
	bar.Position = UDim2.new(1, -205, 0.5, 7)
	bar.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
	bar.BorderSizePixel = 0
	bar.Parent = row
	AddCorner(bar, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = FeatureColor
	fill.BorderSizePixel = 0
	fill.Parent = bar
	AddCorner(fill, 3)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(10, 10)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.BackgroundColor3 = Theme.White
	knob.BorderSizePixel = 0
	knob.Parent = bar
	AddCorner(knob, 3)

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.new(1, -205, 0, 4)
	valueLabel.Size = UDim2.fromOffset(190, 15)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextColor3 = Theme.Text
	valueLabel.TextSize = 10
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = row

	local value = default

	local function Set(newValue, silent)
		value = math.clamp(newValue, min, max)

		local alpha = (value - min) / (max - min)

		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = tostring(math.floor(value * 100) / 100)

		if callback and not silent then
			callback(value)
		end
	end

	local dragging = false

	local function UpdateFromMouse()
		local alpha = math.clamp(
			(Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
			0,
			1
		)

		Set(min + (max - min) * alpha)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateFromMouse()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateFromMouse()
		end
	end)

	Set(value, true)

	return {
		Set = Set,
		Get = function()
			return value
		end,
		Row = row,
	}
end

local function CreateDropdown(parent, title, description, options, default, callback)
	local row = CreateRow(parent, 46)
	CreateLabel(row, title, description)

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(145, 28)
	button.Position = UDim2.new(1, -157, 0.5, -14)
	button.BackgroundColor3 = Theme.Panel2
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 10
	button.TextColor3 = Theme.Text
	button.AutoButtonColor = false
	button.Parent = row
	AddCorner(button, 4)
	AddStroke(button)

	local index = table.find(options, default) or 1
	local current = options[index]

	local function Set(value)
		local found = table.find(options, value)

		if found then
			index = found
			current = value
			button.Text = current

			if callback then
				callback(current)
			end
		end
	end

	button.MouseButton1Click:Connect(function()
		index += 1

		if index > #options then
			index = 1
		end

		Set(options[index])
	end)

	Set(current)

	return {
		Set = Set,
		Get = function()
			return current
		end,
		Row = row,
	}
end

local function CreateButton(parent, title, description, text, callback)
	local row = CreateRow(parent, 46)
	CreateLabel(row, title, description)

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(120, 28)
	button.Position = UDim2.new(1, -132, 0.5, -14)
	button.BackgroundColor3 = Theme.MainDark
	button.BorderSizePixel = 0
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 10
	button.TextColor3 = Theme.Text
	button.AutoButtonColor = false
	button.Parent = row
	AddCorner(button, 4)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return button
end

--==================================================
-- NOTIFICATIONS
--==================================================

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Size = UDim2.fromOffset(280, 300)
NotificationHolder.Position = UDim2.new(1, -295, 0, 70)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 6)
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotificationLayout.Parent = NotificationHolder

local function Notify(title, message)
	if not NotificationsEnabled then
		return
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 54)
	frame.BackgroundColor3 = Theme.Panel
	frame.BorderSizePixel = 0
	frame.Parent = NotificationHolder
	AddCorner(frame, 4)
	AddStroke(frame, Theme.Border)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 1, 0)
	accent.BackgroundColor3 = FeatureColor
	accent.BorderSizePixel = 0
	accent.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(12, 7)
	titleLabel.Size = UDim2.new(1, -20, 0, 16)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 11
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame

	local msg = Instance.new("TextLabel")
	msg.BackgroundTransparency = 1
	msg.Position = UDim2.fromOffset(12, 24)
	msg.Size = UDim2.new(1, -20, 0, 22)
	msg.Font = Enum.Font.Gotham
	msg.Text = message
	msg.TextColor3 = Theme.SubText
	msg.TextSize = 9
	msg.TextWrapped = true
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.Parent = frame

	task.delay(3, function()
		if frame.Parent then
			Tween(frame, {
				BackgroundTransparency = 1,
			}, 0.25)

			task.wait(0.3)
			frame:Destroy()
		end
	end)
end

--==================================================
-- STATUS DISPLAY
--==================================================

local StatusGui = Instance.new("Frame")
StatusGui.Size = UDim2.fromOffset(190, 190)
StatusGui.Position = UDim2.new(0, 15, 1, -205)
StatusGui.BackgroundColor3 = Theme.Panel
StatusGui.BackgroundTransparency = 0.08
StatusGui.BorderSizePixel = 0
StatusGui.Visible = true
StatusGui.Parent = ScreenGui
AddCorner(StatusGui, 4)
AddStroke(StatusGui)

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -20, 0, 24)
StatusTitle.Position = UDim2.fromOffset(10, 6)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "FEATURE STATUS"
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 10
StatusTitle.TextColor3 = Theme.Text
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusGui

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 1, -35)
StatusText.Position = UDim2.fromOffset(10, 30)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Code
StatusText.TextSize = 9
StatusText.TextColor3 = FeatureColor
StatusText.TextWrapped = false
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextYAlignment = Enum.TextYAlignment.Top
StatusText.Parent = StatusGui

local function UpdateStatus()
	local active = {}

	for name, enabled in pairs(FeatureStates) do
		if enabled then
			table.insert(active, name)
		end
	end

	table.sort(active)

	if #active == 0 then
		StatusText.Text = "No active features"
	else
		StatusText.Text = table.concat(active, "\n")
	end
end

--==================================================
-- FPS / INFO HUD
--==================================================

local InfoGui = Instance.new("Frame")
InfoGui.Size = UDim2.fromOffset(240, 120)
InfoGui.Position = UDim2.new(1, -255, 1, -135)
InfoGui.BackgroundColor3 = Theme.Panel
InfoGui.BackgroundTransparency = 0.08
InfoGui.BorderSizePixel = 0
InfoGui.Visible = false
InfoGui.Parent = ScreenGui
AddCorner(InfoGui, 4)
AddStroke(InfoGui)

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, -20)
InfoText.Position = UDim2.fromOffset(10, 10)
InfoText.BackgroundTransparency = 1
InfoText.Font = Enum.Font.Code
InfoText.TextSize = 9
InfoText.TextColor3 = Theme.Text
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = InfoGui

local ShowFPS = false
local ShowServer = false
local ShowPlayer = false
local ShowSession = false

local fps = 0

RunService.RenderStepped:Connect(function(dt)
	if dt > 0 then
		fps = math.floor(1 / dt)
	end

	if InfoGui.Visible then
		local lines = {}

		if ShowFPS then
			table.insert(lines, "FPS       : " .. tostring(fps))
		end

		if ShowServer then
			table.insert(lines, "PLACE ID  : " .. tostring(game.PlaceId))
			table.insert(lines, "PLAYERS   : " .. tostring(#Players:GetPlayers()))
			table.insert(lines, "JOB ID    : " .. string.sub(game.JobId, 1, 12))
		end

		if ShowPlayer then
			table.insert(lines, "PLAYER    : " .. LocalPlayer.Name)
			table.insert(lines, "DISPLAY   : " .. LocalPlayer.DisplayName)
			table.insert(lines, "USER ID   : " .. tostring(LocalPlayer.UserId))
		end

		if ShowSession then
			local elapsed = math.floor(os.clock() - SessionStart)
			local minutes = math.floor(elapsed / 60)
			local seconds = elapsed % 60

			table.insert(lines, string.format(
				"SESSION   : %02d:%02d",
				minutes,
				seconds
			))
		end

		InfoText.Text = table.concat(lines, "\n")
	end
end)

--==================================================
-- CROSSHAIR
--==================================================

local CrosshairGui = Instance.new("Frame")
CrosshairGui.Name = "Crosshair"
CrosshairGui.Size = UDim2.fromScale(1, 1)
CrosshairGui.BackgroundTransparency = 1
CrosshairGui.Visible = CrosshairSettings.Enabled
CrosshairGui.Parent = ScreenGui

local CrosshairParts = {}

for i = 1, 4 do
	local line = Instance.new("Frame")
	line.BorderSizePixel = 0
	line.BackgroundColor3 = CrosshairSettings.Color
	line.Parent = CrosshairGui
	CrosshairParts[i] = line
end

local CrosshairDot = Instance.new("Frame")
CrosshairDot.BorderSizePixel = 0
CrosshairDot.BackgroundColor3 = CrosshairSettings.Color
CrosshairDot.Parent = CrosshairGui
AddCorner(CrosshairDot, 5)

local function UpdateCrosshair()
	CrosshairGui.Visible = CrosshairSettings.Enabled

	local size = CrosshairSettings.Size
	local gap = CrosshairSettings.Gap
	local thickness = CrosshairSettings.Thickness
	local color = CrosshairSettings.Color

	for _, part in ipairs(CrosshairParts) do
		part.BackgroundColor3 = color
	end

	CrosshairDot.BackgroundColor3 = color

	if CrosshairSettings.Style == "Dot" then
		for _, part in ipairs(CrosshairParts) do
			part.Visible = false
		end

		CrosshairDot.Visible = true
		CrosshairDot.Size = UDim2.fromOffset(thickness + 2, thickness + 2)
		CrosshairDot.Position = UDim2.new(
			0.5,
			-(thickness + 2) / 2,
			0.5,
			-(thickness + 2) / 2
		)
	else
		CrosshairDot.Visible = false

		local centerX = Camera.ViewportSize.X / 2
		local centerY = Camera.ViewportSize.Y / 2

		CrosshairParts[1].Visible = true
		CrosshairParts[1].Size = UDim2.fromOffset(thickness, size)
		CrosshairParts[1].Position = UDim2.fromOffset(
			centerX - thickness / 2,
			centerY - gap - size
		)

		CrosshairParts[2].Visible = true
		CrosshairParts[2].Size = UDim2.fromOffset(thickness, size)
		CrosshairParts[2].Position = UDim2.fromOffset(
			centerX - thickness / 2,
			centerY + gap
		)

		CrosshairParts[3].Visible = true
		CrosshairParts[3].Size = UDim2.fromOffset(size, thickness)
		CrosshairParts[3].Position = UDim2.fromOffset(
			centerX - gap - size,
			centerY - thickness / 2
		)

		CrosshairParts[4].Visible = true
		CrosshairParts[4].Size = UDim2.fromOffset(size, thickness)
		CrosshairParts[4].Position = UDim2.fromOffset(
			centerX + gap,
			centerY - thickness / 2
		)
	end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCrosshair)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVGui = Instance.new("Frame")
FOVGui.Name = "FOVCircle"
FOVGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGui.BackgroundTransparency = 1
FOVGui.BorderSizePixel = 0
FOVGui.Parent = ScreenGui

local FOVAspect = Instance.new("UIAspectRatioConstraint")
FOVAspect.AspectRatio = 1
FOVAspect.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Color = FeatureColor
FOVStroke.Transparency = 0.15
FOVStroke.Parent = FOVGui

FOVGui.Visible = false

local function UpdateFOVCircle()
	local radius = CombatSettings.FOV

	FOVGui.Size = UDim2.fromOffset(radius * 2, radius * 2)

	FOVGui.Position = UDim2.new(
		0.5,
		0,
		0.5,
		0
	)

	FOVStroke.Color = FeatureColor
	FOVGui.Visible = CombatSettings.Aimbot
		or CombatSettings.AimAssist
end

--==================================================
-- COLOR WHEEL
--==================================================

local ColorWheelFrame = Instance.new("Frame")
ColorWheelFrame.Size = UDim2.fromOffset(230, 230)
ColorWheelFrame.BackgroundColor3 = Theme.Panel
ColorWheelFrame.BorderSizePixel = 0
ColorWheelFrame.Visible = false
ColorWheelFrame.Parent = ScreenGui
AddCorner(ColorWheelFrame, 4)
AddStroke(ColorWheelFrame)

local WheelTitle = Instance.new("TextLabel")
WheelTitle.Size = UDim2.new(1, -20, 0, 25)
WheelTitle.Position = UDim2.fromOffset(10, 7)
WheelTitle.BackgroundTransparency = 1
WheelTitle.Text = "VISUAL COLOR"
WheelTitle.Font = Enum.Font.GothamBold
WheelTitle.TextSize = 11
WheelTitle.TextColor3 = Theme.Text
WheelTitle.TextXAlignment = Enum.TextXAlignment.Left
WheelTitle.Parent = ColorWheelFrame

local Wheel = Instance.new("Frame")
Wheel.Size = UDim2.fromOffset(160, 160)
Wheel.Position = UDim2.fromOffset(35, 36)
Wheel.BackgroundTransparency = 1
Wheel.Parent = ColorWheelFrame

local WheelCenter = Instance.new("Frame")
WheelCenter.Size = UDim2.fromOffset(50, 50)
WheelCenter.AnchorPoint = Vector2.new(0.5, 0.5)
WheelCenter.Position = UDim2.fromScale(0.5, 0.5)
WheelCenter.BackgroundColor3 = FeatureColor
WheelCenter.BorderSizePixel = 0
WheelCenter.ZIndex = 10
WheelCenter.Parent = Wheel
AddCorner(WheelCenter, 25)
AddStroke(WheelCenter, Theme.White, 1)

local Hue = 0

-- 72 segments create a real clickable circular hue wheel.
local WheelSegments = {}

for i = 1, 72 do
	local segment = Instance.new("Frame")
	segment.Size = UDim2.fromOffset(4, 72)
	segment.AnchorPoint = Vector2.new(0.5, 0.5)
	segment.Position = UDim2.fromScale(0.5, 0.5)
	segment.BorderSizePixel = 0
	segment.BackgroundColor3 = Color3.fromHSV((i - 1) / 72, 1, 1)
	segment.Rotation = (i - 1) * 5
	segment.ZIndex = 5
	segment.Parent = Wheel

	WheelSegments[i] = segment
end

local WheelInput = Instance.new("TextButton")
WheelInput.Size = UDim2.fromScale(1, 1)
WheelInput.BackgroundTransparency = 1
WheelInput.Text = ""
WheelInput.ZIndex = 20
WheelInput.Parent = Wheel

local ColorPreview = Instance.new("Frame")
ColorPreview.Size = UDim2.fromOffset(28, 28)
ColorPreview.Position = UDim2.fromOffset(185, 43)
ColorPreview.BackgroundColor3 = FeatureColor
ColorPreview.BorderSizePixel = 0
ColorPreview.Parent = ColorWheelFrame
AddCorner(ColorPreview, 4)

local ColorHex = Instance.new("TextLabel")
ColorHex.Size = UDim2.fromOffset(50, 20)
ColorHex.Position = UDim2.fromOffset(174, 76)
ColorHex.BackgroundTransparency = 1
ColorHex.Font = Enum.Font.Code
ColorHex.TextSize = 9
ColorHex.TextColor3 = Theme.Text
ColorHex.Text = "#FF2D32"
ColorHex.Parent = ColorWheelFrame

local function ToHex(color)
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255)
	)
end

local function ApplyFeatureColor(color)
	FeatureColor = color
	CrosshairSettings.Color = color

	ColorPreview.BackgroundColor3 = color
	ColorHex.Text = ToHex(color)
	WheelCenter.BackgroundColor3 = color
	FOVStroke.Color = color

	for _, part in ipairs(CrosshairParts) do
		part.BackgroundColor3 = color
	end

	CrosshairDot.BackgroundColor3 = color

	UpdateCrosshair()
end

local function SelectHueFromMouse()
	local center = Wheel.AbsolutePosition + Wheel.AbsoluteSize / 2
	local mousePosition = Vector2.new(Mouse.X, Mouse.Y)

	local delta = mousePosition - center

	if delta.Magnitude < 25 then
		return
	end

	local angle = math.atan2(delta.Y, delta.X)
	Hue = (angle / (math.pi * 2)) + 0.5

	if Hue < 0 then
		Hue += 1
	end

	local color = Color3.fromHSV(Hue, 1, 1)

	ApplyFeatureColor(color)
end

WheelInput.MouseButton1Down:Connect(function()
	SelectHueFromMouse()
end)

WheelInput.MouseMoved:Connect(function()
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		SelectHueFromMouse()
	end
end)

--==================================================
-- VISUAL OBJECT STORAGE
--==================================================

local VisualObjects = {}
local TracerObjects = {}

local function DestroyVisuals(player)
	local objects = VisualObjects[player]

	if objects then
		for _, object in pairs(objects) do
			if typeof(object) == "Instance" and object.Parent then
				object:Destroy()
			end
		end

		VisualObjects[player] = nil
	end

	if TracerObjects[player] then
		TracerObjects[player]:Destroy()
		TracerObjects[player] = nil
	end
end

local function CreateVisuals(player)
	if player == LocalPlayer then
		return
	end

	DestroyVisuals(player)

	local character = player.Character

	if not character then
		return
	end

	local objects = {}
	VisualObjects[player] = objects

	--========================
	-- HIGHLIGHT
	--========================

	local highlight = Instance.new("Highlight")
	highlight.Name = "FLAREHOOK_Highlight"
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.Enabled = VisualSettings.Highlights or VisualSettings.ESP
	highlight.FillColor = VisualSettings.TeamColor
		and TeamColor(player)
		or FeatureColor
	highlight.OutlineColor = FeatureColor
	highlight.Parent = character

	objects.Highlight = highlight

	--========================
	-- BILLBOARD
	--========================

	local head = character:FindFirstChild("Head")

	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "FLAREHOOK_Info"
		billboard.Adornee = head
		billboard.Size = UDim2.fromOffset(180, 70)
		billboard.StudsOffset = Vector3.new(0, 2.8, 0)
		billboard.AlwaysOnTop = true
		billboard.Enabled =
			VisualSettings.NameTags
			or VisualSettings.HealthBars
			or VisualSettings.Distance
		billboard.Parent = head

		objects.Billboard = billboard

		local name = Instance.new("TextLabel")
		name.Name = "Name"
		name.Size = UDim2.new(1, 0, 0, 20)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 11
		name.Text = player.DisplayName .. "  @" .. player.Name
		name.TextColor3 = VisualSettings.TeamColor
			and TeamColor(player)
			or FeatureColor
		name.Visible = VisualSettings.NameTags
		name.Parent = billboard

		objects.Name = name

		local healthBack = Instance.new("Frame")
		healthBack.Size = UDim2.new(0, 110, 0, 5)
		healthBack.Position = UDim2.new(0.5, -55, 0, 24)
		healthBack.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
		healthBack.BorderSizePixel = 0
		healthBack.Visible = VisualSettings.HealthBars
		healthBack.Parent = billboard
		AddCorner(healthBack, 2)

		local healthFill = Instance.new("Frame")
		healthFill.Size = UDim2.fromScale(1, 1)
		healthFill.BackgroundColor3 = FeatureColor
		healthFill.BorderSizePixel = 0
		healthFill.Parent = healthBack
		AddCorner(healthFill, 2)

		objects.HealthBack = healthBack
		objects.HealthFill = healthFill

		local distance = Instance.new("TextLabel")
		distance.Name = "Distance"
		distance.Size = UDim2.new(1, 0, 0, 18)
		distance.Position = UDim2.fromOffset(0, 31)
		distance.BackgroundTransparency = 1
		distance.Font = Enum.Font.Gotham
		distance.TextSize = 9
		distance.TextColor3 = Theme.Text
		distance.Visible = VisualSettings.Distance
		distance.Parent = billboard

		objects.Distance = distance
	end

	--========================
	-- TRACER
	--========================

	local tracer = Instance.new("Frame")
	tracer.Name = "Tracer"
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = VisualSettings.TeamColor
		and TeamColor(player)
		or FeatureColor
	tracer.BorderSizePixel = 0
	tracer.Size = UDim2.fromOffset(2, 0)
	tracer.Visible = VisualSettings.Tracers
	tracer.Parent = ScreenGui

	objects.Tracer = tracer
	TracerObjects[player] = tracer
end

local function RefreshVisuals()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if VisualSettings.ESP
				or VisualSettings.Highlights
				or VisualSettings.NameTags
				or VisualSettings.HealthBars
				or VisualSettings.Distance
				or VisualSettings.Tracers then

				CreateVisuals(player)
			else
				DestroyVisuals(player)
			end
		end
	end
end

local function UpdateVisualObjects()
	for player, objects in pairs(VisualObjects) do
		local character = player.Character
		local humanoid = GetHumanoid(character)
		local root = GetRoot(character)

		if not character or not humanoid or not root then
			continue
		end

		local highlight = objects.Highlight

		if highlight then
			highlight.Enabled =
				VisualSettings.ESP
				or VisualSettings.Highlights

			highlight.FillColor =
				VisualSettings.TeamColor
				and TeamColor(player)
				or FeatureColor

			highlight.OutlineColor = FeatureColor
		end

		if objects.Name then
			objects.Name.Visible = VisualSettings.NameTags
			objects.Name.TextColor3 =
				VisualSettings.TeamColor
				and TeamColor(player)
				or FeatureColor
		end

		if objects.HealthBack then
			objects.HealthBack.Visible = VisualSettings.HealthBars

			local healthPercent = math.clamp(
				humanoid.Health / math.max(humanoid.MaxHealth, 1),
				0,
				1
			)

			objects.HealthFill.Size = UDim2.new(
				healthPercent,
				0,
				1,
				0
			)
		end

		if objects.Distance then
			objects.Distance.Visible = VisualSettings.Distance

			local localRoot = GetRoot(LocalPlayer.Character)

			if localRoot then
				local distance = math.floor(
					(localRoot.Position - root.Position).Magnitude
				)

				objects.Distance.Text = distance .. " studs"
			end
		end

		if objects.Billboard then
			objects.Billboard.Enabled =
				VisualSettings.NameTags
				or VisualSettings.HealthBars
				or VisualSettings.Distance
		end

		if objects.Tracer then
			objects.Tracer.Visible = VisualSettings.Tracers

			local position, visible = Camera:WorldToViewportPoint(
				root.Position
			)

			if visible then
				local startPos = Vector2.new(
					Camera.ViewportSize.X / 2,
					Camera.ViewportSize.Y
				)

				local endPos = Vector2.new(
					position.X,
					position.Y
				)

				local difference = endPos - startPos
				local length = difference.Magnitude

				objects.Tracer.Size = UDim2.fromOffset(
					2,
					length
				)

				objects.Tracer.Position = UDim2.fromOffset(
					(startPos.X + endPos.X) / 2,
					(startPos.Y + endPos.Y) / 2
				)

				objects.Tracer.Rotation =
					math.deg(math.atan2(
						difference.Y,
						difference.X
					)) + 90

				objects.Tracer.BackgroundColor3 =
					VisualSettings.TeamColor
					and TeamColor(player)
					or FeatureColor
			else
				objects.Tracer.Visible = false
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		RefreshVisuals()
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	DestroyVisuals(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			RefreshVisuals()
		end)
	end
end

--==================================================
-- HIT EFFECT
--==================================================

local HitFlash = Instance.new("Frame")
HitFlash.Size = UDim2.fromScale(1, 1)
HitFlash.BackgroundColor3 = FeatureColor
HitFlash.BackgroundTransparency = 1
HitFlash.BorderSizePixel = 0
HitFlash.ZIndex = 200
HitFlash.Parent = ScreenGui

local LastHealth = nil

local function ConnectHitEffect(character)
	local humanoid = GetHumanoid(character)

	if not humanoid then
		return
	end

	LastHealth = humanoid.Health

	humanoid.HealthChanged:Connect(function(newHealth)
		if VisualSettings.HitEffect
			and LastHealth
			and newHealth < LastHealth then

			HitFlash.BackgroundColor3 = FeatureColor
			HitFlash.BackgroundTransparency = 0.75

			Tween(HitFlash, {
				BackgroundTransparency = 1,
			}, 0.25)
		end

		LastHealth = newHealth
	end)
end

if LocalPlayer.Character then
	ConnectHitEffect(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.5)
	ConnectHitEffect(character)
end)

--==================================================
-- WORLD / LIGHTING
--==================================================

local ColorCorrection

local function SaveLighting()
	Original.Lighting.Brightness = Lighting.Brightness
	Original.Lighting.ClockTime = Lighting.ClockTime
	Original.Lighting.FogEnd = Lighting.FogEnd
	Original.Lighting.GlobalShadows = Lighting.GlobalShadows
	Original.Lighting.Ambient = Lighting.Ambient
	Original.Lighting.OutdoorAmbient = Lighting.OutdoorAmbient
end

SaveLighting()

local function ApplyWorldSettings()
	if WorldSettings.Fullbright then
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	else
		Lighting.Brightness = Original.Lighting.Brightness
		Lighting.ClockTime = Original.Lighting.ClockTime
		Lighting.GlobalShadows = Original.Lighting.GlobalShadows
		Lighting.Ambient = Original.Lighting.Ambient
		Lighting.OutdoorAmbient = Original.Lighting.OutdoorAmbient
	end

	if WorldSettings.NoFog then
		Lighting.FogEnd = 100000
	else
		Lighting.FogEnd = Original.Lighting.FogEnd
	end

	if WorldSettings.Bloom then
		if not Lighting:FindFirstChild("FLAREHOOK_Bloom") then
			local bloom = Instance.new("BloomEffect")
			bloom.Name = "FLAREHOOK_Bloom"
			bloom.Intensity = 0.4
			bloom.Size = 24
			bloom.Threshold = 1
			bloom.Parent = Lighting
		end
	else
		local bloom = Lighting:FindFirstChild("FLAREHOOK_Bloom")

		if bloom then
			bloom:Destroy()
		end
	end

	if WorldSettings.ColorCorrection then
		if not ColorCorrection then
			ColorCorrection = Instance.new("ColorCorrectionEffect")
			ColorCorrection.Name = "FLAREHOOK_ColorCorrection"
			ColorCorrection.Saturation = 0.1
			ColorCorrection.Contrast = 0.15
			ColorCorrection.Parent = Lighting
		end
	else
		if ColorCorrection then
			ColorCorrection:Destroy()
			ColorCorrection = nil
		end
	end
end

--==================================================
-- PLAYER FUNCTIONS
--==================================================

local function ApplyMovement()
	local character = LocalPlayer.Character
	local humanoid = GetHumanoid(character)

	if not humanoid then
		return
	end

	if Original.WalkSpeed == nil then
		Original.WalkSpeed = humanoid.WalkSpeed
	end

	if Original.JumpPower == nil then
		Original.JumpPower = humanoid.JumpPower
	end

	if Original.JumpHeight == nil then
		Original.JumpHeight = humanoid.JumpHeight
	end
end

local function SetWalkSpeed(value)
	local humanoid = GetHumanoid(LocalPlayer.Character)

	if humanoid then
		if Original.WalkSpeed == nil then
			Original.WalkSpeed = humanoid.WalkSpeed
		end

		humanoid.WalkSpeed = value
	end
end

local function SetJumpPower(value)
	local humanoid = GetHumanoid(LocalPlayer.Character)

	if humanoid then
		if Original.JumpPower == nil then
			Original.JumpPower = humanoid.JumpPower
		end

		if humanoid.UseJumpPower then
			humanoid.JumpPower = value
		else
			humanoid.JumpHeight = math.max(
				2,
				value / 7
			)
		end
	end
end

local function ResetCharacter()
	local character = LocalPlayer.Character
	local humanoid = GetHumanoid(character)

	if humanoid then
		humanoid.Health = 0
	end
end

local CharacterTransparency = {}

local function SetCharacterVisible(visible)
	local character = LocalPlayer.Character

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if CharacterTransparency[object] == nil then
				CharacterTransparency[object] =
					object.LocalTransparencyModifier
			end

			object.LocalTransparencyModifier =
				visible and 0 or 1
		end
	end
end

local MovementEnabled = true

local function SetMovement(enabled)
	MovementEnabled = enabled

	local humanoid = GetHumanoid(LocalPlayer.Character)

	if not humanoid then
		return
	end

	if enabled then
		humanoid.WalkSpeed =
			FeatureControls["Walk Speed"]
			and FeatureControls["Walk Speed"].Get()
			or 16

		if humanoid.UseJumpPower then
			humanoid.JumpPower =
				FeatureControls["Jump Power"]
				and FeatureControls["Jump Power"].Get()
				or 50
		end
	else
		humanoid.WalkSpeed = 0

		if humanoid.UseJumpPower then
			humanoid.JumpPower = 0
		else
			humanoid.JumpHeight = 0
		end
	end
end

--==================================================
-- COMBAT TARGETING
--==================================================

local LockedTarget = nil

local function IsEnemy(player)
	if not CombatSettings.TeamCheck then
		return true
	end

	if not LocalPlayer.Team or not player.Team then
		return true
	end

	return LocalPlayer.Team ~= player.Team
end

local function IsVisible(part, character)
	if not CombatSettings.VisibilityCheck then
		return true
	end

	local origin = Camera.CFrame.Position
	local direction = part.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
	}

	local result = Workspace:Raycast(
		origin,
		direction,
		params
	)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(character)
end

local function GetTargetCandidates()
	local candidates = {}

	if CombatSettings.TargetSelection == "Players"
		or CombatSettings.TargetSelection == "Both" then

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer
				and IsAlive(player)
				and IsEnemy(player) then

				table.insert(candidates, player)
			end
		end
	end

	if CombatSettings.TargetSelection == "NPCs"
		or CombatSettings.TargetSelection == "Both" then

		for _, model in ipairs(Workspace:GetChildren()) do
			if model:IsA("Model")
				and not Players:GetPlayerFromCharacter(model)
				and GetHumanoid(model)
				and GetHumanoid(model).Health > 0
				and GetRoot(model) then

				table.insert(candidates, model)
			end
		end
	end

	return candidates
end

local function GetTargetPart(target)
	local character = target:IsA("Player")
		and target.Character
		or target

	return GetAimPart(character)
end

local function GetTargetDistance(target)
	local part = GetTargetPart(target)

	if not part then
		return math.huge
	end

	local screenPosition, visible =
		Camera:WorldToViewportPoint(part.Position)

	if not visible then
		return math.huge
	end

	local center = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	return (
		Vector2.new(screenPosition.X, screenPosition.Y)
		- center
	).Magnitude
end

local function GetTarget()
	if CombatSettings.TargetLock
		and LockedTarget
		and GetTargetPart(LockedTarget) then

		return LockedTarget
	end

	local candidates = GetTargetCandidates()
	local best = nil
	local bestScore = math.huge

	for _, target in ipairs(candidates) do
		local part = GetTargetPart(target)

		if not part then
			continue
		end

		if not IsVisible(
			part,
			target:IsA("Player")
				and target.Character
				or target
		) then
			continue
		end

		local screenDistance = GetTargetDistance(target)

		if screenDistance > CombatSettings.FOV then
			continue
		end

		local score

		if CombatSettings.TargetPriority == "Distance" then
			local root = GetRoot(
				target:IsA("Player")
					and target.Character
					or target
			)

			local localRoot = GetRoot(LocalPlayer.Character)

			if root and localRoot then
				score =
					(root.Position - localRoot.Position).Magnitude
			else
				score = screenDistance
			end

		elseif CombatSettings.TargetPriority == "Health" then
			local humanoid = GetHumanoid(
				target:IsA("Player")
					and target.Character
					or target
			)

			score = humanoid
				and humanoid.Health
				or math.huge
		else
			score = screenDistance
		end

		if score < bestScore then
			bestScore = score
			best = target
		end
	end

	return best
end

local function GetPredictedPosition(part)
	local velocity = part.AssemblyLinearVelocity

	return part.Position
		+ velocity * CombatSettings.Prediction
end

local function AimAtTarget(target, strength)
	local part = GetTargetPart(target)

	if not part then
		return
	end

	local predicted = GetPredictedPosition(part)

	local cameraPosition = Camera.CFrame.Position

	local desired =
		CFrame.lookAt(
			cameraPosition,
			predicted
		)

	if strength >= 1 then
		Camera.CFrame = desired
	else
		Camera.CFrame =
			Camera.CFrame:Lerp(
				desired,
				math.clamp(strength, 0, 1)
			)
	end
end

--==================================================
-- SHOOTING
--==================================================

local function ActivateTool()
	local character = LocalPlayer.Character

	if not character then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		tool:Activate()
	end
end

local function TargetUnderCrosshair()
	local target = GetTarget()

	if not target then
		return nil
	end

	local part = GetTargetPart(target)

	if not part then
		return nil
	end

	local position, visible =
		Camera:WorldToViewportPoint(
			GetPredictedPosition(part)
		)

	if not visible then
		return nil
	end

	local center = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	local distance =
		(Vector2.new(position.X, position.Y) - center).Magnitude

	if distance <= 10 then
		return target
	end

	return nil
end

--==================================================
-- HITBOX EXPANSION
--==================================================

local OriginalHitboxes = {}

local function ApplyHitboxExpansion()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= LocalPlayer
			and target.Character then

			local head = target.Character:FindFirstChild("Head")

			if head then
				if OriginalHitboxes[head] == nil then
					OriginalHitboxes[head] = {
						Size = head.Size,
						Transparency = head.Transparency,
					}
				end

				head.Size = Vector3.new(
					4,
					4,
					4
				)

				head.Transparency = 0.75
			end
		end
	end
end

local function RestoreHitboxes()
	for part, original in pairs(OriginalHitboxes) do
		if part and part.Parent then
			part.Size = original.Size
			part.Transparency = original.Transparency
		end
	end

	table.clear(OriginalHitboxes)
end

--==================================================
-- MAIN PAGE
--==================================================

CreateSection(
	MainPage,
	"CORE",
	"Main player and script controls"
)

CreateToggle(
	MainPage,
	"Main Script",
	"Enable or disable FLAREHOOK features",
	true,
	function(state)
		ScriptEnabled = state

		if not state then
			for name, control in pairs(FeatureControls) do
				if name ~= "Notifications" then
					control.Set(false)
				end
			end

			RestoreHitboxes()
			ApplyWorldSettings()
		end

		Notify(
			"FLAREHOOK",
			state and "Script enabled" or "Script disabled"
		)
	end,
	"Main Script"
)

CreateToggle(
	MainPage,
	"Notifications",
	"Show FLAREHOOK notifications",
	true,
	function(state)
		NotificationsEnabled = state
	end,
	"Notifications"
)

CreateToggle(
	MainPage,
	"Panic / Disable All",
	"Immediately disable active features",
	false,
	function(state)
		if not state or PanicBusy then
			return
		end

		PanicBusy = true

		for name, control in pairs(FeatureControls) do
			if name ~= "Panic / Disable All" then
				control.Set(false)
			end
		end

		RestoreHitboxes()

		PanicBusy = false

		task.defer(function()
			local panic = FeatureControls["Panic / Disable All"]

			if panic then
				panic.Set(false)
			end
		end)

		Notify("PANIC", "All active features disabled")
	end,
	"Panic / Disable All"
)

CreateToggle(
	MainPage,
	"Feature Status",
	"Show currently active features",
	true,
	function(state)
		StatusGui.Visible = state
	end,
	"Feature Status"
)

CreateSection(
	MainPage,
	"PLAYER",
	"Movement and camera settings"
)

CreateSlider(
	MainPage,
	"Walk Speed",
	"Local character walking speed",
	0,
	200,
	16,
	function(value)
		if ScriptEnabled and MovementEnabled then
			SetWalkSpeed(value)
		end
	end
)

CreateSlider(
	MainPage,
	"Jump Power",
	"Local character jump power",
	0,
	200,
	50,
	function(value)
		if ScriptEnabled and MovementEnabled then
			SetJumpPower(value)
		end
	end
)

CreateSlider(
	MainPage,
	"FOV",
	"Camera field of view",
	40,
	140,
	70,
	function(value)
		if Camera then
			Camera.FieldOfView = value
		end
	end
)

CreateButton(
	MainPage,
	"Character Reset",
	"Reset your character",
	"RESET",
	function()
		ResetCharacter()
	end
)

CreateToggle(
	MainPage,
	"Character Visibility",
	"Locally hide or show your character",
	true,
	function(state)
		SetCharacterVisible(state)
	end,
	"Character Visibility"
)

CreateToggle(
	MainPage,
	"Movement",
	"Allow local movement",
	true,
	function(state)
		SetMovement(state)
	end,
	"Movement"
)

CreateSlider(
	MainPage,
	"Camera Sensitivity",
	"Mouse camera sensitivity",
	0,
	2,
	1,
	function(value)
		UserInputService.MouseDeltaSensitivity = value
	end
)

CreateToggle(
	MainPage,
	"Third Person",
	"Use Roblox third-person camera mode",
	true,
	function(state)
		if state then
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
		else
			LocalPlayer.CameraMode = Original.CameraMode
		end
	end,
	"Third Person"
)

CreateSection(
	MainPage,
	"CROSSHAIR",
	"Customize the center-screen crosshair"
)

CreateToggle(
	MainPage,
	"Crosshair",
	"Show the crosshair",
	true,
	function(state)
		CrosshairSettings.Enabled = state
		UpdateCrosshair()
	end,
	"Crosshair"
)

CreateDropdown(
	MainPage,
	"Crosshair Style",
	"Choose crosshair shape",
	{
		"Plus",
		"Dot",
	},
	"Plus",
	function(value)
		CrosshairSettings.Style = value
		UpdateCrosshair()
	end
)

CreateSlider(
	MainPage,
	"Crosshair Size",
	"Length of crosshair lines",
	2,
	30,
	8,
	function(value)
		CrosshairSettings.Size = value
		UpdateCrosshair()
	end
)

CreateSlider(
	MainPage,
	"Crosshair Gap",
	"Distance from the center",
	0,
	20,
	5,
	function(value)
		CrosshairSettings.Gap = value
		UpdateCrosshair()
	end
)

CreateSlider(
	MainPage,
	"Crosshair Thickness",
	"Crosshair line thickness",
	1,
	8,
	2,
	function(value)
		CrosshairSettings.Thickness = value
		UpdateCrosshair()
	end
)

--==================================================
-- PLAYER PAGE
--==================================================

CreateSection(
	PlayerPage,
	"CHARACTER",
	"Additional character controls"
)

CreateButton(
	PlayerPage,
	"Reset Character",
	"Force your character to respawn",
	"RESET",
	ResetCharacter
)

CreateToggle(
	PlayerPage,
	"Character Visibility",
	"Hide your local character",
	true,
	function(state)
		SetCharacterVisible(state)
	end
)

CreateToggle(
	PlayerPage,
	"Movement",
	"Enable or disable movement",
	true,
	function(state)
		SetMovement(state)
	end
)

CreateSlider(
	PlayerPage,
	"Walk Speed",
	"Movement speed",
	0,
	200,
	16,
	function(value)
		if MovementEnabled then
			SetWalkSpeed(value)
		end
	end
)

CreateSlider(
	PlayerPage,
	"Jump Power",
	"Jump power",
	0,
	200,
	50,
	function(value)
		if MovementEnabled then
			SetJumpPower(value)
		end
	end
)

CreateSlider(
	PlayerPage,
	"Camera Sensitivity",
	"Mouse sensitivity",
	0,
	2,
	1,
	function(value)
		UserInputService.MouseDeltaSensitivity = value
	end
)

CreateToggle(
	PlayerPage,
	"Third Person",
	"Switch to third-person camera",
	true,
	function(state)
		LocalPlayer.CameraMode =
			state
			and Enum.CameraMode.Classic
			or Original.CameraMode
	end
)

--==================================================
-- VISUALS PAGE
--==================================================

CreateSection(
	VisualsPage,
	"PLAYER VISUALS",
	"Functional player ESP and visual overlays"
)

CreateToggle(
	VisualsPage,
	"ESP",
	"Highlight players through the world",
	false,
	function(state)
		VisualSettings.ESP = state
		RefreshVisuals()
	end,
	"ESP"
)

CreateToggle(
	VisualsPage,
	"Player Highlights",
	"Highlight character models",
	false,
	function(state)
		VisualSettings.Highlights = state
		RefreshVisuals()
	end,
	"Player Highlights"
)

CreateToggle(
	VisualsPage,
	"Name Tags",
	"Display player names above characters",
	false,
	function(state)
		VisualSettings.NameTags = state
		RefreshVisuals()
	end,
	"Name Tags"
)

CreateToggle(
	VisualsPage,
	"Health Bars",
	"Display live health bars",
	false,
	function(state)
		VisualSettings.HealthBars = state
		RefreshVisuals()
	end,
	"Health Bars"
)

CreateToggle(
	VisualsPage,
	"Distance",
	"Display player distance",
	false,
	function(state)
		VisualSettings.Distance = state
		RefreshVisuals()
	end,
	"Distance"
)

CreateToggle(
	VisualsPage,
	"Tracers",
	"Draw screen-space player tracers",
	false,
	function(state)
		VisualSettings.Tracers = state
		RefreshVisuals()
	end,
	"Tracers"
)

CreateToggle(
	VisualsPage,
	"Team Colors",
	"Use each player's team color",
	true,
	function(state)
		VisualSettings.TeamColor = state
		RefreshVisuals()
	end,
	"Team Colors"
)

CreateToggle(
	VisualsPage,
	"Hit Effect",
	"Flash the screen when you take damage",
	false,
	function(state)
		VisualSettings.HitEffect = state
	end,
	"Hit Effect"
)

CreateSection(
	VisualsPage,
	"COLOR",
	"Choose the color used by FLAREHOOK visuals"
)

CreateButton(
	VisualsPage,
	"Color Wheel",
	"Open the visual color selector",
	"OPEN",
	function()
		ColorWheelFrame.Visible = not ColorWheelFrame.Visible

		if ColorWheelFrame.Visible then
			ColorWheelFrame.Position = UDim2.new(
				0.5,
				-115,
				0.5,
				-115
			)
		end
	end
)

--==================================================
-- WORLD PAGE
--==================================================

CreateSection(
	WorldPage,
	"LIGHTING",
	"Client-side environment effects"
)

CreateToggle(
	WorldPage,
	"Fullbright",
	"Increase visibility by changing local lighting",
	false,
	function(state)
		WorldSettings.Fullbright = state
		ApplyWorldSettings()
	end,
	"Fullbright"
)

CreateToggle(
	WorldPage,
	"No Fog",
	"Remove local fog distance",
	false,
	function(state)
		WorldSettings.NoFog = state
		ApplyWorldSettings()
	end,
	"No Fog"
)

CreateToggle(
	WorldPage,
	"Bloom",
	"Add a local bloom effect",
	false,
	function(state)
		WorldSettings.Bloom = state
		ApplyWorldSettings()
	end,
	"Bloom"
)

CreateToggle(
	WorldPage,
	"Color Correction",
	"Apply local contrast and saturation",
	false,
	function(state)
		WorldSettings.ColorCorrection = state
		ApplyWorldSettings()
	end,
	"Color Correction"
)

--==================================================
-- COMBAT PAGE
--==================================================

CreateSection(
	CombatPage,
	"AIM",
	"Targeting and camera assistance for your game"
)

CreateToggle(
	CombatPage,
	"Aim Assist",
	"Soft camera assistance toward the selected target",
	false,
	function(state)
		CombatSettings.AimAssist = state
		UpdateFOVCircle()
	end,
	"Aim Assist"
)

CreateToggle(
	CombatPage,
	"Aimbot",
	"Automatically aim the camera at the selected target",
	false,
	function(state)
		CombatSettings.Aimbot = state

		if not state then
			LockedTarget = nil
		end

		UpdateFOVCircle()
	end,
	"Aimbot"
)

CreateToggle(
	CombatPage,
	"Target Lock",
	"Keep the current target until it becomes invalid",
	false,
	function(state)
		CombatSettings.TargetLock = state

		if not state then
			LockedTarget = nil
		end
	end,
	"Target Lock"
)

CreateDropdown(
	CombatPage,
	"Target Selection",
	"Choose what can be targeted",
	{
		"Players",
		"NPCs",
		"Both",
	},
	"Players",
	function(value)
		CombatSettings.TargetSelection = value
	end
)

CreateDropdown(
	CombatPage,
	"Target Priority",
	"How targets are selected",
	{
		"Crosshair",
		"Distance",
		"Health",
	},
	"Crosshair",
	function(value)
		CombatSettings.TargetPriority = value
	end
)

CreateSlider(
	CombatPage,
	"Prediction",
	"Lead moving targets",
	0,
	1,
	0.12,
	function(value)
		CombatSettings.Prediction = value
	end
)

CreateSlider(
	CombatPage,
	"FOV Circle",
	"Actual circular targeting radius",
	25,
	600,
	150,
	function(value)
		CombatSettings.FOV = value
		UpdateFOVCircle()
	end
)

CreateSlider(
	CombatPage,
	"Smoothing",
	"0 = snap, 1 = slow",
	0,
	1,
	0,
	function(value)
		CombatSettings.Smoothing = value
	end
)

CreateSection(
	CombatPage,
	"CHECKS",
	"Target validation"
)

CreateToggle(
	CombatPage,
	"Team Check",
	"Ignore teammates",
	true,
	function(state)
		CombatSettings.TeamCheck = state
	end,
	"Team Check"
)

CreateToggle(
	CombatPage,
	"Visibility Check",
	"Only target visible characters",
	true,
	function(state)
		CombatSettings.VisibilityCheck = state
	end,
	"Visibility Check"
)

CreateToggle(
	CombatPage,
	"Recoil Control",
	"Compensate for camera recoil",
	false,
	function(state)
		CombatSettings.RecoilControl = state
	end,
	"Recoil Control"
)

CreateSection(
	CombatPage,
	"FIRING",
	"Automated firing controls"
)

CreateToggle(
	CombatPage,
	"Triggerbot",
	"Fire when a valid target is directly under the crosshair",
	false,
	function(state)
		CombatSettings.Triggerbot = state
	end,
	"Triggerbot"
)

CreateToggle(
	CombatPage,
	"Auto Shoot",
	"Automatically activate the equipped tool on a target",
	false,
	function(state)
		CombatSettings.AutoShoot = state
	end,
	"Auto Shoot"
)

CreateToggle(
	CombatPage,
	"Hitbox Expansion",
	"Expand target head hitboxes",
	false,
	function(state)
		CombatSettings.HitboxExpansion = state

		if state then
			ApplyHitboxExpansion()
		else
			RestoreHitboxes()
		end
	end,
	"Hitbox Expansion"
)

--==================================================
-- MISC PAGE
--==================================================

CreateSection(
	MiscPage,
	"INFORMATION",
	"Session and debugging displays"
)

CreateToggle(
	MiscPage,
	"FPS Display",
	"Show current frame rate",
	false,
	function(state)
		ShowFPS = state

		InfoGui.Visible =
			ShowFPS
			or ShowServer
			or ShowPlayer
			or ShowSession
	end,
	"FPS Display"
)

CreateToggle(
	MiscPage,
	"Server Information",
	"Show place, server and player count",
	false,
	function(state)
		ShowServer = state

		InfoGui.Visible =
			ShowFPS
			or ShowServer
			or ShowPlayer
			or ShowSession
	end,
	"Server Information"
)

CreateToggle(
	MiscPage,
	"Player Information",
	"Show your Roblox account information",
	false,
	function(state)
		ShowPlayer = state

		InfoGui.Visible =
			ShowFPS
			or ShowServer
			or ShowPlayer
			or ShowSession
	end,
	"Player Information"
)

CreateToggle(
	MiscPage,
	"Session Statistics",
	"Show current session time",
	false,
	function(state)
		ShowSession = state

		InfoGui.Visible =
			ShowFPS
			or ShowServer
			or ShowPlayer
			or ShowSession
	end,
	"Session Statistics"
)

CreateButton(
	MiscPage,
	"Test Notification",
	"Check the notification system",
	"TEST",
	function()
		Notify(
			"FLAREHOOK",
			"Notification system is working."
		)
	end
)

CreateButton(
	MiscPage,
	"Refresh Visuals",
	"Rebuild all player visual objects",
	"REFRESH",
	function()
		RefreshVisuals()
		Notify(
			"VISUALS",
			"Player visuals refreshed."
		)
	end
)

--==================================================
-- SETTINGS PAGE
--==================================================

CreateSection(
	SettingsPage,
	"UI",
	"Interface controls"
)

CreateToggle(
	SettingsPage,
	"UI Visible",
	"Show or hide the main interface",
	true,
	function(state)
		if not state then
			MainFrame.Visible = false
		else
			MainFrame.Visible = true
		end
	end
)

CreateToggle(
	SettingsPage,
	"Status Display",
	"Show active feature status",
	true,
	function(state)
		StatusGui.Visible = state
	end
)

CreateButton(
	SettingsPage,
	"Reset UI Position",
	"Move FLAREHOOK back to the center",
	"RESET",
	function()
		MainFrame.Position = UDim2.new(
			0.5,
			-410,
			0.5,
			-260
		)
	end
)

CreateSection(
	SettingsPage,
	"KEYBINDS",
	"Keyboard shortcuts"
)

CreateButton(
	SettingsPage,
	"Toggle Menu",
	"Default key: RightShift",
	"RIGHTSHIFT",
	function()
		MainFrame.Visible = not MainFrame.Visible
	end
)

--==================================================
-- CREDITS PAGE
--==================================================

CreateSection(
	CreditsPage,
	"FLAREHOOK",
	"Interface information"
)

CreateButton(
	CreditsPage,
	"Version",
	"Current FLAREHOOK version",
	VERSION,
	function() end
)

CreateButton(
	CreditsPage,
	"Interface",
	"Red / black square UI",
	"FLAREHOOK",
	function() end
)

CreateButton(
	CreditsPage,
	"Logo",
	"Configured logo decal",
	"1688841862",
	function() end
)

CreateSection(
	CreditsPage,
	"AUTHORS",
	"Project credits"
)

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, -4, 0, 70)
CreditLabel.BackgroundColor3 = Theme.Panel
CreditLabel.BorderSizePixel = 0
CreditLabel.Text =
	"FLAREHOOK\n\n"
	.. "Custom Roblox UI / systems\n"
	.. "Version " .. VERSION
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextSize = 11
CreditLabel.TextColor3 = Theme.Text
CreditLabel.TextWrapped = true
CreditLabel.Parent = CreditsPage
AddCorner(CreditLabel, 4)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = MainFrame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		MainFrame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

--==================================================
-- RIGHT SHIFT MENU
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

--==================================================
-- COMBAT LOOP
--==================================================

local lastShot = 0
local shotDelay = 0.08

RunService.RenderStepped:Connect(function()
	if not ScriptEnabled then
		return
	end

	--=========================
	-- AIM
	--=========================

	if CombatSettings.Aimbot
		or CombatSettings.AimAssist then

		local target = GetTarget()

		if target then
			if CombatSettings.TargetLock then
				LockedTarget = target
			end

			if CombatSettings.Aimbot then
				-- Smoothing:
				-- 0.0 = instant snap
				-- 1.0 = slow movement
				--
				-- Keeps a small amount of movement at 1
				-- instead of completely stopping.

				local smoothing = CombatSettings.Smoothing

				local strength =
					1 - (smoothing * 0.90)

				AimAtTarget(
					target,
					strength
				)

			elseif CombatSettings.AimAssist then
				-- Aim Assist is intentionally softer than
				-- even the slowest Aimbot setting.

				AimAtTarget(
					target,
					0.30
				)
			end
		end
	end

	--=========================
	-- TRIGGERBOT
	--=========================

	if CombatSettings.Triggerbot then
		local target = TargetUnderCrosshair()

		if target then
			local now = os.clock()

			if now - lastShot >= shotDelay then
				lastShot = now
				ActivateTool()
			end
		end
	end

	--=========================
	-- AUTO SHOOT
	--=========================

	if CombatSettings.AutoShoot then
		local target = GetTarget()

		if target then
			local now = os.clock()

			if now - lastShot >= shotDelay then
				lastShot = now
				ActivateTool()
			end
		end
	end

	--=========================
	-- HITBOXES
	--=========================

	if CombatSettings.HitboxExpansion then
		ApplyHitboxExpansion()
	end

	UpdateVisualObjects()
	UpdateStatus()
	UpdateFOVCircle()
end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.75)

	ApplyMovement()

	if FeatureControls["Character Visibility"] then
		SetCharacterVisible(
			FeatureControls["Character Visibility"].Get()
		)
	end

	if FeatureControls["Movement"]
		and not FeatureControls["Movement"].Get() then

		SetMovement(false)
	end

	if CombatSettings.HitboxExpansion then
		ApplyHitboxExpansion()
	end
end)

--==================================================
-- INITIALIZATION
--==================================================

SelectTab("Main")
ApplyMovement()
UpdateCrosshair()
UpdateFOVCircle()
RefreshVisuals()
UpdateStatus()

Notify(
	"FLAREHOOK",
	"Loaded successfully • v" .. VERSION
)

--==================================================
-- FINAL UI SCALE
--==================================================

-- Approximately 90% visual scale while retaining
-- readable controls.
MainFrame.Size = UDim2.fromOffset(738, 468)
MainFrame.Position = UDim2.new(
	0.5,
	-369,
	0.5,
	-234
)

-- Recalculate sidebar/content sizes for scaled UI.
Sidebar.Size = UDim2.fromOffset(162, 410)
Content.Size = UDim2.new(1, -162, 1, -58)
Content.Position = UDim2.fromOffset(162, 58)

SelectTab("Main")
UpdateCrosshair()
UpdateFOVCircle()
