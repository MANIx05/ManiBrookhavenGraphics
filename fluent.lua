--========================================================--
--   🎃 MANI PUMPKIN ROBO V.1 — DELTA EXECUTOR EDITION
--   Paste in Delta → Execute
--   PC + Mobile | Default Roblox camera feel
--========================================================--

if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- CHARACTER (with retry)
--========================================================--
local Character, Humanoid, HRP

local function refreshCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid  = Character:WaitForChild("Humanoid", 10)
    HRP       = Character:WaitForChild("HumanoidRootPart", 10)
    return Humanoid ~= nil and HRP ~= nil
end

if not refreshCharacter() then
    warn("[MANI ROBO] Character not ready")
    return
end

--========================================================--
-- CONFIG
--========================================================--
local CONFIG = {
    Title            = "MANI PUMPKIN ROBO V.1",
    RobotHeight      = 1,
    PropDistance     = 1,
    WalkSpeed        = 28,
    JumpPower        = 55,
    CameraDistance   = 18,
    CameraMinDistance= 7,
    CameraMaxDistance= 45,
    CameraPitch      = -10,
    RobotSpawnDist   = 8,
    AnimationSpeed   = 9,
    Gravity          = 100,
    HeadFollow       = true,
}

--========================================================--
-- PROPS FOLDER (retry loop)
--========================================================--
local PropsFolder

local function findPropsFolder()
    local wsc = workspace:FindFirstChild("WorkspaceCom")
    if wsc then
        local f = wsc:FindFirstChild("001_TrafficCones")
        if f then PropsFolder = f; return true end
    end
    return false
end

-- try now, else retry in background
if not findPropsFolder() then
    task.spawn(function()
        for _ = 1, 30 do
            if findPropsFolder() then break end
            task.wait(0.5)
        end
    end)
end

--========================================================--
-- SLOTS & OFFSETS
--========================================================--
local SLOTS = {
    "Head","Waist","Right Hand","Left Hand",
    "Right Leg 1","Right Leg 2","Right Leg 3",
    "Left Leg 1","Left Leg 2","Left Leg 3",
}

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
    Head           = CFrame.Angles(0,0,0),
    Waist          = CFrame.Angles(0, math.rad(180), 0),
    ["Right Hand"] = CFrame.Angles(0, math.rad(180), 0),
    ["Left Hand"]  = CFrame.Angles(0, math.rad(180), 0),
}

--========================================================--
-- STATE
--========================================================--
local controlEnabled = false
local robotLoaded    = false

local robotCenter   = Vector3.zero
local robotRotation = CFrame.identity
local robotAnchor

local renderConn, moveConn

local moveAmount    = 0
local animationTime = 0
local jumpVelocity  = 0
local isJumping     = false

local camYaw, camPitch, camDistance
camPitch    = CONFIG.CameraPitch
camDistance = CONFIG.CameraDistance
camYaw      = 0

local rightMouseDown, lastMousePos
local mobileCamTouch, mobileLastPos

local originalWalkSpeed, originalJumpPower, originalAutoRotate

--========================================================--
-- GUI
--========================================================--
local oldGui = PlayerGui:FindFirstChild("MANI_PUMPKIN_ROBO_V1")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MANI_PUMPKIN_ROBO_V1"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = PlayerGui

local Main = Instance.new("Frame")
Main.Size             = UDim2.fromOffset(340, 430)
Main.Position         = UDim2.new(0, 30, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(18,18,22)
Main.BorderSizePixel  = 0
Main.Active           = true
Main.Parent           = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(75,75,90); stroke.Thickness = 1

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,42)
TitleBar.BackgroundColor3 = Color3.fromRGB(25,25,31)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-95,1,0)
Title.Position = UDim2.fromOffset(12,0)
Title.BackgroundTransparency = 1
Title.Text = "🎃  MANI PUMPKIN ROBO V.1"
Title.TextColor3 = Color3.fromRGB(240,240,245)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinButton = Instance.new("TextButton", TitleBar)
MinButton.Size = UDim2.fromOffset(32,30)
MinButton.Position = UDim2.new(1,-72,0,6)
MinButton.BackgroundColor3 = Color3.fromRGB(45,45,55)
MinButton.Text = "—"; MinButton.TextColor3 = Color3.new(1,1,1); MinButton.TextSize = 18
MinButton.Font = Enum.Font.GothamBold; MinButton.BorderSizePixel = 0
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0,7)

local CloseButton = Instance.new("TextButton", TitleBar)
CloseButton.Size = UDim2.fromOffset(32,30)
CloseButton.Position = UDim2.new(1,-36,0,6)
CloseButton.BackgroundColor3 = Color3.fromRGB(80,35,40)
CloseButton.Text = "×"; CloseButton.TextColor3 = Color3.new(1,1,1); CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold; CloseButton.BorderSizePixel = 0
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0,7)

local Content = Instance.new("ScrollingFrame", Main)
Content.Position = UDim2.fromOffset(8,48)
Content.Size = UDim2.new(1,-16,1,-56)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new()
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local Padding = Instance.new("UIPadding", Content)
Padding.PaddingLeft = UDim.new(0,4)
Padding.PaddingRight = UDim.new(0,4)
Padding.PaddingTop = UDim.new(0,2)
Padding.PaddingBottom = UDim.new(0,10)
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0,7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(1,0,0,30)
Status.BackgroundColor3 = Color3.fromRGB(28,28,35)
Status.BorderSizePixel = 0
Status.Text = "● GUI READY"
Status.TextColor3 = Color3.fromRGB(120,255,150)
Status.TextSize = 12
Status.Font = Enum.Font.GothamMedium
Instance.new("UICorner", Status).CornerRadius = UDim.new(0,8)

local function createButton(text, height)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,height or 36)
    b.BackgroundColor3 = Color3.fromRGB(34,34,42)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(235,235,240)
    b.TextSize = 13
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    b.Parent = Content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(48,48,58)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34,34,42)}):Play()
    end)
    return b
end

local LoadButton     = createButton("🔄  LOAD MY PROPS", 40)
local AssembleButton = createButton("🤖  ASSEMBLE ROBOT", 40)

--========================================================--
-- SLIDER
--========================================================--
local function createSlider(title, minV, maxV, defV, callback)
    local H = Instance.new("Frame", Content)
    H.Size = UDim2.new(1,0,0,58)
    H.BackgroundColor3 = Color3.fromRGB(27,27,34)
    H.BorderSizePixel = 0
    Instance.new("UICorner", H).CornerRadius = UDim.new(0,8)

    local L = Instance.new("TextLabel", H)
    L.Size = UDim2.new(1,-20,0,25); L.Position = UDim2.fromOffset(10,2)
    L.BackgroundTransparency = 1
    L.TextColor3 = Color3.fromRGB(225,225,230); L.TextSize = 12
    L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", H)
    Bar.Size = UDim2.new(1,-20,0,6)
    Bar.Position = UDim2.new(0,10,1,-17)
    Bar.BackgroundColor3 = Color3.fromRGB(55,55,65)
    Bar.BorderSizePixel = 0
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((defV-minV)/(maxV-minV),0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(150,90,255)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    local value = defV
    local dragging = false

    local function setValue(x)
        local percent = math.clamp((x - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
        value = math.floor((minV + (maxV-minV)*percent)*10+0.5)/10
        Fill.Size = UDim2.new(percent,0,1,0)
        L.Text = title .. ": " .. value
        callback(value)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValue(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            setValue(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    L.Text = title .. ": " .. value
    return H
end

createSlider("Robot Height", 0.5, 2, CONFIG.RobotHeight, function(v) CONFIG.RobotHeight = v end)
createSlider("Prop Distance",0.5, 2, CONFIG.PropDistance,function(v) CONFIG.PropDistance = v end)
createSlider("Walk Speed",   8,  60, CONFIG.WalkSpeed,   function(v) CONFIG.WalkSpeed = v end)
createSlider("Jump Power",  20, 100, CONFIG.JumpPower,   function(v) CONFIG.JumpPower = v end)
createSlider("Camera Zoom", CONFIG.CameraMinDistance, CONFIG.CameraMaxDistance,
    CONFIG.CameraDistance, function(v) CONFIG.CameraDistance = v; camDistance = v end)

-- Head toggle
local headEnabled = true
local HeadButton = createButton("👁  Head 360° Follow    ON", 36)
HeadButton.TextColor3 = Color3.fromRGB(120,255,150)
HeadButton.MouseButton1Click:Connect(function()
    headEnabled = not headEnabled
    HeadButton.Text = "👁  Head 360° Follow    " .. (headEnabled and "ON" or "OFF")
    HeadButton.TextColor3 = headEnabled and Color3.fromRGB(120,255,150) or Color3.fromRGB(220,220,225)
end)

local ControlButton    = createButton("🎮  START ROBOT CONTROL", 42)
local CameraResetBtn   = createButton("📷  RESET CAMERA", 36)

--========================================================--
-- PROPS SEARCH
--========================================================--
local myProps = {}

local function findMyProps()
    table.clear(myProps)
    if not findPropsFolder() then
        Status.Text = "⚠  Props folder not found"
        Status.TextColor3 = Color3.fromRGB(255,180,100)
        return false
    end
    for _, obj in ipairs(PropsFolder:GetChildren()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(Player.Name), 1, true) then
            table.insert(myProps, obj)
        end
    end
    if #myProps == 0 then
        Status.Text = "⚠  No props for " .. Player.Name
        Status.TextColor3 = Color3.fromRGB(255,180,100)
        return false
    end
    Status.Text = "● Props loaded: " .. #myProps .. " / " .. #SLOTS
    Status.TextColor3 = Color3.fromRGB(120,255,150)
    return true
end

--========================================================--
-- MOVE PROP
--========================================================--
local function moveProp(prop, cf)
    if not prop then return false end
    local remote = prop:FindFirstChild("SetCurrentCFrame")
    if not remote or not remote:IsA("RemoteFunction") then return false end
    local ok = pcall(function() remote:InvokeServer(cf) end)
    return ok
end

--========================================================--
-- BODY / LEG CFrame
--========================================================--
local function getBodyCFrame(partName, center, rotation)
    local offset = BASE_OFFSETS[partName]
    if not offset then return CFrame.new(center) end
    local sx, sy, sz = CONFIG.PropDistance, CONFIG.RobotHeight, CONFIG.PropDistance
    local lo = Vector3.new(offset.X*sx, offset.Y*sy, offset.Z*sz)
    local wp = center
        + rotation.RightVector * lo.X
        + Vector3.new(0, lo.Y, 0)
        + rotation.LookVector * lo.Z
    local cf = CFrame.lookAt(wp, wp + rotation.LookVector, Vector3.yAxis)
    if PART_CORRECTION[partName] then cf = cf * PART_CORRECTION[partName] end
    return cf
end

local function getLegCFrame(partName, center, rotation, angle)
    local offset = BASE_OFFSETS[partName]
    if not offset then return CFrame.new(center) end
    local sx, sy = CONFIG.PropDistance, CONFIG.RobotHeight

    -- pivot at hip
    local hipY = 2.7 * sy
    local relY = (offset.Y * sy) - hipY
    local cosA, sinA = math.cos(angle), math.sin(angle)
    local rotY = relY * cosA
    local rotZ = relY * sinA

    local wp = center
        + rotation.RightVector * (offset.X * sx)
        + Vector3.new(0, hipY + rotY, 0)
        + rotation.LookVector  * rotZ

    return CFrame.new(wp) * CFrame.Angles(angle, 0, 0)
end

--========================================================--
-- ASSIGN PROPS
--========================================================--
local function assignProps()
    if not findMyProps() then return nil end
    local assigned = {}
    for i, slot in ipairs(SLOTS) do
        if myProps[i] then assigned[slot] = myProps[i] end
    end
    return assigned
end

--========================================================--
-- ASSEMBLE
--========================================================--
local function assembleRobot()
    if not refreshCharacter() then return end
    local assigned = assignProps()
    if not assigned then return end

    robotCenter = HRP.Position + HRP.CFrame.LookVector * CONFIG.RobotSpawnDist
    local look = Vector3.new(HRP.CFrame.LookVector.X, 0, HRP.CFrame.LookVector.Z)
    if look.Magnitude < 0.01 then look = Vector3.new(0,0,-1) end
    look = look.Unit
    robotRotation = CFrame.lookAt(robotCenter, robotCenter + look, Vector3.yAxis)

    for _, slot in ipairs(SLOTS) do
        local prop = assigned[slot]
        if prop then
            moveProp(prop, getBodyCFrame(slot, robotCenter, robotRotation))
            task.wait(0.08)
        end
    end

    robotLoaded = true
    Status.Text = "● ROBOT READY  " .. #myProps .. "/" .. #SLOTS
    Status.TextColor3 = Color3.fromRGB(120,255,150)
end

--========================================================--
-- ANCHOR
--========================================================--
local function createAnchor()
    if robotAnchor then robotAnchor:Destroy() end
    robotAnchor = Instance.new("Part")
    robotAnchor.Name = "MANI_ROBO_ANCHOR"
    robotAnchor.Size = Vector3.new(2,2,2)
    robotAnchor.Transparency = 1
    robotAnchor.CanCollide = false
    robotAnchor.CanTouch  = false
    robotAnchor.CanQuery  = false
    robotAnchor.Anchored  = true
    robotAnchor.CFrame    = CFrame.new(robotCenter)
    robotAnchor.Parent    = workspace
end

--========================================================--
-- HIDE CHARACTER
--========================================================--
local hiddenParts = {}

local function hideCharacter()
    table.clear(hiddenParts)
    if not Character then return end
    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("BasePart") then
            hiddenParts[obj] = {Transparency=obj.Transparency, CanCollide=obj.CanCollide}
            obj.Transparency = 1
            obj.CanCollide = false
        elseif obj:IsA("Decal") then
            hiddenParts[obj] = {Transparency=obj.Transparency}
            obj.Transparency = 1
        end
    end
end

local function showCharacter()
    for obj, data in pairs(hiddenParts) do
        if obj and obj.Parent then
            for prop, val in pairs(data) do
                pcall(function() obj[prop] = val end)
            end
        end
    end
    table.clear(hiddenParts)
end

--========================================================--
-- INPUT (PC keyboard fallback + Mobile joystick via MoveDirection)
--========================================================--
local function getKeyboardDirection()
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.zero end
    local fwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
    local rgt = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
    if fwd.Magnitude > 0 then fwd = fwd.Unit end
    if rgt.Magnitude > 0 then rgt = rgt.Unit end
    local d = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up)    then d += fwd end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down)  then d -= fwd end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then d += rgt end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left)  then d -= rgt end
    if d.Magnitude > 0.05 then return d.Unit end
    return Vector3.zero
end

local function getMoveDirection()
    if Humanoid then
        local md = Humanoid.MoveDirection
        if md.Magnitude > 0.05 then
            return Vector3.new(md.X, 0, md.Z).Unit
        end
    end
    return getKeyboardDirection()
end

--========================================================--
-- JUMP
--========================================================--
UserInputService.JumpRequest:Connect(function()
    if controlEnabled and not isJumping and robotAnchor then
        isJumping = true
        jumpVelocity = CONFIG.JumpPower
    end
end)

--========================================================--
-- MOVEMENT
--========================================================--
local function startMovement()
    if moveConn then moveConn:Disconnect() end
    moveConn = RunService.Heartbeat:Connect(function(dt)
        if not controlEnabled or not robotAnchor then return end

        local dir = getMoveDirection()

        if dir.Magnitude > 0.05 then
            local newPos = robotAnchor.Position + dir * CONFIG.WalkSpeed * dt
            robotAnchor.CFrame = CFrame.lookAt(newPos, newPos + dir, Vector3.yAxis)
            moveAmount = 1
        else
            moveAmount = math.max(0, moveAmount - dt*5)
        end

        -- jump
        if isJumping then
            jumpVelocity = jumpVelocity - CONFIG.Gravity * dt
            local y = robotAnchor.Position.Y + jumpVelocity * dt
            robotAnchor.Position = Vector3.new(robotAnchor.Position.X, y, robotAnchor.Position.Z)
            if jumpVelocity <= 0 and y <= robotCenter.Y then
                robotAnchor.Position = Vector3.new(robotAnchor.Position.X, robotCenter.Y, robotAnchor.Position.Z)
                jumpVelocity = 0
                isJumping = false
            end
        end

        robotCenter   = robotAnchor.Position
        robotRotation = robotAnchor.CFrame

        -- ✅ keep player invisible & glued to robot, but DO NOT zero velocity
        if HRP and HRP.Parent then
            HRP.CFrame = CFrame.new(robotAnchor.Position)
        end
    end)
end

--========================================================--
-- HEAD YAW
--========================================================--
local function getHeadYaw()
    if not headEnabled then return 0 end
    local cam = workspace.CurrentCamera
    if not cam then return 0 end
    local fwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
    if fwd.Magnitude < 0.01 then return 0 end
    fwd = fwd.Unit
    local rf = robotRotation.LookVector
    local angle = math.atan2(rf:Cross(fwd).Y, rf:Dot(fwd))
    return math.clamp(angle, -math.pi, math.pi)
end

--========================================================--
-- ANIMATION
--========================================================--
local function updateAnimation(dt)
    if not robotLoaded then return end
    animationTime += dt * CONFIG.AnimationSpeed

    local assigned = {}
    for i, slot in ipairs(SLOTS) do
        if myProps[i] then assigned[slot] = myProps[i] end
    end

    local walking = moveAmount > 0.1
    local bob = walking
        and math.sin(animationTime * 1.5) * 0.18
        or  math.sin(animationTime * 0.8) * 0.06

    local cc = robotCenter + Vector3.new(0, bob, 0)

    -- Head
    if assigned.Head then
        local yaw = math.atan2(robotRotation.LookVector.X, robotRotation.LookVector.Z) + getHeadYaw()
        local base = getBodyCFrame("Head", cc, robotRotation)
        moveProp(assigned.Head, CFrame.new(base.Position) * CFrame.Angles(0, yaw, 0))
    end

    -- Waist
    if assigned.Waist then
        moveProp(assigned.Waist, getBodyCFrame("Waist", cc, robotRotation))
    end

    -- Hands
    local handSwing = walking and math.sin(animationTime) * math.rad(18) or 0
    if assigned["Right Hand"] then
        local cf = getBodyCFrame("Right Hand", cc, robotRotation) * CFrame.Angles(handSwing, 0, 0)
        moveProp(assigned["Right Hand"], cf)
    end
    if assigned["Left Hand"] then
        local cf = getBodyCFrame("Left Hand", cc, robotRotation) * CFrame.Angles(-handSwing, 0, 0)
        moveProp(assigned["Left Hand"], cf)
    end

    -- Legs (as one plank)
    local legAngle = 0
    if walking then legAngle = math.sin(animationTime) * math.rad(20) end
    if isJumping then legAngle = math.rad(15) end

    for _, side in ipairs({"Right","Left"}) do
        local a = (side == "Left") and -legAngle or legAngle
        for i = 1, 3 do
            local slot = side .. " Leg " .. i
            local prop = assigned[slot]
            if prop then
                moveProp(prop, getLegCFrame(slot, cc, robotRotation, a))
            end
        end
    end
end

--========================================================--
-- CAMERA
--========================================================--
local function resetCamera()
    camYaw = 0
    camPitch = CONFIG.CameraPitch
    camDistance = CONFIG.CameraDistance
end

local function updateCamera()
    if not controlEnabled or not robotAnchor then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    local center = robotAnchor.Position + Vector3.new(0, 4.0 * CONFIG.RobotHeight, 0)
    local yaw   = math.rad(camYaw)
    local pitch = math.rad(math.clamp(camPitch, -75, 75))

    local offset = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0).LookVector * camDistance
    cam.CFrame = CFrame.lookAt(center - offset, center, Vector3.yAxis)
end

--========================================================--
-- START / STOP
--========================================================--
local function startControl()
    if controlEnabled then return end
    if not robotLoaded then
        assembleRobot()
        if not robotLoaded then return end
    end
    if not refreshCharacter() then return end

    originalWalkSpeed   = Humanoid.WalkSpeed
    originalJumpPower   = Humanoid.JumpPower
    originalAutoRotate  = Humanoid.AutoRotate

    createAnchor()
    if not robotAnchor then return end

    controlEnabled = true

    -- ✅ keep WalkSpeed active so MoveDirection updates on mobile
    Humanoid.WalkSpeed  = 16
    Humanoid.JumpPower  = 0
    Humanoid.AutoRotate = false
    Humanoid.PlatformStand = true -- stop physics fighting

    hideCharacter()

    local cam = workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Scriptable end

    resetCamera()

    Status.Text = "● ROBOT CONTROL ACTIVE"
    Status.TextColor3 = Color3.fromRGB(120,255,150)
    ControlButton.Text = "⛔  STOP ROBOT CONTROL"

    startMovement()

    if renderConn then renderConn:Disconnect() end
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if controlEnabled then
            updateAnimation(dt)
            updateCamera()
        end
    end)
end

local function stopControl()
    controlEnabled = false
    isJumping = false
    jumpVelocity = 0

    if moveConn  then moveConn:Disconnect();  moveConn = nil end
    if renderConn then renderConn:Disconnect(); renderConn = nil end

    if Humanoid and Humanoid.Parent then
        Humanoid.WalkSpeed  = originalWalkSpeed or 16
        Humanoid.JumpPower  = originalJumpPower or 50
        Humanoid.AutoRotate = originalAutoRotate or true
        Humanoid.PlatformStand = false
    end

    showCharacter()

    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        if Humanoid then cam.CameraSubject = Humanoid end
    end

    if robotAnchor then robotAnchor:Destroy(); robotAnchor = nil end

    ControlButton.Text = "🎮  START ROBOT CONTROL"
    Status.Text = "● ROBOT CONTROL STOPPED"
    Status.TextColor3 = Color3.fromRGB(255,190,100)

    task.delay(0.2, function()
        if ScreenGui.Parent then assembleRobot() end
    end)
end

--========================================================--
-- BUTTONS
--========================================================--
LoadButton.MouseButton1Click:Connect(function()
    if controlEnabled then return end
    findMyProps()
end)

AssembleButton.MouseButton1Click:Connect(function()
    if controlEnabled then return end
    assembleRobot()
end)

ControlButton.MouseButton1Click:Connect(function()
    if controlEnabled then stopControl() else startControl() end
end)

CameraResetBtn.MouseButton1Click:Connect(resetCamera)

--========================================================--
-- PC CAMERA
--========================================================--
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not controlEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true
        lastMousePos = UserInputService:GetMouseLocation()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not controlEnabled then return end
    if rightMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
        local cur = UserInputService:GetMouseLocation()
        if lastMousePos then
            local d = cur - lastMousePos
            camYaw   -= d.X * 0.35
            camPitch  = math.clamp(camPitch - d.Y * 0.25, -75, 75)
        end
        lastMousePos = cur
    end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        camDistance = math.clamp(camDistance - input.Position.Z * 2,
            CONFIG.CameraMinDistance, CONFIG.CameraMaxDistance)
    end
end)

--========================================================--
-- MOBILE CAMERA
--========================================================--
UserInputService.TouchStarted:Connect(function(touch)
    if not controlEnabled then return end
    local vp = workspace.CurrentCamera.ViewportSize
    if touch.Position.X > vp.X * 0.35 then
        mobileCamTouch = touch
        mobileLastPos  = touch.Position
    end
end)

UserInputService.TouchMoved:Connect(function(touch)
    if not controlEnabled or touch ~= mobileCamTouch then return end
    if not mobileLastPos then mobileLastPos = touch.Position; return end
    local d = touch.Position - mobileLastPos
    camYaw   -= d.X * 0.35
    camPitch  = math.clamp(camPitch - d.Y * 0.25, -75, 75)
    mobileLastPos = touch.Position
end)

UserInputService.TouchEnded:Connect(function(touch)
    if touch == mobileCamTouch then
        mobileCamTouch = nil
        mobileLastPos  = nil
    end
end)

--========================================================--
-- GUI DRAG
--========================================================--
local draggingGui, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingGui = true
        dragStart = input.Position
        startPos  = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingGui then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingGui = false
    end
end)

--========================================================--
-- MINIMIZE / CLOSE
--========================================================--
local minimized = false
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Main.Size = minimized and UDim2.fromOffset(340,42) or UDim2.fromOffset(340,430)
    MinButton.Text = minimized and "+" or "—"
end)

CloseButton.MouseButton1Click:Connect(function()
    stopControl()
    ScreenGui:Destroy()
end)

--========================================================--
-- RESPAWN
--========================================================--
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(1)
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    if controlEnabled then stopControl() end
end)

--========================================================--
-- INIT
--========================================================--
task.defer(function()
    task.wait(0.5)
    if findPropsFolder() then
        findMyProps()
    else
        Status.Text = "● GUI READY • LOAD PROPS"
        Status.TextColor3 = Color3.fromRGB(120,255,150)
    end
end)

print("================================================")
print("🎃 MANI PUMPKIN ROBO V.1 — DELTA READY")
print("✅ GUI LOADED")
print("✅ Mobile + PC")
print("✅ Robot Control + Animation + Camera")
print("================================================")
