--========================================================
-- 🎃 MANI PUMPKIN ROBO V.5
-- SIMPLE + STABLE VERSION
-- 10 PROPS
-- PC + MOBILE
--========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Character = Player.Character
if not Character then
    Character = Player.CharacterAdded:Wait()
end

local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

--========================================================
-- CONFIG
--========================================================

local WorkspaceCom = workspace:FindFirstChild("WorkspaceCom")

if not WorkspaceCom then
    warn("[MANI ROBO] WorkspaceCom not found")
    return
end

local PropsFolder = WorkspaceCom:FindFirstChild("001_TrafficCones")

if not PropsFolder then
    warn("[MANI ROBO] 001_TrafficCones not found")
    return
end

--========================================================
-- FIND PROPS
--========================================================

local Props = {}

for _, Object in ipairs(PropsFolder:GetChildren()) do

    if string.find(Object.Name, Player.Name) then
        table.insert(Props, Object)
    end

    if #Props >= 10 then
        break
    end
end

if #Props < 10 then
    warn("[MANI ROBO] Need 10 props. Found:", #Props)
    return
end

--========================================================
-- FIXED SLOT SYSTEM
--========================================================

local Robot = {

    Head = Props[1],

    Waist = Props[2],

    RightHand = Props[3],
    LeftHand = Props[4],

    RightLeg1 = Props[5],
    RightLeg2 = Props[6],
    RightLeg3 = Props[7],

    LeftLeg1 = Props[8],
    LeftLeg2 = Props[9],
    LeftLeg3 = Props[10]
}

--========================================================
-- WORKING SERVER MOVEMENT
--========================================================

local function MoveProp(Prop, CFrameValue)

    if not Prop then
        return
    end

    local Remote = Prop:FindFirstChild("SetCurrentCFrame")

    if not Remote then
        return
    end

    pcall(function()
        Remote:InvokeServer(CFrameValue)
    end)
end

--========================================================
-- ROBOT SETTINGS
--========================================================

local Height = 1
local Spacing = 1

local WalkSpeed = 40
local JumpPower = 55

local Control = false

local RobotPosition = HRP.Position

local RobotDirection =
    Vector3.new(0, 0, -1)

--========================================================
-- BODY POSITIONS
--========================================================

local function GetOffset(Name)

    local Data = {

        Head = Vector3.new(
            0,
            7.2,
            0
        ),

        Waist = Vector3.new(
            0,
            4.0,
            0
        ),

        RightHand = Vector3.new(
            3.0,
            4.2,
            0
        ),

        LeftHand = Vector3.new(
            -3.0,
            4.2,
            0
        ),

        RightLeg1 = Vector3.new(
            1.45,
            2.35,
            0
        ),

        RightLeg2 = Vector3.new(
            1.45,
            1.15,
            0
        ),

        RightLeg3 = Vector3.new(
            1.45,
            -0.05,
            0
        ),

        LeftLeg1 = Vector3.new(
            -1.45,
            2.35,
            0
        ),

        LeftLeg2 = Vector3.new(
            -1.45,
            1.15,
            0
        ),

        LeftLeg3 = Vector3.new(
            -1.45,
            -0.05,
            0
        )
    }

    local Offset = Data[Name]

    if not Offset then
        return Vector3.zero
    end

    return Vector3.new(

        Offset.X * Spacing,

        Offset.Y * Height,

        Offset.Z * Spacing
    )
end

--========================================================
-- BODY CFRAME
--========================================================

local function GetBodyCFrame(
    Name,
    ExtraPosition,
    ExtraRotation
)

    local Offset = GetOffset(Name)

    local Position =
        RobotPosition
        + Vector3.new(
            Offset.X,
            Offset.Y,
            Offset.Z
        )

    local CF =
        CFrame.lookAt(
            Position,
            Position + RobotDirection
        )

    if ExtraPosition then

        CF =
            CF
            * CFrame.new(
                ExtraPosition
            )
    end

    if ExtraRotation then

        CF =
            CF
            * CFrame.Angles(
                ExtraRotation.X,
                ExtraRotation.Y,
                ExtraRotation.Z
            )
    end

    return CF
end

--========================================================
-- ANIMATION
--========================================================

local AnimationTime = 0

local function UpdateRobot(DT)

    AnimationTime =
        AnimationTime + DT

    --====================================================
    -- MOVEMENT
    --====================================================

    local Direction =
        Humanoid.MoveDirection

    local Moving =
        Direction.Magnitude > 0.05

    if Moving then

        Direction =
            Vector3.new(
                Direction.X,
                0,
                Direction.Z
            )

        if Direction.Magnitude > 0.01 then

            Direction =
                Direction.Unit

            RobotDirection =
                RobotDirection:Lerp(
                    Direction,
                    math.clamp(
                        DT * 8,
                        0,
                        1
                    )
                )

        end

        RobotPosition =
            RobotPosition
            + Direction
            * WalkSpeed
            * DT
    end

    --====================================================
    -- WALK ANIMATION
    --====================================================

    local WalkAmount = 0

    if Moving then
        WalkAmount = 1
    end

    local Wave =
        math.sin(
            AnimationTime * 8
        )

    local OppositeWave =
        math.sin(
            AnimationTime * 8
            + math.pi
        )

    --====================================================
    -- COMPLETE RIGHT LEG
    --====================================================

    local RightLegMovement =
        Vector3.new(
            0,
            math.abs(Wave)
            * 0.12
            * WalkAmount,

            Wave
            * 0.45
            * WalkAmount
        )

    local RightLegRotation =
        Vector3.new(
            -Wave
            * 0.22
            * WalkAmount,

            0,
            0
        )

    --====================================================
    -- COMPLETE LEFT LEG
    --====================================================

    local LeftLegMovement =
        Vector3.new(
            0,
            math.abs(OppositeWave)
            * 0.12
            * WalkAmount,

            OppositeWave
            * 0.45
            * WalkAmount
        )

    local LeftLegRotation =
        Vector3.new(
            -OppositeWave
            * 0.22
            * WalkAmount,

            0,
            0
        )

    --====================================================
    -- HAND IDLE ANIMATION
    --====================================================

    local HandWave =
        math.sin(
            AnimationTime * 3
        )

    local RightHandMovement =
        Vector3.new(
            0,
            HandWave * 0.08,
            0
        )

    local LeftHandMovement =
        Vector3.new(
            0,
            -HandWave * 0.08,
            0
        )

    local RightHandRotation =
        Vector3.new(
            HandWave * 0.08,
            0,
            0
        )

    local LeftHandRotation =
        Vector3.new(
            -HandWave * 0.08,
            0,
            0
        )

    --====================================================
    -- HEAD
    --====================================================

    MoveProp(
        Robot.Head,

        GetBodyCFrame(
            "Head",
            Vector3.new(
                0,
                math.sin(AnimationTime * 2)
                * 0.03,
                0
            ),

            Vector3.new(
                0,
                math.sin(AnimationTime * 2)
                * 0.02,
                0
            )
        )
    )

    --====================================================
    -- WAIST
    --====================================================

    MoveProp(
        Robot.Waist,

        GetBodyCFrame(
            "Waist",
            Vector3.zero,
            Vector3.zero
        )
    )

    --====================================================
    -- RIGHT HAND
    --====================================================

    MoveProp(
        Robot.RightHand,

        GetBodyCFrame(
            "RightHand",
            RightHandMovement,
            RightHandRotation
        )
    )

    --====================================================
    -- LEFT HAND
    --====================================================

    MoveProp(
        Robot.LeftHand,

        GetBodyCFrame(
            "LeftHand",
            LeftHandMovement,
            LeftHandRotation
        )
    )

    --====================================================
    -- RIGHT LEG 1
    --====================================================

    MoveProp(
        Robot.RightLeg1,

        GetBodyCFrame(
            "RightLeg1",
            RightLegMovement,
            RightLegRotation
        )
    )

    --====================================================
    -- RIGHT LEG 2
    --====================================================

    MoveProp(
        Robot.RightLeg2,

        GetBodyCFrame(
            "RightLeg2",
            RightLegMovement,
            RightLegRotation
        )
    )

    --====================================================
    -- RIGHT LEG 3
    --====================================================

    MoveProp(
        Robot.RightLeg3,

        GetBodyCFrame(
            "RightLeg3",
            RightLegMovement,
            RightLegRotation
        )
    )

    --====================================================
    -- LEFT LEG 1
    --====================================================

    MoveProp(
        Robot.LeftLeg1,

        GetBodyCFrame(
            "LeftLeg1",
            LeftLegMovement,
            LeftLegRotation
        )
    )

    --====================================================
    -- LEFT LEG 2
    --====================================================

    MoveProp(
        Robot.LeftLeg2,

        GetBodyCFrame(
            "LeftLeg2",
            LeftLegMovement,
            LeftLegRotation
        )
    )

    --====================================================
    -- LEFT LEG 3
    --====================================================

    MoveProp(
        Robot.LeftLeg3,

        GetBodyCFrame(
            "LeftLeg3",
            LeftLegMovement,
            LeftLegRotation
        )
    )
end

--========================================================
-- ASSEMBLE
--========================================================

local function AssembleRobot()

    local Names = {

        "Head",
        "Waist",

        "RightHand",
        "LeftHand",

        "RightLeg1",
        "RightLeg2",
        "RightLeg3",

        "LeftLeg1",
        "LeftLeg2",
        "LeftLeg3"
    }

    for _, Name in ipairs(Names) do

        local Prop =
            Robot[Name]

        if Prop then

            MoveProp(
                Prop,

                GetBodyCFrame(
                    Name,
                    Vector3.zero,
                    Vector3.zero
                )
            )

            task.wait(0.12)
        end
    end
end

--========================================================
-- CAMERA
--========================================================

local Camera =
    workspace.CurrentCamera

local CameraYaw = 0
local CameraPitch = math.rad(15)

local CameraDistance = 25
local TargetCameraDistance = 25

local MinZoom = 4
local MaxZoom = 120

local CameraSmooth = 10

local function UpdateCamera(DT)

    if not Control then
        return
    end

    Camera =
        workspace.CurrentCamera

    Camera.CameraType =
        Enum.CameraType.Scriptable

    CameraDistance =
        CameraDistance
        + (
            TargetCameraDistance
            - CameraDistance
        )
        * math.clamp(
            DT * CameraSmooth,
            0,
            1
        )

    local Target =
        RobotPosition
        + Vector3.new(
            0,
            4.5 * Height,
            0
        )

    local Horizontal =
        math.cos(CameraPitch)
        * CameraDistance

    local X =
        math.sin(CameraYaw)
        * Horizontal

    local Z =
        math.cos(CameraYaw)
        * Horizontal

    local Y =
        math.sin(CameraPitch)
        * CameraDistance

    local Position =
        Target
        + Vector3.new(
            X,
            Y,
            Z
        )

    local Desired =
        CFrame.lookAt(
            Position,
            Target
        )

    Camera.CFrame =
        Camera.CFrame:Lerp(
            Desired,
            math.clamp(
                DT * CameraSmooth,
                0,
                1
            )
        )
end

--========================================================
-- CAMERA MOUSE
--========================================================

local CameraDragging = false
local LastMousePosition = nil

UserInputService.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton2 then

        CameraDragging = true

        LastMousePosition =
            UserInputService:GetMouseLocation()
    end
end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton2 then

        CameraDragging = false
        LastMousePosition = nil
    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if not Control then
        return
    end

    --====================================================
    -- CAMERA ROTATION
    --====================================================

    if Input.UserInputType ==
        Enum.UserInputType.MouseMovement
        and CameraDragging then

        local Current =
            UserInputService:GetMouseLocation()

        if LastMousePosition then

            local Delta =
                Current
                - LastMousePosition

            CameraYaw =
                CameraYaw
                - Delta.X * 0.008

            CameraPitch =
                CameraPitch
                - Delta.Y * 0.008

            CameraPitch =
                math.clamp(
                    CameraPitch,
                    math.rad(-80),
                    math.rad(80)
                )
        end

        LastMousePosition =
            Current
    end

    --====================================================
    -- ZOOM
    --====================================================

    if Input.UserInputType ==
        Enum.UserInputType.MouseWheel then

        TargetCameraDistance =
            TargetCameraDistance
            - Input.Position.Z * 5

        TargetCameraDistance =
            math.clamp(
                TargetCameraDistance,
                MinZoom,
                MaxZoom
            )
    end
end)

--========================================================
-- MOBILE CAMERA
--========================================================

local MobileCameraTouch = nil
local MobileLastPosition = nil

UserInputService.TouchStarted:Connect(function(Touch)

    if not Control then
        return
    end

    if MobileCameraTouch == nil then

        MobileCameraTouch =
            Touch

        MobileLastPosition =
            Touch.Position
    end
end)

UserInputService.TouchMoved:Connect(function(Touch)

    if not Control then
        return
    end

    if Touch == MobileCameraTouch then

        local Current =
            Touch.Position

        if MobileLastPosition then

            local Delta =
                Current
                - MobileLastPosition

            CameraYaw =
                CameraYaw
                - Delta.X * 0.008

            CameraPitch =
                CameraPitch
                - Delta.Y * 0.008

            CameraPitch =
                math.clamp(
                    CameraPitch,
                    math.rad(-80),
                    math.rad(80)
                )
        end

        MobileLastPosition =
            Current
    end
end)

UserInputService.TouchEnded:Connect(function(Touch)

    if Touch == MobileCameraTouch then

        MobileCameraTouch = nil
        MobileLastPosition = nil
    end
end)

--========================================================
-- CONTROL
--========================================================

local function SetControl(Value)

    Control = Value

    if Control then

        Humanoid.WalkSpeed =
            WalkSpeed

        Humanoid.JumpPower =
            JumpPower

        Humanoid.AutoRotate =
            false

        Camera =
            workspace.CurrentCamera

        Camera.CameraType =
            Enum.CameraType.Scriptable

    else

        Humanoid.WalkSpeed =
            16

        Humanoid.JumpPower =
            50

        Humanoid.AutoRotate =
            true

        Camera =
            workspace.CurrentCamera

        Camera.CameraType =
            Enum.CameraType.Custom

        Camera.CameraSubject =
            Humanoid
    end
end

--========================================================
-- GUI
--========================================================

local OldGUI =
    Player.PlayerGui:FindFirstChild(
        "MANI_PUMPKIN_ROBO_V5"
    )

if OldGUI then
    OldGUI:Destroy()
end

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "MANI_PUMPKIN_ROBO_V5"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.IgnoreGuiInset =
    true

ScreenGui.Parent =
    Player.PlayerGui

--========================================================
-- MAIN
--========================================================

local Main =
    Instance.new("Frame")

Main.Size =
    UDim2.fromOffset(
        240,
        300
    )

Main.Position =
    UDim2.new(
        0,
        25,
        0.5,
        -150
    )

Main.BackgroundColor3 =
    Color3.fromRGB(
        18,
        18,
        24
    )

Main.BorderSizePixel = 0

Main.Parent =
    ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

MainCorner.Parent =
    Main

--========================================================
-- TITLE
--========================================================

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        1,
        -45,
        0,
        40
    )

Title.Position =
    UDim2.fromOffset(
        12,
        3
    )

Title.BackgroundTransparency =
    1

Title.Text =
    "🎃 MANI PUMPKIN ROBO"

Title.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

Title.TextSize =
    13

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    Main

--========================================================
-- MINIMIZE
--========================================================

local Minimize =
    Instance.new("TextButton")

Minimize.Size =
    UDim2.fromOffset(
        28,
        28
    )

Minimize.Position =
    UDim2.new(
        1,
        -34,
        0,
        7
    )

Minimize.BackgroundColor3 =
    Color3.fromRGB(
        38,
        38,
        48
    )

Minimize.Text =
    "−"

Minimize.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

Minimize.TextSize =
    18

Minimize.Font =
    Enum.Font.GothamBold

Minimize.Parent =
    Main

local MinCorner =
    Instance.new("UICorner")

MinCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

MinCorner.Parent =
    Minimize

--========================================================
-- SCROLL
--========================================================

local Scroll =
    Instance.new("ScrollingFrame")

Scroll.Position =
    UDim2.fromOffset(
        8,
        45
    )

Scroll.Size =
    UDim2.new(
        1,
        -16,
        1,
        -52
    )

Scroll.BackgroundTransparency =
    1

Scroll.BorderSizePixel =
    0

Scroll.ScrollBarThickness =
    3

Scroll.CanvasSize =
    UDim2.fromOffset(
        0,
        600
    )

Scroll.Parent =
    Main

local Layout =
    Instance.new("UIListLayout")

Layout.Padding =
    UDim.new(
        0,
        6
    )

Layout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

Layout.Parent =
    Scroll

--========================================================
-- BUTTON
--========================================================

local function Button(Text)

    local B =
        Instance.new("TextButton")

    B.Size =
        UDim2.new(
            1,
            -4,
            0,
            34
        )

    B.BackgroundColor3 =
        Color3.fromRGB(
            30,
            30,
            40
        )

    B.BorderSizePixel =
        0

    B.Text =
        Text

    B.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )

    B.TextSize =
        12

    B.Font =
        Enum.Font.GothamMedium

    B.Parent =
        Scroll

    local C =
        Instance.new("UICorner")

    C.CornerRadius =
        UDim.new(
            0,
            8
        )

    C.Parent =
        B

    return B
end

--========================================================
-- CONTROL BUTTON
--========================================================

local ControlButton =
    Button(
        "🤖 CONTROL : OFF"
    )

ControlButton.MouseButton1Click:Connect(function()

    SetControl(
        not Control
    )

    if Control then

        ControlButton.Text =
            "🤖 CONTROL : ON"

    else

        ControlButton.Text =
            "🤖 CONTROL : OFF"
    end
end)

--========================================================
-- ASSEMBLE BUTTON
--========================================================

local AssembleButton =
    Button(
        "🔧 ASSEMBLE 10 PROPS"
    )

AssembleButton.MouseButton1Click:Connect(function()

    AssembleRobot()
end)

--========================================================
-- HEIGHT
--========================================================

local HeightButton =
    Button(
        "HEIGHT : 1.00"
    )

HeightButton.MouseButton1Click:Connect(function()

    Height =
        Height + 0.25

    if Height > 3 then
        Height = 0.5
    end

    HeightButton.Text =
        string.format(
            "HEIGHT : %.2f",
            Height
        )
end)

--========================================================
-- SPACING
--========================================================

local SpacingButton =
    Button(
        "SPACING : 1.00"
    )

SpacingButton.MouseButton1Click:Connect(function()

    Spacing =
        Spacing + 0.15

    if Spacing > 2 then
        Spacing = 0.5
    end

    SpacingButton.Text =
        string.format(
            "SPACING : %.2f",
            Spacing
        )
end)

--========================================================
-- SPEED
--========================================================

local SpeedButton =
    Button(
        "SPEED : 40"
    )

SpeedButton.MouseButton1Click:Connect(function()

    WalkSpeed =
        WalkSpeed + 10

    if WalkSpeed > 100 then
        WalkSpeed = 10
    end

    Humanoid.WalkSpeed =
        WalkSpeed

    SpeedButton.Text =
        "SPEED : "
        .. tostring(WalkSpeed)
end)

--========================================================
-- JUMP
--========================================================

local JumpButton =
    Button(
        "JUMP POWER : 55"
    )

JumpButton.MouseButton1Click:Connect(function()

    JumpPower =
        JumpPower + 10

    if JumpPower > 100 then
        JumpPower = 30
    end

    Humanoid.JumpPower =
        JumpPower

    JumpButton.Text =
        "JUMP POWER : "
        .. tostring(JumpPower)
end)

--========================================================
-- ZOOM IN
--========================================================

local ZoomIn =
    Button(
        "🔍 ZOOM IN"
    )

ZoomIn.MouseButton1Click:Connect(function()

    TargetCameraDistance =
        math.max(
            MinZoom,
            TargetCameraDistance - 5
        )
end)

--========================================================
-- ZOOM OUT
--========================================================

local ZoomOut =
    Button(
        "🔎 ZOOM OUT"
    )

ZoomOut.MouseButton1Click:Connect(function()

    TargetCameraDistance =
        math.min(
            MaxZoom,
            TargetCameraDistance + 5
        )
end)

--========================================================
-- CAMERA RESET
--========================================================

local CameraReset =
    Button(
        "🎥 RESET CAMERA"
    )

CameraReset.MouseButton1Click:Connect(function()

    CameraYaw = 0
    CameraPitch = math.rad(15)

    TargetCameraDistance = 25
end)

--========================================================
-- INFO
--========================================================

local Info =
    Instance.new("TextLabel")

Info.Size =
    UDim2.new(
        1,
        -5,
        0,
        65
    )

Info.BackgroundTransparency =
    1

Info.Text =
    "PC: Right Mouse + Drag = 360° Camera\n"
    .. "Mouse Wheel = Zoom\n"
    .. "Mobile: Swipe = Camera"

Info.TextColor3 =
    Color3.fromRGB(
        160,
        160,
        170
    )

Info.TextSize =
    10

Info.Font =
    Enum.Font.Gotham

Info.TextWrapped =
    true

Info.Parent =
    Scroll

--========================================================
-- MINIMIZE
--========================================================

local Minimized =
    false

Minimize.MouseButton1Click:Connect(function()

    Minimized =
        not Minimized

    if Minimized then

        Scroll.Visible =
            false

        Main.Size =
            UDim2.fromOffset(
                240,
                48
            )

        Minimize.Text =
            "+"

    else

        Scroll.Visible =
            true

        Main.Size =
            UDim2.fromOffset(
                240,
                300
            )

        Minimize.Text =
            "−"
    end
end)

--========================================================
-- DRAG
--========================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true

        DragStart =
            Input.Position

        StartPosition =
            Main.Position
    end
end)

Title.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        local Delta =
            Input.Position
            - DragStart

        Main.Position =
            UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset
                    + Delta.X,

                StartPosition.Y.Scale,
                StartPosition.Y.Offset
                    + Delta.Y
            )
    end
end)

--========================================================
-- START
--========================================================

AssembleRobot()

print("====================================")
print("🎃 MANI PUMPKIN ROBO V.5")
print("10 PROPS LOADED")
print("GUI LOADED")
print("CAMERA LOADED")
print("====================================")

--========================================================
-- MAIN LOOP
--========================================================

RunService.Heartbeat:Connect(function(DT)

    if Control then
        UpdateRobot(DT)
        UpdateCamera(DT)
    end
end)
