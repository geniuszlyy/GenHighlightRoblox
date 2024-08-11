local Players = game:GetService("Players")

-- Функция обновления цвета подсветки
local function UpdateFillColor(Player, Highlighter)
	local DefaultColor = Color3.fromRGB(255, 48, 51)
	Highlighter.FillColor = (Player.TeamColor and Player.TeamColor.Color) or DefaultColor
end

-- Функция обработки отключения подсветки и событий
local function Disconnect(Highlighter, Connections)
	Highlighter:Remove()
	for _, Connection in ipairs(Connections) do
		Connection:Disconnect()
	end
end

-- Функция настройки подсветки для персонажа
local function SetupCharacter(Player, Character)
	print("Setting up character for player:", Player.Name)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		print("No Humanoid found for character:", Character.Name)
		return
	end

	local Connections = {}
	local Highlighter = Instance.new("Highlight", Character)

	-- Начальная настройка цвета подсветки
	UpdateFillColor(Player, Highlighter)

	-- Обработчик изменения цвета команды
	table.insert(Connections, Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
		UpdateFillColor(Player, Highlighter)
	end))

	-- Обработчик изменения здоровья
	table.insert(Connections, Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			Disconnect(Highlighter, Connections)
		end
	end))

	-- Отключение подсветки при удалении персонажа
	Character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			Disconnect(Highlighter, Connections)
		end
	end)
end

-- Функция применения подсветки к игроку
local function ApplyHighlight(Player)
	-- Подсветка игрока, если у него уже есть персонаж
	if Player.Character then
		SetupCharacter(Player, Player.Character)
	end

	-- Подсветка нового персонажа, когда он создается
	Player.CharacterAdded:Connect(function(Character)
		SetupCharacter(Player, Character)
	end)
end

-- Применение подсветки ко всем существующим игрокам
for _, Player in ipairs(Players:GetPlayers()) do
	ApplyHighlight(Player)
end

-- Применение подсветки к новым игрокам
Players.PlayerAdded:Connect(ApplyHighlight)
