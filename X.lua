local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local VERSION = "v1.0.2"
local WALK_SPEED_VALUE = 60
local MAX_SPEED = 200
local MIN_SPEED = 16
local FLY_SPEED = 50

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
local FLY_ENABLED = false
local IS_MINIMIZED = false

local bodyVelocity = nil
local flyConnection = nil
local controlFrame = nil
local upPressed = false
local downPressed = false

local pcKeys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}

local function CreateTween(obj, props, duration)
    local info = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

local function ApplyHighlight(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        if char:FindFirstChild("X_ESP") then char.X_ESP:Destroy() end
        if ESP_ENABLED then
            local hl = Instance.new("Highlight")
            hl.Name = "X_ESP"
            hl.FillTransparency = 1
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0
            hl.Parent = char
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

local function CreateFlyControls()
    if controlFrame then controlFrame:Destroy() end
    controlFrame = Instance.new("Frame")
    controlFrame.Name = "FlyControls"
    controlFrame.Size = UDim2.new(0, 100, 0, 140)
    controlFrame.Position = UDim2.new(1, -120, 0.5, -70)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Visible = false
    controlFrame.Parent = ScreenGui

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(1, 0, 0.45, 0)
    upBtn.Position = UDim2.new(0, 0, 0, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    upBtn.Text = "↑ SUBIR"
    upBtn.TextColor3 = Color3.new(1,1,1)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 16
    upBtn.Parent = controlFrame
    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 10)

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(1, 0, 0.45, 0)
    downBtn.Position = UDim2.new(0, 0, 0.55, 0)
    downBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    downBtn.Text = "↓ DESCER"
    downBtn.TextColor3 = Color3.new(1,1,1)
    downBtn.Font = Enum.Font.GothamBold
    downBtn.TextSize = 16
    downBtn.Parent = controlFrame
    Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 10)

    upBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            upPressed = true
            CreateTween(upBtn, {BackgroundColor3 = Color3.fromRGB(40, 120, 50)})
        end
    end)
    upBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            upPressed = false
            CreateTween(upBtn, {BackgroundColor3 = Color3.fromRGB(60, 180, 80)})
        end
    end)

    downBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            downPressed = true
            CreateTween(downBtn, {BackgroundColor3 = Color3.fromRGB(120, 40, 40)})
        end
    end)
    downBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            downPressed = false
            CreateTween(downBtn, {BackgroundColor3 = Color3.fromRGB(180, 60, 60)})
        end
    end)
end

local function UpdateFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    if FLY_ENABLED then
        humanoid.PlatformStand = true
        if bodyVelocity then bodyVelocity:Destroy() end
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(90000, 90000, 90000)
        bodyVelocity.Velocity = Vector3.new()
        bodyVelocity.Parent = root

        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.Heartbeat:Connect(function()
            local move = humanoid.MoveDirection * FLY_SPEED
            local vertical = 0
            if upPressed then vertical = vertical + FLY_SPEED end
            if downPressed then vertical = vertical - FLY_SPEED end
            if pcKeys.Space then vertical = vertical + FLY_SPEED end
            if pcKeys.Shift then vertical = vertical - FLY_SPEED end
            bodyVelocity.Velocity = move + Vector3.new(0, vertical, 0)
        end)

        CreateFlyControls()
        controlFrame.Visible = true
    else
        humanoid.PlatformStand = false
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        upPressed = false
        downPressed = false
        if controlFrame then controlFrame.Visible = false end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then pcKeys.W = true
    elseif key == Enum.KeyCode.A then pcKeys.A = true
    elseif key == Enum.KeyCode.S then pcKeys.S = true
    elseif key == Enum.KeyCode.D then pcKeys.D = true
    elseif key == Enum.KeyCode.Space then pcKeys.Space = true
    elseif key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then pcKeys.Shift = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then pcKeys.W = false
    elseif key == Enum.KeyCode.A then pcKeys.A = false
    elseif key == Enum.KeyCode.S then pcKeys.S = false
    elseif key == Enum.KeyCode.D then pcKeys.D = false
    elseif key == Enum.KeyCode.Space then pcKeys.Space = false
    elseif key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then pcKeys.Shift = false
    end
end)

if CoreGui:FindFirstChild("X_Project") then
    CoreGui.X_Project:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "X_Project"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -110)
MainFrame.BackgroundColor3 = UI_CONFIG.MainColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainGroup = Instance.new("CanvasGroup")
MainGroup.Parent = MainFrame

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(45, 45, 45)
Stroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = UI_CONFIG.HeaderColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
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
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -52, 0.5, -11)
MinBtn.BackgroundColor3 = UI_CONFIG.CloseDefault
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -35)
Container.Position = UDim2.new(0, 0, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggleButton(name, text, order)
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

local ESPBtn = CreateToggleButton("ESPBtn", "ESP: OFF", 1)
local SpeedBtn = CreateToggleButton("SpeedBtn", "SPEED: OFF", 2)

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
SliderFill.Size = UDim2.new((WALK_SPEED_VALUE - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderFill.Parent = SliderBG
Instance.new("UICorner", SliderFill)

local FlyBtn = CreateToggleButton("FlyBtn", "FLY: OFF", 4)

local function SetupButton(btn, isToggle)
    local function GetColor()
        if not isToggle then return UI_CONFIG.CloseDefault end
        if btn == ESPBtn then return ESP_ENABLED and UI_CONFIG.OnColor or UI_CONFIG.OffColor end
        if btn == SpeedBtn then return SPEED_ENABLED and UI_CONFIG.OnColor or UI_CONFIG.OffColor end
        if btn == FlyBtn then return FLY_ENABLED and UI_CONFIG.OnColor or UI_CONFIG.OffColor end
        return UI_CONFIG.OffColor
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local press = (btn == CloseBtn or btn == MinBtn) and UI_CONFIG.CloseHover or UI_CONFIG.PressColor
            CreateTween(btn, {
                BackgroundColor3 = press,
                Size = (btn == CloseBtn or btn == MinBtn) and btn.Size or UDim2.new(0, 175, 0, 32)
            })
        end
    end)

    local function Reset()
        CreateTween(btn, {
            BackgroundColor3 = GetColor(),
            Size = (btn == CloseBtn or btn == MinBtn) and btn.Size or UDim2.new(0, 180, 0, 34)
        })
    end

    btn.InputEnded:Connect(Reset)
    btn.MouseLeave:Connect(Reset)

    btn.Activated:Connect(function()
        if btn == ESPBtn then
            ESP_ENABLED = not ESP_ENABLED
            for _, p in Players:GetPlayers() do ApplyHighlight(p) end
            btn.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
        elseif btn == SpeedBtn then
            SPEED_ENABLED = not SPEED_ENABLED
            UpdateSpeed()
            btn.Text = "SPEED: " .. (SPEED_ENABLED and "ON" or "OFF")
        elseif btn == FlyBtn then
            FLY_ENABLED = not FLY_ENABLED
            UpdateFly()
            btn.Text = "FLY: " .. (FLY_ENABLED and "ON" or "OFF")
        elseif btn == CloseBtn then
            CreateTween(MainGroup, {GroupTransparency = 1}, 0.25).Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        elseif btn == MinBtn then
            IS_MINIMIZED = not IS_MINIMIZED
            if IS_MINIMIZED then
                MainFrame.Size = UDim2.new(0, 200, 0, 30)
                Container.Visible = false
                MinBtn.Text = "+"
            else
                MainFrame.Size = UDim2.new(0, 200, 0, 220)
                Container.Visible = true
                MinBtn.Text = "−"
            end
        end
        Reset()
    end)
end

SetupButton(ESPBtn, true)
SetupButton(SpeedBtn, true)
SetupButton(FlyBtn, true)
SetupButton(CloseBtn, false)
SetupButton(MinBtn, false)

local sliding = false

local function UpdateSlider(input)
    local ratio = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    WALK_SPEED_VALUE = math.floor(MIN_SPEED + ratio * (MAX_SPEED - MIN_SPEED))
    SliderLabel.Text = "VELOCIDADE: " .. WALK_SPEED_VALUE
    if SPEED_ENABLED then UpdateSpeed() end
end

SliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function()
    sliding = false
end)

local drag, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Header.InputEnded:Connect(function()
    drag = false
end)

MainGroup.GroupTransparency = 1
CreateTween(MainGroup, {GroupTransparency = 0}, 0.4)

Players.PlayerAdded:Connect(ApplyHighlight)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateSpeed()
    if FLY_ENABLED then UpdateFly() end
end)

for _, player in Players:GetPlayers() do
    ApplyHighlight(player)
end