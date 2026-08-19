--// LUCY v1.3
--// LocalScript para tu propia experiencia de Roblox
--// Mobile + PC

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local SpeedValue = 16
local FlySpeed = 80

local SpeedEnabled = false
local FlyEnabled = false
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local AntiFlingEnabled = false

local FlyVelocity
local FlyGyro
local FlyConnection

--==================================================
-- LIMPIEZA
--==================================================

local OldGui = PlayerGui:FindFirstChild("LucyV1")
if OldGui then
    OldGui:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "LucyV1"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(360, 360)
Main.Position = UDim2.new(0.5, -180, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 18)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(75, 145, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0.15
Stroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 18)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 5)
Title.Size = UDim2.new(1, -80, 0, 55)
Title.Text = "LUCY v1"
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(45, 45)
Close.Position = UDim2.new(1, -55, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 25
Close.BorderSizePixel = 0
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 13)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

--==================================================
-- DRAG MÓVIL / PC
--==================================================

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
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- CONTENEDOR
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Position = UDim2.fromOffset(10, 75)
Content.Size = UDim2.new(1, -20, 1, -85)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.fromOffset(0, 0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Content

--==================================================
-- TOGGLE
--==================================================

local function CreateToggle(text, callback)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 48)
    Button.BackgroundColor3 = Color3.fromRGB(27, 27, 38)
    Button.BorderSizePixel = 0
    Button.Text = text .. "   OFF"
    Button.TextColor3 = Color3.fromRGB(190, 190, 205)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 16
    Button.Parent = Content

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 12)

    local enabled = false

    Button.MouseButton1Click:Connect(function()

        enabled = not enabled

        if enabled then
            Button.Text = text .. "   ON"
            Button.BackgroundColor3 = Color3.fromRGB(35, 105, 190)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.Text = text .. "   OFF"
            Button.BackgroundColor3 = Color3.fromRGB(27, 27, 38)
            Button.TextColor3 = Color3.fromRGB(190, 190, 205)
        end

        callback(enabled)
    end)

    return Button
end

--==================================================
-- VELOCIDAD
--==================================================

local SpeedButton = CreateToggle("⚡ Velocidad", function(state)
    SpeedEnabled = state
end)

--==================================================
-- FLY
--==================================================

local function StopFly()

    FlyEnabled = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            Humanoid.PlatformStand = false
        end
    end
end

local function StartFly()

    StopFly()

    local Character = Player.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Root or not Humanoid then return end

    FlyEnabled = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "LucyFlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "LucyFlyGyro"
    FlyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyGyro.P = 90000
    FlyGyro.D = 1000
    FlyGyro.Parent = Root

    Humanoid.PlatformStand = true

    FlyConnection = RunService.RenderStepped:Connect(function()

        if not FlyEnabled then return end
        if not Root.Parent then
            StopFly()
            return
        end

        local Camera = workspace.CurrentCamera

        -- El joystick móvil alimenta MoveDirection.
        -- En PC también funcionan WASD mediante Humanoid.
        local Direction = Humanoid.MoveDirection

        if Direction.Magnitude > 1 then
            Direction = Direction.Unit
        end

        -- Mantiene la dirección relativa a la cámara.
        if Direction.Magnitude > 0.01 then
            Direction = Camera.CFrame:VectorToWorldSpace(
                Vector3.new(
                    Direction.X,
                    0,
                    Direction.Z
                )
            )
        else
            Direction = Vector3.zero
        end

        FlyVelocity.Velocity = Direction * FlySpeed

        FlyGyro.CFrame = CFrame.lookAt(
            Root.Position,
            Root.Position + Camera.CFrame.LookVector
        )
    end)
end

CreateToggle("✈️ Fly", function(state)

    FlyEnabled = state

    if state then
        StartFly()
    else
        StopFly()
    end

end)

--==================================================
-- NOCLIP
--==================================================

CreateToggle("🧱 Noclip", function(state)
    NoclipEnabled = state
end)

RunService.Stepped:Connect(function()

    if not NoclipEnabled then return end

    local Character = Player.Character
    if not Character then return end

    for _, Object in ipairs(Character:GetDescendants()) do

        if Object:IsA("BasePart") then
            Object.CanCollide = false
        end

    end
end)

--==================================================
-- INFINITE JUMP
--==================================================

CreateToggle("⬆️ Infinite Jump", function(state)
    InfiniteJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()

    if not InfiniteJumpEnabled then return end

    local Character = Player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--==================================================
-- ANTI FLING LOCAL
--==================================================

CreateToggle("🛡️ Anti-Fling", function(state)

    AntiFlingEnabled = state

end)

RunService.Heartbeat:Connect(function()

    if not AntiFlingEnabled then return end

    local Character = Player.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local Velocity = Root.AssemblyLinearVelocity

    if Velocity.Magnitude > 250 then

        Root.AssemblyLinearVelocity = Vector3.new(
            math.clamp(Velocity.X, -100, 100),
            math.clamp(Velocity.Y, -100, 100),
            math.clamp(Velocity.Z, -100, 100)
        )
    end
end)

--==================================================
-- VELOCIDAD
--==================================================

RunService.Heartbeat:Connect(function()

    if not SpeedEnabled then return end

    local Character = Player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid.WalkSpeed = SpeedValue
    end
end)

--==================================================
-- SELECTOR DE VELOCIDAD
--==================================================

local SpeedBox = Instance.new("Frame")
SpeedBox.Size = UDim2.new(1, -10, 0, 58)
SpeedBox.BackgroundColor3 = Color3.fromRGB(27, 27, 38)
SpeedBox.BorderSizePixel = 0
SpeedBox.Parent = Content

Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 12)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.fromOffset(12, 0)
SpeedLabel.Size = UDim2.new(0.55, 0, 1, 0)
SpeedLabel.Text = "⚡ Velocidad: " .. SpeedValue
SpeedLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextSize = 15
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedBox

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.fromOffset(105, 38)
SpeedInput.Position = UDim2.new(1, -115, 0, 10)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SpeedInput.Text = tostring(SpeedValue)
SpeedInput.PlaceholderText = "16"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 15
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = SpeedBox

Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 9)

SpeedInput.FocusLost:Connect(function()

    local Number = tonumber(SpeedInput.Text)

    if Number then

        SpeedValue = math.clamp(Number, 1, 500)

        SpeedInput.Text = tostring(SpeedValue)
        SpeedLabel.Text = "⚡ Velocidad: " .. SpeedValue

    else

        SpeedInput.Text = tostring(SpeedValue)

    end
end)

--==================================================
-- FLY SPEED
--==================================================

local FlyBox = Instance.new("Frame")
FlyBox.Size = UDim2.new(1, -10, 0, 58)
FlyBox.BackgroundColor3 = Color3.fromRGB(27, 27, 38)
FlyBox.BorderSizePixel = 0
FlyBox.Parent = Content

Instance.new("UICorner", FlyBox).CornerRadius = UDim.new(0, 12)

local FlyLabel = Instance.new("TextLabel")
FlyLabel.BackgroundTransparency = 1
FlyLabel.Position = UDim2.fromOffset(12, 0)
FlyLabel.Size = UDim2.new(0.55, 0, 1, 0)
FlyLabel.Text = "✈️ Fly Speed: " .. FlySpeed
FlyLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
FlyLabel.Font = Enum.Font.GothamMedium
FlyLabel.TextSize = 15
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Parent = FlyBox

local FlyInput = Instance.new("TextBox")
FlyInput.Size = UDim2.fromOffset(105, 38)
FlyInput.Position = UDim2.new(1, -115, 0, 10)
FlyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
FlyInput.Text = tostring(FlySpeed)
FlyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyInput.Font = Enum.Font.GothamBold
FlyInput.TextSize = 15
FlyInput.ClearTextOnFocus = false
FlyInput.Parent = FlyBox

Instance.new("UICorner", FlyInput).CornerRadius = UDim.new(0, 9)

FlyInput.FocusLost:Connect(function()

    local Number = tonumber(FlyInput.Text)

    if Number then

        FlySpeed = math.clamp(Number, 10, 300)

        FlyInput.Text = tostring(FlySpeed)
        FlyLabel.Text = "✈️ Fly Speed: " .. FlySpeed

    else

        FlyInput.Text = tostring(FlySpeed)

    end
end)

--==================================================
-- REDIMENSIONAR
--==================================================

local Resize = Instance.new("TextButton")
Resize.Size = UDim2.fromOffset(35, 35)
Resize.Position = UDim2.new(1, -42, 1, -42)
Resize.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Resize.Text = "↗"
Resize.TextColor3 = Color3.fromRGB(180, 210, 255)
Resize.Font = Enum.Font.GothamBold
Resize.TextSize = 18
Resize.BorderSizePixel = 0
Resize.Parent = Main

Instance.new("UICorner", Resize).CornerRadius = UDim.new(0, 9)

local Large = false

Resize.MouseButton1Click:Connect(function()

    Large = not Large

    if Large then
        Main.Size = UDim2.fromOffset(430, 480)
    else
        Main.Size = UDim2.fromOffset(360, 360)
    end
end)

--==================================================
-- ACTUALIZAR SCROLL
--==================================================

local function UpdateCanvas()

    Content.CanvasSize = UDim2.fromOffset(
        0,
        Layout.AbsoluteContentSize.Y + 15
    )
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

UpdateCanvas()

--==================================================
-- RESPAWN
--==================================================

Player.CharacterAdded:Connect(function()

    task.wait(1)

    if FlyEnabled then
        StartFly()
    end

end)

print("LUCY v1.3 cargado correctamente")
