--[[
    FE Bot Creature Script - Props Version
    Works with 15 props arranged in a circle
    PC & Mobile compatible GUI
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ============================================================
-- SOUNDS
-- ============================================================
local jumpSound = Instance.new("Sound")
jumpSound.SoundId = "rbxassetid://9114890978"
jumpSound.Parent = SoundService

local fallSound = Instance.new("Sound")
fallSound.SoundId = "rbxassetid://3923230963"
fallSound.Parent = SoundService

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    PropsFolderPath = {"WorkspaceCom", "001_TrafficCones"}, -- change if needed
    CircleRadius = 12,
    AnimationSpeed = 0.2,
    LerpSpeed = 0.2,
}

-- ============================================================
-- FIND PROPS
-- ============================================================
local function getPropsFolder()
    local current = workspace
    for _, name in ipairs(CONFIG.PropsFolderPath) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

local propsFolder = getPropsFolder()
if not propsFolder then
    warn("❌ Props folder nahi mila")
    return
end

local myProps = {}
for _, v in pairs(propsFolder:GetChildren()) do
    if string.find(v.Name, player.Name) then
        table.insert(myProps, v)
    end
end

local total = #myProps
if total == 0 then
    warn("❌ Koi prop nahi mila")
    return
end

print("✅ Found " .. total .. " props")

-- ============================================================
-- ARRANGE PROPS IN CIRCLE (initial)
-- ============================================================
local center = hrp.Position

for i, prop in ipairs(myProps) do
    local angle = (2 * math.pi / total) * i
    local newPos = center + Vector3.new(
        math.cos(angle) * CONFIG.CircleRadius,
        0,
        math.sin(angle) * CONFIG.CircleRadius
    )
    local lookAt = CFrame.new(newPos, center)
    local setCF = prop:FindFirstChild("SetCurrentCFrame")
    if setCF then
        pcall(function()
            setCF:InvokeServer(lookAt)
        end)
    end
    task.wait(0.2)
end

-- ============================================================
-- GET PROPS AS "MECH PARTS"
-- ============================================================
-- Each prop has a primary part we can manipulate
local function getPropPrimaryPart(prop)
    if prop:IsA("Model") then
        return prop.PrimaryPart or prop:FindFirstChildWhichIsA("BasePart")
    elseif prop:IsA("BasePart") then
        return prop
    end
    return nil
end

-- Build mechParts from props (up to 6 for animation slots, rest idle)
local mechParts = {}
for i, prop in ipairs(myProps) do
    local part = getPropPrimaryPart(prop)
    if part then
        table.insert(mechParts, {
            prop = prop,
            part = part,
            setCF = prop:FindFirstChild("SetCurrentCFrame"),
            index = i
        })
    end
end

-- ============================================================
-- PLAYER CHARACTER SETUP
-- ============================================================
if char:FindFirstChild("Animate") then
    char.Animate:Destroy()
end
if char:FindFirstChildOfClass("Humanoid") then
    char.Humanoid.HipHeight = 4
    char.Humanoid.JumpPower = 120
    char.Humanoid.PlatformStand = true
end

-- ============================================================
-- NO COLLISION
-- ============================================================
local function enforceNoCollision(character)
    for _, partName in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
        end
    end
end

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    if newChar:FindFirstChild("Animate") then
        newChar.Animate:Destroy()
    end
    local hum = newChar:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.HipHeight = 4
        hum.JumpPower = 120
        hum.PlatformStand = true
    end
    enforceNoCollision(newChar)
end)

if player.Character then
    enforceNoCollision(player.Character)
end

-- ============================================================
-- ANIMATION POSES (relative to character parts)
-- ============================================================
local function getCharPart(name)
    return char:FindFirstChild(name)
end

local function buildPoses()
    local torso = getCharPart("Torso")
    local head = getCharPart("Head")
    local rightArm = getCharPart("Right Arm")
    local leftArm = getCharPart("Left Arm")
    local rightLeg = getCharPart("Right Leg")
    local leftLeg = getCharPart("Left Leg")
    local hrpPart = getCharPart("HumanoidRootPart")
    
    return {
        Idle = {
            {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
            {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
            {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 1) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-90))},
            {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 6) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-90))},
            {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 6) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-90))},
            {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 1) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-90))},
        },
        WalkingAnimations = {
            {
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 1) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 6) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-180))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 6) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-180))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 1) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-180))},
            },
            {
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 1) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-60))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 6) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-60))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 6) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-60))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 1) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-60))},
            },
            {
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 1) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -3, 6) * CFrame.Angles(math.rad(-90), math.rad(-65), math.rad(-180))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 6) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-180))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -3, 1) * CFrame.Angles(math.rad(90), math.rad(115), math.rad(-180))},
            }
        },
        JumpAnimations = {
            {
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -1, 1) * CFrame.Angles(math.rad(-90), math.rad(-45), math.rad(-90))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -1, 6) * CFrame.Angles(math.rad(-90), math.rad(-45), math.rad(-90))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, 0.5, 6) * CFrame.Angles(math.rad(90), math.rad(135), math.rad(-90))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, 0.5, 1) * CFrame.Angles(math.rad(90), math.rad(135), math.rad(-90))},
            },
            {
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -4, 1) * CFrame.Angles(math.rad(-90), math.rad(-160), math.rad(-90))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -4, 6) * CFrame.Angles(math.rad(-90), math.rad(-160), math.rad(-90))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -4, 6) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, -4, 1) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90))},
            },
            {
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 1.5) * CFrame.Angles(math.rad(-65), 0, 0)},
                {blueCube = torso or hrpPart, offset = CFrame.new(0, -3, 6) * CFrame.Angles(math.rad(75), math.rad(90), math.rad(180))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -1, 1) * CFrame.Angles(math.rad(-90), math.rad(-45), math.rad(-90))},
                {blueCube = rightLeg or hrpPart, offset = CFrame.new(-2.5, -1, 6) * CFrame.Angles(math.rad(-90), math.rad(-45), math.rad(-90))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, 0.5, 6) * CFrame.Angles(math.rad(90), math.rad(135), math.rad(-90))},
                {blueCube = leftLeg or hrpPart, offset = CFrame.new(2.5, 0.5, 1) * CFrame.Angles(math.rad(90), math.rad(135), math.rad(-90))},
            }
        }
    }
end

-- ============================================================
-- ANIMATION STATE
-- ============================================================
local currentState = "Idle"
local currentAnimIndex = 1
local lastStateChange = tick()
local wasJumping = false

local running = false
local heartbeatConn = nil

-- ============================================================
-- SEND CFrame TO SERVER FOR A PROP
-- ============================================================
local function sendPropCFrame(mech, desiredCFrame)
    if mech.setCF then
        pcall(function()
            mech.setCF:InvokeServer(desiredCFrame)
        end)
    end
end

-- ============================================================
-- MAIN ANIMATION LOOP
-- ============================================================
local function startAnimation()
    if running then return end
    running = true
    
    local poses = buildPoses()
    
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not running then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        local isMoving = hum.MoveDirection.Magnitude > 0
        local isJumping = hum.Jump
        
        local newState = "Idle"
        if isJumping then
            newState = "Jump"
        elseif isMoving then
            newState = "Walk"
        end
        
        -- Sounds
        if newState == "Jump" and not wasJumping then
            jumpSound:Play()
        elseif wasJumping and (newState == "Idle" or newState == "Walk") then
            fallSound:Play()
        end
        wasJumping = isJumping
        
        -- Animation index cycling
        if newState ~= currentState or tick() - lastStateChange >= CONFIG.AnimationSpeed then
            currentState = newState
            currentAnimIndex = (currentAnimIndex % 3) + 1
            lastStateChange = tick()
        end
        
        -- Pick pose set
        local poseList
        if currentState == "Walk" then
            poseList = poses.WalkingAnimations[currentAnimIndex]
        elseif currentState == "Jump" then
            poseList = poses.JumpAnimations[currentAnimIndex]
        else
            poseList = poses.Idle
        end
        
        -- Apply to props
        for i, mech in ipairs(mechParts) do
            local pose = poseList[i]
            if pose and pose.blueCube and mech.part then
                local desiredCFrame = pose.blueCube.CFrame:ToWorldSpace(pose.offset)
                -- Lerp current prop position toward desired
                local currentCF = mech.part.CFrame
                local lerped = currentCF:Lerp(desiredCFrame, CONFIG.LerpSpeed)
                sendPropCFrame(mech, lerped)
            end
        end
    end)
end

local function stopAnimation()
    running = false
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

-- ============================================================
-- GUI (PC + MOBILE)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PropBotCreatureGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 260)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
title.BackgroundTransparency = 0.2
title.BorderSizePixel = 0
title.Text = "🤖 Prop Bot Creature"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0.8, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "▶ START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Rearrange Button
local rearrangeBtn = Instance.new("TextButton")
rearrangeBtn.Name = "RearrangeBtn"
rearrangeBtn.Size = UDim2.new(0.8, 0, 0, 40)
rearrangeBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
rearrangeBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 0)
rearrangeBtn.BorderSizePixel = 0
rearrangeBtn.Text = "🔄 REARRANGE"
rearrangeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rearrangeBtn.TextScaled = true
rearrangeBtn.Font = Enum.Font.GothamBold
rearrangeBtn.Parent = mainFrame

local rearrangeCorner = Instance.new("UICorner")
rearrangeCorner.CornerRadius = UDim.new(0, 8)
rearrangeCorner.Parent = rearrangeBtn

-- Radius Display / Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.8, 0, 0, 30)
infoLabel.Position = UDim2.new(0.1, 0, 0.62, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Props: " .. total
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = mainFrame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0.78, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minBtn.BorderSizePixel = 0
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 15)
minCorner.Parent = minBtn

-- Minimized reopen button
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.new(0, 60, 0, 60)
openBtn.Position = UDim2.new(0, 20, 0.5, -30)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
openBtn.BorderSizePixel = 0
openBtn.Text = "🤖"
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 30)
openCorner.Parent = openBtn

-- ============================================================
-- GUI LOGIC
-- ============================================================
local isRunning = false

local function setStatus(text, color)
    statusLabel.Text = "Status: " .. text
    statusLabel.TextColor3 = color or Color3.fromRGB(150, 255, 150)
end

toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        startAnimation()
        toggleBtn.Text = "⏸ STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        setStatus("Running", Color3.fromRGB(150, 255, 150))
    else
        stopAnimation()
        toggleBtn.Text = "▶ START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        setStatus("Stopped", Color3.fromRGB(255, 150, 150))
    end
end)

rearrangeBtn.MouseButton1Click:Connect(function()
    setStatus("Rearranging...", Color3.fromRGB(255, 200, 100))
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrpPart = char:FindFirstChild("HumanoidRootPart")
    if not hrpPart then return end
    
    local newCenter = hrpPart.Position
    for i, prop in ipairs(myProps) do
        local angle = (2 * math.pi / total) * i
        local newPos = newCenter + Vector3.new(
            math.cos(angle) * CONFIG.CircleRadius,
            0,
            math.sin(angle) * CONFIG.CircleRadius
        )
        local lookAt = CFrame.new(newPos, newCenter)
        local setCF = prop:FindFirstChild("SetCurrentCFrame")
        if setCF then
            pcall(function()
                setCF:InvokeServer(lookAt)
            end)
        end
        task.wait(0.15)
    end
    setStatus("Rearranged!", Color3.fromRGB(150, 255, 150))
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openBtn.Visible = false
end)

-- Drag support for mobile (touch)
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Auto-start
setStatus("Ready - Tap START", Color3.fromRGB(200, 200, 255))
print("✅ Prop Bot Creature GUI loaded. Props: " .. total)
