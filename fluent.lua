```lua
--========================================================
-- 🎃 MANI PUMPKIN ROBO V.1
-- FULL ROBOT CONTROL
-- PC + MOBILE
-- CUSTOM CAMERA + ZOOM
-- 10 PROPS ROBOT
--========================================================

repeat task.wait() until game:IsLoaded()

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

--========================================================
-- PROPS FOLDER
--========================================================

local workspaceCom = workspace:FindFirstChild("WorkspaceCom")

if not workspaceCom then
    warn("❌ WorkspaceCom not found")
    return
end

local propsFolder = workspaceCom:FindFirstChild("001_TrafficCones")

if not propsFolder then
    warn("❌ 001_TrafficCones not found")
    return
end

--========================================================
-- ROBOT SLOTS
--========================================================

local SLOTS = {
    [1] = "Head",
    [2] = "Waist",

    [3] = "Right Hand",
    [4] = "Left Hand",

    [5] = "Right Leg 1",
    [6] = "Right Leg 2",
    [7] = "Right Leg 3",

    [8] = "Left Leg 1",
    [9] = "Left Leg 2",
    [10] = "Left Leg 3",
}

--========================================================
-- BASE OFFSETS
--========================================================

local BASE_OFFSETS = {

    Head = Vector3.new(
        0,
        7.9,
        0
    ),

    Waist = Vector3.new(
        0,
        4.6,
        0
    ),

    ["Right Hand"] = Vector3.new(
        3.0,
        4.9,
        0
    ),

    ["Left Hand"] = Vector3.new(
        -3.0,
        4.9,
        0
    ),

    ["Right Leg 1"] = Vector3.new(
        1.45,
        2.7,
        0
    ),

    ["Right Leg 2"] = Vector3.new(
        1.45,
        1.35,
        0
    ),

    ["Right Leg 3"] = Vector3.new(
        1.45,
        0,
        0
    ),

    ["Left Leg 1"] = Vector3.new(
        -1.45,
        2.7,
        0
    ),

    ["Left Leg 2"] = Vector3.new(
        -1.45,
        1.35,
        0
    ),

    ["Left Leg 3"] = Vector3.new(
        -1.45,
        0,
        0
    ),
}

--========================================================
-- PROP ROTATION CORRECTION
--========================================================

local PART_CORRECTION = {

    Head = CFrame.identity,

    Waist = CFrame.Angles(
        0,
        math.rad(180),
        0
    ),

    ["Right Hand"] = CFrame.Angles(
        0,
        math.rad(180),
        0
    ),

    ["Left Hand"] = CFrame.Angles(
        0,
        math.rad(180),
        0
    ),
}

local HIP_Y = 2.7

--========================================================
-- SETTINGS
--========================================================

local robotHeight = 1
local propDistance = 1

local walkSpeed = 28
local jumpPower = 55

local controlEnabled = false
local headFollowCam = true

local registeredProps = {}

local robotCenter = nil
local robotRotation = nil
local robotAnchor = nil

local movementConnection = nil
local renderConnection = nil

--========================================================
-- ANIMATION STATE
--========================================================

local animClock = 0
local moveAmount = 0

local jumpState = "Ground"
local jumpVelocity = 0
local verticalOffset = 0

--========================================================
-- CAMERA
--========================================================

local camYaw = 0
local camPitch = 12
local camDist = 18

local targetCamYaw = 0
local targetCamPitch = 12
local targetCamDist = 18

local cameraDragging = false
local camDragStart = nil
local camYawStart = 0
local camPitchStart = 0

local CAM_MIN_DIST = 4
local CAM_MAX_DIST = 120

local CAM_MIN_PITCH = -70
local CAM_MAX_PITCH = 70

--========================================================
-- GUI
--========================================================

local oldGui = player.PlayerGui:FindFirstChild(
    "MANI_PUMPKIN_ROBO_V1"
)

if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "MANI_PUMPKIN_ROBO_V1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

--========================================================
-- MAIN
--========================================================

local main = Instance.new("Frame")

main.Name = "Main"
main.Size = UDim2.fromOffset(200, 245)

main.Position = UDim2.new(
    0.5,
    -100,
    0.5,
    -122
)

main.BackgroundColor3 = Color3.fromRGB(
    15,
    15,
    19
)

main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 13)

--========================================================
-- TITLE BAR
--========================================================

local titleBar = Instance.new("Frame")

titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(
    1,
    0,
    0,
    35
)

titleBar.BackgroundColor3 = Color3.fromRGB(
    25,
    25,
    31
)

titleBar.BorderSizePixel = 0
titleBar.Parent = main

Instance.new("UICorner", titleBar).CornerRadius =
    UDim.new(0, 13)

--========================================================
-- TITLE
--========================================================

local title = Instance.new("TextLabel")

title.BackgroundTransparency = 1

title.Position = UDim2.fromOffset(
    9,
    3
)

title.Size = UDim2.new(
    1,
    -68,
    0,
    29
)

title.Text = "🎃 MANI PUMPKIN ROBO V.1"

title.TextColor3 = Color3.fromRGB(
    255,
    255,
    255
)

title.TextSize = 10
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

--========================================================
-- MINIMIZE
--========================================================

local minimize = Instance.new("TextButton")

minimize.Size = UDim2.fromOffset(
    25,
    25
)

minimize.Position = UDim2.new(
    1,
    -55,
    0,
    5
)

minimize.Text = "—"

minimize.TextSize = 16

minimize.TextColor3 = Color3.fromRGB(
    255,
    255,
    255
)

minimize.BackgroundColor3 = Color3.fromRGB(
    43,
    43,
    50
)

minimize.BorderSizePixel = 0
minimize.Parent = titleBar

Instance.new("UICorner", minimize).CornerRadius =
    UDim.new(0, 6)

--========================================================
-- CLOSE
--========================================================

local close = Instance.new("TextButton")

close.Size = UDim2.fromOffset(
    25,
    25
)

close.Position = UDim2.new(
    1,
    -28,
    0,
    5
)

close.Text = "×"

close.TextSize = 17

close.TextColor3 = Color3.fromRGB(
    255,
    100,
    100
)

close.BackgroundColor3 = Color3.fromRGB(
    43,
    43,
    50
)

close.BorderSizePixel = 0
close.Parent = titleBar

Instance.new("UICorner", close).CornerRadius =
    UDim.new(0, 6)

--========================================================
-- GUI DRAG
--========================================================

local guiDragging = false
local guiDragStart = nil
local guiStartPosition = nil

titleBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        guiDragging = true

        guiDragStart = input.Position
        guiStartPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not guiDragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - guiDragStart

        main.Position = UDim2.new(
            guiStartPosition.X.Scale,
            guiStartPosition.X.Offset + delta.X,

            guiStartPosition.Y.Scale,
            guiStartPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        guiDragging = false
    end
end)

--========================================================
-- SCROLL
--========================================================

local scroll = Instance.new("ScrollingFrame")

scroll.Position = UDim2.fromOffset(
    6,
    41
)

scroll.Size = UDim2.new(
    1,
    -12,
    1,
    -48
)

scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0

scroll.ScrollBarThickness = 3

scroll.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        660
    )

scroll.Parent = main

--========================================================
-- CONTENT
--========================================================

local content = Instance.new("Frame")

content.BackgroundTransparency = 1

content.Size = UDim2.new(
    1,
    -6,
    0,
    650
)

content.Parent = scroll

--========================================================
-- STATUS
--========================================================

local status = Instance.new("TextLabel")

status.BackgroundTransparency = 1

status.Position = UDim2.fromOffset(
    4,
    0
)

status.Size = UDim2.new(
    1,
    -8,
    0,
    22
)

status.Text = "PROPS 0 / 10"

status.TextColor3 = Color3.fromRGB(
    180,
    180,
    190
)

status.TextSize = 10
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left

status.Parent = content

--========================================================
-- SLOT FRAME
--========================================================

local slotFrame = Instance.new("Frame")

slotFrame.Position = UDim2.fromOffset(
    4,
    25
)

slotFrame.Size = UDim2.new(
    1,
    -8,
    0,
    138
)

slotFrame.BackgroundColor3 = Color3.fromRGB(
    9,
    9,
    12
)

slotFrame.BorderSizePixel = 0
slotFrame.Parent = content

Instance.new("UICorner", slotFrame).CornerRadius =
    UDim.new(0, 8)

local slotList = Instance.new("UIListLayout")

slotList.Padding =
    UDim.new(0, 1)

slotList.Parent = slotFrame

local slotLabels = {}

for i = 1, 10 do

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(
        1,
        -6,
        0,
        13
    )

    label.BackgroundTransparency = 1

    label.Text =
        i .. ". " .. SLOTS[i] .. " [EMPTY]"

    label.TextColor3 =
        Color3.fromRGB(
            145,
            145,
            155
        )

    label.TextSize = 9

    label.Font =
        Enum.Font.GothamMedium

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = slotFrame

    slotLabels[i] = label
end

--========================================================
-- BUTTON FUNCTION
--========================================================

local function createButton(text, y)

    local b = Instance.new("TextButton")

    b.Position =
        UDim2.fromOffset(
            4,
            y
        )

    b.Size =
        UDim2.new(
            1,
            -8,
            0,
            27
        )

    b.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            43
        )

    b.BorderSizePixel = 0

    b.Text = text

    b.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    b.TextSize = 9

    b.Font =
        Enum.Font.GothamBold

    b.Parent = content

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 7)

    return b
end

--========================================================
-- BUTTONS
--========================================================

local loadButton =
    createButton(
        "LOAD 10 PROPS",
        168
    )

local assembleButton =
    createButton(
        "🤖 ASSEMBLE ROBOT",
        199
    )

--========================================================
-- VALUE ROW
--========================================================

local function makeValueRow(
    labelText,
    y,
    initial
)

    local label = Instance.new("TextLabel")

    label.Position =
        UDim2.fromOffset(
            4,
            y
        )

    label.Size =
        UDim2.new(
            1,
            -78,
            0,
            27
        )

    label.BackgroundTransparency = 1

    label.Text =
        labelText ..
        ": " ..
        tostring(initial)

    label.TextColor3 =
        Color3.fromRGB(
            215,
            215,
            220
        )

    label.TextSize = 9

    label.Font =
        Enum.Font.GothamBold

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = content

    local minus =
        createButton(
            "−",
            y
        )

    minus.Position =
        UDim2.new(
            1,
            -58,
            0,
            y
        )

    minus.Size =
        UDim2.fromOffset(
            24,
            27
        )

    local plus =
        createButton(
            "+",
            y
        )

    plus.Position =
        UDim2.new(
            1,
            -30,
            0,
            y
        )

    plus.Size =
        UDim2.fromOffset(
            24,
            27
        )

    return label, minus, plus
end

--========================================================
-- SETTINGS ROWS
--========================================================

local heightLabel,
heightMinus,
heightPlus =
    makeValueRow(
        "HEIGHT",
        232,
        "1.00"
    )

local distanceLabel,
distanceMinus,
distancePlus =
    makeValueRow(
        "DISTANCE",
        263,
        "1.00"
    )

local speedLabel,
speedMinus,
speedPlus =
    makeValueRow(
        "WALK SPD",
        294,
        walkSpeed
    )

local jumpLabel,
jumpMinus,
jumpPlus =
    makeValueRow(
        "JUMP PWR",
        325,
        jumpPower
    )

--========================================================
-- HEAD FOLLOW
--========================================================

local headToggle =
    createButton(
        "HEAD 360° FOLLOW: ON",
        357
    )

headToggle.TextSize = 8

--========================================================
-- CONTROL
--========================================================

local controlButton =
    createButton(
        "CONTROL: OFF",
        389
    )

--========================================================
-- CAMERA INFO
--========================================================

local cameraInfo =
    Instance.new("TextLabel")

cameraInfo.Position =
    UDim2.fromOffset(
        4,
        422
    )

cameraInfo.Size =
    UDim2.new(
        1,
        -8,
        0,
        58
    )

cameraInfo.BackgroundColor3 =
    Color3.fromRGB(
        23,
        23,
        29
    )

cameraInfo.BorderSizePixel = 0

cameraInfo.Text =
    "CAMERA / CONTROL\n\n" ..
    "PC: WASD • RMB Camera • Wheel Zoom • Space Jump\n" ..
    "Mobile: Joystick • Right Drag • Pinch Zoom"

cameraInfo.TextColor3 =
    Color3.fromRGB(
        160,
        160,
        170
    )

cameraInfo.TextSize = 7

cameraInfo.Font =
    Enum.Font.GothamMedium

cameraInfo.TextXAlignment =
    Enum.TextXAlignment.Left

cameraInfo.TextYAlignment =
    Enum.TextYAlignment.Center

cameraInfo.Parent = content

Instance.new("UICorner", cameraInfo).CornerRadius =
    UDim.new(0, 7)

--========================================================
-- RESIZE
--========================================================

local resize =
    Instance.new("TextButton")

resize.Size =
    UDim2.fromOffset(
        17,
        17
    )

resize.Position =
    UDim2.new(
        1,
        -17,
        1,
        -17
    )

resize.BackgroundTransparency = 1

resize.Text = "◢"

resize.TextColor3 =
    Color3.fromRGB(
        100,
        100,
        110
    )

resize.TextSize = 11

resize.Parent = main

local resizing = false
local resizeStart = nil
local originalSize = nil

resize.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        resizing = true

        resizeStart =
            input.Position

        originalSize =
            main.AbsoluteSize
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not resizing then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position -
            resizeStart

        local w =
            math.clamp(
                originalSize.X + delta.X,
                165,
                330
            )

        local h =
            math.clamp(
                originalSize.Y + delta.Y,
                170,
                500
            )

        main.Size =
            UDim2.fromOffset(
                w,
                h
            )
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        resizing = false
    end
end)

--========================================================
-- UPDATE SLOTS
--========================================================

local function updateSlots()

    local count = 0

    for i = 1, 10 do

        if registeredProps[i] then

            count += 1

            slotLabels[i].Text =
                i ..
                ". " ..
                SLOTS[i] ..
                " [LOCKED]"

            slotLabels[i].TextColor3 =
                Color3.fromRGB(
                    90,
                    255,
                    140
                )

        else

            slotLabels[i].Text =
                i ..
                ". " ..
                SLOTS[i] ..
                " [EMPTY]"

            slotLabels[i].TextColor3 =
                Color3.fromRGB(
                    145,
                    145,
                    155
                )
        end
    end

    status.Text =
        "PROPS " ..
        count ..
        " / 10"
end

--========================================================
-- LOAD PROPS
--========================================================

local function loadProps()

    registeredProps = {}

    local found = {}

    for _, prop in
        ipairs(propsFolder:GetChildren()) do

        if string.find(
            prop.Name,
            player.Name
        ) then

            table.insert(
                found,
                prop
            )
        end
    end

    table.sort(
        found,
        function(a, b)
            return a.Name < b.Name
        end
    )

    for i = 1,
        math.min(#found, 10) do

        registeredProps[i] =
            found[i]
    end

    updateSlots()

    status.Text =
        "LOADED " ..
        math.min(#found, 10) ..
        " / 10"
end

--========================================================
-- MOVE PROP
--========================================================

local function moveProp(
    prop,
    cf
)

    if not prop then
        return
    end

    local remote =
        prop:FindFirstChild(
            "SetCurrentCFrame"
        )

    if remote then

        pcall(function()

            remote:InvokeServer(
                cf
            )

        end)
    end
end

--========================================================
-- BODY CFRAME
--========================================================

local function bodyCFrame(
    offset,
    slot,
    rotationOffset,
    extraOffset
)

    extraOffset =
        extraOffset or Vector3.zero

    rotationOffset =
        rotationOffset or
        CFrame.identity

    if not robotRotation then
        return CFrame.new(
            robotCenter
        )
    end

    local right =
        robotRotation.RightVector

    local forward =
        robotRotation.LookVector

    local pos =
        robotCenter

        + right *
        offset.X *
        propDistance

        + Vector3.new(
            0,
            offset.Y *
            robotHeight,
            0
        )

        + forward *
        offset.Z *
        propDistance

        + extraOffset

    local correction =
        PART_CORRECTION[slot]
        or CFrame.identity

    return
        CFrame.new(
            pos,
            pos + forward
        )
        * correction
        * rotationOffset
end

--========================================================
-- LEG CFRAME
--========================================================

local function legBodyCFrame(
    offset,
    angle,
    extraOffset
)

    extraOffset =
        extraOffset or Vector3.zero

    if not robotRotation then
        return CFrame.new(
            robotCenter
        )
    end

    local relY =
        offset.Y - HIP_Y

    local relZ =
        offset.Z

    local cosA =
        math.cos(angle)

    local sinA =
        math.sin(angle)

    local newY =
        relY * cosA -
        relZ * sinA

    local newZ =
        relY * sinA +
        relZ * cosA

    local finalLocal =
        Vector3.new(
            offset.X,
            HIP_Y + newY,
            newZ
        )

    local right =
        robotRotation.RightVector

    local forward =
        robotRotation.LookVector

    local pos =
        robotCenter

        + right *
        finalLocal.X *
        propDistance

        + Vector3.new(
            0,
            finalLocal.Y *
            robotHeight,
            0
        )

        + forward *
        finalLocal.Z *
        propDistance

        + extraOffset

    return
        CFrame.new(
            pos,
            pos + forward
        )
        * CFrame.Angles(
            angle,
            0,
            0
        )
end

--========================================================
-- ASSEMBLE ROBOT
--========================================================

local function assembleRobot()

    if not registeredProps[1] then
        loadProps()
    end

    if not registeredProps[1] then

        status.Text =
            "NO PROPS"

        return
    end

    robotCenter =
        hrp.Position
        + hrp.CFrame.LookVector * 8

    robotRotation =
        CFrame.lookAt(
            robotCenter,
            robotCenter +
            hrp.CFrame.LookVector
        )

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local slot =
                SLOTS[i]

            local offset =
                BASE_OFFSETS[slot]

            if offset then

                moveProp(
                    prop,
                    bodyCFrame(
                        offset,
                        slot
                    )
                )
            end

            task.wait(0.08)
        end
    end

    status.Text =
        "🤖 ROBOT READY"
end

--========================================================
-- REBUILD ROBOT
--========================================================

local function rebuildRobot()

    if not robotCenter
        or not robotRotation then

        return
    end

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local slot =
                SLOTS[i]

            local offset =
                BASE_OFFSETS[slot]

            if offset then

                moveProp(
                    prop,
                    bodyCFrame(
                        offset,
                        slot
                    )
                )
            end
        end
    end
end

--========================================================
-- SETTINGS
--========================================================

heightMinus.MouseButton1Click:Connect(function()

    robotHeight =
        math.max(
            0.5,
            robotHeight - 0.1
        )

    heightLabel.Text =
        string.format(
            "HEIGHT: %.2f",
            robotHeight
        )

    rebuildRobot()
end)

heightPlus.MouseButton1Click:Connect(function()

    robotHeight =
        math.min(
            3,
            robotHeight + 0.1
        )

    heightLabel.Text =
        string.format(
            "HEIGHT: %.2f",
            robotHeight
        )

    rebuildRobot()
end)

distanceMinus.MouseButton1Click:Connect(function()

    propDistance =
        math.max(
            0.5,
            propDistance - 0.1
        )

    distanceLabel.Text =
        string.format(
            "DISTANCE: %.2f",
            propDistance
        )

    rebuildRobot()
end)

distancePlus.MouseButton1Click:Connect(function()

    propDistance =
        math.min(
            3,
            propDistance + 0.1
        )

    distanceLabel.Text =
        string.format(
            "DISTANCE: %.2f",
            propDistance
        )

    rebuildRobot()
end)

speedMinus.MouseButton1Click:Connect(function()

    walkSpeed =
        math.max(
            5,
            walkSpeed - 5
        )

    speedLabel.Text =
        "WALK SPD: " ..
        walkSpeed
end)

speedPlus.MouseButton1Click:Connect(function()

    walkSpeed =
        math.min(
            100,
            walkSpeed + 5
        )

    speedLabel.Text =
        "WALK SPD: " ..
        walkSpeed
end)

jumpMinus.MouseButton1Click:Connect(function()

    jumpPower =
        math.max(
            20,
            jumpPower - 5
        )

    jumpLabel.Text =
        "JUMP PWR: " ..
        jumpPower
end)

jumpPlus.MouseButton1Click:Connect(function()

    jumpPower =
        math.min(
            150,
            jumpPower + 5
        )

    jumpLabel.Text =
        "JUMP PWR: " ..
        jumpPower
end)

headToggle.MouseButton1Click:Connect(function()

    headFollowCam =
        not headFollowCam

    headToggle.Text =
        "HEAD 360° FOLLOW: " ..
        (
            headFollowCam
            and "ON"
            or "OFF"
        )
end)

--========================================================
-- ROBOT ANCHOR
--========================================================

local function createAnchor()

    if robotAnchor then
        robotAnchor:Destroy()
    end

    robotAnchor =
        Instance.new("Part")

    robotAnchor.Name =
        "MANI_ROBO_ANCHOR"

    robotAnchor.Size =
        Vector3.new(
            2,
            4,
            2
        )

    robotAnchor.Transparency = 1

    robotAnchor.Anchored = true

    robotAnchor.CanCollide = false
    robotAnchor.CanTouch = false
    robotAnchor.CanQuery = false

    robotAnchor.CFrame =
        robotRotation

    robotAnchor.Parent =
        workspace
end

--========================================================
-- ROBOT MOVEMENT INPUT
--========================================================

local function getRobotMoveDirection()

    ------------------------------------------------
    -- MOBILE + DEFAULT ROBLOX CONTROLS
    ------------------------------------------------

    local moveDir =
        humanoid.MoveDirection

    if moveDir.Magnitude > 0.05 then

        return Vector3.new(
            moveDir.X,
            0,
            moveDir.Z
        ).Unit
    end

    ------------------------------------------------
    -- PC KEYBOARD FALLBACK
    ------------------------------------------------

    local camCF =
        camera.CFrame

    local forward =
        Vector3.new(
            camCF.LookVector.X,
            0,
            camCF.LookVector.Z
        )

    local right =
        Vector3.new(
            camCF.RightVector.X,
            0,
            camCF.RightVector.Z
        )

    if forward.Magnitude > 0.01 then
        forward = forward.Unit
    end

    if right.Magnitude > 0.01 then
        right = right.Unit
    end

    local direction =
        Vector3.zero

    if UserInputService:IsKeyDown(
        Enum.KeyCode.W
    )
    or UserInputService:IsKeyDown(
        Enum.KeyCode.Up
    ) then

        direction += forward
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.S
    )
    or UserInputService:IsKeyDown(
        Enum.KeyCode.Down
    ) then

        direction -= forward
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.D
    )
    or UserInputService:IsKeyDown(
        Enum.KeyCode.Right
    ) then

        direction += right
    end

    if UserInputService:IsKeyDown(
        Enum.KeyCode.A
    )
    or UserInputService:IsKeyDown(
        Enum.KeyCode.Left
    ) then

        direction -= right
    end

    if direction.Magnitude > 0.05 then

        return direction.Unit
    end

    return Vector3.zero
end

--========================================================
-- ROBOT MOVEMENT
--========================================================

local function startMovement()

    if movementConnection then

        movementConnection:Disconnect()

        movementConnection = nil
    end

    movementConnection =
        RunService.Heartbeat:Connect(
            function(dt)

                if not controlEnabled then
                    return
                end

                if not robotAnchor then
                    return
                end

                ------------------------------------------------
                -- READ INPUT
                ------------------------------------------------

                local direction =
                    getRobotMoveDirection()

                ------------------------------------------------
                -- MOVE
                ------------------------------------------------

                if direction.Magnitude > 0.05 then

                    local currentPosition =
                        robotAnchor.Position

                    local newPosition =
                        currentPosition
                        + direction *
                        walkSpeed *
                        dt

                    ------------------------------------------------
                    -- ROTATE ROBOT
                    ------------------------------------------------

                    local target =
                        CFrame.lookAt(
                            newPosition,
                            newPosition +
                            direction
                        )

                    robotAnchor.CFrame =
                        robotAnchor.CFrame:Lerp(
                            target,
                            math.clamp(
                                15 * dt,
                                0,
                                1
                            )
                        )

                    moveAmount =
                        math.clamp(
                            moveAmount +
                            dt * 8,
                            0,
                            1
                        )

                else

                    moveAmount =
                        math.clamp(
                            moveAmount -
                            dt * 10,
                            0,
                            1
                        )
                end

                ------------------------------------------------
                -- JUMP PHYSICS
                ------------------------------------------------

                if jumpState == "Jump" then

                    jumpVelocity -=
                        100 * dt

                    verticalOffset +=
                        jumpVelocity * dt

                    if verticalOffset <= 0 then

                        verticalOffset = 0
                        jumpVelocity = 0
                        jumpState = "Ground"

                    end
                end

                ------------------------------------------------
                -- UPDATE ROBOT POSITION
                ------------------------------------------------

                robotCenter =
                    robotAnchor.Position
                    + Vector3.new(
                        0,
                        verticalOffset,
                        0
                    )

                robotRotation =
                    robotAnchor.CFrame

                ------------------------------------------------
                -- SYNC REAL CHARACTER
                ------------------------------------------------

                if hrp
                    and hrp.Parent then

                    hrp.CFrame =
                        robotAnchor.CFrame
                        + Vector3.new(
                            0,
                            verticalOffset,
                            0
                        )

                    -- Prevent physics from pushing
                    -- the hidden character around.

                    hrp.AssemblyLinearVelocity =
                        Vector3.zero

                    hrp.AssemblyAngularVelocity =
                        Vector3.zero
                end
            end
        )
end

--========================================================
-- HEAD CAMERA YAW
--========================================================

local function getHeadYaw()

    if not robotAnchor then
        return 0
    end

    local camLook =
        camera.CFrame.LookVector

    camLook =
        Vector3.new(
            camLook.X,
            0,
            camLook.Z
        )

    if camLook.Magnitude < 0.01 then
        return 0
    end

    camLook =
        camLook.Unit

    local robotLook =
        robotAnchor.CFrame.LookVector

    robotLook =
        Vector3.new(
            robotLook.X,
            0,
            robotLook.Z
        )

    if robotLook.Magnitude < 0.01 then
        return 0
    end

    robotLook =
        robotLook.Unit

    local dot =
        robotLook:Dot(
            camLook
        )

    local cross =
        robotLook:Cross(
            camLook
        ).Y

    return math.atan2(
        cross,
        dot
    )
end

--========================================================
-- ANIMATION
--========================================================

local function updateAnimation(dt)

    if not controlEnabled
        or not robotCenter then

        return
    end

    animClock += dt

    local moving =
        moveAmount > 0.05

    local cycle =
        math.sin(
            animClock * 9
        )

    local opposite =
        math.sin(
            animClock * 9 +
            math.pi
        )

    local idle =
        math.sin(
            animClock * 2
        )

    ------------------------------------------------
    -- BODY BOB
    ------------------------------------------------

    local idleBob = 0

    local walkBob = 0

    local jumpBob = 0

    if not moving
        and jumpState == "Ground" then

        idleBob =
            idle * 0.08
    end

    if moving
        and jumpState == "Ground" then

        walkBob =
            math.abs(cycle) *
            0.10
    end

    if jumpState == "Jump" then

        jumpBob = 0.15
    end

    ------------------------------------------------
    -- LEG MOVEMENT
    ------------------------------------------------

    local rightLegAngle = 0
    local leftLegAngle = 0

    if jumpState == "Jump" then

        -- Both leg groups move together
        -- during jump.

        rightLegAngle =
            math.rad(15)

        leftLegAngle =
            math.rad(15)

    elseif moving then

        rightLegAngle =
            math.rad(
                opposite * 25
            )

        leftLegAngle =
            math.rad(
                cycle * 25
            )
    end

    ------------------------------------------------
    -- HEAD
    ------------------------------------------------

    local headYawAngle = 0

    if headFollowCam then

        headYawAngle =
            getHeadYaw()
    end

    ------------------------------------------------
    -- APPLY ALL PROPS
    ------------------------------------------------

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local slot =
                SLOTS[i]

            local offset =
                BASE_OFFSETS[slot]

            if offset then

                local animationOffset =
                    Vector3.new(
                        0,
                        idleBob +
                        walkBob +
                        jumpBob,
                        0
                    )

                ------------------------------------------------
                -- RIGHT LEGS
                ------------------------------------------------

                if string.find(
                    slot,
                    "Right Leg"
                ) then

                    moveProp(
                        prop,
                        legBodyCFrame(
                            offset,
                            rightLegAngle,
                            animationOffset
                        )
                    )

                ------------------------------------------------
                -- LEFT LEGS
                ------------------------------------------------

                elseif string.find(
                    slot,
                    "Left Leg"
                ) then

                    moveProp(
                        prop,
                        legBodyCFrame(
                            offset,
                            leftLegAngle,
                            animationOffset
                        )
                    )

                ------------------------------------------------
                -- HEAD
                ------------------------------------------------

                elseif slot == "Head" then

                    local rot

                    if moving then

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    opposite * 3
                                ),
                                headYawAngle,
                                math.rad(
                                    cycle * 2
                                )
                            )

                    else

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    idle * 1.5
                                ),
                                headYawAngle,
                                math.rad(
                                    idle * 1.2
                                )
                            )
                    end

                    moveProp(
                        prop,
                        bodyCFrame(
                            offset,
                            slot,
                            rot,
                            animationOffset
                        )
                    )

                ------------------------------------------------
                -- WAIST
                ------------------------------------------------

                elseif slot == "Waist" then

                    local rot =
                        CFrame.identity

                    if moving then

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    opposite * 4
                                ),
                                0,
                                math.rad(
                                    cycle * 3
                                )
                            )
                    end

                    moveProp(
                        prop,
                        bodyCFrame(
                            offset,
                            slot,
                            rot,
                            animationOffset
                        )
                    )

                ------------------------------------------------
                -- RIGHT HAND
                ------------------------------------------------

                elseif slot == "Right Hand" then

                    local rot

                    local extra =
                        animationOffset

                    if jumpState == "Jump" then

                        rot =
                            CFrame.Angles(
                                math.rad(-35),
                                0,
                                0
                            )

                    elseif moving then

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    cycle * 25
                                ),
                                0,
                                0
                            )

                        extra +=
                            Vector3.new(
                                0,
                                0,
                                cycle * 0.12
                            )

                    else

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    idle * 3
                                ),
                                0,
                                0
                            )
                    end

                    moveProp(
                        prop,
                        bodyCFrame(
                            offset,
                            slot,
                            rot,
                            extra
                        )
                    )

                ------------------------------------------------
                -- LEFT HAND
                ------------------------------------------------

                elseif slot == "Left Hand" then

                    local rot

                    local extra =
                        animationOffset

                    if jumpState == "Jump" then

                        rot =
                            CFrame.Angles(
                                math.rad(-35),
                                0,
                                0
                            )

                    elseif moving then

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    opposite * 25
                                ),
                                0,
                                0
                            )

                        extra +=
                            Vector3.new(
                                0,
                                0,
                                opposite * 0.12
                            )

                    else

                        rot =
                            CFrame.Angles(
                                math.rad(
                                    opposite * 3
                                ),
                                0,
                                0
                            )
                    end

                    moveProp(
                        prop,
                        bodyCFrame(
                            offset,
                            slot,
                            rot,
                            extra
                        )
                    )
                end
            end
        end
    end
end

--========================================================
-- CUSTOM CAMERA
--========================================================

-- PC RMB camera
UserInputService.InputBegan:Connect(
    function(input, gameProcessed)

        if gameProcessed then
            return
        end

        if not controlEnabled then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseButton2 then

            cameraDragging = true

            camDragStart =
                input.Position

            camYawStart =
                targetCamYaw

            camPitchStart =
                targetCamPitch
        end
    end
)

-- PC mouse movement + wheel
UserInputService.InputChanged:Connect(
    function(input)

        if not controlEnabled then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement

            and cameraDragging then

            local delta =
                input.Position -
                camDragStart

            targetCamYaw =
                camYawStart -
                delta.X * 0.4

            targetCamPitch =
                math.clamp(
                    camPitchStart -
                    delta.Y * 0.3,

                    CAM_MIN_PITCH,
                    CAM_MAX_PITCH
                )
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseWheel then

            targetCamDist =
                math.clamp(
                    targetCamDist -
                    input.Position.Z * 3,

                    CAM_MIN_DIST,
                    CAM_MAX_DIST
                )
        end
    end
)

UserInputService.InputEnded:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton2 then

            cameraDragging = false
        end
    end
)

--========================================================
-- MOBILE CAMERA
--========================================================

local mobileTouchId = nil
local secondTouch = nil

local mobilePinching = false

local pinchStartDist = 0
local pinchStartZoom = 0

UserInputService.TouchStarted:Connect(
    function(touch)

        if not controlEnabled then
            return
        end

        ------------------------------------------------
        -- RIGHT SIDE CAMERA AREA
        ------------------------------------------------

        if touch.Position.X >
            camera.ViewportSize.X * 0.35 then

            if not mobileTouchId then

                mobileTouchId =
                    touch

                camDragStart =
                    touch.Position

                camYawStart =
                    targetCamYaw

                camPitchStart =
                    targetCamPitch

            elseif not secondTouch then

                secondTouch =
                    touch

                mobilePinching = true

                pinchStartDist =
                    (
                        mobileTouchId.Position -
                        secondTouch.Position
                    ).Magnitude

                pinchStartZoom =
                    targetCamDist
            end
        end
    end
)

UserInputService.TouchMoved:Connect(
    function(touch)

        if not controlEnabled then
            return
        end

        ------------------------------------------------
        -- CAMERA DRAG
        ------------------------------------------------

        if touch ==
            mobileTouchId

            and not mobilePinching then

            local delta =
                touch.Position -
                camDragStart

            targetCamYaw =
                camYawStart -
                delta.X * 0.4

            targetCamPitch =
                math.clamp(
                    camPitchStart -
                    delta.Y * 0.3,

                    CAM_MIN_PITCH,
                    CAM_MAX_PITCH
                )
        end

        ------------------------------------------------
        -- PINCH ZOOM
        ------------------------------------------------

        if mobilePinching
            and mobileTouchId
            and secondTouch then

            local p1 =
                (
                    touch ==
                    mobileTouchId
                )
                and touch.Position
                or mobileTouchId.Position

            local p2 =
                (
                    touch ==
                    secondTouch
                )
                and touch.Position
                or secondTouch.Position

            local distance =
                (p1 - p2).Magnitude

            if pinchStartDist > 0
                and distance > 0 then

                targetCamDist =
                    math.clamp(
                        pinchStartZoom *
                        (
                            pinchStartDist /
                            distance
                        ),

                        CAM_MIN_DIST,
                        CAM_MAX_DIST
                    )
            end
        end
    end
)

UserInputService.TouchEnded:Connect(
    function(touch)

        if touch ==
            mobileTouchId then

            mobileTouchId = nil

            if secondTouch then

                mobileTouchId =
                    secondTouch

                secondTouch = nil

                camDragStart =
                    mobileTouchId.Position

                camYawStart =
                    targetCamYaw

                camPitchStart =
                    targetCamPitch

            end

            mobilePinching = false

        elseif touch ==
            secondTouch then

            secondTouch = nil

            mobilePinching = false
        end
    end
)

--========================================================
-- CAMERA UPDATE
--========================================================

local function updateCamera(dt)

    if not controlEnabled
        or not robotAnchor then

        return
    end

    camYaw =
        camYaw +
        (
            targetCamYaw -
            camYaw
        ) *
        math.clamp(
            10 * dt,
            0,
            1
        )

    camPitch =
        camPitch +
        (
            targetCamPitch -
            camPitch
        ) *
        math.clamp(
            10 * dt,
            0,
            1
        )

    camDist =
        camDist +
        (
            targetCamDist -
            camDist
        ) *
        math.clamp(
            8 * dt,
            0,
            1
        )

    local center =
        robotAnchor.Position
        + Vector3.new(
            0,
            3.2 *
            robotHeight,
            0
        )

    local rot =
        CFrame.Angles(
            0,
            math.rad(camYaw),
            0
        )
        *
        CFrame.Angles(
            math.rad(camPitch),
            0,
            0
        )

    local desired =
        center -
        rot.LookVector *
        camDist

    camera.CFrame =
        CFrame.lookAt(
            desired,
            center
        )
end

--========================================================
-- JUMP
--========================================================

UserInputService.JumpRequest:Connect(
    function()

        if not controlEnabled then
            return
        end

        if jumpState ~= "Ground" then
            return
        end

        jumpState = "Jump"

        jumpVelocity =
            jumpPower
    end
)

--========================================================
-- HIDE CHARACTER
--========================================================

local hiddenState = {}

local function hideCharacter()

    hiddenState = {}

    for _, obj in
        ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart")
            or obj:IsA("Decal") then

            hiddenState[obj] = {

                transparency =
                    obj.Transparency,

                canCollide =
                    obj:IsA("BasePart")
                    and obj.CanCollide
                    or nil
            }

            obj.Transparency = 1

            if obj:IsA("BasePart") then

                obj.CanCollide = false
                obj.CanTouch = false
                obj.CanQuery = false

            end
        end
    end
end

--========================================================
-- SHOW CHARACTER
--========================================================

local function showCharacter()

    for obj, state in
        pairs(hiddenState) do

        if obj
            and obj.Parent then

            obj.Transparency =
                state.transparency

            if obj:IsA("BasePart") then

                obj.CanCollide =
                    state.canCollide

                obj.CanTouch = true
                obj.CanQuery = true

            end
        end
    end

    hiddenState = {}
end

--========================================================
-- START CONTROL
--========================================================

local function startControl()

    if not robotCenter then

        assembleRobot()
    end

    if not robotCenter then
        return
    end

    ------------------------------------------------
    -- ANCHOR
    ------------------------------------------------

    createAnchor()

    ------------------------------------------------
    -- ENABLE
    ------------------------------------------------

    controlEnabled = true

    controlButton.Text =
        "CONTROL: ON"

    ------------------------------------------------
    -- IMPORTANT
    -- KEEP HUMANOID ACTIVE
    -- FOR MOBILE JOYSTICK
    ------------------------------------------------

    hrp.Anchored = false

    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    humanoid.AutoRotate = false

    ------------------------------------------------
    -- RESET PHYSICS
    ------------------------------------------------

    hrp.AssemblyLinearVelocity =
        Vector3.zero

    hrp.AssemblyAngularVelocity =
        Vector3.zero

    hrp.CFrame =
        robotAnchor.CFrame

    ------------------------------------------------
    -- HIDE CHARACTER
    ------------------------------------------------

    hideCharacter()

    ------------------------------------------------
    -- CAMERA
    ------------------------------------------------

    camera.CameraType =
        Enum.CameraType.Scriptable

    targetCamYaw = 0
    targetCamPitch = 12
    targetCamDist = 18

    camYaw = 0
    camPitch = 12
    camDist = 18

    ------------------------------------------------
    -- START MOVEMENT
    ------------------------------------------------

    startMovement()

    ------------------------------------------------
    -- RENDER
    ------------------------------------------------

    if renderConnection then

        renderConnection:Disconnect()
    end

    renderConnection =
        RunService.RenderStepped:Connect(
            function(dt)

                if not controlEnabled then
                    return
                end

                updateAnimation(dt)
                updateCamera(dt)
            end
        )
end

--========================================================
-- STOP CONTROL
--========================================================

local function stopControl()

    controlEnabled = false

    moveAmount = 0

    jumpState = "Ground"
    jumpVelocity = 0
    verticalOffset = 0

    ------------------------------------------------
    -- CONNECTIONS
    ------------------------------------------------

    if movementConnection then

        movementConnection:Disconnect()

        movementConnection = nil
    end

    if renderConnection then

        renderConnection:Disconnect()

        renderConnection = nil
    end

    ------------------------------------------------
    -- PLAYER
    ------------------------------------------------

    if hrp then

        hrp.Anchored = false
    end

    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    humanoid.AutoRotate = true

    ------------------------------------------------
    -- CAMERA
    ------------------------------------------------

    camera.CameraType =
        Enum.CameraType.Custom

    camera.CameraSubject =
        humanoid

    ------------------------------------------------
    -- SHOW PLAYER
    ------------------------------------------------

    showCharacter()

    ------------------------------------------------
    -- ROBOT LAST POSITION
    ------------------------------------------------

    rebuildRobot()

    ------------------------------------------------
    -- BUTTON
    ------------------------------------------------

    controlButton.Text =
        "CONTROL: OFF"

    ------------------------------------------------
    -- DESTROY ANCHOR
    ------------------------------------------------

    if robotAnchor then

        robotAnchor:Destroy()

        robotAnchor = nil
    end
end

--========================================================
-- CONTROL BUTTON
--========================================================

controlButton.MouseButton1Click:Connect(
    function()

        if controlEnabled then

            stopControl()

        else

            startControl()
        end
    end
)

--========================================================
-- LOAD BUTTON
--========================================================

loadButton.MouseButton1Click:Connect(
    function()

        loadProps()
    end
)

--========================================================
-- ASSEMBLE BUTTON
--========================================================

assembleButton.MouseButton1Click:Connect(
    function()

        assembleRobot()
    end
)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

minimize.MouseButton1Click:Connect(
    function()

        minimized =
            not minimized

        scroll.Visible =
            not minimized

        resize.Visible =
            not minimized

        if minimized then

            main.Size =
                UDim2.fromOffset(
                    200,
                    35
                )

            minimize.Text = "+"

        else

            main.Size =
                UDim2.fromOffset(
                    200,
                    245
                )

            minimize.Text = "—"
        end
    end
)

--========================================================
-- CLOSE
--========================================================

close.MouseButton1Click:Connect(
    function()

        if controlEnabled then
            stopControl()
        end

        gui:Destroy()
    end
)

--========================================================
-- RESPAWN
--========================================================

player.CharacterAdded:Connect(
    function(newCharacter)

        if controlEnabled then
            stopControl()
        end

        character =
            newCharacter

        humanoid =
            character:WaitForChild(
                "Humanoid"
            )

        hrp =
            character:WaitForChild(
                "HumanoidRootPart"
            )

        camera =
            workspace.CurrentCamera
    end
)

--========================================================
-- INIT
--========================================================

updateSlots()

print(
    "🎃 MANI PUMPKIN ROBO V.1 LOADED"
)

--========================================================
-- END
--========================================================
```
