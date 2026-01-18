--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--[[
    SoujaHub - Loader Script v1.4 (WITH KEY SYSTEM)

]]

--================================================================================--
--[[ SERVICES ]]--
--================================================================================--
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

--================================================================================--
--[[ CONFIGURATION ]]--
--================================================================================--
local Config = {
    -- Key System Settings
    CORRECT_KEY = "voidrelease",
    DISCORD_LINK = "https://discord.gg/BPRtwyESNn",
    DISCORD_INVITE_CODE = "BPRtwyESNn",
    
    -- Key Storage
    KEY_STORAGE_FILE = "voidkey.json",

    -- Main Settings
    HubName = "Void Hub",
    Subtitle = "Top Script Hub",
    LogoLetter = "V",
    ImageLogo = "", -- Paste your decal ID here. Leave blank for letter.
    LoadTime = 8,

    -- Main script to load after the animation finishes
    ScriptToLoad = "https://github.com/adubwon/nex/raw/refs/heads/main/hub.lua",

    -- Loading Messages & Tips displayed randomly
    Messages = {
        "Connecting...",
        "Authenticating...",
        "Downloading assets...",
        "Configuring environment...",
        "Building interface...",
        "Finalizing..."
    },
    Tips = {
        "Did you know? You can customize the settings in the hub.",
        "Check out our community for support and updates!",
        "New features are added regularly!"
    },

    -- Sound Effects
    Sounds = {
        Open = "rbxassetid/913363037",
        Update = "rbxassetid/6823769213",
        Success = "rbxassetid/10895847421",
        Failure = "rbxassetid/142642633",
        TipPing = "rbxassetid/5151558373"
    },

    -- Animation Timings
    IntroAnimationTime = 0.6,
    OutroAnimationTime = 0.5,

    -- Theme & Colors
    Theme = {
        Primary = Color3.fromRGB(170, 70, 255),
        Background = Color3.fromRGB(20, 20, 30),
        BackgroundGradient = Color3.fromRGB(35, 35, 50),
        Text = Color3.fromRGB(255, 255, 255),
        MutedText = Color3.fromRGB(120, 125, 135),
        ProgressBackground = Color3.fromRGB(30, 32, 38),
        Failure = Color3.fromRGB(255, 80, 80),
        SuccessFlash = Color3.fromRGB(255, 255, 255),
        InputBackground = Color3.fromRGB(25, 25, 35),
        InputBorder = Color3.fromRGB(60, 60, 80),
        ButtonSecondary = Color3.fromRGB(40, 40, 60)
    },

    -- Fonts
    Fonts = {
        Main = Enum.Font.GothamBold,
        Secondary = Enum.Font.Gotham,
        Code = Enum.Font.Code
    }
}

--================================================================================--
--[[ KEY SYSTEM FUNCTIONS ]]--
--================================================================================--
local function notify(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 3
        })
    end)
end

local function saveKeyData()
    pcall(function()
        local player = Players.LocalPlayer
        writefile(Config.KEY_STORAGE_FILE, HttpService:JSONEncode({
            key_verified = true,
            user_id = player.UserId,
            saved_key = Config.CORRECT_KEY
        }))
    end)
end

local function loadKeyData()
    local success, result = pcall(function()
        if isfile(Config.KEY_STORAGE_FILE) then
            local player = Players.LocalPlayer
            local data = HttpService:JSONDecode(readfile(Config.KEY_STORAGE_FILE))
            return data.key_verified and data.user_id == player.UserId and data.saved_key == Config.CORRECT_KEY
        end
        return false
    end)
    return success and result
end

local function handleDiscordInvite()
    -- Try to copy to clipboard
    xpcall(function()
        if setclipboard then
            setclipboard(Config.DISCORD_LINK)
        elseif toclipboard then
            toclipboard(Config.DISCORD_LINK)
        end
    end, function() end)
    
    -- Try to open in Discord desktop app
    xpcall(function()
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {code = Config.DISCORD_INVITE_CODE},
                nonce = HttpService:GenerateGUID(false)
            })
        })
    end, function() end)
    
    -- Show notification
    notify("Discord Link Copied", "Paste in browser to join", 15)
end

--================================================================================--
--[[ SCRIPT SETUP ]]--
--================================================================================--

-- Check if key is already verified
if loadKeyData() then
    -- Key is verified, load the hub directly
    local success, result = pcall(function()
        loadstring(game:HttpGet(Config.ScriptToLoad))()
    end)
    if success then
        notify("Success", "Warp Hub loaded successfully!", 3)
    else
        notify("Error", tostring(result), 5)
    end
    return
end

-- Create a sound player utility
local SoundPlayer = {}
for name, id in pairs(Config.Sounds) do
    if id and id ~= "" then
        local sound = Instance.new("Sound")
        sound.SoundId = id
        sound.Parent = SoundService
        SoundPlayer[name] = sound
    end
end
local function PlaySound(name)
    if SoundPlayer[name] then
        SoundPlayer[name]:Play()
    end
end

-- Get Player and PlayerGui
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Add a blur effect to the world behind the UI
local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0
blur.Enabled = true

-- Create the main ScreenGui container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoujaHubLoader"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999

--================================================================================--
--[[ UI ELEMENT CREATION ]]--
--================================================================================--

-- Main container frame for the loader
local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Size = UDim2.new(0, 0, 0, 0)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.BackgroundColor3 = Config.Theme.Background
container.BorderSizePixel = 0
container.Parent = screenGui

Instance.new("UICorner", container).CornerRadius = UDim.new(0, 20)

local containerGradient = Instance.new("UIGradient", container)
containerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Theme.Background),
    ColorSequenceKeypoint.new(1, Config.Theme.BackgroundGradient)
}
containerGradient.Rotation = 90

local borderStroke = Instance.new("UIStroke", container)
borderStroke.Color = Config.Theme.Primary
borderStroke.Thickness = 3
borderStroke.Transparency = 0.2
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Logo elements
local logoCircle = Instance.new("Frame", container)
logoCircle.Name = "Logo"
logoCircle.AnchorPoint = Vector2.new(0.5, 0)
logoCircle.Size = UDim2.new(0, 70, 0, 70)
logoCircle.Position = UDim2.new(0.5, 0, 0, 25)
logoCircle.BackgroundColor3 = Config.Theme.Primary
logoCircle.BorderSizePixel = 0
logoCircle.ClipsDescendants = true
Instance.new("UICorner", logoCircle).CornerRadius = UDim.new(0, 15)

local logoInner = Instance.new("Frame", logoCircle)
logoInner.AnchorPoint = Vector2.new(0.5, 0.5)
logoInner.Size = UDim2.new(0, 58, 0, 58)
logoInner.Position = UDim2.new(0.5, 0, 0.5, 0)
logoInner.BackgroundColor3 = Config.Theme.Background
logoInner.BorderSizePixel = 0
Instance.new("UICorner", logoInner).CornerRadius = UDim.new(0, 12)

if Config.ImageLogo and Config.ImageLogo ~= "" then
    local logoImage = Instance.new("ImageLabel", logoInner)
    logoImage.Size = UDim2.new(1, 0, 1, 0)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = Config.ImageLogo
else
    local logoText = Instance.new("TextLabel", logoInner)
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = Config.LogoLetter
    logoText.TextColor3 = Config.Theme.Primary
    logoText.TextSize = 36
    logoText.Font = Config.Fonts.Main
end

-- Text elements
local title = Instance.new("TextLabel", container)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 20, 0, 105)
title.BackgroundTransparency = 1
title.Text = Config.HubName
title.TextColor3 = Config.Theme.Text
title.TextSize = 28
title.Font = Config.Fonts.Main
title.TextXAlignment = Enum.TextXAlignment.Center

local versionText = Instance.new("TextLabel", container)
versionText.Size = UDim2.new(1, -40, 0, 18)
versionText.Position = UDim2.new(0, 20, 0, 140)
versionText.BackgroundTransparency = 1
versionText.Text = Config.Subtitle
versionText.TextColor3 = Config.Theme.MutedText
versionText.TextSize = 13
versionText.Font = Config.Fonts.Secondary
versionText.TextXAlignment = Enum.TextXAlignment.Center

-- Key Input Box
local keyInputFrame = Instance.new("Frame", container)
keyInputFrame.Size = UDim2.new(1, -60, 0, 45)
keyInputFrame.Position = UDim2.new(0, 30, 0, 170)
keyInputFrame.BackgroundColor3 = Config.Theme.InputBackground
keyInputFrame.BorderSizePixel = 0
Instance.new("UICorner", keyInputFrame).CornerRadius = UDim.new(0, 10)

local inputStroke = Instance.new("UIStroke", keyInputFrame)
inputStroke.Color = Config.Theme.InputBorder
inputStroke.Thickness = 2

local keyBox = Instance.new("TextBox", keyInputFrame)
keyBox.Size = UDim2.new(1, -20, 1, 0)
keyBox.Position = UDim2.new(0, 10, 0, 0)
keyBox.PlaceholderText = "Enter key..."
keyBox.PlaceholderColor3 = Config.Theme.MutedText
keyBox.TextColor3 = Config.Theme.Text
keyBox.BackgroundTransparency = 1
keyBox.Font = Config.Fonts.Secondary
keyBox.TextSize = 16
keyBox.ClearTextOnFocus = false

-- Buttons
local submitButton = Instance.new("TextButton", container)
submitButton.Size = UDim2.new(1, -60, 0, 45)
submitButton.Position = UDim2.new(0, 30, 0, 225)
submitButton.Text = "VERIFY KEY"
submitButton.Font = Config.Fonts.Main
submitButton.TextSize = 16
submitButton.TextColor3 = Config.Theme.Text
submitButton.BackgroundColor3 = Config.Theme.Primary
submitButton.BorderSizePixel = 0
Instance.new("UICorner", submitButton).CornerRadius = UDim.new(0, 10)

local getKeyButton = Instance.new("TextButton", container)
getKeyButton.Size = UDim2.new(1, -60, 0, 40)
getKeyButton.Position = UDim2.new(0, 30, 0, 280)
getKeyButton.Text = "GET KEY"
getKeyButton.Font = Config.Fonts.Secondary
getKeyButton.TextSize = 14
getKeyButton.TextColor3 = Config.Theme.Text
getKeyButton.BackgroundColor3 = Config.Theme.ButtonSecondary
getKeyButton.BorderSizePixel = 0
Instance.new("UICorner", getKeyButton).CornerRadius = UDim.new(0, 8)

-- Status text
local statusText = Instance.new("TextLabel", container)
statusText.Size = UDim2.new(1, -40, 0, 20)
statusText.Position = UDim2.new(0, 20, 0, 335)
statusText.BackgroundTransparency = 1
statusText.Text = "Enter your key to access the hub"
statusText.TextColor3 = Config.Theme.MutedText
statusText.TextSize = 12
statusText.Font = Config.Fonts.Code
statusText.TextXAlignment = Enum.TextXAlignment.Center

-- Finally, parent the main GUI to the PlayerGui
screenGui.Parent = playerGui

--================================================================================--
--[[ CORE FUNCTIONS & ANIMATIONS ]]--
--================================================================================--

local function updateStatus(text, instant)
    if instant then statusText.Text = text; return end

    PlaySound("Update")
    local outTween = TweenService:Create(statusText, TweenInfo.new(0.15), {TextTransparency = 1})
    outTween:Play()
    outTween.Completed:Wait()
    statusText.Text = text
    local inTween = TweenService:Create(statusText, TweenInfo.new(0.15), {TextTransparency = 0})
    inTween:Play()
end

local function displayFatalError(errorMessage)
    updateStatus(errorMessage, true)
    PlaySound("Failure")
    
    TweenService:Create(borderStroke, TweenInfo.new(0.3), {Color = Config.Theme.Failure}):Play()
end

--================================================================================--
--[[ BUTTON FUNCTIONS ]]--
--================================================================================--

submitButton.MouseButton1Click:Connect(function()
    PlaySound("Update")
    
    if keyBox.Text == Config.CORRECT_KEY then
        saveKeyData()
        updateStatus("Key verified! Loading hub...", true)
        
        -- Hide the key input UI
        TweenService:Create(keyInputFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(submitButton, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(getKeyButton, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(keyBox, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(inputStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        
        -- Create loading elements
        local progressBg = Instance.new("Frame", container)
        progressBg.Name = "progressBg"
        progressBg.Size = UDim2.new(1, -60, 0, 7)
        progressBg.Position = UDim2.new(0, 30, 0, 175)
        progressBg.BackgroundColor3 = Config.Theme.ProgressBackground
        progressBg.BorderSizePixel = 0
        progressBg.BackgroundTransparency = 1
        Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

        local progressFill = Instance.new("Frame", progressBg)
        progressFill.Name = "progressFill"
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = Config.Theme.Primary
        progressFill.BorderSizePixel = 0
        progressFill.BackgroundTransparency = 1
        Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

        local percentText = Instance.new("TextLabel", container)
        percentText.Size = UDim2.new(0, 100, 0, 28)
        percentText.Position = UDim2.new(0.5, -50, 0, 192)
        percentText.BackgroundTransparency = 1
        percentText.Text = "0%"
        percentText.TextColor3 = Config.Theme.Primary
        percentText.TextSize = 20
        percentText.Font = Config.Fonts.Main
        percentText.TextTransparency = 1
        
        -- Fade in loading elements
        TweenService:Create(progressBg, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        TweenService:Create(progressFill, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        TweenService:Create(percentText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        -- Start loading animation
        task.wait(0.5)
        PlaySound("Success")
        
        -- Animate progress
        for i = 0, 100, 5 do
            progressFill.Size = UDim2.new(i/100, 0, 1, 0)
            percentText.Text = i .. "%"
            task.wait(0.05)
        end
        
        -- Load the actual hub
        local success, result = pcall(function()
            loadstring(game:HttpGet(Config.ScriptToLoad))()
        end)
        
        if success then
            updateStatus("Hub loaded successfully!", true)
            task.wait(1)
            
            -- Fade out and destroy
            TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
            local outroTween = TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            outroTween:Play()
            
            for _, child in ipairs(container:GetDescendants()) do
                if child:IsA("TextLabel") then
                    TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                elseif child:IsA("Frame") then
                    TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                elseif child:IsA("UIStroke") then
                    TweenService:Create(child, TweenInfo.new(0.4), {Transparency = 1}):Play()
                end
            end
            
            outroTween.Completed:Wait()
            screenGui:Destroy()
            blur:Destroy()
        else
            displayFatalError("Failed to load hub: " .. tostring(result))
        end
    else
        updateStatus("Invalid key! Try again.", true)
        PlaySound("Failure")
        
        -- Shake animation for wrong key
        local originalPos = keyInputFrame.Position
        for i = 1, 3 do
            TweenService:Create(keyInputFrame, TweenInfo.new(0.05), {Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 5, originalPos.Y.Scale, originalPos.Y.Offset)}):Play()
            task.wait(0.05)
            TweenService:Create(keyInputFrame, TweenInfo.new(0.05), {Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 5, originalPos.Y.Scale, originalPos.Y.Offset)}):Play()
            task.wait(0.05)
        end
        TweenService:Create(keyInputFrame, TweenInfo.new(0.1), {Position = originalPos}):Play()
    end
end)

getKeyButton.MouseButton1Click:Connect(function()
    PlaySound("Update")
    updateStatus("Opening Discord...", true)
    handleDiscordInvite()
end)

-- Button hover effects
submitButton.MouseEnter:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(190, 90, 255)}):Play()
end)
submitButton.MouseLeave:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.Primary}):Play()
end)

getKeyButton.MouseEnter:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
end)
getKeyButton.MouseLeave:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.ButtonSecondary}):Play()
end)

--================================================================================--
--[[ MAIN EXECUTION SEQUENCE ]]--
--================================================================================--

-- Step 1: Set all elements to be fully transparent for the fade-in animation
for _, child in ipairs(container:GetDescendants()) do
    if child:IsA("TextLabel") then
        child.TextTransparency = 1
    elseif child:IsA("ImageLabel") then
        child.ImageTransparency = 1
    elseif child:IsA("Frame") then
        child.BackgroundTransparency = 1
    elseif child:IsA("UIStroke") then
        child.Transparency = 1
    elseif child:IsA("TextBox") then
        child.TextTransparency = 1
        child.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    elseif child:IsA("TextButton") then
        child.TextTransparency = 1
    end
end

-- Step 2: Apply an interactive hover effect to the logo
logoCircle.MouseEnter:Connect(function()
    TweenService:Create(logoCircle, TweenInfo.new(0.2), {Size = UDim2.new(0, 75, 0, 75)}):Play()
end)
logoCircle.MouseLeave:Connect(function()
    TweenService:Create(logoCircle, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)}):Play()
end)

-- Step 3: Run the intro animation
PlaySound("Open")
TweenService:Create(blur, TweenInfo.new(Config.IntroAnimationTime), {Size = 12}):Play()
local introTween = TweenService:Create(container, TweenInfo.new(Config.IntroAnimationTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 360)  -- Increased height for key input
})
introTween:Play()
introTween.Completed:Wait()

-- Step 4: Staggered fade-in for all child elements
for _, child in ipairs(container:GetDescendants()) do
    if child:IsA("TextLabel") then
        TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    elseif child:IsA("ImageLabel") then
        TweenService:Create(child, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
    elseif child:IsA("Frame") then
        TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    elseif child:IsA("UIStroke") then
        local targetTransparency = (child == borderStroke) and 0.2 or 0
        TweenService:Create(child, TweenInfo.new(0.4), {Transparency = targetTransparency}):Play()
    elseif child:IsA("TextBox") then
        TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        TweenService:Create(child, TweenInfo.new(0.4), {PlaceholderColor3 = Config.Theme.MutedText}):Play()
    elseif child:IsA("TextButton") then
        TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    end
    task.wait(0.02)
end
