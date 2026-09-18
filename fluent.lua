--==============================================================
-- 🎃 MANI PUMPKIN ROBO V.1
--==============================================================
-- SMALL MODERN GUI
-- PC + MOBILE
-- DRAGGABLE
-- MINIMIZE
-- 15 PROPS
-- ASSEMBLE
-- ROBOT CAMERA
-- DEFAULT ROBLOX JOYSTICK
-- DEFAULT ROBLOX JUMP BUTTON
--==============================================================

repeat task.wait() until game:IsLoaded()

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--==============================================================
-- PLAYER
--==============================================================

local player = Players.LocalPlayer

local character = player.Character
    or player.CharacterAdded:Wait()

local humanoid =
    character:WaitForChild("Humanoid")

local hrp =
    character:WaitForChild("HumanoidRootPart")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {

    Folder1 = "WorkspaceCom",
    Folder2 = "001_TrafficCones",

    MaxProps = 15,

    MoveSpeed = 35,

    TurnSpeed = 10,

    CameraDistance = 17,

    CameraHeight = 6,

    CameraLookHeight = 3,

    JumpHeight = 5,

    ResetRadius = 12,

    HeightMin = 0.50,

    HeightMax = 3.00,

    HeightStep = 0.25,

    HeightDefault = 1.00,

}

--==============================================================
-- ROBOT ORDER
--==============================================================

local ROBOT_ORDER = {

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

    [11] = "Extra 1",

    [12] = "Extra 2",

    [13] = "Extra 3",

    [14] = "Extra 4",

    [15] = "Extra 5",

}

--==============================================================
-- ROBOT OFFSETS
--==============================================================

local OFFSETS = {

    [1] =
        Vector3.new(0, 5.5, 0),

    [2] =
        Vector3.new(0, 3.0, 0),

    [3] =
        Vector3.new(2.5, 3.5, 0),

    [4] =
        Vector3.new(-2.5, 3.5, 0),

    [5] =
        Vector3.new(1.2, 1.5, 0),

    [6] =
        Vector3.new(1.2, 0.3, 0),

    [7] =
        Vector3.new(1.2, -0.9, 0),

    [8] =
        Vector3.new(-1.2, 1.5, 0),

    [9] =
        Vector3.new(-1.2, 0.3, 0),

    [10] =
        Vector3.new(-1.2, -0.9, 0),

    -- 11-15
    [11] =
        Vector3.new(0, 4.1, 0.8),

    [12] =
        Vector3.new(0, 3.5, 0.9),

    [13] =
        Vector3.new(0, 2.7, 0.9),

    [14] =
        Vector3.new(0, 1.8, 0.8),

    [15] =
        Vector3.new(0, 0.7, 0.6),

}

--==============================================================
-- GUI
--==============================================================

local gui =
    Instance.new("ScreenGui")

gui.Name =
    "MANI_PUMPKIN_ROBO_V1"

gui.ResetOnSpawn = false

gui.IgnoreGuiInset = true

gui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

gui.Parent =
    player:WaitForChild("PlayerGui")

--==============================================================
-- MAIN
--==============================================================

local main =
    Instance.new("Frame")

main.Name = "Main"

main.Size =
    UDim2.new(0, 285, 0, 430)

main.Position =
    UDim2.new(0, 15, 0.5, -215)

main.BackgroundColor3 =
    Color3.fromRGB(15, 15, 19)

main.BorderSizePixel = 0

main.Active = true

main.Parent = gui

local mainCorner =
    Instance.new("UICorner", main)

mainCorner.CornerRadius =
    UDim.new(0, 14)

local mainStroke =
    Instance.new("UIStroke", main)

mainStroke.Color =
    Color3.fromRGB(255, 140, 35)

mainStroke.Thickness = 1.3

mainStroke.Transparency = 0.35

--==============================================================
-- TITLE BAR
--==============================================================

local titleBar =
    Instance.new("Frame", main)

titleBar.Size =
    UDim2.new(1, 0, 0, 46)

titleBar.BackgroundColor3 =
    Color3.fromRGB(24, 24, 29)

titleBar.BorderSizePixel = 0

titleBar.Active = true

local titleCorner =
    Instance.new("UICorner", titleBar)

titleCorner.CornerRadius =
    UDim.new(0, 14)

-- bottom cover

local titleCover =
    Instance.new("Frame", titleBar)

titleCover.Size =
    UDim2.new(1, 0, 0, 15)

titleCover.Position =
    UDim2.new(0, 0, 1, -15)

titleCover.BackgroundColor3 =
    Color3.fromRGB(24, 24, 29)

titleCover.BorderSizePixel = 0

--==============================================================
-- DRAG
--==============================================================

local dragging = false

local dragStart

local startPosition

titleBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position

        startPosition =
            main.Position

        local connection

        connection =
            input.Changed:Connect(function()

                if input.UserInputState ==
                    Enum.UserInputState.End then

                    dragging = false

                    if connection then
                        connection:Disconnect()
                    end

                end

            end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - dragStart

        main.Position =
            UDim2.new(

                startPosition.X.Scale,

                startPosition.X.Offset
                    + delta.X,

                startPosition.Y.Scale,

                startPosition.Y.Offset
                    + delta.Y

            )

    end

end)

--==============================================================
-- TITLE
--==============================================================

local title =
    Instance.new("TextLabel", titleBar)

title.Size =
    UDim2.new(1, -88, 1, 0)

title.Position =
    UDim2.new(0, 13, 0, 0)

title.BackgroundTransparency = 1

title.Text =
    "🎃  MANI PUMPKIN ROBO"

title.Font =
    Enum.Font.GothamBold

title.TextSize = 13

title.TextColor3 =
    Color3.fromRGB(255, 165, 55)

title.TextXAlignment =
    Enum.TextXAlignment.Left

--==============================================================
-- MIN BUTTON
--==============================================================

local minButton =
    Instance.new("TextButton", titleBar)

minButton.Size =
    UDim2.new(0, 29, 0, 29)

minButton.Position =
    UDim2.new(1, -67, 0, 8)

minButton.BackgroundColor3 =
    Color3.fromRGB(43, 43, 51)

minButton.Text = "—"

minButton.Font =
    Enum.Font.GothamBold

minButton.TextSize = 16

minButton.TextColor3 =
    Color3.fromRGB(255, 195, 110)

minButton.BorderSizePixel = 0

Instance.new(
    "UICorner",
    minButton
).CornerRadius =
    UDim.new(0, 8)

--==============================================================
-- CLOSE
--==============================================================

local closeButton =
    Instance.new("TextButton", titleBar)

closeButton.Size =
    UDim2.new(0, 29, 0, 29)

closeButton.Position =
    UDim2.new(1, -34, 0, 8)

closeButton.BackgroundColor3 =
    Color3.fromRGB(58, 27, 31)

closeButton.Text = "×"

closeButton.Font =
    Enum.Font.GothamBold

closeButton.TextSize = 17

closeButton.TextColor3 =
    Color3.fromRGB(255, 105, 105)

closeButton.BorderSizePixel = 0

Instance.new(
    "UICorner",
    closeButton
).CornerRadius =
    UDim.new(0, 8)

--==============================================================
-- BODY
--==============================================================

local body =
    Instance.new("Frame", main)

body.Size =
    UDim2.new(1, -18, 1, -55)

body.Position =
    UDim2.new(0, 9, 0, 51)

body.BackgroundTransparency = 1

--==============================================================
-- STATUS
--==============================================================

local status =
    Instance.new("TextLabel", body)

status.Size =
    UDim2.new(1, 0, 0, 30)

status.BackgroundColor3 =
    Color3.fromRGB(27, 27, 34)

status.Text =
    "●  READY"

status.Font =
    Enum.Font.GothamMedium

status.TextSize = 10

status.TextColor3 =
    Color3.fromRGB(125, 255, 165)

Instance.new(
    "UICorner",
    status
).CornerRadius =
    UDim.new(0, 8)

--==============================================================
-- COUNTER
--==============================================================

local counter =
    Instance.new("TextLabel", body)

counter.Size =
    UDim2.new(1, 0, 0, 22)

counter.Position =
    UDim2.new(0, 0, 0, 34)

counter.BackgroundTransparency = 1

counter.Text =
    "PROPS  0 / 15"

counter.Font =
    Enum.Font.GothamBold

counter.TextSize = 9

counter.TextColor3 =
    Color3.fromRGB(145, 145, 155)

counter.TextXAlignment =
    Enum.TextXAlignment.Left

--==============================================================
-- BUTTON CREATOR
--==============================================================

local function createButton(
    text,
    y,
    bg,
    fg
)

    local button =
        Instance.new(
            "TextButton",
            body
        )

    button.Size =
        UDim2.new(
            1,
            0,
            0,
            37
        )

    button.Position =
        UDim2.new(
            0,
            0,
            0,
            y
        )

    button.BackgroundColor3 =
        bg

    button.Text =
        text

    button.Font =
        Enum.Font.GothamBold

    button.TextSize = 10

    button.TextColor3 =
        fg

    button.BorderSizePixel = 0

    button.AutoButtonColor = false

    Instance.new(
        "UICorner",
        button
    ).CornerRadius =
        UDim.new(0, 9)

    local stroke =
        Instance.new(
            "UIStroke",
            button
        )

    stroke.Color = fg

    stroke.Thickness = 1

    stroke.Transparency = 0.8

    return button
end

--==============================================================
-- BUTTONS
--==============================================================

local scanButton =
    createButton(
        "📦  RESCAN PROPS",
        62,
        Color3.fromRGB(28, 38, 57),
        Color3.fromRGB(120, 190, 255)
    )

local assembleButton =
    createButton(
        "🤖  ASSEMBLE ROBOT",
        105,
        Color3.fromRGB(58, 39, 21),
        Color3.fromRGB(255, 185, 80)
    )

local controlButton =
    createButton(
        "🎮  CONTROL ROBOT",
        148,
        Color3.fromRGB(24, 53, 37),
        Color3.fromRGB(120, 255, 165)
    )

local resetButton =
    createButton(
        "♻  RESET PROPS",
        191,
        Color3.fromRGB(54, 27, 31),
        Color3.fromRGB(255, 130, 135)
    )

--==============================================================
-- HEIGHT
--==============================================================

local heightPanel =
    Instance.new("Frame", body)

heightPanel.Size =
    UDim2.new(1, 0, 0, 60)

heightPanel.Position =
    UDim2.new(0, 0, 0, 235)

heightPanel.BackgroundColor3 =
    Color3.fromRGB(24, 24, 31)

heightPanel.BorderSizePixel = 0

Instance.new(
    "UICorner",
    heightPanel
).CornerRadius =
    UDim.new(0, 9)

local heightTitle =
    Instance.new(
        "TextLabel",
        heightPanel
    )

heightTitle.Size =
    UDim2.new(
        1,
        -16,
        0,
        18
    )

heightTitle.Position =
    UDim2.new(
        0,
        8,
        0,
        3
    )

heightTitle.BackgroundTransparency = 1

heightTitle.Text =
    "ROBOT HEIGHT"

heightTitle.Font =
    Enum.Font.GothamBold

heightTitle.TextSize = 9

heightTitle.TextColor3 =
    Color3.fromRGB(
        255,
        195,
        110
    )

heightTitle.TextXAlignment =
    Enum.TextXAlignment.Left

-- minus

local minus =
    Instance.new(
        "TextButton",
        heightPanel
    )

minus.Size =
    UDim2.new(
        0,
        45,
        0,
        28
    )

minus.Position =
    UDim2.new(
        0,
        7,
        0,
        27
    )

minus.BackgroundColor3 =
    Color3.fromRGB(
        55,
        27,
        31
    )

minus.Text = "−"

minus.Font =
    Enum.Font.GothamBold

minus.TextSize = 17

minus.TextColor3 =
    Color3.fromRGB(
        255,
        125,
        130
    )

minus.BorderSizePixel = 0

Instance.new(
    "UICorner",
    minus
).CornerRadius =
    UDim.new(0, 7)

-- value

local heightValue =
    Instance.new(
        "TextLabel",
        heightPanel
    )

heightValue.Size =
    UDim2.new(
        1,
        -112,
        0,
        28
    )

heightValue.Position =
    UDim2.new(
        0,
        56,
        0,
        27
    )

heightValue.BackgroundColor3 =
    Color3.fromRGB(
        14,
        14,
        18
    )

heightValue.Text =
    "1.00x"

heightValue.Font =
    Enum.Font.GothamBold

heightValue.TextSize = 11

heightValue.TextColor3 =
    Color3.fromRGB(
        255,
        220,
        145
    )

Instance.new(
    "UICorner",
    heightValue
).CornerRadius =
    UDim.new(0, 7)

-- plus

local plus =
    Instance.new(
        "TextButton",
        heightPanel
    )

plus.Size =
    UDim2.new(
        0,
        45,
        0,
        28
    )

plus.Position =
    UDim2.new(
        1,
        -52,
        0,
        27
    )

plus.BackgroundColor3 =
    Color3.fromRGB(
        24,
        53,
        37
    )

plus.Text = "+"

plus.Font =
    Enum.Font.GothamBold

plus.TextSize = 17

plus.TextColor3 =
    Color3.fromRGB(
        120,
        255,
        165
    )

plus.BorderSizePixel = 0

Instance.new(
    "UICorner",
    plus
).CornerRadius =
    UDim.new(0, 7)

--==============================================================
-- PROP LIST
--==============================================================

local propList =
    Instance.new(
        "ScrollingFrame",
        body
    )

propList.Size =
    UDim2.new(
        1,
        0,
        0,
        100
    )

propList.Position =
    UDim2.new(
        0,
        0,
        0,
        303
    )

propList.BackgroundColor3 =
    Color3.fromRGB(
        19,
        19,
        24
    )

propList.BorderSizePixel = 0

propList.ScrollBarThickness = 3

propList.ScrollBarImageColor3 =
    Color3.fromRGB(
        255,
        145,
        40
    )

propList.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

propList.CanvasSize =
    UDim2.new()

Instance.new(
    "UICorner",
    propList
).CornerRadius =
    UDim.new(0, 9)

local listLayout =
    Instance.new(
        "UIListLayout",
        propList
    )

listLayout.Padding =
    UDim.new(0, 2)

listLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

local padding =
    Instance.new(
        "UIPadding",
        propList
    )

padding.PaddingTop =
    UDim.new(0, 4)

padding.PaddingLeft =
    UDim.new(0, 4)

padding.PaddingRight =
    UDim.new(0, 4)

--==============================================================
-- STATE
--==============================================================

local props = {}

local slotProps = {}

local assembled = false

local controlling = false

local robotAnchor = nil

local connections = {}

local heightScale =
    CONFIG.HeightDefault

local jumpRequest = false

local camera =
    workspace.CurrentCamera

local oldCameraType

local oldCameraSubject

local oldFOV

local oldWalkSpeed

local oldJumpPower

local oldAutoRotate

--==============================================================
-- GET FOLDER
--==============================================================

local function getPropsFolder()

    local folder1 =
        workspace:FindFirstChild(
            CONFIG.Folder1
        )

    if not folder1 then
        return nil
    end

    local folder2 =
        folder1:FindFirstChild(
            CONFIG.Folder2
        )

    if not folder2 then
        return nil
    end

    return folder2
end

--==============================================================
-- GET NUMBER
--==============================================================

local function getNumber(name)

    local n =
        string.match(
            name,
            "(%d+)"
        )

    if n then
        return tonumber(n)
    end

    return 999999
end

--==============================================================
-- FIND PROPS
--==============================================================

local function findProps()

    local folder =
        getPropsFolder()

    if not folder then

        warn(
            "[MANI ROBO] Props folder missing"
        )

        return {}

    end

    local found = {}

    for _, object in ipairs(
        folder:GetChildren()
    ) do

        if object:IsA("BasePart") then

            if string.find(
                object.Name,
                player.Name,
                1,
                true
            ) then

                table.insert(
                    found,
                    object
                )

            end

        end

    end

    table.sort(
        found,
        function(a, b)

            local aNumber =
                getNumber(a.Name)

            local bNumber =
                getNumber(b.Name)

            if aNumber ==
                bNumber then

                return a.Name <
                    b.Name

            end

            return aNumber <
                bNumber

        end
    )

    return found
end

--==============================================================
-- CLEAR LIST
--==============================================================

local function clearList()

    for _, child in ipairs(
        propList:GetChildren()
    ) do

        if child:IsA("Frame")
            or child:IsA("TextLabel") then

            child:Destroy()

        end

    end

end

--==============================================================
-- UPDATE LIST
--==============================================================

local function updateList()

    clearList()

    counter.Text =
        "PROPS  "
        .. tostring(#props)
        .. " / 15"

    for i, prop in ipairs(props) do

        if i > CONFIG.MaxProps then
            break
        end

        local row =
            Instance.new(
                "Frame",
                propList
            )

        row.Size =
            UDim2.new(
                1,
                -8,
                0,
                21
            )

        row.BackgroundColor3 =
            Color3.fromRGB(
                28,
                28,
                35
            )

        row.BorderSizePixel = 0

        Instance.new(
            "UICorner",
            row
        ).CornerRadius =
            UDim.new(0, 5)

        local label =
            Instance.new(
                "TextLabel",
                row
            )

        label.Size =
            UDim2.new(
                1,
                -8,
                1,
                0
            )

        label.Position =
            UDim2.new(
                0,
                6,
                0,
                0
            )

        label.BackgroundTransparency = 1

        label.Text =
            string.format(
                "%02d   %s",
                i,
                ROBOT_ORDER[i]
                    or "Extra"
            )

        label.Font =
            Enum.Font.GothamMedium

        label.TextSize = 8

        label.TextColor3 =
            Color3.fromRGB(
                195,
                195,
                205
            )

        label.TextXAlignment =
            Enum.TextXAlignment.Left

    end
end

--==============================================================
-- REMOTE
--==============================================================

local function setProp(
    prop,
    cframe
)

    if not prop
        or not prop.Parent then

        return

    end

    local remote =
        prop:FindFirstChild(
            "SetCurrentCFrame"
        )

    if remote
        and remote:IsA(
            "RemoteFunction"
        ) then

        local success =
            pcall(function()

                remote:InvokeServer(
                    cframe
                )

            end)

        if not success then

            prop.CFrame =
                cframe

        end

    else

        prop.CFrame =
            cframe

    end
end

--==============================================================
-- GET OFFSET
--==============================================================

local function getOffset(index)

    local offset =
        OFFSETS[index]

    if not offset then
        return Vector3.zero
    end

    return Vector3.new(

        offset.X,

        offset.Y *
            heightScale,

        offset.Z

    )
end

--==============================================================
-- GET BASE
--==============================================================

local function getBase()

    local position =
        hrp.Position
        + hrp.CFrame.LookVector
        * 8

    return Vector3.new(

        position.X,

        hrp.Position.Y,

        position.Z

    )
end

--==============================================================
-- SCAN BUTTON
--==============================================================

scanButton.MouseButton1Click:Connect(
    function()

        status.Text =
            "●  SCANNING..."

        status.TextColor3 =
            Color3.fromRGB(
                255,
                195,
                100
            )

        task.wait(0.15)

        props =
            findProps()

        updateList()

        if #props == 0 then

            status.Text =
                "●  NO PROPS FOUND"

            status.TextColor3 =
                Color3.fromRGB(
                    255,
                    100,
                    100
                )

        else

            status.Text =
                "●  FOUND "
                .. #props
                .. " PROPS"

            status.TextColor3 =
                Color3.fromRGB(
                    120,
                    255,
                    165
                )

        end

    end
)

--==============================================================
-- ASSEMBLE
--==============================================================

local function assembleRobot()

    if controlling then

        status.Text =
            "●  STOP CONTROL FIRST"

        return
    end

    if #props == 0 then

        props =
            findProps()

        updateList()

    end

    if #props == 0 then

        status.Text =
            "●  NO PROPS"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                100,
                100
            )

        return
    end

    status.Text =
        "●  ASSEMBLING..."

    status.TextColor3 =
        Color3.fromRGB(
            255,
            190,
            80
        )

    slotProps = {}

    local base =
        getBase()

    for i = 1,
        math.min(
            #props,
            CONFIG.MaxProps
        ) do

        local prop =
            props[i]

        local offset =
            getOffset(i)

        local cf =
            CFrame.new(
                base + offset
            )

        setProp(
            prop,
            cf
        )

        slotProps[i] =
            prop

        task.wait(0.10)

    end

    assembled = true

    status.Text =
        "●  ROBOT ASSEMBLED"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            255,
            165
        )

end

assembleButton.MouseButton1Click:Connect(
    assembleRobot
)

--==============================================================
-- HEIGHT
--==============================================================

local function updateHeightText()

    heightValue.Text =
        string.format(
            "%.2fx",
            heightScale
        )

end

plus.MouseButton1Click:Connect(
    function()

        if controlling then
            return
        end

        heightScale =
            math.min(
                heightScale
                    + CONFIG.HeightStep,

                CONFIG.HeightMax
            )

        updateHeightText()

        status.Text =
            "●  HEIGHT "
            .. string.format(
                "%.2fx",
                heightScale
            )

        if assembled then

            local center =
                Vector3.zero

            local count = 0

            for _, prop in pairs(
                slotProps
            ) do

                if prop
                    and prop.Parent then

                    center +=
                        prop.Position

                    count += 1

                end

            end

            if count > 0 then

                center /=
                    count

                for i, prop in pairs(
                    slotProps
                ) do

                    if prop
                        and prop.Parent then

                        setProp(

                            prop,

                            CFrame.new(
                                center
                                + getOffset(i)
                            )

                        )

                    end

                end

            end

        end

    end
)

minus.MouseButton1Click:Connect(
    function()

        if controlling then
            return
        end

        heightScale =
            math.max(
                heightScale
                    - CONFIG.HeightStep,

                CONFIG.HeightMin
            )

        updateHeightText()

        status.Text =
            "●  HEIGHT "
            .. string.format(
                "%.2fx",
                heightScale
            )

    end
)

updateHeightText()

--==============================================================
-- CLEAR CONNECTIONS
--==============================================================

local function clearConnections()

    for _, connection in ipairs(
        connections
    ) do

        pcall(function()

            connection:Disconnect()

        end)

    end

    connections = {}

end

--==============================================================
-- UPDATE ROBOT PARTS
--==============================================================

local function updateRobotParts(
    anchorCF,
    useRemote
)

    for i, prop in pairs(
        slotProps
    ) do

        if prop
            and prop.Parent then

            local target =
                anchorCF
                * CFrame.new(
                    getOffset(i)
                )

            -- smooth visual

            prop.CFrame =
                prop.CFrame:Lerp(
                    target,
                    0.35
                )

            -- server update

            if useRemote then

                setProp(
                    prop,
                    target
                )

            end

        end

    end
end

--==============================================================
-- START CONTROL
--==============================================================

local function startControl()

    if not assembled then

        status.Text =
            "●  ASSEMBLE ROBOT FIRST"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                190,
                80
            )

        return
    end

    if #slotProps == 0 then
        return
    end

    --==========================================================
    -- FIND CENTER
    --==========================================================

    local center =
        Vector3.zero

    local count = 0

    for _, prop in pairs(
        slotProps
    ) do

        if prop
            and prop.Parent then

            center +=
                prop.Position

            count += 1

        end

    end

    if count == 0 then
        return
    end

    center /=
        count

    --==========================================================
    -- SAVE PLAYER
    --==========================================================

    oldWalkSpeed =
        humanoid.WalkSpeed

    oldJumpPower =
        humanoid.JumpPower

    oldAutoRotate =
        humanoid.AutoRotate

    oldCameraType =
        camera.CameraType

    oldCameraSubject =
        camera.CameraSubject

    oldFOV =
        camera.FieldOfView

    --==========================================================
    -- CONTROL STATE
    --==========================================================

    controlling = true

    jumpRequest = false

    -- IMPORTANT:
    -- Keep Humanoid active so Roblox
    -- mobile joystick continues producing
    -- MoveDirection.

    humanoid.AutoRotate = false

    --==========================================================
    -- FREEZE PLAYER BODY
    --==========================================================

    hrp.Anchored = true

    --==========================================================
    -- ROBOT ANCHOR
    --==========================================================

    robotAnchor =
        Instance.new("Part")

    robotAnchor.Name =
        "MANI_PUMPKIN_ROBOT_ANCHOR"

    robotAnchor.Size =
        Vector3.new(
            1,
            1,
            1
        )

    robotAnchor.Transparency = 1

    robotAnchor.Anchored = true

    robotAnchor.CanCollide = false

    robotAnchor.CanTouch = false

    robotAnchor.CanQuery = false

    robotAnchor.CFrame =
        CFrame.new(center)

    robotAnchor.Parent =
        workspace

    --==========================================================
    -- CAMERA
    --==========================================================

    camera.CameraType =
        Enum.CameraType.Scriptable

    camera.FieldOfView = 72

    --==========================================================
    -- CAMERA LOOP
    --==========================================================

    table.insert(
        connections,

        RunService.RenderStepped:Connect(
            function()

                if not controlling then
                    return
                end

                if not robotAnchor
                    or not robotAnchor.Parent then

                    return

                end

                local a =
                    robotAnchor

                local cameraPosition =
                    a.Position
                    - a.CFrame.LookVector
                    * CONFIG.CameraDistance
                    + Vector3.new(
                        0,
                        CONFIG.CameraHeight,
                        0
                    )

                local lookPosition =
                    a.Position
                    + Vector3.new(
                        0,
                        CONFIG.CameraLookHeight
                            * heightScale,
                        0
                    )

                camera.CFrame =
                    CFrame.new(
                        cameraPosition,
                        lookPosition
                    )

            end
        )
    )

    --==========================================================
    -- MOVEMENT LOOP
    --==========================================================

    local lastRemoteUpdate = 0

    table.insert(
        connections,

        RunService.Heartbeat:Connect(
            function(dt)

                if not controlling then
                    return
                end

                if not robotAnchor
                    or not robotAnchor.Parent then

                    return

                end

                --================================================
                -- DEFAULT ROBLOX JOYSTICK
                --================================================

                local move =
                    humanoid.MoveDirection

                local direction =
                    Vector3.new(
                        move.X,
                        0,
                        move.Z
                    )

                if direction.Magnitude
                    > 0.05 then

                    direction =
                        direction.Unit

                    -- smooth rotation

                    local wantedCF =
                        CFrame.new(
                            robotAnchor.Position,

                            robotAnchor.Position
                                + direction
                        )

                    robotAnchor.CFrame =
                        robotAnchor.CFrame:Lerp(
                            wantedCF,

                            math.clamp(
                                CONFIG.TurnSpeed
                                    * dt,
                                0,
                                1
                            )
                        )

                    -- movement

                    local newPosition =
                        robotAnchor.Position
                        + direction
                        * CONFIG.MoveSpeed
                        * dt

                    robotAnchor.CFrame =
                        CFrame.new(
                            newPosition,
                            newPosition
                                + direction
                        )

                end

                --================================================
                -- JUMP
                --================================================

                if jumpRequest then

                    jumpRequest = false

                    local start =
                        robotAnchor.CFrame

                    local jumpUp =
                        start
                        + Vector3.new(
                            0,
                            CONFIG.JumpHeight,
                            0
                        )

                    local upTween =
                        TweenService:Create(

                            robotAnchor,

                            TweenInfo.new(
                                0.20,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            ),

                            {
                                CFrame =
                                    jumpUp
                            }

                        )

                    upTween:Play()

                    task.delay(
                        0.20,
                        function()

                            if not controlling then
                                return
                            end

                            if not robotAnchor
                                or not robotAnchor.Parent then

                                return

                            end

                            local down =
                                robotAnchor.CFrame
                                - Vector3.new(
                                    0,
                                    CONFIG.JumpHeight,
                                    0
                                )

                            TweenService:Create(

                                robotAnchor,

                                TweenInfo.new(
                                    0.25,
                                    Enum.EasingStyle.Quad,
                                    Enum.EasingDirection.In
                                ),

                                {
                                    CFrame =
                                        down
                                }

                            ):Play()

                        end
                    )

                end

                --================================================
                -- ROBOT PARTS
                --================================================

                local sendRemote =
                    os.clock()
                    - lastRemoteUpdate
                    >= 0.08

                if sendRemote then
                    lastRemoteUpdate =
                        os.clock()
                end

                updateRobotParts(
                    robotAnchor.CFrame,
                    sendRemote
                )

            end
        )
    )

    --==========================================================
    -- DEFAULT ROBLOX JUMP BUTTON
    --==========================================================

    table.insert(
        connections,

        UserInputService.JumpRequest:Connect(
            function()

                if controlling then

                    jumpRequest = true

                end

            end
        )
    )

    --==========================================================
    -- UI
    --==========================================================

    controlButton.Text =
        "🛑  STOP ROBOT"

    status.Text =
        "●  ROBOT CONTROL ACTIVE"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            255,
            165
        )

end

--==============================================================
-- STOP CONTROL
--==============================================================

local function stopControl()

    if not controlling then
        return
    end

    controlling = false

    jumpRequest = false

    clearConnections()

    if robotAnchor then

        robotAnchor:Destroy()

        robotAnchor = nil

    end

    -- restore player

    humanoid.WalkSpeed =
        oldWalkSpeed
        or 16

    humanoid.JumpPower =
        oldJumpPower
        or 50

    humanoid.AutoRotate =
        oldAutoRotate
        ~= false

    hrp.Anchored = false

    -- restore camera

    camera.CameraType =
        oldCameraType
        or Enum.CameraType.Custom

    camera.CameraSubject =
        oldCameraSubject
        or humanoid

    camera.FieldOfView =
        oldFOV
        or 70

    controlButton.Text =
        "🎮  CONTROL ROBOT"

    status.Text =
        "●  CONTROL STOPPED"

    status.TextColor3 =
        Color3.fromRGB(
            180,
            220,
            180
        )

end

--==============================================================
-- CONTROL BUTTON
--==============================================================

controlButton.MouseButton1Click:Connect(
    function()

        if controlling then

            stopControl()

        else

            startControl()

        end

    end
)

--==============================================================
-- RESET
--==============================================================

resetButton.MouseButton1Click:Connect(
    function()

        if controlling then
            stopControl()
        end

        assembled = false

        slotProps = {}

        if #props == 0 then

            props =
                findProps()

            updateList()

        end

        local total =
            math.min(
                #props,
                CONFIG.MaxProps
            )

        if total > 0 then

            local center =
                hrp.Position

            for i = 1, total do

                local prop =
                    props[i]

                if prop
                    and prop.Parent then

                    local angle =
                        (
                            2 * math.pi
                            / total
                        ) * i

                    local position =
                        center
                        + Vector3.new(

                            math.cos(angle)
                                * CONFIG.ResetRadius,

                            0,

                            math.sin(angle)
                                * CONFIG.ResetRadius

                        )

                    setProp(

                        prop,

                        CFrame.new(
                            position,
                            center
                        )

                    )

                    task.wait(0.10)

                end

            end

        end

        status.Text =
            "●  RESET COMPLETE"

        status.TextColor3 =
            Color3.fromRGB(
                120,
                255,
                165
            )

        controlButton.Text =
            "🎮  CONTROL ROBOT"

    end
)

--==============================================================
-- MINIMIZE
--==============================================================

local minimized = false

minButton.MouseButton1Click:Connect(
    function()

        minimized =
            not minimized

        if minimized then

            body.Visible = false

            minButton.Text = "+"

            TweenService:Create(

                main,

                TweenInfo.new(
                    0.20,
                    Enum.EasingStyle.Quad
                ),

                {
                    Size =
                        UDim2.new(
                            0,
                            285,
                            0,
                            46
                        )
                }

            ):Play()

        else

            body.Visible = true

            minButton.Text = "—"

            TweenService:Create(

                main,

                TweenInfo.new(
                    0.20,
                    Enum.EasingStyle.Quad
                ),

                {
                    Size =
                        UDim2.new(
                            0,
                            285,
                            0,
                            430
                        )
                }

            ):Play()

        end

    end
)

--==============================================================
-- CLOSE
--==============================================================

closeButton.MouseButton1Click:Connect(
    function()

        if controlling then
            stopControl()
        end

        gui:Destroy()

    end
)

--==============================================================
-- FLOATING BUTTON
--==============================================================

local floating =
    Instance.new(
        "TextButton",
        gui
    )

floating.Size =
    UDim2.new(
        0,
        46,
        0,
        46
    )

floating.Position =
    UDim2.new(
        1,
        -60,
        0.55,
        0
    )

floating.BackgroundColor3 =
    Color3.fromRGB(
        22,
        22,
        28
    )

floating.Text = "🎃"

floating.Font =
    Enum.Font.GothamBold

floating.TextSize = 19

floating.TextColor3 =
    Color3.fromRGB(
        255,
        160,
        50
    )

floating.BorderSizePixel = 0

floating.Active = true

Instance.new(
    "UICorner",
    floating
).CornerRadius =
    UDim.new(0, 23)

local floatStroke =
    Instance.new(
        "UIStroke",
        floating
    )

floatStroke.Color =
    Color3.fromRGB(
        255,
        140,
        35
    )

floatStroke.Thickness = 1.3

--==============================================================
-- FLOATING DRAG
--==============================================================

local floatDragging = false

local floatStart

local floatPosition

floating.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            floatDragging = true

            floatStart =
                input.Position

            floatPosition =
                floating.Position

        end

    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not floatDragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            local delta =
                input.Position
                - floatStart

            floating.Position =
                UDim2.new(

                    floatPosition.X.Scale,

                    floatPosition.X.Offset
                        + delta.X,

                    floatPosition.Y.Scale,

                    floatPosition.Y.Offset
                        + delta.Y

                )

        end

    end
)

UserInputService.InputEnded:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            floatDragging = false

        end

    end
)

floating.MouseButton1Click:Connect(
    function()

        main.Visible =
            not main.Visible

    end
)

--==============================================================
-- RESPAWN
--==============================================================

player.CharacterAdded:Connect(
    function(newCharacter)

        if controlling then
            stopControl()
        end

        task.wait(0.5)

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

--==============================================================
-- INITIAL SCAN
--==============================================================

props =
    findProps()

updateList()

updateHeightText()

status.Text =
    "●  READY — "
    .. tostring(#props)
    .. " PROPS"

print(
    "[MANI PUMPKIN ROBO V.1] LOADED"
)
