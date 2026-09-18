--========================================================
-- 🎃 MANI PUMPKIN ROBO V.2
-- 10 PROP ROBOT
-- R6 / R15 STYLE ANIMATION
-- PC + MOBILE
--========================================================

repeat task.wait() until game:IsLoaded()

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character =
    player.Character or player.CharacterAdded:Wait()

local humanoid =
    character:WaitForChild("Humanoid")

local hrp =
    character:WaitForChild("HumanoidRootPart")

--========================================================
-- PROPS FOLDER
--========================================================

local propsFolder =
    workspace:FindFirstChild("WorkspaceCom")
    and workspace.WorkspaceCom:FindFirstChild(
        "001_TrafficCones"
    )

if not propsFolder then

    warn(
        "❌ WorkspaceCom > 001_TrafficCones nahi mila"
    )

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
-- ROBOT BODY OFFSETS
--========================================================

-- Head ko waist se clearly separate rakha hai.

local BASE_OFFSETS = {

    Head =
        Vector3.new(
            0,
            6.6,
            0
        ),

    Waist =
        Vector3.new(
            0,
            3.5,
            0
        ),

    ["Right Hand"] =
        Vector3.new(
            2.8,
            3.8,
            0
        ),

    ["Left Hand"] =
        Vector3.new(
            -2.8,
            3.8,
            0
        ),

    ["Right Leg 1"] =
        Vector3.new(
            1.35,
            1.8,
            0
        ),

    ["Right Leg 2"] =
        Vector3.new(
            1.35,
            0.45,
            0
        ),

    ["Right Leg 3"] =
        Vector3.new(
            1.35,
            -0.9,
            0
        ),

    ["Left Leg 1"] =
        Vector3.new(
            -1.35,
            1.8,
            0
        ),

    ["Left Leg 2"] =
        Vector3.new(
            -1.35,
            0.45,
            0
        ),

    ["Left Leg 3"] =
        Vector3.new(
            -1.35,
            -0.9,
            0
        ),
}

--========================================================
-- SETTINGS
--========================================================

local robotHeight = 1
local propDistance = 1

local walkSpeed = 28
local jumpPower = 55

local controlEnabled = false

local robotCenter = nil
local robotRotation = nil

local robotAnchor = nil

local registeredProps = {}

local movementConnection = nil
local animationConnection = nil

--========================================================
-- ANIMATION SETTINGS
--========================================================

local animationTime = 0

local currentMovement =
    Vector3.zero

local isJumping = false

local jumpVelocity = 0

local gravity = 95

-- R6 style default
local animationStyle = "R6"

--========================================================
-- GUI
--========================================================

local gui =
    Instance.new("ScreenGui")

gui.Name =
    "ManiPumpkinRoboV2"

gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent =
    player:WaitForChild("PlayerGui")

--========================================================
-- MAIN
--========================================================

local main =
    Instance.new("Frame")

main.Size =
    UDim2.fromOffset(
        250,
        400
    )

main.Position =
    UDim2.new(
        0.5,
        -125,
        0.5,
        -200
    )

main.BackgroundColor3 =
    Color3.fromRGB(
        17,
        17,
        21
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
-- TITLE BAR
--========================================================

local titleBar =
    Instance.new("Frame")

titleBar.Size =
    UDim2.new(
        1,
        0,
        0,
        42
    )

titleBar.BackgroundColor3 =
    Color3.fromRGB(
        25,
        25,
        30
    )

titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title =
    Instance.new("TextLabel")

title.BackgroundTransparency = 1

title.Position =
    UDim2.fromOffset(
        12,
        5
    )

title.Size =
    UDim2.new(
        1,
        -90,
        0,
        30
    )

title.Text =
    "🎃 MANI PUMPKIN ROBO V.2"

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

title.Parent = titleBar

--========================================================
-- MINIMIZE
--========================================================

local minimize =
    Instance.new("TextButton")

minimize.Size =
    UDim2.fromOffset(
        32,
        28
    )

minimize.Position =
    UDim2.new(
        1,
        -72,
        0,
        7
    )

minimize.Text = "—"

minimize.TextSize = 19

minimize.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

minimize.BackgroundColor3 =
    Color3.fromRGB(
        45,
        45,
        52
    )

minimize.BorderSizePixel = 0

minimize.Parent = titleBar

local minCorner =
    Instance.new("UICorner")

minCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

minCorner.Parent = minimize

--========================================================
-- CLOSE
--========================================================

local close =
    Instance.new("TextButton")

close.Size =
    UDim2.fromOffset(
        32,
        28
    )

close.Position =
    UDim2.new(
        1,
        -36,
        0,
        7
    )

close.Text = "×"

close.TextSize = 20

close.TextColor3 =
    Color3.fromRGB(
        255,
        100,
        100
    )

close.BackgroundColor3 =
    Color3.fromRGB(
        45,
        45,
        52
    )

close.BorderSizePixel = 0

close.Parent = titleBar

local closeCorner =
    Instance.new("UICorner")

closeCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

closeCorner.Parent = close

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPosition

titleBar.InputBegan:Connect(
    function(input)

        if
            input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch
        then

            dragging = true

            dragStart =
                input.Position

            startPosition =
                main.Position

        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not dragging then
            return
        end

        if
            input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or
            input.UserInputType ==
            Enum.UserInputType.Touch
        then

            local delta =
                input.Position -
                dragStart

            main.Position =
                UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )

        end
    end
)

UserInputService.InputEnded:Connect(
    function(input)

        if
            input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch
        then

            dragging = false

        end
    end
)

--========================================================
-- CONTENT
--========================================================

local content =
    Instance.new("Frame")

content.BackgroundTransparency = 1

content.Position =
    UDim2.fromOffset(
        10,
        50
    )

content.Size =
    UDim2.new(
        1,
        -20,
        1,
        -58
    )

content.Parent = main

--========================================================
-- STATUS
--========================================================

local status =
    Instance.new("TextLabel")

status.BackgroundTransparency = 1

status.Size =
    UDim2.new(
        1,
        0,
        0,
        25
    )

status.Text =
    "Props: 0 / 10"

status.TextColor3 =
    Color3.fromRGB(
        180,
        180,
        190
    )

status.TextSize = 12

status.Font =
    Enum.Font.GothamMedium

status.TextXAlignment =
    Enum.TextXAlignment.Left

status.Parent = content

--========================================================
-- SLOT LIST
--========================================================

local slotFrame =
    Instance.new("ScrollingFrame")

slotFrame.Position =
    UDim2.fromOffset(
        0,
        27
    )

slotFrame.Size =
    UDim2.new(
        1,
        0,
        0,
        115
    )

slotFrame.BackgroundColor3 =
    Color3.fromRGB(
        11,
        11,
        14
    )

slotFrame.BorderSizePixel = 0

slotFrame.ScrollBarThickness = 3

slotFrame.Parent = content

local slotCorner =
    Instance.new("UICorner")

slotCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

slotCorner.Parent = slotFrame

local slotLayout =
    Instance.new("UIListLayout")

slotLayout.Padding =
    UDim.new(
        0,
        1
    )

slotLayout.Parent = slotFrame

local slotLabels = {}

for i = 1, 10 do

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -8,
            0,
            20
        )

    label.BackgroundTransparency = 1

    label.Text =
        tostring(i)
        .. ". "
        .. SLOTS[i]
        .. " [EMPTY]"

    label.TextColor3 =
        Color3.fromRGB(
            150,
            150,
            160
        )

    label.TextSize = 10

    label.Font =
        Enum.Font.GothamMedium

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent = slotFrame

    slotLabels[i] = label

end

slotFrame.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        210
    )

--========================================================
-- BUTTON
--========================================================

local function createButton(
    text,
    pos,
    size
)

    local button =
        Instance.new("TextButton")

    button.Size = size

    button.Position = pos

    button.BackgroundColor3 =
        Color3.fromRGB(
            36,
            36,
            43
        )

    button.BorderSizePixel = 0

    button.Text = text

    button.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    button.TextSize = 11

    button.Font =
        Enum.Font.GothamBold

    button.Parent = content

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    corner.Parent = button

    return button
end

--========================================================
-- LOAD
--========================================================

local loadButton =
    createButton(
        "LOAD 10 PROPS",
        UDim2.fromOffset(
            0,
            148
        ),
        UDim2.new(
            1,
            0,
            0,
            30
        )
    )

--========================================================
-- ASSEMBLE
--========================================================

local assembleButton =
    createButton(
        "🤖 ASSEMBLE ROBOT",
        UDim2.fromOffset(
            0,
            182
        ),
        UDim2.new(
            1,
            0,
            0,
            30
        )
    )

--========================================================
-- HEIGHT
--========================================================

local heightLabel =
    Instance.new("TextLabel")

heightLabel.BackgroundTransparency = 1

heightLabel.Position =
    UDim2.fromOffset(
        0,
        220
    )

heightLabel.Size =
    UDim2.fromOffset(
        110,
        25
    )

heightLabel.Text =
    "Height: 1.00"

heightLabel.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        225
    )

heightLabel.TextSize = 11

heightLabel.Font =
    Enum.Font.GothamBold

heightLabel.TextXAlignment =
    Enum.TextXAlignment.Left

heightLabel.Parent = content

local heightMinus =
    createButton(
        "−",
        UDim2.fromOffset(
            135,
            220
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

local heightPlus =
    createButton(
        "+",
        UDim2.fromOffset(
            171,
            220
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

--========================================================
-- DISTANCE
--========================================================

local distanceLabel =
    Instance.new("TextLabel")

distanceLabel.BackgroundTransparency = 1

distanceLabel.Position =
    UDim2.fromOffset(
        0,
        249
    )

distanceLabel.Size =
    UDim2.fromOffset(
        120,
        25
    )

distanceLabel.Text =
    "Distance: 1.00"

distanceLabel.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        225
    )

distanceLabel.TextSize = 11

distanceLabel.Font =
    Enum.Font.GothamBold

distanceLabel.TextXAlignment =
    Enum.TextXAlignment.Left

distanceLabel.Parent = content

local distanceMinus =
    createButton(
        "−",
        UDim2.fromOffset(
            135,
            249
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

local distancePlus =
    createButton(
        "+",
        UDim2.fromOffset(
            171,
            249
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

--========================================================
-- SPEED
--========================================================

local speedLabel =
    Instance.new("TextLabel")

speedLabel.BackgroundTransparency = 1

speedLabel.Position =
    UDim2.fromOffset(
        0,
        278
    )

speedLabel.Size =
    UDim2.fromOffset(
        120,
        25
    )

speedLabel.Text =
    "Walk Speed: 28"

speedLabel.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        225
    )

speedLabel.TextSize = 11

speedLabel.Font =
    Enum.Font.GothamBold

speedLabel.TextXAlignment =
    Enum.TextXAlignment.Left

speedLabel.Parent = content

local speedMinus =
    createButton(
        "−",
        UDim2.fromOffset(
            135,
            278
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

local speedPlus =
    createButton(
        "+",
        UDim2.fromOffset(
            171,
            278
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

--========================================================
-- JUMP POWER
--========================================================

local jumpLabel =
    Instance.new("TextLabel")

jumpLabel.BackgroundTransparency = 1

jumpLabel.Position =
    UDim2.fromOffset(
        0,
        307
    )

jumpLabel.Size =
    UDim2.fromOffset(
        120,
        25
    )

jumpLabel.Text =
    "Jump Power: 55"

jumpLabel.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        225
    )

jumpLabel.TextSize = 11

jumpLabel.Font =
    Enum.Font.GothamBold

jumpLabel.TextXAlignment =
    Enum.TextXAlignment.Left

jumpLabel.Parent = content

local jumpMinus =
    createButton(
        "−",
        UDim2.fromOffset(
            135,
            307
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

local jumpPlus =
    createButton(
        "+",
        UDim2.fromOffset(
            171,
            307
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

--========================================================
-- CONTROL
--========================================================

local controlButton =
    createButton(
        "CONTROL: OFF",
        UDim2.fromOffset(
            0,
            340
        ),
        UDim2.new(
            1,
            0,
            0,
            32
        )
    )

--========================================================
-- SLOT UI
--========================================================

local function updateSlotUI()

    local count = 0

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            count += 1

            slotLabels[i].Text =
                tostring(i)
                .. ". "
                .. SLOTS[i]
                .. " [LOCKED]"

            slotLabels[i].TextColor3 =
                Color3.fromRGB(
                    80,
                    255,
                    140
                )

        else

            slotLabels[i].Text =
                tostring(i)
                .. ". "
                .. SLOTS[i]
                .. " [EMPTY]"

            slotLabels[i].TextColor3 =
                Color3.fromRGB(
                    150,
                    150,
                    160
                )

        end

    end

    status.Text =
        "Props: "
        .. count
        .. " / 10"

end

--========================================================
-- GET PROPS
--========================================================

local function getAvailableProps()

    local props = {}

    for _, v in pairs(
        propsFolder:GetChildren()
    ) do

        if string.find(
            v.Name,
            player.Name
        ) then

            table.insert(
                props,
                v
            )

        end

    end

    return props
end

--========================================================
-- LOAD PROPS
--========================================================

local function loadProps()

    registeredProps = {}

    local props =
        getAvailableProps()

    local amount =
        math.min(
            #props,
            10
        )

    for i = 1, amount do

        registeredProps[i] =
            props[i]

    end

    updateSlotUI()

    status.Text =
        "Loaded: "
        .. amount
        .. " / 10"

end

--========================================================
-- ROBOT CFRAME
--========================================================

local function getRobotCFrame(
    offset,
    animationOffset
)

    animationOffset =
        animationOffset or Vector3.zero

    local right =
        robotRotation.RightVector

    local forward =
        robotRotation.LookVector

    local pos =
        robotCenter

        + right
            * offset.X
            * propDistance

        + Vector3.new(
            0,
            offset.Y
                * robotHeight,
            0
        )

        + forward
            * offset.Z
            * propDistance

        + animationOffset

    return CFrame.new(
        pos,
        pos + forward
    )
end

--========================================================
-- SET PROP
--========================================================

local function setPropCFrame(
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

    if not remote then

        warn(
            "❌ SetCurrentCFrame missing:",
            prop.Name
        )

        return
    end

    remote:InvokeServer(cf)

end

--========================================================
-- ASSEMBLE
--========================================================

local function assembleRobot()

    if not registeredProps[1] then

        loadProps()

    end

    if not registeredProps[1] then

        status.Text =
            "❌ No props"

        return
    end

    robotCenter =
        hrp.Position
        + hrp.CFrame.LookVector * 8

    robotRotation =
        CFrame.lookAt(
            robotCenter,
            robotCenter
                + hrp.CFrame.LookVector
        )

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local offset =
                BASE_OFFSETS[
                    SLOTS[i]
                ]

            if offset then

                setPropCFrame(
                    prop,
                    getRobotCFrame(
                        offset
                    )
                )

                task.wait(
                    0.15
                )

            end

        end

    end

    status.Text =
        "🤖 ROBOT READY"

end

--========================================================
-- REBUILD
--========================================================

local function rebuildRobot()

    if not robotCenter then
        return
    end

    if not robotRotation then
        return
    end

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local offset =
                BASE_OFFSETS[
                    SLOTS[i]
                ]

            if offset then

                setPropCFrame(
                    prop,
                    getRobotCFrame(
                        offset
                    )
                )

            end

        end

    end

end

--========================================================
-- HEIGHT
--========================================================

heightMinus.MouseButton1Click:Connect(
    function()

        robotHeight =
            math.max(
                0.5,
                robotHeight - 0.25
            )

        heightLabel.Text =
            string.format(
                "Height: %.2f",
                robotHeight
            )

        rebuildRobot()

    end
)

heightPlus.MouseButton1Click:Connect(
    function()

        robotHeight =
            math.min(
                3,
                robotHeight + 0.25
            )

        heightLabel.Text =
            string.format(
                "Height: %.2f",
                robotHeight
            )

        rebuildRobot()

    end
)

--========================================================
-- DISTANCE
--========================================================

distanceMinus.MouseButton1Click:Connect(
    function()

        propDistance =
            math.max(
                0.5,
                propDistance - 0.25
            )

        distanceLabel.Text =
            string.format(
                "Distance: %.2f",
                propDistance
            )

        rebuildRobot()

    end
)

distancePlus.MouseButton1Click:Connect(
    function()

        propDistance =
            math.min(
                3,
                propDistance + 0.25
            )

        distanceLabel.Text =
            string.format(
                "Distance: %.2f",
                propDistance
            )

        rebuildRobot()

    end
)

--========================================================
-- WALK SPEED
--========================================================

speedMinus.MouseButton1Click:Connect(
    function()

        walkSpeed =
            math.max(
                5,
                walkSpeed - 5
            )

        speedLabel.Text =
            "Walk Speed: "
            .. walkSpeed

    end
)

speedPlus.MouseButton1Click:Connect(
    function()

        walkSpeed =
            math.min(
                100,
                walkSpeed + 5
            )

        speedLabel.Text =
            "Walk Speed: "
            .. walkSpeed

    end
)

--========================================================
-- JUMP POWER
--========================================================

jumpMinus.MouseButton1Click:Connect(
    function()

        jumpPower =
            math.max(
                20,
                jumpPower - 5
            )

        jumpLabel.Text =
            "Jump Power: "
            .. jumpPower

    end
)

jumpPlus.MouseButton1Click:Connect(
    function()

        jumpPower =
            math.min(
                150,
                jumpPower + 5
            )

        jumpLabel.Text =
            "Jump Power: "
            .. jumpPower

    end
)

--========================================================
-- ROBOT ANCHOR
--========================================================

local function createRobotAnchor()

    if robotAnchor then
        robotAnchor:Destroy()
    end

    robotAnchor =
        Instance.new("Part")

    robotAnchor.Name =
        "MANI_ROBOT_ANCHOR"

    robotAnchor.Size =
        Vector3.new(
            1,
            1,
            1
        )

    robotAnchor.Transparency = 1

    robotAnchor.CanCollide = false
    robotAnchor.CanTouch = false
    robotAnchor.CanQuery = false

    robotAnchor.Anchored = true

    robotAnchor.CFrame =
        robotRotation

    robotAnchor.Parent =
        workspace

end

--========================================================
-- ANIMATION
--========================================================

local function animateRobot(dt)

    if not controlEnabled then
        return
    end

    if not robotCenter then
        return
    end

    if not robotRotation then
        return
    end

    animationTime += dt

    local moving =
        currentMovement.Magnitude > 0.05

    local walkCycle = 0

    if moving and not isJumping then

        walkCycle =
            math.sin(
                animationTime * 10
            )

    end

    --====================================================
    -- IDLE
    --====================================================

    local idleBob =
        0

    if not moving
        and not isJumping then

        idleBob =
            math.sin(
                animationTime * 2.2
            )
            * 0.08

    end

    --====================================================
    -- BODY OFFSETS
    --====================================================

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local slot =
                SLOTS[i]

            local offset =
                BASE_OFFSETS[slot]

            if offset then

                local anim =
                    Vector3.zero

                --========================================
                -- HEAD
                --========================================

                if slot == "Head" then

                    anim =
                        Vector3.new(
                            0,
                            idleBob,
                            0
                        )

                --========================================
                -- WAIST
                --========================================

                elseif slot == "Waist" then

                    anim =
                        Vector3.new(
                            0,
                            idleBob * 0.5,
                            0
                        )

                --========================================
                -- HANDS
                --========================================

                elseif slot == "Right Hand" then

                    if moving then

                        anim =
                            Vector3.new(
                                0,
                                math.abs(
                                    walkCycle
                                ) * 0.15,
                                walkCycle * 0.55
                            )

                    else

                        anim =
                            Vector3.new(
                                0,
                                idleBob,
                                0
                            )

                    end

                elseif slot == "Left Hand" then

                    if moving then

                        anim =
                            Vector3.new(
                                0,
                                math.abs(
                                    walkCycle
                                ) * 0.15,
                                -walkCycle * 0.55
                            )

                    else

                        anim =
                            Vector3.new(
                                0,
                                idleBob,
                                0
                            )

                    end

                --========================================
                -- RIGHT LEG
                --========================================

                elseif
                    slot == "Right Leg 1"
                    or
                    slot == "Right Leg 2"
                    or
                    slot == "Right Leg 3"
                then

                    if moving then

                        anim =
                            Vector3.new(
                                0,
                                0,
                                walkCycle * 0.35
                            )

                    end

                --========================================
                -- LEFT LEG
                --========================================

                elseif
                    slot == "Left Leg 1"
                    or
                    slot == "Left Leg 2"
                    or
                    slot == "Left Leg 3"
                then

                    if moving then

                        anim =
                            Vector3.new(
                                0,
                                0,
                                -walkCycle * 0.35
                            )

                    end

                end

                setPropCFrame(
                    prop,
                    getRobotCFrame(
                        offset,
                        anim
                    )
                )

            end

        end

    end

end

--========================================================
-- JUMP
--========================================================

local function performJump()

    if not controlEnabled then
        return
    end

    if isJumping then
        return
    end

    if not robotAnchor then
        return
    end

    isJumping = true

    jumpVelocity =
        jumpPower

end

UserInputService.JumpRequest:Connect(
    function()

        performJump()

    end
)

--========================================================
-- CAMERA
--========================================================

local camera =
    workspace.CurrentCamera

local oldCameraType
local oldCameraSubject

local cameraDistance = 16
local cameraHeight = 7

local function updateCamera()

    if not controlEnabled then
        return
    end

    if not robotAnchor then
        return
    end

    camera.CameraType =
        Enum.CameraType.Scriptable

    local robotCF =
        robotAnchor.CFrame

    local target =
        robotCF.Position
        + Vector3.new(
            0,
            cameraHeight,
            0
        )

    local cameraPosition =
        robotCF.Position
        - robotCF.LookVector
            * cameraDistance
        + Vector3.new(
            0,
            cameraHeight,
            0
        )

    local wanted =
        CFrame.lookAt(
            cameraPosition,
            target
        )

    camera.CFrame =
        camera.CFrame:Lerp(
            wanted,
            0.15
        )

end

--========================================================
-- CONTROL START
--========================================================

local function startControl()

    if not robotCenter then

        assembleRobot()

    end

    if not robotCenter then
        return
    end

    createRobotAnchor()

    controlEnabled = true

    controlButton.Text =
        "CONTROL: ON"

    -- Save camera
    oldCameraType =
        camera.CameraType

    oldCameraSubject =
        camera.CameraSubject

    -- Disable real character movement
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    -- Hide character
    for _, obj in pairs(
        character:GetDescendants()
    ) do

        if
            obj:IsA("BasePart")
            and obj ~= hrp
        then

            obj.LocalTransparencyModifier =
                1

        end

    end

    --====================================================
    -- MOVEMENT
    --====================================================

    if movementConnection then
        movementConnection:Disconnect()
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

                local direction =
                    humanoid.MoveDirection

                currentMovement =
                    direction

                --========================================
                -- WALK
                --========================================

                if direction.Magnitude > 0.05 then

                    local flatDirection =
                        Vector3.new(
                            direction.X,
                            0,
                            direction.Z
                        )

                    if flatDirection.Magnitude > 0.01 then

                        flatDirection =
                            flatDirection.Unit

                        local newPosition =
                            robotAnchor.Position
                            + flatDirection
                                * walkSpeed
                                * dt

                        local targetCF =
                            CFrame.lookAt(
                                newPosition,
                                newPosition
                                    + flatDirection
                            )

                        robotAnchor.CFrame =
                            robotAnchor.CFrame:Lerp(
                                targetCF,
                                math.clamp(
                                    10 * dt,
                                    0,
                                    1
                                )
                            )

                    end

                end

                --========================================
                -- JUMP PHYSICS
                --========================================

                if isJumping then

                    jumpVelocity -=
                        gravity * dt

                    robotAnchor.CFrame =
                        robotAnchor.CFrame
                        + Vector3.new(
                            0,
                            jumpVelocity * dt,
                            0
                        )

                    -- Ground
                    local groundY =
                        robotCenter.Y

                    if
                        robotAnchor.Position.Y
                        <= groundY
                    then

                        robotAnchor.CFrame =
                            CFrame.new(
                                Vector3.new(
                                    robotAnchor.Position.X,
                                    groundY,
                                    robotAnchor.Position.Z
                                ),
                                robotAnchor.Position
                                    + robotAnchor.CFrame.LookVector
                            )

                        jumpVelocity = 0
                        isJumping = false

                    end

                end

                robotCenter =
                    robotAnchor.Position

                robotRotation =
                    robotAnchor.CFrame

            end
        )

    --====================================================
    -- ANIMATION
    --====================================================

    if animationConnection then
        animationConnection:Disconnect()
    end

    animationConnection =
        RunService.RenderStepped:Connect(
            function(dt)

                animateRobot(dt)

                updateCamera()

            end
        )

end

--========================================================
-- CONTROL STOP
--========================================================

local function stopControl()

    controlEnabled = false

    currentMovement =
        Vector3.zero

    isJumping = false

    controlButton.Text =
        "CONTROL: OFF"

    if movementConnection then

        movementConnection:Disconnect()

        movementConnection = nil

    end

    if animationConnection then

        animationConnection:Disconnect()

        animationConnection = nil

    end

    if robotAnchor then

        robotAnchor:Destroy()

        robotAnchor = nil

    end

    -- Restore character
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    for _, obj in pairs(
        character:GetDescendants()
    ) do

        if
            obj:IsA("BasePart")
        then

            obj.LocalTransparencyModifier =
                0

        end

    end

    -- Restore camera
    camera.CameraType =
        oldCameraType
        or Enum.CameraType.Custom

    camera.CameraSubject =
        oldCameraSubject
        or humanoid

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

        content.Visible =
            not minimized

        if minimized then

            main.Size =
                UDim2.fromOffset(
                    250,
                    42
                )

            minimize.Text = "+"

        else

            main.Size =
                UDim2.fromOffset(
                    250,
                    400
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

        stopControl()

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

    end
)

--========================================================
-- INITIAL
--========================================================

updateSlotUI()

print(
    "🎃 MANI PUMPKIN ROBO V.2 LOADED"
)
