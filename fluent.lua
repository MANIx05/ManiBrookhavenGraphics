--========================================================
-- 🎃 MANI PUMPKIN ROBO V.3.6
-- Player STAYS VISIBLE | Control transfers to robot
-- LIVE feature changes | Own camera + own input
--========================================================

repeat task.wait() until game:IsLoaded()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local hrp       = character:WaitForChild("HumanoidRootPart")
local camera    = workspace.CurrentCamera

--========================================================
-- FOLDER
--========================================================
local propsFolder =
    workspace:FindFirstChild("WorkspaceCom")
    and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")

if not propsFolder then
    warn("❌ WorkspaceCom > 001_TrafficCones not found")
    return
end

--========================================================
-- SLOTS
--========================================================
local SLOTS = {
    [1]="Head",[2]="Waist",[3]="Right Hand",[4]="Left Hand",
    [5]="Right Leg 1",[6]="Right Leg 2",[7]="Right Leg 3",
    [8]="Left Leg 1",[9]="Left Leg 2",[10]="Left Leg 3",
}

--========================================================
-- BASE OFFSETS
--========================================================
local BASE_OFFSETS = {
    Head           = Vector3.new( 0,    7.9, 0),
    Waist          = Vector3.new( 0,    4.6, 0),
    ["Right Hand"] = Vector3.new( 3.0,  4.9, 0),
    ["Left Hand"]  = Vector3.new(-3.0,  4.9, 0),
    ["Right Leg 1"]= Vector3.new( 1.45, 2.7, 0),
    ["Right Leg 2"]= Vector3.new( 1.45, 1.35,0),
    ["Right Leg 3"]= Vector3.new( 1.45, 0,   0),
    ["Left Leg 1"] = Vector3.new(-1.45, 2.7, 0),
    ["Left Leg 2"] = Vector3.new(-1.45, 1.35,0),
    ["Left Leg 3"] = Vector3.new(-1.45, 0,   0),
}

local PART_CORRECTION = {
    ["Head"]       = CFrame.identity,
    ["Waist"]      = CFrame.Angles(0, math.rad(180), 0),
    ["Right Hand"] = CFrame.Angles(0, math.rad(180), 0),
    ["Left Hand"]  = CFrame.Angles(0, math.rad(180), 0),
}

local HIP_Y = 2.7

--========================================================
-- SETTINGS (LIVE — editable anytime)
--========================================================
local robotHeight    = 1
local propDistance   = 1
local walkSpeed      = 28
local jumpPower      = 55
local controlEnabled = false
local headFollowCam  = true

local registeredProps = {}
local robotCenter, robotRotation, robotAnchor = nil, nil, nil
local movementConnection, renderConnection = nil, nil

local animClock, moveAmount = 0, 0
local jumpState, jumpVelocity, verticalOffset = "Ground", 0, 0
local ANIMATION_RATE = 1/30
local animationAccumulator = 0

--========================================================
-- INPUT (keyboard state — fallback)
--========================================================
local keys = {W=false, A=false, S=false, D=false}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then keys.W = true end
    if input.KeyCode == Enum.KeyCode.A then keys.A = true end
    if input.KeyCode == Enum.KeyCode.S then keys.S = true end
    if input.KeyCode == Enum.KeyCode.D then keys.D = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false end
    if input.KeyCode == Enum.KeyCode.A then keys.A = false end
    if input.KeyCode == Enum.KeyCode.S then keys.S = false end
    if input.KeyCode == Enum.KeyCode.D then keys.D = false end
end)

-- PlayerModule for mobile joystick
local Controls = nil

local function setupControls()
    local ok, pm = pcall(function()
        return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10))
    end)
    if ok and pm then
        local ok2, c = pcall(function() return pm:GetControls() end)
        if ok2 then Controls = c end
    end
end

setupControls()

-- Read mobile thumbstick directly (fallback if PlayerModule fails)
local function getMobileThumbstick()
    local touchGui = player:FindFirstChild("PlayerGui")
    if not touchGui then return Vector3.zero end
    touchGui = touchGui:FindFirstChild("TouchGui")
    if not touchGui then return Vector3.zero end
    local frame = touchGui:FindFirstChild("TouchControlFrame")
    if not frame then return Vector3.zero end
    local stick = frame:FindFirstChild("Thumbstick")
    if not stick then return Vector3.zero end
    local knob = stick:FindFirstChild("Thumbstick")
    if not knob then return Vector3.zero end

    local center = stick.AbsolutePosition + stick.AbsoluteSize/2
    local pos    = knob.AbsolutePosition + knob.AbsoluteSize/2
    local delta  = pos - center
    local radius = stick.AbsoluteSize.X / 2
    return Vector3.new(delta.X / radius, 0, -delta.Y / radius)
end

local function getInputVector()
    -- Try PlayerModule
    if Controls then
        local ok, mv = pcall(function() return Controls:GetMoveVector() end)
        if ok and mv and mv.Magnitude > 0.05 then
            return mv
        end
    end

    -- Try mobile thumbstick directly
    local mobile = getMobileThumbstick()
    if mobile.Magnitude > 0.05 then
        return Vector3.new(mobile.X, 0, mobile.Z)
    end

    -- Keyboard fallback
    local v = Vector3.zero
    if keys.W then v = v + Vector3.new(0, 0, -1) end
    if keys.S then v = v + Vector3.new(0, 0, 1) end
    if keys.A then v = v + Vector3.new(-1, 0, 0) end
    if keys.D then v = v + Vector3.new(1, 0, 0) end
    if v.Magnitude > 1 then v = v.Unit end
    return v
end

--========================================================
-- CAMERA STATE
--========================================================
local camYaw, camPitch, camDist = 0, 12, 18
local targetCamYaw, targetCamPitch, targetCamDist = 0, 12, 18
local cameraDragging = false
local camDragStart, camYawStart, camPitchStart

local CAM_MIN_DIST, CAM_MAX_DIST = 4, 120
local CAM_MIN_PITCH, CAM_MAX_PITCH = -70, 70

--========================================================
-- GUI
--========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MANI_PUMPKIN_ROBO_V3"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(190, 230)
main.Position = UDim2.new(0.5, -95, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(8, 3)
title.Size = UDim2.new(1, -60, 0, 28)
title.Text = "🎃 MANI PUMPKIN V.3.6"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 10
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(24, 24)
minimize.Position = UDim2.new(1, -54, 0, 5)
minimize.Text = "—"
minimize.TextSize = 16
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
minimize.BorderSizePixel = 0
minimize.Parent = titleBar
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(24, 24)
close.Position = UDim2.new(1, -28, 0, 5)
close.Text = "×"
close.TextSize = 16
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
close.BorderSizePixel = 0
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

-- Drag GUI
local guiDragging, guiDragStart, guiStartPosition = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        guiDragging = true
        guiDragStart = input.Position
        guiStartPosition = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not guiDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - guiDragStart
        main.Position = UDim2.new(
            guiStartPosition.X.Scale, guiStartPosition.X.Offset + d.X,
            guiStartPosition.Y.Scale, guiStartPosition.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        guiDragging = false
    end
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(6, 40)
scroll.Size = UDim2.new(1, -12, 1, -46)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 610)
scroll.Parent = main

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, -6, 0, 600)
content.Parent = scroll

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(4, 0)
status.Size = UDim2.new(1, -8, 0, 22)
status.Text = "PROPS 0 / 10"
status.TextColor3 = Color3.fromRGB(180, 180, 190)
status.TextSize = 10
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

local slotFrame = Instance.new("Frame")
slotFrame.Position = UDim2.fromOffset(4, 25)
slotFrame.Size = UDim2.new(1, -8, 0, 138)
slotFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
slotFrame.BorderSizePixel = 0
slotFrame.Parent = content
Instance.new("UICorner", slotFrame).CornerRadius = UDim.new(0, 8)

local slotList = Instance.new("UIListLayout")
slotList.Padding = UDim.new(0, 1)
slotList.Parent = slotFrame

local slotLabels = {}
for i = 1, 10 do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -6, 0, 13)
    label.BackgroundTransparency = 1
    label.Text = i .. ". " .. SLOTS[i] .. " [EMPTY]"
    label.TextColor3 = Color3.fromRGB(145, 145, 155)
    label.TextSize = 9
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slotFrame
    slotLabels[i] = label
end

local function button(text, y)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(4, y)
    b.Size = UDim2.new(1, -8, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 9
    b.Font = Enum.Font.GothamBold
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local loadButton     = button("LOAD 10 PROPS", 168)
local assembleButton = button("🤖 ASSEMBLE ROBOT", 198)

local function makeValueRow(labelText, y, initial)
    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(4, y)
    label.Size = UDim2.new(1, -78, 0, 26)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(initial)
    label.TextColor3 = Color3.fromRGB(215, 215, 220)
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local minus = button("−", y)
    minus.Position = UDim2.new(1, -58, 0, y)
    minus.Size = UDim2.fromOffset(24, 26)

    local plus = button("+", y)
    plus.Position = UDim2.new(1, -30, 0, y)
    plus.Size = UDim2.fromOffset(24, 26)

    return label, minus, plus
end

local heightLabel,   heightMinus,   heightPlus   = makeValueRow("HEIGHT",     232, "1.00")
local distanceLabel, distanceMinus, distancePlus = makeValueRow("DISTANCE",   262, "1.00")
local speedLabel,    speedMinus,    speedPlus    = makeValueRow("WALK SPD",   292, walkSpeed)
local jumpLabel,     jumpMinus,     jumpPlus     = makeValueRow("JUMP PWR",   322, jumpPower)

local headToggle = button("HEAD 360° FOLLOW: ON", 358)
headToggle.TextSize = 8

local controlButton = button("CONTROL: OFF", 390)

local cameraInfo = Instance.new("TextLabel")
cameraInfo.Position = UDim2.fromOffset(4, 424)
cameraInfo.Size = UDim2.new(1, -8, 0, 48)
cameraInfo.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
cameraInfo.BorderSizePixel = 0
cameraInfo.Text = "CAMERA\nPC: RMB Drag • Wheel\nMobile: Drag • Pinch"
cameraInfo.TextColor3 = Color3.fromRGB(160, 160, 170)
cameraInfo.TextSize = 8
cameraInfo.Font = Enum.Font.GothamMedium
cameraInfo.TextXAlignment = Enum.TextXAlignment.Left
cameraInfo.Parent = content
Instance.new("UICorner", cameraInfo).CornerRadius = UDim.new(0, 7)

local resize = Instance.new("TextButton")
resize.Size = UDim2.fromOffset(16, 16)
resize.Position = UDim2.new(1, -16, 1, -16)
resize.BackgroundTransparency = 1
resize.Text = "◢"
resize.TextColor3 = Color3.fromRGB(100, 100, 110)
resize.TextSize = 11
resize.Parent = main

local resizing, resizeStart, originalSize = false, nil, nil
resize.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        originalSize = main.AbsoluteSize
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not resizing then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - resizeStart
        local w = math.clamp(originalSize.X + d.X, 160, 300)
        local h = math.clamp(originalSize.Y + d.Y, 150, 460)
        main.Size = UDim2.fromOffset(w, h)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

--========================================================
-- SLOT UI
--========================================================
local function updateSlots()
    local count = 0
    for i = 1, 10 do
        if registeredProps[i] then
            count += 1
            slotLabels[i].Text = i .. ". " .. SLOTS[i] .. " [LOCKED]"
            slotLabels[i].TextColor3 = Color3.fromRGB(90, 255, 140)
        else
            slotLabels[i].Text = i .. ". " .. SLOTS[i] .. " [EMPTY]"
            slotLabels[i].TextColor3 = Color3.fromRGB(145, 145, 155)
        end
    end
    status.Text = "PROPS " .. count .. " / 10"
end

local function loadProps()
    registeredProps = {}
    local found = {}
    for _, v in pairs(propsFolder:GetChildren()) do
        if string.find(v.Name, player.Name) then
            table.insert(found, v)
        end
    end
    for i = 1, math.min(#found, 10) do
        registeredProps[i] = found[i]
    end
    updateSlots()
    status.Text = "LOADED " .. math.min(#found, 10) .. " / 10"
end

--========================================================
-- CFRAME HELPERS
--========================================================
local function bodyCFrame(offset, slot, rotationOffset, extraOffset)
    extraOffset    = extraOffset or Vector3.zero
    rotationOffset = rotationOffset or CFrame.identity

    local right   = robotRotation.RightVector
    local forward = robotRotation.LookVector

    local pos = robotCenter
        + right   * offset.X * propDistance
        + Vector3.new(0, offset.Y * robotHeight, 0)
        + forward * offset.Z * propDistance
        + extraOffset

    local correction = PART_CORRECTION[slot] or CFrame.identity
    return CFrame.new(pos, pos + forward) * correction * rotationOffset
end

local function legBodyCFrame(offset, angle, extraOffset)
    extraOffset = extraOffset or Vector3.zero

    local relY = offset.Y - HIP_Y
    local relZ = offset.Z
    local cosA, sinA = math.cos(angle), math.sin(angle)
    local newY = relY * cosA - relZ * sinA
    local newZ = relY * sinA + relZ * cosA

    local finalLocal = Vector3.new(offset.X, HIP_Y + newY, newZ)

    local right   = robotRotation.RightVector
    local forward = robotRotation.LookVector

    local pos = robotCenter
        + right   * finalLocal.X * propDistance
        + Vector3.new(0, finalLocal.Y * robotHeight, 0)
        + forward * finalLocal.Z * propDistance
        + extraOffset

    return CFrame.new(pos, pos + forward) * CFrame.Angles(angle, 0, 0)
end

local function moveProp(prop, cf)
    if not prop then return end
    local remote = prop:FindFirstChild("SetCurrentCFrame")
    if remote then
        pcall(function() remote:InvokeServer(cf) end)
    end
end

--========================================================
-- ASSEMBLE
--========================================================
local function assembleRobot()
    if not registeredProps[1] then loadProps() end
    if not registeredProps[1] then status.Text = "NO PROPS"; return end

    robotCenter = hrp.Position + hrp.CFrame.LookVector * 8
    robotRotation = CFrame.lookAt(robotCenter, robotCenter + hrp.CFrame.LookVector)

    for i = 1, 10 do
        local prop = registeredProps[i]
        if prop then
            local offset = BASE_OFFSETS[SLOTS[i]]
            if offset then
                moveProp(prop, bodyCFrame(offset, SLOTS[i]))
            end
            task.wait(0.08)
        end
    end

    status.Text = "🤖 ROBOT READY"
end

local function rebuildRobot()
    if not robotCenter or not robotRotation then return end
    for i = 1, 10 do
        local prop = registeredProps[i]
        if prop then
            local slot = SLOTS[i]
            local offset = BASE_OFFSETS[slot]
            if offset then
                moveProp(prop, bodyCFrame(offset, slot))
            end
        end
    end
end

--========================================================
-- ✅ LIVE FEATURE BUTTONS (apply immediately, even during control)
--========================================================
heightMinus.MouseButton1Click:Connect(function()
    robotHeight = math.max(0.5, robotHeight - 0.1)
    heightLabel.Text = string.format("HEIGHT: %.2f", robotHeight)
end)
heightPlus.MouseButton1Click:Connect(function()
    robotHeight = math.min(3, robotHeight + 0.1)
    heightLabel.Text = string.format("HEIGHT: %.2f", robotHeight)
end)

distanceMinus.MouseButton1Click:Connect(function()
    propDistance = math.max(0.5, propDistance - 0.1)
    distanceLabel.Text = string.format("DISTANCE: %.2f", propDistance)
end)
distancePlus.MouseButton1Click:Connect(function()
    propDistance = math.min(3, propDistance + 0.1)
    distanceLabel.Text = string.format("DISTANCE: %.2f", propDistance)
end)

speedMinus.MouseButton1Click:Connect(function()
    walkSpeed = math.max(5, walkSpeed - 5)
    speedLabel.Text = "WALK SPD: " .. walkSpeed
end)
speedPlus.MouseButton1Click:Connect(function()
    walkSpeed = math.min(100, walkSpeed + 5)
    speedLabel.Text = "WALK SPD: " .. walkSpeed
end)

jumpMinus.MouseButton1Click:Connect(function()
    jumpPower = math.max(20, jumpPower - 5)
    jumpLabel.Text = "JUMP PWR: " .. jumpPower
end)
jumpPlus.MouseButton1Click:Connect(function()
    jumpPower = math.min(150, jumpPower + 5)
    jumpLabel.Text = "JUMP PWR: " .. jumpPower
end)

headToggle.MouseButton1Click:Connect(function()
    headFollowCam = not headFollowCam
    headToggle.Text = "HEAD 360° FOLLOW: " .. (headFollowCam and "ON" or "OFF")
end)

--========================================================
-- ANCHOR
--========================================================
local function createAnchor()
    if robotAnchor then robotAnchor:Destroy() end
    robotAnchor = Instance.new("Part")
    robotAnchor.Name = "MANI_ROBO_ANCHOR"
    robotAnchor.Size = Vector3.new(2, 4, 2)
    robotAnchor.Transparency = 1
    robotAnchor.Anchored = true
    robotAnchor.CanCollide = false
    robotAnchor.CanTouch = false
    robotAnchor.CanQuery = false
    robotAnchor.CFrame = robotRotation
    robotAnchor.Parent = workspace
end

--========================================================
-- JUMP
--========================================================
UserInputService.JumpRequest:Connect(function()
    if not controlEnabled then return end
    if jumpState ~= "Ground" then return end
    jumpState    = "Jump"
    jumpVelocity = jumpPower
end)

--========================================================
-- ✅ MOVEMENT (uses own input reader)
--========================================================
local function startMovement()
    if movementConnection then movementConnection:Disconnect() end

    movementConnection = RunService.Heartbeat:Connect(function(dt)
        if not controlEnabled or not robotAnchor then return end

        -- Get input (PlayerModule → mobile thumbstick → keyboard)
        local raw = getInputVector()

        -- Convert to camera-relative world direction
        local camLook  = camera.CFrame.LookVector
        local camRight = camera.CFrame.RightVector
        camLook  = Vector3.new(camLook.X, 0, camLook.Z)
        camRight = Vector3.new(camRight.X, 0, camRight.Z)
        if camLook.Magnitude > 0.01 then camLook = camLook.Unit end
        if camRight.Magnitude > 0.01 then camRight = camRight.Unit end

        -- raw.Z = forward/back, raw.X = strafe
        local worldDir = camLook * (-raw.Z) + camRight * raw.X

        if worldDir.Magnitude > 0.05 then
            worldDir = worldDir.Unit
            local newPos = robotAnchor.Position + worldDir * walkSpeed * dt
            local target = CFrame.lookAt(newPos, newPos + worldDir)
            robotAnchor.CFrame = robotAnchor.CFrame:Lerp(target, math.clamp(12 * dt, 0, 1))
            moveAmount = math.clamp(moveAmount + dt * 7, 0, 1)
        else
            moveAmount = math.clamp(moveAmount - dt * 8, 0, 1)
        end

        -- Jump physics
        if jumpState == "Jump" then
            jumpVelocity -= 100 * dt
            verticalOffset += jumpVelocity * dt
            if verticalOffset <= 0 then
                verticalOffset = 0
                jumpVelocity = 0
                jumpState = "Ground"
            end
        end

        robotCenter   = robotAnchor.Position + Vector3.new(0, verticalOffset, 0)
        robotRotation = robotAnchor.CFrame
    end)
end

--========================================================
-- HEAD YAW
--========================================================
local function getHeadYaw()
    if not robotAnchor then return 0 end
    local camLook = camera.CFrame.LookVector
    camLook = Vector3.new(camLook.X, 0, camLook.Z)
    if camLook.Magnitude < 0.01 then return 0 end
    camLook = camLook.Unit

    local robotLook = robotAnchor.CFrame.LookVector
    robotLook = Vector3.new(robotLook.X, 0, robotLook.Z)
    if robotLook.Magnitude < 0.01 then return 0 end
    robotLook = robotLook.Unit

    local dot   = robotLook:Dot(camLook)
    local cross = robotLook:Cross(camLook).Y
    return math.atan2(cross, dot)
end

--========================================================
-- ANIMATION (reads LIVE variables every frame)
--========================================================
local function updateAnimation(dt)
    if not controlEnabled or not robotCenter then return end

    animClock += dt
    animationAccumulator += dt
    if animationAccumulator < ANIMATION_RATE then return end
    animationAccumulator = 0

    local moving = moveAmount > 0.05

    local cycle    = math.sin(animClock * 9)
    local opposite = math.sin(animClock * 9 + math.pi)
    local idle     = math.sin(animClock * 2)

    local idleBob = (not moving and jumpState == "Ground") and (idle * 0.08) or 0
    local walkBob = (moving and jumpState == "Ground") and (math.abs(cycle) * 0.10) or 0
    local jumpBob = (jumpState == "Jump") and 0.15 or 0

    local rightLegAngle, leftLegAngle = 0, 0
    if jumpState == "Jump" then
        rightLegAngle = math.rad(15)
        leftLegAngle  = math.rad(15)
    elseif moving then
        rightLegAngle = math.rad(opposite * 25)
        leftLegAngle  = math.rad(cycle    * 25)
    end

    local headYawAngle = headFollowCam and getHeadYaw() or 0

    for i = 1, 10 do
        local prop = registeredProps[i]
        if prop then
            local slot   = SLOTS[i]
            local offset = BASE_OFFSETS[slot]
            if offset then
                local animationOffset = Vector3.new(0, idleBob + walkBob + jumpBob, 0)

                if string.find(slot, "Right Leg") then
                    moveProp(prop, legBodyCFrame(offset, rightLegAngle, animationOffset))
                elseif string.find(slot, "Left Leg") then
                    moveProp(prop, legBodyCFrame(offset, leftLegAngle, animationOffset))

                elseif slot == "Head" then
                    local rot
                    if moving then
                        rot = CFrame.Angles(math.rad(opposite * 3), headYawAngle, math.rad(cycle * 2))
                    else
                        rot = CFrame.Angles(math.rad(idle * 1.5), headYawAngle, math.rad(idle * 1.2))
                    end
                    moveProp(prop, bodyCFrame(offset, slot, rot, animationOffset))

                elseif slot == "Waist" then
                    local rot = CFrame.identity
                    if moving then
                        rot = CFrame.Angles(math.rad(opposite * 4), 0, math.rad(cycle * 3))
                    end
                    moveProp(prop, bodyCFrame(offset, slot, rot, animationOffset))

                elseif slot == "Right Hand" then
                    local rot
                    if jumpState == "Jump" then
                        rot = CFrame.Angles(math.rad(-35), 0, 0)
                    elseif moving then
                        rot = CFrame.Angles(math.rad(cycle * 25), 0, 0)
                        animationOffset += Vector3.new(0, 0, cycle * 0.12)
                    else
                        rot = CFrame.Angles(math.rad(idle * 3), 0, 0)
                    end
                    moveProp(prop, bodyCFrame(offset, slot, rot, animationOffset))

                elseif slot == "Left Hand" then
                    local rot
                    if jumpState == "Jump" then
                        rot = CFrame.Angles(math.rad(-35), 0, 0)
                    elseif moving then
                        rot = CFrame.Angles(math.rad(opposite * 25), 0, 0)
                        animationOffset += Vector3.new(0, 0, opposite * 0.12)
                    else
                        rot = CFrame.Angles(math.rad(opposite * 3), 0, 0)
                    end
                    moveProp(prop, bodyCFrame(offset, slot, rot, animationOffset))
                end
            end
        end
    end
end

--========================================================
-- CAMERA INPUT
--========================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not controlEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        cameraDragging = true
        camDragStart   = input.Position
        camYawStart    = targetCamYaw
        camPitchStart  = targetCamPitch
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not controlEnabled then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement and cameraDragging then
        local d = input.Position - camDragStart
        targetCamYaw   = camYawStart - d.X * 0.4
        targetCamPitch = math.clamp(camPitchStart - d.Y * 0.3, CAM_MIN_PITCH, CAM_MAX_PITCH)
    end

    if input.UserInputType == Enum.UserInputType.MouseWheel then
        targetCamDist = math.clamp(targetCamDist - input.Position.Z * 3, CAM_MIN_DIST, CAM_MAX_DIST)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        cameraDragging = false
    end
end)

-- Mobile camera
local mobileTouchId  = nil
local mobilePinching = false
local pinchStartDist, pinchStartZoom = 0, 0
local secondTouch    = nil

UserInputService.TouchStarted:Connect(function(touch)
    if not controlEnabled then return end
    -- Right side of screen = camera
    if touch.Position.X > camera.ViewportSize.X * 0.35 then
        if not mobileTouchId then
            mobileTouchId  = touch
            camDragStart   = touch.Position
            camYawStart    = targetCamYaw
            camPitchStart  = targetCamPitch
        elseif not secondTouch then
            secondTouch    = touch
            mobilePinching = true
            pinchStartDist = (mobileTouchId.Position - secondTouch.Position).Magnitude
            pinchStartZoom = targetCamDist
        end
    end
end)

UserInputService.TouchMoved:Connect(function(touch)
    if not controlEnabled then return end

    if touch == mobileTouchId and not mobilePinching then
        local d = touch.Position - camDragStart
        targetCamYaw   = camYawStart - d.X * 0.4
        targetCamPitch = math.clamp(camPitchStart - d.Y * 0.3, CAM_MIN_PITCH, CAM_MAX_PITCH)
    elseif mobilePinching and mobileTouchId and secondTouch then
        local p1 = (touch == mobileTouchId) and touch.Position or mobileTouchId.Position
        local p2 = (touch == secondTouch)   and touch.Position or secondTouch.Position
        local d = (p1 - p2).Magnitude
        if pinchStartDist > 0 then
            targetCamDist = math.clamp(pinchStartZoom * (pinchStartDist / d), CAM_MIN_DIST, CAM_MAX_DIST)
        end
    end
end)

UserInputService.TouchEnded:Connect(function(touch)
    if touch == mobileTouchId then
        mobileTouchId = nil
        if secondTouch then
            mobileTouchId = secondTouch
            secondTouch = nil
            camDragStart = mobileTouchId.Position
            camYawStart  = targetCamYaw
            camPitchStart= targetCamPitch
        end
        mobilePinching = false
    elseif touch == secondTouch then
        secondTouch = nil
        mobilePinching = false
    end
end)

local function updateCamera(dt)
    if not controlEnabled or not robotAnchor then return end

    camYaw   = camYaw   + (targetCamYaw   - camYaw)   * math.clamp(10 * dt, 0, 1)
    camPitch = camPitch + (targetCamPitch - camPitch) * math.clamp(10 * dt, 0, 1)
    camDist  = camDist  + (targetCamDist  - camDist)  * math.clamp(8  * dt, 0, 1)

    local center = robotAnchor.Position + Vector3.new(0, 3.2 * robotHeight, 0)

    local rot = CFrame.Angles(0, math.rad(camYaw), 0)
              * CFrame.Angles(math.rad(camPitch), 0, 0)

    local desired = center - rot.LookVector * camDist
    camera.CFrame = CFrame.lookAt(desired, center)
end

--========================================================
-- START / STOP CONTROL
--========================================================
local function startControl()
    if not robotCenter then assembleRobot() end
    if not robotCenter then return end

    setupControls()

    createAnchor()
    controlEnabled = true
    controlButton.Text = "CONTROL: ON"

    -- ✅ FREEZE player but DON'T hide
    hrp.Anchored = true
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    -- Custom camera
    camera.CameraType = Enum.CameraType.Scriptable
    targetCamYaw, targetCamPitch, targetCamDist = 0, 12, 18
    camYaw, camPitch, camDist = 0, 12, 18

    startMovement()

    if renderConnection then renderConnection:Disconnect() end
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        updateAnimation(dt)
        updateCamera(dt)
    end)

    status.Text = "🎮 WALK WITH WASD / JOYSTICK"
end

local function stopControl()
    controlEnabled = false
    moveAmount = 0
    jumpState = "Ground"
    verticalOffset = 0

    if movementConnection then movementConnection:Disconnect(); movementConnection = nil end
    if renderConnection   then renderConnection:Disconnect();   renderConnection   = nil end

    -- Restore player
    hrp.Anchored = false
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid

    rebuildRobot()
    controlButton.Text = "CONTROL: OFF"
    status.Text = "🤖 ROBOT READY"

    if robotAnchor then robotAnchor:Destroy(); robotAnchor = nil end
end

--========================================================
-- BUTTONS
--========================================================
controlButton.MouseButton1Click:Connect(function()
    if controlEnabled then stopControl() else startControl() end
end)

loadButton.MouseButton1Click:Connect(function() loadProps() end)
assembleButton.MouseButton1Click:Connect(function() assembleRobot() end)

--========================================================
-- MIN / CLOSE
--========================================================
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    scroll.Visible = not minimized
    resize.Visible = not minimized
    if minimized then
        main.Size = UDim2.fromOffset(190, 34)
        minimize.Text = "+"
    else
        main.Size = UDim2.fromOffset(190, 230)
        minimize.Text = "—"
    end
end)

close.MouseButton1Click:Connect(function()
    stopControl()
    gui:Destroy()
end)

--========================================================
-- RESPAWN
--========================================================
player.CharacterAdded:Connect(function(newCharacter)
    if controlEnabled then stopControl() end
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    setupControls()
end)

updateSlots()
print("🎃 MANI PUMPKIN ROBO V.3.6 LOADED")
