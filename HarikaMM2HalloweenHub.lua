-- Harika MM2 Halloween Hub
-- v0.1 - mobile-first purple neon prototype
-- No remote code loaders, no touch spoofing, no teleport/noclip.
-- Candy collection depends on the current MM2 map and may need adaptation.

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end

local GUI_NAME = "HarikaMM2HalloweenHub"
local old = player:WaitForChild("PlayerGui"):FindFirstChild(GUI_NAME)
if old then old:Destroy() end

local PURPLE = Color3.fromRGB(160, 72, 255)
local PURPLE_DARK = Color3.fromRGB(31, 16, 49)
local PANEL = Color3.fromRGB(20, 13, 31)
local PANEL_2 = Color3.fromRGB(37, 23, 55)
local WHITE = Color3.fromRGB(247, 241, 255)
local MUTED = Color3.fromRGB(177, 160, 197)
local GREEN = Color3.fromRGB(97, 245, 173)
local RED = Color3.fromRGB(255, 104, 130)

local state = {
    enabled = false,
    running = false,
    found = 0,
    target = nil,
    lastScan = 0,
    lastMove = 0,
    connections = {},
    alive = true,
}

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(state.connections, c)
    return c
end

local function cleanup()
    state.alive = false
    state.enabled = false
    state.target = nil
    for _, c in ipairs(state.connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(state.connections)
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = gui

local function updateScale()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local width = camera.ViewportSize.X
    scale.Scale = math.clamp(width / 420, 0.76, 1)
end
updateScale()
if Workspace.CurrentCamera then
    connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), updateScale)
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(340, 330)
main.Position = UDim2.new(0.5, -170, 0.5, -165)
main.BackgroundColor3 = PANEL
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local outline = Instance.new("UIStroke")
outline.Color = PURPLE
outline.Thickness = 1.6
outline.Transparency = 0.12
outline.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 72)
header.BackgroundColor3 = PURPLE_DARK
header.BorderSizePixel = 0
header.Parent = main
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 18)
headerFix.Position = UDim2.new(0, 0, 1, -18)
headerFix.BackgroundColor3 = PURPLE_DARK
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 9)
title.Size = UDim2.new(1, -66, 0, 29)
title.Font = Enum.Font.GothamBold
title.Text = "✦ HARIKA MM2"
title.TextColor3 = WHITE
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(17, 38)
subtitle.Size = UDim2.new(1, -32, 0, 20)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "HALLOWEEN  •  CANDY MODE"
subtitle.TextColor3 = Color3.fromRGB(207, 157, 255)
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 34)
close.Position = UDim2.new(1, -46, 0, 15)
close.BackgroundColor3 = Color3.fromRGB(74, 35, 91)
close.Text = "×"
close.TextColor3 = WHITE
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.AutoButtonColor = true
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 10)

local statusCard = Instance.new("Frame")
statusCard.Position = UDim2.fromOffset(14, 86)
statusCard.Size = UDim2.new(1, -28, 0, 57)
statusCard.BackgroundColor3 = PANEL_2
statusCard.BorderSizePixel = 0
statusCard.Parent = main
Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 11)

local statusDot = Instance.new("Frame")
statusDot.Position = UDim2.fromOffset(13, 21)
statusDot.Size = UDim2.fromOffset(13, 13)
statusDot.BackgroundColor3 = RED
statusDot.BorderSizePixel = 0
statusDot.Parent = statusCard
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.fromOffset(36, 8)
statusLabel.Size = UDim2.new(1, -47, 0, 22)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "READY TO SCAN"
statusLabel.TextColor3 = WHITE
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusCard

local detailLabel = Instance.new("TextLabel")
detailLabel.BackgroundTransparency = 1
detailLabel.Position = UDim2.fromOffset(36, 29)
detailLabel.Size = UDim2.new(1, -47, 0, 18)
detailLabel.Font = Enum.Font.Gotham
detailLabel.Text = "Candy targets: checking..."
detailLabel.TextColor3 = MUTED
detailLabel.TextSize = 11
detailLabel.TextXAlignment = Enum.TextXAlignment.Left
detailLabel.Parent = statusCard

local countCard = Instance.new("Frame")
countCard.Position = UDim2.fromOffset(14, 153)
countCard.Size = UDim2.new(0.5, -19, 0, 58)
countCard.BackgroundColor3 = PANEL_2
countCard.BorderSizePixel = 0
countCard.Parent = main
Instance.new("UICorner", countCard).CornerRadius = UDim.new(0, 11)

local countTitle = Instance.new("TextLabel")
countTitle.BackgroundTransparency = 1
countTitle.Position = UDim2.fromOffset(12, 7)
countTitle.Size = UDim2.new(1, -20, 0, 18)
countTitle.Font = Enum.Font.Gotham
countTitle.Text = "SESSION PICKS"
countTitle.TextColor3 = MUTED
countTitle.TextSize = 10
countTitle.TextXAlignment = Enum.TextXAlignment.Left
countTitle.Parent = countCard

local countValue = Instance.new("TextLabel")
countValue.BackgroundTransparency = 1
countValue.Position = UDim2.fromOffset(12, 24)
countValue.Size = UDim2.new(1, -20, 0, 26)
countValue.Font = Enum.Font.GothamBold
countValue.Text = "0"
countValue.TextColor3 = WHITE
countValue.TextSize = 21
countValue.TextXAlignment = Enum.TextXAlignment.Left
countValue.Parent = countCard

local targetsCard = Instance.new("Frame")
targetsCard.Position = UDim2.new(0.5, 5, 0, 153)
targetsCard.Size = UDim2.new(0.5, -19, 0, 58)
targetsCard.BackgroundColor3 = PANEL_2
targetsCard.BorderSizePixel = 0
targetsCard.Parent = main
Instance.new("UICorner", targetsCard).CornerRadius = UDim.new(0, 11)

local targetsTitle = Instance.new("TextLabel")
targetsTitle.BackgroundTransparency = 1
targetsTitle.Position = UDim2.fromOffset(12, 7)
targetsTitle.Size = UDim2.new(1, -20, 0, 18)
targetsTitle.Font = Enum.Font.Gotham
targetsTitle.Text = "CANDY FOUND"
targetsTitle.TextColor3 = MUTED
targetsTitle.TextSize = 10
targetsTitle.TextXAlignment = Enum.TextXAlignment.Left
targetsTitle.Parent = targetsCard

local targetsValue = Instance.new("TextLabel")
targetsValue.BackgroundTransparency = 1
targetsValue.Position = UDim2.fromOffset(12, 24)
targetsValue.Size = UDim2.new(1, -20, 0, 26)
targetsValue.Font = Enum.Font.GothamBold
targetsValue.Text = "0"
targetsValue.TextColor3 = Color3.fromRGB(219, 174, 255)
targetsValue.TextSize = 21
targetsValue.TextXAlignment = Enum.TextXAlignment.Left
targetsValue.Parent = targetsCard

local farmButton = Instance.new("TextButton")
farmButton.Position = UDim2.fromOffset(14, 225)
farmButton.Size = UDim2.new(1, -28, 0, 43)
farmButton.BackgroundColor3 = PURPLE
farmButton.BorderSizePixel = 0
farmButton.Font = Enum.Font.GothamBold
farmButton.Text = "▶   START CANDY FARM"
farmButton.TextColor3 = WHITE
farmButton.TextSize = 14
farmButton.AutoButtonColor = true
farmButton.Parent = main
Instance.new("UICorner", farmButton).CornerRadius = UDim.new(0, 12)

local scanButton = Instance.new("TextButton")
scanButton.Position = UDim2.fromOffset(14, 277)
scanButton.Size = UDim2.new(0.5, -19, 0, 34)
scanButton.BackgroundColor3 = PANEL_2
scanButton.BorderSizePixel = 0
scanButton.Font = Enum.Font.GothamSemibold
scanButton.Text = "↻  RESCAN"
scanButton.TextColor3 = WHITE
scanButton.TextSize = 12
scanButton.Parent = main
Instance.new("UICorner", scanButton).CornerRadius = UDim.new(0, 10)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Position = UDim2.new(0.5, 5, 0, 277)
minimizeButton.Size = UDim2.new(0.5, -19, 0, 34)
minimizeButton.BackgroundColor3 = PANEL_2
minimizeButton.BorderSizePixel = 0
minimizeButton.Font = Enum.Font.GothamSemibold
minimizeButton.Text = "—  MINIMIZE"
minimizeButton.TextColor3 = WHITE
minimizeButton.TextSize = 12
minimizeButton.Parent = main
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 10)

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(14, 310)
footer.Size = UDim2.new(1, -28, 0, 14)
footer.Font = Enum.Font.Gotham
footer.Text = "HARIKA • MOBILE UI • v0.1"
footer.TextColor3 = MUTED
footer.TextSize = 9
footer.Parent = main

-- Drag support for mouse and touch.
local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        dragInput = input
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
connect(UserInputService.InputEnded, function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragInput = false, nil
    end
end)

local minimized = false
connect(minimizeButton.Activated, function()
    minimized = not minimized
    statusCard.Visible = not minimized
    countCard.Visible = not minimized
    targetsCard.Visible = not minimized
    farmButton.Visible = not minimized
    scanButton.Visible = not minimized
    footer.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(340, 72) or UDim2.fromOffset(340, 330)
    minimizeButton.Text = minimized and "+  EXPAND" or "—  MINIMIZE"
end)

local function setStatus(text, color, detail)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or WHITE
    statusDot.BackgroundColor3 = color or PURPLE
    if detail then detailLabel.Text = detail end
end

local function getCharacterParts()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return nil end
    return character, humanoid, root
end

local function isCandyContainer(obj)
    if not (obj:IsA("Folder") or obj:IsA("Model")) then return false end
    local n = string.lower(obj.Name)
    return n == "candycontainer" or n == "coincontainer" or n == "tokencontainer"
end

local function isCandyPart(obj)
    if not obj:IsA("BasePart") then return false end
    local id = obj:GetAttribute("CoinID")
    if typeof(id) == "string" and string.lower(id) == "candy" then return true end
    local name = string.lower(obj.Name)
    return name == "candy" or name == "candy_server" or name == "coin_candy"
end

local function isAvailable(obj)
    if not obj or not obj.Parent or not obj:IsDescendantOf(Workspace) then return false end
    if not isCandyPart(obj) then return false end
    if obj:GetAttribute("Collected") == true or not obj.CanTouch then return false end
    local visual = obj:FindFirstChild("CoinVisual")
    if visual and visual:GetAttribute("Collected") == true then return false end
    if obj.Transparency >= 1 and (not visual or not visual:IsA("BasePart") or visual.Transparency >= 1) then
        return false
    end
    return true
end

local function scanCandy()
    local results, seen = {}, {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isCandyContainer(obj) then
            for _, item in ipairs(obj:GetDescendants()) do
                if isCandyPart(item) and isAvailable(item) and not seen[item] then
                    seen[item] = true
                    table.insert(results, item)
                end
            end
        end
    end
    -- Some event versions place live pickups outside a named container.
    if #results == 0 then
        for _, item in ipairs(Workspace:GetDescendants()) do
            if isCandyPart(item) and isAvailable(item) and not seen[item] then
                seen[item] = true
                table.insert(results, item)
            end
        end
    end
    state.lastScan = os.clock()
    targetsValue.Text = tostring(#results)
    detailLabel.Text = "Candy targets: " .. tostring(#results)
    return results
end

local function nearestCandy()
    local _, _, root = getCharacterParts()
    if not root then return nil end
    local best, bestDistance = nil, math.huge
    for _, item in ipairs(scanCandy()) do
        if item and item.Parent then
            local distance = (item.Position - root.Position).Magnitude
            if distance < bestDistance then
                best, bestDistance = item, distance
            end
        end
    end
    return best
end

local function stopFarm(message)
    state.enabled = false
    state.running = false
    state.target = nil
    farmButton.Text = "▶   START CANDY FARM"
    farmButton.BackgroundColor3 = PURPLE
    setStatus(message or "FARM PAUSED", MUTED, "Tap start to resume")
end

connect(farmButton.Activated, function()
    state.enabled = not state.enabled
    if state.enabled then
        farmButton.Text = "■   STOP CANDY FARM"
        farmButton.BackgroundColor3 = Color3.fromRGB(111, 48, 147)
        setStatus("SCANNING FOR CANDY", GREEN, "Walking to nearby targets")
        state.lastMove = 0
    else
        stopFarm("FARM STOPPED")
        local _, humanoid = getCharacterParts()
        if humanoid then humanoid:MoveTo((select(3, getCharacterParts()) or Vector3.zero).Position) end
    end
end)

connect(scanButton.Activated, function()
    local found = scanCandy()
    if #found > 0 then
        setStatus("CANDY DETECTED", GREEN, tostring(#found) .. " possible targets")
    else
        setStatus("NO CANDY FOUND", RED, "May be lobby, event off, or names changed")
    end
end)

connect(close.Activated, function()
    cleanup()
    gui:Destroy()
end)

connect(player.CharacterAdded, function()
    state.target = nil
    if state.enabled then
        setStatus("CHARACTER RESPAWNED", MUTED, "Searching for candy again...")
    end
end)

local scanAccumulator = 0
connect(RunService.Heartbeat, function(dt)
    if not state.alive or not state.enabled then return end
    if not getCharacterParts() then
        setStatus("WAITING FOR CHARACTER", MUTED, "Waiting for respawn...")
        return
    end

    scanAccumulator += dt
    if scanAccumulator >= 1.25 then
        scanAccumulator = 0
        local target = nearestCandy()
        state.target = target
        if target then
            local _, humanoid, root = getCharacterParts()
            if humanoid and root and target.Parent then
                humanoid:MoveTo(target.Position)
                state.lastMove = os.clock()
                setStatus("WALKING TO CANDY", GREEN, string.format("Distance: %d studs", math.floor((target.Position-root.Position).Magnitude)))
            end
        else
            state.target = nil
            setStatus("NO CANDY TARGET", RED, "Wait for a round or rescan")
        end
    end

    local target = state.target
    if target and not isAvailable(target) then
        state.found += 1
        countValue.Text = tostring(state.found)
        state.target = nil
        setStatus("PICKUP CHANGED", GREEN, "Checking next candy...")
    end
end)

connect(RunService.Heartbeat, function()
    if not state.alive then return end
    if os.clock() - state.lastScan > 3 and not state.enabled then
        -- Keep the UI passive until the user presses Rescan.
    end
end)

print("[Harika MM2 Halloween Hub] UI loaded. Candy farm is experimental; test in a safe session.")
