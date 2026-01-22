local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local VERSION = "v1.0.2"
local WALK_SPEED_VALUE = 60
local UI_SIZE = UDim2.new(0, 260, 0, 180)
local UI_CONFIG = {
    MainColor = Color3.fromRGB(10, 10, 10),
    HeaderColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(255, 255, 255),
    CloseColor = Color3.fromRGB(255, 50, 50),
    StrokeColor = Color3.fromRGB(40, 40, 40),
    CornerRadius = UDim.new(0, 10),
}

local ESP_ENABLED = false
local SPEED_ENABLED = false
local isPressingClose = false

local function CreateTween(obj, target, duration)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, target)
    tween:Play()
    return tween
end

local function IsInBounds(obj, inputPos)
    local absPos = obj.AbsolutePosition
    local absSize = obj.AbsoluteSize
    return inputPos.X >= absPos.X and inputPos.X <= absPos.X + absSize.X and
           inputPos.Y >= absPos.Y and inputPos.Y <= absPos.Y + absSize.Y
end

local function ApplyHighlight(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        local old = char:FindFirstChild("X_ESP")
        if old then old:Destroy() end
        
        if ESP_ENABLED then
            local highlight = Instance.new("Highlight")
            highlight.Name = "X_ESP"
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = char
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
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UI_SIZE
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = UI_CONFIG.MainColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UI_CONFIG.CornerRadius
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = UI_CONFIG.StrokeColor
MainStroke.Thickness = 1.5

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = UI_CONFIG.HeaderColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UI_CONFIG.CornerRadius

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "X <font size='10' color='rgb(150, 150, 150)'>" .. VERSION .. "</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -31, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = UI_CONFIG.CloseColor
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -35)
Container.Position = UDim2.new(0, 0, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function CreateToggleButton(name, defaultText)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = defaultText
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local ESPBtn = CreateToggleButton("ESPBtn", "ESP HIGHLIGHTS: OFF")
local SpeedBtn = CreateToggleButton("SpeedBtn", "SPEED: OFF")

MainFrame.BackgroundTransparency = 1
CreateTween(MainFrame, {BackgroundTransparency = 0}, 0.5)

CloseBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isPressingClose = true
        CreateTween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(60, 20, 20), Size = UDim2.new(0, 22, 0, 22)}, 0.1)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isPressingClose then
            isPressingClose = false
            CreateTween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(0, 26, 0, 26)}, 0.1)
            
            if IsInBounds(CloseBtn, input.Position) then
                local t = CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
                t.Completed:Connect(function() ScreenGui:Destroy() end)
            end
        end
    end
end)

local function HandleToggle(btn, callback)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            CreateTween(btn, {Size = UDim2.new(0, 210, 0, 36), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}, 0.1)
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            CreateTween(btn, {Size = UDim2.new(0, 220, 0, 40), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
            if IsInBounds(btn, input.Position) then
                callback()
            end
        end
    end)
end

HandleToggle(ESPBtn, function()
    ESP_ENABLED = not ESP_ENABLED
    for _, p in pairs(Players:GetPlayers()) do ApplyHighlight(p) end
    ESPBtn.Text = ESP_ENABLED and "ESP HIGHLIGHTS: ON" or "ESP HIGHLIGHTS: OFF"
    ESPBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 255, 255)
end)

HandleToggle(SpeedBtn, function()
    SPEED_ENABLED = not SPEED_ENABLED
    UpdateSpeed()
    SpeedBtn.Text = SPEED_ENABLED and "SPEED: ON" or "SPEED: OFF"
    SpeedBtn.BackgroundColor3 = SPEED_ENABLED and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 255, 255)
end)

local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

Players.PlayerAdded:Connect(ApplyHighlight)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); UpdateSpeed() end)
