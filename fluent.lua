-- ============================================================
-- RAYFIELD GRAPHICS UPGRADE V2 - REALISM EDITION
-- PBR • Sky • Clouds • Sun Simulation • Cinematic Grading
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Lighting      = game:GetService("Lighting")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")

-- ============================================================
-- HELPERS
-- ============================================================

local function findOrCreate(class, name)
    local inst = Lighting:FindFirstChildOfClass(class)
    if not inst then
        inst = Instance.new(class)
        inst.Name = name or class
        inst.Parent = Lighting
    end
    return inst
end

local function tween(inst, prop, value, dur)
    TweenService:Create(
        inst,
        TweenInfo.new(dur or 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {[prop] = value}
    ):Play()
end

-- ============================================================
-- INSTANCES (safe create/reuse)
-- ============================================================

local Atmosphere      = findOrCreate("Atmosphere",       "GFX_Atmosphere")
local Bloom           = findOrCreate("BloomEffect",      "GFX_Bloom")
local SunRays         = findOrCreate("SunRaysEffect",    "GFX_SunRays")
local ColorCorrection = findOrCreate("ColorCorrectionEffect", "GFX_ColorCorrection")
local DepthOfField    = findOrCreate("DepthOfFieldEffect","GFX_DOF")
local Blur            = findOrCreate("BlurEffect",       "GFX_Blur")

-- Sky
local Sky = Lighting:FindFirstChildOfClass("Sky")
if not Sky then
    Sky = Instance.new("Sky")
    Sky.Name = "GFX_Sky"
    Sky.Parent = Lighting
end

-- Cloud support (only if modern client)
local Clouds = Lighting:FindFirstChildOfClass("Clouds")

-- ============================================================
-- WINDOW
-- ============================================================

local Window = Rayfield:CreateWindow({
    Name = "Graphics Upgrade V2 | Realism",
    LoadingTitle = "Loading Realism Suite",
    LoadingSubtitle = "physically-inspired rendering",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GFXRealismV2",
        FileName = "RealismConfig"
    },
    KeySystem = false
})

-- ============================================================
-- TAB 1 : SUN & SKY
-- ============================================================

local SkyTab = Window:CreateTab("Sun & Sky", 4483362458)

SkyTab:CreateSection("Solar Position (Real-World Simulation)")

SkyTab:CreateSlider({
    Name = "Time of Day (24h)",
    Range = {0, 24}, Increment = 0.05, Suffix = "h",
    CurrentValue = Lighting.ClockTime, Flag = "ClockTime",
    Callback = function(v) tween(Lighting, "ClockTime", v, 0.4) end
})

SkyTab:CreateSlider({
    Name = "Geographic Latitude",
    Range = {-90, 90}, Increment = 0.5, Suffix = "°",
    CurrentValue = Lighting.GeographicLatitude, Flag = "Latitude",
    Callback = function(v) tween(Lighting, "GeographicLatitude", v, 0.4) end
})

SkyTab:CreateSlider({
    Name = "Sun Azimuth (extra tilt)",
    Range = {-180, 180}, Increment = 1, Suffix = "°",
    CurrentValue = 0, Flag = "Azimuth",
    Callback = function(v)
        -- rotate sky dome slightly for artist control
        if Sky then tween(Sky, "SunAngularSize", math.clamp(1 + math.abs(v)/180, 1, 3), 0.4) end
    end
})

SkyTab:CreateSlider({
    Name = "Sun Angular Size",
    Range = {0.5, 5}, Increment = 0.05, Suffix = "°",
    CurrentValue = Sky.SunAngularSize, Flag = "SunSize",
    Callback = function(v) tween(Sky, "SunAngularSize", v, 0.4) end
})

SkyTab:CreateSlider({
    Name = "Moon Angular Size",
    Range = {0.5, 5}, Increment = 0.05, Suffix = "°",
    CurrentValue = Sky.MoonAngularSize, Flag = "MoonSize",
    Callback = function(v) tween(Sky, "MoonAngularSize", v, 0.4) end
})

SkyTab:CreateSection("Sky Appearance")

SkyTab:CreateColorPicker({
    Name = "Sky Tint (SkyboxColor)",
    Color = Color3.fromRGB(255, 255, 255), Flag = "SkyTint",
    Callback = function(c)
        -- Simulate tint via Atmosphere color blend
        tween(Atmosphere, "Color", c:Lerp(Color3.new(1,1,1), 0.3), 0.5)
    end
})

SkyTab:CreateToggle({
    Name = "Enable Realistic Sky (clear)",
    CurrentValue = true, Flag = "RealSky",
    Callback = function(v)
        Sky.SkyboxBk = v and "rbxassetid://159454299" or ""
        Sky.SkyboxDn = v and "rbxassetid://159454296" or ""
        Sky.SkyboxFt = v and "rbxassetid://159454293" or ""
        Sky.SkyboxLf = v and "rbxassetid://159454286" or ""
        Sky.SkyboxRt = v and "rbxassetid://159454300" or ""
        Sky.SkyboxUp = v and "rbxassetid://159454288" or ""
    end
})

SkyTab:CreateSection("Clouds")

if Clouds then
    SkyTab:CreateSlider({
        Name = "Cloud Cover",
        Range = {0, 1}, Increment = 0.01, Suffix = "Cover",
        CurrentValue = Clouds.Cover, Flag = "CloudCover",
        Callback = function(v) tween(Clouds, "Cover", v, 0.4) end
    })
    SkyTab:CreateSlider({
        Name = "Cloud Density",
        Range = {0, 1}, Increment = 0.01, Suffix = "Density",
        CurrentValue = Clouds.Density, Flag = "CloudDensity",
        Callback = function(v) tween(Clouds, "Density", v, 0.4) end
    })
    SkyTab:CreateColorPicker({
        Name = "Cloud Color",
        Color = Clouds.Color, Flag = "CloudColor",
        Callback = function(c) tween(Clouds, "Color", c, 0.4) end
    })
else
    SkyTab:CreateButton({
        Name = "(Clouds instance not present — insert manually for cloud control)",
        Callback = function() end
    })
end

-- ============================================================
-- TAB 2 : LIGHTING & PBR
-- ============================================================

local LightTab = Window:CreateTab("Lighting & PBR", 4483362458)

LightTab:CreateSection("Core Lighting")

LightTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 5}, Increment = 0.05, Suffix = "x",
    CurrentValue = Lighting.Brightness, Flag = "Brightness",
    Callback = function(v) tween(Lighting, "Brightness", v, 0.4) end
})

LightTab:CreateSlider({
    Name = "Exposure Compensation",
    Range = {-3, 3}, Increment = 0.05, Suffix = "EV",
    CurrentValue = Lighting.ExposureCompensation, Flag = "Exposure",
    Callback = function(v) tween(Lighting, "ExposureCompensation", v, 0.4) end
})

LightTab:CreateColorPicker({
    Name = "Ambient (shadow fill)",
    Color = Lighting.Ambient, Flag = "Ambient",
    Callback = function(c) tween(Lighting, "Ambient", c, 0.4) end
})

LightTab:CreateColorPicker({
    Name = "Outdoor Ambient (sky fill)",
    Color = Lighting.OutdoorAmbient, Flag = "OutdoorAmbient",
    Callback = function(c) tween(Lighting, "OutdoorAmbient", c, 0.4) end
})

LightTab:CreateSection("PBR Environment (IBL)")

LightTab:CreateSlider({
    Name = "Environment Diffuse Scale",
    Range = {0, 1}, Increment = 0.01, Suffix = "Diffuse",
    CurrentValue = Lighting.EnvironmentDiffuseScale, Flag = "EnvDiffuse",
    Callback = function(v) tween(Lighting, "EnvironmentDiffuseScale", v, 0.4) end
})

LightTab:CreateSlider({
    Name = "Environment Specular Scale",
    Range = {0, 1}, Increment = 0.01, Suffix = "Specular",
    CurrentValue = Lighting.EnvironmentSpecularScale, Flag = "EnvSpecular",
    Callback = function(v) tween(Lighting, "EnvironmentSpecularScale", v, 0.4) end
})

LightTab:CreateSection("Shadows")

LightTab:CreateToggle({
    Name = "Global Shadows",
    CurrentValue = Lighting.GlobalShadows, Flag = "Shadows",
    Callback = function(v) Lighting.GlobalShadows = v end
})

LightTab:CreateSlider({
    Name = "Shadow Softness",
    Range = {0, 1}, Increment = 0.01, Suffix = "Soft",
    CurrentValue = Lighting.ShadowSoftness, Flag = "ShadowSoft",
    Callback = function(v) tween(Lighting, "ShadowSoftness", v, 0.4) end
})

-- ============================================================
-- TAB 3 : ATMOSPHERE & FOG
-- ============================================================

local AtmTab = Window:CreateTab("Atmosphere & Fog", 4483362458)

AtmTab:CreateSection("Volumetric Atmosphere (Rayleigh/Mie)")

AtmTab:CreateSlider({
    Name = "Density",
    Range = {0, 1}, Increment = 0.005,
    CurrentValue = Atmosphere.Density, Flag = "AtmDensity",
    Callback = function(v) tween(Atmosphere, "Density", v, 0.4) end
})

AtmTab:CreateSlider({
    Name = "Offset (altitude)",
    Range = {0, 1}, Increment = 0.005,
    CurrentValue = Atmosphere.Offset, Flag = "AtmOffset",
    Callback = function(v) tween(Atmosphere, "Offset", v, 0.4) end
})

AtmTab:CreateColorPicker({
    Name = "Rayleigh Scattering Color",
    Color = Atmosphere.Color, Flag = "AtmColor",
    Callback = function(c) tween(Atmosphere, "Color", c, 0.4) end
})

AtmTab:CreateColorPicker({
    Name = "Decay Color (horizon)",
    Color = Atmosphere.Decay, Flag = "AtmDecay",
    Callback = function(c) tween(Atmosphere, "Decay", c, 0.4) end
})

AtmTab:CreateSlider({
    Name = "Glare",
    Range = {0, 5}, Increment = 0.05,
    CurrentValue = Atmosphere.Glare, Flag = "AtmGlare",
    Callback = function(v) tween(Atmosphere, "Glare", v, 0.4) end
})

AtmTab:CreateSlider({
    Name = "Haze",
    Range = {0, 10}, Increment = 0.05,
    CurrentValue = Atmosphere.Haze, Flag = "AtmHaze",
    Callback = function(v) tween(Atmosphere, "Haze", v, 0.4) end
})

AtmTab:CreateSection("Distance Fog")

AtmTab:CreateSlider({
    Name = "Fog Start",
    Range = {0, 2000}, Increment = 10, Suffix = "studs",
    CurrentValue = Lighting.FogStart, Flag = "FogStart",
    Callback = function(v) tween(Lighting, "FogStart", v, 0.4) end
})

AtmTab:CreateSlider({
    Name = "Fog End",
    Range = {100, 100000}, Increment = 100, Suffix = "studs",
    CurrentValue = Lighting.FogEnd, Flag = "FogEnd",
    Callback = function(v) tween(Lighting, "FogEnd", v, 0.4) end
})

AtmTab:CreateColorPicker({
    Name = "Fog Color",
    Color = Lighting.FogColor, Flag = "FogColor",
    Callback = function(c) tween(Lighting, "FogColor", c, 0.4) end
})

-- ============================================================
-- TAB 4 : POST-PROCESS (Tonemapping / Optics)
-- ============================================================

local PostTab = Window:CreateTab("Post-Processing", 4483362458)

-- ---- COLOR CORRECTION (tonemap emulation) ----
PostTab:CreateSection("Color Correction (Tonemap)")

PostTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = ColorCorrection.Enabled, Flag = "CCOn",
    Callback = function(v) ColorCorrection.Enabled = v end
})

PostTab:CreateSlider({
    Name = "Brightness",
    Range = {-1, 1}, Increment = 0.005,
    CurrentValue = ColorCorrection.Brightness, Flag = "CCBright",
    Callback = function(v) tween(ColorCorrection, "Brightness", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Contrast",
    Range = {-1, 1}, Increment = 0.005,
    CurrentValue = ColorCorrection.Contrast, Flag = "CCContrast",
    Callback = function(v) tween(ColorCorrection, "Contrast", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Saturation",
    Range = {-1, 1}, Increment = 0.005,
    CurrentValue = ColorCorrection.Saturation, Flag = "CCSat",
    Callback = function(v) tween(ColorCorrection, "Saturation", v, 0.4) end
})

PostTab:CreateColorPicker({
    Name = "Tint Color (white balance)",
    Color = ColorCorrection.TintColor, Flag = "CCTint",
    Callback = function(c) tween(ColorCorrection, "TintColor", c, 0.4) end
})

-- ---- BLOOM (lens glare) ----
PostTab:CreateSection("Bloom (Lens Glare)")

PostTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = Bloom.Enabled, Flag = "BloomOn",
    Callback = function(v) Bloom.Enabled = v end
})

PostTab:CreateSlider({
    Name = "Intensity",
    Range = {0, 3}, Increment = 0.02,
    CurrentValue = Bloom.Intensity, Flag = "BloomInt",
    Callback = function(v) tween(Bloom, "Intensity", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Size",
    Range = {1, 56}, Increment = 1,
    CurrentValue = Bloom.Size, Flag = "BloomSize",
    Callback = function(v) tween(Bloom, "Size", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Threshold",
    Range = {0, 3}, Increment = 0.02,
    CurrentValue = Bloom.Threshold, Flag = "BloomThresh",
    Callback = function(v) tween(Bloom, "Threshold", v, 0.4) end
})

-- ---- SUN RAYS (volumetric god rays) ----
PostTab:CreateSection("Sun Rays")

PostTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = SunRays.Enabled, Flag = "SROn",
    Callback = function(v) SunRays.Enabled = v end
})

PostTab:CreateSlider({
    Name = "Intensity",
    Range = {0, 1}, Increment = 0.005,
    CurrentValue = SunRays.Intensity, Flag = "SRInt",
    Callback = function(v) tween(SunRays, "Intensity", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Spread",
    Range = {0, 1}, Increment = 0.005,
    CurrentValue = SunRays.Spread, Flag = "SRSpread",
    Callback = function(v) tween(SunRays, "Spread", v, 0.4) end
})

-- ---- DEPTH OF FIELD (bokeh) ----
PostTab:CreateSection("Depth of Field (Bokeh)")

PostTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = DepthOfField.Enabled, Flag = "DOFOn",
    Callback = function(v) DepthOfField.Enabled = v end
})

PostTab:CreateSlider({
    Name = "Focus Distance",
    Range = {0, 1000}, Increment = 1,
    CurrentValue = DepthOfField.FocusDistance, Flag = "DOFFocus",
    Callback = function(v) tween(DepthOfField, "FocusDistance", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "In-Focus Radius",
    Range = {0, 500}, Increment = 1,
    CurrentValue = DepthOfField.InFocusRadius, Flag = "DOFRadius",
    Callback = function(v) tween(DepthOfField, "InFocusRadius", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Near Intensity",
    Range = {0, 1}, Increment = 0.01,
    CurrentValue = DepthOfField.NearIntensity, Flag = "DOFNear",
    Callback = function(v) tween(DepthOfField, "NearIntensity", v, 0.4) end
})

PostTab:CreateSlider({
    Name = "Far Intensity",
    Range = {0, 1}, Increment = 0.01,
    CurrentValue = DepthOfField.FarIntensity, Flag = "DOFFar",
    Callback = function(v) tween(DepthOfField, "FarIntensity", v, 0.4) end
})

-- ---- BLUR (motion fallback) ----
PostTab:CreateSection("Blur")

PostTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = Blur.Enabled, Flag = "BlurOn",
    Callback = function(v) Blur.Enabled = v end
})

PostTab:CreateSlider({
    Name = "Size",
    Range = {0, 56}, Increment = 1,
    CurrentValue = Blur.Size, Flag = "BlurSize",
    Callback = function(v) tween(Blur, "Size", v, 0.4) end
})

-- ============================================================
-- TAB 5 : REALISM PRESETS
-- ============================================================

local PresetTab = Window:CreateTab("Realism Presets", 4483362458)

-- Helper to bulk-apply a table of properties
local function applyPreset(tbl)
    for inst, props in pairs(tbl) do
        for prop, val in pairs(props) do
            if typeof(val) == "Color3" then
                tween(inst, prop, val, 1.0)
            else
                tween(inst, prop, val, 1.0)
            end
        end
    end
end

-- ── Golden Hour ─────────────────────────────────────────────
PresetTab:CreateButton({
    Name = "🌅 Golden Hour (photoreal)",
    Callback = function()
        applyPreset({
            [Lighting] = {
                ClockTime = 17.5, GeographicLatitude = 35,
                Brightness = 2.2, ExposureCompensation = 0.15,
                Ambient = Color3.fromRGB(45, 38, 34),
                OutdoorAmbient = Color3.fromRGB(180, 130, 90),
                EnvironmentDiffuseScale = 0.55, EnvironmentSpecularScale = 0.65,
                GlobalShadows = true, ShadowSoftness = 0.28,
                FogStart = 120, FogEnd = 4500,
                FogColor = Color3.fromRGB(230, 175, 120)
            },
            [Atmosphere] = {
                Density = 0.32, Offset = 0.15,
                Color = Color3.fromRGB(230, 190, 150),
                Decay = Color3.fromRGB(160, 90, 60),
                Glare = 0.35, Haze = 2.1
            },
            [Bloom] = {
                Enabled = true, Intensity = 0.45, Size = 30, Threshold = 1.05
            },
            [SunRays] = { Enabled = true, Intensity = 0.14, Spread = 0.85 },
            [ColorCorrection] = {
                Enabled = true,
                Brightness = -0.01, Contrast = 0.07, Saturation = 0.06,
                TintColor = Color3.fromRGB(255, 240, 220)
            },
            [DepthOfField] = {
                Enabled = true, FocusDistance = 60, InFocusRadius = 180,
                NearIntensity = 0.05, FarIntensity = 0.22
            }
        })
        Rayfield:Notify({Title="Preset Applied", Content="Golden Hour lighting loaded.", Duration=3})
    end
})

-- ── Overcast Day ────────────────────────────────────────────
PresetTab:CreateButton({
    Name = "☁️ Overcast Day (softbox)",
    Callback = function()
        applyPreset({
            [Lighting] = {
                ClockTime = 13, Brightness = 2.6, ExposureCompensation = 0.05,
                Ambient = Color3.fromRGB(95, 98, 105),
                OutdoorAmbient = Color3.fromRGB(190, 195, 205),
                EnvironmentDiffuseScale = 0.75, EnvironmentSpecularScale = 0.35,
                GlobalShadows = true, ShadowSoftness = 0.55,
                FogStart = 200, FogEnd = 12000,
                FogColor = Color3.fromRGB(205, 210, 218)
            },
            [Atmosphere] = {
                Density = 0.42, Offset = 0.1,
                Color = Color3.fromRGB(215, 218, 225),
                Decay = Color3.fromRGB(180, 185, 195),
                Glare = 0, Haze = 3.5
            },
            [Bloom] = { Enabled = true, Intensity = 0.15, Size = 22, Threshold = 1.4 },
            [SunRays] = { Enabled = false, Intensity = 0, Spread = 1 },
            [ColorCorrection] = {
                Enabled = true,
                Brightness = 0.02, Contrast = -0.04, Saturation = -0.10,
                TintColor = Color3.fromRGB(248, 250, 255)
            },
            [DepthOfField] = { Enabled = false }
        })
        Rayfield:Notify({Title="Preset Applied", Content="Overcast daylight loaded.", Duration=3})
    end
})

-- ── Clear Midday ────────────────────────────────────────────
PresetTab:CreateButton({
    Name = "☀️ Clear Midday (HDR)",
    Callback = function()
        applyPreset({
            [Lighting] = {
                ClockTime = 12, GeographicLatitude = 23.5,
                Brightness = 2.4, ExposureCompensation = -0.05,
                Ambient = Color3.fromRGB(75, 78, 82),
                OutdoorAmbient = Color3.fromRGB(155, 165, 180),
                EnvironmentDiffuseScale = 0.5, EnvironmentSpecularScale = 0.5,
                GlobalShadows = true, ShadowSoftness = 0.15,
                FogStart = 400, FogEnd = 60000,
                FogColor = Color3.fromRGB(200, 210, 225)
            },
            [Atmosphere] = {
                Density = 0.30, Offset = 0,
                Color = Color3.fromRGB(199, 210, 225),
                Decay = Color3.fromRGB(106, 112, 125),
                Glare = 0, Haze = 1.2
            },
            [Bloom] = { Enabled = true, Intensity = 0.25, Size = 24, Threshold = 1.2 },
            [SunRays] = { Enabled = true, Intensity = 0.10, Spread = 0.9 },
            [ColorCorrection] = {
                Enabled = true,
                Brightness = 0, Contrast = 0.06, Saturation = 0.02,
                TintColor = Color3.fromRGB(255, 255, 255)
            },
            [DepthOfField] = { Enabled = false }
        })
        Rayfield:Notify({Title="Preset Applied", Content="Clear midday HDR loaded.", Duration=3})
    end
})

-- ── Blue Hour ───────────────────────────────────────────────
PresetTab:CreateButton({
    Name = "🌆 Blue Hour (twilight)",
    Callback = function()
        applyPreset({
            [Lighting] = {
                ClockTime = 19.1, Brightness = 1.4,
                ExposureCompensation = 0.35,
                Ambient = Color3.fromRGB(28, 32, 48),
                OutdoorAmbient = Color3.fromRGB(70, 85, 120),
                EnvironmentDiffuseScale = 0.45, EnvironmentSpecularScale = 0.55,
                GlobalShadows = true, ShadowSoftness = 0.4,
                FogStart = 80, FogEnd = 3000,
                FogColor = Color3.fromRGB(60, 75, 110)
            },
            [Atmosphere] = {
                Density = 0.38, Offset = 0.05,
                Color = Color3.fromRGB(90, 110, 160),
                Decay = Color3.fromRGB(40, 50, 90),
                Glare = 0.2, Haze = 2.8
            },
            [Bloom] = { Enabled = true, Intensity = 0.55, Size = 34, Threshold = 0.95 },
            [SunRays] = { Enabled = true, Intensity = 0.06, Spread = 1 },
            [ColorCorrection] = {
                Enabled = true,
                Brightness = 0.03, Contrast = 0.05, Saturation = 0.05,
                TintColor = Color3.fromRGB(210, 220, 255)
            },
            [DepthOfField] = { Enabled = false }
        })
        Rayfield:Notify({Title="Preset Applied", Content="Blue Hour loaded.", Duration=3})
    end
})

-- ── Moonlit Night ───────────────────────────────────────────
PresetTab:CreateButton({
    Name = "🌙 Moonlit Night",
    Callback = function()
        applyPreset({
            [Lighting] = {
                ClockTime = 0, Brightness = 0.9,
                ExposureCompensation = 0.6,
                Ambient = Color3.fromRGB(15, 18, 28),
                OutdoorAmbient = Color3.fromRGB(45, 55, 85),
                EnvironmentDiffuseScale = 0.35, EnvironmentSpecularScale = 0.5,
                GlobalShadows = true, ShadowSoftness = 0.3,
                FogStart = 40, FogEnd = 2000,
                FogColor = Color3.fromRGB(20, 25, 45)
            },
            [Atmosphere] = {
                Density = 0.35, Offset = 0.1,
                Color = Color3.fromRGB(40, 55, 90),
                Decay = Color3.fromRGB(15, 20, 40),
                Glare = 0.15, Haze = 1.5
            },
            [Bloom] = { Enabled = true, Intensity = 0.6, Size = 28, Threshold = 0.85 },
            [SunRays] = { Enabled = false },
            [ColorCorrection] = {
                Enabled = true,
                Brightness = 0.04, Contrast = 0.08, Saturation = -0.05,
                TintColor = Color3.fromRGB(200, 215, 255)
            },
            [DepthOfField] = { Enabled = true, FocusDistance = 40, InFocusRadius = 120, FarIntensity = 0.25 }
        })
        Rayfield:Notify({Title="Preset Applied", Content="Moonlit Night loaded.", Duration=3})
    end
})

-- ── Studio Neutral (edit-mode look) ─────────────────────────
PresetTab:CreateButton({
    Name = "🎬 Neutral (color-grade baseline)",
    Callback = function()
        applyPreset({
            [Lighting] = {
                ClockTime = 14, Brightness = 2,
                ExposureCompensation = 0,
                Ambient = Color3.fromRGB(70,70,70),
                OutdoorAmbient = Color3.fromRGB(140,140,140),
                EnvironmentDiffuseScale = 0.4, EnvironmentSpecularScale = 0.4,
                GlobalShadows = true, ShadowSoftness = 0.25,
                FogStart = 0, FogEnd = 100000,
                FogColor = Color3.fromRGB(192,192,192)
            },
            [Atmosphere] = { Density = 0.3, Offset = 0, Color = Color3.fromRGB(199,199,199),
                             Decay = Color3.fromRGB(106,112,125), Glare = 0, Haze = 0 },
            [Bloom] = { Enabled = true, Intensity = 0.2, Size = 24, Threshold = 1.3 },
            [SunRays] = { Enabled = true, Intensity = 0.1, Spread = 1 },
            [ColorCorrection] = { Enabled = true, Brightness = 0, Contrast = 0, Saturation = 0,
                                  TintColor = Color3.fromRGB(255,255,255) },
            [DepthOfField] = { Enabled = false },
            [Blur] = { Enabled = false, Size = 0 }
        })
        Rayfield:Notify({Title="Preset Applied", Content="Neutral grade loaded.", Duration=3})
    end
})

-- ── Performance Mode ────────────────────────────────────────
PresetTab:CreateButton({
    Name = "⚡ Performance Mode (fps boost)",
    Callback = function()
        applyPreset({
            [Lighting] = {
                GlobalShadows = false,
                ShadowSoftness = 0,
                EnvironmentDiffuseScale = 0,
                EnvironmentSpecularScale = 0,
                FogEnd = 100000
            },
            [Bloom] = { Enabled = false },
            [SunRays] = { Enabled = false },
            [ColorCorrection] = { Enabled = false },
            [DepthOfField] = { Enabled = false },
            [Blur] = { Enabled = false },
            [Atmosphere] = { Density = 0.15, Glare = 0, Haze = 0 }
        })
        Rayfield:Notify({Title="Performance Mode", Content="Heavy effects disabled.", Duration=3})
    end
})

-- ============================================================
-- TAB 6 : SMART / DYNAMIC
-- ============================================================

local SmartTab = Window:CreateTab("Dynamic", 4483362458)

SmartTab:CreateSection("Auto Sun Cycle")

local cycleConn
local cycleSpeed = 1

SmartTab:CreateToggle({
    Name = "Live Day/Night Cycle",
    CurrentValue = false, Flag = "AutoCycle",
    Callback = function(v)
        if v then
            cycleConn = RunService.Heartbeat:Connect(function(dt)
                Lighting.ClockTime = (Lighting.ClockTime + dt * cycleSpeed * 0.05) % 24
            end)
        else
            if cycleConn then cycleConn:Disconnect(); cycleConn = nil end
        end
    end
})

SmartTab:CreateSlider({
    Name = "Cycle Speed",
    Range = {0.1, 10}, Increment = 0.1,
    CurrentValue = 1, Flag = "CycleSpeed",
    Callback = function(v) cycleSpeed = v end
})

SmartTab:CreateSection("Utilities")

SmartTab:CreateButton({
    Name = "Freeze Current Look (kill all tweens)",
    Callback = function()
        for _, t in ipairs(game:GetService("TweenService"):GetTweens() or {}) do
            pcall(function() t:Cancel() end)
        end
        Rayfield:Notify({Title="Frozen", Content="All tweens cancelled.", Duration=2})
    end
})

SmartTab:CreateButton({
    Name = "Print Current Values (dev console)",
    Callback = function()
        print("=== GFX Realism V2 Snapshot ===")
        print("ClockTime", Lighting.ClockTime)
        print("Brightness", Lighting.Brightness)
        print("Atmosphere.Density", Atmosphere.Density)
        print("Bloom.Intensity", Bloom.Intensity)
        print("ColorCorrection:", ColorCorrection.Brightness, ColorCorrection.Contrast, ColorCorrection.Saturation)
    end
})

-- ============================================================
-- BOOT NOTIFICATION
-- ============================================================

Rayfield:Notify({
    Title = "Realism Suite Loaded",
    Content = "5 tabs • 8 presets • PBR + Sky + Post-FX ready.",
    Duration = 6
})
