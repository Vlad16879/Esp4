local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local highlights = {}

-- Создаем интерфейс для мобильных устройств
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileHighlighterPro"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная кнопка с анимацией
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 160, 0, 70) -- Увеличенный размер
toggleButton.Position = UDim2.new(0.02, 0, 0.5, -35)
toggleButton.Text = "🌠 ВКЛ"
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui

-- Индикатор долгого нажатия
local holdIndicator = Instance.new("Frame")
holdIndicator.Name = "HoldIndicator"
holdIndicator.Size = UDim2.new(0, 0, 1, 0)
holdIndicator.Position = UDim2.new(0, 0, 0, 0)
holdIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
holdIndicator.BorderSizePixel = 0
holdIndicator.ZIndex = 11
holdIndicator.Parent = toggleButton

-- Панель настроек с анимацией
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "MobileSettingsPro"
settingsFrame.Size = UDim2.new(0, 200, 0, 140)
settingsFrame.Position = UDim2.new(0.02, 0, 0.65, 0)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.ZIndex = 9
settingsFrame.Parent = screenGui

-- Улучшенные элементы настроек
local colorButton = Instance.new("TextButton")
colorButton.Name = "ColorButtonPro"
colorButton.Size = UDim2.new(1, -10, 0, 45)
colorButton.Position = UDim2.new(0, 5, 0, 5)
colorButton.Text = "🌈 Цвет: 🔴"
colorButton.TextSize = 16
colorButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
colorButton.TextColor3 = Color3.new(1, 1, 1)
colorButton.ZIndex = 10
colorButton.Parent = settingsFrame

local transparencyButton = Instance.new("TextButton")
transparencyButton.Name = "TransparencyButtonPro"
transparencyButton.Size = UDim2.new(1, -10, 0, 45)
transparencyButton.Position = UDim2.new(0, 5, 0, 55)
transparencyButton.Text = "👁 Прозрачность: 50%"
transparencyButton.TextSize = 16
transparencyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
transparencyButton.TextColor3 = Color3.new(1, 1, 1)
transparencyButton.ZIndex = 10
transparencyButton.Parent = settingsFrame

-- Дополнительная кнопка эффектов
local effectsButton = Instance.new("TextButton")
effectsButton.Name = "EffectsButton"
effectsButton.Size = UDim2.new(1, -10, 0, 45)
effectsButton.Position = UDim2.new(0, 5, 0, 105)
effectsButton.Text = "✨ Эффекты: ВЫКЛ"
effectsButton.TextSize = 16
effectsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
effectsButton.TextColor3 = Color3.new(1, 1, 1)
effectsButton.ZIndex = 10
effectsButton.Parent = settingsFrame

-- Цвета и настройки
local colors = {
    {emoji = "🔴", color = Color3.fromRGB(255, 50, 50)},
    {emoji = "🟢", color = Color3.fromRGB(50, 255, 50)},
    {emoji = "🔵", color = Color3.fromRGB(50, 50, 255)},
    {emoji = "🟡", color = Color3.fromRGB(255, 255, 50)},
    {emoji = "🟣", color = Color3.fromRGB(255, 50, 255)}
}
local currentColorIndex = 1
local currentTransparency = 0.5
local effectsEnabled = false
local isHolding = false
local holdStartTime = 0

-- Анимации
local function tweenButton(button, size, time)
    local tweenInfo = TweenInfo.new(
        time,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(button, tweenInfo, {Size = size})
    tween:Play()
end

-- Функции подсветки
local function createHighlight(character)
    if not character or character:FindFirstChild("PlayerHighlightPro") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlightPro"
    highlight.Adornee = character
    highlight.FillColor = colors[currentColorIndex].color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = currentTransparency
    highlight.Parent = character
    
    if effectsEnabled then
        local particle = Instance.new("ParticleEmitter")
        particle.Name = "HighlightParticle"
        particle.Texture = "rbxassetid://242487987"
        particle.LightEmission = 1
        particle.Size = NumberSequence.new(0.5)
        particle.Transparency = NumberSequence.new(0.5)
        particle.Speed = NumberRange.new(2)
        particle.Lifetime = NumberRange.new(1)
        particle.Rate = 20
        particle.Rotation = NumberRange.new(0, 360)
        particle.Parent = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
    end
    
    return highlight
end

local function updateAllHighlights()
    for _, highlightData in pairs(highlights) do
        if highlightData and highlightData.highlight and highlightData.highlight.Parent then
            highlightData.highlight.FillColor = colors[currentColorIndex].color
            highlightData.highlight.FillTransparency = currentTransparency
            
            if highlightData.particle then
                highlightData.particle.Enabled = effectsEnabled
            end
        end
    end
end

local function removeHighlight(character)
    if not character then return end
    local highlight = character:FindFirstChild("PlayerHighlightPro")
    if highlight then highlight:Destroy() end
    
    local particle = character:FindFirstChild("HighlightParticle") 
        or (character:FindFirstChild("HumanoidRootPart") 
        and character.HumanoidRootPart:FindFirstChild("HighlightParticle"))
    if particle then particle:Destroy() end
end

-- Обработчики для мобильных устройств
local function startHold()
    isHolding = true
    holdStartTime = os.clock()
    
    local holdTween = TweenService:Create(
        holdIndicator,
        TweenInfo.new(2, Enum.EasingStyle.Linear),
        {Size = UDim2.new(1, 0, 1, 0)}
    )
    holdTween:Play()
    
    while isHolding and os.clock() - holdStartTime < 2 do
        task.wait()
    end
    
    if isHolding then
        toggleSettings()
    end
    
    isHolding = false
    holdIndicator.Size = UDim2.new(0, 0, 1, 0)
end

local function toggleEffects()
    effectsEnabled = not effectsEnabled
    effectsButton.Text = effectsEnabled and "✨ Эффекты: ВКЛ" or "✨ Эффекты: ВЫКЛ"
    updateAllHighlights()
end

-- Назначаем обработчики
toggleButton.MouseButton1Down:Connect(function()
    task.spawn(startHold)
end)

toggleButton.MouseButton1Up:Connect(function()
    if not isHolding and os.clock() - holdStartTime < 0.5 then
        local enabled = toggleButton.Text == "🌠 ВКЛ"
        toggleButton.Text = enabled and "🌠 ВЫКЛ" or "🌠 ВКЛ"
        toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 170, 255)
        updateHighlightsState(not enabled)
    end
    isHolding = false
end)

colorButton.MouseButton1Click:Connect(function()
    currentColorIndex = currentColorIndex % #colors + 1
    colorButton.Text = "🌈 Цвет: "..colors[currentColorIndex].emoji
    updateAllHighlights()
    tweenButton(colorButton, UDim2.new(1, -10, 0, 40), 0.2)
    task.wait(0.2)
    tweenButton(colorButton, UDim2.new(1, -10, 0, 45), 0.2)
end)

transparencyButton.MouseButton1Click:Connect(function()
    currentTransparency = (currentTransparency + 0.2) % 1
    transparencyButton.Text = "👁 Прозрачность: "..math.floor((1-currentTransparency)*100).."%"
    updateAllHighlights()
    tweenButton(transparencyButton, UDim2.new(1, -10, 0, 40), 0.2)
    task.wait(0.2)
    tweenButton(transparencyButton, UDim2.new(1, -10, 0, 45), 0.2)
end)

effectsButton.MouseButton1Click:Connect(function()
    toggleEffects()
    tweenButton(effectsButton, UDim2.new(1, -10, 0, 40), 0.2)
    task.wait(0.2)
    tweenButton(effectsButton, UDim2.new(1, -10, 0, 45), 0.2)
end)

-- Инициализация
Players.PlayerAdded:Connect(function(plr)
    if toggleButton.Text == "🌠 ВЫКЛ" then
        plr.CharacterAdded:Connect(function(char)
            highlights[plr] = {highlight = createHighlight(char)}
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then
        removeHighlight(plr.Character)
        highlights[plr] = nil
    end
end)

-- Первоначальная настройка
toggleButton.Text = "🌠 ВКЛ"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
