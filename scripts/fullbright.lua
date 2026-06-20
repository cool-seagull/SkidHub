--[[
    Fullbright for Roblox
    Removes darkness/ambient shadows so the whole map is evenly lit.
    Re-applies automatically so games that fight back can't re-darken the map.
    Toggle with the on-screen flashlight button.
--]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Tweak this if you want a brighter/darker "max bright" look.
local BRIGHT = Color3.fromRGB(255, 255, 255)

local enabled = true

-- Stash the original values so we can restore them on toggle-off.
local original = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    ExposureCompensation = Lighting.ExposureCompensation,
}

local function applyFullbright()
    Lighting.Ambient = BRIGHT
    Lighting.OutdoorAmbient = BRIGHT
    Lighting.Brightness = 2
    Lighting.FogEnd = 1e9          -- push fog far enough that it never occludes
    Lighting.FogStart = 1e9
    Lighting.ClockTime = 12        -- noon
    Lighting.GlobalShadows = false
    Lighting.ExposureCompensation = 0
end

local function restore()
    for prop, value in pairs(original) do
        Lighting[prop] = value
    end
end

-- Keep enforcing it every frame so the game can't override us while enabled.
RunService.RenderStepped:Connect(function()
    if enabled then
        applyFullbright()
    end
end)

----------------------------------------------------------------------
-- GUI
----------------------------------------------------------------------

local ON_COLOR = Color3.fromRGB(46, 204, 113)
local OFF_COLOR = Color3.fromRGB(192, 57, 43)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FullbrightGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 86)
frame.Position = UDim2.fromOffset(20, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Title doubles as the drag handle, so dragging never steals button clicks.
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Fullbright"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Manual dragging on the title bar only.
do
    local dragging, dragStart, startPos
    title.Active = true
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.fromOffset(10, 36)
button.BackgroundColor3 = ON_COLOR
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Text = "Flashlight: ON"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = button

local function refreshButton()
    button.Text = enabled and "Flashlight: ON" or "Flashlight: OFF"
    button.BackgroundColor3 = enabled and ON_COLOR or OFF_COLOR
end

local function setEnabled(state)
    enabled = state
    if enabled then
        applyFullbright()
    else
        restore()
    end
    refreshButton()
end

-- Activated fires for both mouse and touch.
button.Activated:Connect(function()
    setEnabled(not enabled)
end)

applyFullbright()
refreshButton()
