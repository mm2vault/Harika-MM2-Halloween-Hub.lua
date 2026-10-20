if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Удаляем старый UI
if player.PlayerGui:FindFirstChild("MM2_UI") then
    player.PlayerGui.MM2_UI:Destroy()
end

-- Стартовые значения
local autoFarmEnabled = false
local autoResetEnabled = false
local disableRenderEnabled = false
local antiAFKUsed = false

-- Halloween UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MM2_UI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.5, -160, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(15, 0, 15)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 120, 0)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Halloween градиент
local gradient = Instance.new("UIGradient", frame)
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(30, 0, 50)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(80, 0, 120)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(150, 0, 60)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 80, 20)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 140, 0))
})

frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 320, 0, 260)
}):Play()

-- 🎃 Тыква вместо солнца
local pumpkin = Instance.new("Frame", frame)
pumpkin.Size = UDim2.new(0, 42, 0, 42)
pumpkin.Position = UDim2.new(0.82, 0, 0.04, 0)
pumpkin.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
pumpkin.BorderSizePixel = 0
Instance.new("UICorner", pumpkin).CornerRadius = UDim.new(1, 0)

-- Глаза
for i = 1, 2 do
    local eye = Instance.new("Frame", pumpkin)
    eye.Size = UDim2.new(0, 6, 0, 6)
    eye.Position = UDim2.new(i == 1 and 0.3 or 0.65, 0, 0.3, 0)
    eye.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", eye).CornerRadius = UDim.new(1, 0)
end

-- Рот
local mouth = Instance.new("Frame", pumpkin)
mouth.Size = UDim2.new(0.5, 0, 0.2, 0)
mouth.Position = UDim2.new(0.25, 0, 0.65, 0)
mouth.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", mouth)

-- Анимация покачивания
local angle = 0
RunService.RenderStepped:Connect(function()
    angle += 0.8
    pumpkin.Rotation = math.sin(angle/20) * 8
end)

-- Заголовок
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -50, 0, 42)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎃 Murder Mystery 2 | Halloween 🕷️"
title.TextColor3 = Color3.fromRGB(255, 180, 50)
title.Font = Enum.Font.FredokaOne
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.3
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 6)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
Instance.new("UICorner", closeBtn)

-- Фон контента
local contentBg = Instance.new("Frame", frame)
contentBg.Size = UDim2.new(0.92, 0, 0.76, 0)
contentBg.Position = UDim2.new(0.04, 0, 0.18, 0)
contentBg.BackgroundColor3 = Color3.fromRGB(20, 0, 20)
contentBg.BackgroundTransparency = 0.4
Instance.new("UICorner", contentBg)

local content = Instance.new("Frame", contentBg)
content.Size = UDim2.new(1, -10, 1, -10)
content.Position = UDim2.new(0, 5, 0, 5)
content.BackgroundTransparency = 1

-- Функция создания переключателей
local function createToggle(yPos, labelText, defaultValue, callback)
    local label = Instance.new("TextLabel", content)
    label.Size = UDim2.new(0.7, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 200, 150)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("TextButton", content)
    toggleBg.Size = UDim2.new(0, 50, 0, 25)
    toggleBg.Position = UDim2.new(0.78, 0, 0, yPos + 2)
    toggleBg.BackgroundColor3 = defaultValue and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(100, 100, 100)
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = defaultValue and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    toggleBg.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        local pos = defaultValue and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
        local color = defaultValue and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(100, 100, 100)
        TweenService:Create(toggleKnob, TweenInfo.new(0.25), { Position = pos }):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = color }):Play()
        callback(defaultValue)
    end)
end

createToggle(10, "🎃 Auto Farm Coins", autoFarmEnabled, function(value) autoFarmEnabled = value end)
createToggle(40, "💀 Auto Reset", autoResetEnabled, function(value) autoResetEnabled = value end)
createToggle(70, "👻 Disable Render", disableRenderEnabled, function(value)
    disableRenderEnabled = value
    RunService:Set3dRenderingEnabled(not disableRenderEnabled)
end)

-- Anti-AFK
local afkBtn = Instance.new("TextButton", content)
afkBtn.Size = UDim2.new(0.9, 0, 0, 32)
afkBtn.Position = UDim2.new(0.05, 0, 0, 110)
afkBtn.BackgroundColor3 = antiAFKUsed and Color3.fromRGB(70, 160, 70) or Color3.fromRGB(255, 120, 0)
afkBtn.Text = antiAFKUsed and "Anti-AFK Active" or "Enable Anti-AFK"
afkBtn.TextColor3 = Color3.new(1, 1, 1)
afkBtn.Font = Enum.Font.GothamBold
afkBtn.TextSize = 15
Instance.new("UICorner", afkBtn)

afkBtn.MouseButton1Click:Connect(function()
    if not antiAFKUsed then
        antiAFKUsed = true
        afkBtn.Text = "🕷️ Anti-AFK Active"
        afkBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 70)
        loadstring(game:HttpGet("https://pastebin.com/raw/bwP4bmed"))()
    end
end)

-- Время в игре
local startTime = tick()
local playTimeLabel = Instance.new("TextLabel", content)
playTimeLabel.Size = UDim2.new(0.9, 0, 0, 28)
playTimeLabel.Position = UDim2.new(0.05, 0, 0, 155)
playTimeLabel.BackgroundTransparency = 1
playTimeLabel.Text = "⏳ time in game: 0d 0h 0m 0s"
playTimeLabel.TextColor3 = Color3.fromRGB(255, 200, 150)
playTimeLabel.Font = Enum.Font.GothamBold
playTimeLabel.TextSize = 14
playTimeLabel.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while true do
        local delta = math.floor(tick() - startTime)
        local d, h, m, s = math.floor(delta/86400), math.floor(delta%86400/3600), math.floor(delta%3600/60), delta%60
        playTimeLabel.Text = string.format("⏳ time in game: %dd %02dh %02dm %02ds", d, h, m, s)
        task.wait(1)
    end
end)

-- Перетаскивание UI
local dragging, dragInput, dragStart, startPos
local function updateFramePosition(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        if input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                else
                    updateFramePosition(input)
                end
            end)
        end

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateFramePosition(input)
    end
end)

-- Скрытие/раскрытие
local isHidden = false
closeBtn.MouseButton1Click:Connect(function()
    isHidden = not isHidden
    local newSize = isHidden and UDim2.new(0, 320, 0, 42) or UDim2.new(0, 320, 0, 260)
    TweenService:Create(frame, TweenInfo.new(0.3), { Size = newSize }):Play()
    contentBg.Visible = not isHidden
    pumpkin.Visible = not isHidden
end)

-- Auto Farm Coins
local CoinCollected = ReplicatedStorage.Remotes.Gameplay.CoinCollected
local RoundStart = ReplicatedStorage.Remotes.Gameplay.RoundStart
local RoundEnd = ReplicatedStorage.Remotes.Gameplay.RoundEndFade

local farming = false
local bag_full = false
local resetting = false
local start_position = nil

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local function getCharacter() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getCharacter():WaitForChild("HumanoidRootPart") end

CoinCollected.OnClientEvent:Connect(function(_, current, max)
    if current == max and not resetting and autoResetEnabled then
        resetting = true
        bag_full = true
        local hrp = getHRP()
        if start_position then
            local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = start_position})
            tween:Play()
            tween.Completed:Wait()
        end
        task.wait(0.5)
        player.Character.Humanoid.Health = 0
        player.CharacterAdded:Wait()
        task.wait(1.5)
        resetting = false
        bag_full = false
    end
end)

RoundStart.OnClientEvent:Connect(function()
    farming = true
    start_position = getHRP().CFrame
end)

RoundEnd.OnClientEvent:Connect(function()
    farming = false
end)

local function get_nearest_coin()
    local hrp = getHRP()
    local closest, dist = nil, math.huge
    for _, m in pairs(workspace:GetChildren()) do
        if m:FindFirstChild("CoinContainer") then
            for _, coin in pairs(m.CoinContainer:GetChildren()) do
                if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                    local d = (hrp.Position - coin.Position).Magnitude
                    if d < dist then closest, dist = coin, d end
                end
            end
        end
    end
    return closest, dist
end

task.spawn(function()
    while true do
        if autoFarmEnabled and farming and not bag_full then
            local coin, dist = get_nearest_coin()
            if coin then
                local hrp = getHRP()
                if dist > 150 then
                    hrp.CFrame = coin.CFrame
                else
                    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 20, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                    tween:Play()
                    repeat task.wait() until not coin:FindFirstChild("TouchInterest") or not farming or not autoFarmEnabled
                    tween:Cancel()
                end
            end
        end
        task.wait(0.2)
    end
end)
