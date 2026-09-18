--========================================================
-- 🤖 MANI PUMPKIN ROBO V.1
-- 10 PROP ROBOT
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

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

--========================================================
-- CONFIG
--========================================================

local propsFolder =
    workspace:FindFirstChild("WorkspaceCom")
    and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")

if not propsFolder then
    warn("❌ WorkspaceCom > 001_TrafficCones nahi mila")
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
-- ROBOT SETTINGS
--========================================================

local robotHeight = 1
local propDistance = 1

local MOVE_SPEED = 28
local TURN_SPEED = 7

local robotCenter = nil
local robotRotation = nil

local controlEnabled = false

local robotAnchor = nil

local registeredProps = {}

--========================================================
-- BASE OFFSETS
--========================================================

local BASE_OFFSETS = {

    Head =
        Vector3.new(
            0,
            5.5,
            0
        ),

    Waist =
        Vector3.new(
            0,
            3,
            0
        ),

    ["Right Hand"] =
        Vector3.new(
            2.5,
            3.5,
            0
        ),

    ["Left Hand"] =
        Vector3.new(
            -2.5,
            3.5,
            0
        ),

    ["Right Leg 1"] =
        Vector3.new(
            1.2,
            1.5,
            0
        ),

    ["Right Leg 2"] =
        Vector3.new(
            1.2,
            0.3,
            0
        ),

    ["Right Leg 3"] =
        Vector3.new(
            1.2,
            -0.9,
            0
        ),

    ["Left Leg 1"] =
        Vector3.new(
            -1.2,
            1.5,
            0
        ),

    ["Left Leg 2"] =
        Vector3.new(
            -1.2,
            0.3,
            0
        ),

    ["Left Leg 3"] =
        Vector3.new(
            -1.2,
            -0.9,
            0
        ),
}

--========================================================
-- GUI
--========================================================

local gui =
    Instance.new("ScreenGui")

gui.Name =
    "ManiPumpkinRoboV1"

gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

--========================================================
-- MAIN WINDOW
--========================================================

local main =
    Instance.new("Frame")

main.Name = "Main"

main.Size =
    UDim2.fromOffset(
        245,
        330
    )

main.Position =
    UDim2.new(
        0.5,
        -122,
        0.5,
        -165
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
        24,
        24,
        29
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
    "🎃  MANI PUMPKIN ROBO"

title.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

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

minimize.TextSize = 20

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
-- DRAG SYSTEM
--========================================================

local dragging = false
local dragStart = nil
local startPosition = nil

titleBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
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
end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
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
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
        Enum.UserInputType.Touch
    then

        dragging = false

    end
end)

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

status.TextSize = 13
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left

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
        12,
        12,
        15
    )

slotFrame.BorderSizePixel = 0

slotFrame.ScrollBarThickness = 3

slotFrame.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        0
    )

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
        2
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
        .. "  [ EMPTY ]"

    label.TextColor3 =
        Color3.fromRGB(
            150,
            150,
            160
        )

    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = slotFrame

    slotLabels[i] = label

end

slotFrame.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        10 * 22
    )

--========================================================
-- BUTTON FUNCTION
--========================================================

local function createButton(
    text,
    position,
    size
)

    local button =
        Instance.new("TextButton")

    button.Size = size

    button.Position = position

    button.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            42
        )

    button.BorderSizePixel = 0

    button.Text = text

    button.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    button.TextSize = 12

    button.Font =
        Enum.Font.GothamBold

    button.AutoButtonColor = true

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
-- LOAD BUTTON
--========================================================

local loadButton =
    createButton(
        "LOAD 10 PROPS",
        UDim2.fromOffset(
            0,
            150
        ),
        UDim2.new(
            1,
            0,
            0,
            32
        )
    )

--========================================================
-- ASSEMBLE BUTTON
--========================================================

local assembleButton =
    createButton(
        "🤖  ASSEMBLE ROBOT",
        UDim2.fromOffset(
            0,
            187
        ),
        UDim2.new(
            1,
            0,
            0,
            32
        )
    )

--========================================================
-- HEIGHT CONTROLS
--========================================================

local heightLabel =
    Instance.new("TextLabel")

heightLabel.BackgroundTransparency = 1

heightLabel.Position =
    UDim2.fromOffset(
        0,
        225
    )

heightLabel.Size =
    UDim2.fromOffset(
        100,
        25
    )

heightLabel.Text =
    "Height: 1.0"

heightLabel.TextColor3 =
    Color3.fromRGB(
        210,
        210,
        220
    )

heightLabel.TextSize = 12
heightLabel.Font = Enum.Font.GothamBold
heightLabel.TextXAlignment = Enum.TextXAlignment.Left

heightLabel.Parent = content

local heightMinus =
    createButton(
        "−",
        UDim2.fromOffset(
            130,
            225
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
            166,
            225
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

--========================================================
-- DISTANCE CONTROLS
--========================================================

local distanceLabel =
    Instance.new("TextLabel")

distanceLabel.BackgroundTransparency = 1

distanceLabel.Position =
    UDim2.fromOffset(
        0,
        255
    )

distanceLabel.Size =
    UDim2.fromOffset(
        125,
        25
    )

distanceLabel.Text =
    "Distance: 1.0"

distanceLabel.TextColor3 =
    Color3.fromRGB(
        210,
        210,
        220
    )

distanceLabel.TextSize = 12
distanceLabel.Font = Enum.Font.GothamBold
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left

distanceLabel.Parent = content

local distanceMinus =
    createButton(
        "−",
        UDim2.fromOffset(
            130,
            255
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
            166,
            255
        ),
        UDim2.fromOffset(
            32,
            25
        )
    )

--========================================================
-- CONTROL BUTTON
--========================================================

local controlButton =
    createButton(
        "CONTROL: OFF",
        UDim2.fromOffset(
            0,
            285
        ),
        UDim2.new(
            1,
            0,
            0,
            32
        )
    )

--========================================================
-- UPDATE SLOT UI
--========================================================

local function updateSlotUI()

    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            slotLabels[i].Text =
                tostring(i)
                .. ". "
                .. SLOTS[i]
                .. "  [LOCKED]"

            slotLabels[i].TextColor3 =
                Color3.fromRGB(
                    90,
                    255,
                    140
                )

        else

            slotLabels[i].Text =
                tostring(i)
                .. ". "
                .. SLOTS[i]
                .. "  [EMPTY]"

            slotLabels[i].TextColor3 =
                Color3.fromRGB(
                    150,
                    150,
                    160
                )

        end

    end

    local count = 0

    for i = 1, 10 do
        if registeredProps[i] then
            count += 1
        end
    end

    status.Text =
        "Props: "
        .. count
        .. " / 10"

end

--========================================================
-- GET PLAYER PROPS
--========================================================

local function getAvailableProps()

    local result = {}

    for _, v in pairs(
        propsFolder:GetChildren()
    ) do

        if string.find(
            v.Name,
            player.Name
        ) then

            table.insert(
                result,
                v
            )

        end

    end

    return result
end

--========================================================
-- LOAD PROPS
--========================================================

local function loadProps()

    registeredProps = {}

    local props =
        getAvailableProps()

    -- IMPORTANT:
    -- Current order is the order returned
    -- by the props folder.

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

    print(
        "🤖 Loaded ",
        amount,
        "/10 props"
    )

end

--========================================================
-- GET ROBOT CFRAME
--========================================================

local function getRobotCFrame(
    offset
)

    local base =
        robotCenter

    local right =
        robotRotation.RightVector

    local forward =
        robotRotation.LookVector

    local pos =
        base
        + right * offset.X * propDistance
        + Vector3.new(
            0,
            offset.Y * robotHeight,
            0
        )
        + forward * offset.Z * propDistance

    return CFrame.new(
        pos,
        pos + forward
    )
end

--========================================================
-- MOVE PROP USING YOUR WORKING METHOD
--========================================================

local function setPropCFrame(
    prop,
    cf
)

    if not prop then
        return false
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

        return false
    end

    remote:InvokeServer(cf)

    return true
end

--========================================================
-- ASSEMBLE ROBOT
--========================================================

local function assembleRobot()

    if not registeredProps[1] then

        loadProps()

    end

    local count = 0

    for i = 1, 10 do
        if registeredProps[i] then
            count += 1
        end
    end

    if count == 0 then

        status.Text =
            "❌ No props loaded"

        return
    end

    -- Robot center
    robotCenter =
        hrp.Position
        + hrp.CFrame.LookVector * 8

    robotRotation =
        CFrame.lookAt(
            robotCenter,
            robotCenter + hrp.CFrame.LookVector
        )

    -- Place each prop
    for i = 1, 10 do

        local prop =
            registeredProps[i]

        if prop then

            local slot =
                SLOTS[i]

            local offset =
                BASE_OFFSETS[slot]

            if offset then

                local cf =
                    getRobotCFrame(
                        offset
                    )

                setPropCFrame(
                    prop,
                    cf
                )

                task.wait(
                    0.2
                )

            end
        end

    end

    print(
        "🤖 MANI ROBOT ASSEMBLED"
    )

end

--========================================================
-- REBUILD
--========================================================

local function rebuildRobot()

    if not robotCenter then

        robotCenter =
            hrp.Position
            + hrp.CFrame.LookVector * 8

        robotRotation =
            CFrame.lookAt(
                robotCenter,
                robotCenter
                    + hrp.CFrame.LookVector
            )

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
-- PROP DISTANCE
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
-- BUTTONS
--========================================================

loadButton.MouseButton1Click:Connect(
    function()

        loadProps()

    end
)

assembleButton.MouseButton1Click:Connect(
    function()

        assembleRobot()

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
        "ManiRobotController"

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
        or CFrame.new(
            robotCenter
        )

    robotAnchor.Parent =
        workspace

end

--========================================================
-- CONTROL
--========================================================

local controlConnection = nil

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

    -- Player ko movement input dene do
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    -- Robot control loop
    if controlConnection then
        controlConnection:Disconnect()
    end

    controlConnection =
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

                if direction.Magnitude > 0.05 then

                    local move =
                        direction.Unit
                        * MOVE_SPEED
                        * dt

                    local newPosition =
                        robotAnchor.Position
                        + move

                    local currentLook =
                        robotAnchor.CFrame.LookVector

                    local targetLook =
                        Vector3.new(
                            direction.X,
                            0,
                            direction.Z
                        )

                    if targetLook.Magnitude > 0.01 then

                        targetLook =
                            targetLook.Unit

                        local currentCF =
                            robotAnchor.CFrame

                        local targetCF =
                            CFrame.lookAt(
                                newPosition,
                                newPosition
                                    + targetLook
                            )

                        robotAnchor.CFrame =
                            currentCF:Lerp(
                                targetCF,
                                math.clamp(
                                    TURN_SPEED * dt,
                                    0,
                                    1
                                )
                            )

                    else

                        robotAnchor.Position =
                            newPosition

                    end

                end

                robotCenter =
                    robotAnchor.Position

                robotRotation =
                    robotAnchor.CFrame

                -- Robot ke props ko anchor follow karvao
                for i = 1, 10 do

                    local prop =
                        registeredProps[i]

                    if prop then

                        local offset =
                            BASE_OFFSETS[
                                SLOTS[i]
                            ]

                        if offset then

                            local cf =
                                getRobotCFrame(
                                    offset
                                )

                            setPropCFrame(
                                prop,
                                cf
                            )

                        end

                    end

                end

            end
        )

end

--========================================================
-- STOP CONTROL
--========================================================

local function stopControl()

    controlEnabled = false

    controlButton.Text =
        "CONTROL: OFF"

    if controlConnection then

        controlConnection:Disconnect()
        controlConnection = nil

    end

    if robotAnchor then

        robotAnchor:Destroy()
        robotAnchor = nil

    end

    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

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
                    245,
                    42
                )

            minimize.Text = "+"

        else

            main.Size =
                UDim2.fromOffset(
                    245,
                    330
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
-- RESPAWN CLEANUP
--========================================================

player.CharacterAdded:Connect(
    function(newCharacter)

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

        if controlEnabled then
            stopControl()
        end

    end
)

--========================================================
-- INITIAL
--========================================================

updateSlotUI()

print(
    "🎃 MANI PUMPKIN ROBO V.1 LOADED"
)
