--==============================================================
-- 🎃 MANI PUMPKIN ROBO V.1
-- PC + MOBILE | SMALL MODERN DARK GUI
-- 15 PROPS | ROBOT ASSEMBLY | JOYSTICK CONTROL
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

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {

    FolderPath = {
        "WorkspaceCom",
        "001_TrafficCones"
    },

    -- Robot movement
    MoveSpeed = 38,
    TurnSpeed = 8,

    -- Camera
    CameraDistance = 18,
    CameraHeight = 7,
    CameraLookHeight = 3,

    -- Reset circle
    ResetRadius = 12,

    -- Height
    HeightMin = 0.50,
    HeightMax = 3.00,
    HeightStep = 0.25,
    HeightDefault = 1.00,

    -- GUI
    GuiWidth = 290,
    GuiHeight = 455,
}

--==============================================================
-- 15 ROBOT SLOTS
--==============================================================

local SPAWN_ORDER = {

    -- MAIN BODY
    "Head",        -- 1
    "Waist",       -- 2
    "RightHand",   -- 3
    "LeftHand",    -- 4

    -- RIGHT LEG
    "RightLeg1",   -- 5
    "RightLeg2",   -- 6
    "RightLeg3",   -- 7

    -- LEFT LEG
    "LeftLeg1",    -- 8
    "LeftLeg2",    -- 9
    "LeftLeg3",    -- 10

    -- EXTRA 5 PROPS
    "Armor1",      -- 11
    "Armor2",      -- 12
    "Armor3",      -- 13
    "Armor4",      -- 14
    "Armor5",      -- 15
}

--==============================================================
-- ROBOT POSITIONS
--==============================================================

local BASE_OFFSETS = {

    -- Head
    Head = Vector3.new(
        0,
        5.5,
        0
    ),

    -- Waist
    Waist = Vector3.new(
        0,
        3.0,
        0
    ),

    -- Hands
    RightHand = Vector3.new(
        2.5,
        3.5,
        0
    ),

    LeftHand = Vector3.new(
        -2.5,
        3.5,
        0
    ),

    -- Right Leg
    RightLeg1 = Vector3.new(
        1.2,
        1.5,
        0
    ),

    RightLeg2 = Vector3.new(
        1.2,
        0.3,
        0
    ),

    RightLeg3 = Vector3.new(
        1.2,
        -0.9,
        0
    ),

    -- Left Leg
    LeftLeg1 = Vector3.new(
        -1.2,
        1.5,
        0
    ),

    LeftLeg2 = Vector3.new(
        -1.2,
        0.3,
        0
    ),

    LeftLeg3 = Vector3.new(
        -1.2,
        -0.9,
        0
    ),

    --==========================================================
    -- EXTRA ARMOR / DETAIL PROPS
    --==========================================================

    Armor1 = Vector3.new(
        0,
        4.0,
        1.5
    ),

    Armor2 = Vector3.new(
        1.4,
        4.0,
        0.8
    ),

    Armor3 = Vector3.new(
        -1.4,
        4.0,
        0.8
    ),

    Armor4 = Vector3.new(
        0,
        2.5,
        1.2
    ),

    Armor5 = Vector3.new(
        0,
        1.2,
        0.8
    ),
}

--==============================================================
-- GUI
--==============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MANI_PUMPKIN_ROBO_V1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

--==============================================================
-- MAIN WINDOW
--==============================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(
    0,
    CONFIG.GuiWidth,
    0,
    CONFIG.GuiHeight
)

main.Position = UDim2.new(
    0,
    18,
    0.5,
    -(CONFIG.GuiHeight / 2)
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
    UDim.new(0, 14)

local mainStroke = Instance.new(
    "UIStroke",
    main
)

mainStroke.Color = Color3.fromRGB(
    255,
    140,
    35
)

mainStroke.Thickness = 1.4
mainStroke.Transparency = 0.35

--==============================================================
-- TITLE BAR
--==============================================================

local titleBar = Instance.new(
    "Frame",
    main
)

titleBar.Size = UDim2.new(
    1,
    0,
    0,
    48
)

titleBar.BackgroundColor3 = Color3.fromRGB(
    23,
    23,
    28
)

titleBar.BorderSizePixel = 0
titleBar.Active = true

Instance.new("UICorner", titleBar).CornerRadius =
    UDim.new(0, 14)

-- bottom cover
local titleFix = Instance.new(
    "Frame",
    titleBar
)

titleFix.Size = UDim2.new(
    1,
    0,
    0,
    18
)

titleFix.Position = UDim2.new(
    0,
    0,
    1,
    -18
)

titleFix.BackgroundColor3 =
    Color3.fromRGB(23,23,28)

titleFix.BorderSizePixel = 0

--==============================================================
-- DRAG SYSTEM
--==============================================================

local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false

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

        main.Position = UDim2.new(

            startPos.X.Scale,
            startPos.X.Offset + delta.X,

            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end

end)

--==============================================================
-- TITLE
--==============================================================

local title = Instance.new(
    "TextLabel",
    titleBar
)

title.Size = UDim2.new(
    1,
    -92,
    1,
    0
)

title.Position = UDim2.new(
    0,
    14,
    0,
    0
)

title.BackgroundTransparency = 1

title.Text =
    "🎃  MANI PUMPKIN ROBO"

title.Font =
    Enum.Font.GothamBold

title.TextSize = 14

title.TextColor3 =
    Color3.fromRGB(
        255,
        166,
        55
    )

title.TextXAlignment =
    Enum.TextXAlignment.Left

--==============================================================
-- MINIMIZE
--==============================================================

local minBtn = Instance.new(
    "TextButton",
    titleBar
)

minBtn.Size = UDim2.new(
    0,
    30,
    0,
    30
)

minBtn.Position = UDim2.new(
    1,
    -70,
    0,
    9
)

minBtn.BackgroundColor3 =
    Color3.fromRGB(
        42,
        42,
        50
    )

minBtn.Text = "—"

minBtn.Font =
    Enum.Font.GothamBold

minBtn.TextSize = 17

minBtn.TextColor3 =
    Color3.fromRGB(
        255,
        190,
        100
    )

minBtn.BorderSizePixel = 0

Instance.new("UICorner", minBtn).CornerRadius =
    UDim.new(0, 8)

--==============================================================
-- CLOSE
--==============================================================

local closeBtn = Instance.new(
    "TextButton",
    titleBar
)

closeBtn.Size = UDim2.new(
    0,
    30,
    0,
    30
)

closeBtn.Position = UDim2.new(
    1,
    -36,
    0,
    9
)

closeBtn.BackgroundColor3 =
    Color3.fromRGB(
        55,
        25,
        30
    )

closeBtn.Text = "×"

closeBtn.Font =
    Enum.Font.GothamBold

closeBtn.TextSize = 17

closeBtn.TextColor3 =
    Color3.fromRGB(
        255,
        100,
        100
    )

closeBtn.BorderSizePixel = 0

Instance.new("UICorner", closeBtn).CornerRadius =
    UDim.new(0, 8)

--==============================================================
-- BODY
--==============================================================

local body = Instance.new(
    "Frame",
    main
)

body.Name = "Body"

body.Size = UDim2.new(
    1,
    -20,
    1,
    -58
)

body.Position = UDim2.new(
    0,
    10,
    0,
    54
)

body.BackgroundTransparency = 1

--==============================================================
-- STATUS
--==============================================================

local status = Instance.new(
    "TextLabel",
    body
)

status.Size = UDim2.new(
    1,
    0,
    0,
    32
)

status.BackgroundColor3 =
    Color3.fromRGB(
        27,
        27,
        34
    )

status.Text =
    "●  Ready"

status.Font =
    Enum.Font.GothamMedium

status.TextSize = 11

status.TextColor3 =
    Color3.fromRGB(
        130,
        255,
        165
    )

Instance.new("UICorner", status).CornerRadius =
    UDim.new(0, 8)

--==============================================================
-- PROP COUNTER
--==============================================================

local propCounter = Instance.new(
    "TextLabel",
    body
)

propCounter.Size = UDim2.new(
    1,
    0,
    0,
    22
)

propCounter.Position = UDim2.new(
    0,
    0,
    0,
    37
)

propCounter.BackgroundTransparency = 1

propCounter.Text =
    "ROBOT PARTS   0 / 15"

propCounter.Font =
    Enum.Font.GothamBold

propCounter.TextSize = 10

propCounter.TextColor3 =
    Color3.fromRGB(
        150,
        150,
        165
    )

propCounter.TextXAlignment =
    Enum.TextXAlignment.Left

--==============================================================
-- BUTTON FUNCTION
--==============================================================

local function makeButton(
    text,
    position,
    background,
    textColor
)

    local button = Instance.new(
        "TextButton",
        body
    )

    button.Size = UDim2.new(
        1,
        0,
        0,
        38
    )

    button.Position = position

    button.BackgroundColor3 =
        background

    button.Text = text

    button.Font =
        Enum.Font.GothamBold

    button.TextSize = 11

    button.TextColor3 =
        textColor

    button.BorderSizePixel = 0

    button.AutoButtonColor = false

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 9)

    local stroke =
        Instance.new("UIStroke", button)

    stroke.Color = textColor
    stroke.Thickness = 1
    stroke.Transparency = 0.78

    button.MouseEnter:Connect(function()

        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 =
                    Color3.new(
                        math.min(background.R + 0.06, 1),
                        math.min(background.G + 0.06, 1),
                        math.min(background.B + 0.06, 1)
                    )
            }
        ):Play()

    end)

    button.MouseLeave:Connect(function()

        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 =
                    background
            }
        ):Play()

    end)

    return button
end

--==============================================================
-- MAIN BUTTONS
--==============================================================

local spawnBtn = makeButton(
    "📦   RESCAN 15 PROPS",
    UDim2.new(0,0,0,64),
    Color3.fromRGB(29,38,57),
    Color3.fromRGB(120,190,255)
)

local assembleBtn = makeButton(
    "🤖   ASSEMBLE ROBOT",
    UDim2.new(0,0,0,108),
    Color3.fromRGB(58,39,22),
    Color3.fromRGB(255,185,80)
)

local controlBtn = makeButton(
    "🎮   CONTROL ROBOT",
    UDim2.new(0,0,0,152),
    Color3.fromRGB(25,55,38),
    Color3.fromRGB(120,255,165)
)

local resetBtn = makeButton(
    "♻   RESET TO CIRCLE",
    UDim2.new(0,0,0,196),
    Color3.fromRGB(55,28,32),
    Color3.fromRGB(255,130,135)
)

--==============================================================
-- HEIGHT PANEL
--==============================================================

local heightPanel = Instance.new(
    "Frame",
    body
)

heightPanel.Size = UDim2.new(
    1,
    0,
    0,
    65
)

heightPanel.Position = UDim2.new(
    0,
    0,
    0,
    242
)

heightPanel.BackgroundColor3 =
    Color3.fromRGB(
        25,
        25,
        32
    )

heightPanel.BorderSizePixel = 0

Instance.new("UICorner", heightPanel).CornerRadius =
    UDim.new(0, 10)

-- label

local heightTitle = Instance.new(
    "TextLabel",
    heightPanel
)

heightTitle.Size = UDim2.new(
    1,
    -20,
    0,
    20
)

heightTitle.Position = UDim2.new(
    0,
    10,
    0,
    4
)

heightTitle.BackgroundTransparency = 1

heightTitle.Text =
    "📏  ROBOT HEIGHT"

heightTitle.Font =
    Enum.Font.GothamBold

heightTitle.TextSize = 10

heightTitle.TextColor3 =
    Color3.fromRGB(
        255,
        195,
        110
    )

heightTitle.TextXAlignment =
    Enum.TextXAlignment.Left

-- minus

local minusBtn = Instance.new(
    "TextButton",
    heightPanel
)

minusBtn.Size = UDim2.new(
    0,
    48,
    0,
    29
)

minusBtn.Position = UDim2.new(
    0,
    8,
    0,
    29
)

minusBtn.BackgroundColor3 =
    Color3.fromRGB(
        55,
        28,
        32
    )

minusBtn.Text = "−"

minusBtn.Font =
    Enum.Font.GothamBold

minusBtn.TextSize = 17

minusBtn.TextColor3 =
    Color3.fromRGB(
        255,
        130,
        130
    )

minusBtn.BorderSizePixel = 0

Instance.new("UICorner", minusBtn).CornerRadius =
    UDim.new(0, 7)

-- value

local heightValue = Instance.new(
    "TextLabel",
    heightPanel
)

heightValue.Size = UDim2.new(
    1,
    -116,
    0,
    29
)

heightValue.Position = UDim2.new(
    0,
    58,
    0,
    29
)

heightValue.BackgroundColor3 =
    Color3.fromRGB(
        16,
        16,
        21
    )

heightValue.Text =
    "1.00x"

heightValue.Font =
    Enum.Font.GothamBold

heightValue.TextSize = 12

heightValue.TextColor3 =
    Color3.fromRGB(
        255,
        220,
        145
    )

Instance.new("UICorner", heightValue).CornerRadius =
    UDim.new(0, 7)

-- plus

local plusBtn = Instance.new(
    "TextButton",
    heightPanel
)

plusBtn.Size = UDim2.new(
    0,
    48,
    0,
    29
)

plusBtn.Position = UDim2.new(
    1,
    -56,
    0,
    29
)

plusBtn.BackgroundColor3 =
    Color3.fromRGB(
        25,
        55,
        38
    )

plusBtn.Text = "+"

plusBtn.Font =
    Enum.Font.GothamBold

plusBtn.TextSize = 17

plusBtn.TextColor3 =
    Color3.fromRGB(
        120,
        255,
        165
    )

plusBtn.BorderSizePixel = 0

Instance.new("UICorner", plusBtn).CornerRadius =
    UDim.new(0, 7)

--==============================================================
-- PROP LIST
--==============================================================

local listFrame = Instance.new(
    "ScrollingFrame",
    body
)

listFrame.Size = UDim2.new(
    1,
    0,
    0,
    108
)

listFrame.Position = UDim2.new(
    0,
    0,
    0,
    316
)

listFrame.BackgroundColor3 =
    Color3.fromRGB(
        20,
        20,
        26
    )

listFrame.BorderSizePixel = 0

listFrame.ScrollBarThickness = 3

listFrame.ScrollBarImageColor3 =
    Color3.fromRGB(
        255,
        145,
        40
    )

listFrame.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

listFrame.CanvasSize =
    UDim2.new()

Instance.new("UICorner", listFrame).CornerRadius =
    UDim.new(0, 9)

local listLayout =
    Instance.new(
        "UIListLayout",
        listFrame
    )

listLayout.Padding =
    UDim.new(0, 3)

listLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

local listPadding =
    Instance.new(
        "UIPadding",
        listFrame
    )

listPadding.PaddingTop =
    UDim.new(0, 5)

listPadding.PaddingLeft =
    UDim.new(0, 5)

listPadding.PaddingRight =
    UDim.new(0, 5)

--==============================================================
-- STATE
--==============================================================

local state = {

    props = {},

    slotMap = {},

    isAssembled = false,

    isControlling = false,

    robotAnchor = nil,

    jumpRequested = false,

    heightScale =
        CONFIG.HeightDefault,

    connections = {},

    originalCamType = nil,

    originalWalkSpeed = 16,

    originalJumpPower = 50,

    originalAutoRotate = true,
}

local camera =
    workspace.CurrentCamera

--==============================================================
-- FOLDER
--==============================================================

local function getFolder()

    local current =
        workspace

    for _, name in ipairs(
        CONFIG.FolderPath
    ) do

        current =
            current:FindFirstChild(name)

        if not current then
            return nil
        end

    end

    return current
end

--==============================================================
-- SORT PROP NUMBER
--==============================================================

local function getPropNumber(name)

    -- supports:
    -- prop_1
    -- prop1
    -- 1
    -- trafficcone_01

    local number =
        string.match(
            name,
            "(%d+)"
        )

    if number then
        return tonumber(number)
    end

    return math.huge
end

--==============================================================
-- SCAN PROPS
--==============================================================

local function scanProps()

    local folder =
        getFolder()

    if not folder then
        return {}
    end

    local found = {}

    for _, obj in ipairs(
        folder:GetChildren()
    ) do

        if obj:IsA("BasePart") then

            if string.find(
                obj.Name,
                player.Name,
                1,
                true
            ) then

                table.insert(
                    found,
                    obj
                )

            end

        end

    end

    table.sort(
        found,
        function(a,b)

            local na =
                getPropNumber(a.Name)

            local nb =
                getPropNumber(b.Name)

            if na == nb then
                return a.Name < b.Name
            end

            return na < nb

        end
    )

    return found
end

--==============================================================
-- REFRESH LIST
--==============================================================

local function refreshList()

    for _, child in ipairs(
        listFrame:GetChildren()
    ) do

        if child:IsA("TextLabel")
            or child:IsA("Frame") then

            child:Destroy()

        end

    end

    propCounter.Text =
        "ROBOT PARTS   "
        .. tostring(#state.props)
        .. " / 15"

    if #state.props == 0 then

        local empty =
            Instance.new(
                "TextLabel",
                listFrame
            )

        empty.Size =
            UDim2.new(
                1,
                -10,
                0,
                32
            )

        empty.BackgroundTransparency = 1

        empty.Text =
            "No props found"

        empty.Font =
            Enum.Font.Gotham

        empty.TextSize = 11

        empty.TextColor3 =
            Color3.fromRGB(
                140,
                140,
                150
            )

        return
    end

    for i, prop in ipairs(
        state.props
    ) do

        local slot =
            SPAWN_ORDER[i]
            or "Extra"

        local row =
            Instance.new(
                "Frame",
                listFrame
            )

        row.Size =
            UDim2.new(
                1,
                -10,
                0,
                24
            )

        row.BackgroundColor3 =
            Color3.fromRGB(
                29,
                29,
                37
            )

        row.BorderSizePixel = 0

        Instance.new("UICorner", row).CornerRadius =
            UDim.new(0, 6)

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
                "%02d  %s",
                i,
                slot
            )

        label.Font =
            Enum.Font.GothamMedium

        label.TextSize = 9

        label.TextColor3 =
            Color3.fromRGB(
                200,
                200,
                210
            )

        label.TextXAlignment =
            Enum.TextXAlignment.Left

        label.TextTruncate =
            Enum.TextTruncate.AtEnd

    end
end

--==============================================================
-- SET PROP CFRAME
--==============================================================

local function setPropCFrame(
    prop,
    cf
)

    if not prop or not prop.Parent then
        return
    end

    local remote =
        prop:FindFirstChild(
            "SetCurrentCFrame"
        )

    if remote
        and remote:IsA("RemoteFunction") then

        pcall(function()
            remote:InvokeServer(cf)
        end)

    else

        prop.CFrame = cf

    end
end

--==============================================================
-- HEIGHT OFFSET
--==============================================================

local function getScaledOffset(
    slot
)

    local base =
        BASE_OFFSETS[slot]

    if not base then
        return Vector3.zero
    end

    return Vector3.new(

        base.X,

        base.Y *
            state.heightScale,

        base.Z

    )
end

--==============================================================
-- BASE POSITION
--==============================================================

local function getBasePosition()

    local position =
        hrp.Position
        + hrp.CFrame.LookVector * 8

    return Vector3.new(

        position.X,

        hrp.Position.Y,

        position.Z
    )
end

--==============================================================
-- RESCAN
--==============================================================

spawnBtn.MouseButton1Click:Connect(function()

    status.Text =
        "●  Scanning props..."

    status.TextColor3 =
        Color3.fromRGB(
            255,
            200,
            100
        )

    task.wait(0.1)

    state.props =
        scanProps()

    refreshList()

    if #state.props == 0 then

        status.Text =
            "●  No props found"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                100,
                100
            )

    else

        status.Text =
            "●  Found "
            .. #state.props
            .. " props"

        status.TextColor3 =
            Color3.fromRGB(
                120,
                255,
                165
            )

    end

end)

--==============================================================
-- ASSEMBLE
--==============================================================

local function assembleRobot()

    if #state.props == 0 then

        state.props =
            scanProps()

        refreshList()

    end

    if #state.props == 0 then

        status.Text =
            "●  No props available"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                100,
                100
            )

        return
    end

    status.Text =
        "●  Assembling robot..."

    status.TextColor3 =
        Color3.fromRGB(
            255,
            190,
            80
        )

    state.slotMap = {}

    local base =
        getBasePosition()

    for i, prop in ipairs(
        state.props
    ) do

        local slot =
            SPAWN_ORDER[i]

        if slot then

            local offset =
                getScaledOffset(slot)

            local cf =
                CFrame.new(
                    base + offset
                )

            setPropCFrame(
                prop,
                cf
            )

            state.slotMap[slot] =
                prop

        end

        task.wait(0.06)

    end

    state.isAssembled = true

    status.Text =
        "●  ROBOT ASSEMBLED"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            255,
            165
        )

end

assembleBtn.MouseButton1Click:Connect(function()

    if state.isControlling then

        status.Text =
            "●  Stop control first"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                190,
                80
            )

        return
    end

    assembleRobot()

end)

--==============================================================
-- HEIGHT
--==============================================================

local function updateHeight()

    heightValue.Text =
        string.format(
            "%.2fx",
            state.heightScale
        )
end

local function rebuildHeight()

    if not state.isAssembled then
        return
    end

    if state.isControlling then
        return
    end

    local waist =
        state.slotMap.Waist

    if not waist then
        return
    end

    local baseY =
        waist.Position.Y
        - (
            BASE_OFFSETS.Waist.Y
            * state.heightScale
        )

    local sum =
        Vector3.zero

    local count = 0

    for _, prop in pairs(
        state.slotMap
    ) do

        if prop
            and prop.Parent then

            sum += prop.Position
            count += 1

        end

    end

    if count == 0 then
        return
    end

    local center =
        sum / count

    local base =
        Vector3.new(
            center.X,
            baseY,
            center.Z
        )

    for slot, prop in pairs(
        state.slotMap
    ) do

        if prop
            and prop.Parent then

            local offset =
                getScaledOffset(slot)

            setPropCFrame(
                prop,
                CFrame.new(
                    base + offset
                )
            )

        end

    end
end

plusBtn.MouseButton1Click:Connect(function()

    if state.isControlling then
        return
    end

    state.heightScale =
        math.min(
            state.heightScale
            + CONFIG.HeightStep,

            CONFIG.HeightMax
        )

    updateHeight()
    rebuildHeight()

    status.Text =
        "●  Height "
        .. string.format(
            "%.2fx",
            state.heightScale
        )

end)

minusBtn.MouseButton1Click:Connect(function()

    if state.isControlling then
        return
    end

    state.heightScale =
        math.max(
            state.heightScale
            - CONFIG.HeightStep,

            CONFIG.HeightMin
        )

    updateHeight()
    rebuildHeight()

    status.Text =
        "●  Height "
        .. string.format(
            "%.2fx",
            state.heightScale
        )

end)

updateHeight()

--==============================================================
-- CLEAR CONNECTIONS
--==============================================================

local function clearConnections()

    for _, connection in ipairs(
        state.connections
    ) do

        pcall(function()
            connection:Disconnect()
        end)

    end

    state.connections = {}

end

--==============================================================
-- ROBOT CAMERA
--==============================================================

local function updateRobotCamera()

    if not state.robotAnchor then
        return
    end

    local anchor =
        state.robotAnchor

    local camPosition =
        anchor.Position
        - anchor.CFrame.LookVector
        * CONFIG.CameraDistance

        + Vector3.new(
            0,
            CONFIG.CameraHeight,
            0
        )

    local lookPosition =
        anchor.Position
        + Vector3.new(
            0,
            CONFIG.CameraLookHeight
            * state.heightScale,
            0
        )

    camera.CFrame =
        CFrame.new(
            camPosition,
            lookPosition
        )
end

--==============================================================
-- START ROBOT CONTROL
--==============================================================

local function startControl()

    if not state.isAssembled then

        status.Text =
            "●  Assemble robot first"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                190,
                80
            )

        return
    end

    if next(state.slotMap) == nil then
        return
    end

    -- Calculate robot center

    local sum =
        Vector3.zero

    local count = 0

    for _, prop in pairs(
        state.slotMap
    ) do

        if prop
            and prop.Parent then

            sum += prop.Position
            count += 1

        end

    end

    if count == 0 then

        status.Text =
            "●  Robot parts missing"

        return
    end

    local center =
        sum / count

    -- STATE

    state.isControlling = true

    state.jumpRequested = false

    -- Save player values

    state.originalWalkSpeed =
        humanoid.WalkSpeed

    state.originalJumpPower =
        humanoid.JumpPower

    state.originalAutoRotate =
        humanoid.AutoRotate

    state.originalCamType =
        camera.CameraType

    -- Player control remains enabled
    -- so Roblox joystick can provide MoveDirection

    humanoid.AutoRotate = false

    humanoid.WalkSpeed = 16

    -- Freeze actual player body

    hrp.Anchored = true

    --==========================================================
    -- ROBOT ANCHOR
    --==========================================================

    local anchor =
        Instance.new("Part")

    anchor.Name =
        "MANI_RobotAnchor"

    anchor.Size =
        Vector3.new(
            1,
            1,
            1
        )

    anchor.Transparency = 1

    anchor.CanCollide = false

    anchor.CanTouch = false

    anchor.CanQuery = false

    anchor.Anchored = true

    anchor.CFrame =
        CFrame.new(center)

    anchor.Parent =
        workspace

    state.robotAnchor =
        anchor

    --==========================================================
    -- CAMERA
    --==========================================================

    camera.CameraType =
        Enum.CameraType.Scriptable

    camera.FieldOfView = 72

    controlBtn.Text =
        "🛑   STOP CONTROL"

    status.Text =
        "●  ROBOT CONTROL ACTIVE"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            255,
            165
        )

    --==========================================================
    -- CAMERA LOOP
    --==========================================================

    table.insert(
        state.connections,

        RunService.RenderStepped:Connect(
            function()

                if not state.isControlling then
                    return
                end

                if not state.robotAnchor then
                    return
                end

                updateRobotCamera()

            end
        )
    )

    --==========================================================
    -- MOVEMENT LOOP
    --==========================================================

    table.insert(
        state.connections,

        RunService.Heartbeat:Connect(
            function(dt)

                if not state.isControlling then
                    return
                end

                local anchor =
                    state.robotAnchor

                if not anchor
                    or not anchor.Parent then
                    return
                end

                -- DEFAULT ROBLOX JOYSTICK
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

                    local target =
                        CFrame.new(
                            anchor.Position,
                            anchor.Position
                            + direction
                        )

                    anchor.CFrame =
                        anchor.CFrame:Lerp(
                            target,
                            math.clamp(
                                CONFIG.TurnSpeed
                                * dt,
                                0,
                                1
                            )
                        )

                    -- smooth movement

                    local newPosition =
                        anchor.Position
                        + direction
                        * CONFIG.MoveSpeed
                        * dt

                    anchor.CFrame =
                        CFrame.new(
                            newPosition,
                            newPosition
                            + direction
                        )

                end

                --================================================
                -- JUMP
                --================================================

                if state.jumpRequested then

                    state.jumpRequested =
                        false

                    local jumpHeight = 5.5

                    local startCF =
                        anchor.CFrame

                    local upCF =
                        startCF
                        + Vector3.new(
                            0,
                            jumpHeight,
                            0
                        )

                    local upTween =
                        TweenService:Create(
                            anchor,

                            TweenInfo.new(
                                0.22,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            ),

                            {
                                CFrame =
                                    upCF
                            }
                        )

                    upTween:Play()

                    task.delay(
                        0.22,

                        function()

                            if not anchor
                                or not anchor.Parent then
                                return
                            end

                            local downCF =
                                anchor.CFrame
                                - Vector3.new(
                                    0,
                                    jumpHeight,
                                    0
                                )

                            TweenService:Create(
                                anchor,

                                TweenInfo.new(
                                    0.30,
                                    Enum.EasingStyle.Quad,
                                    Enum.EasingDirection.In
                                ),

                                {
                                    CFrame =
                                        downCF
                                }
                            ):Play()

                        end
                    )

                end

                --================================================
                -- MOVE ALL ROBOT PARTS
                --================================================

                local anchorCF =
                    anchor.CFrame

                for slot, prop in pairs(
                    state.slotMap
                ) do

                    if prop
                        and prop.Parent then

                        local offset =
                            getScaledOffset(slot)

                        local targetCF =
                            anchorCF
                            * CFrame.new(
                                offset
                            )

                        -- client visual movement

                        prop.CFrame =
                            prop.CFrame:Lerp(
                                targetCF,
                                math.clamp(
                                    dt * 22,
                                    0,
                                    1
                                )
                            )

                    end

                end

            end
        )
    )

    --==========================================================
    -- DEFAULT ROBLOX JUMP BUTTON
    --==========================================================

    table.insert(
        state.connections,

        UserInputService.JumpRequest:Connect(
            function()

                if state.isControlling then

                    state.jumpRequested =
                        true

                end

            end
        )
    )

end

--==============================================================
-- STOP CONTROL
--==============================================================

local function stopControl()

    if not state.isControlling then
        return
    end

    state.isControlling = false

    state.jumpRequested = false

    clearConnections()

    if state.robotAnchor then

        state.robotAnchor:Destroy()

        state.robotAnchor = nil

    end

    -- Restore player

    humanoid.WalkSpeed =
        state.originalWalkSpeed

    humanoid.JumpPower =
        state.originalJumpPower

    humanoid.AutoRotate =
        state.originalAutoRotate

    hrp.Anchored = false

    -- Restore camera

    camera.CameraType =
        state.originalCamType
        or Enum.CameraType.Custom

    camera.CameraSubject =
        humanoid

    camera.FieldOfView = 70

    controlBtn.Text =
        "🎮   CONTROL ROBOT"

    status.Text =
        "●  Control released"

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

controlBtn.MouseButton1Click:Connect(function()

    if state.isControlling then

        stopControl()

    else

        startControl()

    end

end)

--==============================================================
-- RESET
--==============================================================

resetBtn.MouseButton1Click:Connect(function()

    if state.isControlling then
        stopControl()
    end

    state.isAssembled = false
    state.slotMap = {}

    local total =
        #state.props

    if total == 0 then

        state.props =
            scanProps()

        refreshList()

        total =
            #state.props

    end

    if total > 0 then

        local center =
            hrp.Position

        for i, prop in ipairs(
            state.props
        ) do

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

            local cf =
                CFrame.new(
                    position,
                    center
                )

            setPropCFrame(
                prop,
                cf
            )

            task.wait(0.08)

        end

    end

    status.Text =
        "●  Props reset"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            255,
            165
        )

    controlBtn.Text =
        "🎮   CONTROL ROBOT"

end)

--==============================================================
-- MINIMIZE
--==============================================================

local minimized = false

minBtn.MouseButton1Click:Connect(function()

    minimized =
        not minimized

    if minimized then

        body.Visible = false

        minBtn.Text = "+"

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
                        CONFIG.GuiWidth,
                        0,
                        48
                    )
            }
        ):Play()

    else

        body.Visible = true

        minBtn.Text = "—"

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
                        CONFIG.GuiWidth,
                        0,
                        CONFIG.GuiHeight
                    )
            }
        ):Play()

    end

end)

--==============================================================
-- CLOSE
--==============================================================

closeBtn.MouseButton1Click:Connect(function()

    if state.isControlling then
        stopControl()
    end

    gui:Destroy()

end)

--==============================================================
-- FLOATING MOBILE BUTTON
--==============================================================

local floating =
    Instance.new(
        "TextButton",
        gui
    )

floating.Name =
    "FloatingButton"

floating.Size =
    UDim2.new(
        0,
        48,
        0,
        48
    )

floating.Position =
    UDim2.new(
        1,
        -62,
        0.55,
        0
    )

floating.BackgroundColor3 =
    Color3.fromRGB(
        23,
        23,
        29
    )

floating.Text =
    "🎃"

floating.Font =
    Enum.Font.GothamBold

floating.TextSize = 20

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
    UDim.new(
        0,
        24
    )

local floatingStroke =
    Instance.new(
        "UIStroke",
        floating
    )

floatingStroke.Color =
    Color3.fromRGB(
        255,
        140,
        35
    )

floatingStroke.Thickness = 1.4

floatingStroke.Transparency = 0.25

--==============================================================
-- FLOATING BUTTON DRAG
--==============================================================

local floatingDragging = false
local floatingStart
local floatingPosition

floating.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            floatingDragging = true

            floatingStart =
                input.Position

            floatingPosition =
                floating.Position

            input.Changed:Connect(
                function()

                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        floatingDragging = false

                    end

                end
            )

        end

    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not floatingDragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            local delta =
                input.Position
                - floatingStart

            floating.Position =
                UDim2.new(

                    floatingPosition.X.Scale,

                    floatingPosition.X.Offset
                    + delta.X,

                    floatingPosition.Y.Scale,

                    floatingPosition.Y.Offset
                    + delta.Y
                )

        end

    end
)

--==============================================================
-- FLOATING BUTTON OPEN/CLOSE
--==============================================================

floating.MouseButton1Click:Connect(
    function()

        main.Visible =
            not main.Visible

    end
)

--==============================================================
-- CHARACTER RESPAWN
--==============================================================

player.CharacterAdded:Connect(
    function(newCharacter)

        if state.isControlling then
            stopControl()
        end

        task.wait(0.5)

        char =
            newCharacter

        hrp =
            char:WaitForChild(
                "HumanoidRootPart"
            )

        humanoid =
            char:WaitForChild(
                "Humanoid"
            )

    end
)

--==============================================================
-- INITIAL
--==============================================================

status.Text =
    "●  READY — RESCAN PROPS"

status.TextColor3 =
    Color3.fromRGB(
        120,
        255,
        165
    )

refreshList()

print(
    "🎃 MANI PUMPKIN ROBO V.1 LOADED"
)
