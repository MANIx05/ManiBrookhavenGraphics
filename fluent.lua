--// MANI PUMPKIN ROBO V.4
--// 10 PROP ROBOT | PC + MOBILE
--// LocalScript

repeat task.wait() until game:IsLoaded()

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    PropsFolder = {"WorkspaceCom", "001_TrafficCones"},

    MaxProps = 10,

    RobotHeight = 1,
    RobotHeightMin = 0.6,
    RobotHeightMax = 2.0,
    RobotHeightStep = 0.1,

    PropSpacing = 1,
    PropSpacingMin = 0.6,
    PropSpacingMax = 1.8,
    PropSpacingStep = 0.1,

    HeadHeight = 7.2,
    HeadHeightMin = 5.0,
    HeadHeightMax = 10.0,
    HeadHeightStep = 0.2,

    WalkSpeed = 40,
    WalkSpeedMin = 5,
    WalkSpeedMax = 100,
    WalkSpeedStep = 5,

    JumpPower = 50,
    JumpPowerMin = 10,
    JumpPowerMax = 120,
    JumpPowerStep = 5,

    CameraDistance = 22,
    CameraMinDistance = 8,
    CameraMaxDistance = 45,

    CameraHeight = 8,

    Smoothness = 10,
}

--==================================================
-- STATE
--==================================================

local RobotEnabled = false
local RobotLoaded = false

local RobotPosition = HRP.Position
local RobotForward = Vector3.new(0, 0, -1)

local CameraYaw = 0
local CameraPitch = math.rad(12)
local CameraDistance = CONFIG.CameraDistance

local WalkTime = 0
local LastTime = tick()

local Jumping = false
local JumpStart = 0

local HeadHeight = CONFIG.HeadHeight

local RobotParts = {}

local Connections = {}

--==================================================
-- PROP FOLDER
--==================================================

local function getPropsFolder()

    local folder = workspace

    for _, name in ipairs(CONFIG.PropsFolder) do

        folder = folder:FindFirstChild(name)

        if not folder then
            return nil
        end

    end

    return folder
end

local PropsFolder = getPropsFolder()

if not PropsFolder then
    warn("[MANI ROBO] Props folder not found")
    warn("Expected: workspace.WorkspaceCom.001_TrafficCones")
    return
end

--==================================================
-- PROP ORDER
--==================================================

local myProps = {}

for _, v in ipairs(PropsFolder:GetChildren()) do

    if string.find(v.Name, LocalPlayer.Name) then
        table.insert(myProps, v)
    end

end

if #myProps < CONFIG.MaxProps then

    warn(
        "[MANI ROBO] Need 10 props, found:",
        #myProps
    )

end

while #myProps > CONFIG.MaxProps do
    table.remove(myProps)
end

--==================================================
-- ROBOT SLOTS
--==================================================

local SLOT_NAMES = {
    "Head",
    "Waist",
    "RightHand",
    "LeftHand",

    "RightLeg1",
    "RightLeg2",
    "RightLeg3",

    "LeftLeg1",
    "LeftLeg2",
    "LeftLeg3",
}

--==================================================
-- BASE OFFSETS
--==================================================

local BASE_OFFSETS = {

    -- HEAD
    Head = Vector3.new(
        0,
        7.2,
        0
    ),

    -- WAIST
    Waist = Vector3.new(
        0,
        4.0,
        0
    ),

    -- RIGHT HAND
    RightHand = Vector3.new(
        3.0,
        4.0,
        0
    ),

    -- LEFT HAND
    LeftHand = Vector3.new(
        -3.0,
        4.0,
        0
    ),

    -- RIGHT LEG
    RightLeg1 = Vector3.new(
        1.45,
        1.9,
        0
    ),

    RightLeg2 = Vector3.new(
        1.45,
        0.65,
        0
    ),

    RightLeg3 = Vector3.new(
        1.45,
        -0.55,
        0
    ),

    -- LEFT LEG
    LeftLeg1 = Vector3.new(
        -1.45,
        1.9,
        0
    ),

    LeftLeg2 = Vector3.new(
        -1.45,
        0.65,
        0
    ),

    LeftLeg3 = Vector3.new(
        -1.45,
        -0.55,
        0
    ),
}

--==================================================
-- UI
--==================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("MANI_PUMPKIN_ROBO")

if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MANI_PUMPKIN_ROBO"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- MAIN FRAME
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(245, 315)
Main.Position = UDim2.new(0, 25, 0.5, -157)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 72)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -85, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎃 MANI PUMPKIN ROBO"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Version = Instance.new("TextLabel")
Version.Size = UDim2.fromOffset(45, 18)
Version.Position = UDim2.new(1, -82, 0, 12)
Version.BackgroundTransparency = 1
Version.Text = "V.4"
Version.TextColor3 = Color3.fromRGB(150, 150, 165)
Version.TextSize = 10
Version.Font = Enum.Font.GothamBold
Version.Parent = TopBar

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(30, 30)
Minimize.Position = UDim2.new(1, -36, 0, 6)
Minimize.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
Minimize.Text = "—"
Minimize.TextColor3 = Color3.fromRGB(240, 240, 245)
Minimize.TextSize = 15
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = Minimize

--==================================================
-- SCROLL
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Size = UDim2.new(1, -10, 1, -52)
Scroll.Position = UDim2.fromOffset(5, 47)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageTransparency = 0.25
Scroll.CanvasSize = UDim2.fromOffset(0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent = Main

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 7)
Padding.PaddingRight = UDim.new(0, 7)
Padding.PaddingTop = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 8)
Padding.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

--==================================================
-- UI HELPERS
--==================================================

local function createSection(text)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1

    label.Text = text
    label.TextColor3 = Color3.fromRGB(130, 130, 145)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = Scroll

    return label
end

local function createButton(text)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, 0, 0, 35)

    button.BackgroundColor3 = Color3.fromRGB(28, 28, 35)

    button.BorderSizePixel = 0

    button.Text = text
    button.TextColor3 = Color3.fromRGB(235, 235, 240)

    button.TextSize = 11
    button.Font = Enum.Font.GothamMedium

    button.AutoButtonColor = false

    button.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(38, 38, 47)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    end)

    return button
end

local function createValueButton(text)
    return createButton(text)
end

--==================================================
-- STATUS
--==================================================

createSection("ROBOT")

local Status = createButton("●  ROBOT NOT LOADED")

Status.TextColor3 = Color3.fromRGB(180, 180, 190)

local LoadButton = createButton("LOAD 10 PROPS")

--==================================================
-- CONTROL
--==================================================

local ControlButton = createButton("CONTROL : OFF")

local function updateControlText()

    if RobotEnabled then
        ControlButton.Text = "CONTROL : ON"
        ControlButton.TextColor3 = Color3.fromRGB(120, 255, 150)
    else
        ControlButton.Text = "CONTROL : OFF"
        ControlButton.TextColor3 = Color3.fromRGB(235, 235, 240)
    end

end

--==================================================
-- HEAD
--==================================================

createSection("HEAD")

local HeadButton = createValueButton(
    "HEAD HEIGHT : " ..
    string.format("%.1f", HeadHeight)
)

local function updateHeadButton()

    HeadButton.Text =
        "HEAD HEIGHT : " ..
        string.format("%.1f", HeadHeight)

end

--==================================================
-- ROBOT HEIGHT
--==================================================

createSection("ROBOT SIZE")

local HeightButton = createValueButton(
    "ROBOT HEIGHT : " ..
    string.format("%.1f", CONFIG.RobotHeight)
)

--==================================================
-- PROP SPACING
--==================================================

local SpacingButton = createValueButton(
    "PROP SPACING : " ..
    string.format("%.1f", CONFIG.PropSpacing)
)

--==================================================
-- MOVEMENT
--==================================================

createSection("MOVEMENT")

local SpeedButton = createValueButton(
    "WALK SPEED : " ..
    CONFIG.WalkSpeed
)

local JumpButton = createValueButton(
    "JUMP POWER : " ..
    CONFIG.JumpPower
)

--==================================================
-- CAMERA
--==================================================

createSection("CAMERA")

local CameraButton = createValueButton(
    "CAMERA DISTANCE : " ..
    math.floor(CameraDistance)
)

--==================================================
-- PROP ASSIGNMENT LABEL
--==================================================

createSection("10 PROP SLOT MAP")

local SlotInfo = createButton(
    "1 HEAD  •  2 WAIST"
)

local SlotInfo2 = createButton(
    "3 R-HAND  •  4 L-HAND"
)

local SlotInfo3 = createButton(
    "5-7 R-LEG  •  8-10 L-LEG"
)

--==================================================
-- RESIZE HANDLE
--==================================================

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.fromOffset(20, 20)
ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Color3.fromRGB(100, 100, 115)
ResizeHandle.TextSize = 13
ResizeHandle.Parent = Main

--==================================================
-- DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)

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

    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,

        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )

end)

--==================================================
-- RESIZE
--==================================================

local resizing = false
local resizeStart
local resizeSize

ResizeHandle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        resizing = true

        resizeStart = input.Position
        resizeSize = Main.AbsoluteSize

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not resizing then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - resizeStart

    local newWidth = math.clamp(
        resizeSize.X + delta.X,
        210,
        360
    )

    local newHeight = math.clamp(
        resizeSize.Y + delta.Y,
        240,
        600
    )

    Main.Size = UDim2.fromOffset(
        newWidth,
        newHeight
    )

end)

--==================================================
-- MINIMIZE
--==================================================

local minimized = false

Minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    Scroll.Visible = not minimized
    ResizeHandle.Visible = not minimized

    if minimized then

        Main.Size = UDim2.fromOffset(
            245,
            42
        )

        Minimize.Text = "+"

    else

        Main.Size = UDim2.fromOffset(
            245,
            315
        )

        Minimize.Text = "—"

    end

end)

--==================================================
-- PROP SERVER MOVEMENT
--==================================================

local function setPropCFrame(prop, cf)

    if not prop then
        return false
    end

    local remote = prop:FindFirstChild("SetCurrentCFrame")

    if remote and remote:IsA("RemoteFunction") then

        local success = pcall(function()
            remote:InvokeServer(cf)
        end)

        return success
    end

    -- fallback only if actual prop itself supports CFrame
    local success = pcall(function()

        if prop:IsA("BasePart") then
            prop.CFrame = cf
            return
        end

        local part = prop:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

        if part then
            part.CFrame = cf
        end

    end)

    return success
end

--==================================================
-- OFFSET SYSTEM
--==================================================

local function getOffset(name)

    local base = BASE_OFFSETS[name]

    if not base then
        return Vector3.zero
    end

    local scale = CONFIG.RobotHeight

    local x = base.X * scale
    local y = base.Y * scale
    local z = base.Z * scale

    if name == "Head" then

        y = HeadHeight

    end

    -- spacing affects horizontal body width
    if name == "RightHand"
        or string.find(name, "RightLeg") then

        x = x * CONFIG.PropSpacing

    elseif name == "LeftHand"
        or string.find(name, "LeftLeg") then

        x = x * CONFIG.PropSpacing

    end

    return Vector3.new(
        x,
        y,
        z
    )
end

--==================================================
-- ANIMATION OFFSETS
--==================================================

local function getAnimationOffset(name, walking)

    local offset = Vector3.zero

    ------------------------------------------------
    -- IDLE
    ------------------------------------------------

    if not walking then

        local idle = math.sin(WalkTime * 2.2)

        if name == "Head" then

            offset = Vector3.new(
                0,
                idle * 0.04,
                0
            )

        elseif name == "RightHand" then

            offset = Vector3.new(
                0,
                idle * 0.04,
                idle * 0.03
            )

        elseif name == "LeftHand" then

            offset = Vector3.new(
                0,
                idle * 0.04,
                -idle * 0.03
            )

        end

        return offset
    end

    ------------------------------------------------
    -- WALK
    ------------------------------------------------

    local cycle = WalkTime * 8

    local rightPhase = math.sin(cycle)
    local leftPhase = math.sin(cycle + math.pi)

    ------------------------------------------------
    -- RIGHT HAND
    ------------------------------------------------

    if name == "RightHand" then

        offset = Vector3.new(
            0,
            math.abs(rightPhase) * 0.08,
            rightPhase * 0.55
        )

    ------------------------------------------------
    -- LEFT HAND
    ------------------------------------------------

    elseif name == "LeftHand" then

        offset = Vector3.new(
            0,
            math.abs(leftPhase) * 0.08,
            leftPhase * 0.55
        )

    ------------------------------------------------
    -- RIGHT LEG
    ------------------------------------------------

    elseif name == "RightLeg1" then

        offset = Vector3.new(
            0,
            math.abs(rightPhase) * 0.12,
            rightPhase * 0.45
        )

    elseif name == "RightLeg2" then

        offset = Vector3.new(
            0,
            math.abs(rightPhase) * 0.08,
            rightPhase * 0.30
        )

    elseif name == "RightLeg3" then

        offset = Vector3.new(
            0,
            -math.abs(rightPhase) * 0.05,
            rightPhase * 0.18
        )

    ------------------------------------------------
    -- LEFT LEG
    ------------------------------------------------

    elseif name == "LeftLeg1" then

        offset = Vector3.new(
            0,
            math.abs(leftPhase) * 0.12,
            leftPhase * 0.45
        )

    elseif name == "LeftLeg2" then

        offset = Vector3.new(
            0,
            math.abs(leftPhase) * 0.08,
            leftPhase * 0.30
        )

    elseif name == "LeftLeg3" then

        offset = Vector3.new(
            0,
            -math.abs(leftPhase) * 0.05,
            leftPhase * 0.18
        )

    end

    return offset
end

--==================================================
-- JUMP ANIMATION
--==================================================

local function getJumpOffset(name)

    if not Jumping then
        return Vector3.zero
    end

    local elapsed = tick() - JumpStart

    local jumpWave = math.sin(
        math.clamp(elapsed * 5, 0, math.pi)
    )

    if name == "Head" then

        return Vector3.new(
            0,
            jumpWave * 0.15,
            0
        )

    elseif name == "RightHand"
        or name == "LeftHand" then

        return Vector3.new(
            0,
            jumpWave * 0.35,
            0
        )

    elseif string.find(name, "Leg") then

        return Vector3.new(
            0,
            jumpWave * 0.15,
            0
        )
    end

    return Vector3.zero
end

--==================================================
-- ROBOT CFRAME
--==================================================

local function getRobotCFrame(position)

    local forward = RobotForward

    forward = Vector3.new(
        forward.X,
        0,
        forward.Z
    )

    if forward.Magnitude < 0.001 then
        forward = Vector3.new(
            0,
            0,
            -1
        )
    end

    forward = forward.Unit

    return CFrame.lookAt(
        position,
        position + forward,
        Vector3.new(0, 1, 0)
    )
end

--==================================================
-- ASSEMBLE ROBOT
--==================================================

local function assembleRobot()

    RobotParts = {}

    for i = 1, math.min(#myProps, 10) do

        local prop = myProps[i]

        RobotParts[SLOT_NAMES[i]] = prop

    end

    RobotLoaded = true

    Status.Text =
        "●  ROBOT READY  " ..
        tostring(#RobotParts) ..
        "/10"

    Status.TextColor3 =
        Color3.fromRGB(120, 255, 150)

end

--==================================================
-- MOVE ALL ROBOT PROPS
--==================================================

local function updateRobot()

    if not RobotLoaded then
        return
    end

    local walking =
        RobotEnabled
        and Humanoid.MoveDirection.Magnitude > 0.05

    if walking then
        WalkTime += 0.04
    else
        WalkTime += 0.015
    end

    local baseCF = getRobotCFrame(
        RobotPosition
    )

    for _, name in ipairs(SLOT_NAMES) do

        local prop = RobotParts[name]

        if prop then

            local offset =
                getOffset(name)

            local animation =
                getAnimationOffset(
                    name,
                    walking
                )

            local jumpOffset =
                getJumpOffset(name)

            local finalOffset =
                offset
                + animation
                + jumpOffset

            local worldPosition =
                RobotPosition
                + baseCF.RightVector * finalOffset.X
                + Vector3.new(
                    0,
                    finalOffset.Y,
                    0
                )
                + baseCF.LookVector * finalOffset.Z

            local cf = CFrame.lookAt(
                worldPosition,
                worldPosition + RobotForward,
                Vector3.new(0, 1, 0)
            )

            setPropCFrame(
                prop,
                cf
            )

        end

    end
end

--==================================================
-- LOAD BUTTON
--==================================================

LoadButton.MouseButton1Click:Connect(function()

    if RobotLoaded then

        assembleRobot()

        return
    end

    assembleRobot()

end)

--==================================================
-- CONTROL BUTTON
--==================================================

ControlButton.MouseButton1Click:Connect(function()

    if not RobotLoaded then

        Status.Text =
            "●  LOAD ROBOT FIRST"

        Status.TextColor3 =
            Color3.fromRGB(255, 170, 80)

        return
    end

    RobotEnabled = not RobotEnabled

    updateControlText()

    if RobotEnabled then

        RobotPosition = HRP.Position

        -- Keep player's character visible.
        -- Only anchor its root so default
        -- character stays where it is.
        HRP.Anchored = true

        Humanoid.AutoRotate = false

        -- Camera
        workspace.CurrentCamera.CameraType =
            Enum.CameraType.Scriptable

        local look =
            HRP.CFrame.LookVector

        RobotForward = Vector3.new(
            look.X,
            0,
            look.Z
        ).Unit

    else

        HRP.Anchored = false

        Humanoid.AutoRotate = true

        workspace.CurrentCamera.CameraType =
            Enum.CameraType.Custom

        workspace.CurrentCamera.CameraSubject =
            Humanoid
    end

end)

--==================================================
-- HEAD HEIGHT BUTTON
--==================================================

HeadButton.MouseButton1Click:Connect(function()

    HeadHeight += CONFIG.HeadHeightStep

    if HeadHeight >
        CONFIG.HeadHeightMax then

        HeadHeight =
            CONFIG.HeadHeightMin
    end

    updateHeadButton()

end)

--==================================================
-- ROBOT HEIGHT
--==================================================

HeightButton.MouseButton1Click:Connect(function()

    CONFIG.RobotHeight +=
        CONFIG.RobotHeightStep

    if CONFIG.RobotHeight >
        CONFIG.RobotHeightMax then

        CONFIG.RobotHeight =
            CONFIG.RobotHeightMin
    end

    HeightButton.Text =
        "ROBOT HEIGHT : " ..
        string.format(
            "%.1f",
            CONFIG.RobotHeight
        )

end)

--==================================================
-- SPACING
--==================================================

SpacingButton.MouseButton1Click:Connect(function()

    CONFIG.PropSpacing +=
        CONFIG.PropSpacingStep

    if CONFIG.PropSpacing >
        CONFIG.PropSpacingMax then

        CONFIG.PropSpacing =
            CONFIG.PropSpacingMin
    end

    SpacingButton.Text =
        "PROP SPACING : " ..
        string.format(
            "%.1f",
            CONFIG.PropSpacing
        )

end)

--==================================================
-- WALK SPEED
--==================================================

SpeedButton.MouseButton1Click:Connect(function()

    CONFIG.WalkSpeed +=
        CONFIG.WalkSpeedStep

    if CONFIG.WalkSpeed >
        CONFIG.WalkSpeedMax then

        CONFIG.WalkSpeed =
            CONFIG.WalkSpeedMin
    end

    SpeedButton.Text =
        "WALK SPEED : " ..
        CONFIG.WalkSpeed

end)

--==================================================
-- JUMP POWER
--==================================================

JumpButton.MouseButton1Click:Connect(function()

    CONFIG.JumpPower +=
        CONFIG.JumpPowerStep

    if CONFIG.JumpPower >
        CONFIG.JumpPowerMax then

        CONFIG.JumpPower =
            CONFIG.JumpPowerMin
    end

    JumpButton.Text =
        "JUMP POWER : " ..
        CONFIG.JumpPower

end)

--==================================================
-- CAMERA DISTANCE
--==================================================

local function updateCameraButton()

    CameraButton.Text =
        "CAMERA DISTANCE : " ..
        math.floor(CameraDistance)

end

CameraButton.MouseButton1Click:Connect(function()

    CameraDistance += 5

    if CameraDistance >
        CONFIG.CameraMaxDistance then

        CameraDistance =
            CONFIG.CameraMinDistance
    end

    updateCameraButton()

end)

--==================================================
-- CAMERA MOUSE CONTROL
--==================================================

local rotatingCamera = false
local lastMousePosition

UserInputService.InputBegan:Connect(function(input)

    if not RobotEnabled then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseButton2 then

        rotatingCamera = true

        lastMousePosition =
            input.Position
    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton2 then

        rotatingCamera = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not RobotEnabled then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        and rotatingCamera then

        local delta =
            input.Position -
            lastMousePosition

        lastMousePosition =
            input.Position

        CameraYaw -= delta.X * 0.008

        CameraPitch -= delta.Y * 0.005

        CameraPitch =
            math.clamp(
                CameraPitch,
                math.rad(-35),
                math.rad(55)
            )
    end

end)

--==================================================
-- MOUSE WHEEL
--==================================================

UserInputService.InputChanged:Connect(function(input)

    if not RobotEnabled then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseWheel then

        CameraDistance -=
            input.Position.Z * 3

        CameraDistance =
            math.clamp(
                CameraDistance,
                CONFIG.CameraMinDistance,
                CONFIG.CameraMaxDistance
            )

        updateCameraButton()

    end

end)

--==================================================
-- MOBILE CAMERA TOUCH
--==================================================

local touchPositions = {}

local previousPinchDistance = nil

UserInputService.TouchStarted:Connect(function(
    touch
)

    if not RobotEnabled then
        return
    end

    touchPositions[touch] =
        touch.Position

end)

UserInputService.TouchMoved:Connect(function(
    touch
)

    if not RobotEnabled then
        return
    end

    touchPositions[touch] =
        touch.Position

    local touches = {}

    for t, pos in pairs(touchPositions) do

        table.insert(
            touches,
            {
                Touch = t,
                Position = pos
            }
        )

    end

    ------------------------------------------------
    -- TWO FINGER PINCH
    ------------------------------------------------

    if #touches >= 2 then

        local p1 =
            touches[1].Position

        local p2 =
            touches[2].Position

        local distance =
            (p1 - p2).Magnitude

        if previousPinchDistance then

            local change =
                distance -
                previousPinchDistance

            CameraDistance -=
                change * 0.025

            CameraDistance =
                math.clamp(
                    CameraDistance,
                    CONFIG.CameraMinDistance,
                    CONFIG.CameraMaxDistance
                )

            updateCameraButton()

        end

        previousPinchDistance =
            distance

    end

end)

UserInputService.TouchEnded:Connect(function(
    touch
)

    touchPositions[touch] = nil

    previousPinchDistance = nil

end)

--==================================================
-- MOBILE SINGLE FINGER CAMERA
--==================================================

local mobileCameraTouch = nil
local mobileLastPosition = nil

UserInputService.TouchStarted:Connect(function(
    touch
)

    if not RobotEnabled then
        return
    end

    -- Don't take GUI touches
    local guiObjects =
        GuiService:GetGuiObjectsAtPosition(
            touch.Position.X,
            touch.Position.Y
        )

    if #guiObjects > 0 then
        return
    end

    if mobileCameraTouch == nil then

        mobileCameraTouch = touch
        mobileLastPosition =
            touch.Position

    end

end)

UserInputService.TouchMoved:Connect(function(
    touch
)

    if not RobotEnabled then
        return
    end

    if touch ~= mobileCameraTouch then
        return
    end

    local delta =
        touch.Position -
        mobileLastPosition

    mobileLastPosition =
        touch.Position

    CameraYaw -=
        delta.X * 0.008

    CameraPitch -=
        delta.Y * 0.005

    CameraPitch =
        math.clamp(
            CameraPitch,
            math.rad(-35),
            math.rad(55)
        )

end)

UserInputService.TouchEnded:Connect(function(
    touch
)

    if touch == mobileCameraTouch then

        mobileCameraTouch = nil
        mobileLastPosition = nil

    end

end)

--==================================================
-- JUMP DETECTION
--==================================================

Humanoid.Jumping:Connect(function(
    active
)

    if not RobotEnabled then
        return
    end

    if active then

        Jumping = true
        JumpStart = tick()

    end

end)

Humanoid.StateChanged:Connect(function(
    oldState,
    newState
)

    if newState ==
        Enum.HumanoidStateType.Landed then

        Jumping = false

    end

end)

--==================================================
-- CAMERA
--==================================================

local function updateCamera(dt)

    if not RobotEnabled then
        return
    end

    local camera =
        workspace.CurrentCamera

    local target =
        RobotPosition
        + Vector3.new(
            0,
            CONFIG.CameraHeight,
            0
        )

    local rotation =
        CFrame.Angles(
            0,
            CameraYaw,
            0
        )
        *
        CFrame.Angles(
            CameraPitch,
            0,
            0
        )

    local cameraOffset =
        rotation:VectorToWorldSpace(
            Vector3.new(
                0,
                0,
                CameraDistance
            )
        )

    local desiredPosition =
        target + cameraOffset

    local desiredCF =
        CFrame.lookAt(
            desiredPosition,
            target,
            Vector3.new(0, 1, 0)
        )

    local alpha =
        math.clamp(
            dt * 8,
            0,
            1
        )

    camera.CFrame =
        camera.CFrame:Lerp(
            desiredCF,
            alpha
        )

end

--==================================================
-- ROBOT MOVEMENT
--==================================================

local function updateMovement(dt)

    if not RobotEnabled then
        return
    end

    local moveDirection =
        Humanoid.MoveDirection

    if moveDirection.Magnitude > 0.05 then

        local direction =
            Vector3.new(
                moveDirection.X,
                0,
                moveDirection.Z
            )

        if direction.Magnitude > 0.001 then

            direction =
                direction.Unit

            RobotPosition +=
                direction
                * CONFIG.WalkSpeed
                * dt

            RobotForward =
                RobotForward:Lerp(
                    direction,
                    math.clamp(
                        dt * 8,
                        0,
                        1
                    )
                )

            if RobotForward.Magnitude >
                0.001 then

                RobotForward =
                    RobotForward.Unit

            end

        end

    end

end

--==================================================
-- JUMP MOVEMENT
--==================================================

local robotVerticalVelocity = 0

RunService.Heartbeat:Connect(function(dt)

    if not RobotEnabled then
        return
    end

    -- Default Roblox jump input
    if Humanoid.Jump and
        math.abs(robotVerticalVelocity) < 0.1 then

        robotVerticalVelocity =
            CONFIG.JumpPower

        Jumping = true
        JumpStart = tick()

    end

    robotVerticalVelocity -=
        workspace.Gravity * dt

    RobotPosition +=
        Vector3.new(
            0,
            robotVerticalVelocity * dt,
            0
        )

    -- Ground reference
    local groundY =
        HRP.Position.Y

    if RobotPosition.Y <
        groundY then

        RobotPosition =
            Vector3.new(
                RobotPosition.X,
                groundY,
                RobotPosition.Z
            )

        robotVerticalVelocity = 0

        Jumping = false

    end

end)

--==================================================
-- MAIN RENDER LOOP
--==================================================

RunService.RenderStepped:Connect(function(dt)

    if not RobotLoaded then
        return
    end

    if RobotEnabled then

        updateMovement(dt)

        updateRobot()

        updateCamera(dt)

    else

        -- Keep assembled robot around
        -- player's current position

        RobotPosition =
            RobotPosition:Lerp(
                HRP.Position,
                math.clamp(
                    dt * 4,
                    0,
                    1
                )
            )

    end

end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

LocalPlayer.CharacterAdded:Connect(function(
    newCharacter
)

    Character = newCharacter

    Humanoid =
        newCharacter:WaitForChild(
            "Humanoid"
        )

    HRP =
        newCharacter:WaitForChild(
            "HumanoidRootPart"
        )

    if RobotEnabled then

        HRP.Anchored = true
        Humanoid.AutoRotate = false

    end

end)

--==================================================
-- STARTUP
--==================================================

updateControlText()
updateHeadButton()
updateCameraButton()

print("================================")
print("🎃 MANI PUMPKIN ROBO V.4")
print("10 PROP ROBOT READY")
print("PC + MOBILE")
print("HEAD HEIGHT FIX")
print("HAND MOVEMENT FIX")
print("LEG ANIMATION FIX")
print("================================")
