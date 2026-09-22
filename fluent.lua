```lua
--========================================================
-- MANI UNIVERSAL GRAPHICS MOD V1.1
-- FIXED GUI LOADER
-- PC + MOBILE
--========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--========================================================
-- SAFE GUI PARENT
--========================================================

local function GetGuiParent()

    -- Delta / common executors
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end

    -- Roblox CoreGui fallback
    local ok, core = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and core then
        return core
    end

    -- Normal Roblox fallback
    return Player:WaitForChild("PlayerGui")
end

local GuiParent = GetGuiParent()

--========================================================
-- REMOVE OLD VERSION
--========================================================

pcall(function()
    local old = GuiParent:FindFirstChild("MANI_GRAPHICS_V11")
    if old then
        old:Destroy()
    end
end)

--========================================================
-- GUI
--========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MANI_GRAPHICS_V11"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local parentOK = pcall(function()
    ScreenGui.Parent = GuiParent
end)

if not parentOK then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

--========================================================
-- LOADING
--========================================================

local Loading = Instance.new("TextLabel")
Loading.Size = UDim2.fromOffset(300,60)
Loading.Position = UDim2.new(.5,-150,.5,-30)
Loading.BackgroundColor3 = Color3.fromRGB(15,15,20)
Loading.Text = "MANI GRAPHICS\nLOADING..."
Loading.TextColor3 = Color3.fromRGB(170,200,255)
Loading.TextSize = 15
Loading.Font = Enum.Font.GothamBold
Loading.BorderSizePixel = 0
Loading.ZIndex = 999
Loading.Parent = ScreenGui

local LC = Instance.new("UICorner")
LC.CornerRadius = UDim.new(0,12)
LC.Parent = Loading

task.wait(.5)

pcall(function()
    Loading:Destroy()
end)

--========================================================
-- EFFECT CLEANUP
--========================================================

local function DeleteEffect(name)
    pcall(function()
        local obj = Lighting:FindFirstChild(name)
        if obj then
            obj:Destroy()
        end
    end)
end

DeleteEffect("MANI_Bloom")
DeleteEffect("MANI_Color")
DeleteEffect("MANI_Atmosphere")
DeleteEffect("MANI_SunRays")
DeleteEffect("MANI_DOF")

--========================================================
-- CREATE EFFECTS
--========================================================

local Bloom = Instance.new("BloomEffect")
Bloom.Name = "MANI_Bloom"
Bloom.Intensity = .4
Bloom.Size = 24
Bloom.Threshold = .9
Bloom.Enabled = true
Bloom.Parent = Lighting

local Color = Instance.new("ColorCorrectionEffect")
Color.Name = "MANI_Color"
Color.Brightness = .02
Color.Contrast = .12
Color.Saturation = .12
Color.Enabled = true
Color.Parent = Lighting

local Atmosphere = Instance.new("Atmosphere")
Atmosphere.Name = "MANI_Atmosphere"
Atmosphere.Density = .22
Atmosphere.Offset = .1
Atmosphere.Haze = .7
Atmosphere.Glare = .05
Atmosphere.Color = Color3.fromRGB(200,215,255)
Atmosphere.Decay = Color3.fromRGB(100,105,120)
Atmosphere.Enabled = true
Atmosphere.Parent = Lighting

local SunRays = Instance.new("SunRaysEffect")
SunRays.Name = "MANI_SunRays"
SunRays.Intensity = .1
SunRays.Spread = .85
SunRays.Enabled = true
SunRays.Parent = Lighting

local DOF = Instance.new("DepthOfFieldEffect")
DOF.Name = "MANI_DOF"
DOF.FarIntensity = .1
DOF.NearIntensity = .03
DOF.FocusDistance = 50
DOF.InFocusRadius = 30
DOF.Enabled = false
DOF.Parent = Lighting

--========================================================
-- MAIN GUI
--========================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(380,480)
Main.Position = UDim2.new(.5,-190,.5,-240)
Main.BackgroundColor3 = Color3.fromRGB(12,12,17)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,15)
Corner.Parent = Main

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(70,70,90)
Border.Thickness = 1
Border.Transparency = .25
Border.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,60)
Header.BackgroundColor3 = Color3.fromRGB(20,20,28)
Header.BorderSizePixel = 0
Header.Parent = Main

local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0,15)
HCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-120,0,27)
Title.Position = UDim2.fromOffset(17,7)
Title.BackgroundTransparency = 1
Title.Text = "MANI UNIVERSAL"
Title.TextColor3 = Color3.fromRGB(245,245,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1,-120,0,18)
Sub.Position = UDim2.fromOffset(17,34)
Sub.BackgroundTransparency = 1
Sub.Text = "GRAPHICS MOD  •  V1.1"
Sub.TextColor3 = Color3.fromRGB(135,135,155)
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

local Min = Instance.new("TextButton")
Min.Size = UDim2.fromOffset(34,30)
Min.Position = UDim2.new(1,-78,0,15)
Min.BackgroundColor3 = Color3.fromRGB(35,35,45)
Min.Text = "—"
Min.TextColor3 = Color3.fromRGB(255,255,255)
Min.TextSize = 16
Min.Font = Enum.Font.GothamBold
Min.BorderSizePixel = 0
Min.Parent = Header

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0,8)
MC.Parent = Min

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34,30)
Close.Position = UDim2.new(1,-40,0,15)
Close.BackgroundColor3 = Color3.fromRGB(55,25,30)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255,120,130)
Close.TextSize = 14
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = Header

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0,8)
CC.Parent = Close

--========================================================
-- SCROLL
--========================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,1,-72)
Scroll.Position = UDim2.fromOffset(10,68)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Scroll

--========================================================
-- UI FUNCTIONS
--========================================================

local function Section(text)

    local x = Instance.new("TextLabel")
    x.Size = UDim2.new(1,-5,0,24)
    x.BackgroundTransparency = 1
    x.Text = text
    x.TextColor3 = Color3.fromRGB(130,130,155)
    x.TextSize = 10
    x.Font = Enum.Font.GothamBold
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.Parent = Scroll

end

local function Button(text,callback)

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-5,0,42)
    b.BackgroundColor3 = Color3.fromRGB(25,25,34)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(235,235,245)
    b.TextSize = 12
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,9)
    c.Parent = b

    b.Activated:Connect(function()
        pcall(callback)
    end)

    return b
end

local function Toggle(text,start,callback)

    local state = start

    local b = Button(text.." : "..(state and "ON" or "OFF"),function()

        state = not state

        b.Text = text.." : "..(state and "ON" or "OFF")

        pcall(function()
            callback(state)
        end)

    end)

    return b
end

--========================================================
-- PRESETS
--========================================================

local function Ultra()

    Bloom.Enabled = true
    Bloom.Intensity = .45
    Bloom.Size = 28
    Bloom.Threshold = .85

    Color.Enabled = true
    Color.Brightness = .02
    Color.Contrast = .15
    Color.Saturation = .12

    Atmosphere.Enabled = true
    Atmosphere.Density = .22
    Atmosphere.Haze = .7
    Atmosphere.Glare = .06

    SunRays.Enabled = true
    SunRays.Intensity = .12
    SunRays.Spread = .9

    DOF.Enabled = false

    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 3
        Lighting.ExposureCompensation = .1
    end)

end

local function Cinematic()

    Bloom.Enabled = true
    Bloom.Intensity = .5
    Bloom.Size = 30
    Bloom.Threshold = .8

    Color.Enabled = true
    Color.Brightness = -.02
    Color.Contrast = .2
    Color.Saturation = .08

    Atmosphere.Enabled = true
    Atmosphere.Density = .28
    Atmosphere.Haze = 1
    Atmosphere.Glare = .08

    SunRays.Enabled = true
    SunRays.Intensity = .15

    DOF.Enabled = true

    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2.5
        Lighting.ExposureCompensation = 0
    end)

end

local function Natural()

    Bloom.Enabled = true
    Bloom.Intensity = .2
    Bloom.Size = 18
    Bloom.Threshold = 1

    Color.Enabled = true
    Color.Brightness = 0
    Color.Contrast = .05
    Color.Saturation = .04

    Atmosphere.Enabled = true
    Atmosphere.Density = .17
    Atmosphere.Haze = .5
    Atmosphere.Glare = .03

    SunRays.Enabled = true
    SunRays.Intensity = .05

    DOF.Enabled = false

end

local function Performance()

    Bloom.Enabled = false
    Atmosphere.Enabled = false
    SunRays.Enabled = false
    DOF.Enabled = false

    Color.Enabled = true
    Color.Brightness = 0
    Color.Contrast = 0
    Color.Saturation = 0

    pcall(function()
        Lighting.GlobalShadows = false
    end)

end

--========================================================
-- BUTTONS
--========================================================

Section("GRAPHICS PRESETS")

Button("⚡  ULTRA REALISTIC",Ultra)
Button("🎬  CINEMATIC",Cinematic)
Button("🌤  NATURAL",Natural)
Button("🚀  PERFORMANCE",Performance)

Section("VISUAL EFFECTS")

Toggle("Bloom",true,function(v)
    Bloom.Enabled = v
end)

Toggle("Sun Rays",true,function(v)
    SunRays.Enabled = v
end)

Toggle("Atmosphere",true,function(v)
    Atmosphere.Enabled = v
end)

Toggle("Depth Of Field",false,function(v)
    DOF.Enabled = v
end)

Section("SYSTEM")

Button("↻  RESET / ULTRA",function()
    Ultra()
end)

Button("✕  CLOSE MOD",function()

    DeleteEffect("MANI_Bloom")
    DeleteEffect("MANI_Color")
    DeleteEffect("MANI_Atmosphere")
    DeleteEffect("MANI_SunRays")
    DeleteEffect("MANI_DOF")

    ScreenGui:Destroy()

end)

--========================================================
-- CANVAS SIZE
--========================================================

task.wait()

Scroll.CanvasSize = UDim2.new(
    0,
    0,
    0,
    Layout.AbsoluteContentSize.Y + 15
)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

    Scroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        Layout.AbsoluteContentSize.Y + 15
    )

end)

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

    end

end)

Header.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then return end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

Min.Activated:Connect(function()

    minimized = not minimized

    if minimized then

        Scroll.Visible = false
        Main.Size = UDim2.fromOffset(380,60)
        Min.Text = "+"

    else

        Scroll.Visible = true
        Main.Size = UDim2.fromOffset(380,480)
        Min.Text = "—"

    end

end)

--========================================================
-- MOBILE RESPONSIVE
--========================================================

local function Responsive()

    local camera = workspace.CurrentCamera

    if not camera then return end

    local size = camera.ViewportSize

    if size.X < 600 then

        Main.Size = UDim2.new(.88,0,0,450)
        Main.Position = UDim2.new(.06,0,.5,-225)

    else

        Main.Size = UDim2.fromOffset(380,480)
        Main.Position = UDim2.new(.5,-190,.5,-240)

    end

end

Responsive()

pcall(function()

    workspace.CurrentCamera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(Responsive)

end)

--========================================================
-- START
--========================================================

Ultra()

print("================================")
print("MANI GRAPHICS MOD V1.1 LOADED")
print("GUI PARENT:",GuiParent:GetFullName())
print("================================")
```
