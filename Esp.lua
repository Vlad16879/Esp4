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

-- Функция для превращения любого объекта в перетаскиваемый (Drag & Drop)
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
toggleButton.Parent = screenGui
makeDraggable(toggleButton) -- ТЕПЕРЬ ЛЕТАЕТ! 🚀

-- Кнопка настроек
local settingsButton = Instance.new("TextButton")
settingsButton.Size = UDim2.new(0, 60, 0, 60)
settingsButton.Position = UDim2.new(0.02, 160, 0.5, -30)
settingsButton.Text = "⚙"
settingsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
settingsButton.TextColor3 = Color3.new(1,
