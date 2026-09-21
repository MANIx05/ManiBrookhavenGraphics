--========================================================
-- MANI PROP WING V.2
-- DELTA EXECUTOR
--========================================================

repeat task.wait() until game:IsLoaded()

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================
-- GUI PARENT
--========================================================

local function getGuiParent()

    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)

        if ok and hui then
            return hui
        end
    end

    local CoreGui = game:GetService("CoreGui")

    local ok = pcall(function()
        return CoreGui.Name
    end)

    if ok then
        return CoreGui
    end

    return Player:WaitForChild("PlayerGui")
end

local GUI_PARENT = getGuiParent()

--========================================================
-- REMOVE OLD VERSION
--========================================================

pcall(function()

    local old = GUI_PARENT:FindFirstChild("MANI_PROP_WING_V2")

    if old then
        old:Destroy()
    end

end)

--========================================================
-- CONFIG
--========================================================

local Config = {

    MaxProps = 15,

    LeftProps = 6,
    RightProps = 6,

    WingSize = 1.00,

    Spread = 1.00,

    WaistHeight = 0,

    AnimationSpeed = 2.0,

    FlapStrength = 0.75,

    UpdateRate = 0.14,

    BaseDistance = 2.8,

    DistanceStep = 0.95,

    VerticalStep = 0.42,

    BackOffset = -0.7,
}

--========================================================
-- CHARACTER
--========================================================

local Character
local HRP
local Humanoid

local function updateCharacter()

    Character = Player.Character
        or Player.CharacterAdded:Wait()

    HRP = Character:WaitForChild(
        "HumanoidRootPart",
        10
    )

    Humanoid = Character:FindFirstChildOfClass(
        "Humanoid"
    )

end

updateCharacter()

Player.CharacterAdded:Connect(function()

    task.wait(0.8)

    pcall(updateCharacter)

end)

--========================================================
-- GUI
--========================================================

local GUI = Instance.new("ScreenGui")

GUI.Name = "MANI_PROP_WING_V2"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

GUI.Parent = GUI_PARENT

--========================================================
-- MAIN
--========================================================

local Main = Instance.new("Frame")

Main.Name = "Main"

Main.Size = UDim2.fromOffset(
    245,
    300
)

Main.Position = UDim2.new(
    0,
    25,
    0.5,
    -150
)

Main.BackgroundColor3 =
    Color3.fromRGB(12, 12, 17)

Main.BorderSizePixel = 0

Main.Parent = GUI

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 13)

MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")

MainStroke.Color =
    Color3.fromRGB(72, 72, 86)

MainStroke.Transparency = 0.25
MainStroke.Thickness = 1

MainStroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")

Header.Size =
    UDim2.new(1, 0, 0, 42)

Header.BackgroundColor3 =
    Color3.fromRGB(21, 21, 28)

Header.BorderSizePixel = 0

Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")

HeaderCorner.CornerRadius =
    UDim.new(0, 13)

HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")

HeaderFix.Size =
    UDim2.new(1, 0, 0, 12)

HeaderFix.Position =
    UDim2.new(0, 0, 1, -12)

HeaderFix.BackgroundColor3 =
    Color3.fromRGB(21, 21, 28)

HeaderFix.BorderSizePixel = 0

HeaderFix.Parent = Header

--========================================================
-- TITLE
--========================================================

local Title = Instance.new("TextLabel")

Title.BackgroundTransparency = 1

Title.Position =
    UDim2.fromOffset(12, 5)

Title.Size =
    UDim2.new(1, -60, 0, 18)

Title.Text =
    "MANI PROP WING"

Title.TextColor3 =
    Color3.fromRGB(245, 245, 250)

Title.TextSize = 13
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = Header

local Version = Instance.new("TextLabel")

Version.BackgroundTransparency = 1

Version.Position =
    UDim2.fromOffset(12, 22)

Version.Size =
    UDim2.new(1, -60, 0, 12)

Version.Text =
    "V.2  •  WAIST WING SYSTEM"

Version.TextColor3 =
    Color3.fromRGB(120, 120, 135)

Version.TextSize = 7

Version.Font =
    Enum.Font.Gotham

Version.TextXAlignment =
    Enum.TextXAlignment.Left

Version.Parent = Header

--========================================================
-- MINIMIZE
--========================================================

local Min = Instance.new("TextButton")

Min.Size =
    UDim2.fromOffset(28, 28)

Min.Position =
    UDim2.new(1, -34, 0, 7)

Min.BackgroundColor3 =
    Color3.fromRGB(35, 35, 44)

Min.BorderSizePixel = 0

Min.Text = "−"

Min.TextColor3 =
    Color3.fromRGB(235, 235, 240)

Min.TextSize = 17

Min.Font =
    Enum.Font.GothamBold

Min.Parent = Header

local MinCorner = Instance.new("UICorner")

MinCorner.CornerRadius =
    UDim.new(0, 7)

MinCorner.Parent = Min

--========================================================
-- CONTENT
--========================================================

local Content = Instance.new("ScrollingFrame")

Content.Position =
    UDim2.fromOffset(9, 48)

Content.Size =
    UDim2.new(1, -18, 1, -57)

Content.BackgroundTransparency = 1

Content.BorderSizePixel = 0

Content.ScrollBarThickness = 3

Content.ScrollBarImageColor3 =
    Color3.fromRGB(80, 80, 95)

Content.CanvasSize =
    UDim2.new(0, 0, 0, 430)

Content.Parent = Main

--========================================================
-- STATUS
--========================================================

local Status = Instance.new("TextLabel")

Status.Size =
    UDim2.new(1, -5, 0, 23)

Status.BackgroundTransparency = 1

Status.Text =
    "● V2 READY"

Status.TextColor3 =
    Color3.fromRGB(100, 255, 170)

Status.TextSize = 10

Status.Font =
    Enum.Font.GothamMedium

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent = Content

--========================================================
-- HELPER BUTTON
--========================================================

local function createButton(
    name,
    text,
    x,
    y,
    width
)

    local button =
        Instance.new("TextButton")

    button.Name = name

    button.Size =
        UDim2.fromOffset(
            width or 70,
            31
        )

    button.Position =
        UDim2.fromOffset(x, y)

    button.BackgroundColor3 =
        Color3.fromRGB(28, 28, 37)

    button.BorderSizePixel = 0

    button.Text = text

    button.TextColor3 =
        Color3.fromRGB(225, 225, 232)

    button.TextSize = 9

    button.Font =
        Enum.Font.GothamBold

    button.Parent = Content

    local c = Instance.new("UICorner")

    c.CornerRadius =
        UDim.new(0, 7)

    c.Parent = button

    return button
end

--========================================================
-- VALUE LABEL
--========================================================

local function createLabel(
    text,
    y
)

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(1, -5, 0, 18)

    label.Position =
        UDim2.fromOffset(0, y)

    label.BackgroundTransparency = 1

    label.Text = text

    label.TextColor3 =
        Color3.fromRGB(155, 155, 170)

    label.TextSize = 8

    label.Font =
        Enum.Font.GothamMedium

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = Content

    return label
end

--========================================================
-- WING TOGGLE
--========================================================

local WingButton =
    createButton(
        "WingToggle",
        "WING  •  OFF",
        0,
        28,
        112
    )

local ResetButton =
    createButton(
        "Reset",
        "RESET",
        118,
        28,
        105
    )

--========================================================
-- SIZE
--========================================================

local SizeLabel =
    createLabel(
        "WING SIZE  •  100%",
        68
    )

local SizeMinus =
    createButton(
        "SizeMinus",
        "−",
        0,
        87,
        48
    )

local SizePlus =
    createButton(
        "SizePlus",
        "+",
        174,
        87,
        48
    )

--========================================================
-- SPREAD
--========================================================

local SpreadLabel =
    createLabel(
        "SPREAD  •  100%",
        125
    )

local SpreadMinus =
    createButton(
        "SpreadMinus",
        "−",
        0,
        144,
        48
    )

local SpreadPlus =
    createButton(
        "SpreadPlus",
        "+",
        174,
        144,
        48
    )

--========================================================
-- SPEED
--========================================================

local SpeedLabel =
    createLabel(
        "ANIMATION SPEED  •  2.0",
        182
    )

local SpeedMinus =
    createButton(
        "SpeedMinus",
        "−",
        0,
        201,
        48
    )

local SpeedPlus =
    createButton(
        "SpeedPlus",
        "+",
        174,
        201,
        48
    )

--========================================================
-- FLAP
--========================================================

local FlapLabel =
    createLabel(
        "FLAP STRENGTH  •  0.75",
        239
    )

local FlapMinus =
    createButton(
        "FlapMinus",
        "−",
        0,
        258,
        48
    )

local FlapPlus =
    createButton(
        "FlapPlus",
        "+",
        174,
        258,
        48
    )

--========================================================
-- WAIST HEIGHT
--========================================================

local HeightLabel =
    createLabel(
        "WAIST HEIGHT  •  0.0",
        296
    )

local HeightMinus =
    createButton(
        "HeightMinus",
        "DOWN",
        0,
        315,
        72
    )

local HeightPlus =
    createButton(
        "HeightPlus",
        "UP",
        150,
        315,
        72
    )

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            Main.Position

    end
end)

UIS.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - dragStart

        Main.Position =
            UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = false
    end
end)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

Min.MouseButton1Click:Connect(function()

    minimized = not minimized

    if minimized then

        Content.Visible = false

        Main.Size =
            UDim2.fromOffset(
                245,
                42
            )

    else

        Content.Visible = true

        Main.Size =
            UDim2.fromOffset(
                245,
                300
            )

    end
end)

--========================================================
-- PROP FINDER
--========================================================

local function getPropsFolder()

    local wc =
        workspace:FindFirstChild(
            "WorkspaceCom"
        )

    if not wc then
        return nil
    end

    return wc:FindFirstChild(
        "001_TrafficCones"
    )
end

local function getProps()

    local folder =
        getPropsFolder()

    if not folder then
        return {}
    end

    local result = {}

    for _, object in
        ipairs(folder:GetChildren()) do

        if string.find(
            object.Name,
            Player.Name,
            1,
            true
        ) then

            if object:FindFirstChild(
                "SetCurrentCFrame"
            ) then

                table.insert(
                    result,
                    object
                )
            end
        end

        if #result >= Config.MaxProps then
            break
        end
    end

    table.sort(
        result,
        function(a, b)
            return a.Name < b.Name
        end
    )

    return result
end

--========================================================
-- REMOTE
--========================================================

local function moveProp(prop, cf)

    if not prop
        or not prop.Parent then
        return
    end

    local remote =
        prop:FindFirstChild(
            "SetCurrentCFrame"
        )

    if not remote then
        return
    end

    pcall(function()

        remote:InvokeServer(cf)

    end)
end

--========================================================
-- WING POSITION
--========================================================

local function getWingPosition(
    side,
    index,
    flap
)

    if not HRP then
        return nil
    end

    local sideSign = side

    local distance =
        (
            Config.BaseDistance
            + ((index - 1)
            * Config.DistanceStep)
        )
        * Config.WingSize
        * Config.Spread

    local x =
        sideSign * distance

    local y =
        Config.WaistHeight
        + (
            (index - 1)
            * Config.VerticalStep
            * Config.WingSize
        )

    local z =
        Config.BackOffset
        - ((index - 1) * 0.18)

    -- Wing flap
    y += flap

    -- Waist anchor
    local waist =
        HRP.CFrame:PointToWorldSpace(
            Vector3.new(
                0,
                -1.05,
                0
            )
        )

    local position =
        waist
        + HRP.CFrame.RightVector * x
        + HRP.CFrame.UpVector * y
        + HRP.CFrame.LookVector * z

    return position
end

--========================================================
-- ARRANGE
--========================================================

local function arrange()

    if not HRP then

        Status.Text =
            "● CHARACTER NOT READY"

        return
    end

    local props =
        getProps()

    if #props == 0 then

        Status.Text =
            "● NO PROPS FOUND"

        Status.TextColor3 =
            Color3.fromRGB(
                255,
                170,
                80
            )

        return
    end

    Status.Text =
        "● " .. #props .. " PROPS"

    Status.TextColor3 =
        Color3.fromRGB(
            100,
            255,
            170
        )

    for i, prop in
        ipairs(props) do

        local cf

        if i <= 6 then

            local pos =
                getWingPosition(
                    -1,
                    i,
                    0
                )

            if pos then

                cf =
                    CFrame.new(pos)
                    * HRP.CFrame.Rotation

            end

        elseif i <= 12 then

            local n = i - 6

            local pos =
                getWingPosition(
                    1,
                    n,
                    0
                )

            if pos then

                cf =
                    CFrame.new(pos)
                    * HRP.CFrame.Rotation

            end

        else

            local n = i - 12

            local pos =
                HRP.CFrame:PointToWorldSpace(
                    Vector3.new(
                        0,
                        0.8 + n * 0.65,
                        -3
                    )
                )

            cf =
                CFrame.new(pos)
                * HRP.CFrame.Rotation
        end

        if cf then
            moveProp(prop, cf)
        end

        task.wait(0.06)
    end

    Status.Text =
        "● 6L + 6R + 3 EXTRA"

end

--========================================================
-- ANIMATION
--========================================================

local WingEnabled = false
local AnimationTime = 0
local LastUpdate = 0

RunService.Heartbeat:Connect(
    function(dt)

        if not WingEnabled then
            return
        end

        if not HRP then
            return
        end

        if tick() - LastUpdate
            < Config.UpdateRate then
            return
        end

        LastUpdate = tick()

        AnimationTime +=
            dt * Config.AnimationSpeed

        local props =
            getProps()

        for i, prop in
            ipairs(props) do

            if i <= 12 then

                local side
                local index

                if i <= 6 then

                    side = -1
                    index = i

                else

                    side = 1
                    index = i - 6

                end

                local phase =
                    AnimationTime
                    + index * 0.38

                local flap =
                    math.sin(phase)
                    * Config.FlapStrength

                local pos =
                    getWingPosition(
                        side,
                        index,
                        flap
                    )

                if pos then

                    local tilt =
                        math.sin(phase)
                        * Config.FlapStrength
                        * 14

                    local rotation =
                        HRP.CFrame.Rotation
                        * CFrame.Angles(
                            0,
                            0,
                            math.rad(
                                side * tilt
                            )
                        )

                    moveProp(
                        prop,
                        CFrame.new(pos)
                        * rotation
                    )
                end
            end
        end
    end
)

--========================================================
-- BUTTON HELPER
--========================================================

local function changeValue(
    field,
    amount,
    min,
    max
)

    Config[field] =
        math.clamp(
            Config[field] + amount,
            min,
            max
        )
end

--========================================================
-- SIZE CONTROLS
--========================================================

SizeMinus.MouseButton1Click:Connect(
    function()

        changeValue(
            "WingSize",
            -0.10,
            0.25,
            2
        )

        SizeLabel.Text =
            "WING SIZE  •  "
            .. math.floor(
                Config.WingSize * 100
            )
            .. "%"

        arrange()
    end
)

SizePlus.MouseButton1Click:Connect(
    function()

        changeValue(
            "WingSize",
            0.10,
            0.25,
            2
        )

        SizeLabel.Text =
            "WING SIZE  •  "
            .. math.floor(
                Config.WingSize * 100
            )
            .. "%"

        arrange()
    end
)

--========================================================
-- SPREAD
--========================================================

SpreadMinus.MouseButton1Click:Connect(
    function()

        changeValue(
            "Spread",
            -0.10,
            0.40,
            2
        )

        SpreadLabel.Text =
            "SPREAD  •  "
            .. math.floor(
                Config.Spread * 100
            )
            .. "%"

        arrange()
    end
)

SpreadPlus.MouseButton1Click:Connect(
    function()

        changeValue(
            "Spread",
            0.10,
            0.40,
            2
        )

        SpreadLabel.Text =
            "SPREAD  •  "
            .. math.floor(
                Config.Spread * 100
            )
            .. "%"

        arrange()
    end
)

--========================================================
-- SPEED
--========================================================

SpeedMinus.MouseButton1Click:Connect(
    function()

        changeValue(
            "AnimationSpeed",
            -0.25,
            0.2,
            5
        )

        SpeedLabel.Text =
            "ANIMATION SPEED  •  "
            .. string.format(
                "%.2f",
                Config.AnimationSpeed
            )

    end
)

SpeedPlus.MouseButton1Click:Connect(
    function()

        changeValue(
            "AnimationSpeed",
            0.25,
            0.2,
            5
        )

        SpeedLabel.Text =
            "ANIMATION SPEED  •  "
            .. string.format(
                "%.2f",
                Config.AnimationSpeed
            )

    end
)

--========================================================
-- FLAP
--========================================================

FlapMinus.MouseButton1Click:Connect(
    function()

        changeValue(
            "FlapStrength",
            -0.15,
            0,
            2.5
        )

        FlapLabel.Text =
            "FLAP STRENGTH  •  "
            .. string.format(
                "%.2f",
                Config.FlapStrength
            )

    end
)

FlapPlus.MouseButton1Click:Connect(
    function()

        changeValue(
            "FlapStrength",
            0.15,
            0,
            2.5
        )

        FlapLabel.Text =
            "FLAP STRENGTH  •  "
            .. string.format(
                "%.2f",
                Config.FlapStrength
            )

    end
)

--========================================================
-- WAIST HEIGHT
--========================================================

HeightMinus.MouseButton1Click:Connect(
    function()

        changeValue(
            "WaistHeight",
            -0.25,
            -3,
            3
        )

        HeightLabel.Text =
            "WAIST HEIGHT  •  "
            .. string.format(
                "%.2f",
                Config.WaistHeight
            )

        arrange()
    end
)

HeightPlus.MouseButton1Click:Connect(
    function()

        changeValue(
            "WaistHeight",
            0.25,
            -3,
            3
        )

        HeightLabel.Text =
            "WAIST HEIGHT  •  "
            .. string.format(
                "%.2f",
                Config.WaistHeight
            )

        arrange()
    end
)

--========================================================
-- WING TOGGLE
--========================================================

WingButton.MouseButton1Click:Connect(
    function()

        WingEnabled =
            not WingEnabled

        if WingEnabled then

            WingButton.Text =
                "WING  •  ON"

            WingButton.BackgroundColor3 =
                Color3.fromRGB(
                    35,
                    75,
                    58
                )

            WingButton.TextColor3 =
                Color3.fromRGB(
                    130,
                    255,
                    190
                )

            Status.Text =
                "● WING ANIMATION ON"

        else

            WingButton.Text =
                "WING  •  OFF"

            WingButton.BackgroundColor3 =
                Color3.fromRGB(
                    28,
                    28,
                    37
                )

            WingButton.TextColor3 =
                Color3.fromRGB(
                    225,
                    225,
                    232
                )

            Status.Text =
                "● WING ANIMATION OFF"
        end
    end
)

--========================================================
-- RESET
--========================================================

ResetButton.MouseButton1Click:Connect(
    function()

        Config.WingSize = 1
        Config.Spread = 1
        Config.WaistHeight = 0
        Config.AnimationSpeed = 2
        Config.FlapStrength = 0.75

        SizeLabel.Text =
            "WING SIZE  •  100%"

        SpreadLabel.Text =
            "SPREAD  •  100%"

        SpeedLabel.Text =
            "ANIMATION SPEED  •  2.0"

        FlapLabel.Text =
            "FLAP STRENGTH  •  0.75"

        HeightLabel.Text =
            "WAIST HEIGHT  •  0.0"

        arrange()

    end
)

--========================================================
-- INITIALIZE
--========================================================

Status.Text =
    "● MANI WING V2 LOADED"

Status.TextColor3 =
    Color3.fromRGB(
        100,
        255,
        170
    )

task.wait(0.5)

task.spawn(function()
    arrange()
end)

print(
    "======================================"
)

print(
    " MANI PROP WING V.2"
)

print(
    " WAIST WING SYSTEM"
)

print(
    " 6 LEFT / 6 RIGHT / 3 EXTRA"
)

print(
    "======================================"
)
