local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local highlights = {}

-- Создаем интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileHighlighterUltra"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная кнопка
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 150, 0, 60)
toggleButton.Position = UDim2.new(0.02, 0, 0.5, -30)
toggleButton.Text = "🌟 ВКЛ"
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui

-- Кнопка настроек (отдельная)
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Size = UDim2.new(0, 60, 0, 60)
settingsButton.Position = UDim2.new(0.02, 160, 0.5, -30)
settingsButton.Text = "⚙"
settingsButton.TextSize = 20
settingsButton.Font = Enum.Font.SourceSansBold
settingsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
settingsButton.TextColor3 = Color3.new(1, 1, 1)
settingsButton.ZIndex = 10
settingsButton.Parent = screenGui

-- Панель настроек
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsPanel"
settingsFrame.Size = UDim2.new(0, 200, 0, 120)
settingsFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
settingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.ZIndex = 11
settingsFrame.Parent = screenGui

-- Элементы настроек
local colorButton = Instance.new("TextButton")
colorButton.Name = "ColorButton"
colorButton.Size = UDim2.new(1, -10, 0, 40)
colorButton.Position = UDim2.new(0, 5, 0, 5)
colorButton.Text = "Цвет: 🔴"
colorButton.TextSize = 16
colorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
colorButton.TextColor3 = Color3.new(1, 1, 1)
colorButton.ZIndex = 12
colorButton.Parent = settingsFrame

local transparencyButton = Instance.new("TextButton")
transparencyButton.Name = "TransparencyButton"
transparencyButton.Size = UDim2.new(1, -10, 0, 40)
transparencyButton.Position = UDim2.new(0, 5, 0, 50)
transparencyButton.Text = "Прозрачность: 50%"
transparencyButton.TextSize = 16
transparencyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
transparencyButton.TextColor3 = Color3.new(1, 1, 1)
transparencyButton.ZIndex = 12
transparencyButton.Parent = settingsFrame

-- Настройки
local colors = {
    {emoji = "🔴", color = Color3.fromRGB(255, 50, 50)},
    {emoji = "🟢", color = Color3.fromRGB(50, 255, 50)},
    {emoji = "🔵", color = Color3.fromRGB(50, 50, 255)}
}
local currentColorIndex = 1
local currentTransparency = 0.5
local isHolding = false

-- Функции подсветки
local function createHighlight(character)
    if not character or character:FindFirstChild("PlayerHighlight") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = colors[currentColorIndex].color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = currentTransparency
    highlight.Parent = character
    
    return highlight
end

local function updateAllHighlights()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            removeHighlight(plr.Character)
            if toggleButton.Text == "🌟 ВЫКЛ" then
                highlights[plr] = createHighlight(plr.Character)
            end
        end
    end
end

local function removeHighlight(character)
    if not character then return end
    local highlight = character:FindFirstChild("PlayerHighlight")
    if highlight then highlight:Destroy() end
end

-- Обработчики
local function toggleSettings()
    settingsFrame.Visible = not settingsFrame.Visible
end

local function cycleColors()
    currentColorIndex = currentColorIndex % #colors + 1
    colorButton.Text = "Цвет: "..colors[currentColorIndex].emoji
    updateAllHighlights()
end

local function cycleTransparency()
    currentTransparency = (currentTransparency + 0.2) % 1
    transparencyButton.Text = "Прозрачность: "..math.floor((1-currentTransparency)*100).."%"
    updateAllHighlights()
end

-- Удержание кнопки (0.5 сек)
local function startHold()
    isHolding = true
    local startTime = os.clock()
    
    while isHolding and os.clock() - startTime < 0.5 do
        task.wait()
    end
    
    if isHolding then
        toggleSettings()
    end
    isHolding = false
end

-- Назначаем обработчики
settingsButton.MouseButton1Down:Connect(function()
    task.spawn(startHold)
end)

settingsButton.MouseButton1Up:Connect(function()
    isHolding = false
end)

toggleButton.MouseButton1Click:Connect(function()
    local enabled = toggleButton.Text == "🌟 ВКЛ"
    toggleButton.Text = enabled and "🌟 ВЫКЛ" or "🌟 ВКЛ"
    toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 170, 255)
    
    if enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                highlights[plr] = createHighlight(plr.Character)
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                removeHighlight(plr.Character)
            end
            highlights[plr] = nil
        end
    end
end)

colorButton.MouseButton1Click:Connect(cycleColors)
transparencyButton.MouseButton1Click:Connect(cycleTransparency)

-- Инициализация
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if toggleButton.Text == "🌟 ВЫКЛ" then
            highlights[plr] = createHighlight(char)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then
        removeHighlight(plr.Character)
        highlights[plr] = nil
    end
end)
