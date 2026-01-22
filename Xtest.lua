if not game:IsLoaded() then game.Loaded:Wait() end
if not game:GetService("RunService"):IsClient() then return end

local g1 = game
local sP = g1:GetService("Players")
local sT = g1:GetService("TweenService")
local sU = g1:GetService("UserInputService")
local sC = g1:GetService("CoreGui")

local lp = sP.LocalPlayer

local v_ = string.reverse("2.0.1v")
local ws_ = (20 + 40)

local uiS = UDim2.new(0, 260, 0, 180)

local c_ = {
	a = Color3.fromRGB(10,10,10),
	b = Color3.fromRGB(20,20,20),
	c = Color3.fromRGB(255,255,255),
	d = Color3.fromRGB(255,50,50),
	e = Color3.fromRGB(40,40,40),
	f = UDim.new(0,10)
}

local e_ = false
local s_ = false
local k_ = false

local function t_(o,p,d)
	local i = TweenInfo.new(d or .3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tw = sT:Create(o,i,p)
	tw:Play()
	return tw
end

local function b_(o,i)
	local p,s = o.AbsolutePosition,o.AbsoluteSize
	return i.X>=p.X and i.X<=p.X+s.X and i.Y>=p.Y and i.Y<=p.Y+s.Y
end

local function h_(plr)
	if plr==lp then return end
	local function f_(ch)
		if not ch then return end
		local old = ch:FindFirstChild("X_ESP")
		if old then old:Destroy() end
		if e_ then
			local h = Instance.new("Highlight")
			h.Name="X_ESP"
			h.FillTransparency=1
			h.OutlineTransparency=0
			h.OutlineColor=c_.c
			h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent=ch
		end
	end
	f_(plr.Character)
	plr.CharacterAdded:Connect(f_)
end

local function u_()
	local c = lp.Character
	local h = c and c:FindFirstChild("Humanoid")
	if h then
		h.WalkSpeed = s_ and ws_ or 16
	end
end

if sC:FindFirstChild("X_Project") then
	sC.X_Project:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name="X_Project"
sg.ResetOnSpawn=false
sg.Parent=sC

local mf = Instance.new("Frame")
mf.Size=uiS
mf.Position=UDim2.new(.5,-130,.5,-90)
mf.BackgroundColor3=c_.a
mf.BorderSizePixel=0
mf.ClipsDescendants=true
mf.Parent=sg

Instance.new("UICorner",mf).CornerRadius=c_.f
local st = Instance.new("UIStroke",mf)
st.Color=c_.e
st.Thickness=1.5

local hd = Instance.new("Frame")
hd.Size=UDim2.new(1,0,0,35)
hd.BackgroundColor3=c_.b
hd.BorderSizePixel=0
hd.Parent=mf
Instance.new("UICorner",hd).CornerRadius=c_.f

local tl = Instance.new("TextLabel")
tl.Size=UDim2.new(1,-40,1,0)
tl.Position=UDim2.new(0,12,0,0)
tl.BackgroundTransparency=1
tl.RichText=true
tl.Text="X <font size='10' color='rgb(150,150,150)'>"..v_.."</font>"
tl.TextColor3=c_.c
tl.Font=Enum.Font.GothamBold
tl.TextSize=18
tl.TextXAlignment=Enum.TextXAlignment.Left
tl.Parent=hd

local cb = Instance.new("TextButton")
cb.Size=UDim2.new(0,26,0,26)
cb.Position=UDim2.new(1,-31,.5,-13)
cb.BackgroundColor3=Color3.fromRGB(30,30,30)
cb.Text="X"
cb.TextColor3=c_.d
cb.Font=Enum.Font.GothamBold
cb.TextSize=14
cb.AutoButtonColor=false
cb.Parent=hd
Instance.new("UICorner",cb).CornerRadius=UDim.new(0,6)

local ct = Instance.new("Frame")
ct.Size=UDim2.new(1,0,1,-35)
ct.Position=UDim2.new(0,0,0,35)
ct.BackgroundTransparency=1
ct.Parent=mf

local ll = Instance.new("UIListLayout",ct)
ll.Padding=UDim.new(0,8)
ll.HorizontalAlignment=Enum.HorizontalAlignment.Center
ll.VerticalAlignment=Enum.VerticalAlignment.Center

local function tb_(n,t)
	local b = Instance.new("TextButton")
	b.Name=n
	b.Size=UDim2.new(0,220,0,40)
	b.BackgroundColor3=c_.c
	b.Text=t
	b.TextColor3=Color3.fromRGB(0,0,0)
	b.Font=Enum.Font.GothamBold
	b.TextSize=13
	b.AutoButtonColor=false
	b.Parent=ct
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	return b
end

local eb = tb_("A","ESP HIGHLIGHTS: OFF")
local sb = tb_("B","SPEED: OFF")

mf.BackgroundTransparency=1
t_(mf,{BackgroundTransparency=0},.5)

cb.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		k_=true
		t_(cb,{BackgroundColor3=Color3.fromRGB(60,20,20),Size=UDim2.new(0,22,0,22)},.1)
	end
end)

sU.InputEnded:Connect(function(i)
	if k_ then
		k_=false
		t_(cb,{BackgroundColor3=Color3.fromRGB(30,30,30),Size=UDim2.new(0,26,0,26)},.1)
		if b_(cb,i.Position) then
			local tw=t_(mf,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.4)
			tw.Completed:Connect(function() sg:Destroy() end)
		end
	end
end)

local function g_(b,f)
	b.InputEnded:Connect(function(i)
		if b_(b,i.Position) then f() end
	end)
end

g_(eb,function()
	e_=not e_
	for _,p in pairs(sP:GetPlayers()) do h_(p) end
	eb.Text=e_ and "ESP HIGHLIGHTS: ON" or "ESP HIGHLIGHTS: OFF"
end)

g_(sb,function()
	s_=not s_
	u_()
	sb.Text=s_ and "SPEED: ON" or "SPEED: OFF"
end)

sP.PlayerAdded:Connect(h_)
lp.CharacterAdded:Connect(function() task.wait(.5) u_() end)