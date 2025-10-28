local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ⚙️ CONFIG
local teleportDelay = 5
local teleportPoints = {
    Vector3.new(597, 269, 516),
    Vector3.new(-23477, 6347, -6886)
}

local isTeleporting = false
local teleportThread = nil
local antiGravityEnabled = false
local autoResetCheckpoint = false
local currentIndex = 1

-- ⚡ TELEPORT FUNCTION
local function teleportToPosition(position)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(position)
	end
end

-- 🧲 Anti Gravity
local function applyAntiGravity(enable)
	local character = player.Character
	if not character then return end
	local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRoot then return end

	if enable then
		if not humanoidRoot:FindFirstChild("AntiGrav") then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "AntiGrav"
			bv.MaxForce = Vector3.new(0, math.huge, 0)
			bv.Velocity = Vector3.new(0, 0.1, 0)
			bv.Parent = humanoidRoot

			local bg = Instance.new("BodyGyro")
			bg.MaxTorque = Vector3.new(400000, 400000, 400000)
			bg.P = 10000
			bg.CFrame = humanoidRoot.CFrame
			bg.Parent = humanoidRoot
		end
	else
		local bv = humanoidRoot:FindFirstChild("AntiGrav")
		if bv then bv:Destroy() end
		local bg = humanoidRoot:FindFirstChildOfClass("BodyGyro")
		if bg then bg:Destroy() end
	end
end

-- ⚡ LOOP TELEPORT (continuous)
local function startTeleportLoop(speedLabel, toggle)
	teleportThread = task.spawn(function()
		while isTeleporting do
			for i = currentIndex, #teleportPoints do
				if not isTeleporting then break end
				teleportToPosition(teleportPoints[i])
				currentIndex = i
				speedLabel.Text = ("Delay: %.1fs | Point %d/%d"):format(teleportDelay, i, #teleportPoints)
				task.wait(teleportDelay)

				-- 🧿 Auto reset checkpoint saat sampai titik terakhir
				if autoResetCheckpoint and i == #teleportPoints then
					task.wait(0.5)
					currentIndex = 1
					teleportToPosition(teleportPoints[currentIndex])
					speedLabel.Text = "🔁 Restarted to Checkpoint 1"
				end
			end
			currentIndex = 1
		end
	end)
end

-- 🌈 Gradient
local function createGradient(obj, color1, color2)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(color1, color2)
	g.Rotation = 90
	g.Parent = obj
end

-- 🌌 Teleporter UI
local function createTeleporterUI()
	if CoreGui:FindFirstChild("ZassXdTeleporter") then CoreGui.ZassXdTeleporter:Destroy() end
	local ui = Instance.new("ScreenGui", CoreGui)
	ui.Name = "ZassXdTeleporter"
	ui.ResetOnSpawn = false

	local frame = Instance.new("Frame", ui)
	frame.Size = UDim2.new(0,240,0,370)
	frame.Position = UDim2.new(0.77,0,0.75,0)
	frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
	frame.Active = true
	frame.Draggable = true
	createGradient(frame, Color3.fromRGB(0,255,255), Color3.fromRGB(0,100,255))
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

	local title = Instance.new("TextLabel", frame)
	title.Text = "🌀 MT LEMBAYANA"
	title.Size = UDim2.new(1,-10,0,25)
	title.Position = UDim2.new(0,8,0,5)
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.new(1,1,1)
	title.BackgroundTransparency = 1

	local close = Instance.new("TextButton", frame)
	close.Size = UDim2.new(0,25,0,25)
	close.Position = UDim2.new(1,-30,0,5)
	close.BackgroundColor3 = Color3.fromRGB(255,60,60)
	close.Text = "✕"
	close.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)
	close.MouseButton1Click:Connect(function() ui:Destroy() end)

	-- === BUTTONS ===
	local toggle = Instance.new("TextButton", frame)
	toggle.Size = UDim2.new(0,200,0,35)
	toggle.Position = UDim2.new(0,20,0,35)
	toggle.Text = "Teleport: OFF"
	toggle.BackgroundColor3 = Color3.fromRGB(0,200,100)
	toggle.TextColor3 = Color3.new(1,1,1)
	toggle.Font = Enum.Font.GothamBold
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

	local speedLabel = Instance.new("TextLabel", frame)
	speedLabel.Size = UDim2.new(1,-20,0,20)
	speedLabel.Position = UDim2.new(0,10,0,80)
	speedLabel.Text = ("Delay: %.1fs | Point %d/%d"):format(teleportDelay, currentIndex, #teleportPoints)
	speedLabel.TextColor3 = Color3.new(1,1,1)
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.BackgroundTransparency = 1

	local speedSlider = Instance.new("TextButton", frame)
	speedSlider.Size = UDim2.new(0,200,0,25)
	speedSlider.Position = UDim2.new(0,20,0,105)
	speedSlider.Text = "⚙️ Speed Control: "..teleportDelay.."s"
	speedSlider.BackgroundColor3 = Color3.fromRGB(0,170,255)
	speedSlider.TextColor3 = Color3.new(1,1,1)
	speedSlider.Font = Enum.Font.GothamBold
	Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0,6)

	speedSlider.MouseButton1Click:Connect(function()
		teleportDelay = teleportDelay - 0.5
		if teleportDelay < 0.5 then teleportDelay = 3 end
		speedSlider.Text = ("⚙️ Speed Control: %.1fs"):format(teleportDelay)
		speedLabel.Text = ("Delay: %.1fs | Point %d/%d"):format(teleportDelay, currentIndex, #teleportPoints)
	end)

	local gravityBtn = Instance.new("TextButton", frame)
	gravityBtn.Size = UDim2.new(0,200,0,30)
	gravityBtn.Position = UDim2.new(0,20,0,135)
	gravityBtn.Text = "🧲 Anti Gravity: OFF"
	gravityBtn.BackgroundColor3 = Color3.fromRGB(255,170,0)
	gravityBtn.TextColor3 = Color3.new(0,0,0)
	gravityBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", gravityBtn).CornerRadius = UDim.new(0,6)

	gravityBtn.MouseButton1Click:Connect(function()
		antiGravityEnabled = not antiGravityEnabled
		applyAntiGravity(antiGravityEnabled)
		gravityBtn.Text = antiGravityEnabled and "🧲 Anti Gravity: ON" or "🧲 Anti Gravity: OFF"
		gravityBtn.BackgroundColor3 = antiGravityEnabled and Color3.fromRGB(0,255,150) or Color3.fromRGB(255,170,0)
	end)

	local resetBtn = Instance.new("TextButton", frame)
	resetBtn.Size = UDim2.new(0,200,0,30)
	resetBtn.Position = UDim2.new(0,20,0,170)
	resetBtn.Text = "🧿 Auto Reset Checkpoint: OFF"
	resetBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
	resetBtn.TextColor3 = Color3.new(1,1,1)
	resetBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,6)

	resetBtn.MouseButton1Click:Connect(function()
		autoResetCheckpoint = not autoResetCheckpoint
		resetBtn.Text = autoResetCheckpoint and "🧿 Auto Reset Checkpoint: ON" or "🧿 Auto Reset Checkpoint: OFF"
		resetBtn.BackgroundColor3 = autoResetCheckpoint and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,100,100)
	end)

	local backBtn = Instance.new("TextButton", frame)
	backBtn.Size = UDim2.new(0,90,0,28)
	backBtn.Position = UDim2.new(0,20,0,205)
	backBtn.Text = "⏪ Back"
	backBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
	backBtn.TextColor3 = Color3.new(0,0,0)
	backBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0,6)
	backBtn.MouseButton1Click:Connect(function()
		if currentIndex > 1 then
			currentIndex -= 1
			teleportToPosition(teleportPoints[currentIndex])
			speedLabel.Text = ("Moved ⏪ | Point %d/%d"):format(currentIndex, #teleportPoints)
		end
	end)

	local nextBtn = Instance.new("TextButton", frame)
	nextBtn.Size = UDim2.new(0,90,0,28)
	nextBtn.Position = UDim2.new(0,130,0,205)
	nextBtn.Text = "⏩ Next"
	nextBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
	nextBtn.TextColor3 = Color3.new(0,0,0)
	nextBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0,6)
	nextBtn.MouseButton1Click:Connect(function()
		if currentIndex < #teleportPoints then
			currentIndex += 1
			teleportToPosition(teleportPoints[currentIndex])
			speedLabel.Text = ("Moved ⏩ | Point %d/%d"):format(currentIndex, #teleportPoints)
		end
	end)

	local respawnBtn = Instance.new("TextButton", frame)
	respawnBtn.Size = UDim2.new(0,200,0,30)
	respawnBtn.Position = UDim2.new(0,20,0,240)
	respawnBtn.Text = "🔄 Respawn"
	respawnBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
	respawnBtn.TextColor3 = Color3.new(0,0,0)
	respawnBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", respawnBtn).CornerRadius = UDim.new(0,6)
	respawnBtn.MouseButton1Click:Connect(function()
		if player.Character then
			local hum = player.Character:FindFirstChild("Humanoid")
			if hum then hum.Health = 0 end
		end
	end)

	local restartBtn = Instance.new("TextButton", frame)
	restartBtn.Size = UDim2.new(0,200,0,30)
	restartBtn.Position = UDim2.new(0,20,0,275)
	restartBtn.Text = "🔁 Restart Teleport"
	restartBtn.BackgroundColor3 = Color3.fromRGB(0,255,150)
	restartBtn.TextColor3 = Color3.new(0,0,0)
	restartBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", restartBtn).CornerRadius = UDim.new(0,6)
	restartBtn.MouseButton1Click:Connect(function()
		currentIndex = 1
		teleportToPosition(teleportPoints[currentIndex])
		speedLabel.Text = ("Restarted 🔁 | Point %d/%d"):format(currentIndex, #teleportPoints)
	end)

	-- === TOGGLE LOGIC ===
	toggle.MouseButton1Click:Connect(function()
		isTeleporting = not isTeleporting
		if isTeleporting then
			toggle.Text = "Teleport: ON"
			TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255,60,60)}):Play()
			startTeleportLoop(speedLabel, toggle)
		else
			toggle.Text = "Teleport: OFF"
			TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0,200,100)}):Play()
			if teleportThread then task.cancel(teleportThread) end
		end
	end)
end

-- 🚀 Start langsung tanpa key
createTeleporterUI()
