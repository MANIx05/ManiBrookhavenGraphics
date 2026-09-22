```lua
--[[
=========================================================
        MANI UNIVERSAL GRAPHICS MOD V.1
        Client-Side Graphics Enhancement
        PC + MOBILE
=========================================================
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- CONFIG
--========================================================

local GUI_NAME = "MANI_Universal_Graphics_Mod_V1"

-- Remove previous version
pcall(function()
    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end
end)

--========================================================
-- EFFECT CLEANUP
--========================================================

local EFFECT_NAMES = {
    "MANI_Bloom",
    "MANI_ColorCorrection",
    "MANI_Atmosphere",
    "MANI_SunRays",
    "MANI_DepthOfField"
}

local function removeEffects()
    for _, name in ipairs(EFFECT_NAMES) do
        local obj = Lighting:FindFirstChild(name)
        if obj then
            obj:Destroy()
        end
    end
end

removeEffects()

--========================================================
-- EFFECT CREATION
--========================================================

local Bloom = Instance.new("BloomEffect")
Bloom.Name = "MANI_Bloom"
Bloom.Parent = Lighting
Bloom.Enabled = true
Bloom.Intensity = 0.35
Bloom.Size = 24
Bloom.Threshold = 1

local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Name = "MANI_ColorCorrection"
ColorCorrection.Parent = Lighting
ColorCorrection.Enabled = true
ColorCorrection.Brightness = 0
ColorCorrection.Contrast = 0.08
ColorCorrection.Saturation = 0.08
ColorCorrection.TintColor = Color3.fromRGB(255,255,255)

local Atmosphere = Instance.new("Atmosphere")
Atmosphere.Name = "MANI_Atmosphere"
Atmosphere.Parent = Lighting
Atmosphere.Density = 0.25
Atmosphere.Offset = 0.15
Atmosphere.Color = Color3.fromRGB(199,216,255)
Atmosphere.Decay = Color3.fromRGB(106,112,125)
Atmosphere.Glare = 0.05
Atmosphere.Haze = 0.8

local SunRays = Instance.new("SunRaysEffect")
SunRays.Name = "MANI_SunRays"
SunRays.Parent = Lighting
SunRays.Enabled = true
SunRays.Intensity = 0.08
SunRays.Spread = 0.85

local DOF = Instance.new("DepthOfFieldEffect")
DOF.Name = "MANI_DepthOfField"
DOF.Parent = Lighting
DOF.Enabled = false
DOF.FarIntensity = 0.08
DOF.FocusDistance = 50
DOF.InFocusRadius = 35
DOF.NearIntensity = 0.03

--========================================================
-- GUI
--========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(390, 510)
Main.Position = UDim2.new(0.5, -195, 0.5, -255)
Main.BackgroundColor3 = Color3.fromRGB(12,12,16)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,16)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(75,75,95)
Stroke.Thickness = 1
Stroke.Transparency = 0.35
Stroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,58)
Header.BackgroundColor3 = Color3.fromRGB(20,20,27)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,16)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-105,0,28)
Title.Position = UDim2.fromOffset(18,7)
Title.BackgroundTransparency = 1
Title.Text = "MANI UNIVERSAL"
Title.TextColor3 = Color3.fromRGB(245,245,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1,-105,0,18)
Subtitle.Position = UDim2.fromOffset(18,32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "GRAPHICS MOD  •  V1.0"
Subtitle.TextColor3 = Color3.fromRGB(145,145,165)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.fromOffset(36,30)
MinButton.Position = UDim2.new(1,-82,0,14)
MinButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
MinButton.Text = "—"
MinButton.TextColor3 = Color3.fromRGB(235,235,245)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 16
MinButton.AutoButtonColor = false
MinButton.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,8)
MinCorner.Parent = MinButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(36,30)
CloseButton.Position = UDim2.new(1,-42,0,14)
CloseButton.BackgroundColor3 = Color3.fromRGB(55,25,30)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255,130,140)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 19
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,8)
CloseCorner.Parent = CloseButton

--========================================================
-- CONTENT
--========================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,1,-72)
Scroll.Position = UDim2.fromOffset(10,66)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,125)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,9)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0,15)
Padding.Parent = Scroll

--========================================================
-- HELPERS
--========================================================

local function makeSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-6,0,25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(135,135,160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = Scroll
    return label
end

local function makeButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,-6,0,43)
    button.BackgroundColor3 = Color3.fromRGB(25,25,33)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(235,235,245)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50,50,65)
    stroke.Transparency = 0.4
    stroke.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button,TweenInfo.new(.15),{
            BackgroundColor3 = Color3.fromRGB(35,35,47)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button,TweenInfo.new(.15),{
            BackgroundColor3 = Color3.fromRGB(25,25,33)
        }):Play()
    end)

    button.Activated:Connect(callback)

    return button
end

local function makeToggle(text, default, callback)
    local state = default

    local button = makeButton("", function()
        state = not state
        callback(state)

        if state then
            button.Text = text .. "     ON"
            button.TextColor3 = Color3.fromRGB(150,210,255)
        else
            button.Text = text .. "     OFF"
            button.TextColor3 = Color3.fromRGB(170,170,180)
        end
    end)

    if state then
        button.Text = text .. "     ON"
        button.TextColor3 = Color3.fromRGB(150,210,255)
    else
        button.Text = text .. "     OFF"
    end

    return button
end

--========================================================
-- PRESETS
--========================================================

makeSection("GRAPHICS PRESETS")

local function ultra()
    Bloom.Enabled = true
    Bloom.Intensity = 0.42
    Bloom.Size = 32
    Bloom.Threshold = 0.85

    ColorCorrection.Enabled = true
    ColorCorrection.Brightness = 0.02
    ColorCorrection.Contrast = 0.16
    ColorCorrection.Saturation = 0.12

    Atmosphere.Enabled = true
    Atmosphere.Density = 0.22
    Atmosphere.Haze = 0.7
    Atmosphere.Glare = 0.08

    SunRays.Enabled = true
    SunRays.Intensity = 0.12
    SunRays.Spread = 0.9

    DOF.Enabled = false

    Lighting.Brightness = 3
    Lighting.ExposureCompensation = 0.15
    Lighting.GlobalShadows = true
end

local function cinematic()
    Bloom.Enabled = true
    Bloom.Intensity = 0.55
    Bloom.Size = 28
    Bloom.Threshold = 0.75

    ColorCorrection.Enabled = true
    ColorCorrection.Brightness = -0.02
    ColorCorrection.Contrast = 0.2
    ColorCorrection.Saturation = 0.05

    Atmosphere.Enabled = true
    Atmosphere.Density = 0.28
    Atmosphere.Haze = 1.1
    Atmosphere.Glare = 0.1

    SunRays.Enabled = true
    SunRays.Intensity = 0.15

    DOF.Enabled = true
    DOF.FarIntensity = 0.12
    DOF.NearIntensity = 0.04

    Lighting.Brightness = 2.5
    Lighting.ExposureCompensation = 0
    Lighting.GlobalShadows = true
end

local function natural()
    Bloom.Enabled = true
    Bloom.Intensity = 0.18
    Bloom.Size = 18
    Bloom.Threshold = 1.1

    ColorCorrection.Enabled = true
    ColorCorrection.Brightness = 0
    ColorCorrection.Contrast = 0.05
    ColorCorrection.Saturation = 0.04

    Atmosphere.Enabled = true
    Atmosphere.Density = 0.18
    Atmosphere.Haze = 0.5
    Atmosphere.Glare = 0.03

    SunRays.Enabled = true
    SunRays.Intensity = 0.05

    DOF.Enabled = false

    Lighting.Brightness = 2
    Lighting.ExposureCompensation = 0
    Lighting.GlobalShadows = true
end

local function performance()
    Bloom.Enabled = false
    ColorCorrection.Enabled = true
    ColorCorrection.Brightness = 0
    ColorCorrection.Contrast = 0
    ColorCorrection.Saturation = 0

    Atmosphere.Enabled = false
    SunRays.Enabled = false
    DOF.Enabled = false

    Lighting.GlobalShadows = false
end

makeButton("⚡  ULTRA REALISTIC", ultra)
makeButton("🎬  CINEMATIC", cinematic)
makeButton("🌤  NATURAL", natural)
makeButton("🚀  PERFORMANCE", performance)

--========================================================
-- EFFECTS
--========================================================

makeSection("VISUAL EFFECTS")

makeToggle("Bloom", true, function(v)
    Bloom.Enabled = v
end)

makeToggle("Sun Rays", true, function(v)
    SunRays.Enabled = v
end)

makeToggle("Atmosphere", true, function(v)
    Atmosphere.Enabled = v
end)

makeToggle("Depth Of Field", false, function(v)
    DOF.Enabled = v
end)

--========================================================
-- RESET
--========================================================

makeSection("SYSTEM")

makeButton("↻  RESET GRAPHICS", function()

    Bloom.Enabled = false
    ColorCorrection.Enabled = false
    Atmosphere.Enabled = false
    SunRays.Enabled = false
    DOF.Enabled = false

    Lighting.Brightness = 2
    Lighting.ExposureCompensation = 0
    Lighting.GlobalShadows = true

    task.wait(.15)

    ultra()
end)

makeButton("✕  REMOVE MOD", function()

    removeEffects()

    pcall(function()
        ScreenGui:Destroy()
    end)
end)

--========================================================
-- DRAG SYSTEM
--========================================================

local dragging = false
local dragStart
local startPos

local function updateDrag(input)

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateDrag(input)
    end

end)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

MinButton.Activated:Connect(function()

    minimized = not minimized

    if minimized then

        Scroll.Visible = false

        TweenService:Create(
            Main,
            TweenInfo.new(.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(390,58)}
        ):Play()

        MinButton.Text = "+"

    else

        Scroll.Visible = true

        TweenService:Create(
            Main,
            TweenInfo.new(.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(390,510)}
        ):Play()

        MinButton.Text = "—"
    end
end)

CloseButton.Activated:Connect(function()
    removeEffects()
    ScreenGui:Destroy()
end)

--========================================================
-- RESPONSIVE MOBILE SCALE
--========================================================

local function resizeGUI()

    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize

    if viewport.X < 500 then
        Main.Size = UDim2.new(0.88,0,0,470)
        Main.Position = UDim2.new(0.06,0,0.5,-235)
    else
        Main.Size = UDim2.fromOffset(390,510)
        Main.Position = UDim2.new(0.5,-195,0.5,-255)
    end
end

resizeGUI()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeGUI)
end

--========================================================
-- INITIAL PRESET
--========================================================

ultra()

--========================================================
-- UPDATE CANVAS
--========================================================

task.defer(function()
    task.wait()
    Scroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        Layout.AbsoluteContentSize.Y + 20
    )
end)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        Layout.AbsoluteContentSize.Y + 20
    )
end)

print("MANI UNIVERSAL GRAPHICS MOD V.1 LOADED")
```
