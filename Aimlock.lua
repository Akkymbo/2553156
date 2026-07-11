local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = UIS

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end)

local Settings = {
	Enabled = false,
	Smoothness = 0.3,
	FOV = 120,
	FOVVisible = true,
	FOVColor = Color3.fromRGB(255, 255, 255),
	FOVTransparency = 0.7,
	FOVThickness = 1,
	TargetPart = "Head",
	TeamCheck = true,
	VisibleCheck = true,
	MouseBind = true,
	Prediction = 0.15,
	AimSpeed = 360,
	Keybind = Enum.KeyCode.F1,
	GUIBind = Enum.KeyCode.Insert,
	LockTarget = false,
	Watermark = true,
}

local target = nil
local guiLib = nil

local Theme = {
	Bg = Color3.fromRGB(14, 14, 22),
	Card = Color3.fromRGB(20, 20, 32),
	CardAlt = Color3.fromRGB(26, 26, 40),
	Border = Color3.fromRGB(40, 40, 55),
	Accent = Color3.fromRGB(90, 75, 200),
	AccentDark = Color3.fromRGB(60, 50, 150),
	Text = Color3.fromRGB(200, 200, 220),
	TextBright = Color3.fromRGB(230, 230, 255),
	TextDim = Color3.fromRGB(130, 130, 160),
	Green = Color3.fromRGB(60, 200, 80),
	Danger = Color3.fromRGB(220, 60, 60),
}

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do obj[k] = v end
	return obj
end

local FOVGui = Create("ScreenGui", {
	Name = "FOV_" .. HttpService:GenerateGUID(false):sub(1, 4),
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
	Parent = LP:WaitForChild("PlayerGui"),
})

local FOVCircle = Create("Frame", {
	Name = "FOVCircle",
	Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2),
	Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 999,
	Parent = FOVGui,
})

Create("UICorner", {
	CornerRadius = UDim.new(1, 0),
	Parent = FOVCircle,
})

local FOVStroke = Create("UIStroke", {
	Color = Settings.FOVColor,
	Thickness = Settings.FOVThickness,
	Transparency = Settings.FOVTransparency,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	Parent = FOVCircle,
})

local WatermarkLabel
local creditHue = 0

local creditGui = Create("ScreenGui", {
	Name = "Credit_" .. HttpService:GenerateGUID(false):sub(1, 4),
	ResetOnSpawn = false,
	DisplayOrder = 9999,
	Parent = LP:WaitForChild("PlayerGui"),
})

local creditLabel = Create("TextLabel", {
	Size = UDim2.new(0, 150, 0, 24),
	Position = UDim2.new(1, -160, 1, -32),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
	Text = "By Github@Decairy",
	TextColor3 = Color3.new(1, 0, 0),
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 9999,
	Parent = creditGui,
})

Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = creditLabel})
Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1.5, Parent = creditLabel})

if Settings.Watermark then
	local wmGui = Create("ScreenGui", {
		Name = "WM_" .. HttpService:GenerateGUID(false):sub(1, 4),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LP:WaitForChild("PlayerGui"),
	})

	WatermarkLabel = Create("TextLabel", {
		Size = UDim2.new(0, 180, 0, 24),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Text = "Aimlock [OFF] | F1",
		TextColor3 = Theme.Danger,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 10,
	})

	local wmCorner = Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = WatermarkLabel})
	local wmStroke = Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = WatermarkLabel})

	WatermarkLabel.Parent = wmGui

	local padding = Create("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = WatermarkLabel})
end

local gui = Create("ScreenGui", {
	Name = "AL_" .. HttpService:GenerateGUID(false):sub(1, 5),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = LP:WaitForChild("PlayerGui"),
})

local frame = Create("Frame", {
	Size = UDim2.new(0, 340, 0, 420),
	Position = UDim2.new(0.5, -170, 0.5, -210),
	BackgroundColor3 = Theme.Bg,
	BorderSizePixel = 0,
	Active = true,
	Parent = gui,
})

Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = frame})

local header = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundColor3 = Theme.Card,
	BorderSizePixel = 0,
	Parent = frame,
})

Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = header})

local dragging, dragStart, framePos
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = UIS:GetMouseLocation(); framePos = frame.Position
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = UIS:GetMouseLocation() - dragStart
		frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)

Create("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.new(0, 14, 0, 0),
	Text = "Universe O Guryx'd (Aimlock)",
	TextColor3 = Theme.TextBright,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = header,
})

local closeBtn = Create("TextButton", {
	Size = UDim2.new(0, 30, 0, 30),
	Position = UDim2.new(1, -38, 0.5, -15),
	Text = "X",
	TextColor3 = Theme.TextDim,
	BackgroundColor3 = Theme.CardAlt,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = header,
})

Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = closeBtn})
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

local scrollFrame = Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -44),
	Position = UDim2.new(0, 0, 0, 44),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.CardAlt,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	Parent = frame,
})

local sList = Create("UIListLayout", {
	Padding = UDim.new(0, 4),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = scrollFrame,
})

Create("UIPadding", {PaddingTop = UDim.new(0, 6), Parent = scrollFrame})

local function Spacer(h)
	Create("Frame", {Size = UDim2.new(1, 0, 0, h or 4), BackgroundTransparency = 1, Parent = scrollFrame})
end

local function Section(text)
	Create("TextLabel", {
		Size = UDim2.new(1, -10, 0, 26),
		Text = text,
		TextColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = scrollFrame,
	})
end

local function Toggle(text, get, set)
	local state = get
	local card = Create("Frame", {
		Size = UDim2.new(1, -8, 0, 36),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = scrollFrame,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = card})

	local indicator = Create("Frame", {
		Size = UDim2.new(0, 3, 0, 0),
		BackgroundColor3 = Theme.TextDim,
		BorderSizePixel = 0,
		Parent = card,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = indicator})

	Create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		Text = text,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local btn = Create("TextButton", {
		Size = UDim2.new(0, 44, 0, 22),
		Position = UDim2.new(1, -52, 0.5, -11),
		Text = state and "ON" or "OFF",
		TextColor3 = state and Theme.Green or Theme.Danger,
		BackgroundColor3 = state and Color3.fromRGB(25, 50, 30) or Theme.CardAlt,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = card,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = btn})

	if state then indicator.Size = UDim2.new(0, 3, 0, 36); indicator.BackgroundColor3 = Theme.Green end

	btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(25, 50, 30)
			btn.TextColor3 = Theme.Green; btn.Text = "ON"
			indicator.Size = UDim2.new(0, 3, 0, 36)
			indicator.BackgroundColor3 = Theme.Green
		else
			btn.BackgroundColor3 = Theme.CardAlt
			btn.TextColor3 = Theme.Danger; btn.Text = "OFF"
			indicator.Size = UDim2.new(0, 3, 0, 0)
			indicator.BackgroundColor3 = Theme.TextDim
		end
		pcall(set, state)
	end)

	return card, function() return state end
end

local function Slider(text, min, max, default, callback, suffix)
	suffix = suffix or ""
	local val = default
	local card = Create("Frame", {
		Size = UDim2.new(1, -8, 0, 54),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = scrollFrame,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = card})

	Create("TextLabel", {
		Size = UDim2.new(0.5, -10, 0, 20),
		Position = UDim2.new(0, 12, 0, 6),
		Text = text,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local valueBox = Create("TextBox", {
		Size = UDim2.new(0, 56, 0, 20),
		Position = UDim2.new(0.5, -2, 0, 6),
		Text = tostring(val) .. suffix,
		TextColor3 = Theme.TextBright,
		BackgroundColor3 = Theme.CardAlt,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		ClearTextOnFocus = true,
		BorderSizePixel = 0,
		Parent = card,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = valueBox})

	local bgBar = Create("Frame", {
		Size = UDim2.new(1, -24, 0, 5),
		Position = UDim2.new(0, 12, 0, 34),
		BackgroundColor3 = Theme.CardAlt,
		BorderSizePixel = 0,
		Parent = card,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = bgBar})

	local fillBar = Create("Frame", {
		Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = bgBar,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = fillBar})

	valueBox.FocusLost:Connect(function(enter)
		if not enter then return end
		local n = tonumber(valueBox.Text)
		if n then
			val = math.clamp(n, min, max)
			valueBox.Text = tostring(val) .. suffix
			fillBar.Size = UDim2.new((val - min) / math.max(max - min, 1), 0, 1, 0)
			pcall(callback, val)
		else
			valueBox.Text = tostring(val) .. suffix
		end
	end)

	local dragBtn = Create("TextButton", {
		Size = UDim2.new(1, 0, 1, -28),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundTransparency = 1,
		Text = "",
		BorderSizePixel = 0,
		Parent = card,
	})

	dragBtn.MouseButton1Down:Connect(function()
		local connMove = UIS.InputChanged:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local mouse = UIS:GetMouseLocation()
			local ax = bgBar.AbsolutePosition.X
			local sx = bgBar.AbsoluteSize.X
			if sx <= 0 then return end
			local r = math.clamp((mouse.X - ax) / sx, 0, 1)
			val = min + (max - min) * r
			valueBox.Text = tostring(val) .. suffix
			fillBar.Size = UDim2.new(r, 0, 1, 0)
			pcall(callback, val)
		end)
		local connEnd = UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				connMove:Disconnect(); connEnd:Disconnect()
			end
		end)
	end)

	return card, function() return val end
end

local function Dropdown(text, options, default, callback)
	local selected = default or options[1]
	local card = Create("Frame", {
		Size = UDim2.new(1, -8, 0, 34),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = scrollFrame,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = card})

	Create("TextLabel", {
		Size = UDim2.new(0.5, -10, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Text = text,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local btn = Create("TextButton", {
		Size = UDim2.new(0.45, -4, 0, 24),
		Position = UDim2.new(0.55, -4, 0.5, -12),
		Text = selected,
		TextColor3 = Theme.TextBright,
		BackgroundColor3 = Theme.CardAlt,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = card,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = btn})

	btn.MouseButton1Click:Connect(function()
		local idx = 0
		for i, opt in ipairs(options) do
			if opt == selected then idx = i; break end
		end
		selected = options[idx % #options + 1]
		btn.Text = selected
		pcall(callback, selected)
	end)
end

local function KeybindPicker(text, default, callback)
	local key = default
	local card = Create("Frame", {
		Size = UDim2.new(1, -8, 0, 34),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = scrollFrame,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = card})

	Create("TextLabel", {
		Size = UDim2.new(0.5, -10, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Text = text,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local btn = Create("TextButton", {
		Size = UDim2.new(0.45, -4, 0, 24),
		Position = UDim2.new(0.55, -4, 0.5, -12),
		Text = key.Name,
		TextColor3 = Theme.TextBright,
		BackgroundColor3 = Theme.CardAlt,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = card,
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = btn})

	btn.MouseButton1Click:Connect(function()
		btn.Text = "..."
		btn.TextColor3 = Theme.Accent
		local conn = UIS.InputBegan:Connect(function(inp, gp)
			if gp then return end
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				key = inp.KeyCode
				btn.Text = key.Name
				btn.TextColor3 = Theme.TextBright
				conn:Disconnect()
				pcall(callback, key)
			end
		end)
	end)
end

Section("Aim Control")
Toggle("Aimlock", Settings.Enabled, function(v) Settings.Enabled = v end)
Slider("Smoothness", 0.0, 1, Settings.Smoothness, function(v) Settings.Smoothness = v end, "")
Slider("Aim Speed", 10, 360, Settings.AimSpeed, function(v) Settings.AimSpeed = v end, "")
Slider("Prediction", 0, 0.5, Settings.Prediction, function(v) Settings.Prediction = v end, "")
Spacer(4)

Section("Targeting")
Dropdown("Target Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Settings.TargetPart, function(v) Settings.TargetPart = v end)
Dropdown("FOV", {60, 90, 120, 150, 180, 200, 250, 300, 360, 500}, Settings.FOV, function(v)
	Settings.FOV = v
	FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
	FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
end)
Spacer(4)

Section("Checks")
Toggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
Toggle("Visible Check", Settings.VisibleCheck, function(v) Settings.VisibleCheck = v end)
Toggle("Lock Target", Settings.LockTarget, function(v) Settings.LockTarget = v end)
Spacer(4)

Section("Display")
Toggle("Show FOV", Settings.FOVVisible, function(v) Settings.FOVVisible = v; FOVCircle.Visible = v end)
Toggle("Watermark", Settings.Watermark, function(v)
	Settings.Watermark = v
	if WatermarkLabel then WatermarkLabel.Parent.Enabled = v end
end)
Spacer(4)

Section("Keybinds")
Toggle("Mouse M2 Toggle", Settings.MouseBind, function(v) Settings.MouseBind = v end)
KeybindPicker("Toggle Aimlock", Settings.Keybind, function(v) Settings.Keybind = v end)
KeybindPicker("Toggle Menu", Settings.GUIBind, function(v) Settings.GUIBind = v end)

Spacer(2)

local statusBar = Create("Frame", {
	Size = UDim2.new(1, -8, 0, 28),
	BackgroundColor3 = Theme.Card,
	BorderSizePixel = 0,
	Parent = scrollFrame,
})
Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = statusBar})

local statusLabel = Create("TextLabel", {
	Size = UDim2.new(1, -12, 1, 0),
	Position = UDim2.new(0, 8, 0, 0),
	Text = "Status: Aimlock OFF",
	TextColor3 = Theme.Danger,
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = statusBar,
})

task.spawn(function()
	task.wait()
	local layout = scrollFrame:FindFirstChildOfClass("UIListLayout")
	if layout then
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end
end)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if Settings.MouseBind and input.UserInputType == Enum.UserInputType.MouseButton2 then
		Settings.Enabled = true
	end

	if input.KeyCode == Settings.Keybind then
		Settings.Enabled = not Settings.Enabled
		if not Settings.Enabled then target = nil end
	end

	if input.KeyCode == Settings.GUIBind then
		gui.Enabled = not gui.Enabled
	end
end)

UIS.InputEnded:Connect(function(input)
	if Settings.MouseBind and input.UserInputType == Enum.UserInputType.MouseButton2 then
		Settings.Enabled = false
		target = nil
	end
end)

local function getClosestTarget()
	local closestPlayer = nil
	local closestDist = Settings.FOV
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LP then continue end
		if Settings.TeamCheck and player.Team == LP.Team then continue end

		local character = player.Character
		if not character then continue end
		if not character:FindFirstChild("HumanoidRootPart") then continue end

		local part = character:FindFirstChild(Settings.TargetPart) or character:FindFirstChild("HumanoidRootPart")
		if not part then continue end

		if Settings.VisibleCheck then
			local origin = Camera.CFrame.Position
			local direction = (part.Position - origin).Unit * 500
			local ray = Ray.new(origin, direction)
			local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, Camera})
			if hit and not hit:IsDescendantOf(character) then
				continue
			end
		end

		local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
		if not onScreen then continue end

		local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

		if dist < closestDist then
			closestDist = dist
			closestPlayer = player
		end
	end

	return closestPlayer
end

local function rotateCamera(targetPos)
	local currentLook = Camera.CFrame.LookVector
	local targetDir = (targetPos - Camera.CFrame.Position).Unit

	local angle = math.deg(math.acos(math.clamp(currentLook:Dot(targetDir), -1, 1)))
	if angle < 0.05 then return end

	local turnAngle = math.min(angle, Settings.AimSpeed)
	local smoothFactor = 1 - (Settings.Smoothness * 0.95)
	turnAngle = math.max(turnAngle * smoothFactor, 0.1)

	local axis = currentLook:Cross(targetDir)
	if axis.Magnitude > 0.001 then
		local newLook = (CFrame.fromAxisAngle(axis.Unit, math.rad(turnAngle)) * currentLook).Unit
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
	end
end

RunService:BindToRenderStep("AimlockMain", Enum.RenderPriority.Camera.Value, function()
	creditHue = (creditHue + 0.004) % 1
	creditLabel.TextColor3 = Color3.fromHSV(creditHue, 1, 1)

	FOVCircle.Visible = Settings.FOVVisible
	FOVStroke.Color = Settings.FOVColor
	FOVStroke.Transparency = Settings.FOVTransparency
	FOVStroke.Thickness = Settings.FOVThickness

	if not Settings.Enabled then
		target = nil
		if WatermarkLabel then
			WatermarkLabel.Text = "Aimlock [OFF] | " .. Settings.Keybind.Name
			WatermarkLabel.TextColor3 = Theme.Danger
		end
		statusLabel.Text = "Status: Aimlock OFF"
		statusLabel.TextColor3 = Theme.Danger
		return
	end

	if Settings.LockTarget and target then
		local character = target.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local part = character:FindFirstChild(Settings.TargetPart) or character:FindFirstChild("HumanoidRootPart")
			if part then
				local targetPos = part.Position + (part.Velocity * Settings.Prediction)
				rotateCamera(targetPos)
			end
		else
			target = nil
		end
	else
		local newTarget = getClosestTarget()
		if newTarget then
			target = newTarget
			local character = target.Character
			if character then
				local part = character:FindFirstChild(Settings.TargetPart) or character:FindFirstChild("HumanoidRootPart")
				if part then
					local targetPos = part.Position + (part.Velocity * Settings.Prediction)
					rotateCamera(targetPos)
				end
			end
		else
			target = nil
		end
	end

	if target then
		if WatermarkLabel then
			WatermarkLabel.Text = "Aimlock [ON] -> " .. target.DisplayName .. " | " .. Settings.Keybind.Name
			WatermarkLabel.TextColor3 = Theme.Green
		end
		statusLabel.Text = "Status: Locked -> " .. target.DisplayName
		statusLabel.TextColor3 = Theme.Green
	else
		if WatermarkLabel then
			WatermarkLabel.Text = "Aimlock [ON] | " .. Settings.Keybind.Name
			WatermarkLabel.TextColor3 = Theme.Text
		end
		statusLabel.Text = "Status: Aimlock ON - No Target"
		statusLabel.TextColor3 = Theme.Text
	end
end)
