local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local highlights = {}

-- Создаем интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileHighlighterDraggable"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Функция для перетаскивания (Drag & Drop)
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Основная кнопка
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 60)
toggleButton.Position = UDim2.new(0.02, 0, 0.5, -30)
toggleButton.Text = "🌟 ВКЛ"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.ZIndex = 10
toggleButton.Active = true -- Обязательно для перетаскивания!
toggleButton.Parent = screenGui
makeDraggable(toggleButton)

-- Кнопка настроек
local settingsButton = Instance.new("TextButton")
settingsButton.Size = UDim2.new(0, 60, 0, 60)
settingsButton.Position = UDim2.new(0.02, 160, 0.5, -30)
settingsButton.Text = "⚙"
settingsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
settingsButton.TextColor3 = Color3.new(1, 1, 1)
settingsButton.Font = Enum.Font.SourceSansBold
settingsButton.TextSize = 25
settingsButton.ZIndex = 10
settingsButton.Active = true
settingsButton.Parent = screenGui
makeDraggable(settingsButton)

-- Панель настроек
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 200, 0, 120)
settingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsFrame.Visible = false
settingsFrame.ZIndex = 11
settingsFrame.Parent = screenGui

local colorButton = Instance.new("TextButton")
colorButton.Size = UDim2.new(1, -10, 0, 40)
colorButton.Position = UDim2.new(0, 5, 0, 5)
colorButton.Text = "Цвет: 🔴"
colorButton.Parent = settingsFrame

local transparencyButton = Instance.new("TextButton")
transparencyButton.Size = UDim2.new(1, -10, 0, 40)
transparencyButton.Position = UDim2.new(0, 5, 0, 50)
transparencyButton.Text = "Прозрачность: 50%"
transparencyButton.Parent = settingsFrame

-- Логика цветов
local colors = {
    {emoji = "🔴", color = Color3.fromRGB(255, 50, 50)},
    {emoji = "🟢", color = Color3.fromRGB(50, 255, 50)},
    {emoji = "🔵", color = Color3.fromRGB(50, 50, 255)}
}
local currentColorIndex = 1
local currentTransparency = 0.5

local function createHighlight(character)
    if not character or character:FindFirstChild("PlayerHighlight") then return end
    local h = Instance.new("Highlight")
    h.Name = "PlayerHighlight"
    h.Adornee = character
    h.FillColor = colors[currentColorIndex].color
    h.OutlineColor = Color3.new(1, 1, 1)
    h.FillTransparency = currentTransparency
    h.Parent = character
end

local function updateAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local old = plr.Character:FindFirstChild("PlayerHighlight")
            if old then old:Destroy() end
            if toggleButton.Text == "🌟 ВЫКЛ" then
                createHighlight(plr.Character)
            end
        end
    end
end

-- Обработка кликов
toggleButton.MouseButton1Click:Connect(function()
    local enabled = toggleButton.Text == "🌟 ВКЛ"
    toggleButton.Text = enabled and "🌟 ВЫКЛ" or "🌟 ВКЛ"
    toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 170, 255)
    updateAll()
end)

settingsButton.MouseButton1Click:Connect(function()
    -- Панель настроек появляется под кнопкой шестеренки
    settingsFrame.Position = UDim2.new(settingsButton.Position.X.Scale, settingsButton.Position.X.Offset, settingsButton.Position.Y.Scale, settingsButton.Position.Y.Offset + 70)
    settingsFrame.Visible = not settingsFrame.Visible
end)

colorButton.MouseButton1Click:Connect(function()
    currentColorIndex = currentColorIndex % #colors + 1
    colorButton.Text = "Цвет: "..colors[currentColorIndex].emoji
    updateAll()
end)

transparencyButton.MouseButton1Click:Connect(function()
    currentTransparency = (currentTransparency + 0.2) % 1
    transparencyButton.Text = "Прозрачность: "..math.floor((1-currentTransparency)*100).."%"
    updateAll()
end)

-- Следим за новыми игроками
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1) -- Подождем загрузки персонажа
        if toggleButton.Text == "🌟 ВЫКЛ" then createHighlight(char) end
    end)
end)

print("ESP готов! Кнопки можно таскать. 🌟⚙️")
