--[[
    Warp Hub - Key System Loader with Premium UI
    Always shows verification UI
]]

--================================================================================--
--[[ SERVICES ]]--
--================================================================================--
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--================================================================================--
--[[ CONFIGURATION ]]--
--================================================================================--
local Config = {
    -- Key System Settings
    CORRECT_KEY = "voidrelease",
    DISCORD_LINK = "https://discord.gg/BPRtwyESNn",
    DISCORD_INVITE_CODE = "BPRtwyESNn",
    
    -- Key Storage
    KEY_STORAGE_FILE = "Warp_KeyData.json",

    -- Main Settings
    HubName = "Warp Hub Premium",
    ScriptToLoad = "https://github.com/adubwon/nex/raw/refs/heads/main/hub.lua",

    -- UI Configuration
    GlassTransparency = 0.15,
    DarkGlassTransparency = 0.1,
    CornerRadius = 20,
    AccentColor = Color3.fromRGB(168, 128, 255),
    SecondaryColor = Color3.fromRGB(128, 96, 255),
    GlassColor = Color3.fromRGB(25, 25, 35),
    DarkGlassColor = Color3.fromRGB(15, 15, 22),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(200, 200, 220),
    ButtonColor = Color3.fromRGB(35, 35, 45),
    ButtonHoverColor = Color3.fromRGB(168, 128, 255),
    InputBackground = Color3.fromRGB(40, 40, 50),
    SliderTrack = Color3.fromRGB(45, 45, 55),
    SliderFill = Color3.fromRGB(168, 128, 255),
    DropdownBackground = Color3.fromRGB(40, 40, 50),
    DropdownHover = Color3.fromRGB(50, 50, 60),
    ErrorColor = Color3.fromRGB(255, 85, 85),
    SuccessColor = Color3.fromRGB(85, 255, 127)
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
            saved_key = Config.CORRECT_KEY,
            timestamp = os.time()
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
    
    -- Show notification
    notify("Discord Link Copied", "Paste in browser to join", 15)
end

--================================================================================--
--[[ CHECK IF KEY IS ALREADY VERIFIED - BUT STILL SHOW UI ]]--
--================================================================================--
local alreadyVerified = loadKeyData()

--================================================================================--
--[[ PREMIUM UI FUNCTIONS ]]--
--================================================================================--
local function createFrame(parent, size, position, transparency, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or Config.GlassColor
    frame.BackgroundTransparency = transparency or Config.GlassTransparency
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or Config.CornerRadius)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.GlassColor
    stroke.Thickness = 1.5
    stroke.Transparency = 0.6
    stroke.Parent = frame

    if parent then
        frame.Parent = parent
    end
    
    return frame
end

local function createNotification(title, message, notificationType, duration)
    local duration = duration or 2.5
    local notificationGUI = Instance.new("ScreenGui")
    notificationGUI.Name = "WarpHubKeyNotification_" .. HttpService:GenerateGUID(false)
    notificationGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    notificationGUI.ResetOnSpawn = false
    
    local padding = 12
    local notificationWidth = 320
    local titleHeight = 24
    local messageHeight = 36
    local totalHeight = titleHeight + messageHeight + padding

    local mainFrame = createFrame(nil, UDim2.new(0, notificationWidth, 0, totalHeight), 
        UDim2.new(1, -notificationWidth - 20, 1, totalHeight), 
        0.05, Config.DarkGlassColor, 12)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -padding * 2, 0, titleHeight)
    titleLabel.Position = UDim2.new(0, padding, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = Config.AccentColor
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -padding * 2, 0, messageHeight)
    messageLabel.Position = UDim2.new(0, padding, 0, titleHeight)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = Config.TextColor
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.GothamMedium
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    
    titleLabel.Parent = mainFrame
    messageLabel.Parent = mainFrame
    mainFrame.Parent = notificationGUI
    notificationGUI.Parent = CoreGui
    
    local targetY = 80
    
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -notificationWidth - 20, 0, targetY)
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -notificationWidth - 20, 1, totalHeight)
        }):Play()
        
        task.wait(0.3)
        if notificationGUI and notificationGUI.Parent then
            notificationGUI:Destroy()
        end
    end)
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, -notificationWidth - 20, 1, totalHeight)
            }):Play()
            
            task.wait(0.2)
            if notificationGUI and notificationGUI.Parent then
                notificationGUI:Destroy()
            end
        end
    end)
end

--================================================================================--
--[[ CREATE KEY SYSTEM UI ]]--
--================================================================================--
local windowWidth = 480
local windowHeight = 480

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WarpHubKeySystem"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

local MainFrame = createFrame(nil, UDim2.new(0, windowWidth, 0, windowHeight), 
    UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2), 
    Config.DarkGlassTransparency, Config.DarkGlassColor, 22)

-- Top Bar
local topBarHeight = 55
local TopBar = createFrame(MainFrame, UDim2.new(1, -24, 0, topBarHeight), 
    UDim2.new(0, 12, 0, 12), 0.1, Config.GlassColor, 14)

local windowTitle = Instance.new("TextLabel")
windowTitle.Size = UDim2.new(1, -16, 1, 0)
windowTitle.Position = UDim2.new(0, 16, 0, 0)
windowTitle.BackgroundTransparency = 1
windowTitle.Text = Config.HubName
windowTitle.TextColor3 = Config.TextColor
windowTitle.TextSize = 26
windowTitle.Font = Enum.Font.GothamBlack
windowTitle.TextXAlignment = Enum.TextXAlignment.Left

local titleGlow = Instance.new("UIGradient")
titleGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.AccentColor),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Config.SecondaryColor)
})
titleGlow.Parent = windowTitle
windowTitle.Parent = TopBar

-- Logo/Icon
local logoContainer = createFrame(MainFrame, UDim2.new(0, 120, 0, 120), 
    UDim2.new(0.5, -60, 0, topBarHeight + 40), 0.1, Config.GlassColor, 20)

local logoLetter = Instance.new("TextLabel")
logoLetter.Size = UDim2.new(1, 0, 1, 0)
logoLetter.BackgroundTransparency = 1
logoLetter.Text = "W"
logoLetter.TextColor3 = Config.AccentColor
logoLetter.TextSize = 64
logoLetter.Font = Enum.Font.GothamBlack
logoLetter.TextTransparency = 0
logoLetter.Parent = logoContainer

local logoGlow = Instance.new("UIGradient")
logoGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.AccentColor),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Config.SecondaryColor)
})
logoGlow.Parent = logoLetter

-- Status Text
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -40, 0, 30)
statusText.Position = UDim2.new(0, 20, 0, topBarHeight + 180)
statusText.BackgroundTransparency = 1
statusText.Text = alreadyVerified and "Key already verified! Click VERIFY to continue." or "Enter your key to access premium features"
statusText.TextColor3 = alreadyVerified and Config.SuccessColor or Config.SubTextColor
statusText.TextSize = 16
statusText.Font = Enum.Font.GothamMedium
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.Parent = MainFrame

-- Key Input Box
local keyInputContainer = createFrame(MainFrame, UDim2.new(1, -60, 0, 52), 
    UDim2.new(0, 30, 0, topBarHeight + 220), 0.1, Config.InputBackground, 14)

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -20, 1, 0)
keyInput.Position = UDim2.new(0, 10, 0, 0)
keyInput.BackgroundTransparency = 1
keyInput.PlaceholderText = alreadyVerified and "Key already saved (click VERIFY)" or "Enter your premium key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
keyInput.TextColor3 = Config.TextColor
keyInput.TextSize = 16
keyInput.Font = Enum.Font.GothamMedium
keyInput.ClearTextOnFocus = false
keyInput.Text = alreadyVerified and Config.CORRECT_KEY or ""
keyInput.Parent = keyInputContainer

-- Buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -60, 0, 52)
buttonContainer.Position = UDim2.new(0, 30, 0, topBarHeight + 290)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = MainFrame

local buttonList = Instance.new("UIListLayout")
buttonList.Padding = UDim.new(0, 12)
buttonList.FillDirection = Enum.FillDirection.Horizontal
buttonList.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonList.SortOrder = Enum.SortOrder.LayoutOrder
buttonList.Parent = buttonContainer

local verifyButton = Instance.new("TextButton")
verifyButton.Size = UDim2.new(0.5, -6, 1, 0)
verifyButton.BackgroundColor3 = alreadyVerified and Config.SuccessColor or Config.AccentColor
verifyButton.BackgroundTransparency = 0.2
verifyButton.AutoButtonColor = false
verifyButton.Text = alreadyVerified and "CONTINUE" or "VERIFY KEY"
verifyButton.TextColor3 = Config.TextColor
verifyButton.TextSize = 16
verifyButton.Font = Enum.Font.GothamBold
verifyButton.BorderSizePixel = 0
verifyButton.LayoutOrder = 1

local verifyCorner = Instance.new("UICorner")
verifyCorner.CornerRadius = UDim.new(0, 12)
verifyCorner.Parent = verifyButton

local getKeyButton = Instance.new("TextButton")
getKeyButton.Size = UDim2.new(0.5, -6, 1, 0)
getKeyButton.BackgroundColor3 = Config.ButtonColor
getKeyButton.BackgroundTransparency = 0.2
getKeyButton.AutoButtonColor = false
getKeyButton.Text = "GET KEY"
getKeyButton.TextColor3 = Config.TextColor
getKeyButton.TextSize = 16
getKeyButton.Font = Enum.Font.GothamMedium
getKeyButton.BorderSizePixel = 0
getKeyButton.LayoutOrder = 2

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 12)
getKeyCorner.Parent = getKeyButton

verifyButton.Parent = buttonContainer
getKeyButton.Parent = buttonContainer

-- Footer Text
local footerText = Instance.new("TextLabel")
footerText.Size = UDim2.new(1, -40, 0, 40)
footerText.Position = UDim2.new(0, 20, 1, -50)
footerText.BackgroundTransparency = 1
footerText.Text = "Join our Discord for keys and updates"
footerText.TextColor3 = Config.SubTextColor
footerText.TextSize = 14
footerText.Font = Enum.Font.Gotham
footerText.TextXAlignment = Enum.TextXAlignment.Center
footerText.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("ImageButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -46, 0, 14)
CloseButton.BackgroundTransparency = 1
CloseButton.Image = "rbxassetid://3926305904"
CloseButton.ImageRectOffset = Vector2.new(284, 4)
CloseButton.ImageRectSize = Vector2.new(24, 24)
CloseButton.ImageColor3 = Config.TextColor
CloseButton.Parent = TopBar

-- Add blur effect
local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0
blur.Enabled = true

-- Add to CoreGui
MainFrame.Parent = ScreenGui
ScreenGui.Parent = CoreGui

--================================================================================--
--[[ UI INTERACTIONS ]]--
--================================================================================--
local isClosing = false
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new(0, 0, 0, 0)

local function closeUI()
    if isClosing then return end
    isClosing = true
    
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.3)
    if ScreenGui then
        ScreenGui:Destroy()
    end
    if blur and blur.Parent then
        blur:Destroy()
    end
end

local function handleDragInput(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end

TopBar.InputBegan:Connect(handleDragInput)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

CloseButton.MouseButton1Click:Connect(closeUI)

-- Button hover effects
verifyButton.MouseEnter:Connect(function()
    if isClosing then return end
    TweenService:Create(verifyButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.1,
        BackgroundColor3 = Config.ButtonHoverColor,
        Size = UDim2.new(0.5, -2, 1.05, 0)
    }):Play()
end)

verifyButton.MouseLeave:Connect(function()
    if isClosing then return end
    TweenService:Create(verifyButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2,
        BackgroundColor3 = alreadyVerified and Config.SuccessColor or Config.AccentColor,
        Size = UDim2.new(0.5, -6, 1, 0)
    }):Play()
end)

getKeyButton.MouseEnter:Connect(function()
    if isClosing then return end
    TweenService:Create(getKeyButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.1,
        BackgroundColor3 = Config.ButtonHoverColor,
        Size = UDim2.new(0.5, -2, 1.05, 0)
    }):Play()
end)

getKeyButton.MouseLeave:Connect(function()
    if isClosing then return end
    TweenService:Create(getKeyButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2,
        BackgroundColor3 = Config.ButtonColor,
        Size = UDim2.new(0.5, -6, 1, 0)
    }):Play()
end)

CloseButton.MouseEnter:Connect(function()
    if isClosing then return end
    TweenService:Create(CloseButton, TweenInfo.new(0.15), {
        ImageColor3 = Config.ErrorColor,
        Size = UDim2.new(0, 32, 0, 32)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    if isClosing then return end
    TweenService:Create(CloseButton, TweenInfo.new(0.15), {
        ImageColor3 = Config.TextColor,
        Size = UDim2.new(0, 28, 0, 28)
    }):Play()
end)

logoContainer.MouseEnter:Connect(function()
    if isClosing then return end
    TweenService:Create(logoContainer, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 130, 0, 130),
        Position = UDim2.new(0.5, -65, 0, topBarHeight + 35)
    }):Play()
    TweenService:Create(logoLetter, TweenInfo.new(0.2), {
        TextSize = 70
    }):Play()
end)

logoContainer.MouseLeave:Connect(function()
    if isClosing then return end
    TweenService:Create(logoContainer, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 120, 0, 120),
        Position = UDim2.new(0.5, -60, 0, topBarHeight + 40)
    }):Play()
    TweenService:Create(logoLetter, TweenInfo.new(0.2), {
        TextSize = 64
    }):Play()
end)

--================================================================================--
--[[ KEY VERIFICATION LOGIC ]]--
--================================================================================--
local function updateStatus(text, isError)
    statusText.Text = text
    if isError then
        TweenService:Create(statusText, TweenInfo.new(0.15), {
            TextColor3 = Config.ErrorColor
        }):Play()
    else
        TweenService:Create(statusText, TweenInfo.new(0.15), {
            TextColor3 = Config.SuccessColor
        }):Play()
    end
end

local function showError(message)
    updateStatus(message, true)
    createNotification("Key Error", message, "error", 3)
    
    -- Shake animation
    local originalPos = keyInputContainer.Position
    for i = 1, 3 do
        TweenService:Create(keyInputContainer, TweenInfo.new(0.05), {
            Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 5, originalPos.Y.Scale, originalPos.Y.Offset)
        }):Play()
        task.wait(0.05)
        TweenService:Create(keyInputContainer, TweenInfo.new(0.05), {
            Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 5, originalPos.Y.Scale, originalPos.Y.Offset)
        }):Play()
        task.wait(0.05)
    end
    TweenService:Create(keyInputContainer, TweenInfo.new(0.1), {Position = originalPos}):Play()
end

local function showSuccess(message)
    updateStatus(message, false)
    createNotification("Success", message, "success", 3)
end

local function startLoadingAnimation()
    -- Hide input elements
    TweenService:Create(keyInputContainer, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(keyInput, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(verifyButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    TweenService:Create(getKeyButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    
    -- Create loading bar
    local loadingContainer = createFrame(MainFrame, UDim2.new(1, -60, 0, 8), 
        UDim2.new(0, 30, 0, topBarHeight + 280), 0.2, Config.SliderTrack, 4)
    loadingContainer.BackgroundTransparency = 0.8
    
    local loadingFill = createFrame(loadingContainer, UDim2.new(0, 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), 0, Config.SuccessColor, 4)
    loadingFill.BackgroundTransparency = 0
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0, 15)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading hub... 0%"
    loadingText.TextColor3 = Config.SuccessColor
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.GothamMedium
    loadingText.TextXAlignment = Enum.TextXAlignment.Center
    loadingText.Parent = loadingContainer
    
    -- Animate loading
    for i = 0, 100, 2 do
        loadingFill.Size = UDim2.new(i/100, 0, 1, 0)
        loadingText.Text = string.format("Loading hub... %d%%", i)
        task.wait(0.03)
    end
    
    return loadingContainer, loadingFill, loadingText
end

local function loadMainHub()
    -- Start loading animation
    local loadingContainer, loadingFill, loadingText = startLoadingAnimation()
    
    -- Load the hub
    task.wait(1)
    
    local success, result = pcall(function()
        loadstring(game:HttpGet(Config.ScriptToLoad))()
    end)
    
    if success then
        loadingText.Text = "Hub loaded successfully!"
        task.wait(1)
        
        -- Close the key system UI
        closeUI()
    else
        showError("Failed to load hub: " .. tostring(result))
        -- Reset UI
        TweenService:Create(keyInputContainer, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(keyInput, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(verifyButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
        TweenService:Create(getKeyButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
        
        if loadingContainer then
            loadingContainer:Destroy()
        end
    end
end

verifyButton.MouseButton1Click:Connect(function()
    local key = keyInput.Text:gsub("%s+", "") -- Remove whitespace
    
    if key == "" then
        showError("Please enter a key")
        return
    end
    
    if alreadyVerified or key == Config.CORRECT_KEY then
        if not alreadyVerified then
            -- Save the key if this is the first time verifying
            saveKeyData()
        end
        showSuccess("Key verified! Loading hub...")
        
        -- Load the main hub
        loadMainHub()
    else
        showError("Invalid key! Please try again.")
    end
end)

getKeyButton.MouseButton1Click:Connect(function()
    showSuccess("Opening Discord...")
    handleDiscordInvite()
end)

-- Allow Enter key to submit
keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        verifyButton.MouseButton1Click:Fire()
    end
end)

--================================================================================--
--[[ INTRO ANIMATION ]]--
--================================================================================--
-- Initial transparent state
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
TopBar.BackgroundTransparency = 1
logoContainer.BackgroundTransparency = 1
logoLetter.TextTransparency = 1
statusText.TextTransparency = 1
keyInputContainer.BackgroundTransparency = 1
keyInput.TextTransparency = 1
keyInput.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
verifyButton.BackgroundTransparency = 1
verifyButton.TextTransparency = 1
getKeyButton.BackgroundTransparency = 1
getKeyButton.TextTransparency = 1
footerText.TextTransparency = 1
windowTitle.TextTransparency = 1
CloseButton.ImageTransparency = 1

-- Intro animation
task.wait(0.5)
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 12}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, windowWidth, 0, windowHeight),
    BackgroundTransparency = Config.DarkGlassTransparency
}):Play()

task.wait(0.3)

-- Fade in elements
local elements = {
    {TopBar, "BackgroundTransparency", 0.1},
    {windowTitle, "TextTransparency", 0},
    {CloseButton, "ImageTransparency", 0},
    {logoContainer, "BackgroundTransparency", 0.1},
    {logoLetter, "TextTransparency", 0},
    {statusText, "TextTransparency", 0},
    {keyInputContainer, "BackgroundTransparency", 0.1},
    {keyInput, "TextTransparency", 0},
    {keyInput, "PlaceholderColor3", Color3.fromRGB(120, 120, 140)},
    {verifyButton, "BackgroundTransparency", 0.2},
    {verifyButton, "TextTransparency", 0},
    {getKeyButton, "BackgroundTransparency", 0.2},
    {getKeyButton, "TextTransparency", 0},
    {footerText, "TextTransparency", 0}
}

for _, elementData in ipairs(elements) do
    local element = elementData[1]
    local property = elementData[2]
    local value = elementData[3]
    
    if element and element[property] then
        TweenService:Create(element, TweenInfo.new(0.3), {
            [property] = value
        }):Play()
    end
    task.wait(0.05)
end

-- Auto-focus on input if not already verified
if not alreadyVerified then
    task.wait(0.5)
    keyInput:CaptureFocus()
end

-- Prevent UI from being destroyed when scripts load
ScreenGui.Destroying:Connect(function()
    if blur and blur.Parent then
        blur:Destroy()
    end
end)

-- Return success
return true
