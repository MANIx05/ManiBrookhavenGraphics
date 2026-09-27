-- MANI GUI V.1 by MANISH_K05
-- Fixed: minimize toggles, full-screen toggle, aura follows player, props work

local AllAuraConfigs = {
    SoftGlow = { name = "Soft Glow", speed = 0.5, radius = 12, offsetY = 0, rotation = 0, type = "circle", color = "🟢" },
    FreshBreeze = { name = "Fresh Breeze", speed = 0.7, radius = 14, offsetY = 2, rotation = 15, type = "circle", color = "🟢" },
    CalmRing = { name = "Calm Ring", speed = 0.3, radius = 10, offsetY = 1, rotation = 0, type = "circle", color = "🟢" },
    TinyOrbit = { name = "Tiny Orbit", speed = 1.2, radius = 8, offsetY = 0, rotation = 0, type = "circle", color = "🟢" },
    SimpleHalo = { name = "Simple Halo", speed = 0.4, radius = 13, offsetY = 3, rotation = 0, type = "circle", color = "🟢" },
    FloatingMist = { name = "Floating Mist", speed = 0.2, radius = 16, offsetY = 5, rotation = 10, type = "circle", color = "🟢" },
    GentleWave = { name = "Gentle Wave", speed = 0.8, radius = 11, offsetY = 1, rotation = 0, type = "wave", color = "🟢" },
    LightBloom = { name = "Light Bloom", speed = 0.6, radius = 9, offsetY = 0, rotation = 5, type = "circle", color = "🟢" },
    MiniSpiral = { name = "Mini Spiral", speed = 0.9, radius = 10, offsetY = 2, rotation = 0, type = "spiral", color = "🟢" },
    CloudRing = { name = "Cloud Ring", speed = 0.2, radius = 18, offsetY = 4, rotation = 0, type = "circle", color = "🟢" },
    SoftOrbit = { name = "Soft Orbit", speed = 0.5, radius = 12, offsetY = 0, rotation = 0, type = "circle", color = "🟢" },
    BrightCircle = { name = "Bright Circle", speed = 0.6, radius = 14, offsetY = 1, rotation = 0, type = "circle", color = "🟢" },
    PeaceAura = { name = "Peace Aura", speed = 0.3, radius = 16, offsetY = 2, rotation = 5, type = "circle", color = "🟢" },
    BreezeHalo = { name = "Breeze Halo", speed = 0.7, radius = 13, offsetY = 3, rotation = 0, type = "circle", color = "🟢" },
    MorningGlow = { name = "Morning Glow", speed = 0.4, radius = 15, offsetY = 1, rotation = 10, type = "circle", color = "🟢" },
    FloatingStars = { name = "Floating Stars", speed = 0.8, radius = 11, offsetY = 4, rotation = 0, type = "star", color = "🟢" },
    LittleGalaxy = { name = "Little Galaxy", speed = 0.5, radius = 17, offsetY = 2, rotation = 15, type = "spiral", color = "🟢" },
    DreamRing = { name = "Dream Ring", speed = 0.3, radius = 14, offsetY = 0, rotation = 0, type = "double", color = "🟢" },
    PureHalo = { name = "Pure Halo", speed = 0.4, radius = 12, offsetY = 3, rotation = 0, type = "circle", color = "🟢" },
    SkyBloom = { name = "Sky Bloom", speed = 0.6, radius = 18, offsetY = 5, rotation = 8, type = "circle", color = "🟢" },
    AquaOrbit = { name = "Aqua Orbit", speed = 0.7, radius = 13, offsetY = 1, rotation = 5, type = "circle", color = "🔵" },
    FrostRing = { name = "Frost Ring", speed = 0.4, radius = 11, offsetY = 0, rotation = 0, type = "circle", color = "🔵" },
    CrystalWave = { name = "Crystal Wave", speed = 0.9, radius = 14, offsetY = 2, rotation = 0, type = "wave", color = "🔵" },
    WindSpiral = { name = "Wind Spiral", speed = 1.0, radius = 12, offsetY = 1, rotation = 10, type = "spiral", color = "🔵" },
    Rainfall = { name = "Rainfall", speed = 0.5, radius = 15, offsetY = 4, rotation = 0, type = "circle", color = "🔵" },
    BlueComet = { name = "Blue Comet", speed = 1.2, radius = 10, offsetY = 0, rotation = 15, type = "circle", color = "🔵" },
    IceHalo = { name = "Ice Halo", speed = 0.3, radius = 13, offsetY = 3, rotation = 0, type = "circle", color = "🔵" },
    MistSpiral = { name = "Mist Spiral", speed = 0.6, radius = 16, offsetY = 2, rotation = 5, type = "spiral", color = "🔵" },
    OceanRing = { name = "Ocean Ring", speed = 0.4, radius = 14, offsetY = 1, rotation = 0, type = "circle", color = "🔵" },
    CloudSpiral = { name = "Cloud Spiral", speed = 0.3, radius = 17, offsetY = 5, rotation = 8, type = "spiral", color = "🔵" },
    SnowOrbit = { name = "Snow Orbit", speed = 0.5, radius = 14, offsetY = 1, rotation = 0, type = "circle", color = "🔵" },
    SilverBloom = { name = "Silver Bloom", speed = 0.6, radius = 16, offsetY = 2, rotation = 5, type = "circle", color = "🔵" },
    MoonRing = { name = "Moon Ring", speed = 0.3, radius = 12, offsetY = 0, rotation = 0, type = "circle", color = "🔵" },
    StarOrbit = { name = "Star Orbit", speed = 0.8, radius = 13, offsetY = 3, rotation = 10, type = "star", color = "🔵" },
    SkySpiral = { name = "Sky Spiral", speed = 0.7, radius = 15, offsetY = 2, rotation = 12, type = "spiral", color = "🔵" },
    FrozenHalo = { name = "Frozen Halo", speed = 0.4, radius = 11, offsetY = 4, rotation = 0, type = "circle", color = "🔵" },
    CrystalOrbit = { name = "Crystal Orbit", speed = 0.9, radius = 17, offsetY = 1, rotation = 15, type = "circle", color = "🔵" },
    TidalWave = { name = "Tidal Wave", speed = 0.5, radius = 18, offsetY = 3, rotation = 0, type = "wave", color = "🔵" },
    WinterBloom = { name = "Winter Bloom", speed = 0.4, radius = 14, offsetY = 2, rotation = 8, type = "circle", color = "🔵" },
    ArcticRing = { name = "Arctic Ring", speed = 0.3, radius = 16, offsetY = 5, rotation = 0, type = "double", color = "🔵" },
    MysticSpiral = { name = "Mystic Spiral", speed = 0.8, radius = 14, offsetY = 2, rotation = 10, type = "spiral", color = "🟣" },
    PhantomRing = { name = "Phantom Ring", speed = 0.5, radius = 12, offsetY = 0, rotation = 0, type = "double", color = "🟣" },
    ArcaneOrbit = { name = "Arcane Orbit", speed = 0.7, radius = 15, offsetY = 1, rotation = 8, type = "circle", color = "🟣" },
    SoulHalo = { name = "Soul Halo", speed = 0.4, radius = 13, offsetY = 3, rotation = 0, type = "circle", color = "🟣" },
    AstralBloom = { name = "Astral Bloom", speed = 0.6, radius = 16, offsetY = 2, rotation = 12, type = "star", color = "🟣" },
    RuneCircle = { name = "Rune Circle", speed = 0.3, radius = 11, offsetY = 0, rotation = 15, type = "circle", color = "🟣" },
    DreamSpiral = { name = "Dream Spiral", speed = 0.9, radius = 14, offsetY = 3, rotation = 0, type = "spiral", color = "🟣" },
    SpiritOrbit = { name = "Spirit Orbit", speed = 0.5, radius = 17, offsetY = 4, rotation = 6, type = "circle", color = "🟣" },
    Moonveil = { name = "Moonveil", speed = 0.4, radius = 12, offsetY = 1, rotation = 0, type = "wave", color = "🟣" },
    Starveil = { name = "Starveil", speed = 0.7, radius = 15, offsetY = 2, rotation = 10, type = "star", color = "🟣" },
    EtherRing = { name = "Ether Ring", speed = 0.5, radius = 16, offsetY = 1, rotation = 0, type = "double", color = "🟣" },
    MirageOrbit = { name = "Mirage Orbit", speed = 0.8, radius = 14, offsetY = 2, rotation = 8, type = "circle", color = "🟣" },
    TwilightHalo = { name = "Twilight Halo", speed = 0.4, radius = 17, offsetY = 3, rotation = 5, type = "circle", color = "🟣" },
    SpectralBloom = { name = "Spectral Bloom", speed = 0.6, radius = 18, offsetY = 4, rotation = 10, type = "spiral", color = "🟣" },
    MysticCrown = { name = "Mystic Crown", speed = 0.3, radius = 13, offsetY = 5, rotation = 0, type = "circle", color = "🟣" },
    AstralRing = { name = "Astral Ring", speed = 0.7, radius = 15, offsetY = 0, rotation = 12, type = "circle", color = "🟣" },
    PhantomOrbit = { name = "Phantom Orbit", speed = 0.9, radius = 12, offsetY = 2, rotation = 15, type = "wave", color = "🟣" },
    SoulSpiral = { name = "Soul Spiral", speed = 0.5, radius = 19, offsetY = 3, rotation = 6, type = "spiral", color = "🟣" },
    ArcaneBloom = { name = "Arcane Bloom", speed = 0.6, radius = 16, offsetY = 2, rotation = 9, type = "star", color = "🟣" },
    Dreamveil = { name = "Dreamveil", speed = 0.4, radius = 14, offsetY = 4, rotation = 0, type = "double", color = "🟣" },
    SolarCrown = { name = "Solar Crown", speed = 0.6, radius = 15, offsetY = 3, rotation = 0, type = "double", color = "🟠" },
    LunarCrown = { name = "Lunar Crown", speed = 0.4, radius = 14, offsetY = 2, rotation = 10, type = "double", color = "🟠" },
    ThunderRing = { name = "Thunder Ring", speed = 1.2, radius = 13, offsetY = 0, rotation = 5, type = "wave", color = "🟠" },
    FlameOrbit = { name = "Flame Orbit", speed = 0.9, radius = 16, offsetY = 1, rotation = 8, type = "spiral", color = "🟠" },
    FrostCrown = { name = "Frost Crown", speed = 0.3, radius = 12, offsetY = 4, rotation = 0, type = "circle", color = "🟠" },
    StormSpiral = { name = "Storm Spiral", speed = 1.0, radius = 17, offsetY = 2, rotation = 12, type = "spiral", color = "🟠" },
    CometHalo = { name = "Comet Halo", speed = 0.8, radius = 14, offsetY = 1, rotation = 15, type = "star", color = "🟠" },
    MeteorRing = { name = "Meteor Ring", speed = 1.1, radius = 11, offsetY = 0, rotation = 0, type = "circle", color = "🟠" },
    GalaxyOrbit = { name = "Galaxy Orbit", speed = 0.5, radius = 18, offsetY = 3, rotation = 6, type = "circle", color = "🟠" },
    NebulaBloom = { name = "Nebula Bloom", speed = 0.4, radius = 16, offsetY = 4, rotation = 10, type = "star", color = "🟠" },
    GravityRing = { name = "Gravity Ring", speed = 0.5, radius = 16, offsetY = 0, rotation = 0, type = "double", color = "🟠" },
    EnergySpiral = { name = "Energy Spiral", speed = 0.9, radius = 15, offsetY = 2, rotation = 8, type = "spiral", color = "🟠" },
    VortexHalo = { name = "Vortex Halo", speed = 0.7, radius = 18, offsetY = 3, rotation = 5, type = "wave", color = "🟠" },
    PlasmaOrbit = { name = "Plasma Orbit", speed = 1.0, radius = 14, offsetY = 1, rotation = 12, type = "circle", color = "🟠" },
    SolarSpiral = { name = "Solar Spiral", speed = 0.6, radius = 19, offsetY = 4, rotation = 15, type = "spiral", color = "🟠" },
    ThunderCrown = { name = "Thunder Crown", speed = 0.8, radius = 13, offsetY = 5, rotation = 0, type = "double", color = "🟠" },
    CosmicRing = { name = "Cosmic Ring", speed = 0.4, radius = 17, offsetY = 1, rotation = 10, type = "circle", color = "🟠" },
    Starstorm = { name = "Starstorm", speed = 1.1, radius = 12, offsetY = 2, rotation = 6, type = "star", color = "🟠" },
    SupernovaHalo = { name = "Supernova Halo", speed = 0.7, radius = 20, offsetY = 3, rotation = 8, type = "wave", color = "🟠" },
    CelestialOrbit = { name = "Celestial Orbit", speed = 0.5, radius = 16, offsetY = 2, rotation = 12, type = "circle", color = "🟠" },
    EclipseCrown = { name = "Eclipse Crown", speed = 0.5, radius = 16, offsetY = 4, rotation = 8, type = "double", color = "🔴" },
    VoidSpiral = { name = "Void Spiral", speed = 1.0, radius = 14, offsetY = 1, rotation = 12, type = "spiral", color = "🔴" },
    InfinityRing = { name = "Infinity Ring", speed = 0.4, radius = 13, offsetY = 0, rotation = 0, type = "double", color = "🔴" },
    EternalOrbit = { name = "Eternal Orbit", speed = 0.6, radius = 17, offsetY = 2, rotation = 6, type = "circle", color = "🔴" },
    DivineHalo = { name = "Divine Halo", speed = 0.3, radius = 15, offsetY = 5, rotation = 0, type = "circle", color = "🔴" },
    AncientCrown = { name = "Ancient Crown", speed = 0.4, radius = 12, offsetY = 3, rotation = 10, type = "star", color = "🔴" },
    ImmortalSpiral = { name = "Immortal Spiral", speed = 0.9, radius = 18, offsetY = 2, rotation = 15, type = "spiral", color = "🔴" },
    RealityRing = { name = "Reality Ring", speed = 0.5, radius = 14, offsetY = 0, rotation = 5, type = "wave", color = "🔴" },
    DimensionOrbit = { name = "Dimension Orbit", speed = 0.7, radius = 16, offsetY = 3, rotation = 8, type = "circle", color = "🔴" },
    TimeflowHalo = { name = "Timeflow Halo", speed = 0.3, radius = 13, offsetY = 4, rotation = 0, type = "wave", color = "🔴" },
    CosmicCrown = { name = "Cosmic Crown", speed = 0.4, radius = 18, offsetY = 4, rotation = 6, type = "double", color = "🔴" },
    UniverseSpiral = { name = "Universe Spiral", speed = 0.8, radius = 20, offsetY = 2, rotation = 12, type = "spiral", color = "🔴" },
    InfinityBloom = { name = "Infinity Bloom", speed = 0.5, radius = 16, offsetY = 3, rotation = 8, type = "star", color = "🔴" },
    CelestialCrown = { name = "Celestial Crown", speed = 0.3, radius = 17, offsetY = 5, rotation = 0, type = "circle", color = "🔴" },
    EternityRing = { name = "Eternity Ring", speed = 0.4, radius = 14, offsetY = 0, rotation = 10, type = "double", color = "🔴" },
    AstralDominion = { name = "Astral Dominion", speed = 0.6, radius = 19, offsetY = 3, rotation = 5, type = "circle", color = "🔴" },
    DivineOrbit = { name = "Divine Orbit", speed = 0.5, radius = 15, offsetY = 2, rotation = 12, type = "wave", color = "🔴" },
    RealityHalo = { name = "Reality Halo", speed = 0.4, radius = 16, offsetY = 4, rotation = 0, type = "circle", color = "🔴" },
    InfiniteSpiral = { name = "Infinite Spiral", speed = 0.9, radius = 18, offsetY = 1, rotation = 15, type = "spiral", color = "🔴" },
    EternalBloom = { name = "Eternal Bloom", speed = 0.5, radius = 17, offsetY = 3, rotation = 8, type = "star", color = "🔴" },
    ChaosCrown = { name = "Chaos Crown", speed = 0.8, radius = 18, offsetY = 4, rotation = 12, type = "double", color = "🟡" },
    AbyssOrbit = { name = "Abyss Orbit", speed = 0.6, radius = 16, offsetY = 2, rotation = 8, type = "circle", color = "🟡" },
    OblivionRing = { name = "Oblivion Ring", speed = 0.5, radius = 14, offsetY = 0, rotation = 0, type = "double", color = "🟡" },
    VoidCrown = { name = "Void Crown", speed = 0.4, radius = 17, offsetY = 5, rotation = 10, type = "circle", color = "🟡" },
    DarkstarSpiral = { name = "Darkstar Spiral", speed = 1.0, radius = 15, offsetY = 3, rotation = 15, type = "spiral", color = "🟡" },
    BlackholeHalo = { name = "Blackhole Halo", speed = 0.3, radius = 13, offsetY = 1, rotation = 0, type = "wave", color = "🟡" },
    EndworldOrbit = { name = "Endworld Orbit", speed = 0.7, radius = 19, offsetY = 2, rotation = 6, type = "circle", color = "🟡" },
    PhantomDominion = { name = "Phantom Dominion", speed = 0.9, radius = 14, offsetY = 4, rotation = 12, type = "star", color = "🟡" },
    AbyssalCrown = { name = "Abyssal Crown", speed = 0.5, radius = 16, offsetY = 3, rotation = 8, type = "double", color = "🟡" },
    InfiniteVoid = { name = "Infinite Void", speed = 0.6, radius = 12, offsetY = 0, rotation = 5, type = "spiral", color = "🟡" },
    RealityBreaker = { name = "Reality Breaker", speed = 0.9, radius = 20, offsetY = 3, rotation = 10, type = "spiral", color = "🟡" },
    CosmicDestroyer = { name = "Cosmic Destroyer", speed = 0.7, radius = 18, offsetY = 4, rotation = 8, type = "double", color = "🟡" },
    EternalVoid = { name = "Eternal Void", speed = 0.5, radius = 17, offsetY = 2, rotation = 12, type = "wave", color = "🟡" },
    DimensionBreak = { name = "Dimension Break", speed = 0.8, radius = 19, offsetY = 1, rotation = 15, type = "circle", color = "🟡" },
    ChaosSpiral = { name = "Chaos Spiral", speed = 1.0, radius = 16, offsetY = 3, rotation = 6, type = "spiral", color = "🟡" },
    Voidstorm = { name = "Voidstorm", speed = 0.6, radius = 21, offsetY = 5, rotation = 10, type = "star", color = "🟡" },
    BlackstarCrown = { name = "Blackstar Crown", speed = 0.4, radius = 15, offsetY = 4, rotation = 0, type = "double", color = "🟡" },
    OblivionHalo = { name = "Oblivion Halo", speed = 0.5, radius = 18, offsetY = 2, rotation = 8, type = "circle", color = "🟡" },
    ZeroPoint = { name = "Zero Point", speed = 0.3, radius = 14, offsetY = 0, rotation = 5, type = "wave", color = "🟡" },
    FinalEclipse = { name = "Final Eclipse", speed = 0.7, radius = 22, offsetY = 3, rotation = 12, type = "double", color = "🟡" },
    NOVA15 = { name = "NOVA-15", speed = 1.5, radius = 20, offsetY = 3, rotation = 15, type = "double", color = "💠" },
    Fifteenfold = { name = "Fifteenfold", speed = 0.8, radius = 18, offsetY = 2, rotation = 10, type = "spiral", color = "💠" },
    Prophecy = { name = "Prophecy", speed = 0.6, radius = 16, offsetY = 4, rotation = 8, type = "star", color = "💠" },
    TheCollector = { name = "The Collector", speed = 0.4, radius = 14, offsetY = 1, rotation = 0, type = "circle", color = "💠" },
    LostFormation = { name = "Lost Formation", speed = 0.7, radius = 17, offsetY = 3, rotation = 12, type = "wave", color = "💠" },
    ForbiddenOrbit = { name = "Forbidden Orbit", speed = 0.9, radius = 15, offsetY = 0, rotation = 6, type = "double", color = "💠" },
    UnknownEntity = { name = "Unknown Entity", speed = 0.5, radius = 19, offsetY = 5, rotation = 10, type = "spiral", color = "💠" },
    ZeroGravity = { name = "Zero Gravity", speed = 0.3, radius = 13, offsetY = 2, rotation = 0, type = "circle", color = "💠" },
    BeyondReality = { name = "Beyond Reality", speed = 1.0, radius = 16, offsetY = 4, rotation = 15, type = "star", color = "💠" },
    TheLastAura = { name = "The Last Aura", speed = 0.6, radius = 14, offsetY = 1, rotation = 8, type = "wave", color = "💠" },
    HiddenDimension = { name = "Hidden Dimension", speed = 0.8, radius = 22, offsetY = 3, rotation = 12, type = "double", color = "💠" },
    InfiniteMachinery = { name = "Infinite Machinery", speed = 0.6, radius = 18, offsetY = 2, rotation = 10, type = "spiral", color = "💠" },
    AbsoluteZero = { name = "Absolute Zero", speed = 0.4, radius = 16, offsetY = 1, rotation = 0, type = "circle", color = "💠" },
    Worldbreaker = { name = "Worldbreaker", speed = 0.9, radius = 24, offsetY = 4, rotation = 15, type = "star", color = "💠" },
    EternalMachinery = { name = "Eternal Machinery", speed = 0.7, radius = 20, offsetY = 3, rotation = 8, type = "double", color = "💠" },
    UnknownSignal = { name = "Unknown Signal", speed = 0.5, radius = 17, offsetY = 2, rotation = 6, type = "wave", color = "💠" },
    The15thRealm = { name = "The 15th Realm", speed = 0.3, radius = 15, offsetY = 0, rotation = 5, type = "circle", color = "💠" },
    Singularity = { name = "Singularity", speed = 1.0, radius = 21, offsetY = 5, rotation = 12, type = "spiral", color = "💠" },
    Realityexe = { name = "Reality.exe", speed = 0.8, radius = 19, offsetY = 3, rotation = 10, type = "double", color = "💠" }
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentAura = nil
local auraRunning = false
local auraThread = nil
local auraToken = 0
local stopSnake

local propList = {}
local centerPosition = nil
local propFolder = nil
local totalProps = 0

-- =========================================================
-- PROP ENGINE
-- Uses the same server RemoteFunction as the working
-- SetCurrentCFrame prop-handle script.
-- =========================================================

local function getPropFolder()
    local workspaceCom = workspace:FindFirstChild("WorkspaceCom")
    if not workspaceCom then
        return nil
    end

    return workspaceCom:FindFirstChild("001_TrafficCones")
end

local function findSetCurrentCFrame(prop)
    if not prop then
        return nil
    end

    -- The known-working prop script uses this as a direct child.
    local remote = prop:FindFirstChild("SetCurrentCFrame")
    if remote and remote:IsA("RemoteFunction") then
        return remote
    end

    -- Extra robustness if the RemoteFunction is nested.
    for _, descendant in ipairs(prop:GetDescendants()) do
        if descendant.Name == "SetCurrentCFrame"
            and descendant:IsA("RemoteFunction") then
            return descendant
        end
    end

    return nil
end

local function findProps()
    table.clear(propList)
    propFolder = getPropFolder()
    totalProps = 0

    if not propFolder then
        return false
    end

    local playerName = LocalPlayer.Name

    -- IMPORTANT:
    -- Only use props whose name contains the local player's
    -- username, matching the user's working prop script.
    for _, prop in ipairs(propFolder:GetChildren()) do
        if (prop:IsA("BasePart") or prop:IsA("Model"))
            and string.find(prop.Name, playerName, 1, true) then
            table.insert(propList, prop)
        end
    end

    if #propList == 0 then
        return false
    end

    -- Prefer 25 props when available.
    -- If fewer exist, use every owned prop instead of failing.
    totalProps = math.min(#propList, 25)

    return true
end

local remoteCache = setmetatable({}, {__mode = "k"})

local function moveProp(prop, targetCFrame)
    if not prop or not prop.Parent then return end
    local setCF = remoteCache[prop]
    if not setCF or not setCF.Parent then
        setCF = findSetCurrentCFrame(prop)
        remoteCache[prop] = setCF
    end
    if setCF then
        pcall(function() setCF:InvokeServer(targetCFrame) end)
        return
    end
    pcall(function()
        if prop:IsA("BasePart") then prop.CFrame = targetCFrame
        elseif prop:IsA("Model") then prop:PivotTo(targetCFrame) end
    end)
end

-- Sends the whole formation without waiting between props. This keeps the
-- aura synchronized instead of visibly moving one prop at a time.
local function movePropsTogether(items)
    for _, item in ipairs(items) do
        task.spawn(function() moveProp(item[1], item[2]) end)
    end
end

local function getCharacter()
    local character = LocalPlayer.Character

    if not character or not character.Parent then
        return nil
    end

    return character
end


-- =========================================================
-- AURA ENGINE V3
-- Smooth, deterministic and visually different formations.
-- Styles are cached once per aura to avoid rebuilding tables
-- every frame.
-- =========================================================

local auraStyleCache = {}

local function auraHash(text)
    local h = 0
    for i = 1, #text do
        h = (h * 31 + string.byte(text, i)) % 100000
    end
    return h
end

local function getAuraStyle(auraKey, config)
    local cached = auraStyleCache[auraKey]
    if cached then
        return cached
    end

    local h = auraHash(tostring(auraKey) .. "|" .. tostring(config.name))
    cached = {
        style = (h % 14) + 1,
        phase = (h % 628) / 100,
        wave = 0.7 + ((math.floor(h / 17) % 100) / 100) * 1.8,
        height = 0.7 + ((math.floor(h / 29) % 100) / 100) * 2.0,
        twist = ((math.floor(h / 37) % 360) - 180) * math.pi / 180,
        tilt = ((math.floor(h / 43) % 28) - 14) * math.pi / 180,
        direction = (h % 2 == 0) and 1 or -1,
        petals = 3 + (h % 8),
        inner = 0.55 + ((math.floor(h / 53) % 25) / 100),
        outer = 0.95 + ((math.floor(h / 61) % 30) / 100),
        speedMul = 0.78 + ((math.floor(h / 71) % 45) / 100),
    }
    auraStyleCache[auraKey] = cached
    return cached
end

local function getAuraCFrame(auraKey, config, index, total, elapsed, center)
    local speed = tonumber(config.speed) or 0.5
    local baseRadius = tonumber(config.radius) or 12
    local baseY = tonumber(config.offsetY) or 0
    local rotation = math.rad(tonumber(config.rotation) or 0)
    local style = getAuraStyle(auraKey, config)

    local t = (index - 1) / math.max(total, 1)
    local baseAngle = math.pi * 2 * t
    local time = elapsed * speed * style.speedMul * style.direction
    local angle = baseAngle + time + rotation + style.phase

    local radius = baseRadius
    local y = baseY

    if style.style == 1 then
        -- Smooth breathing halo
        local breath = 0.5 + 0.5 * math.sin(time * 1.65 + index * 0.22)
        radius = baseRadius * (0.90 + breath * 0.16)
        y = baseY + math.sin(time * 1.9 + index * 0.35) * 0.55

    elseif style.style == 2 then
        -- Flower / petals
        local petal = math.sin(angle * style.petals + time * 0.55)
        radius = baseRadius * (0.72 + math.abs(petal) * 0.34)
        y = baseY + math.cos(angle * 2 + time) * 0.65

    elseif style.style == 3 then
        -- Helix
        radius = baseRadius * (0.76 + 0.20 * math.sin(t * math.pi * 2 + time))
        y = baseY + math.sin(t * math.pi * 2 + time * 1.35) * style.height * 1.55

    elseif style.style == 4 then
        -- Star
        local star = math.abs(math.cos(angle * 5 + time * 0.65))
        radius = baseRadius * (0.56 + 0.55 * star)
        y = baseY + math.sin(time * 1.7 + index * 0.52) * 0.85

    elseif style.style == 5 then
        -- Infinity / double orbit
        local side = (index % 2 == 0) and 1 or -1
        radius = baseRadius * ((side == 1) and style.outer or style.inner)
        angle = angle + side * (math.pi / 8)
        y = baseY + side * 1.45 + math.sin(time * 1.2 + index) * 0.4

    elseif style.style == 6 then
        -- Flowing wave
        radius = baseRadius + math.sin(angle * 3 + time * 1.9) * (1.1 + style.wave)
        y = baseY + math.sin(angle * 2 + time * 1.4) * style.height

    elseif style.style == 7 then
        -- Vortex
        local depth = (t - 0.5) * 2
        radius = baseRadius * (0.54 + 0.76 * (1 - math.abs(depth) * 0.28))
        angle = angle + depth * 2.35 + time * 0.38
        y = baseY + depth * style.height * 2.2

    elseif style.style == 8 then
        -- Crown
        local crown = math.sin(angle * 4 + time * 0.8)
        radius = baseRadius * (0.70 + 0.32 * math.max(crown, 0))
        y = baseY + 1.5 + math.max(crown, 0) * 2.7

    elseif style.style == 9 then
        -- Comet
        local trail = t
        radius = baseRadius * (0.58 + trail * 0.50)
        angle = angle - trail * 1.45
        y = baseY + math.sin(time * 1.45 + trail * math.pi * 2) * 1.25

    elseif style.style == 10 then
        -- Galaxy arms
        local arm = math.sin(t * math.pi * 4 + time)
        radius = baseRadius * (0.52 + 0.58 * math.abs(arm))
        angle = angle + arm * 1.05
        y = baseY + math.sin(t * math.pi * 4 + time * 0.75) * 2.15

    elseif style.style == 11 then
        -- Diamond pulse
        local diamond = 1 - math.abs(math.sin(angle * 4 + time))
        radius = baseRadius * (0.62 + diamond * 0.58)
        y = baseY + math.cos(angle * 4 + time) * 1.0

    elseif style.style == 12 then
        -- Three orbital lanes
        local lane = (index % 3) - 1
        radius = baseRadius * (1 + lane * 0.17)
        angle = angle + lane * 0.82
        y = baseY + lane * 1.65 + math.sin(time * 1.6 + index) * 0.5

    elseif style.style == 13 then
        -- Ripple sphere
        local wave = math.sin(t * math.pi * 2 + time * 1.2)
        radius = baseRadius * (0.72 + math.abs(wave) * 0.42)
        y = baseY + math.cos(t * math.pi * 4 + time) * 2.0

    else
        -- Slow orbital ribbon
        local ribbon = math.sin(t * math.pi * 2 + time)
        radius = baseRadius * (0.82 + ribbon * 0.20)
        angle = angle + math.sin(time * 0.55) * 0.65
        y = baseY + ribbon * 2.4
    end

    -- Original aura type is still respected as a secondary motion layer.
    if config.type == "wave" then
        radius += math.sin(angle * 3 + time * 1.65) * 1.25
        y += math.sin(time * 2 + index * 0.6) * 0.55
    elseif config.type == "spiral" then
        radius += t * 2.8
        y += (t - 0.5) * 2.0
        angle += t * 1.8
    elseif config.type == "star" then
        radius *= (index % 2 == 0) and 0.68 or 1.08
    elseif config.type == "double" then
        local side = (index % 2 == 0) and 1 or -1
        radius *= (side == 1) and 1.12 or 0.82
        y += side * 0.72
    end

    -- Universal micro-motion prevents dead/static frames.
    radius += math.sin(elapsed * speed * 2.0 + index * 0.31 + style.phase) * 0.28
    y += math.cos(elapsed * speed * 1.65 + index * 0.43) * 0.20

    local position = center + Vector3.new(
        math.cos(angle) * radius,
        y,
        math.sin(angle) * radius
    )

    local look = CFrame.lookAt(position, center)
    return look * CFrame.Angles(
        math.sin(angle + style.twist) * style.tilt,
        angle * 0.12,
        math.cos(angle + style.phase) * style.tilt
    )
end

local function runAuraAnimation(auraKey, config, token)
    local updateInterval = 0.055

    while auraRunning
        and currentAura == auraKey
        and auraToken == token do

        local character = getCharacter()

        if not character then
            task.wait(0.25)
            continue
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")

        if not hrp then
            task.wait(0.1)
            continue
        end

        -- Refresh props if they were recreated by the game.
        if not propFolder
            or not propFolder.Parent
            or #propList == 0 then
            findProps()
        end

        local total = math.min(totalProps, #propList)

        if total > 0 then
            centerPosition = hrp.Position
            local elapsed = os.clock()

            local batch = {}
            for index = 1, total do
                if not auraRunning or currentAura ~= auraKey or auraToken ~= token then break end
                local prop = propList[index]
                if prop and prop.Parent then
                    batch[#batch + 1] = {prop, getAuraCFrame(auraKey, config, index, total, elapsed, centerPosition)}
                end
            end
            movePropsTogether(batch)
        end

        task.wait(updateInterval)
    end
end

local function stopAura()
    auraRunning = false
    currentAura = nil

    -- Invalidates any previous animation loop.
    auraToken += 1

    -- Do not coroutine.close() a running thread. Let the token/state
    -- condition end it safely.
    auraThread = nil
end

local function startAura(auraKey)
    stopSnake()
    local config = AllAuraConfigs[auraKey]

    if not config then
        warn("[MANI AURA] Unknown aura:", auraKey)
        return
    end

    stopAura()

    if not findProps() then
        print("[MANI AURA] No owned props found in WorkspaceCom/001_TrafficCones")
        return
    end

    if totalProps <= 0 then
        print("[MANI AURA] No usable props found")
        return
    end

    currentAura = auraKey
    auraRunning = true

    auraToken += 1
    local myToken = auraToken

    auraThread = task.spawn(function()
        runAuraAnimation(auraKey, config, myToken)
    end)

    print(
        config.color
        .. " "
        .. config.name
        .. " activated with "
        .. totalProps
        .. " props"
    )
end

local function resetProps()
    stopAura()

    if not findProps() then
        return false
    end

    local character = getCharacter()
    if not character then
        return false
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return false
    end

    local resetCFrame = CFrame.new(hrp.Position)

    for _, prop in ipairs(propList) do
        moveProp(prop, resetCFrame)
        task.wait(0.03)
    end

    return true
end


-- =========================================================
-- SNAKE ENGINE V3
-- Up to 25 owned props become one smooth snake.
-- 20 controls/features are exposed in the Snake tab.
-- =========================================================

local snakeRunning = false
local snakeAutoTravel = false
local snakeFollowPlayer = true
local snakeReverse = false
local snakeWave = true
local snakePatrol = false
local snakeSmoothTurns = true
local snakeHeadLead = true
local snakeBreathing = true
local snakeTailWhip = true
local snakeSpiralTravel = false
local snakeRandomStops = true
local snakeHover = false
local snakeLength = 15
local snakeSpeed = 8
local snakeSpacing = 2.15
local snakeWaveHeight = 0.65
local snakeTurnSmooth = 0.18
local snakeTarget = nil
local snakeHeadPosition = nil
local snakeNextTargetAt = 0
local snakeHeading = nil
local snakeTravelSeed = 0
local snakeTrail = {}

local function getSnakeProps()
    if not propFolder or not propFolder.Parent or #propList == 0 then findProps() end
    local out = {}
    local count = math.clamp(tonumber(snakeLength) or 15, 1, math.min(25, #propList))
    for i=1,count do if propList[i] and propList[i].Parent then out[#out+1]=propList[i] end end
    return out
end

local function chooseSnakeTarget(origin)
    snakeTravelSeed += 1
    local seed = snakeTravelSeed * 17 + math.floor(os.clock()*10)
    local angle = math.rad((seed*47)%360)
    local distance = 22 + ((seed*13)%34)
    local y = snakeHover and (2+((seed*7)%5)) or 0
    return origin + Vector3.new(math.cos(angle)*distance,y,math.sin(angle)*distance)
end

local function sampleTrail(secondsAgo, fallback)
    if #snakeTrail == 0 then return fallback end
    local wanted = os.clock() - secondsAgo
    for i=1,#snakeTrail-1 do
        local newer, older = snakeTrail[i], snakeTrail[i+1]
        if newer.t >= wanted and older.t <= wanted then
            local span = math.max(newer.t-older.t, 0.001)
            local a = math.clamp((wanted-older.t)/span,0,1)
            return older.p:Lerp(newer.p,a)
        end
    end
    return snakeTrail[#snakeTrail].p
end

local function moveSnake()
    local character=getCharacter()
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local props=getSnakeProps(); local count=#props
    if count==0 then return end
    local now=os.clock(); local playerPos=hrp.Position; local forward=hrp.CFrame.LookVector
    local desiredHead
    if snakeAutoTravel then
        if not snakeTarget or now>=snakeNextTargetAt or (snakeTarget-playerPos).Magnitude<7 then
            snakeTarget=chooseSnakeTarget(playerPos)
            snakeNextTargetAt=now+(snakeRandomStops and 4.5 or 8)
        end
        desiredHead=snakeTarget
    else
        desiredHead=playerPos+(snakeHeadLead and forward*2.5 or Vector3.zero)
        if snakeHover then desiredHead += Vector3.new(0,2.2,0) end
    end
    snakeHeadPosition=snakeHeadPosition and snakeHeadPosition:Lerp(desiredHead,math.clamp(1-math.exp(-math.max(snakeSpeed,1)*0.10),0.08,0.9)) or desiredHead
    local wantedDir=(desiredHead-playerPos)
    if wantedDir.Magnitude<0.01 then wantedDir=forward end
    wantedDir=wantedDir.Unit
    snakeHeading=snakeHeading and snakeHeading:Lerp(wantedDir,math.clamp(snakeTurnSmooth,0.03,0.5)).Unit or wantedDir
    local head=snakeHeadPosition
    table.insert(snakeTrail,1,{t=now,p=head})
    while #snakeTrail>160 do table.remove(snakeTrail) end
    local batch={}
    for i=1,count do
        local segIndex=snakeReverse and (count-i) or (i-1)
        local delay=(segIndex*snakeSpacing)/math.max(snakeSpeed,1)
        local pos=sampleTrail(delay,head-snakeHeading*(segIndex*snakeSpacing))
        local side=Vector3.new(-snakeHeading.Z,0,snakeHeading.X)
        if snakeWave then pos += side*math.sin(now*snakeSpeed*0.32-segIndex*0.72)*(snakeWaveHeight*(1+segIndex/count*0.45)) end
        if snakeSpiralTravel then local q=segIndex/count*math.pi*1.5; pos += Vector3.new(math.cos(q+now)*0.5,math.sin(q+now*0.8)*0.3,math.sin(q+now)*0.5) end
        if snakeBreathing then pos += Vector3.new(0,math.sin(now*2-segIndex*0.35)*0.12,0) end
        if snakeTailWhip and segIndex>math.max(2,count-6) then pos += side*math.sin(now*4+segIndex)*((segIndex-(count-6))/6)*1.0 end
        local nextPos=sampleTrail(math.max(0,delay-0.04),pos+snakeHeading*0.3)
        local cf=(nextPos-pos).Magnitude>0.01 and CFrame.lookAt(pos,nextPos) or CFrame.new(pos)
        batch[#batch+1]={props[i],cf}
    end
    movePropsTogether(batch)
end

local function startSnake()
    if snakeRunning then return end
    if not findProps() then return end
    snakeRunning=true; snakeTarget=nil; snakeHeadPosition=nil; snakeHeading=nil; snakeTrail={}
    task.spawn(function() while snakeRunning do pcall(moveSnake); task.wait(0.055) end end)
end

stopSnake=function()
    snakeRunning=false; snakeTarget=nil; snakeHeadPosition=nil; snakeHeading=nil; snakeTrail={}
end

-- =========================================================
-- ROPE ENGINE
-- =========================================================
local ropeP1=""; local ropeP2=""; local ropeIncludeMe=false; local ropeRunning=false
local ropeWave=0.6; local ropeSag=0.18; local ropeSegments=15; local ropeSpeed=3

local function getPlayerByName(name)
    name=string.lower(tostring(name or "")); if name=="" then return nil end
    for _,plr in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(plr.Name),name,1,true) then return plr end
    end
end
local function getHRP(plr) local c=plr and plr.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function ropePoint(t,a,b)
    local mid=(a+b)*0.5; local sag=math.clamp((a-b).Magnitude*ropeSag,2,14)
    mid-=Vector3.new(0,sag,0)
    return a:Lerp(mid,t):Lerp(mid:Lerp(b,t),t)
end
local function stopRope() ropeRunning=false end
local function startRope()
    if ropeRunning then return end
    if not findProps() then return end
    ropeRunning=true
    task.spawn(function()
        while ropeRunning do
            local p1=ropeIncludeMe and LocalPlayer or getPlayerByName(ropeP1)
            local p2=getPlayerByName(ropeP2)
            local h1,h2=getHRP(p1),getHRP(p2); local props=getSnakeProps()
            if h1 and h2 and #props>0 then
                local a,b=h1.Position,h2.Position; local dist=(a-b).Magnitude
                local count=math.min(#props,math.clamp(math.floor(dist/2),4,math.max(4,ropeSegments)))
                local batch={}; local now=os.clock()
                for i=1,count do
                    local t=i/(count+1); local pos=ropePoint(t,a,b)+Vector3.new(0,math.sin(t*math.pi*4+now*ropeSpeed)*ropeWave,0)
                    batch[#batch+1]={props[i],CFrame.lookAt(pos,b)}
                end
                movePropsTogether(batch)
            end
            task.wait(0.055)
        end
    end)
end

-- Mobile-first sizing hint. Roblox exposes display size categories for UI adaptation.
pcall(function()
    local GuiService = game:GetService("GuiService")
    if GuiService.ViewportDisplaySize == Enum.DisplaySize.Small then
        isFull = false
    end
end)

-- GUI handling

-- ============================================================
-- MANI PROP GUI V.1 — REDZLIB V5 EDITION
-- GUI layer only is migrated. Original prop/aura/snake/rope
-- engine above remains the working engine from MANI PROP V.1.
-- ============================================================

local RedzLib = nil
local REDZ_URL = "https://raw.githubusercontent.com/RedzLib/RedzLibV5/refs/heads/main/Source.lua"

for attempt = 1, 3 do
    local ok, result = pcall(function()
        local source = game:HttpGet(REDZ_URL)
        if type(source) ~= "string" or #source < 1000 then
            error("RedzLib source download was empty/invalid")
        end
        local fn = loadstring(source)
        if type(fn) ~= "function" then
            error("loadstring failed for RedzLib source")
        end
        return fn()
    end)
    if ok and type(result) == "table" and type(result.MakeWindow) == "function" then
        RedzLib = result
        break
    end
    warn("[MANI PROP] RedzLib load attempt " .. attempt .. " failed:", result)
    task.wait(1)
end

if not RedzLib then
    warn("[MANI PROP] GUI stopped: RedzLib could not be loaded.")
    return
end

local Window = RedzLib:MakeWindow({
    Title = "MANI PROP GUI V.1",
    SubTitle = "by MANISH_K05",
    SaveFolder = "MANI_PROP_GUI_V1"
})

-- Native RedzLib tabs. No custom replacement GUI is used.
local Tabs = {}
Tabs.Common = Window:MakeTab({Name = "🟢 Common", Icon = "sparkles"})
Tabs.Uncommon = Window:MakeTab({Name = "🔵 Uncommon", Icon = "droplets"})
Tabs.Rare = Window:MakeTab({Name = "🟣 Rare", Icon = "gem"})
Tabs.Epic = Window:MakeTab({Name = "🟠 Epic", Icon = "flame"})
Tabs.Legendary = Window:MakeTab({Name = "🔴 Legendary", Icon = "star"})
Tabs.Mythic = Window:MakeTab({Name = "🟡 Mythic", Icon = "infinity"})
Tabs.Secret = Window:MakeTab({Name = "💠 Secret", Icon = "eye"})
Tabs.Snake = Window:MakeTab({Name = "🐍 Snake", Icon = "move-3d"})
Tabs.Rope = Window:MakeTab({Name = "🪢 Rope", Icon = "link"})
Tabs.Settings = Window:MakeTab({Name = "⚙️ Settings", Icon = "settings"})

local function addAuraTab(tab, title, list)
    tab:AddSection(title)
    tab:AddParagraph({
        Title = "MANI PROP ENGINE",
        Text = "Select an aura. The original V1 aura engine will use your detected props."
    })
    for _, key in ipairs(list) do
        local cfg = AllAuraConfigs[key]
        if cfg then
            tab:AddButton({
                Name = cfg.color .. " " .. cfg.name,
                Desc = "Activate " .. cfg.name,
                Callback = function()
                    startAura(key)
                end
            })
        end
    end
end

local commonList = {"SoftGlow","FreshBreeze","CalmRing","TinyOrbit","SimpleHalo","FloatingMist","GentleWave","LightBloom","MiniSpiral","CloudRing","SoftOrbit","BrightCircle","PeaceAura","BreezeHalo","MorningGlow","FloatingStars","LittleGalaxy","DreamRing","PureHalo","SkyBloom"}
addAuraTab(Tabs.Common, "🟢 Common Auras", commonList)

local uncommonList = {"AquaOrbit","FrostRing","CrystalWave","WindSpiral","Rainfall","BlueComet","IceHalo","MistSpiral","OceanRing","CloudSpiral","SnowOrbit","SilverBloom","MoonRing","StarOrbit","SkySpiral","FrozenHalo","CrystalOrbit","TidalWave","WinterBloom","ArcticRing"}
addAuraTab(Tabs.Uncommon, "🔵 Uncommon Auras", uncommonList)

local rareList = {"MysticSpiral","PhantomRing","ArcaneOrbit","SoulHalo","AstralBloom","RuneCircle","DreamSpiral","SpiritOrbit","Moonveil","Starveil","EtherRing","MirageOrbit","TwilightHalo","SpectralBloom","MysticCrown","AstralRing","PhantomOrbit","SoulSpiral","ArcaneBloom","Dreamveil"}
addAuraTab(Tabs.Rare, "🟣 Rare Auras", rareList)

local epicList = {"SolarCrown","LunarCrown","ThunderRing","FlameOrbit","FrostCrown","StormSpiral","CometHalo","MeteorRing","GalaxyOrbit","NebulaBloom","GravityRing","EnergySpiral","VortexHalo","PlasmaOrbit","SolarSpiral","ThunderCrown","CosmicRing","Starstorm","SupernovaHalo","CelestialOrbit"}
addAuraTab(Tabs.Epic, "🟠 Epic Auras", epicList)

local legendaryList = {"EclipseCrown","VoidSpiral","InfinityRing","EternalOrbit","DivineHalo","AncientCrown","ImmortalSpiral","RealityRing","DimensionOrbit","TimeflowHalo","CosmicCrown","UniverseSpiral","InfinityBloom","CelestialCrown","EternityRing","AstralDominion","DivineOrbit","RealityHalo","InfiniteSpiral","EternalBloom"}
addAuraTab(Tabs.Legendary, "🔴 Legendary Auras", legendaryList)

local mythicList = {"ChaosCrown","AbyssOrbit","OblivionRing","VoidCrown","DarkstarSpiral","BlackholeHalo","EndworldOrbit","PhantomDominion","AbyssalCrown","InfiniteVoid","RealityBreaker","CosmicDestroyer","EternalVoid","DimensionBreak","ChaosSpiral","Voidstorm","BlackstarCrown","OblivionHalo","ZeroPoint","FinalEclipse"}
addAuraTab(Tabs.Mythic, "🟡 Mythic Auras", mythicList)

local secretList = {"NOVA15","Fifteenfold","Prophecy","TheCollector","LostFormation","ForbiddenOrbit","UnknownEntity","ZeroGravity","BeyondReality","TheLastAura","HiddenDimension","InfiniteMachinery","AbsoluteZero","Worldbreaker","EternalMachinery","UnknownSignal","The15thRealm","Singularity","Realityexe"}
addAuraTab(Tabs.Secret, "💠 Secret Auras", secretList)

-- ========================= SNAKE =========================
Tabs.Snake:AddSection("🐍 Snake Engine")
Tabs.Snake:AddParagraph({Title="Snake",Text="Uses the same owned props as V1. Toggle the engine first, then tune movement."})
Tabs.Snake:AddToggle({Name="Snake Enabled", Desc="Start/stop the prop snake", Default=false, Callback=function(v) if v then startSnake() else stopSnake() end})
Tabs.Snake:AddToggle({Name="Auto Travel", Desc="Snake travels to generated destinations", Default=false, Callback=function(v) snakeAutoTravel=v end})
Tabs.Snake:AddToggle({Name="Follow Player", Desc="Follow your character when Auto Travel is off", Default=true, Callback=function(v) snakeFollowPlayer=v; if v then snakeAutoTravel=false end end})
Tabs.Snake:AddToggle({Name="Reverse", Desc="Reverse segment order", Default=false, Callback=function(v) snakeReverse=v end})
Tabs.Snake:AddToggle({Name="Wave", Desc="Add side-to-side body wave", Default=true, Callback=function(v) snakeWave=v end})
Tabs.Snake:AddToggle({Name="Smooth Turns", Desc="Smooth snake direction changes", Default=true, Callback=function(v) snakeSmoothTurns=v; snakeTurnSmooth=v and 0.18 or 0.5 end})
Tabs.Snake:AddToggle({Name="Head Lead", Desc="Place the head slightly ahead of you", Default=true, Callback=function(v) snakeHeadLead=v end})
Tabs.Snake:AddToggle({Name="Hover", Desc="Raise the snake above the ground", Default=false, Callback=function(v) snakeHover=v end})
Tabs.Snake:AddToggle({Name="Breathing", Desc="Subtle vertical body motion", Default=true, Callback=function(v) snakeBreathing=v end})
Tabs.Snake:AddToggle({Name="Tail Whip", Desc="Extra motion at the tail", Default=true, Callback=function(v) snakeTailWhip=v end})
Tabs.Snake:AddToggle({Name="Spiral Travel", Desc="Add spiral travel motion", Default=false, Callback=function(v) snakeSpiralTravel=v end})
Tabs.Snake:AddToggle({Name="Random Destinations", Desc="Change Auto Travel destinations automatically", Default=true, Callback=function(v) snakeRandomStops=v end})
Tabs.Snake:AddToggle({Name="Patrol", Desc="Patrol mode uses automatic travel", Default=false, Callback=function(v) snakePatrol=v; snakeAutoTravel=v end})
Tabs.Snake:AddSlider({Name="Length", Min=1, Max=25, Increase=1, Default=15, Callback=function(v) snakeLength=math.clamp(math.floor(v+0.5),1,25) end})
Tabs.Snake:AddSlider({Name="Speed", Min=1, Max=25, Increase=1, Default=8, Callback=function(v) snakeSpeed=v end})
Tabs.Snake:AddSlider({Name="Spacing", Min=0.5, Max=5, Increase=0.1, Default=2.15, Callback=function(v) snakeSpacing=v end})
Tabs.Snake:AddSlider({Name="Wave Strength", Min=0, Max=3, Increase=0.05, Default=0.65, Callback=function(v) snakeWaveHeight=v end})
Tabs.Snake:AddSlider({Name="Turn Smoothness", Min=0.03, Max=0.5, Increase=0.01, Default=0.18, Callback=function(v) snakeTurnSmooth=v end})
Tabs.Snake:AddButton({Name="New Destination", Desc="Pick a new Auto Travel target", Callback=function() local c=getCharacter(); local h=c and c:FindFirstChild("HumanoidRootPart"); if h then snakeTarget=chooseSnakeTarget(h.Position); snakeNextTargetAt=0 end end})
Tabs.Snake:AddButton({Name="Stop Snake", Desc="Stop the snake and release the engine", Callback=function() stopSnake() end})

-- ========================== ROPE ==========================
Tabs.Rope:AddSection("🪢 Rope Engine")
Tabs.Rope:AddParagraph({Title="Rope",Text="Connect two players with your owned props. Player names can be partial usernames."})
Tabs.Rope:AddTextBox({Name="Player 1", Default="", PlaceholderText="Username", Callback=function(v) ropeP1=tostring(v) end})
Tabs.Rope:AddTextBox({Name="Player 2", Default="", PlaceholderText="Username", Callback=function(v) ropeP2=tostring(v) end})
Tabs.Rope:AddToggle({Name="Include Me", Desc="Use your character as Player 1", Default=false, Callback=function(v) ropeIncludeMe=v end})
Tabs.Rope:AddButton({Name="Start Rope", Desc="Start the rope engine", Callback=function() startRope() end})
Tabs.Rope:AddButton({Name="Stop Rope", Desc="Stop the rope engine", Callback=function() stopRope() end})
Tabs.Rope:AddSlider({Name="Wave", Min=0, Max=2, Increase=0.05, Default=0.6, Callback=function(v) ropeWave=v end})
Tabs.Rope:AddSlider({Name="Sag", Min=0.05, Max=0.5, Increase=0.01, Default=0.18, Callback=function(v) ropeSag=v end})
Tabs.Rope:AddSlider({Name="Max Segments", Min=4, Max=25, Increase=1, Default=15, Callback=function(v) ropeSegments=math.floor(v+0.5) end})
Tabs.Rope:AddSlider({Name="Wave Speed", Min=0.5, Max=8, Increase=0.1, Default=3, Callback=function(v) ropeSpeed=v end})

-- ========================= SETTINGS ========================
Tabs.Settings:AddSection("⚙️ MANI PROP")
local propInfo = Tabs.Settings:AddParagraph({Title="Props",Text="Scanning..."})
local profileInfo = Tabs.Settings:AddParagraph({Title="👤 Profile",Text="Loading..."})

local function updateInfo()
    pcall(function()
        findProps()
        propInfo:Set(tostring(#propList) .. " props found • using " .. tostring(totalProps))
        local aura="None"
        if currentAura and AllAuraConfigs[currentAura] then aura=AllAuraConfigs[currentAura].name end
        local status = "Ready"
        if snakeRunning then status="Snake Active" elseif ropeRunning then status="Rope Active" elseif auraRunning then status="Aura Active" end
        profileInfo:Set("Profile", "Display: "..LocalPlayer.DisplayName.."\nUsername: @"..LocalPlayer.Name.."\nStatus: "..status.."\nAura: "..aura)
    end)
end

Tabs.Settings:AddButton({Name="Refresh Props", Desc="Re-scan WorkspaceCom/001_TrafficCones", Callback=function() findProps(); updateInfo() end})
Tabs.Settings:AddButton({Name="Stop Aura", Desc="Stop the current aura", Callback=function() stopAura() end})
Tabs.Settings:AddButton({Name="Stop Snake", Desc="Stop snake movement", Callback=function() stopSnake() end})
Tabs.Settings:AddButton({Name="Stop Rope", Desc="Stop rope movement", Callback=function() stopRope() end})
Tabs.Settings:AddButton({Name="STOP ALL", Desc="Stop aura, snake and rope", Callback=function() stopAura(); stopSnake(); stopRope() end})
Tabs.Settings:AddButton({Name="Reset Props", Desc="Stop aura and return props to your character", Callback=function() resetProps() end})
Tabs.Settings:AddButton({Name="Find Props", Desc="Print detected prop count", Callback=function() findProps(); print("[MANI PROP] Found",#propList,"props; using",totalProps) end})
Tabs.Settings:AddParagraph({Title="MANI GUI V.1",Text="by MANISH_K05\nOriginal V1 prop engine + native RedzLib controls"})

-- Native RedzLib minimize/reopen button.
Window:AddMinimizeButton({Button = {Image = "rbxassetid://10734896206"}, Corner = true})

-- Initial scan and live status refresh.
findProps()
updateInfo()

print("[MANI PROP GUI V.1] Loaded successfully")
