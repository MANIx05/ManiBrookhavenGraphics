--==============================================================
-- 🎃 MANI PUMPKIN ROBO V.1
-- Modern Dark GUI | PC + Mobile | Assemble & Control Robot
--==============================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--==============================================================
-- 🎨 CONFIG
--==============================================================
local CONFIG = {
    FolderPath = {"WorkspaceCom", "001_TrafficCones"}, -- WorkspaceCom > 001_TrafficCones
    AssembleOffset = {
        Head       = Vector3.new(0, 5.5, 0),
        Waist      = Vector3.new(0, 3.0, 0),
        RightHand  = Vector3.new(2.5, 3.5, 0),
        LeftHand   = Vector3.new(-2.5, 3.5, 0),
        RightLeg1  = Vector3.new(1.2, 1.5, 0),
        RightLeg2  = Vector3.new(1.2, 0.3, 0),
        RightLeg3  = Vector3.new(1.2, -0.9, 0),
        LeftLeg1   = Vector3.new(-1.2, 1.5, 0),
        LeftLeg2   = Vector3.new(-1.2, 0.3, 0),
        LeftLeg3   = Vector3.new(-1.2, -0.9, 0),
    },
    CameraOffset = Vector3.new(0, 8, 18),
    MoveSpeed = 40,
    JumpPower = 60,
    TurnSpeed = 6,
}

--==============================================================
-- 🖥️ GUI CREATION
--==============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MANI_PUMPKIN_ROBO_V1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN FRAME
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 460)
main.Position = UDim2.new(0, 20, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 140, 0)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = main

-- TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎃 MANI PUMPKIN ROBO V.1"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 160, 40)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -78, 0, 9)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- BODY CONTAINER
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, -24, 1, -70)
body.Position = UDim2.new(0, 12, 0, 58)
body.BackgroundTransparency = 1
body.Parent = main

-- STATUS LABEL
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 36)
status.Position = UDim2.new(0, 0, 0, 0)
status.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
status.Text = "⚡ Status: Idle"
status.Font = Enum.Font.GothamMedium
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(180, 220, 180)
status.Parent = body

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = status

-- PROP LIST PANEL
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 0, 140)
listFrame.Position = UDim2.new(0, 0, 0, 46)
listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = body

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 8)
listPad.PaddingLeft = UDim.new(0, 8)
listPad.PaddingRight = UDim.new(0, 8)
listPad.Parent = listFrame

-- HELPER: CREATE BUTTON
local function makeButton(name, color, textColor, yPos, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = textColor
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = textColor
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = btn

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.new(
                math.min(color.R + 0.1, 1),
                math.min(color.G + 0.1, 1),
                math.min(color.B + 0.1, 1)
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = color
        }):Play()
    end)

    return btn
end

-- BUTTONS
local spawnBtn    = makeButton("📦 Spawn Props",   Color3.fromRGB(35, 40, 60), Color3.fromRGB(120, 180, 255), 196, body)
local assembleBtn = makeButton("🤖 Assemble Robot", Color3.fromRGB(60, 40, 20), Color3.fromRGB(255, 180, 80),  250, body)
local controlBtn  = makeButton("🎮 Control Robot",  Color3.fromRGB(25, 55, 35), Color3.fromRGB(120, 255, 160), 304, body)
local resetBtn    = makeButton("♻️ Reset Robot",    Color3.fromRGB(60, 25, 30), Color3.fromRGB(255, 130, 130), 358, body)

-- MOBILE ADJUST TOGGLE (small floating button on right)
local adjustBtn = Instance.new("TextButton")
adjustBtn.Size = UDim2.new(0, 55, 0, 55)
adjustBtn.Position = UDim2.new(1, -75, 0.5, -27)
adjustBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
adjustBtn.Text = "⚙️"
adjustBtn.Font = Enum.Font.GothamBold
adjustBtn.TextSize = 22
adjustBtn.TextColor3 = Color3.fromRGB(255, 160, 40)
adjustBtn.BorderSizePixel = 0
adjustBtn.Active = true
adjustBtn.Draggable = true
adjustBtn.Parent = gui

local adjustCorner = Instance.new("UICorner")
adjustCorner.CornerRadius = UDim.new(0, 28)
adjustCorner.Parent = adjustBtn

local adjustStroke = Instance.new("UIStroke")
adjustStroke.Color = Color3.fromRGB(255, 140, 0)
adjustStroke.Thickness = 1.5
adjustStroke.Transparency = 0.3
adjustStroke.Parent = adjustBtn

adjustBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

--==============================================================
-- 🔧 STATE
--==============================================================
local state = {
    props = {},
    robotParts = {},
    isAssembled = false,
    isControlling = false,
    moveDir = Vector3.new(0, 0, 0),
    jumpRequested = false,
    bodyGyro = nil,
    alignOrient = nil,
    robotModel = nil,
    camera = workspace.CurrentCamera,
    originalCameraType = nil,
    connections = {},
}

--==============================================================
-- 📋 GET PROPS
--==============================================================
local function getFolder()
    local cur = workspace
    for _, name in ipairs(CONFIG.FolderPath) do
        cur = cur:FindFirstChild(name)
        if not cur then return nil end
    end
    return cur
end

local function scanProps()
    local folder = getFolder()
    if not folder then
        warn("❌ Props folder not found: " .. table.concat(CONFIG.FolderPath, " > "))
        return {}
    end

    local found = {}
    for _, v in pairs(folder:GetChildren()) do
        if v:IsA("BasePart") and string.find(v.Name, player.Name, 1, true) then
            table.insert(found, v)
        end
    end
    return found
end

local function refreshList()
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end

    local count = #state.props
    if count == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -16, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "No props found for " .. player.Name
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 12
        empty.TextColor3 = Color3.fromRGB(140, 140, 150)
        empty.Parent = listFrame
        return
    end

    for i, prop in ipairs(state.props) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 28)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        row.BorderSizePixel = 0
        row.Parent = listFrame

        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 6)
        rc.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("%02d.  %s", i, prop.Name)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row
    end
end

--==============================================================
-- 📦 SPAWN PROPS
--==============================================================
spawnBtn.MouseButton1Click:Connect(function()
    status.Text = "📦 Scanning props..."
    status.TextColor3 = Color3.fromRGB(255, 200, 100)
    task.wait(0.2)

    state.props = scanProps()
    refreshList()

    if #state.props == 0 then
        status.Text = "❌ No props found!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    status.Text = string.format("✅ Found %d props", #state.props)
    status.TextColor3 = Color3.fromRGB(120, 255, 160)
end)

--==============================================================
-- 🤖 ASSEMBLE ROBOT
--==============================================================
local function classifyProp(name)
    local n = string.lower(name)
    if n:find("head") then return "Head"
    elseif n:find("waist") then return "Waist"
    elseif n:find("rhand") or n:find("right") and n:find("hand") then return "RightHand"
    elseif n:find("lhand") or n:find("left") and n:find("hand") then return "LeftHand"
    elseif n:find("rleg1") then return "RightLeg1"
    elseif n:find("rleg2") then return "RightLeg2"
    elseif n:find("rleg3") then return "RightLeg3"
    elseif n:find("lleg1") then return "LeftLeg1"
    elseif n:find("lleg2") then return "LeftLeg2"
    elseif n:find("lleg3") then return "LeftLeg3"
    else return nil end
end

local function getBasePosition()
    local base = hrp.Position + hrp.CFrame.LookVector * 8
    return Vector3.new(base.X, hrp.Position.Y, base.Z)
end

local function setPropCFrame(prop, cf)
    local setCF = prop:FindFirstChild("SetCurrentCFrame")
    if setCF and setCF:IsA("RemoteFunction") then
        setCF:InvokeServer(cf)
    else
        prop.CFrame = cf
    end
end

local function assembleRobot()
    if #state.props == 0 then
        state.props = scanProps()
        refreshList()
    end

    if #state.props == 0 then
        status.Text = "❌ No props!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    status.Text = "🤖 Assembling..."
    status.TextColor3 = Color3.fromRGB(255, 200, 100)

    local base = getBasePosition()
    state.robotParts = {}

    -- Fallback: if no name match, use index-based ordering
    local sorted = table.clone(state.props)
    table.sort(sorted, function(a, b) return a.Name < b.Name end)

    local fallbackOrder = {
        "Head", "Waist", "RightHand", "LeftHand",
        "RightLeg1", "RightLeg2", "RightLeg3",
        "LeftLeg1", "LeftLeg2", "LeftLeg3",
    }

    local usedFallback = 0
    for _, prop in ipairs(sorted) do
        local part = classifyProp(prop.Name)

        if not part then
            usedFallback += 1
            part = fallbackOrder[usedFallback] or "Extra"
        end

        local offset = CONFIG.AssembleOffset[part] or Vector3.new(0, 0, 0)
        local cf = CFrame.new(base + offset)

        setPropCFrame(prop, cf)
        state.robotParts[part] = prop

        task.wait(0.12)
    end

    state.isAssembled = true
    status.Text = "✅ Robot assembled!"
    status.TextColor3 = Color3.fromRGB(120, 255, 160)
end

assembleBtn.MouseButton1Click:Connect(function()
    if state.isControlling then
        status.Text = "⚠️ Release control first!"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end
    assembleRobot()
end)

--==============================================================
-- 🎮 CONTROL ROBOT
--==============================================================
local function buildRobotModel()
    if next(state.robotParts) == nil then return nil end

    -- Compute bounding center from all parts
    local sum = Vector3.new(0, 0, 0)
    local count = 0
    for _, p in pairs(state.robotParts) do
        if p and p.Parent then
            sum += p.Position
            count += 1
        end
    end
    if count == 0 then return nil end

    local center = sum / count
    return center
end

local function clearConnections()
    for _, c in ipairs(state.connections) do
        if c.Disconnect then c:Disconnect() end
    end
    state.connections = {}
end

local function startControl()
    if not state.isAssembled then
        status.Text = "⚠️ Assemble robot first!"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local center = buildRobotModel()
    if not center then
        status.Text = "❌ Robot parts missing!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    state.isControlling = true
    status.Text = "🎮 Controlling robot..."
    status.TextColor3 = Color3.fromRGB(120, 255, 160)

    -- Freeze player character
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    hrp.Anchored = true

    -- Store original camera
    state.originalCameraType = state.camera.CameraType

    -- Move HRP under robot so camera follows
    -- We use a hidden anchor part for movement
    local anchor = Instance.new("Part")
    anchor.Name = "RobotAnchor"
    anchor.Size = Vector3.new(2, 2, 2)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = true
    anchor.CFrame = CFrame.new(center)
    anchor.Parent = workspace
    state.robotModel = anchor

    -- Camera setup
    state.camera.CameraType = Enum.CameraType.Scriptable
    state.camera.CameraSubject = anchor
    state.camera.FieldOfView = 75

    -- Camera follow loop
    local camConn = RunService.RenderStepped:Connect(function(dt)
        if not state.robotModel or not state.robotModel.Parent then return end
        local a = state.robotModel
        local camPos = a.Position + a.CFrame.LookVector * -CONFIG.CameraOffset.Z + Vector3.new(0, CONFIG.CameraOffset.Y, 0)
        state.camera.CFrame = CFrame.new(camPos, a.Position + Vector3.new(0, 3, 0))
    end)
    table.insert(state.connections, camConn)

    -- Movement loop
    local lastDir = Vector3.new(0, 0, 0)
    local moveConn = RunService.Heartbeat:Connect(function(dt)
        if not state.isControlling then return end
        if not state.robotModel or not state.robotModel.Parent then return end

            -- Gather input from joystick / keyboard
            local moveVector = humanoid.MoveDirection
            local dir = Vector3.new(moveVector.X, 0, moveVector.Z)

            -- Rotate robot to face movement direction
            if dir.Magnitude > 0.05 then
                lastDir = dir.Unit
                local target = CFrame.new(state.robotModel.Position, state.robotModel.Position + lastDir)
                state.robotModel.CFrame = state.robotModel.CFrame:Lerp(target, CONFIG.TurnSpeed * dt)

                -- Move forward
                local newPos = state.robotModel.Position + lastDir * CONFIG.MoveSpeed * dt
                state.robotModel.CFrame = CFrame.new(newPos, newPos + lastDir)
            end

        -- Jump
        if state.jumpRequested then
            state.jumpRequested = false
            local jumpTween = TweenService:Create(state.robotModel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0.1), {
                Position = state.robotModel.Position + Vector3.new(0, 6, 0)
            })
            jumpTween:Play()
        end

        -- Move all robot parts relative to anchor
        if state.robotParts then
            local anchorCF = state.robotModel.CFrame
            for part, prop in pairs(state.robotParts) do
                if prop and prop.Parent then
                    local offset = CONFIG.AssembleOffset[part] or Vector3.new(0, 0, 0)
                    local targetCF = anchorCF * CFrame.new(offset)
                    -- Smooth follow
                    prop.CFrame = prop.CFrame:Lerp(targetCF, math.clamp(dt * 20, 0, 1))
                end
            end
        end
    end)
    table.insert(state.connections, moveConn)

    -- Jump detection via Humanoid.Jumping
    local jumpConn = humanoid.Jumping:Connect(function(active)
        if active and state.isControlling then
            state.jumpRequested = true
        end
    end)
    table.insert(state.connections, jumpConn)

    -- Restore character control when unanchored
    -- Handle stop via button
    controlBtn.Text = "🛑 Stop Control"
end

local function stopControl()
    if not state.isControlling then return end

    state.isControlling = false
    clearConnections()

    -- Destroy anchor
    if state.robotModel then
        state.robotModel:Destroy()
        state.robotModel = nil
    end

    -- Restore player
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    hrp.Anchored = false

    -- Restore camera
    state.camera.CameraType = state.originalCameraType or Enum.CameraType.Custom
    state.camera.CameraSubject = humanoid
    state.camera.FieldOfView = 70

    status.Text = "♻️ Control released"
    status.TextColor3 = Color3.fromRGB(180, 220, 180)
    controlBtn.Text = "🎮 Control Robot"
end

controlBtn.MouseButton1Click:Connect(function()
    if state.isControlling then
        stopControl()
    else
        startControl()
    end
end)

--==============================================================
-- ♻️ RESET ROBOT
--==============================================================
resetBtn.MouseButton1Click:Connect(function()
    if state.isControlling then stopControl() end

    state.isAssembled = false
    state.robotParts = {}

    -- Re-arrange in circle (from original script)
    local center = hrp.Position
    local radius = 12
    local total = #state.props

    if total > 0 then
        for i, prop in ipairs(state.props) do
            local angle = (2 * math.pi / total) * i
            local newPos = center + Vector3.new(
                math.cos(angle) * radius,
                0,
                math.sin(angle) * radius
            )
            local lookAt = CFrame.new(newPos, center)
            setPropCFrame(prop, lookAt)
            task.wait(0.15)
        end
    end

    status.Text = "✅ Reset complete"
    status.TextColor3 = Color3.fromRGB(120, 255, 160)
    controlBtn.Text = "🎮 Control Robot"
end)

--==============================================================
-- 🪟 MINIMIZE / CLOSE
--==============================================================
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        body.Visible = false
        minBtn.Text = "+"
        TweenService:Create(main, TweenInfo.new(0.25), {
            Size = UDim2.new(0, 320, 0, 50)
        }):Play()
    else
        body.Visible = true
        minBtn.Text = "—"
        TweenService:Create(main, TweenInfo.new(0.25), {
            Size = UDim2.new(0, 320, 0, 460)
        }):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if state.isControlling then stopControl() end
    gui:Destroy()
end)

--==============================================================
-- 📱 MOBILE JUMP DETECTION
--==============================================================
-- Roblox mobile jump button triggers Humanoid.Jumping automatically.
-- Our jumpConn already listens to it.

--==============================================================
-- 🚪 CLEANUP ON RESPAWN
--==============================================================
player.CharacterAdded:Connect(function(newChar)
    if state.isControlling then
        stopControl()
    end
    task.wait(0.5)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

--==============================================================
-- ✅ INIT
--==============================================================
status.Text = "✅ Loaded — Press Spawn Props"
status.TextColor3 = Color3.fromRGB(120, 255, 160)
print("🎃 MANI PUMPKIN ROBO V.1 loaded")
