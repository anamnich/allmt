-- WHITELIST CHECK + AUTO REFRESH + GUI (Windows 11 Style - Tanpa Taskbar)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ===== CONFIG =====
local WHITELIST_URL = "https://raw.githubusercontent.com/ZassTdr/whitelist/refs/heads/main/wltpmt.json"
local KICK_MESSAGE = "Hubungi owner ZassXd agar bisa menggunakan script 085182791956"
local REFRESH_INTERVAL = 5 -- detik

-- ====== FUNGSI FETCH DATA ======
local function fetchWhitelist()
	local success, response = pcall(function()
		return game:HttpGet(WHITELIST_URL, true)
	end)
	if not success then
		warn("[Whitelist] Gagal fetch data: " .. tostring(response))
		return nil
	end
	local parsed, data = pcall(function()
		return HttpService:JSONDecode(response)
	end)
	if not parsed then
		warn("[Whitelist] JSON invalid: " .. tostring(data))
		return nil
	end
	return data
end

local function isWhitelisted(name, whitelistTable)
	if not whitelistTable or type(whitelistTable) ~= "table" then return false end
	for _, v in ipairs(whitelistTable) do
		if tostring(v) == tostring(name) then
			return true
		end
	end
	return false
end

-- ====== CEK AWAL (Dengan pcall untuk safety) ======
local whitelist = fetchWhitelist()
if not whitelist or not isWhitelisted(player.Name, whitelist) then
	player:Kick(KICK_MESSAGE)
	return
end

-- ====== AUTO REFRESH LOOP ======
task.spawn(function()
	while task.wait(REFRESH_INTERVAL) do
		local newList = fetchWhitelist()
		if newList and not isWhitelisted(player.Name, newList) then
			player:Kick(KICK_MESSAGE)
			break
		end
	end
end)

-- ===== GUI SETUP (Windows 11 Style - Hanya Main Window) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZassXdWindows11GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- === MAIN WINDOW (Windows 11 Style) ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Tengah layar, tanpa taskbar
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(100, 150, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- === TITLE BAR ===
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LIST TP ALL MT"
Title.Font = Enum.Font.SourceSansSemibold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeBtn.Text = "─"
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- === SCROLLING FRAME ===
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
Scroll.ScrollingEnabled = true

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function updateCanvasSize()
	Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end
updateCanvasSize()
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

-- === BUTTON FACTORY ===
local function createButton(text, icon, func)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = (icon or "") .. " " .. text
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = false
	
	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 4)
	BtnCorner.Parent = btn
	
	local BtnStroke = Instance.new("UIStroke")
	BtnStroke.Color = Color3.fromRGB(100, 150, 255)
	BtnStroke.Thickness = 0.5
	BtnStroke.Transparency = 0.8
	BtnStroke.Parent = btn

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end)

	btn.MouseButton1Click:Connect(func)
	btn.Parent = Scroll
end

-- === DAFTAR BUTTON ===
createButton("MT NIRWANA", "⛰️", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/anamnich/allmt/refs/heads/main/nirwana.lua"))()
end)
