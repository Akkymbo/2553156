local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end)

local char, hum, root
local function bindChar(c)
	if not c then return end
	char = c
	local ok1, ok2 = c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
	if ok1 and ok2 then hum, root = ok1, ok2 end
end
task.spawn(function() if LP.Character then bindChar(LP.Character) end end)
LP.CharacterAdded:Connect(bindChar)

local Keybinds = {
	ToggleGUI   = Enum.KeyCode.Insert,
	ClickTP     = nil,
	Noclip      = nil,
	Fly         = Enum.KeyCode.X,
	InfJump     = nil,
	SpeedToggle = nil,
}

local fogData = {
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	FogColor = Lighting.FogColor,
	Atmospheres = {},
}
local fogConns = {}

local Config = {
	FlySpeed    = 50,
	SpeedValue  = 50,
	ESP         = false,
	ESPHighlight = false,
	Fly         = false,
	Noclip      = false,
	InfJump     = false,
	SpeedToggle = false,
	ClickTP     = true,
	NoFog       = false,
	EnemyColor  = Color3.fromRGB(255, 0, 0),
	AllyColor   = Color3.fromRGB(0, 255, 0),
}

local Theme = {
	Bg      = Color3.fromRGB(13, 13, 20),
	Header  = Color3.fromRGB(18, 18, 30),
	TabBar  = Color3.fromRGB(16, 16, 26),
	Card    = Color3.fromRGB(20, 20, 32),
	CardAlt = Color3.fromRGB(24, 24, 38),
	Accent  = Color3.fromRGB(80, 70, 180),
	AText   = Color3.fromRGB(110, 100, 220),
	Text    = Color3.fromRGB(200, 200, 220),
	TDim    = Color3.fromRGB(130, 130, 160),
	TBright = Color3.fromRGB(230, 230, 255),
	Danger  = Color3.fromRGB(200, 50, 50),
	Green   = Color3.fromRGB(60, 180, 80),
	Border  = Color3.fromRGB(35, 35, 50),
}

local gui = Instance.new("ScreenGui")
gui.Name = "U" .. HttpService:GenerateGUID(false):sub(1, 5)
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 540, 0, 560)
frame.Position = UDim2.new(0.5, -270, 0.5, -280)
frame.BackgroundColor3 = Theme.Bg
frame.BorderSizePixel = 0
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Theme.Border; frameStroke.Thickness = 1

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Active = true
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local dragging, dragS, dragP
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragS = UIS:GetMouseLocation(); dragP = frame.Position
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = UIS:GetMouseLocation() - dragS
		frame.Position = UDim2.new(dragP.X.Scale, dragP.X.Offset + d.X, dragP.Y.Scale, dragP.Y.Offset + d.Y)
	end
end)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.Text = "Universe O Guryx'd"
title.TextColor3 = Theme.TBright
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold; title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left

local closeB = Instance.new("TextButton", header)
closeB.Size = UDim2.new(0, 36, 0, 36)
closeB.Position = UDim2.new(1, -44, 0.5, -18)
closeB.Text = "X"; closeB.TextColor3 = Theme.TDim
closeB.BackgroundColor3 = Theme.CardAlt
closeB.Font = Enum.Font.GothamBold; closeB.TextSize = 14
closeB.BorderSizePixel = 0; closeB.AutoButtonColor = false
Instance.new("UICorner", closeB).CornerRadius = UDim.new(0, 8)
closeB.MouseButton1Click:Connect(function() gui.Enabled = false end)

local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 48)
tabBar.BackgroundColor3 = Theme.TabBar; tabBar.BorderSizePixel = 0

local tabNames = {"Movement", "Visual", "Players"}
local tabs, activeTab = {}, "Movement"
local scrollingFrame, contentArea

contentArea = Instance.new("Frame", frame)
contentArea.Size = UDim2.new(1, 0, 1, -88)
contentArea.Position = UDim2.new(0, 0, 0, 88)
contentArea.BackgroundColor3 = Theme.Bg
contentArea.BorderSizePixel = 0

scrollingFrame = Instance.new("ScrollingFrame", contentArea)
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.ScrollBarImageColor3 = Theme.Card
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
local sList = Instance.new("UIListLayout", scrollingFrame)
sList.Padding = UDim.new(0, 4); sList.HorizontalAlignment = Enum.HorizontalAlignment.Center
sList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", scrollingFrame).PaddingTop = UDim.new(0, 6)

local nGui = Instance.new("ScreenGui")
nGui.Name = "N" .. HttpService:GenerateGUID(false):sub(1, 4)
nGui.ResetOnSpawn = false; nGui.Parent = LP:WaitForChild("PlayerGui")

local nFrame = Instance.new("Frame", nGui)
nFrame.Size = UDim2.new(0, 320, 0, 0)
nFrame.Position = UDim2.new(1, -340, 0, 50)
nFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", nFrame).Padding = UDim.new(0, 6)

local function Notify(txt, col)
	col = col or Theme.Green
	local n = Instance.new("Frame", nFrame)
	n.Size = UDim2.new(1, 0, 0, 40)
	n.BackgroundColor3 = Theme.Card; n.BorderSizePixel = 0; n.ClipsDescendants = true
	Instance.new("UICorner", n).CornerRadius = UDim.new(0, 6)
	local s = Instance.new("UIStroke", n); s.Color = Theme.Border; s.Thickness = 1
	local bar = Instance.new("Frame", n)
	bar.Size = UDim2.new(0, 3, 1, 0); bar.BackgroundColor3 = col; bar.BorderSizePixel = 0
	local l = Instance.new("TextLabel", n)
	l.Size = UDim2.new(1, -18, 1, 0); l.Position = UDim2.new(0, 18, 0, 0)
	l.Text = txt; l.TextColor3 = Theme.Text; l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham; l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	task.spawn(function()
		task.wait(3)
		TweenService:Create(n, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		task.wait(0.4); n:Destroy()
	end)
end

local function ClearUI()
	for _, v in ipairs(scrollingFrame:GetChildren()) do
		if v:IsA("TextButton") or v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextBox") then v:Destroy() end
	end
end

local function Sec(t)
	local h = Instance.new("TextLabel", scrollingFrame)
	h.Size = UDim2.new(1, -8, 0, 28); h.Text = t
	h.TextColor3 = Theme.AText; h.BackgroundTransparency = 1
	h.Font = Enum.Font.GothamBold; h.TextSize = 14
	h.TextXAlignment = Enum.TextXAlignment.Left
end

local function Spacer(h)
	Instance.new("Frame", scrollingFrame).Size = UDim2.new(1, 0, 0, h or 4)
end

local function Toggle(text, state, cb)
	if type(state) == "function" then cb = state; state = false end
	local c = Instance.new("Frame", scrollingFrame)
	c.Size = UDim2.new(1, -4, 0, 38)
	c.BackgroundColor3 = Theme.Card; c.BorderSizePixel = 0
	Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
	local ind = Instance.new("Frame", c)
	ind.Size = UDim2.new(0, 3, 0, 0); ind.BackgroundColor3 = Theme.TDim; ind.BorderSizePixel = 0
	Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)
	local l = Instance.new("TextLabel", c)
	l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 16, 0, 0)
	l.Text = text; l.TextColor3 = Theme.Text; l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham; l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left
	local b = Instance.new("TextButton", c)
	b.Size = UDim2.new(0, 48, 0, 24); b.Position = UDim2.new(1, -58, 0.5, -12)
	b.BackgroundColor3 = Theme.CardAlt; b.Text = state and "ON" or "OFF"
	b.TextColor3 = state and Theme.Green or Theme.Danger
	b.Font = Enum.Font.GothamBold; b.TextSize = 11
	b.BorderSizePixel = 0; b.AutoButtonColor = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	if state then b.BackgroundColor3 = Color3.fromRGB(25, 50, 30); ind.Size = UDim2.new(0, 3, 0, 38); ind.BackgroundColor3 = Theme.Green end
	b.MouseButton1Click:Connect(function()
		state = not state
		if state then
			b.BackgroundColor3 = Color3.fromRGB(25, 50, 30); b.TextColor3 = Theme.Green; b.Text = "ON"
			ind.Size = UDim2.new(0, 3, 0, 38); ind.BackgroundColor3 = Theme.Green
		else
			b.BackgroundColor3 = Theme.CardAlt; b.TextColor3 = Theme.Danger; b.Text = "OFF"
			ind.Size = UDim2.new(0, 3, 0, 0); ind.BackgroundColor3 = Theme.TDim
		end
		pcall(cb, state)
	end)
	return c, function() return state end
end

local function Slider(text, min, max, default, cb, suf)
	suf = suf or ""
	local c = Instance.new("Frame", scrollingFrame)
	c.Size = UDim2.new(1, -4, 0, 56)
	c.BackgroundColor3 = Theme.Card; c.BorderSizePixel = 0; c.ClipsDescendants = true
	Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
	local l = Instance.new("TextLabel", c)
	l.Size = UDim2.new(0.5, -10, 0, 20); l.Position = UDim2.new(0, 14, 0, 6)
	l.Text = text
	l.TextColor3 = Theme.Text; l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
	local inp = Instance.new("TextBox", c)
	inp.Size = UDim2.new(0, 60, 0, 22); inp.Position = UDim2.new(0.5, -4, 0, 5)
	inp.BackgroundColor3 = Theme.CardAlt; inp.BorderSizePixel = 0
	inp.TextColor3 = Theme.TBright; inp.Font = Enum.Font.GothamBold; inp.TextSize = 13
	inp.Text = tostring(default)
	inp.ClearTextOnFocus = true
	Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 5)
	local val = default
	local bg = Instance.new("Frame", c)
	bg.Size = UDim2.new(1, -28, 0, 6); bg.Position = UDim2.new(0, 14, 0, 34)
	bg.BackgroundColor3 = Theme.CardAlt; bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)
	local fill = Instance.new("Frame", bg)
	fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
	inp.FocusLost:Connect(function(entered)
		if not entered then return end
		local n = tonumber(inp.Text)
		if n then
			val = math.clamp(n, min, max)
			if math.floor(max - min) > 0 then val = math.floor(val) end
			inp.Text = tostring(val)
			fill.Size = UDim2.new((val - min) / math.max(max - min, 1), 0, 1, 0)
			pcall(cb, val)
		else
			inp.Text = tostring(val)
		end
	end)
	local drag = Instance.new("TextButton", c)
	drag.Size = UDim2.new(1, 0, 1, -28); drag.Position = UDim2.new(0, 0, 0, 28); drag.BackgroundTransparency = 1; drag.Text = ""; drag.BorderSizePixel = 0
	drag.MouseButton1Down:Connect(function()
		local c1 = UIS.InputChanged:Connect(function(inp2)
			if inp2.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local pos = UIS:GetMouseLocation()
			local ax = bg.AbsolutePosition.X; local sx = bg.AbsoluteSize.X
			if sx <= 0 then return end
			local r = math.min(math.max((pos.X - ax) / sx, 0), 1)
			val = min + (max - min) * r
			if math.floor(max - min) > 0 then val = math.floor(val) end
			fill.Size = UDim2.new(r, 0, 1, 0)
			inp.Text = tostring(val)
			pcall(cb, val)
		end)
		local c2 = UIS.InputEnded:Connect(function(inp2)
			if inp2.UserInputType == Enum.UserInputType.MouseButton1 then c1:Disconnect(); c2:Disconnect() end
		end)
	end)
end

local function ColorPicker(text, default, cb)
	local c = Instance.new("Frame", scrollingFrame)
	c.Size = UDim2.new(1, -4, 0, 38)
	c.BackgroundColor3 = Theme.Card; c.BorderSizePixel = 0
	Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
	local l = Instance.new("TextLabel", c)
	l.Size = UDim2.new(1, -55, 1, 0); l.Position = UDim2.new(0, 16, 0, 0)
	l.Text = text; l.TextColor3 = Theme.Text; l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
	local box = Instance.new("Frame", c)
	box.Size = UDim2.new(0, 30, 0, 22); box.Position = UDim2.new(1, -42, 0.5, -11)
	box.BackgroundColor3 = default; box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
	local b = Instance.new("TextButton", box)
	b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Text = ""; b.BorderSizePixel = 0
	local cur = default

	local picker = Instance.new("Frame", gui)
	picker.Size = UDim2.new(0, 220, 0, 240)
	picker.Position = UDim2.new(0.5, -110, 0.5, -120)
	picker.BackgroundColor3 = Theme.Bg
	picker.BorderSizePixel = 0
	picker.Visible = false; picker.ZIndex = 100
	Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)
	local pS = Instance.new("UIStroke", picker); pS.Color = Theme.Border; pS.Thickness = 1

	local hueBar = Instance.new("Frame", picker)
	hueBar.Size = UDim2.new(0, 200, 0, 16)
	hueBar.Position = UDim2.new(0.5, -100, 0, 10)
	hueBar.BackgroundColor3 = Color3.new(1, 0, 0); hueBar.BorderSizePixel = 0; hueBar.ZIndex = 100
	Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 4)

	local sqFrame = Instance.new("Frame", picker)
	sqFrame.Size = UDim2.new(0, 180, 0, 180)
	sqFrame.Position = UDim2.new(0.5, -90, 0, 34)
	sqFrame.BackgroundColor3 = Color3.new(1, 0, 0); sqFrame.BorderSizePixel = 0; sqFrame.ZIndex = 100
	Instance.new("UICorner", sqFrame).CornerRadius = UDim.new(0, 4)

	local wGrad = Instance.new("Frame", sqFrame)
	wGrad.Size = UDim2.new(1, 0, 1, 0); wGrad.BackgroundColor3 = Color3.new(1, 1, 1)
	wGrad.BorderSizePixel = 0; wGrad.ZIndex = 101
	local wUIG = Instance.new("UIGradient", wGrad)
	wUIG.Rotation = 180
	wUIG.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
	wUIG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})

	local bGrad = Instance.new("Frame", sqFrame)
	bGrad.Size = UDim2.new(1, 0, 1, 0); bGrad.BackgroundTransparency = 1
	bGrad.BorderSizePixel = 0; bGrad.ZIndex = 102
	local bUIG = Instance.new("UIGradient", bGrad)
	bUIG.Rotation = 90
	bUIG.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
	bUIG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})

	local cursor = Instance.new("Frame", sqFrame)
	cursor.Size = UDim2.new(0, 10, 0, 10)
	cursor.BackgroundColor3 = Color3.new(1, 1, 1)
	cursor.BorderColor3 = Color3.new(0, 0, 0); cursor.ZIndex = 103
	Instance.new("UICorner", cursor).CornerRadius = UDim.new(1, 0)

	local apply = Instance.new("TextButton", picker)
	apply.Size = UDim2.new(0, 80, 0, 24)
	apply.Position = UDim2.new(0.5, -40, 1, -32)
	apply.Text = "Apply"; apply.TextColor3 = Theme.TBright
	apply.BackgroundColor3 = Theme.Accent; apply.BorderSizePixel = 0; apply.AutoButtonColor = false
	apply.Font = Enum.Font.GothamBold; apply.TextSize = 13; apply.ZIndex = 101
	Instance.new("UICorner", apply).CornerRadius = UDim.new(0, 6)

	local curH, curS, curV = 0, 1, 1
	b.MouseButton1Click:Connect(function()
		picker.Visible = not picker.Visible
	end)

	sqFrame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local c1 = UIS.InputChanged:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local m = UIS:GetMouseLocation()
			local aPos = sqFrame.AbsolutePosition; local aSize = sqFrame.AbsoluteSize
			local rx = math.clamp((m.X - aPos.X) / aSize.X, 0, 1)
			local ry = math.clamp((m.Y - aPos.Y) / aSize.Y, 0, 1)
			curS = rx; curV = 1 - ry
			cursor.Position = UDim2.new(curS, -5, 1 - curV, -5)
			cur = Color3.fromHSV(curH, curS, curV)
			box.BackgroundColor3 = cur
			pcall(cb, cur)
		end)
		local c2 = UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then c1:Disconnect(); c2:Disconnect() end
		end)
	end)

	local hueSlider, hueFill
	do
		local hc = Instance.new("Frame", picker)
		hc.Size = UDim2.new(0, 200, 0, 16)
		hc.Position = UDim2.new(0.5, -100, 0, 10)
		hc.BackgroundColor3 = Color3.new(1, 0, 0); hc.BorderSizePixel = 0; hc.ZIndex = 101
		hc.BackgroundTransparency = 1
		for i = 0, 360, 15 do
			local seg = Instance.new("Frame", hc)
			seg.Size = UDim2.new(0, 8, 1, 0)
			seg.Position = UDim2.new(0, 2 + (i / 360) * 196, 0, 0)
			seg.BackgroundColor3 = Color3.fromHSV(i / 360, 1, 1)
			seg.BorderSizePixel = 0; seg.ZIndex = 102
		end
		hueBar = hc

		hueBar.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			local c1 = UIS.InputChanged:Connect(function(inp)
				if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
				local m = UIS:GetMouseLocation()
				local aPos = hueBar.AbsolutePosition; local aSize = hueBar.AbsoluteSize
				if aSize.X <= 0 then return end
				curH = math.clamp((m.X - aPos.X) / aSize.X, 0, 1)
				sqFrame.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
				cur = Color3.fromHSV(curH, curS, curV)
				box.BackgroundColor3 = cur
				pcall(cb, cur)
			end)
			local c2 = UIS.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then c1:Disconnect(); c2:Disconnect() end
			end)
		end)
	end

	apply.MouseButton1Click:Connect(function()
		cur = Color3.fromHSV(curH, curS, curV)
		box.BackgroundColor3 = cur
		pcall(cb, cur)
		picker.Visible = false
	end)
end

local function TabBtn(name, x)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0, 180, 1, 0); b.Position = UDim2.new(0, x, 0, 0)
	b.Text = name; b.TextColor3 = Theme.TDim; b.BackgroundColor3 = Theme.TabBar
	b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.BorderSizePixel = 0; b.AutoButtonColor = false
	local ul = Instance.new("Frame", b)
	ul.Size = UDim2.new(1, 0, 0, 2); ul.Position = UDim2.new(0, 0, 1, -2)
	ul.BackgroundColor3 = Theme.Accent; ul.BorderSizePixel = 0; ul.BackgroundTransparency = 1
	tabs[name] = {b = b, ul = ul}
	b.MouseButton1Click:Connect(function()
		activeTab = name
		for _, t in pairs(tabs) do t.b.TextColor3 = Theme.TDim; t.b.BackgroundColor3 = Theme.TabBar; t.ul.BackgroundTransparency = 1 end
		b.TextColor3 = Theme.TBright; b.BackgroundColor3 = Theme.Card; ul.BackgroundTransparency = 0
		RebuildUI()
	end)
end

for i, n in ipairs(tabNames) do TabBtn(n, (i - 1) * 180) end
tabs[activeTab].b.TextColor3 = Theme.TBright
tabs[activeTab].b.BackgroundColor3 = Theme.Card
tabs[activeTab].ul.BackgroundTransparency = 0

function RebuildUI()
	ClearUI()

	if activeTab == "Movement" then
		Sec("Fly")
		Toggle("Fly", Config.Fly, function(v) Config.Fly = v; Notify("Fly: " .. (v and "ON" or "OFF")) end)
		Slider("Fly Speed", 10, 500, Config.FlySpeed, function(v) Config.FlySpeed = v end)
		Spacer(4)
		Toggle("Noclip", Config.Noclip, function(v) Config.Noclip = v; Notify("Noclip: " .. (v and "ON" or "OFF")) end)
		Toggle("Infinite Jump", Config.InfJump, function(v) Config.InfJump = v; Notify("Inf. Jump: " .. (v and "ON" or "OFF")) end)
		Spacer(4)
		Sec("Speed")
		Toggle("Speed", Config.SpeedToggle, function(v) Config.SpeedToggle = v; Notify("Speed: " .. (v and "ON" or "OFF")) end)
		Slider("Speed Value", 16, 200, Config.SpeedValue, function(v) Config.SpeedValue = v end)
		Spacer(4)
		Sec("Teleport")
		Toggle("Click TP", Config.ClickTP, function(v) Config.ClickTP = v; Notify("Click TP: " .. (v and "ON" or "OFF")) end)
		Spacer(4)
		Sec("Keybinds")
		local bindNames = {"ToggleGUI","ClickTP","Noclip","Fly","InfJump","SpeedToggle"}
		local bindLabels = {"Toggle GUI","Click TP","Noclip","Fly","Inf Jump","Speed"}
		for i, name in ipairs(bindNames) do
			local cur = Keybinds[name] and Keybinds[name].Name or "none"
			local c = Instance.new("Frame", scrollingFrame)
			c.Size = UDim2.new(1, -4, 0, 32)
			c.BackgroundColor3 = Theme.Card; c.BorderSizePixel = 0
			Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
			local l = Instance.new("TextLabel", c)
			l.Size = UDim2.new(0.5, -10, 1, 0); l.Position = UDim2.new(0, 12, 0, 0)
			l.Text = bindLabels[i]; l.TextColor3 = Theme.Text; l.BackgroundTransparency = 1
			l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
			local btn = Instance.new("TextButton", c)
			btn.Size = UDim2.new(0.5, -10, 0, 24); btn.Position = UDim2.new(0.5, 4, 0.5, -12)
			btn.Text = cur; btn.TextColor3 = Theme.TBright
			btn.BackgroundColor3 = Theme.CardAlt; btn.BorderSizePixel = 0; btn.AutoButtonColor = false
			btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			btn.MouseButton1Click:Connect(function()
				btn.Text = "..."; btn.TextColor3 = Theme.Accent
				local conn
				conn = UIS.InputBegan:Connect(function(inp, gp)
					if gp then return end
					if inp.UserInputType == Enum.UserInputType.Keyboard then
						Keybinds[name] = inp.KeyCode
						btn.Text = inp.KeyCode.Name
						btn.TextColor3 = Theme.TBright
						conn:Disconnect()
					elseif inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 then
						Keybinds[name] = inp.KeyCode
						btn.Text = inp.KeyCode.Name
						btn.TextColor3 = Theme.TBright
						conn:Disconnect()
					end
				end)
			end)
		end

	elseif activeTab == "Visual" then
		Toggle("ESP", Config.ESP, function(v) Config.ESP = v; Notify("ESP: " .. (v and "ON" or "OFF")) end)
		Toggle("ESP Highlight", Config.ESPHighlight, function(v) Config.ESPHighlight = v; Notify("Chams: " .. (v and "ON" or "OFF")) end)
		Toggle("NoFog", Config.NoFog, function(v)
			Config.NoFog = v
			if v then
				fogData.FogEnd = Lighting.FogEnd
				fogData.FogStart = Lighting.FogStart
				fogData.FogColor = Lighting.FogColor
				fogData.Atmospheres = {}
				for _, at in ipairs(Lighting:GetDescendants()) do
					if at:IsA("Atmosphere") then
						table.insert(fogData.Atmospheres, {obj = at, den = at.Density})
						at:Destroy()
					end
				end
				Lighting.FogEnd = 100000
				Lighting.FogStart = 99998
				fogConns.fogEnd = Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
					Lighting.FogEnd = 100000
				end)
				fogConns.fogStart = Lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
					Lighting.FogStart = 99998
				end)
				fogConns.descAdded = Lighting.DescendantAdded:Connect(function(child)
					task.wait(0.1)
					if child:IsA("Atmosphere") then
						table.insert(fogData.Atmospheres, {obj = child, den = child.Density})
						child:Destroy()
					end
				end)
			else
				for _, conn in pairs(fogConns) do
					pcall(conn.Disconnect, conn)
				end
				fogConns = {}
				Lighting.FogEnd = fogData.FogEnd
				Lighting.FogStart = fogData.FogStart
				Lighting.FogColor = fogData.FogColor
				for _, data in ipairs(fogData.Atmospheres) do
					local at = data.obj
					if at and at.Parent == nil then
						local clone = at:Clone()
						clone.Density = data.den
						clone.Parent = Lighting
					end
				end
				fogData.Atmospheres = {}
			end
			Notify("NoFog: " .. (v and "ON" or "OFF"))
		end)
		ColorPicker("Enemy Color", Config.EnemyColor, function(v) Config.EnemyColor = v end)
		ColorPicker("Ally Color", Config.AllyColor, function(v) Config.AllyColor = v end)

	elseif activeTab == "Players" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p == LP then continue end
			local b = Instance.new("TextButton", scrollingFrame)
			b.Size = UDim2.new(1, -4, 0, 30)
			b.Text = p.Name .. " [" .. p.DisplayName .. "]"
			b.TextColor3 = Theme.Text
			b.BackgroundColor3 = Theme.Card
			b.Font = Enum.Font.Gotham
			b.TextSize = 12
			b.BorderSizePixel = 0
			b.AutoButtonColor = false
			b.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.MouseButton1Click:Connect(function()
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and root then
					local target = p.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
					TweenService:Create(root, TweenInfo.new(0.3), {CFrame = CFrame.new(target)}):Play()
					Notify("TP to " .. p.DisplayName)
				end
			end)
		end
	end

	task.spawn(function()
		task.wait()
		local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
		if layout then
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
		end
	end)
end

task.spawn(RebuildUI)

local espObjs = {}
local espFld = Instance.new("Folder", CoreGui)
espFld.Name = "E" .. HttpService:GenerateGUID(false):sub(1, 4)

local function mkESP(p)
	if espObjs[p] then return end
	local bb = Instance.new("BillboardGui", espFld)
	bb.Name = p.Name; bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.ResetOnSpawn = false
	bb.Adornee = p.Character and p.Character:FindFirstChild("Head") or nil
	local nl = Instance.new("TextLabel", bb)
	nl.Size = UDim2.new(1, 0, 0, 24); nl.BackgroundTransparency = 1
	nl.Text = p.Name; nl.Font = Enum.Font.GothamBold; nl.TextSize = 14; nl.TextStrokeTransparency = 0.5
	nl.TextColor3 = p.Team == LP.Team and Config.AllyColor or Config.EnemyColor
	local hl = Instance.new("TextLabel", bb)
	hl.Size = UDim2.new(1, 0, 0, 20); hl.Position = UDim2.new(0, 0, 0, 22)
	hl.BackgroundTransparency = 1; hl.Font = Enum.Font.Gotham; hl.TextSize = 12; hl.TextStrokeTransparency = 0.5
	local hgl = Instance.new("Highlight", espFld)
	hgl.Name = "H" .. p.Name; hgl.FillTransparency = 0.5; hgl.OutlineTransparency = 0.3; hgl.Enabled = false
	espObjs[p] = {bb = bb, nl = nl, hl = hl, hgl = hgl}
end

local function rmESP(p)
	local o = espObjs[p]
	if o then o.bb:Destroy(); o.hgl:Destroy(); espObjs[p] = nil end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then mkESP(p) end end
Players.PlayerAdded:Connect(mkESP)
Players.PlayerRemoving:Connect(rmESP)

RunService.RenderStepped:Connect(function()
	for p, o in pairs(espObjs) do
		if p.Character and p.Character:FindFirstChild("Head") and root then
			local head = p.Character.Head
			local dist = math.floor((root.Position - head.Position).Magnitude)
			o.bb.Adornee = head
			local col = p.Team == LP.Team and Config.AllyColor or Config.EnemyColor
			o.nl.Text = p.Name .. " [" .. dist .. "m]"; o.nl.TextColor3 = col
			o.bb.Enabled = Config.ESP
			if hum then
				local pc = math.floor((hum.Health / hum.MaxHealth) * 100)
				o.hl.Text = "HP: " .. pc .. "%"
				o.hl.TextColor3 = pc > 50 and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(200, 50, 50)
			end
			if Config.ESPHighlight then
				o.hgl.Adornee = p.Character; o.hgl.Enabled = true
				o.hgl.FillColor = col; o.hgl.OutlineColor = col
			else o.hgl.Enabled = false end
		else o.bb.Enabled = false; o.hgl.Enabled = false end
	end

	if Config.Fly and root and Camera then
		local m = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then m = m + Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then m = m - Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then m = m - Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then m = m + Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then m = m + Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then m = m + Vector3.new(0, -1, 0) end
		if m.Magnitude > 0 then m = m.Unit * Config.FlySpeed end
		root.AssemblyLinearVelocity = m
	end
end)

RunService.Stepped:Connect(function()
	if Config.Noclip and char then
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if hum then hum.WalkSpeed = Config.SpeedToggle and Config.SpeedValue or 16 end
end)

UIS.JumpRequest:Connect(function()
	if Config.InfJump and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end

	if Keybinds.ToggleGUI and i.KeyCode == Keybinds.ToggleGUI then
		gui.Enabled = not gui.Enabled
	end

	if Keybinds.ClickTP and i.KeyCode == Keybinds.ClickTP and Config.ClickTP and root then
		local m = LP:GetMouse()
		if m and m.Hit then
			local pos = m.Hit.Position
			TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))}):Play()
			Notify("Teleported!")
		end
	end

	if Keybinds.Noclip and i.KeyCode == Keybinds.Noclip then
		Config.Noclip = not Config.Noclip; Notify("Noclip: " .. (Config.Noclip and "ON" or "OFF"))
	end

	if Keybinds.Fly and i.KeyCode == Keybinds.Fly then
		Config.Fly = not Config.Fly; Notify("Fly: " .. (Config.Fly and "ON" or "OFF"))
	end

	if Keybinds.InfJump and i.KeyCode == Keybinds.InfJump then
		Config.InfJump = not Config.InfJump; Notify("Inf. Jump: " .. (Config.InfJump and "ON" or "OFF"))
	end

	if Keybinds.SpeedToggle and i.KeyCode == Keybinds.SpeedToggle then
		Config.SpeedToggle = not Config.SpeedToggle; Notify("Speed: " .. (Config.SpeedToggle and "ON" or "OFF"))
	end
end)
