local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local VERSION = "v1.0.1"
local WALK_SPEED_VALUE = 60
local MAX_SPEED = 200
local MIN_SPEED = 16

local UI_CONFIG = {
    MainColor = Color3.fromRGB(12, 12, 12),
    HeaderColor = Color3.fromRGB(20, 20, 20),
    OffColor = Color3.fromRGB(255, 80, 80),
    OnColor = Color3.fromRGB(80, 255, 120),
    PressColor = Color3.fromRGB(140, 140, 140),
    CloseDefault = Color3.fromRGB(35, 35, 35),
    CloseHover = Color3.fromRGB(255, 60, 60),
}

local ESP_ENABLED = false
local SPEED_ENABLED = false

local function CreateTween(obj, target, duration)
    local info = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, target)
    tween:Play()
    return tween
end

local function ApplyHighlight(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        if char:FindFirstChild("X_ESP") then char["X_ESP"]:Destroy() end
        if ESP_ENABLED then
            local hl = Instance.new("Highlight", char)
            hl.Name = "X_ESP"
            hl.FillTransparency = 1
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end
    setup(player.Character)
    player.CharacterAdded:Connect(setup)
end

local function UpdateSpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = SPEED_ENABLED and WALK_SPEED_VALUE or 16
    end
end

if CoreGui:FindFirstChild("X_Project") then CoreGui["X_Project"]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "X_Project"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("CanvasGroup") 
MainFrame.Size = UDim2.new(0, 200, 0, 180) 
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -90)
MainFrame.BackgroundColor3 = UI_CONFIG.MainColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true -- CORRIGE O ARREDONDAMENTO DO TOPO
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(45, 45, 45)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = UI_CONFIG.HeaderColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -35, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "X <font size='9' color='rgb(150,150,150)'>" .. VERSION .. "</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -11)
CloseBtn.BackgroundColor3 = UI_CONFIG.CloseDefault
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -35)
Container.Position = UDim2.new(0, 0, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder -- ATIVA A ORDEM MANUAL

local function CreateButton(name, text, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 180, 0, 34)
    btn.BackgroundColor3 = UI_CONFIG.OffColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local ESPBtn = CreateButton("ESPBtn", "ESP: OFF", 1)
local SpeedBtn = CreateButton("SpeedBtn", "SPEED: OFF", 2)

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0, 180, 0, 35)
SliderFrame.BackgroundTransparency = 1
SliderFrame.LayoutOrder = 3 
SliderFrame.Parent = Container

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 12)
SliderLabel.Text = "VELOCIDADE: " .. WALK_SPEED_VALUE
SliderLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextSize = 9
SliderLabel.BackgroundTransparency = 1
SliderLabel.Parent = SliderFrame

local SliderBG = Instance.new("Frame")
SliderBG.Size = UDim2.new(1, 0, 0, 4)
SliderBG.Position = UDim2.new(0, 0, 0, 20)
SliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SliderBG.Parent = SliderFrame
Instance.new("UICorner", SliderBG)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new((WALK_SPEED_VALUE - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderFill.Parent = SliderBG
Instance.new("UICorner", SliderFill)

local function SetupAction(btn, isToggle)
    local function GetStateColor()
        if not isToggle then return UI_CONFIG.CloseDefault end
        if btn == ESPBtn then return ESP_ENABLED and UI_CONFIG.OnColor or UI_CONFIG.OffColor end
        if btn == SpeedBtn then return SPEED_ENABLED and UI_CONFIG.OnColor or UI_CONFIG.OffColor end
    end

    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            local press = (btn == CloseBtn) and UI_CONFIG.CloseHover or UI_CONFIG.PressColor
            CreateTween(btn, {BackgroundColor3 = press, Size = (btn == CloseBtn and btn.Size or UDim2.new(0, 175, 0, 32))})
        end
    end)

    local function Reset()
        CreateTween(btn, {BackgroundColor3 = GetStateColor(), Size = (btn == CloseBtn and btn.Size or UDim2.new(0, 180, 0, 34))})
    end

    btn.InputEnded:Connect(Reset)
    btn.MouseLeave:Connect(Reset)

    btn.Activated:Connect(function()
        if btn == ESPBtn then
            ESP_ENABLED = not ESP_ENABLED
            for _, p in pairs(Players:GetPlayers()) do ApplyHighlight(p) end
            btn.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
        elseif btn == SpeedBtn then
            SPEED_ENABLED = not SPEED_ENABLED
            UpdateSpeed()
            btn.Text = "SPEED: " .. (SPEED_ENABLED and "ON" or "OFF")
        elseif btn == CloseBtn then
            CreateTween(MainFrame, {GroupTransparency = 1}, 0.2).Completed:Connect(function() ScreenGui:Destroy() end)
        end
        Reset()
    end)
end

SetupAction(ESPBtn, true)
SetupAction(SpeedBtn, true)
SetupAction(CloseBtn, false)

local sliding = false
local function UpdateSlider(input)
    local ratio = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    WALK_SPEED_VALUE = math.floor(MIN_SPEED + (ratio * (MAX_SPEED - MIN_SPEED)))
    SliderLabel.Text = "VELOCIDADE: " .. WALK_SPEED_VALUE
    if SPEED_ENABLED then UpdateSpeed() end
end

SliderBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true UpdateSlider(i) end end)
UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then UpdateSlider(i) end end)
UserInputService.InputEnded:Connect(function() sliding = false end)

local drag, dStart, sPos
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true dStart = i.Position sPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
    local delta = i.Position - dStart
    MainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
end end)
Header.InputEnded:Connect(function() drag = false end)

MainFrame.GroupTransparency = 1
CreateTween(MainFrame, {GroupTransparency = 0}, 0.4)
Players.PlayerAdded:Connect(ApplyHighlight)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); UpdateSpeed() end)
