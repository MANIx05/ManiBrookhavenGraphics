--========================================================
-- 🎃 MANI PUMPKIN ROBO V.3.2
-- Default Roblox Camera | Legs as Planes | Head 360
-- Fix: Waist/Hand flip | Ground-anchored height
--========================================================

repeat task.wait() until game:IsLoaded()

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")

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
    warn("❌ WorkspaceCom > 001_TrafficCones nahi mila")
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
-- BASE OFFSETS (bottom of legs = Y 0, so height grows UP)
--========================================================
local BASE_OFFSETS = {
    Head          = Vector3.new( 0,    7.9, 0),
    Waist         = Vector3.new( 0,    4.6, 0),
    ["Right Hand"]= Vector3.new( 3.0,  4.9, 0),
    ["Left Hand"] = Vector3.new(-3.0,  4.9, 0),
    ["Right Leg 1"]=Vector3.new( 1.45, 2.7, 0),
    ["Right Leg 2"]=Vector3.new( 1.45, 1.35,0),
    ["Right Leg 3"]=Vector3.new( 1.45, 0,   0),
    ["Left Leg 1"] =Vector3.new(-1.45, 2.7, 0),
    ["Left Leg 2"] =Vector3.new(-1.45, 1.35,0),
    ["Left Leg 3"] =Vector3.new(-1.45, 0,   0),
}

--========================================================
-- PART CORRECTION (flip inverted props)
--========================================================
local PART_CORRECTION = {
    ["Head"]       = CFrame.identity,
    ["Waist"]      = CFrame.Angles(0, math.rad(180), 0), -- flipped
    ["Right Hand"] = CFrame.Angles(0, math.rad(180), 0), -- flipped
    ["Left Hand"]  = CFrame.Angles(0, math.rad(180), 0), -- flipped
}

--========================================================
-- LEG HIP PIVOT
--========================================================
local HIP_Y = 2.7  -- hip Y in base offsets (top of legs)

--========================================================
-- SETTINGS
--========================================================
local robotHeight   = 1
local propDistance  = 1
local walkSpeed     = 28
local jumpPower     = 55
local controlEnabled= false
local headFollowCam = true   -- head looks where camera looks

local registeredProps = {}
local robotCenter, robotRotation, robotAnchor = nil, nil, nil
local movementConnection, renderConnection = nil, nil

--========================================================
-- ANIM STATE
--========================================================
local animClock, moveAmount = 0, 0
local jumpState, jumpVelocity, verticalOffset = "Ground", 0, 0
local ANIMATION_RATE = 1/30
local animationAccumulator = 0

--========================================================
-- CAMERA STATE
--========================================================
local oldCameraType, oldCameraSubject

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

-- Title
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
title.Text = "🎃 MANI PUMPKIN V.3.2"
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

-- Drag
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

-- Scroll
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

-- Status
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

-- Slot list
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

-- Button maker
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

-- Head Follow Camera toggle
local headToggle = button("HEAD 360° FOLLOW CAM: ON", 358)
headToggle.TextSize = 8

local controlButton = button("CONTROL: OFF", 390)

-- Camera info
local cameraInfo = Instance.new("TextLabel")
cameraInfo.Position = UDim2.fromOffset(4, 424)
cameraInfo.Size = UDim2.new(1, -8, 0, 48)
cameraInfo.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
cameraInfo.BorderSizePixel = 0
cameraInfo.Text = "CAMERA (Default Roblox)\nPC: RMB Drag • Wheel Zoom\nMobile: Drag • Pinch Zoom"
cameraInfo.TextColor3 = Color3.fromRGB(160, 160, 170)
cameraInfo.TextSize = 8
cameraInfo.Font = Enum.Font.GothamMedium
cameraInfo.TextXAlignment = Enum.TextXAlignment.Left
cameraInfo.Parent = content
Instance.new("UICorner", cameraInfo).CornerRadius = UDim.new(0, 7)

-- Resize handle
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

--========================================================
-- LOAD PROPS
--========================================================
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
-- BODY CFRAME
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

--========================================================
-- LEG CFRAME — pivot at hip so all 3 parts swing together
--========================================================
local function legBodyCFrame(offset, angle, extraOffset)
    extraOffset = extraOffset or Vector3.zero

    -- rotate part-local position around hip pivot (X-axis rotation)
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

--========================================================
-- MOVE PROP
--========================================================
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

--========================================================
-- REBUILD (static)
--========================================================
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
-- CONTROLS
--========================================================
heightMinus.MouseButton1Click:Connect(function()
    robotHeight = math.max(0.5, robotHeight - 0.1)
    heightLabel.Text = string.format("HEIGHT: %.2f", robotHeight)
    rebuildRobot()
end)
heightPlus.MouseButton1Click:Connect(function()
    robotHeight = math.min(3, robotHeight + 0.1)
    heightLabel.Text = string.format("HEIGHT: %.2f", robotHeight)
    rebuildRobot()
end)

distanceMinus.MouseButton1Click:Connect(function()
    propDistance = math.max(0.5, propDistance - 0.1)
    distanceLabel.Text = string.format("DISTANCE: %.2f", propDistance)
    rebuildRobot()
end)
distancePlus.MouseButton1Click:Connect(function()
    propDistance = math.min(3, propDistance + 0.1)
    distanceLabel.Text = string.format("DISTANCE: %.2f", propDistance)
    rebuildRobot()
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
    headToggle.Text = "HEAD 360° FOLLOW CAM: " .. (headFollowCam and "ON" or "OFF")
end)

--========================================================
-- ANCHOR
--========================================================
local function createAnchor()
    if robotAnchor then robotAnchor:Destroy() end
    robotAnchor = Instance.new("Part")
    robotAnchor.Name = "MANI_ROBO_ANCHOR"
    robotAnchor.Size = Vector3.new(2, 1, 2)
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
    jumpState = "Jump"
    jumpVelocity = jumpPower
end)

--========================================================
-- MOVEMENT
--========================================================
local function startMovement()
    if movementConnection then movementConnection:Disconnect() end

    movementConnection = RunService.Heartbeat:Connect(function(dt)
        if not controlEnabled or not robotAnchor then return end

        local direction = humanoid.MoveDirection
        if direction.Magnitude > 0.05 then
            local flat = Vector3.new(direction.X, 0, direction.Z)
            if flat.Magnitude > 0 then
                flat = flat.Unit
                local newPos = robotAnchor.Position + flat * walkSpeed * dt
                local target = CFrame.lookAt(newPos, newPos + flat)
                robotAnchor.CFrame = robotAnchor.CFrame:Lerp(target, math.clamp(12 * dt, 0, 1))
            end
            moveAmount = math.clamp(moveAmount + dt * 7, 0, 1)
        else
            moveAmount = math.clamp(moveAmount - dt * 8, 0, 1)
        end

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
-- HEAD YAW from camera (for 360° human-like follow)
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
-- ANIMATION
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

    -- Leg swing (same for all 3 parts per side)
    local rightLegAngle, leftLegAngle = 0, 0
    if jumpState == "Jump" then
        rightLegAngle = math.rad(15)
        leftLegAngle  = math.rad(15)
    elseif moving then
        rightLegAngle = math.rad(opposite * 25)
        leftLegAngle  = math.rad(cycle    * 25)
    end

    -- Head 360 follow
    local headYawAngle = 0
    if headFollowCam then
        headYawAngle = getHeadYaw()
    end

    for i = 1, 10 do
        local prop = registeredProps[i]
        if prop then
            local slot   = SLOTS[i]
            local offset = BASE_OFFSETS[slot]
            if offset then
                local animationOffset = Vector3.new(0, idleBob + walkBob + jumpBob, 0)

                -- LEGS: swing as one plank
                if string.find(slot, "Right Leg") then
                    moveProp(prop, legBodyCFrame(offset, rightLegAngle, animationOffset))
                elseif string.find(slot, "Left Leg") then
                    moveProp(prop, legBodyCFrame(offset, leftLegAngle, animationOffset))

                -- HEAD: 360 + idle
                elseif slot == "Head" then
                    local rot
                    if moving then
                        rot = CFrame.Angles(math.rad(opposite * 3), headYawAngle, math.rad(cycle * 2))
                    else
                        rot = CFrame.Angles(math.rad(idle * 1.5), headYawAngle, math.rad(idle * 1.2))
                    end
                    moveProp(prop, bodyCFrame(offset, slot, rot, animationOffset))

                -- WAIST
                elseif slot == "Waist" then
                    local rot = CFrame.identity
                    if moving then
                        rot = CFrame.Angles(math.rad(opposite * 4), 0, math.rad(cycle * 3))
                    end
                    moveProp(prop, bodyCFrame(offset, slot, rot, animationOffset))

                -- RIGHT HAND
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

                -- LEFT HAND
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
-- START / STOP CONTROL
--========================================================
local function startControl()
    if not robotCenter then assembleRobot() end
    if not robotCenter then return end

    createAnchor()
    controlEnabled = true
    controlButton.Text = "CONTROL: ON"

    hrp.Anchored = true
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    -- ✅ Use DEFAULT Roblox camera behavior
    oldCameraType    = camera.CameraType
    oldCameraSubject = camera.CameraSubject

    camera.CameraType    = Enum.CameraType.Custom
    camera.CameraSubject = robotAnchor
    camera.CameraMode    = Enum.CameraMode.Classic

    startMovement()

    if renderConnection then renderConnection:Disconnect() end
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        updateAnimation(dt)
    end)
end

local function stopControl()
    controlEnabled = false
    moveAmount = 0
    jumpState = "Ground"
    verticalOffset = 0

    if movementConnection then movementConnection:Disconnect(); movementConnection = nil end
    if renderConnection   then renderConnection:Disconnect();   renderConnection   = nil end

    if hrp then hrp.Anchored = false end
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    camera.CameraType    = oldCameraType or Enum.CameraType.Custom
    camera.CameraSubject = oldCameraSubject or humanoid

    rebuildRobot()
    controlButton.Text = "CONTROL: OFF"

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
end)

--========================================================
-- INIT
--========================================================
updateSlots()
print("🎃 MANI PUMPKIN ROBO V.3.2 LOADED")
