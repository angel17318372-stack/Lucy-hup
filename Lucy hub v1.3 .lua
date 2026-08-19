--// LUCY v1.3
--// Mobile UI | Fly | Speed | Noclip | Infinite Jump | Anti-Fling local
--// LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local Config = {
    Speed = 80,
    FlySpeed = 80,
    MinSpeed = 16,
    MaxSpeed = 250,
    MinFlySpeed = 20,
    MaxFlySpeed = 250,
}

local State = {
    Speed = false,
    KeepSpeed = false,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    AntiFling = false,
}

local Character
local Humanoid
local Root

local FlyVelocity
local FlyGyro
local FlyConnection

local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

--==================================================
-- CHARACTER
--==================================================

local function UpdateCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")

    OriginalWalkSpeed = Humanoid.WalkSpeed
    OriginalJumpPower = Humanoid.JumpPower

    if State.Speed then
        Humanoid.WalkSpeed = Config.Speed
    end
end

UpdateCharacter()

--==================================================
-- GUI
--==================================================

local OldGui = PlayerGui:FindFirstChild("LucyV13")
if OldGui then
    OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LucyV13"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

-- Main
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(360, 420)
Main.Position = UDim2.new(0.5, -180, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 70, 100)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.15
Stroke.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 65)
Top.BackgroundColor3 = Color3.fromRGB(20, 20, 29)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 18)
TopCorner.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "LUCY v1.3"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -120, 0, 18)
SubTitle.Position = UDim2.fromOffset(22, 39)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "MOBILE CONTROL PANEL"
SubTitle.TextColor3 = Color3.fromRGB(130, 135, 160)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(42, 42)
Close.Position = UDim2.new(1, -52, 0, 11)
Close.BackgroundColor3 = Color3.fromRGB(40, 40, 54)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 25
Close.Parent = Top

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 12)

--==================================================
-- TABS
--==================================================

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -24, 0, 42)
Tabs.Position = UDim2.fromOffset(12, 75)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 7)
TabLayout.Parent = Tabs

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -24, 1, -130)
Pages.Position = UDim2.fromOffset(12, 125)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

local function CreatePage()
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = Pages

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 9)
    Layout.Parent = Page

    return Page
end

local MovementPage = CreatePage()
local ProtectionPage = CreatePage()
local SettingsPage = CreatePage()

local function CreateTab(Text)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(105, 40)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(160, 165, 185)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Tabs

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

    return Button
end

local MovementTab = CreateTab("MOVIMIENTO")
local ProtectionTab = CreateTab("PROTECCIÓN")
local SettingsTab = CreateTab("AJUSTES")

local function SelectPage(Page, Button)
    MovementPage.Visible = false
    ProtectionPage.Visible = false
    SettingsPage.Visible = false

    MovementTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ProtectionTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

    MovementTab.TextColor3 = Color3.fromRGB(160, 165, 185)
    ProtectionTab.TextColor3 = Color3.fromRGB(160, 165, 185)
    SettingsTab.TextColor3 = Color3.fromRGB(160, 165, 185)

    Page.Visible = true
    Button.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

MovementTab.MouseButton1Click:Connect(function()
    SelectPage(MovementPage, MovementTab)
end)

ProtectionTab.MouseButton1Click:Connect(function()
    SelectPage(ProtectionPage, ProtectionTab)
end)

SettingsTab.MouseButton1Click:Connect(function()
    SelectPage(SettingsPage, SettingsTab)
end)

--==================================================
-- BUTTONS
--==================================================

local function CreateToggle(Parent, Text, Default, Callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -4, 0, 48)
    Button.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    Button.BorderSizePixel = 0
    Button.Text = Text .. "   OFF"
    Button.TextColor3 = Color3.fromRGB(190, 192, 210)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 14
    Button.Parent = Parent

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 12)

    local Enabled = Default or false

    local function Refresh()
        if Enabled then
            Button.Text = Text .. "   ON"
            Button.BackgroundColor3 = Color3.fromRGB(35, 115, 75)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.Text = Text .. "   OFF"
            Button.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
            Button.TextColor3 = Color3.fromRGB(190, 192, 210)
        end
    end

    Button.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Refresh()
        Callback(Enabled)
    end)

    Refresh()

    return Button
end

local function CreateSlider(Parent, Text, Min, Max, Value, Callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -4, 0, 72)
    Holder.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    Holder.BorderSizePixel = 0
    Holder.Parent = Parent

    Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 12)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.fromOffset(10, 6)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. tostring(Value)
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 8)
    Bar.Position = UDim2.fromOffset(10, 48)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder

    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(70, 145, 235)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Dragging = false

    local function SetValue(InputX)
        local Relative = math.clamp(
            (InputX - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
            0,
            1
        )

        local NewValue = math.floor(Min + ((Max - Min) * Relative))
        Value = NewValue

        Fill.Size = UDim2.new(Relative, 0, 1, 0)
        Label.Text = Text .. ": " .. tostring(NewValue)

        Callback(NewValue)
    end

    Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            SetValue(Input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (
            Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch
        ) then
            SetValue(Input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    return Holder
end

--==================================================
-- MOVEMENT
--==================================================

CreateToggle(MovementPage, "🏃 Velocidad", false, function(Value)
    State.Speed = Value

    if Humanoid then
        if Value then
            Humanoid.WalkSpeed = Config.Speed
        else
            Humanoid.WalkSpeed = OriginalWalkSpeed
        end
    end
end)

CreateToggle(MovementPage, "🔒 Mantener velocidad", false, function(Value)
    State.KeepSpeed = Value
end)

CreateSlider(
    MovementPage,
    "Velocidad",
    Config.MinSpeed,
    Config.MaxSpeed,
    Config.Speed,
    function(Value)
        Config.Speed = Value

        if State.Speed and Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
)

CreateToggle(MovementPage, "✈️ Fly", false, function(Value)
    State.Fly = Value

    if Value then
        StartFly()
    else
        StopFly()
    end
end)

CreateSlider(
    MovementPage,
    "Fly Speed",
    Config.MinFlySpeed,
    Config.MaxFlySpeed,
    Config.FlySpeed,
    function(Value)
        Config.FlySpeed = Value
    end
)

CreateToggle(MovementPage, "👻 Noclip", false, function(Value)
    State.Noclip = Value
end)

CreateToggle(MovementPage, "♾️ Infinite Jump", false, function(Value)
    State.InfiniteJump = Value
end)

--==================================================
-- FLY
--==================================================

function StopFly()
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

    if Humanoid then
        Humanoid.PlatformStand = false
        Humanoid.AutoRotate = true
    end
end

function StartFly()
    if not Character or not Humanoid or not Root then
        UpdateCharacter()
    end

    StopFly()

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "LucyFlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    FlyVelocity.P = 15000
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "LucyFlyGyro"
    FlyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    FlyGyro.P = 15000
    FlyGyro.D = 500
    FlyGyro.CFrame = workspace.CurrentCamera.CFrame
    FlyGyro.Parent = Root

    Humanoid.AutoRotate = false

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not State.Fly or not Root or not Root.Parent then
            return
        end

        local Camera = workspace.CurrentCamera
        local Move = Humanoid.MoveDirection

        -- El joystick controla dirección horizontal.
        -- La cámara determina hacia dónde mira el vuelo.
        local CameraLook = Camera.CFrame.LookVector
        local CameraRight = Camera.CFrame.RightVector

        local HorizontalLook = Vector3.new(
            CameraLook.X,
            0,
            CameraLook.Z
        )

        local HorizontalRight = Vector3.new(
            CameraRight.X,
            0,
            CameraRight.Z
        )

        if HorizontalLook.Magnitude > 0 then
            HorizontalLook = HorizontalLook.Unit
        end

        if HorizontalRight.Magnitude > 0 then
            HorizontalRight = HorizontalRight.Unit
        end

        local X = Move.X
        local Z = Move.Z

        local Direction =
            HorizontalRight * X +
            HorizontalLook * (-Z)

        -- Botón de salto móvil = subir.
        if Humanoid.Jump then
            Direction += Vector3.new(0, 1, 0)
        end

        -- Si no hay movimiento, permanecer en el aire.
        if Direction.Magnitude > 0 then
            Direction = Direction.Unit
            FlyVelocity.Velocity = Direction * Config.FlySpeed
        else
            FlyVelocity.Velocity = Vector3.zero
        end

        FlyGyro.CFrame = CFrame.lookAt(
            Root.Position,
            Root.Position + Camera.CFrame.LookVector
        )
    end)
end

--==================================================
-- PROTECTION
--==================================================

CreateToggle(ProtectionPage, "🛡️ Anti-Fling local", false, function(Value)
    State.AntiFling = Value
end)

CreateToggle(ProtectionPage, "🧱 Noclip", false, function(Value)
    State.Noclip = Value
end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -4, 0, 80)
Info.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
Info.BorderSizePixel = 0
Info.Text =
    "PROTECCIONES LOCALES\n\n" ..
    "Estas opciones actúan sobre tu personaje.\n" ..
    "No modifican ni engañan al servidor."
Info.TextColor3 = Color3.fromRGB(175, 180, 200)
Info.Font = Enum.Font.GothamMedium
Info.TextSize = 12
Info.TextWrapped = true
Info.Parent = ProtectionPage

Instance.new("UICorner", Info).CornerRadius = UDim.new(0, 12)

--==================================================
-- SETTINGS
--==================================================

local PanelSize = Instance.new("TextButton")
PanelSize.Size = UDim2.new(1, -4, 0, 48)
PanelSize.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
PanelSize.BorderSizePixel = 0
PanelSize.Text = "📐 Tamaño del panel"
PanelSize.TextColor3 = Color3.fromRGB(220, 220, 235)
PanelSize.Font = Enum.Font.GothamMedium
PanelSize.TextSize = 14
PanelSize.Parent = SettingsPage

Instance.new("UICorner", PanelSize).CornerRadius = UDim.new(0, 12)

local Sizes = {
    UDim2.fromOffset(320, 380),
    UDim2.fromOffset(360, 420),
    UDim2.fromOffset(410, 480),
}

local SizeIndex = 2

PanelSize.MouseButton1Click:Connect(function()
    SizeIndex += 1

    if SizeIndex > #Sizes then
        SizeIndex = 1
    end

    Main.Size = Sizes[SizeIndex]
end)

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(1, -4, 0, 48)
HideButton.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
HideButton.BorderSizePixel = 0
HideButton.Text = "👁️ Ocultar panel"
HideButton.TextColor3 = Color3.fromRGB(220, 220, 235)
HideButton.Font = Enum.Font.GothamMedium
HideButton.TextSize = 14
HideButton.Parent = SettingsPage

Instance.new("UICorner", HideButton).CornerRadius = UDim.new(0, 12)

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(55, 55)
Mini.Position = UDim2.new(0, 20, 0.5, -25)
Mini.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
Mini.BorderSizePixel = 0
Mini.Text = "L"
Mini.TextColor3 = Color3.fromRGB(255, 255, 255)
Mini.Font = Enum.Font.GothamBold
Mini.TextSize = 24
Mini.Visible = false
Mini.Parent = Gui

Instance.new("UICorner", Mini).CornerRadius = UDim.new(1, 0)

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(70, 145, 235)
MiniStroke.Thickness = 2
MiniStroke.Parent = Mini

HideButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
    Main.Visible = true
    Mini.Visible = false
end)

--==================================================
-- DRAG PANEL
--==================================================

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Dragging and (
        Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch
    ) then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)

--==================================================
-- CONTINUOUS SYSTEMS
--==================================================

RunService.Heartbeat:Connect(function()
    if not Character or not Character.Parent then
        return
    end

    if State.Speed and State.KeepSpeed and Humanoid then
        if Humanoid.WalkSpeed ~= Config.Speed then
            Humanoid.WalkSpeed = Config.Speed
        end
    end

    if State.Noclip then
        for _, Object in ipairs(Character:GetDescendants()) do
            if Object:IsA("BasePart") then
                Object.CanCollide = false
            end
        end
    end

    if State.AntiFling and Root then
        local Velocity = Root.AssemblyLinearVelocity

        if Velocity.Magnitude > 180 then
            Root.AssemblyLinearVelocity = Vector3.zero
        end

        local Angular = Root.AssemblyAngularVelocity

        if Angular.Magnitude > 100 then
            Root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

--==================================================
-- INFINITE JUMP
--==================================================

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then
     
