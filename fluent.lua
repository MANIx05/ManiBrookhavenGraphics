--========================================================
-- 🎃 MANI PUMPKIN ROBO V.3.1
-- 10 PROP CUSTOM ROBOT | PC + MOBILE
-- CUSTOM IDLE / WALK / JUMP | 360 CAMERA
-- FIXED: LEGS MOVE AS ONE | PART CORRECTION | ZOOM+
--========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

--========================================================
-- PROP FOLDER
--========================================================
local propsFolder =
    workspace:FindFirstChild("WorkspaceCom")
    and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")

if not propsFolder then
    warn("❌ WorkspaceCom > 001_TrafficCones nahi mila")
    return
end

--========================================================
-- 10 ROBOT SLOTS
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
    Head        = Vector3.new( 0,     7.0,  0),
    Waist       = Vector3.new( 0,     3.7,  0),
    ["Right Hand"] = Vector3.new( 3.0, 4.0,  0),
    ["Left Hand"]  = Vector3.new(-3.0, 4.0,  0),
    ["Right Leg 1"] = Vector3.new( 1.45, 1.8, 0),
    ["Right Leg 2"] = Vector3.new( 1.45, 0.45,0),
    ["Right Leg 3"] = Vector3.new( 1.45,-0.9, 0),
    ["Left Leg 1"]  = Vector3.new(-1.45, 1.8, 0),
    ["Left Leg 2"]  = Vector3.new(-1.45, 0.45,0),
    ["Left Leg 3"]  = Vector3.new(-1.45,-0.9, 0),
}

--========================================================
-- 🆕 PART CORRECTION (FIX UPSIDE-DOWN PROPS)
--========================================================
-- If Head/Waist/Hands appear upside-down or backwards,
-- change the value below. Examples:
--   CFrame.identity                                  = no change
--   CFrame.Angles(math.rad(180), 0, 0)               = flip front/back
--   CFrame.Angles(0, math.rad(180), 0)               = flip left/right
--   CFrame.Angles(math.rad(180), math.rad(180), 0)   = full upside-down
local PART_CORRECTION = {
    ["Head"]       = CFrame.identity,
    ["Waist"]      = CFrame.identity,
    ["Right Hand"] = CFrame.identity,
    ["Left Hand"]  = CFrame.identity,
}

--========================================================
-- 🆕 LEG HIP PIVOT (all 3 segments rotate around this)
--========================================================
local HIP_Y = 2.5   -- higher = swing more, lower = swing less

--========================================================
-- SETTINGS
--========================================================
local robotHeight   = 1
local propDistance  = 1
local walkSpeed     = 28
local jumpPower     = 55
local controlEnabled = false

local registeredProps = {}
local robotCenter  = nil
local robotRotation= nil
local robotAnchor  = nil
local movementConnection = nil
local renderConnection   = nil

--========================================================
-- ANIMATION STATE
--========================================================
local animClock = 0
local moveAmount = 0
local jumpState = "Ground"
local jumpVelocity = 0
local verticalOffset = 0
local lastGroundY = 0
local ANIMATION_RATE = 1 / 30
local animationAccumulator = 0

--========================================================
-- CAMERA STATE
--========================================================
local cameraYaw = 0
local cameraPitch = 12
local cameraDistance = 18
local targetCameraYaw = 0
local targetCameraPitch = 12
local targetCameraDistance = 18
local cameraDragging = false
local cameraDragStart = nil
local cameraYawStart = 0
local cameraPitchStart = 0
local oldCameraType = nil
local oldCameraSubject = nil

-- 🆕 Camera zoom / pitch limits
local CAM_MIN_DIST = 3
local CAM_MAX_DIST = 150
local CAM_MIN_PITCH = -80
local CAM_MAX_PITCH = 80

--========================================================
-- GUI
--========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MANI_PUMPKIN_ROBO_V3"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(225, 280)
main.Position = UDim2.new(0.5, -112, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- TITLE
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(10, 4)
title.Size = UDim2.new(1, -70, 0, 28)
title.Text = "🎃 MANI PUMPKIN ROBO V.3.1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- MIN
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(28, 26)
minimize.Position = UDim2.new(1, -62, 0, 6)
minimize.Text = "—"
minimize.TextSize = 18
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
minimize.BorderSizePixel = 0
minimize.Parent = titleBar
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

-- CLOSE
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 26)
close.Position = UDim2.new(1, -32, 0, 6)
close.Text = "×"
close.TextSize = 18
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
close.BorderSizePixel = 0
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

-- DRAG
local guiDragging = false
local guiDragStart
local guiStartPosition

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
        local delta = input.Position - guiDragStart
        main.Position = UDim2.new(
            guiStartPosition.X.Scale,
            guiStartPosition.X.Offset + delta.X,
            guiStartPosition.Y.Scale,
            guiStartPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        guiDragging = false
    end
end)

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(7, 44)
scroll.Size = UDim2.new(1, -14, 1, -51)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 590)
scroll.Parent = main

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, -6, 0, 580)
content.Parent = scroll

-- STATUS
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(4, 0)
status.Size = UDim2.new(1, -8, 0, 25)
status.Text = "PROPS 0 / 10"
status.TextColor3 = Color3.fromRGB(180, 180, 190)
status.TextSize = 11
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

-- SLOTS
local slotFrame = Instance.new("Frame")
slotFrame.Position = UDim2.fromOffset(4, 28)
slotFrame.Size = UDim2.new(1, -8, 0, 140)
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
    label.Size = UDim2.new(1, -8, 0, 13)
    label.BackgroundTransparency = 1
    label.Text = i .. ". " .. SLOTS[i] .. " [EMPTY]"
    label.TextColor3 = Color3.fromRGB(145, 145, 155)
    label.TextSize = 9
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slotFrame
    slotLabels[i] = label
end

-- BUTTON MAKER
local function button(text, y, width)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(4, y)
    b.Size = UDim2.new(1, -8, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local loadButton     = button("LOAD 10 PROPS", 174)
local assembleButton = button("🤖 ASSEMBLE ROBOT", 207)

-- VALUE ROW
local function makeValueRow(labelText, y, initial)
    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(4, y)
    label.Size = UDim2.new(1, -90, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(initial)
    label.TextColor3 = Color3.fromRGB(215, 215, 220)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local minus = button("−", y, 1)
    minus.Position = UDim2.new(1, -66, 0, y)
    minus.Size = UDim2.fromOffset(28, 28)

    local plus = button("+", y, 1)
    plus.Position = UDim2.new(1, -34, 0, y)
    plus.Size = UDim2.fromOffset(28, 28)

    return label, minus, plus
end

local heightLabel,   heightMinus,   heightPlus   = makeValueRow("HEIGHT",     242, "1.00")
local distanceLabel, distanceMinus, distancePlus = makeValueRow("DISTANCE",   275, "1.00")
local speedLabel,    speedMinus,    speedPlus    = makeValueRow("WALK SPEED", 308, walkSpeed)
local jumpLabel,     jumpMinus,     jumpPlus     = makeValueRow("JUMP POWER", 341, jumpPower)

local controlButton = button("CONTROL: OFF", 378)

-- CAMERA INFO
local cameraInfo = Instance.new("TextLabel")
cameraInfo.Position = UDim2.fromOffset(4, 414)
cameraInfo.Size = UDim2.new(1, -8, 0, 48)
cameraInfo.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
cameraInfo.BorderSizePixel = 0
cameraInfo.Text = "CAMERA\nPC: RMB Drag • Wheel Zoom\nMobile: Drag • PINCH Zoom"
cameraInfo.TextColor3 = Color3.fromRGB(160, 160, 170)
cameraInfo.TextSize = 9
cameraInfo.Font = Enum.Font.GothamMedium
cameraInfo.TextXAlignment = Enum.TextXAlignment.Left
cameraInfo.Parent = content
Instance.new("UICorner", cameraInfo).CornerRadius = UDim.new(0, 7)

-- RESIZE HANDLE
local resize = Instance.new("TextButton")
resize.Size = UDim2.fromOffset(18, 18)
resize.Position = UDim2.new(1, -18, 1, -18)
resize.BackgroundTransparency = 1
resize.Text = "◢"
resize.TextColor3 = Color3.fromRGB(100, 100, 110)
resize.TextSize = 12
resize.Parent = main

local resizing = false
local resizeStart
local originalSize

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
        local delta = input.Position - resizeStart
        local newWidth  = math.clamp(originalSize.X + delta.X, 190, 320)
        local newHeight = math.clamp(originalSize.Y + delta.Y, 180, 500)
        main.Size = UDim2.fromOffset(newWidth, newHeight)
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
-- BODY CFrame (with per-slot correction)
--========================================================
local function bodyCFrame(offset, slot, rotationOffset, extraOffset)
    extraOffset = extraOffset or Vector3.zero
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
-- 🆕 LEG CFrame — pivot at HIP so all segments move together
--========================================================
local function legBodyCFrame(offset, hipY, angle, extraOffset)
    extraOffset = extraOffset or Vector3.zero

    -- rotate part-local position around hip pivot (X-axis rotation)
    local relY = offset.Y - hipY
    local relZ = offset.Z
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    local newY = relY * cosA - relZ * sinA
    local newZ = relY * sinA + relZ * cosA

    local finalLocal = Vector3.new(offset.X, hipY + newY, newZ)

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
-- SERVER PROP MOVE
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
    lastGroundY = robotCenter.Y

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
-- REBUILD (static, no animation)
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
-- VALUE CONTROLS
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
    speedLabel.Text = "WALK SPEED: " .. walkSpeed
end)
speedPlus.MouseButton1Click:Connect(function()
    walkSpeed = math.min(100, walkSpeed + 5)
    speedLabel.Text = "WALK SPEED: " .. walkSpeed
end)

jumpMinus.MouseButton1Click:Connect(function()
    jumpPower = math.max(20, jumpPower - 5)
    jumpLabel.Text = "JUMP POWER: " .. jumpPower
end)
jumpPlus.MouseButton1Click:Connect(function()
    jumpPower = math.min(150, jumpPower + 5)
    jumpLabel.Text = "JUMP POWER: " .. jumpPower
end)

--========================================================
-- ANCHOR
--========================================================
local function createAnchor()
    if robotAnchor then robotAnchor:Destroy() end
    robotAnchor = Instance.new("Part")
    robotAnchor.Name = "MANI_ROBO_ANCHOR"
    robotAnchor.Size = Vector3.new(1, 1, 1)
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
local function requestJump()
    if not controlEnabled then return end
    if jumpState ~= "Ground" then return end
    jumpState = "Jump"
    jumpVelocity = jumpPower
end

UserInputService.JumpRequest:Connect(requestJump)

--========================================================
-- MOVEMENT
--========================================================
local function startMovement()
    if movementConnection then movementConnection:Disconnect() end

    movementConnection = RunService.Heartbeat:Connect(function(dt)
        if not controlEnabled then return end
        if not robotAnchor then return end

        local direction = humanoid.MoveDirection
        if direction.Magnitude > 0.05 then
            local flat = Vector3.new(direction.X, 0, direction.Z)
            if flat.Magnitude > 0 then
                flat = flat.Unit
                local newPosition = robotAnchor.Position + flat * walkSpeed * dt
                local target = CFrame.lookAt(newPosition, newPosition + flat)
                robotAnchor.CFrame = robotAnchor.CFrame:Lerp(target, math.clamp(12 * dt, 0, 1))
            end
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

        robotCenter = robotAnchor.Position + Vector3.new(0, verticalOffset, 0)
        robotRotation = robotAnchor.CFrame
    end)
end

--========================================================
-- 🆕 ANIMATION — LEGS MOVE TOGETHER
--========================================================
local function updateAnimation(dt)
    if not controlEnabled then return end
    if not robotCenter then return end

    animClock += dt
    animationAccumulator += dt
    if animationAccumulator < ANIMATION_RATE then return end
    animationAccumulator = 0

    local moving = moveAmount > 0.05

    -- Walk / idle cycles
    local cycle    = math.sin(animClock * 9)
    local opposite = math.sin(animClock * 9 + math.pi)
    local idle     = math.sin(animClock * 2)

    local idleBob = 0
    if not moving and jumpState == "Ground" then
        idleBob = idle * 0.08
    end

    local walkBob = 0
    if moving and jumpState == "Ground" then
        walkBob = math.abs(math.sin(animClock * 9)) * 0.10
    end

    local jumpBob = 0
    if jumpState == "Jump" then jumpBob = 0.15 end

    -- 🆕 Leg swing angles (same angle for ALL 3 segments per side)
    local rightLegAngle = 0
    local leftLegAngle  = 0

    if jumpState == "Jump" then
        rightLegAngle = math.rad(15)
        leftLegAngle  = math.rad(15)
    elseif moving then
        rightLegAngle = math.rad(opposite * 25)
        leftLegAngle  = math.rad(cycle    * 25)
    end

    for i = 1, 10 do
        local prop = registeredProps[i]
        if prop then
            local slot = SLOTS[i]
            local offset = BASE_OFFSETS[slot]
            if offset then
                local animationOffset = Vector3.new(0, idleBob + walkBob + jumpBob, 0)

                --════════════════════════════════════════════
                -- LEGS: rotate whole chain around hip pivot
                --════════════════════════════════════════════
                if string.find(slot, "Right Leg") then
                    moveProp(prop, legBodyCFrame(offset, HIP_Y, rightLegAngle, animationOffset))

                elseif string.find(slot, "Left Leg") then
                    moveProp(prop, legBodyCFrame(offset, HIP_Y, leftLegAngle, animationOffset))

                --════════════════════════════════════════════
                -- HEAD / WAIST / HANDS: use bodyCFrame
                --════════════════════════════════════════════
                else
                    local rotation = CFrame.identity

                    if slot == "Head" then
                        if moving then
                            rotation = CFrame.Angles(
                                math.rad(opposite * 3), 0,
                                math.rad(cycle * 2)
                            )
                        else
                            rotation = CFrame.Angles(
                                math.rad(idle * 1.5), 0,
                                math.rad(idle * 1.2)
                            )
                        end

                    elseif slot == "Waist" then
                        if moving then
                            rotation = CFrame.Angles(
                                math.rad(opposite * 4), 0,
                                math.rad(cycle * 3)
                            )
                        end

                    elseif slot == "Right Hand" then
                        if moving then
                            rotation = CFrame.Angles(math.rad(cycle * 25), 0, 0)
                            animationOffset += Vector3.new(0, 0, cycle * 0.12)
                        else
                            rotation = CFrame.Angles(math.rad(idle * 3), 0, 0)
                        end

                    elseif slot == "Left Hand" then
                        if moving then
                            rotation = CFrame.Angles(math.rad(opposite * 25), 0, 0)
                            animationOffset += Vector3.new(0, 0, opposite * 0.12)
                        else
                            rotation = CFrame.Angles(math.rad(opposite * 3), 0, 0)
                        end
                    end

                    -- Jump pose for hands
                    if jumpState == "Jump"
                    and (slot == "Right Hand" or slot == "Left Hand") then
                        rotation = CFrame.Angles(math.rad(-35), 0, 0)
                    end

                    moveProp(prop, bodyCFrame(offset, slot, rotation, animationOffset))
                end
            end
        end
    end
end

--========================================================
-- PC CAMERA INPUT
--========================================================
UserInputService.InputBegan:Connect(function(input)
    if not controlEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        cameraDragging = true
        cameraDragStart = input.Position
        cameraYawStart = targetCameraYaw
        cameraPitchStart = targetCameraPitch
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not controlEnabled then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement and cameraDragging then
        local delta = input.Position - cameraDragStart
        targetCameraYaw   = cameraYawStart - delta.X * 0.35
        targetCameraPitch = math.clamp(
            cameraPitchStart - delta.Y * 0.25,
            CAM_MIN_PITCH, CAM_MAX_PITCH
        )
    end

    -- 🆕 Faster wheel zoom + wider range
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        targetCameraDistance = math.clamp(
            targetCameraDistance - input.Position.Z * 4,
            CAM_MIN_DIST, CAM_MAX_DIST
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        cameraDragging = false
    end
end)

--========================================================
-- 🆕 MOBILE CAMERA (drag + PINCH ZOOM)
--========================================================
local touches = {}
local touchStart = nil
local touchYawStart = 0
local touchPitchStart = 0
local pinchStartDist = 0
local pinchStartZoom = 0

UserInputService.TouchStarted:Connect(function(touch)
    if not controlEnabled then return end
    table.insert(touches, {input = touch, startPos = touch.Position, currentPos = touch.Position})

    if #touches == 2 then
        local d = (touches[1].startPos - touches[2].startPos).Magnitude
        pinchStartDist = d
        pinchStartZoom = targetCameraDistance
        touchStart = nil -- disable single-finger drag
    elseif #touches == 1 then
        touchStart = touch.Position
        touchYawStart = targetCameraYaw
        touchPitchStart = targetCameraPitch
    end
end)

UserInputService.TouchMoved:Connect(function(touch)
    if not controlEnabled then return end

    for _, t in ipairs(touches) do
        if t.input == touch then
            t.currentPos = touch.Position
        end
    end

    if #touches == 2 then
        local p1 = touches[1].currentPos or touches[1].startPos
        local p2 = touches[2].currentPos or touches[2].startPos
        local d = (p1 - p2).Magnitude
        if pinchStartDist > 0 then
            local ratio = pinchStartDist / d
            targetCameraDistance = math.clamp(
                pinchStartZoom * ratio,
                CAM_MIN_DIST, CAM_MAX_DIST
            )
        end
    elseif #touches == 1 and touchStart then
        local delta = touch.Position - touchStart
        targetCameraYaw   = touchYawStart - delta.X * 0.35
        targetCameraPitch = math.clamp(
            touchPitchStart - delta.Y * 0.25,
            CAM_MIN_PITCH, CAM_MAX_PITCH
        )
    end
end)

UserInputService.TouchEnded:Connect(function(touch)
    for i, t in ipairs(touches) do
        if t.input == touch then
            table.remove(touches, i)
            break
        end
    end
    if #touches < 2 then pinchStartDist = 0 end
    if #touches == 0 then touchStart = nil end
end)

--========================================================
-- CAMERA UPDATE
--========================================================
local function updateCamera(dt)
    if not controlEnabled then return end
    if not robotAnchor then return end

    cameraYaw    = cameraYaw    + (targetCameraYaw    - cameraYaw)    * math.clamp(10 * dt, 0, 1)
    cameraPitch  = cameraPitch  + (targetCameraPitch  - cameraPitch)  * math.clamp(10 * dt, 0, 1)
    cameraDistance = cameraDistance + (targetCameraDistance - cameraDistance) * math.clamp(8 * dt, 0, 1)

    local center = robotAnchor.Position + Vector3.new(0, 3.2 * robotHeight, 0)

    local rotation = CFrame.Angles(0, math.rad(cameraYaw), 0)
        * CFrame.Angles(math.rad(cameraPitch), 0, 0)

    local direction = rotation.LookVector
    local desiredPosition = center - direction * cameraDistance
    local desiredCamera = CFrame.lookAt(desiredPosition, center)

    camera.CFrame = camera.CFrame:Lerp(desiredCamera, math.clamp(9 * dt, 0, 1))
end

--========================================================
-- START CONTROL
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

    oldCameraType = camera.CameraType
    oldCameraSubject = camera.CameraSubject

    camera.CameraType = Enum.CameraType.Scriptable

    targetCameraYaw = 0
    targetCameraPitch = 12
    targetCameraDistance = 18
    cameraYaw = 0
    cameraPitch = 12
    cameraDistance = 18

    startMovement()

    if renderConnection then renderConnection:Disconnect() end
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        updateAnimation(dt)
        updateCamera(dt)
    end)
end

--========================================================
-- STOP CONTROL
--========================================================
local function stopControl()
    controlEnabled = false
    moveAmount = 0
    jumpState = "Ground"
    verticalOffset = 0

    if movementConnection then
        movementConnection:Disconnect()
        movementConnection = nil
    end
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end

    if hrp then hrp.Anchored = false end
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50

    camera.CameraType = oldCameraType or Enum.CameraType.Custom
    camera.CameraSubject = oldCameraSubject or humanoid

    rebuildRobot()
    controlButton.Text = "CONTROL: OFF"

    if robotAnchor then
        robotAnchor:Destroy()
        robotAnchor = nil
    end
end

--========================================================
-- BUTTON CONNECTIONS
--========================================================
controlButton.MouseButton1Click:Connect(function()
    if controlEnabled then stopControl() else startControl() end
end)

loadButton.MouseButton1Click:Connect(function()
    loadProps()
end)

assembleButton.MouseButton1Click:Connect(function()
    assembleRobot()
end)

--========================================================
-- MINIMIZE / CLOSE
--========================================================
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    scroll.Visible = not minimized
    resize.Visible = not minimized
    if minimized then
        main.Size = UDim2.fromOffset(225, 38)
        minimize.Text = "+"
    else
        main.Size = UDim2.fromOffset(225, 280)
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
print("🎃 MANI PUMPKIN ROBO V.3.1 LOADED")
