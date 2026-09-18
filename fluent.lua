repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--==================================================
-- CONFIG
--==================================================

local propsFolder = workspace
    :FindFirstChild("WorkspaceCom")
    :FindFirstChild("001_TrafficCones")

if not propsFolder then
    warn("❌ Props folder nahi mila")
    return
end

-- Robot ke 10 slots
local ROBOT_SLOTS = {
    "Head",
    "Waist",
    "RightHand",
    "LeftHand",

    "RightLeg1",
    "RightLeg2",
    "RightLeg3",

    "LeftLeg1",
    "LeftLeg2",
    "LeftLeg3",
}

-- Robot body positions
local OFFSETS = {

    -- 1
    Head = Vector3.new(0, 5.5, 0),

    -- 2
    Waist = Vector3.new(0, 3, 0),

    -- 3
    RightHand = Vector3.new(2.5, 3.5, 0),

    -- 4
    LeftHand = Vector3.new(-2.5, 3.5, 0),

    -- Right leg
    RightLeg1 = Vector3.new(1.2, 1.5, 0),
    RightLeg2 = Vector3.new(1.2, 0.3, 0),
    RightLeg3 = Vector3.new(1.2, -0.9, 0),

    -- Left leg
    LeftLeg1 = Vector3.new(-1.2, 1.5, 0),
    LeftLeg2 = Vector3.new(-1.2, 0.3, 0),
    LeftLeg3 = Vector3.new(-1.2, -0.9, 0),
}

--==================================================
-- FIND PLAYER PROPS
--==================================================

local myProps = {}

for _, v in pairs(propsFolder:GetChildren()) do

    if string.find(v.Name, player.Name) then
        table.insert(myProps, v)
    end

end

print("Found props:", #myProps)

--==================================================
-- SORT PROPS
--==================================================

table.sort(myProps, function(a, b)
    return a.Name < b.Name
end)

--==================================================
-- ROBOT CENTER
--==================================================

local robotCenter =
    hrp.Position
    + hrp.CFrame.LookVector * 8

--==================================================
-- PLACE PROP
--==================================================

local function placeProp(prop, slotName)

    local offset = OFFSETS[slotName]

    if not offset then
        warn("❌ Offset nahi mila:", slotName)
        return false
    end

    -- Robot center ke according position
    local worldPosition =
        robotCenter
        + hrp.CFrame.RightVector * offset.X
        + Vector3.new(0, offset.Y, 0)
        + hrp.CFrame.LookVector * offset.Z

    -- Robot same direction mein face kare
    local cf =
        CFrame.new(
            worldPosition,
            worldPosition + hrp.CFrame.LookVector
        )

    local remote =
        prop:FindFirstChild("SetCurrentCFrame")

    if not remote then
        warn("❌ SetCurrentCFrame nahi mila:", prop.Name)
        return false
    end

    -- SAME working method
    remote:InvokeServer(cf)

    print(
        "✅",
        slotName,
        "<-",
        prop.Name
    )

    return true
end

--==================================================
-- ASSEMBLE ONLY FIRST 10
--==================================================

local usedProps = {}

local totalToUse =
    math.min(#myProps, 10)

for i = 1, totalToUse do

    local prop = myProps[i]
    local slotName = ROBOT_SLOTS[i]

    if prop and slotName then

        local success =
            placeProp(prop, slotName)

        if success then

            usedProps[i] = prop

            -- Prop lock delay
            task.wait(0.25)

        end

    end

end

--==================================================
-- RESULT
--==================================================

if #myProps < 10 then

    warn(
        "⚠️ Robot ke liye sirf "
        .. #myProps
        .. "/10 props mile"
    )

else

    print("================================")
    print("🤖 ROBOT ASSEMBLED")
    print("10/10 PROPS USED")
    print("================================")

end
