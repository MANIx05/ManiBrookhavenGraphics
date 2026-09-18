--==============================================================
-- 🎃 MANI PUMPKIN ROBO V.1  (Spawn-Order Fix + Height Control)
-- PC + Mobile | Modern Dark GUI
--==============================================================

repeat task.wait() until game:IsLoaded()

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")

local player   = Players.LocalPlayer
local char     = player.Character or player.CharacterAdded:Wait()
local hrp      = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--==============================================================
-- 🎨 CONFIG
--==============================================================
local CONFIG = {
    FolderPath    = {"WorkspaceCom", "001_TrafficCones"},
    CameraOffset  = Vector3.new(0, 8, 18),
    MoveSpeed     = 40,
    TurnSpeed     = 6,
    HeightMin     = 0.5,
    HeightMax     = 3.0,
    HeightStep    = 0.25,
    HeightDefault = 1.0,
}

-- Base offsets (at height scale = 1.0)
local BASE_OFFSETS = {
    Head      = Vector3.new( 0,   5.5,  0),
    Waist     = Vector3.new( 0,   3.0,  0),
    RightHand = Vector3.new( 2.5, 3.5,  0),
    LeftHand  = Vector3.new(-2.5, 3.5,  0),
    RightLeg1 = Vector3.new( 1.2, 1.5,  0),
    RightLeg2 = Vector3.new( 1.2, 0.3,  0),
    RightLeg3 = Vector3.new( 1.2,-0.9,  0),
    LeftLeg1  = Vector3.new(-1.2, 1.5,  0),
    LeftLeg2  = Vector3.new(-1.2, 0.3,  0),
    LeftLeg3  = Vector3.new(-1.2,-0.9,  0),
}

-- Order of assembly (index -> slot name)
local SPAWN_ORDER = {
    "Head", "Waist", "RightHand", "LeftHand",
    "RightLeg1", "RightLeg2", "RightLeg3",
    "LeftLeg1", "LeftLeg2", "LeftLeg3",
}

--==============================================================
-- 🖥️ GUI
--==============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MANI_PUMPKIN_ROBO_V1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 330, 0, 560)
main.Position = UDim2.new(0, 20, 0.5, -280)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color = Color3.fromRGB(255, 140, 0)
mStroke.Thickness = 1.5
mStroke.Transparency = 0.4

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local tFix = Instance.new("Frame", titleBar)
tFix.Size = UDim2.new(1, 0, 0, 20)
tFix.Position = UDim2.new(0, 0, 1, -20)
tFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tFix.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎃 MANI PUMPKIN ROBO V.1"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255, 160, 40)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -78, 0, 9)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
minBtn.BorderSizePixel = 0
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Close
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Body
local body = Instance.new("Frame", main)
body.Name = "Body"
body.Size = UDim2.new(1, -24, 1, -70)
body.Position = UDim2.new(0, 12, 0, 58)
body.BackgroundTransparency = 1

-- Status
local status = Instance.new("TextLabel", body)
status.Size = UDim2.new(1, 0, 0, 34)
status.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
status.Text = "⚡ Status: Idle"
status.Font = Enum.Font.GothamMedium
status.TextSize = 12
status.TextColor3 = Color3.fromRGB(180, 220, 180)
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 8)

-- Prop list
local listFrame = Instance.new("ScrollingFrame", body)
listFrame.Size = UDim2.new(1, 0, 0, 120)
listFrame.Position = UDim2.new(0, 0, 0, 42)
listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.CanvasSize = UDim2.new()
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local listPad = Instance.new("UIPadding", listFrame)
listPad.PaddingTop    = UDim.new(0, 6)
listPad.PaddingLeft   = UDim.new(0, 6)
listPad.PaddingRight  = UDim.new(0, 6)
listPad.PaddingBottom = UDim.new(0, 6)

-- Button maker
local function makeBtn(text, bg, fg, y, h)
    local b = Instance.new("TextButton", body)
    b.Size = UDim2.new(1, 0, 0, h or 42)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = bg
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = fg
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", b)
    s.Color = fg
    s.Thickness = 1
    s.Transparency = 0.7
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.new(
                math.min(bg.R + 0.08, 1),
                math.min(bg.G + 0.08, 1),
                math.min(bg.B + 0.08, 1))
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = bg }):Play()
    end)
    return b
end

-- Buttons (Y positions stacked)
local spawnBtn    = makeBtn("📦 Rescan Props",     Color3.fromRGB(35, 40, 60), Color3.fromRGB(120, 180, 255), 170)
local assembleBtn = makeBtn("🤖 Assemble Robot",   Color3.fromRGB(60, 40, 20), Color3.fromRGB(255, 180, 80),  218)
local controlBtn  = makeBtn("🎮 Control Robot",    Color3.fromRGB(25, 55, 35), Color3.fromRGB(120, 255, 160), 266)
local resetBtn    = makeBtn("♻️ Reset (Circle)",   Color3.fromRGB(60, 25, 30), Color3.fromRGB(255, 130, 130), 314)

-- Height control panel
local heightPanel = Instance.new("Frame", body)
heightPanel.Size = UDim2.new(1, 0, 0, 60)
heightPanel.Position = UDim2.new(0, 0, 0, 366)
heightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
heightPanel.BorderSizePixel = 0
Instance.new("UICorner", heightPanel).CornerRadius = UDim.new(0, 10)

local hLabel = Instance.new("TextLabel", heightPanel)
hLabel.Size = UDim2.new(1, -20, 0, 20)
hLabel.Position = UDim2.new(0, 10, 0, 4)
hLabel.BackgroundTransparency = 1
hLabel.Text = "📏 Robot Height Scale"
hLabel.Font = Enum.Font.GothamBold
hLabel.TextSize = 11
hLabel.TextColor3 = Color3.fromRGB(255, 200, 120)
hLabel.TextXAlignment = Enum.TextXAlignment.Left

local minusBtn = Instance.new("TextButton", heightPanel)
minusBtn.Size = UDim2.new(0, 55, 0, 30)
minusBtn.Position = UDim2.new(0, 10, 0, 24)
minusBtn.BackgroundColor3 = Color3.fromRGB(55, 25, 25)
minusBtn.Text = "➖"
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 16
minusBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
minusBtn.BorderSizePixel = 0
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

local plusBtn = Instance.new("TextButton", heightPanel)
plusBtn.Size = UDim2.new(0, 55, 0, 30)
plusBtn.Position = UDim2.new(1, -65, 0, 24)
plusBtn.BackgroundColor3 = Color3.fromRGB(25, 55, 35)
plusBtn.Text = "➕"
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 16
plusBtn.TextColor3 = Color3.fromRGB(120, 255, 160)
plusBtn.BorderSizePixel = 0
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

local heightValue = Instance.new("TextLabel", heightPanel)
heightValue.Size = UDim2.new(1, -140, 0, 30)
heightValue.Position = UDim2.new(0, 70, 0, 24)
heightValue.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
heightValue.Text = "1.00x"
heightValue.Font = Enum.Font.GothamBold
heightValue.TextSize = 14
heightValue.TextColor3 = Color3.fromRGB(255, 220, 150)
Instance.new("UICorner", heightValue).CornerRadius = UDim.new(0, 6)

-- Floating gear (mobile adjust)
local adjustBtn = Instance.new("TextButton", gui)
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
Instance.new("UICorner", adjustBtn).CornerRadius = UDim.new(0, 28)
local aStroke = Instance.new("UIStroke", adjustBtn)
aStroke.Color = Color3.fromRGB(255, 140, 0)
aStroke.Thickness = 1.5
aStroke.Transparency = 0.3

adjustBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

--==============================================================
-- 🔧 STATE
--==============================================================
local state = {
    props           = {},       -- ordered list of props (spawn order = index)
    slotMap         = {},       -- slotName -> prop
    isAssembled     = false,
    isControlling   = false,
    robotAnchor     = nil,
    jumpRequested   = false,
    heightScale     = CONFIG.HeightDefault,
    connections     = {},
    originalCamType = nil,
}

local camera = workspace.CurrentCamera

--==============================================================
-- 📋 PROPS
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
    if not folder then return {} end
    local found = {}
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("BasePart") and string.find(v.Name, player.Name, 1, true) then
            table.insert(found, v)
        end
    end
    -- Sort by name so order is stable (prop_1, prop_2...)
    table.sort(found, function(a, b) return a.Name < b.Name end)
    return found
end

local function refreshList()
    for _, c in ipairs(listFrame:GetChildren()) do
        if c:IsA("TextLabel") or c:IsA("Frame") then c:Destroy() end
    end

    if #state.props == 0 then
        local e = Instance.new("TextLabel", listFrame)
        e.Size = UDim2.new(1, -16, 0, 40)
        e.BackgroundTransparency = 1
        e.Text = "No props found for " .. player.Name
        e.Font = Enum.Font.Gotham
        e.TextSize = 12
        e.TextColor3 = Color3.fromRGB(140, 140, 150)
        return
    end

    for i, prop in ipairs(state.props) do
        local slot = SPAWN_ORDER[i] or "Extra"
        local row = Instance.new("Frame", listFrame)
        row.Size = UDim2.new(1, -8, 0, 26)
        row.BackgroundColor3 = (slot == "Extra")
            and Color3.fromRGB(45, 30, 30)
            or  Color3.fromRGB(30, 30, 38)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("%02d. [%s]  %s", i, slot, prop.Name)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = (slot == "Extra")
            and Color3.fromRGB(255, 140, 140)
            or  Color3.fromRGB(200, 200, 210)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
    end
end

spawnBtn.MouseButton1Click:Connect(function()
    status.Text = "📦 Scanning props..."
    status.TextColor3 = Color3.fromRGB(255, 200, 100)
    task.wait(0.1)
    state.props = scanProps()
    refreshList()
    if #state.props == 0 then
        status.Text = "❌ No props found!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        status.Text = string.format("✅ Found %d props", #state.props)
        status.TextColor3 = Color3.fromRGB(120, 255, 160)
    end
end)

--==============================================================
-- 🤖 ASSEMBLE (by spawn order)
--==============================================================
local function setPropCFrame(prop, cf)
    local setCF = prop:FindFirstChild("SetCurrentCFrame")
    if setCF and setCF:IsA("RemoteFunction") then
        setCF:InvokeServer(cf)
    else
        prop.CFrame = cf
    end
end

local function getScaledOffset(slot)
    local base = BASE_OFFSETS[slot]
    if not base then return Vector3.new() end
    -- scale Y only (height), keep X same for width integrity
    return Vector3.new(base.X, base.Y * state.heightScale, base.Z)
end

local function getBasePosition()
    local b = hrp.Position + hrp.CFrame.LookVector * 8
    return Vector3.new(b.X, hrp.Position.Y, b.Z)
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
    state.slotMap = {}

    for i, prop in ipairs(state.props) do
        local slot = SPAWN_ORDER[i]
        if slot then
            local off = getScaledOffset(slot)
            local cf  = CFrame.new(base + off)
            setPropCFrame(prop, cf)
            state.slotMap[slot] = prop
        else
            -- Extra props: place off to the side
            local off = Vector3.new(4, 0, (i - 10) * 2)
            setPropCFrame(prop, CFrame.new(base + off))
        end
        task.wait(0.1)
    end

    state.isAssembled = true
    status.Text = string.format("✅ Assembled (H: %.2fx)", state.heightScale)
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
-- 📏 HEIGHT +/- (rebuild live)
--==============================================================
local function updateHeightLabel()
    heightValue.Text = string.format("%.2fx", state.heightScale)
end

local function rebuildHeights()
    if not state.isAssembled then return end
    -- If controlling, just update live (parts follow anchor)
    if state.isControlling then return end
    if next(state.slotMap) == nil then return end

    -- Compute new base from current robot center
    local sum, count = Vector3.new(), 0
    for _, p in pairs(state.slotMap) do
        if p and p.Parent then
            sum += p.Position
            count += 1
        end
    end
    if count == 0 then return end

    -- Use the ORIGINAL base position (feet at Y=0) = waist Y - 3*scale
    local waistPart = state.slotMap["Waist"]
    local baseY = waistPart and (waistPart.Position.Y - BASE_OFFSETS.Waist.Y * state.heightScale)
                  or hrp.Position.Y

    local centerXZ = Vector3.new(sum.X / count, 0, sum.Z / count)
    local base = Vector3.new(centerXZ.X, baseY, centerXZ.Z)

    for slot, prop in pairs(state.slotMap) do
        if prop and prop.Parent then
            local off = getScaledOffset(slot)
            setPropCFrame(prop, CFrame.new(base + off))
        end
    end
end

plusBtn.MouseButton1Click:Connect(function()
    if state.isControlling then
        status.Text = "⚠️ Stop control to change height"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end
    state.heightScale = math.min(state.heightScale + CONFIG.HeightStep, CONFIG.HeightMax)
    updateHeightLabel()
    rebuildHeights()
    status.Text = string.format("📏 Height: %.2fx", state.heightScale)
    status.TextColor3 = Color3.fromRGB(255, 220, 150)
end)

minusBtn.MouseButton1Click:Connect(function()
    if state.isControlling then
        status.Text = "⚠️ Stop control to change height"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end
    state.heightScale = math.max(state.heightScale - CONFIG.HeightStep, CONFIG.HeightMin)
    updateHeightLabel()
    rebuildHeights()
    status.Text = string.format("📏 Height: %.2fx", state.heightScale)
    status.TextColor3 = Color3.fromRGB(255, 220, 150)
end)

updateHeightLabel()

--==============================================================
-- 🎮 CONTROL ROBOT
--==============================================================
local function clearConnections()
    for _, c in ipairs(state.connections) do
        if c.Disconnect then c:Disconnect() end
    end
    state.connections = {}
end

local function startControl()
    if not state.isAssembled or next(state.slotMap) == nil then
        status.Text = "⚠️ Assemble robot first!"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    -- Compute robot center
    local sum, count = Vector3.new(), 0
    for _, p in pairs(state.slotMap) do
        if p and p.Parent then sum += p.Position; count += 1 end
    end
    if count == 0 then
        status.Text = "❌ Robot parts missing!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    local center = sum / count

    state.isControlling = true
    status.Text = "🎮 Controlling robot..."
    status.TextColor3 = Color3.fromRGB(120, 255, 160)
    controlBtn.Text = "🛑 Stop Control"

    -- Freeze player character
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    hrp.Anchored = true

    state.originalCamType = camera.CameraType

    -- Hidden anchor
    local anchor = Instance.new("Part")
    anchor.Name = "RobotAnchor"
    anchor.Size = Vector3.new(2, 2, 2)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = true
    anchor.CFrame = CFrame.new(center)
    anchor.Parent = workspace
    state.robotAnchor = anchor

    -- Camera
    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = 75

    -- Camera follow
    table.insert(state.connections, RunService.RenderStepped:Connect(function()
        if not state.robotAnchor or not state.robotAnchor.Parent then return end
        local a = state.robotAnchor
        local camPos = a.Position + a.CFrame.LookVector * -CONFIG.CameraOffset.Z + Vector3.new(0, CONFIG.CameraOffset.Y, 0)
        camera.CFrame = CFrame.new(camPos, a.Position + Vector3.new(0, 3 * state.heightScale, 0))
    end))

    -- Movement
    local lastDir = Vector3.new(0, 0, 1)
    table.insert(state.connections, RunService.Heartbeat:Connect(function(dt)
        if not state.isControlling then return end
        if not state.robotAnchor or not state.robotAnchor.Parent then return end

        local mv = humanoid.MoveDirection
        local dir = Vector3.new(mv.X, 0, mv.Z)

        if dir.Magnitude > 0.05 then
            lastDir = dir.Unit
            local target = CFrame.new(state.robotAnchor.Position, state.robotAnchor.Position + lastDir)
            state.robotAnchor.CFrame = state.robotAnchor.CFrame:Lerp(target, math.clamp(CONFIG.TurnSpeed * dt, 0, 1))
            local newPos = state.robotAnchor.Position + lastDir * CONFIG.MoveSpeed * dt
            state.robotAnchor.CFrame = CFrame.new(newPos, newPos + lastDir)
        end

        if state.jumpRequested then
            state.jumpRequested = false
            TweenService:Create(state.robotAnchor, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0.1), {
                Position = state.robotAnchor.Position + Vector3.new(0, 6, 0)
            }):Play()
        end

        -- Move parts relative to anchor
        local aCF = state.robotAnchor.CFrame
        for slot, prop in pairs(state.slotMap) do
            if prop and prop.Parent then
                local off = getScaledOffset(slot)
                local targetCF = aCF * CFrame.new(off)
                prop.CFrame = prop.CFrame:Lerp(targetCF, math.clamp(dt * 20, 0, 1))
            end
        end
    end))

    table.insert(state.connections, humanoid.Jumping:Connect(function(active)
        if active and state.isControlling then
            state.jumpRequested = true
        end
    end))
end

local function stopControl()
    if not state.isControlling then return end
    state.isControlling = false
    clearConnections()

    if state.robotAnchor then
        state.robotAnchor:Destroy()
        state.robotAnchor = nil
    end

    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    hrp.Anchored = false

    camera.CameraType = state.originalCamType or Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    camera.FieldOfView = 70

    status.Text = "♻️ Control released"
    status.TextColor3 = Color3.fromRGB(180, 220, 180)
    controlBtn.Text = "🎮 Control Robot"
end

controlBtn.MouseButton1Click:Connect(function()
    if state.isControlling then stopControl() else startControl() end
end)

--==============================================================
-- ♻️ RESET (circle)
--==============================================================
resetBtn.MouseButton1Click:Connect(function()
    if state.isControlling then stopControl() end
    state.isAssembled = false
    state.slotMap = {}

    local center = hrp.Position
    local radius = 12
    local total = #state.props
    if total > 0 then
        for i, prop in ipairs(state.props) do
            local a = (2 * math.pi / total) * i
            local p = center + Vector3.new(math.cos(a) * radius, 0, math.sin(a) * radius)
            setPropCFrame(prop, CFrame.new(p, center))
            task.wait(0.12)
        end
    end

    status.Text = "✅ Reset complete"
    status.TextColor3 = Color3.fromRGB(120, 255, 160)
    controlBtn.Text = "🎮 Control Robot"
end)

--==============================================================
-- 🪟 MIN / CLOSE
--==============================================================
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        body.Visible = false
        minBtn.Text = "+"
        TweenService:Create(main, TweenInfo.new(0.25), { Size = UDim2.new(0, 330, 0, 50) }):Play()
    else
        body.Visible = true
        minBtn.Text = "—"
        TweenService:Create(main, TweenInfo.new(0.25), { Size = UDim2.new(0, 330, 0, 560) }):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if state.isControlling then stopControl() end
    gui:Destroy()
end)

--==============================================================
-- 🚪 RESPAWN CLEANUP
--==============================================================
player.CharacterAdded:Connect(function(nc)
    if state.isControlling then stopControl() end
    task.wait(0.5)
    char = nc
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

--==============================================================
-- ✅ INIT
--==============================================================
status.Text = "✅ Loaded — Press Rescan Props"
status.TextColor3 = Color3.fromRGB(120, 255, 160)
print("🎃 MANI PUMPKIN ROBO V.1 (fixed) loaded")
