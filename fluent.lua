--========================================================
-- MANI PUMPKIN ROBO V.4
-- 10 PROP ROBOT
-- PC + MOBILE
-- ADVANCED CAMERA + SMOOTH ROBOT CONTROL
--========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

--========================================================
-- CONFIG
--========================================================

local PROPS_FOLDER =
    workspace:FindFirstChild("WorkspaceCom")
    and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")

if not PROPS_FOLDER then
    warn("[MANI ROBO] 001_TrafficCones folder nahi mila")
    return
end

local MAX_PROPS = 10

-- Robot movement
local robotSpeed = 40
local jumpPower = 55

-- Robot size
local robotHeight = 1
local robotSpacing = 1

-- Camera
local camera = workspace.CurrentCamera

local cameraYaw = 0
local cameraPitch = math.rad(15)

local cameraDistance = 22
local cameraTargetDistance = 22

local CAMERA_MIN = 5
local CAMERA_MAX = 100

local CAMERA_SMOOTH = 10
local CAMERA_ROTATE_SENSITIVITY = 0.008

local robotPosition = hrp.Position
local robotForward = Vector3.new(0, 0, -1)

local controlEnabled = false
local robotJumping = false

--========================================================
-- PROP ORDER
--========================================================

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
    "LeftLeg3"
}

local props = {}

--========================================================
-- FIND PLAYER PROPS
--========================================================

for _, v in ipairs(PROPS_FOLDER:GetChildren()) do

    if string.find(v.Name, player.Name) then
        table.insert(props, v)
    end

    if #props >= MAX_PROPS then
        break
    end
end

if #props < MAX_PROPS then
    warn(
        "[MANI ROBO] 10 props nahi mile. Found:",
        #props
    )
    return
end

--========================================================
-- MAP PROPS
--========================================================

local robot = {}

for i = 1, MAX_PROPS do
    robot[SLOT_NAMES[i]] = props[i]
end

print("[MANI ROBO] 10 props loaded")

for i = 1, MAX_PROPS do
    print(
        i,
        SLOT_NAMES[i],
        props[i].Name
    )
end

--========================================================
-- WORKING PROP MOVEMENT
--========================================================

local function setPropCFrame(prop, cf)

    if not prop then
        return
    end

    local remote = prop:FindFirstChild("SetCurrentCFrame")

    if remote then

        pcall(function()
            remote:InvokeServer(cf)
        end)

    else

        warn(
            "[MANI ROBO] SetCurrentCFrame missing:",
            prop.Name
        )

    end
end

--========================================================
-- ROBOT BODY OFFSETS
--========================================================

-- Important:
-- Head ko waist se clearly separate kiya gaya hai.
-- Hands waist ke upper side par hain.
-- Legs complete assemblies hain.

local BASE_OFFSETS = {

    -- HEAD
    Head = Vector3.new(
        0,
        7.4,
        0
    ),

    -- WAIST
    Waist = Vector3.new(
        0,
        4.1,
        0
    ),

    -- HANDS
    RightHand = Vector3.new(
        3.0,
        4.25,
        0
    ),

    LeftHand = Vector3.new(
        -3.0,
        4.25,
        0
    ),

    -- RIGHT LEG
    RightLeg1 = Vector3.new(
        1.45,
        2.25,
        0
    ),

    RightLeg2 = Vector3.new(
        1.45,
        1.05,
        0
    ),

    RightLeg3 = Vector3.new(
        1.45,
        -0.15,
        0
    ),

    -- LEFT LEG
    LeftLeg1 = Vector3.new(
        -1.45,
        2.25,
        0
    ),

    LeftLeg2 = Vector3.new(
        -1.45,
        1.05,
        0
    ),

    LeftLeg3 = Vector3.new(
        -1.45,
        -0.15,
        0
    )
}

--========================================================
-- GET SCALED OFFSET
--========================================================

local function getOffset(name)

    local offset = BASE_OFFSETS[name]

    if not offset then
        return Vector3.zero
    end

    local h = robotHeight

    local result = Vector3.new(
        offset.X,
        offset.Y * h,
        offset.Z
    )

    -- Horizontal spacing
    result = Vector3.new(
        result.X * robotSpacing,
        result.Y,
        result.Z * robotSpacing
    )

    return result
end

--========================================================
-- ROBOT ROOT
--========================================================

local robotCF = CFrame.new(
    robotPosition,
    robotPosition + robotForward
)

--========================================================
-- ANIMATION STATE
--========================================================

local animationTime = 0

local currentMoveAmount = 0
local targetMoveAmount = 0

local currentTurn = 0
local targetTurn = 0

local jumpAnimation = 0

--========================================================
-- SMOOTH NUMBER
--========================================================

local function smoothNumber(current, target, speed, dt)

    local alpha = 1 - math.exp(-speed * dt)

    return current + (target - current) * alpha
end

--========================================================
-- LOCAL BODY OFFSET
--========================================================

local function bodyCFrame(
    name,
    animationOffset,
    animationRotation
)

    local offset = getOffset(name)

    local worldPosition =
        robotPosition
        + robotCF.RightVector * offset.X
        + Vector3.new(0, offset.Y, 0)
        + robotCF.LookVector * offset.Z

    local cf =
        CFrame.new(
            worldPosition,
            worldPosition + robotCF.LookVector
        )

    if animationOffset then
        cf =
            cf
            * CFrame.new(animationOffset)
    end

    if animationRotation then
        cf =
            cf
            * CFrame.Angles(
                animationRotation.X,
                animationRotation.Y,
                animationRotation.Z
            )
    end

    return cf
end

--========================================================
-- APPLY ROBOT
--========================================================

local function updateRobot(dt)

    animationTime =
        animationTime + dt

    --====================================================
    -- MOVEMENT
    --====================================================

    local moveDirection = humanoid.MoveDirection

    local moveAmount = moveDirection.Magnitude

    targetMoveAmount =
        math.clamp(moveAmount, 0, 1)

    currentMoveAmount =
        smoothNumber(
            currentMoveAmount,
            targetMoveAmount,
            12,
            dt
        )

    --====================================================
    -- TURN ROBOT
    --====================================================

    if moveAmount > 0.05 then

        local direction =
            Vector3.new(
                moveDirection.X,
                0,
                moveDirection.Z
            )

        if direction.Magnitude > 0.01 then

            direction =
                direction.Unit

            local targetCF =
                CFrame.lookAt(
                    robotPosition,
                    robotPosition + direction
                )

            robotCF =
                robotCF:Lerp(
                    targetCF,
                    math.clamp(dt * 8, 0, 1)
                )

            robotForward =
                robotCF.LookVector

        end
    end

    --====================================================
    -- WALK CYCLE
    --====================================================

    local walkWave =
        math.sin(animationTime * 9)

    local walkWaveOpposite =
        math.sin(animationTime * 9 + math.pi)

    local walkAmount =
        currentMoveAmount

    --====================================================
    -- COMPLETE RIGHT LEG UNIT
    --====================================================

    local rightLegOffset =
        Vector3.new(
            0,
            math.abs(walkWave) * 0.10 * walkAmount,
            walkWave * 0.55 * walkAmount
        )

    local rightLegRotation =
        Vector3.new(
            -walkWave * 0.25 * walkAmount,
            0,
            0
        )

    --====================================================
    -- COMPLETE LEFT LEG UNIT
    --====================================================

    local leftLegOffset =
        Vector3.new(
            0,
            math.abs(walkWaveOpposite) * 0.10 * walkAmount,
            walkWaveOpposite * 0.55 * walkAmount
        )

    local leftLegRotation =
        Vector3.new(
            -walkWaveOpposite * 0.25 * walkAmount,
            0,
            0
        )

    --====================================================
    -- HAND IDLE / WALK
    --====================================================

    local handWave =
        math.sin(animationTime * 3)

    local rightHandOffset =
        Vector3.new(
            0,
            handWave * 0.08,
            0
        )

    local leftHandOffset =
        Vector3.new(
            0,
            -handWave * 0.08,
            0
        )

    local rightHandRotation =
        Vector3.new(
            handWave * 0.10,
            0,
            0
        )

    local leftHandRotation =
        Vector3.new(
            -handWave * 0.10,
            0,
            0
        )

    --====================================================
    -- JUMP ANIMATION
    --====================================================

    if robotJumping then

        jumpAnimation =
            math.min(
                jumpAnimation + dt * 5,
                math.pi
            )

    else

        jumpAnimation =
            smoothNumber(
                jumpAnimation,
                0,
                8,
                dt
            )
    end

    local jumpOffset =
        math.sin(jumpAnimation)
        * 0.35

    --====================================================
    -- HEAD
    --====================================================

    local headCF =
        bodyCFrame(
            "Head",
            Vector3.new(
                0,
                jumpOffset,
                0
            ),
            Vector3.new(
                0,
                math.sin(animationTime * 2) * 0.025,
                0
            )
        )

    setPropCFrame(
        robot.Head,
        headCF
    )

    --====================================================
    -- WAIST
    --====================================================

    local waistCF =
        bodyCFrame(
            "Waist",
            Vector3.new(
                0,
                jumpOffset * 0.6,
                0
            ),
            Vector3.new(
                0,
                0,
                math.sin(animationTime * 2) * 0.02
            )
        )

    setPropCFrame(
        robot.Waist,
        waistCF
    )

    --====================================================
    -- RIGHT HAND
    --====================================================

    local rightHandCF =
        bodyCFrame(
            "RightHand",
            rightHandOffset
                + Vector3.new(
                    0,
                    jumpOffset * 0.5,
                    0
                ),
            rightHandRotation
        )

    setPropCFrame(
        robot.RightHand,
        rightHandCF
    )

    --====================================================
    -- LEFT HAND
    --====================================================

    local leftHandCF =
        bodyCFrame(
            "LeftHand",
            leftHandOffset
                + Vector3.new(
                    0,
                    jumpOffset * 0.5,
                    0
                ),
            leftHandRotation
        )

    setPropCFrame(
        robot.LeftHand,
        leftHandCF
    )

    --====================================================
    -- RIGHT LEG - ALL 3 MOVE TOGETHER
    --====================================================

    for _, name in ipairs({
        "RightLeg1",
        "RightLeg2",
        "RightLeg3"
    }) do

        local cf =
            bodyCFrame(
                name,
                rightLegOffset
                    + Vector3.new(
                        0,
                        jumpOffset,
                        0
                    ),
                rightLegRotation
            )

        setPropCFrame(
            robot[name],
            cf
        )
    end

    --====================================================
    -- LEFT LEG - ALL 3 MOVE TOGETHER
    --====================================================

    for _, name in ipairs({
        "LeftLeg1",
        "LeftLeg2",
        "LeftLeg3"
    }) do

        local cf =
            bodyCFrame(
                name,
                leftLegOffset
                    + Vector3.new(
                        0,
                        jumpOffset,
                        0
                    ),
                leftLegRotation
            )

        setPropCFrame(
            robot[name],
            cf
        )
    end
end

--========================================================
-- INITIAL ASSEMBLE
--========================================================

local function assembleRobot()

    print("[MANI ROBO] Assembling...")

    for _, name in ipairs(SLOT_NAMES) do

        if robot[name] then

            local cf =
                bodyCFrame(
                    name,
                    Vector3.zero,
                    Vector3.zero
                )

            setPropCFrame(
                robot[name],
                cf
            )

            task.wait(0.12)
        end
    end

    print("[MANI ROBO] Robot assembled")
end

--========================================================
-- PLAYER MOVEMENT SETUP
--========================================================

local originalWalkSpeed =
    humanoid.WalkSpeed

local originalJumpPower =
    humanoid.JumpPower

local originalAutoRotate =
    humanoid.AutoRotate

--========================================================
-- CAMERA SYSTEM
--========================================================

local cameraConnection

local function enableCamera()

    camera =
        workspace.CurrentCamera

    camera.CameraType =
        Enum.CameraType.Scriptable

    cameraYaw = 0
    cameraPitch = math.rad(12)

    cameraDistance = 25
    cameraTargetDistance = 25
end

local function disableCamera()

    camera =
        workspace.CurrentCamera

    camera.CameraType =
        Enum.CameraType.Custom

    camera.CameraSubject =
        humanoid
end

local function updateCamera(dt)

    if not controlEnabled then
        return
    end

    camera =
        workspace.CurrentCamera

    local target =
        robotPosition
        + Vector3.new(
            0,
            4.0 * robotHeight,
            0
        )

    cameraDistance =
        smoothNumber(
            cameraDistance,
            cameraTargetDistance,
            CAMERA_SMOOTH,
            dt
        )

    local horizontal =
        math.cos(cameraPitch)
        * cameraDistance

    local vertical =
        math.sin(cameraPitch)
        * cameraDistance

    local offset =
        Vector3.new(
            math.sin(cameraYaw) * horizontal,
            vertical,
            math.cos(cameraYaw) * horizontal
        )

    local desiredPosition =
        target + offset

    local desiredCF =
        CFrame.lookAt(
            desiredPosition,
            target
        )

    camera.CFrame =
        camera.CFrame:Lerp(
            desiredCF,
            math.clamp(dt * CAMERA_SMOOTH, 0, 1)
        )
end

--========================================================
-- CAMERA INPUT
--========================================================

local rotatingCamera = false
local lastMousePosition = nil

local activeTouches = {}

local pinchStartDistance = nil
local pinchStartZoom = nil

UserInputService.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton2 then

        rotatingCamera = true

        lastMousePosition =
            UserInputService:GetMouseLocation()
    end

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        activeTouches[input] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton2 then

        rotatingCamera = false
        lastMousePosition = nil
    end

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        activeTouches[input] = nil

        pinchStartDistance = nil
        pinchStartZoom = nil
    end
end)

UserInputService.InputChanged:Connect(function(input)

    --====================================================
    -- PC MOUSE ORBIT
    --====================================================

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        and rotatingCamera
        and controlEnabled then

        local current =
            UserInputService:GetMouseLocation()

        if lastMousePosition then

            local delta =
                current - lastMousePosition

            cameraYaw =
                cameraYaw
                - delta.X
                * CAMERA_ROTATE_SENSITIVITY

            cameraPitch =
                cameraPitch
                - delta.Y
                * CAMERA_ROTATE_SENSITIVITY

            cameraPitch =
                math.clamp(
                    cameraPitch,
                    math.rad(-75),
                    math.rad(75)
                )
        end

        lastMousePosition = current
    end

    --====================================================
    -- PC WHEEL ZOOM
    --====================================================

    if input.UserInputType ==
        Enum.UserInputType.MouseWheel
        and controlEnabled then

        cameraTargetDistance =
            cameraTargetDistance
            - input.Position.Z * 4

        cameraTargetDistance =
            math.clamp(
                cameraTargetDistance,
                CAMERA_MIN,
                CAMERA_MAX
            )
    end
end)

--========================================================
-- MOBILE CAMERA
--========================================================

UserInputService.TouchPan:Connect(function(
    touchPositions,
    totalTranslation,
    velocity,
    state
)

    if not controlEnabled then
        return
    end

    if #touchPositions == 1 then

        cameraYaw =
            cameraYaw
            - totalTranslation.X
            * 0.006

        cameraPitch =
            cameraPitch
            - totalTranslation.Y
            * 0.006

        cameraPitch =
            math.clamp(
                cameraPitch,
                math.rad(-75),
                math.rad(75)
            )
    end
end)

--========================================================
-- PINCH ZOOM
--========================================================

local function getTwoTouches()

    local result = {}

    for touch in pairs(activeTouches) do

        table.insert(
            result,
            touch
        )

        if #result >= 2 then
            break
        end
    end

    return result
end

UserInputService.TouchPinch:Connect(function(
    touches,
    scale,
    velocity,
    state,
    gameProcessed
)

    if not controlEnabled then
        return
    end

    if scale ~= 0 then

        cameraTargetDistance =
            cameraTargetDistance
            / scale

        cameraTargetDistance =
            math.clamp(
                cameraTargetDistance,
                CAMERA_MIN,
                CAMERA_MAX
            )
    end
end)

--========================================================
-- JUMP
--========================================================

humanoid.StateChanged:Connect(function(
    oldState,
    newState
)

    if newState ==
        Enum.HumanoidStateType.Jumping
        or newState ==
        Enum.HumanoidStateType.Freefall then

        robotJumping = true

    elseif newState ==
        Enum.HumanoidStateType.Landed then

        robotJumping = false
        jumpAnimation = 0
    end
end)

--========================================================
-- CONTROL ON/OFF
--========================================================

local function setControl(enabled)

    controlEnabled = enabled

    if enabled then

        print("[MANI ROBO] CONTROL ON")

        humanoid.WalkSpeed =
            robotSpeed

        humanoid.JumpPower =
            jumpPower

        humanoid.AutoRotate =
            false

        -- Player visible
        for _, obj in ipairs(character:GetDescendants()) do

            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end

        end

        enableCamera()

    else

        print("[MANI ROBO] CONTROL OFF")

        humanoid.WalkSpeed =
            originalWalkSpeed

        humanoid.JumpPower =
            originalJumpPower

        humanoid.AutoRotate =
            originalAutoRotate

        disableCamera()
    end
end

--========================================================
-- MAIN LOOP
--========================================================

RunService.RenderStepped:Connect(function(dt)

    if controlEnabled then

        -- Keep actual player character visible.
        for _, obj in ipairs(character:GetDescendants()) do

            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end

        updateRobot(dt)
        updateCamera(dt)

    end
end)

--========================================================
-- GUI
--========================================================

local gui =
    Instance.new("ScreenGui")

gui.Name =
    "MANI_PUMPKIN_ROBO_V4"

gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

gui.Parent =
    player:WaitForChild("PlayerGui")

--========================================================
-- MAIN
--========================================================

local main =
    Instance.new("Frame")

main.Name = "Main"

main.Size =
    UDim2.fromOffset(
        245,
        310
    )

main.Position =
    UDim2.new(
        0,
        25,
        0.5,
        -155
    )

main.BackgroundColor3 =
    Color3.fromRGB(
        18,
        18,
        23
    )

main.BorderSizePixel = 0

main.Parent = gui

local mainCorner =
    Instance.new("UICorner")

mainCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

mainCorner.Parent = main

--========================================================
-- TITLE
--========================================================

local title =
    Instance.new("TextLabel")

title.Size =
    UDim2.new(
        1,
        -45,
        0,
        38
    )

title.Position =
    UDim2.fromOffset(
        12,
        4
    )

title.BackgroundTransparency = 1

title.Text =
    "🎃 MANI PUMPKIN ROBO V.4"

title.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

title.TextSize = 14

title.Font =
    Enum.Font.GothamBold

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent = main

--========================================================
-- MINIMIZE
--========================================================

local minimize =
    Instance.new("TextButton")

minimize.Size =
    UDim2.fromOffset(
        30,
        28
    )

minimize.Position =
    UDim2.new(
        1,
        -35,
        0,
        8
    )

minimize.BackgroundColor3 =
    Color3.fromRGB(
        35,
        35,
        43
    )

minimize.Text =
    "−"

minimize.TextSize = 18

minimize.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

minimize.Font =
    Enum.Font.GothamBold

minimize.Parent = main

local miniCorner =
    Instance.new("UICorner")

miniCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

miniCorner.Parent = minimize

--========================================================
-- SCROLL
--========================================================

local scroll =
    Instance.new("ScrollingFrame")

scroll.Position =
    UDim2.fromOffset(
        8,
        45
    )

scroll.Size =
    UDim2.new(
        1,
        -16,
        1,
        -53
    )

scroll.BackgroundTransparency = 1

scroll.BorderSizePixel = 0

scroll.ScrollBarThickness = 3

scroll.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        570
    )

scroll.Parent = main

local layout =
    Instance.new("UIListLayout")

layout.Padding =
    UDim.new(
        0,
        7
    )

layout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

layout.Parent = scroll

--========================================================
-- BUTTON CREATOR
--========================================================

local function createButton(
    text,
    height
)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(
            1,
            -5,
            0,
            height or 34
        )

    button.BackgroundColor3 =
        Color3.fromRGB(
            30,
            30,
            38
        )

    button.Text =
        text

    button.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )

    button.TextSize = 12

    button.Font =
        Enum.Font.GothamMedium

    button.AutoButtonColor = true

    button.Parent = scroll

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(
            0,
            8
        )

    corner.Parent = button

    return button
end

--========================================================
-- LABEL
--========================================================

local function createLabel(text)

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -5,
            0,
            25
        )

    label.BackgroundTransparency = 1

    label.Text =
        text

    label.TextColor3 =
        Color3.fromRGB(
            190,
            190,
            200
        )

    label.TextSize = 11

    label.Font =
        Enum.Font.Gotham

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = scroll

    return label
end

--========================================================
-- CONTROL
--========================================================

local controlButton =
    createButton(
        "🤖 CONTROL : OFF",
        38
    )

controlButton.MouseButton1Click:Connect(function()

    setControl(
        not controlEnabled
    )

    if controlEnabled then

        controlButton.Text =
            "🤖 CONTROL : ON"

    else

        controlButton.Text =
            "🤖 CONTROL : OFF"
    end
end)

--========================================================
-- ASSEMBLE
--========================================================

local assembleButton =
    createButton(
        "🔧 RE-ASSEMBLE ROBOT",
        34
    )

assembleButton.MouseButton1Click:Connect(function()

    assembleRobot()
end)

--========================================================
-- HEIGHT
--========================================================

createLabel(
    "ROBOT HEIGHT"
)

local heightButton =
    createButton(
        "HEIGHT : 1.00",
        32
    )

heightButton.MouseButton1Click:Connect(function()

    robotHeight =
        robotHeight + 0.25

    if robotHeight > 3 then
        robotHeight = 0.5
    end

    heightButton.Text =
        string.format(
            "HEIGHT : %.2f",
            robotHeight
        )
end)

--========================================================
-- SPACING
--========================================================

createLabel(
    "BODY SPACING"
)

local spacingButton =
    createButton(
        "SPACING : 1.00",
        32
    )

spacingButton.MouseButton1Click:Connect(function()

    robotSpacing =
        robotSpacing + 0.15

    if robotSpacing > 2 then
        robotSpacing = 0.5
    end

    spacingButton.Text =
        string.format(
            "SPACING : %.2f",
            robotSpacing
        )
end)

--========================================================
-- SPEED
--========================================================

createLabel(
    "ROBOT SPEED"
)

local speedButton =
    createButton(
        "SPEED : 40",
        32
    )

speedButton.MouseButton1Click:Connect(function()

    robotSpeed =
        robotSpeed + 10

    if robotSpeed > 100 then
        robotSpeed = 10
    end

    humanoid.WalkSpeed =
        robotSpeed

    speedButton.Text =
        "SPEED : "
        .. tostring(robotSpeed)
end)

--========================================================
-- JUMP
--========================================================

createLabel(
    "ROBOT JUMP POWER"
)

local jumpButton =
    createButton(
        "JUMP : 55",
        32
    )

jumpButton.MouseButton1Click:Connect(function()

    jumpPower =
        jumpPower + 10

    if jumpPower > 100 then
        jumpPower = 30
    end

    humanoid.JumpPower =
        jumpPower

    jumpButton.Text =
        "JUMP : "
        .. tostring(jumpPower)
end)

--========================================================
-- CAMERA ZOOM IN
--========================================================

local zoomIn =
    createButton(
        "🔍 CAMERA ZOOM IN",
        32
    )

zoomIn.MouseButton1Click:Connect(function()

    cameraTargetDistance =
        math.max(
            CAMERA_MIN,
            cameraTargetDistance - 5
        )
end)

--========================================================
-- CAMERA ZOOM OUT
--========================================================

local zoomOut =
    createButton(
        "🔎 CAMERA ZOOM OUT",
        32
    )

zoomOut.MouseButton1Click:Connect(function()

    cameraTargetDistance =
        math.min(
            CAMERA_MAX,
            cameraTargetDistance + 5
        )
end)

--========================================================
-- CAMERA RESET
--========================================================

local cameraReset =
    createButton(
        "🎥 RESET CAMERA",
        32
    )

cameraReset.MouseButton1Click:Connect(function()

    cameraYaw = 0
    cameraPitch = math.rad(12)

    cameraTargetDistance = 25
end)

--========================================================
-- INFO
--========================================================

createLabel(
    "PC: RMB drag = 360° camera"
)

createLabel(
    "PC: Mouse wheel = zoom"
)

createLabel(
    "Mobile: swipe = camera / pinch = zoom"
)

createLabel(
    "10 PROPS: HEAD • WAIST • HANDS • LEGS"
)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

    minimized =
        not minimized

    scroll.Visible =
        not minimized

    if minimized then

        main.Size =
            UDim2.fromOffset(
                245,
                48
            )

        minimize.Text = "+"

    else

        main.Size =
            UDim2.fromOffset(
                245,
                310
            )

        minimize.Text = "−"
    end
end)

--========================================================
-- DRAG SYSTEM
--========================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)

    local delta =
        input.Position - dragStart

    main.Position =
        UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
end

title.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            main.Position
    end
end)

title.InputChanged:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging then

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            updateDrag(input)
        end
    end
end)

--========================================================
-- RESIZE HANDLE
--========================================================

local resize =
    Instance.new("TextButton")

resize.Size =
    UDim2.fromOffset(
        18,
        18
    )

resize.Position =
    UDim2.new(
        1,
        -20,
        1,
        -20
    )

resize.BackgroundTransparency = 1

resize.Text =
    "◢"

resize.TextSize = 12

resize.TextColor3 =
    Color3.fromRGB(
        150,
        150,
        160
    )

resize.Parent = main

local resizing = false
local resizeStart
local originalSize

resize.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        resizing = true

        resizeStart =
            input.Position

        originalSize =
            main.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if resizing then

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            local delta =
                input.Position
                - resizeStart

            local newX =
                math.clamp(
                    originalSize.X.Offset
                    + delta.X,
                    190,
                    380
                )

            local newY =
                math.clamp(
                    originalSize.Y.Offset
                    + delta.Y,
                    220,
                    600
                )

            main.Size =
                UDim2.fromOffset(
                    newX,
                    newY
                )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        resizing = false
        dragging = false
    end
end)

--========================================================
-- INITIAL ROBOT
--========================================================

assembleRobot()

print("================================")
print("🎃 MANI PUMPKIN ROBO V.4")
print("10 PROPS READY")
print("ADVANCED CAMERA READY")
print("LEG GROUP ANIMATION READY")
print("================================")
