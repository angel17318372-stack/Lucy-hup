--// LUCY v1
--// Panel móvil | Fly | Noclip | Infinite Jump | Anti-Fling
--// LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// Limpieza
local old = PlayerGui:FindFirstChild("Lucy_v1")
if old then
	old:Destroy()
end

--// Estados
local FlyEnabled = false
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local AntiFlingEnabled = false

local FlySpeed = 80
local BV
local BG
local FlyConnection
local NoclipConnection
local AntiFlingConnection
local JumpConnection

--// GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "Lucy_v1"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(340, 420)
Main.Position = UDim2.new(0.5, -170, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 90, 180)
Stroke.Thickness = 2
Stroke.Transparency = 0.15
Stroke.Parent = Main

--// Barra superior
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = Color3.fromRGB(16, 15, 22)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -65, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.BackgroundTransparency = 1
Title.Text = "LUCY v1"
Title.TextColor3 = Color3.fromRGB(235, 230, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 23
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(40, 40)
Close.Position = UDim2.new(1, -49, 0, 9)
Close.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 25
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 11)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--// Área de botones
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -24, 1, -76)
Container.Position = UDim2.fromOffset(12, 68)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3
Container.CanvasSize = UDim2.fromOffset(0, 0)
Container.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 9)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Container

local function updateCanvas()
	Container.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 12)
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

--// Botón toggle
local function MakeToggle(text, callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -4, 0, 48)
	Button.BackgroundColor3 = Color3.fromRGB(22, 21, 29)
	Button.BorderSizePixel = 0
	Button.Text = text .. "     OFF"
	Button.TextColor3 = Color3.fromRGB(190, 190, 200)
	Button.Font = Enum.Font.GothamMedium
	Button.TextSize = 16
	Button.AutoButtonColor = false
	Button.Parent = Container

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 12)

	local enabled = false

	Button.MouseButton1Click:Connect(function()
		enabled = not enabled

		if enabled then
			Button.Text = text .. "     ON"
			Button.BackgroundColor3 = Color3.fromRGB(70, 58, 125)
			Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			Button.Text = text .. "     OFF"
			Button.BackgroundColor3 = Color3.fromRGB(22, 21, 29)
			Button.TextColor3 = Color3.fromRGB(190, 190, 200)
		end

		callback(enabled)
	end)

	return Button
end

--// Personaje
local function GetCharacter()
	local Character = Player.Character
	if not Character then
		return nil, nil, nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Root = Character:FindFirstChild("HumanoidRootPart")

	return Character, Humanoid, Root
end

--// Fly
local function StopFly()
	FlyEnabled = false

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if BV then
		BV:Destroy()
		BV = nil
	end

	if BG then
		BG:Destroy()
		BG = nil
	end

	local _, Humanoid = GetCharacter()

	if Humanoid then
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
	end
end

local function StartFly()
	StopFly()

	local _, Humanoid, Root = GetCharacter()
	if not Humanoid or not Root then
		return
	end

	FlyEnabled = true

	BV = Instance.new("BodyVelocity")
	BV.Name = "LucyFlyVelocity"
	BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	BV.Velocity = Vector3.zero
	BV.Parent = Root

	BG = Instance.new("BodyGyro")
	BG.Name = "LucyFlyGyro"
	BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	BG.P = 50000
	BG.D = 500
	BG.CFrame = workspace.CurrentCamera.CFrame
	BG.Parent = Root

	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not FlyEnabled or not Root.Parent then
			return
		end

		local Camera = workspace.CurrentCamera
		local Move = Humanoid.MoveDirection

		-- Joystick móvil controla dirección horizontal.
		local Direction = Vector3.zero

		if Move.Magnitude > 0.05 then
			Direction = Move.Unit * math.min(Move.Magnitude, 1)
			
			local CameraLook = Camera.CFrame.LookVector
			local CameraRight = Camera.CFrame.RightVector

			Direction =
				(CameraRight * Direction.X) +
				(CameraLook * Direction.Z)

			if Direction.Magnitude > 0 then
				Direction = Direction.Unit
			end
		end

		-- Teclas de teclado para subir/bajar.
		local Vertical = 0

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			Vertical += 1
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			Vertical -= 1
		end

		BV.Velocity =
			(Direction * FlySpeed) +
			Vector3.new(0, Vertical * FlySpeed, 0)

		BG.CFrame = Camera.CFrame
	end)
end

MakeToggle("✈  Fly", function(state)
	if state then
		StartFly()
	else
		StopFly()
	end
end)

--// Noclip
MakeToggle("◈  Noclip", function(state)
	NoclipEnabled = state

	if NoclipConnection then
		NoclipConnection:Disconnect()
		NoclipConnection = nil
	end

	if state then
		NoclipConnection = RunService.Stepped:Connect(function()
			local Character = Player.Character

			if Character then
				for _, Object in ipairs(Character:GetDescendants()) do
					if Object:IsA("BasePart") then
						Object.CanCollide = false
					end
				end
			end
		end)
	end
end)

--// Infinite Jump
MakeToggle("↑  Infinite Jump", function(state)
	InfiniteJumpEnabled = state

	if JumpConnection then
		JumpConnection:Disconnect()
		JumpConnection = nil
	end

	if state then
		JumpConnection = UserInputService.JumpRequest:Connect(function()
			if not InfiniteJumpEnabled then
				return
			end

			local _, Humanoid = GetCharacter()

			if Humanoid then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end
end)

--// Anti-Fling local
MakeToggle("◆  Anti-Fling", function(state)
	AntiFlingEnabled = state

	if AntiFlingConnection then
		AntiFlingConnection:Disconnect()
		AntiFlingConnection = nil
	end

	if state then
		AntiFlingConnection = RunService.Heartbeat:Connect(function()
			local _, _, Root = GetCharacter()

			if Root then
				local Velocity = Root.AssemblyLinearVelocity

				if Velocity.Magnitude > 250 then
					Root.AssemblyLinearVelocity = Vector3.zero
					Root.AssemblyAngularVelocity = Vector3.zero
				end
			end
		end)
	end
end)

--// Velocidad de Fly
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(1, -4, 0, 48)
SpeedButton.BackgroundColor3 = Color3.fromRGB(22, 21, 29)
SpeedButton.BorderSizePixel = 0
SpeedButton.Text = "⚡  Fly Speed: 80"
SpeedButton.TextColor3 = Color3.fromRGB(210, 205, 225)
SpeedButton.Font = Enum.Font.GothamMedium
SpeedButton.TextSize = 16
SpeedButton.Parent = Container

Instance.new("UICorner", SpeedButton).CornerRadius = UDim.new(0, 12)

SpeedButton.MouseButton1Click:Connect(function()
	FlySpeed += 20

	if FlySpeed > 200 then
		FlySpeed = 40
	end

	SpeedButton.Text = "⚡  Fly Speed: " .. FlySpeed
end)

--// Mostrar / ocultar con botón flotante
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(58, 58)
OpenButton.Position = UDim2.new(0, 18, 0.5, -29)
OpenButton.BackgroundColor3 = Color3.fromRGB(55, 45, 100)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "L"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 25
OpenButton.Visible = false
OpenButton.Parent = Gui

Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)

OpenButton.MouseButton1Click:Connect(function()
	Main.Visible = true
	OpenButton.Visible = false
end)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
	OpenButton.Visible = true
end)

--// Arrastrar panel en móvil/PC
local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local Delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + Delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + Delta.Y
		)
	end
end)

--// Respawn
Player.CharacterAdded:Connect(function()
	task.wait(1)

	if FlyEnabled then
		StartFly()
	end
end)

updateCanvas()

print("Lucy v1 cargado correctamente")
