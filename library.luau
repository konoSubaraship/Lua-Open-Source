local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Load Lucide Icons
local LucideIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/lib/Icons.luau"))()

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CSGOStyleUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Utility Functions
local function Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateIcon(iconName, parent)
    local size = "48px" -- Always use 48px
    local iconData = LucideIcons[size] and LucideIcons[size][iconName]
    
    if not iconData then
        warn("Icon not found:", iconName)
        return nil
    end
    
    local imageId = iconData[1]
    local imageSize = iconData[2]
    local imageRect = iconData[3]
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16) -- Display size
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. imageId
    icon.ImageRectSize = Vector2.new(imageSize[1], imageSize[2])
    icon.ImageRectOffset = Vector2.new(imageRect[1], imageRect[2])
    icon.Parent = parent
    
    return icon
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function MakeResizable(frame, handle, window)
    local resizing = false
    local resizeInput, mousePos, frameSize

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not window.Minimized then
            resizing = true
            mousePos = input.Position
            frameSize = frame.Size

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            resizeInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if resizing and resizeInput and not window.Minimized then
            local delta = resizeInput.Position - mousePos
            local newWidth = math.max(500, frameSize.X.Offset + delta.X)
            local newHeight = math.max(350, frameSize.Y.Offset + delta.Y)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

-- Enhanced Color Scheme - Dark Gray Theme
local Colors = {
    Background = Color3.fromRGB(28, 28, 30),
    BackgroundDark = Color3.fromRGB(20, 20, 22),
    BackgroundDarker = Color3.fromRGB(15, 15, 17),
    Secondary = Color3.fromRGB(24, 24, 26),
    Tertiary = Color3.fromRGB(32, 32, 34),
    Border = Color3.fromRGB(45, 45, 48),
    BorderLight = Color3.fromRGB(60, 60, 63),
    Accent = Color3.fromRGB(70, 70, 75),
    AccentHover = Color3.fromRGB(85, 85, 90),
    AccentDark = Color3.fromRGB(55, 55, 60),
    Text = Color3.fromRGB(235, 235, 240),
    TextDark = Color3.fromRGB(160, 160, 165),
    TextMuted = Color3.fromRGB(120, 120, 125),
    Toggle = Color3.fromRGB(70, 70, 75),
    ToggleOff = Color3.fromRGB(40, 40, 43),
    Header = Color3.fromRGB(12, 12, 14),
    ElementBg = Color3.fromRGB(22, 22, 24),
    ElementHover = Color3.fromRGB(32, 32, 35),
    Success = Color3.fromRGB(60, 180, 75),
    Warning = Color3.fromRGB(245, 166, 35),
    Danger = Color3.fromRGB(220, 53, 69),
}

-- Available Fonts
local Fonts = {
    {Name = "Code", Font = Enum.Font.Code},
    {Name = "Roboto Mono", Font = Enum.Font.RobotoMono},
    {Name = "Ubuntu", Font = Enum.Font.Ubuntu},
    {Name = "Gotham", Font = Enum.Font.Gotham},
    {Name = "Source Sans", Font = Enum.Font.SourceSans},
}

local CurrentFont = Enum.Font.Code
local CurrentFontSize = 10

function Library:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "CHEAT MENU"
    local windowIcon = options.Icon or "layout-dashboard"
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false
    Window.Font = CurrentFont
    Window.FontSize = CurrentFontSize
    Window.Accent = Colors.Accent
    Window.AccentElements = {}

    -- Main Frame (700x400 - better proportions)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    Window.MainFrame = MainFrame

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Colors.Border
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    -- Subtle shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Colors.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 8)
    HeaderCover.Position = UDim2.new(0, 0, 1, -8)
    HeaderCover.BackgroundColor3 = Colors.Header
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header

    local HeaderBorder = Instance.new("Frame")
    HeaderBorder.Size = UDim2.new(1, 0, 0, 1)
    HeaderBorder.Position = UDim2.new(0, 0, 1, 0)
    HeaderBorder.BackgroundColor3 = Colors.Border
    HeaderBorder.BorderSizePixel = 0
    HeaderBorder.Parent = Header

    -- Window Icon
    local WindowIcon = CreateIcon(windowIcon, Header)
    if WindowIcon then
        WindowIcon.Position = UDim2.new(0, 10, 0.5, -8)
        WindowIcon.ImageColor3 = Colors.Accent
        table.insert(Window.AccentElements, {Type = "Icon", Element = WindowIcon})
    end

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Position = UDim2.new(0, WindowIcon and 32 or 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = windowName
    Title.TextColor3 = Colors.Text
    Title.Font = CurrentFont
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Control Buttons Container
    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Size = UDim2.new(0, 60, 1, -6)
    ControlsContainer.Position = UDim2.new(1, -63, 0, 3)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = Header

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.Padding = UDim.new(0, 4)
    ControlsLayout.Parent = ControlsContainer

    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
    MinimizeButton.BackgroundColor3 = Colors.Secondary
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = ""
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.Parent = ControlsContainer

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 4)
    MinimizeCorner.Parent = MinimizeButton

    local MinimizeStroke = Instance.new("UIStroke")
    MinimizeStroke.Color = Colors.Border
    MinimizeStroke.Thickness = 1
    MinimizeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MinimizeStroke.Parent = MinimizeButton

    local MinimizeIcon = CreateIcon("minimize-2", MinimizeButton)
    if MinimizeIcon then
        MinimizeIcon.Size = UDim2.new(0, 14, 0, 14)
        MinimizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        MinimizeIcon.ImageColor3 = Colors.Text
    end

    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Colors.ElementHover}, 0.15)
    end)

    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Colors.Secondary}, 0.15)
    end)

    -- Resize Handle (declare before minimize click handler)
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.Parent = MainFrame

    local ResizeIcon = CreateIcon("grip-horizontal", ResizeHandle)
    if ResizeIcon then
        ResizeIcon.Size = UDim2.new(0, 14, 0, 14)
        ResizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        ResizeIcon.ImageColor3 = Colors.TextMuted
        ResizeIcon.Rotation = 45
    end

    ResizeHandle.MouseEnter:Connect(function()
        if ResizeIcon and not Window.Minimized then
            ResizeIcon.ImageColor3 = Colors.Accent
        end
    end)

    ResizeHandle.MouseLeave:Connect(function()
        if ResizeIcon then
            ResizeIcon.ImageColor3 = Colors.TextMuted
        end
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        
        if Window.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 35)}, 0.3)
            ResizeHandle.Visible = false
            if MinimizeIcon then
                MinimizeIcon:Destroy()
            end
            MinimizeIcon = CreateIcon("maximize-2", MinimizeButton)
            if MinimizeIcon then
                MinimizeIcon.Size = UDim2.new(0, 14, 0, 14)
                MinimizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
                MinimizeIcon.ImageColor3 = Colors.Text
            end
        else
            Tween(MainFrame, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 420)}, 0.3)
            ResizeHandle.Visible = true
            if MinimizeIcon then
                MinimizeIcon:Destroy()
            end
            MinimizeIcon = CreateIcon("minimize-2", MinimizeButton)
            if MinimizeIcon then
                MinimizeIcon.Size = UDim2.new(0, 14, 0, 14)
                MinimizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
                MinimizeIcon.ImageColor3 = Colors.Text
            end
        end
    end)

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 28, 0, 28)
    CloseButton.BackgroundColor3 = Colors.Secondary
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = ControlsContainer

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = Colors.Border
    CloseStroke.Thickness = 1
    CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CloseStroke.Parent = CloseButton

    local CloseIcon = CreateIcon("x", CloseButton)
    if CloseIcon then
        CloseIcon.Size = UDim2.new(0, 14, 0, 14)
        CloseIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        CloseIcon.ImageColor3 = Colors.Text
    end

    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Colors.Danger}, 0.15)
        if CloseIcon then
            CloseIcon.ImageColor3 = Colors.Text
        end
    end)

    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Colors.Secondary}, 0.15)
        if CloseIcon then
            CloseIcon.ImageColor3 = Colors.Text
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 42)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = Colors.BackgroundDark
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    local TabBorder = Instance.new("Frame")
    TabBorder.Size = UDim2.new(1, 0, 0, 1)
    TabBorder.Position = UDim2.new(0, 0, 1, 0)
    TabBorder.BackgroundColor3 = Colors.Border
    TabBorder.BorderSizePixel = 0
    TabBorder.Parent = TabContainer

    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, -16, 1, -8)
    TabList.Position = UDim2.new(0, 8, 0, 4)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabList.ScrollingDirection = Enum.ScrollingDirection.X
    TabList.Parent = TabContainer

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabList

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -77)
    ContentContainer.Position = UDim2.new(0, 0, 0, 77)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    MakeDraggable(MainFrame, Header)
    MakeResizable(MainFrame, ResizeHandle, Window)

    function Window:UpdateFont(font)
        Window.Font = font
        Title.Font = font
        
        for _, tab in pairs(Window.Tabs) do
            if tab.Label then
                tab.Label.Font = font
            end
            
            for _, element in pairs(tab.Content:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") then
                    element.Font = font
                end
            end
        end
    end

    function Window:UpdateFontSize(size)
        Window.FontSize = size
        
        for _, tab in pairs(Window.Tabs) do
            for _, element in pairs(tab.Content:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") then
                    if element.Name == "SectionLabel" then
                        element.TextSize = size + 2
                    elseif element.Parent and element.Parent.Name == "Header" then
                        element.TextSize = size + 1
                    else
                        element.TextSize = size
                    end
                end
            end
        end
    end

    function Window:UpdateAccent(color)
        Window.Accent = color
        Colors.Accent = color
        Colors.AccentHover = Color3.new(
            math.min(1, color.R * 1.2),
            math.min(1, color.G * 1.2),
            math.min(1, color.B * 1.2)
        )
        Colors.AccentDark = Color3.new(
            color.R * 0.8,
            color.G * 0.8,
            color.B * 0.8
        )
        Colors.Toggle = color
        
        for _, data in pairs(Window.AccentElements) do
            if data.Type == "Icon" then
                data.Element.ImageColor3 = color
            elseif data.Type == "Background" then
                data.Element.BackgroundColor3 = color
            elseif data.Type == "Stroke" then
                data.Element.Color = Colors.AccentHover
            elseif data.Type == "Text" then
                data.Element.TextColor3 = color
            elseif data.Type == "ScrollBar" then
                data.Element.ScrollBarImageColor3 = color
            end
        end
    end

    function Window:CreateTab(tabName, iconName)
        local Tab = {}
        Tab.Name = tabName

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Size = UDim2.new(0, 120, 1, 0)
        TabButton.BackgroundColor3 = Colors.ElementBg
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabList

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 5)
        TabCorner.Parent = TabButton

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Colors.Border
        TabStroke.Thickness = 1
        TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabStroke.Parent = TabButton

        if iconName then
            local TabIcon = CreateIcon(iconName, TabButton)
            if TabIcon then
                TabIcon.Size = UDim2.new(0, 16, 0, 16)
                TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
                TabIcon.ImageColor3 = Colors.TextMuted
                Tab.Icon = TabIcon
            end
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, iconName and -32 or -16, 1, 0)
        TabLabel.Position = UDim2.new(0, iconName and 28 or 8, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName:upper()
        TabLabel.TextColor3 = Colors.TextMuted
        TabLabel.Font = Window.Font
        TabLabel.TextSize = 11
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 5
        TabContent.ScrollBarImageColor3 = Colors.Accent
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        table.insert(Window.AccentElements, {Type = "ScrollBar", Element = TabContent})

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = TabContent

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Colors.ElementHover}, 0.15)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Colors.ElementBg}, 0.15)
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Colors.ElementBg
                tab.Label.TextColor3 = Colors.TextMuted
                tab.Stroke.Color = Colors.Border
                tab.Content.Visible = false
                if tab.Icon then
                    tab.Icon.ImageColor3 = Colors.TextMuted
                end
            end

            TabButton.BackgroundColor3 = Colors.Accent
            TabLabel.TextColor3 = Colors.Text
            TabStroke.Color = Colors.AccentHover
            TabContent.Visible = true
            Window.CurrentTab = Tab
            if Tab.Icon then
                Tab.Icon.ImageColor3 = Colors.Text
            end
            
            for i = #Window.AccentElements, 1, -1 do
                local data = Window.AccentElements[i]
                if data.Type == "TabBackground" or data.Type == "TabStroke" then
                    table.remove(Window.AccentElements, i)
                end
            end
            table.insert(Window.AccentElements, {Type = "TabBackground", Element = TabButton})
            table.insert(Window.AccentElements, {Type = "TabStroke", Element = TabStroke})
        end)

        Tab.Button = TabButton
        Tab.Label = TabLabel
        Tab.Stroke = TabStroke
        Tab.Content = TabContent

        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = Colors.Accent
            TabLabel.TextColor3 = Colors.Text
            TabStroke.Color = Colors.AccentHover
            TabContent.Visible = true
            Window.CurrentTab = Tab
            if Tab.Icon then
                Tab.Icon.ImageColor3 = Colors.Text
            end
            
            table.insert(Window.AccentElements, {Type = "TabBackground", Element = TabButton})
            table.insert(Window.AccentElements, {Type = "TabStroke", Element = TabStroke})
        end

        table.insert(Window.Tabs, Tab)

        function Tab:CreateSection(sectionName)
            local Section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName
            SectionFrame.Size = UDim2.new(1, 0, 0, 35)
            SectionFrame.BackgroundColor3 = Colors.BackgroundDark
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabContent

            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Colors.Border
            SectionStroke.Thickness = 1
            SectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            SectionStroke.Parent = SectionFrame

            local SectionHeader = Instance.new("Frame")
            SectionHeader.Size = UDim2.new(1, 0, 0, 30)
            SectionHeader.BackgroundColor3 = Colors.BackgroundDarker
            SectionHeader.BorderSizePixel = 0
            SectionHeader.Parent = SectionFrame

            local SectionHeaderCorner = Instance.new("UICorner")
            SectionHeaderCorner.CornerRadius = UDim.new(0, 6)
            SectionHeaderCorner.Parent = SectionHeader

            local HeaderCover = Instance.new("Frame")
            HeaderCover.Size = UDim2.new(1, 0, 0, 6)
            HeaderCover.Position = UDim2.new(0, 0, 1, -6)
            HeaderCover.BackgroundColor3 = Colors.BackgroundDarker
            HeaderCover.BorderSizePixel = 0
            HeaderCover.Parent = SectionHeader

            local HeaderBorder = Instance.new("Frame")
            HeaderBorder.Size = UDim2.new(1, 0, 0, 1)
            HeaderBorder.Position = UDim2.new(0, 0, 1, 0)
            HeaderBorder.BackgroundColor3 = Colors.Border
            HeaderBorder.BorderSizePixel = 0
            HeaderBorder.Parent = SectionHeader

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -20, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = sectionName
            SectionLabel.TextColor3 = Colors.Text
            SectionLabel.Font = Window.Font
            SectionLabel.TextSize = Window.FontSize + 2
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionHeader

            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 1, -30)
            SectionContent.Position = UDim2.new(0, 0, 0, 30)
            SectionContent.BackgroundTransparency = 1
            SectionContent.Parent = SectionFrame

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 5)
            SectionLayout.Parent = SectionContent

            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 10)
            SectionPadding.PaddingRight = UDim.new(0, 10)
            SectionPadding.PaddingTop = UDim.new(0, 8)
            SectionPadding.PaddingBottom = UDim.new(0, 8)
            SectionPadding.Parent = SectionContent

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 46)
            end)

            function Section:CreateCheckbox(options)
                options = options or {}
                local name = options.Name or "Checkbox"
                local default = options.Default or false
                local callback = options.Callback or function() end

                local Checkbox = {}
                Checkbox.Value = default

                local CheckboxFrame = Instance.new("Frame")
                CheckboxFrame.Size = UDim2.new(1, 0, 0, 22)
                CheckboxFrame.BackgroundColor3 = Colors.ElementBg
                CheckboxFrame.BorderSizePixel = 0
                CheckboxFrame.Parent = SectionContent

                local CheckboxCorner = Instance.new("UICorner")
                CheckboxCorner.CornerRadius = UDim.new(0, 4)
                CheckboxCorner.Parent = CheckboxFrame

                local CheckboxStroke = Instance.new("UIStroke")
                CheckboxStroke.Color = Colors.Border
                CheckboxStroke.Thickness = 1
                CheckboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                CheckboxStroke.Parent = CheckboxFrame

                local CheckboxButton = Instance.new("TextButton")
                CheckboxButton.Size = UDim2.new(1, 0, 1, 0)
                CheckboxButton.BackgroundTransparency = 1
                CheckboxButton.Text = ""
                CheckboxButton.Parent = CheckboxFrame

                local CheckboxLabel = Instance.new("TextLabel")
                CheckboxLabel.Size = UDim2.new(1, -30, 1, 0)
                CheckboxLabel.Position = UDim2.new(0, 8, 0, 0)
                CheckboxLabel.BackgroundTransparency = 1
                CheckboxLabel.Text = name
                CheckboxLabel.TextColor3 = Colors.Text
                CheckboxLabel.Font = Window.Font
                CheckboxLabel.TextSize = Window.FontSize
                CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                CheckboxLabel.Parent = CheckboxFrame

                local CheckboxBox = Instance.new("Frame")
                CheckboxBox.Size = UDim2.new(0, 16, 0, 16)
                CheckboxBox.Position = UDim2.new(1, -20, 0.5, -8)
                CheckboxBox.BackgroundColor3 = Colors.BackgroundDarker
                CheckboxBox.BorderSizePixel = 0
                CheckboxBox.Parent = CheckboxFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = CheckboxBox

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Colors.Border
                BoxStroke.Thickness = 1
                BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BoxStroke.Parent = CheckboxBox

                local CheckIcon = CreateIcon("check", CheckboxBox)
                if CheckIcon then
                    CheckIcon.Size = UDim2.new(0, 12, 0, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.ImageColor3 = Colors.Text
                    CheckIcon.Visible = default
                end

                if default then
                    CheckboxBox.BackgroundColor3 = Colors.Toggle
                    BoxStroke.Color = Colors.Toggle
                    table.insert(Window.AccentElements, {Type = "Background", Element = CheckboxBox})
                    table.insert(Window.AccentElements, {Type = "Stroke", Element = BoxStroke})
                end

                CheckboxButton.MouseEnter:Connect(function()
                    Tween(CheckboxFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                end)

                CheckboxButton.MouseLeave:Connect(function()
                    Tween(CheckboxFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                end)

                CheckboxButton.MouseButton1Click:Connect(function()
                    Checkbox.Value = not Checkbox.Value
                    
                    if Checkbox.Value then
                        CheckboxBox.BackgroundColor3 = Colors.Toggle
                        BoxStroke.Color = Colors.Toggle
                        if CheckIcon then CheckIcon.Visible = true end
                        table.insert(Window.AccentElements, {Type = "Background", Element = CheckboxBox})
                        table.insert(Window.AccentElements, {Type = "Stroke", Element = BoxStroke})
                    else
                        CheckboxBox.BackgroundColor3 = Colors.BackgroundDarker
                        BoxStroke.Color = Colors.Border
                        if CheckIcon then CheckIcon.Visible = false end
                        for i = #Window.AccentElements, 1, -1 do
                            local data = Window.AccentElements[i]
                            if data.Element == CheckboxBox or data.Element == BoxStroke then
                                table.remove(Window.AccentElements, i)
                            end
                        end
                    end
                    
                    callback(Checkbox.Value)
                end)

                function Checkbox:Set(value)
                    Checkbox.Value = value
                    if value then
                        CheckboxBox.BackgroundColor3 = Colors.Toggle
                        BoxStroke.Color = Colors.Toggle
                        if CheckIcon then CheckIcon.Visible = true end
                        table.insert(Window.AccentElements, {Type = "Background", Element = CheckboxBox})
                        table.insert(Window.AccentElements, {Type = "Stroke", Element = BoxStroke})
                    else
                        CheckboxBox.BackgroundColor3 = Colors.BackgroundDarker
                        BoxStroke.Color = Colors.Border
                        if CheckIcon then CheckIcon.Visible = false end
                        for i = #Window.AccentElements, 1, -1 do
                            local data = Window.AccentElements[i]
                            if data.Element == CheckboxBox or data.Element == BoxStroke then
                                table.remove(Window.AccentElements, i)
                            end
                        end
                    end
                    callback(value)
                end

                return Checkbox
            end

            function Section:CreateButton(options)
                options = options or {}
                local name = options.Name or "Button"
                local iconName = options.Icon
                local callback = options.Callback or function() end

                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Size = UDim2.new(1, 0, 0, 26)
                ButtonFrame.BackgroundColor3 = Colors.Accent
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Parent = SectionContent

                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 5)
                ButtonCorner.Parent = ButtonFrame

                local ButtonStroke = Instance.new("UIStroke")
                ButtonStroke.Color = Colors.AccentHover
                ButtonStroke.Thickness = 1
                ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ButtonStroke.Parent = ButtonFrame
                
                table.insert(Window.AccentElements, {Type = "Background", Element = ButtonFrame})
                table.insert(Window.AccentElements, {Type = "Stroke", Element = ButtonStroke})

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundTransparency = 1
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.Parent = ButtonFrame

                if iconName then
                    local ButtonIcon = CreateIcon(iconName, Button)
                    if ButtonIcon then
                        ButtonIcon.Size = UDim2.new(0, 14, 0, 14)
                        ButtonIcon.Position = UDim2.new(0, 8, 0.5, -7)
                        ButtonIcon.ImageColor3 = Colors.Text
                    end
                end

                local ButtonLabel = Instance.new("TextLabel")
                ButtonLabel.Size = UDim2.new(1, iconName and -32 or -16, 1, 0)
                ButtonLabel.Position = UDim2.new(0, iconName and 26 or 8, 0, 0)
                ButtonLabel.BackgroundTransparency = 1
                ButtonLabel.Text = name
                ButtonLabel.TextColor3 = Colors.Text
                ButtonLabel.Font = Window.Font
                ButtonLabel.TextSize = Window.FontSize
                ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
                ButtonLabel.Parent = Button

                Button.MouseButton1Click:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.AccentHover}, 0.1)
                    task.wait(0.1)
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.Accent}, 0.1)
                    callback()
                end)

                Button.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.AccentHover}, 0.1)
                end)

                Button.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.Accent}, 0.1)
                end)

                return Button
            end

            function Section:CreateSlider(options)
                options = options or {}
                local name = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local suffix = options.Suffix or "%"
                local callback = options.Callback or function() end

                local Slider = {}
                Slider.Value = default

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 36)
                SliderFrame.BackgroundColor3 = Colors.ElementBg
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = SectionContent

                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 4)
                SliderCorner.Parent = SliderFrame

                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = Colors.Border
                SliderStroke.Thickness = 1
                SliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                SliderStroke.Parent = SliderFrame

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(0.6, 0, 0, 16)
                SliderLabel.Position = UDim2.new(0, 8, 0, 5)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Colors.Text
                SliderLabel.Font = Window.Font
                SliderLabel.TextSize = Window.FontSize
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local SliderValue = Instance.new("TextLabel")
                SliderValue.Size = UDim2.new(0.4, -8, 0, 16)
                SliderValue.Position = UDim2.new(0.6, 0, 0, 5)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(default) .. suffix
                SliderValue.TextColor3 = Colors.Accent
                SliderValue.Font = Window.Font
                SliderValue.TextSize = Window.FontSize
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                table.insert(Window.AccentElements, {Type = "Text", Element = SliderValue})

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -16, 0, 6)
                SliderBar.Position = UDim2.new(0, 8, 1, -12)
                SliderBar.BackgroundColor3 = Colors.BackgroundDarker
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SliderBar

                local BarStroke = Instance.new("UIStroke")
                BarStroke.Color = Colors.Border
                BarStroke.Thickness = 1
                BarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BarStroke.Parent = SliderBar

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Colors.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar
                
                table.insert(Window.AccentElements, {Type = "Background", Element = SliderFill})

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill

                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(1, 0, 1, 10)
                SliderButton.Position = UDim2.new(0, 0, 0, -5)
                SliderButton.BackgroundTransparency = 1
                SliderButton.Text = ""
                SliderButton.Parent = SliderBar

                local dragging = false

                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                local function updateSlider()
                    local mouse = UserInputService:GetMouseLocation()
                    local percent = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor((min + (max - min) * percent) / increment + 0.5) * increment
                    Slider:Set(value)
                end

                SliderButton.MouseButton1Click:Connect(updateSlider)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider()
                    end
                end)

                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                end)

                SliderFrame.MouseLeave:Connect(function()
                    if not dragging then
                        Tween(SliderFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                    end
                end)

                function Slider:Set(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    SliderValue.Text = tostring(value) .. suffix
                    Tween(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.1)
                    callback(value)
                end

                return Slider
            end

            function Section:CreateDropdown(options)
                options = options or {}
                local name = options.Name or "Dropdown"
                local items = options.Items or {}
                local default = options.Default or (items[1] or "None")
                local callback = options.Callback or function() end

                local Dropdown = {}
                Dropdown.Value = default
                Dropdown.Items = items
                Dropdown.Open = false

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 24)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.ZIndex = 5
                DropdownFrame.Parent = SectionContent

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, 24)
                DropdownButton.BackgroundColor3 = Colors.ElementBg
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = ""
                DropdownButton.AutoButtonColor = false
                DropdownButton.ZIndex = 6
                DropdownButton.Parent = DropdownFrame

                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 4)
                DropdownCorner.Parent = DropdownButton

                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = Colors.Border
                DropdownStroke.Thickness = 1
                DropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                DropdownStroke.Parent = DropdownButton

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(1, -55, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 8, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Colors.TextDark
                DropdownLabel.Font = Window.Font
                DropdownLabel.TextSize = Window.FontSize - 1
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.ZIndex = 6
                DropdownLabel.Parent = DropdownButton

                local DropdownValue = Instance.new("TextLabel")
                DropdownValue.Size = UDim2.new(0, 80, 1, 0)
                DropdownValue.Position = UDim2.new(1, -100, 0, 0)
                DropdownValue.BackgroundTransparency = 1
                DropdownValue.Text = default
                DropdownValue.TextColor3 = Colors.Accent
                DropdownValue.Font = Window.Font
                DropdownValue.TextSize = Window.FontSize - 1
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
                DropdownValue.ZIndex = 6
                DropdownValue.Parent = DropdownButton
                
                table.insert(Window.AccentElements, {Type = "Text", Element = DropdownValue})

                local DropdownArrow = CreateIcon("chevron-down", DropdownButton)
                if DropdownArrow then
                    DropdownArrow.Size = UDim2.new(0, 14, 0, 14)
                    DropdownArrow.Position = UDim2.new(1, -18, 0.5, -7)
                    DropdownArrow.ImageColor3 = Colors.TextDark
                    DropdownArrow.ZIndex = 6
                end

                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Position = UDim2.new(0, 0, 0, 26)
                DropdownList.BackgroundColor3 = Colors.BackgroundDarker
                DropdownList.BorderSizePixel = 0
                DropdownList.Visible = false
                DropdownList.ZIndex = 10
                DropdownList.Parent = DropdownFrame

                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 4)
                ListCorner.Parent = DropdownList

                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Colors.Accent
                ListStroke.Thickness = 1
                ListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ListStroke.Parent = DropdownList

                local ListContainer = Instance.new("ScrollingFrame")
                ListContainer.Size = UDim2.new(1, 0, 1, 0)
                ListContainer.BackgroundTransparency = 1
                ListContainer.BorderSizePixel = 0
                ListContainer.ScrollBarThickness = 4
                ListContainer.ScrollBarImageColor3 = Colors.Accent
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
                ListContainer.ZIndex = 10
                ListContainer.Parent = DropdownList
                
                table.insert(Window.AccentElements, {Type = "ScrollBar", Element = ListContainer})

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = ListContainer

                local ListPadding = Instance.new("UIPadding")
                ListPadding.PaddingLeft = UDim.new(0, 4)
                ListPadding.PaddingRight = UDim.new(0, 4)
                ListPadding.PaddingTop = UDim.new(0, 4)
                ListPadding.PaddingBottom = UDim.new(0, 4)
                ListPadding.Parent = ListContainer

                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
                end)

                DropdownButton.MouseEnter:Connect(function()
                    if not Dropdown.Open then
                        Tween(DropdownButton, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                    end
                end)

                DropdownButton.MouseLeave:Connect(function()
                    if not Dropdown.Open then
                        Tween(DropdownButton, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                    end
                end)

                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownList.Visible = true
                        local height = math.min(#items * 22 + 8, 110)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 24 + height + 2)}, 0.15)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, height)}, 0.15)
                        if DropdownArrow then
                            Tween(DropdownArrow, {Rotation = 180}, 0.15)
                        end
                        DropdownStroke.Color = Colors.Accent
                        DropdownButton.BackgroundColor3 = Colors.ElementHover
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 24)}, 0.15)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        if DropdownArrow then
                            Tween(DropdownArrow, {Rotation = 0}, 0.15)
                        end
                        DropdownStroke.Color = Colors.Border
                        DropdownButton.BackgroundColor3 = Colors.ElementBg
                        task.wait(0.15)
                        DropdownList.Visible = false
                    end
                end)

                function Dropdown:Refresh(newItems)
                    for _, child in pairs(ListContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    Dropdown.Items = newItems or items

                    for _, item in pairs(Dropdown.Items) do
                        local ItemButton = Instance.new("TextButton")
                        ItemButton.Size = UDim2.new(1, 0, 0, 20)
                        ItemButton.BackgroundColor3 = Colors.ElementBg
                        ItemButton.BorderSizePixel = 0
                        ItemButton.Text = item
                        ItemButton.TextColor3 = Colors.Text
                        ItemButton.Font = Window.Font
                        ItemButton.TextSize = Window.FontSize - 1
                        ItemButton.AutoButtonColor = false
                        ItemButton.ZIndex = 10
                        ItemButton.Parent = ListContainer

                        local ItemCorner = Instance.new("UICorner")
                        ItemCorner.CornerRadius = UDim.new(0, 3)
                        ItemCorner.Parent = ItemButton

                        ItemButton.MouseButton1Click:Connect(function()
                            Dropdown.Value = item
                            DropdownValue.Text = item
                            Dropdown.Open = false
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 24)}, 0.15)
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                            if DropdownArrow then
                                Tween(DropdownArrow, {Rotation = 0}, 0.15)
                            end
                            DropdownStroke.Color = Colors.Border
                            DropdownButton.BackgroundColor3 = Colors.ElementBg
                            task.wait(0.15)
                            DropdownList.Visible = false
                            callback(item)
                        end)

                        ItemButton.MouseEnter:Connect(function()
                            Tween(ItemButton, {BackgroundColor3 = Colors.Accent}, 0.1)
                        end)

                        ItemButton.MouseLeave:Connect(function()
                            Tween(ItemButton, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                        end)
                    end
                end

                Dropdown:Refresh()
                return Dropdown
            end

            function Section:CreateColorpicker(options)
                options = options or {}
                local name = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(255, 255, 255)
                local callback = options.Callback or function() end

                local Colorpicker = {}
                Colorpicker.Value = default

                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, 0, 0, 22)
                ColorFrame.BackgroundColor3 = Colors.ElementBg
                ColorFrame.BorderSizePixel = 0
                ColorFrame.Parent = SectionContent

                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(0, 4)
                ColorCorner.Parent = ColorFrame

                local ColorStroke = Instance.new("UIStroke")
                ColorStroke.Color = Colors.Border
                ColorStroke.Thickness = 1
                ColorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ColorStroke.Parent = ColorFrame

                local ColorLabel = Instance.new("TextLabel")
                ColorLabel.Size = UDim2.new(1, -45, 1, 0)
                ColorLabel.Position = UDim2.new(0, 8, 0, 0)
                ColorLabel.BackgroundTransparency = 1
                ColorLabel.Text = name
                ColorLabel.TextColor3 = Colors.Text
                ColorLabel.Font = Window.Font
                ColorLabel.TextSize = Window.FontSize
                ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColorLabel.Parent = ColorFrame

                local ColorDisplayBg = Instance.new("Frame")
                ColorDisplayBg.Size = UDim2.new(0, 20, 0, 14)
                ColorDisplayBg.Position = UDim2.new(1, -28, 0.5, -7)
                ColorDisplayBg.BackgroundColor3 = Colors.BackgroundDarker
                ColorDisplayBg.BorderSizePixel = 0
                ColorDisplayBg.Parent = ColorFrame

                local DisplayCorner = Instance.new("UICorner")
                DisplayCorner.CornerRadius = UDim.new(0, 3)
                DisplayCorner.Parent = ColorDisplayBg

                local ColorDisplay = Instance.new("Frame")
                ColorDisplay.Size = UDim2.new(1, -4, 1, -4)
                ColorDisplay.Position = UDim2.new(0, 2, 0, 2)
                ColorDisplay.BackgroundColor3 = default
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.Parent = ColorDisplayBg

                local DisplayInnerCorner = Instance.new("UICorner")
                DisplayInnerCorner.CornerRadius = UDim.new(0, 2)
                DisplayInnerCorner.Parent = ColorDisplay

                local DisplayStroke = Instance.new("UIStroke")
                DisplayStroke.Color = Colors.Border
                DisplayStroke.Thickness = 1
                DisplayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                DisplayStroke.Parent = ColorDisplayBg

                local ColorButton = Instance.new("TextButton")
                ColorButton.Size = UDim2.new(1, 0, 1, 0)
                ColorButton.BackgroundTransparency = 1
                ColorButton.Text = ""
                ColorButton.Parent = ColorFrame

                ColorButton.MouseEnter:Connect(function()
                    Tween(ColorFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                end)

                ColorButton.MouseLeave:Connect(function()
                    Tween(ColorFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                end)

                -- Color Picker Window (positioned next to main window)
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Size = UDim2.new(0, 230, 0, 270)
                PickerFrame.BackgroundColor3 = Colors.Background
                PickerFrame.BorderSizePixel = 0
                PickerFrame.Visible = false
                PickerFrame.ZIndex = 100
                PickerFrame.Parent = ScreenGui

                -- Position next to main window
                local function updatePickerPosition()
                    local mainX = Window.MainFrame.AbsolutePosition.X
                    local mainY = Window.MainFrame.AbsolutePosition.Y
                    local mainWidth = Window.MainFrame.AbsoluteSize.X
                    
                    PickerFrame.Position = UDim2.new(0, mainX + mainWidth + 10, 0, mainY)
                end

                local PickerCorner = Instance.new("UICorner")
                PickerCorner.CornerRadius = UDim.new(0, 8)
                PickerCorner.Parent = PickerFrame

                local PickerStroke = Instance.new("UIStroke")
                PickerStroke.Color = Colors.Accent
                PickerStroke.Thickness = 2
                PickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                PickerStroke.Parent = PickerFrame

                local PickerHeader = Instance.new("Frame")
                PickerHeader.Size = UDim2.new(1, 0, 0, 30)
                PickerHeader.BackgroundColor3 = Colors.Header
                PickerHeader.BorderSizePixel = 0
                PickerHeader.ZIndex = 100
                PickerHeader.Parent = PickerFrame

                local PickerHeaderCorner = Instance.new("UICorner")
                PickerHeaderCorner.CornerRadius = UDim.new(0, 8)
                PickerHeaderCorner.Parent = PickerHeader

                local PickerHeaderCover = Instance.new("Frame")
                PickerHeaderCover.Size = UDim2.new(1, 0, 0, 8)
                PickerHeaderCover.Position = UDim2.new(0, 0, 1, -8)
                PickerHeaderCover.BackgroundColor3 = Colors.Header
                PickerHeaderCover.BorderSizePixel = 0
                PickerHeaderCover.ZIndex = 100
                PickerHeaderCover.Parent = PickerHeader

                local PickerTitle = Instance.new("TextLabel")
                PickerTitle.Size = UDim2.new(1, -20, 1, 0)
                PickerTitle.Position = UDim2.new(0, 10, 0, 0)
                PickerTitle.BackgroundTransparency = 1
                PickerTitle.Text = "COLOR PICKER"
                PickerTitle.TextColor3 = Colors.Accent
                PickerTitle.Font = Window.Font
                PickerTitle.TextSize = Window.FontSize + 1
                PickerTitle.TextXAlignment = Enum.TextXAlignment.Left
                PickerTitle.ZIndex = 100
                PickerTitle.Parent = PickerHeader

                -- Palette Canvas
                local PaletteFrame = Instance.new("Frame")
                PaletteFrame.Size = UDim2.new(1, -20, 0, 160)
                PaletteFrame.Position = UDim2.new(0, 10, 0, 40)
                PaletteFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                PaletteFrame.BorderSizePixel = 0
                PaletteFrame.ZIndex = 100
                PaletteFrame.Parent = PickerFrame

                local PaletteCorner = Instance.new("UICorner")
                PaletteCorner.CornerRadius = UDim.new(0, 6)
                PaletteCorner.Parent = PaletteFrame

                local PaletteStroke = Instance.new("UIStroke")
                PaletteStroke.Color = Colors.Border
                PaletteStroke.Thickness = 1
                PaletteStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                PaletteStroke.Parent = PaletteFrame

                local SaturationOverlay = Instance.new("Frame")
                SaturationOverlay.Size = UDim2.new(1, 0, 1, 0)
                SaturationOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SaturationOverlay.BorderSizePixel = 0
                SaturationOverlay.ZIndex = 101
                SaturationOverlay.Parent = PaletteFrame

                local SaturationGradient = Instance.new("UIGradient")
                SaturationGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                SaturationGradient.Rotation = 0
                SaturationGradient.Parent = SaturationOverlay

                local SaturationCorner = Instance.new("UICorner")
                SaturationCorner.CornerRadius = UDim.new(0, 6)
                SaturationCorner.Parent = SaturationOverlay

                local BrightnessOverlay = Instance.new("Frame")
                BrightnessOverlay.Size = UDim2.new(1, 0, 1, 0)
                BrightnessOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                BrightnessOverlay.BorderSizePixel = 0
                BrightnessOverlay.ZIndex = 102
                BrightnessOverlay.Parent = PaletteFrame

                local BrightnessGradient = Instance.new("UIGradient")
                BrightnessGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                BrightnessGradient.Rotation = 90
                BrightnessGradient.Parent = BrightnessOverlay

                local BrightnessCorner = Instance.new("UICorner")
                BrightnessCorner.CornerRadius = UDim.new(0, 6)
                BrightnessCorner.Parent = BrightnessOverlay

                local Selector = Instance.new("Frame")
                Selector.Size = UDim2.new(0, 10, 0, 10)
                Selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Selector.BorderSizePixel = 0
                Selector.ZIndex = 103
                Selector.Parent = PaletteFrame

                local SelectorCorner = Instance.new("UICorner")
                SelectorCorner.CornerRadius = UDim.new(1, 0)
                SelectorCorner.Parent = Selector

                local SelectorStroke = Instance.new("UIStroke")
                SelectorStroke.Color = Color3.fromRGB(0, 0, 0)
                SelectorStroke.Thickness = 2
                SelectorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                SelectorStroke.Parent = Selector

                local HueSlider = Instance.new("Frame")
                HueSlider.Size = UDim2.new(1, -20, 0, 18)
                HueSlider.Position = UDim2.new(0, 10, 0, 208)
                HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSlider.BorderSizePixel = 0
                HueSlider.ZIndex = 100
                HueSlider.Parent = PickerFrame

                local HueCorner = Instance.new("UICorner")
                HueCorner.CornerRadius = UDim.new(0, 6)
                HueCorner.Parent = HueSlider

                local HueStroke = Instance.new("UIStroke")
                HueStroke.Color = Colors.Border
                HueStroke.Thickness = 1
                HueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                HueStroke.Parent = HueSlider

                local HueGradient = Instance.new("UIGradient")
                HueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                HueGradient.Parent = HueSlider

                local HueSelector = Instance.new("Frame")
                HueSelector.Size = UDim2.new(0, 6, 1, 6)
                HueSelector.Position = UDim2.new(0, -3, 0, -3)
                HueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSelector.BorderSizePixel = 0
                HueSelector.ZIndex = 101
                HueSelector.Parent = HueSlider

                local HueSelectorCorner = Instance.new("UICorner")
                HueSelectorCorner.CornerRadius = UDim.new(1, 0)
                HueSelectorCorner.Parent = HueSelector

                local HueSelectorStroke = Instance.new("UIStroke")
                HueSelectorStroke.Color = Color3.fromRGB(0, 0, 0)
                HueSelectorStroke.Thickness = 1
                HueSelectorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                HueSelectorStroke.Parent = HueSelector

                local HueButton = Instance.new("TextButton")
                HueButton.Size = UDim2.new(1, 0, 1, 0)
                HueButton.BackgroundTransparency = 1
                HueButton.Text = ""
                HueButton.ZIndex = 102
                HueButton.Parent = HueSlider

                local h, s, v = default:ToHSV()
                
                local function updateColor()
                    local color = Color3.fromHSV(h, s, v)
                    Colorpicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    callback(color)
                end

                local function updatePalette()
                    PaletteFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                end

                HueSelector.Position = UDim2.new(h, -3, 0, -3)
                Selector.Position = UDim2.new(s, -5, 1 - v, -5)
                updatePalette()

                local paletteSelecting = false
                PaletteFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        paletteSelecting = true
                        local pos = input.Position
                        local relX = math.clamp((pos.X - PaletteFrame.AbsolutePosition.X) / PaletteFrame.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((pos.Y - PaletteFrame.AbsolutePosition.Y) / PaletteFrame.AbsoluteSize.Y, 0, 1)
                        s = relX
                        v = 1 - relY
                        Selector.Position = UDim2.new(relX, -5, relY, -5)
                        updateColor()
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if paletteSelecting and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = input.Position
                        local relX = math.clamp((pos.X - PaletteFrame.AbsolutePosition.X) / PaletteFrame.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((pos.Y - PaletteFrame.AbsolutePosition.Y) / PaletteFrame.AbsoluteSize.Y, 0, 1)
                        s = relX
                        v = 1 - relY
                        Selector.Position = UDim2.new(relX, -5, relY, -5)
                        updateColor()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        paletteSelecting = false
                    end
                end)

                local hueSelecting = false
                HueButton.MouseButton1Down:Connect(function()
                    hueSelecting = true
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueSelecting = false
                    end
                end)

                HueButton.MouseButton1Click:Connect(function()
                    local mouse = UserInputService:GetMouseLocation()
                    local percent = math.clamp((mouse.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    h = percent
                    HueSelector.Position = UDim2.new(percent, -3, 0, -3)
                    updatePalette()
                    updateColor()
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if hueSelecting and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouse = UserInputService:GetMouseLocation()
                        local percent = math.clamp((mouse.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                        h = percent
                        HueSelector.Position = UDim2.new(percent, -3, 0, -3)
                        updatePalette()
                        updateColor()
                    end
                end)

                local ClosePickerButton = Instance.new("TextButton")
                ClosePickerButton.Size = UDim2.new(1, -20, 0, 30)
                ClosePickerButton.Position = UDim2.new(0, 10, 1, -40)
                ClosePickerButton.BackgroundColor3 = Colors.Accent
                ClosePickerButton.BorderSizePixel = 0
                ClosePickerButton.Text = "CLOSE"
                ClosePickerButton.TextColor3 = Colors.Text
                ClosePickerButton.Font = Window.Font
                ClosePickerButton.TextSize = Window.FontSize
                ClosePickerButton.ZIndex = 100
                ClosePickerButton.Parent = PickerFrame

                local ClosePickerCorner = Instance.new("UICorner")
                ClosePickerCorner.CornerRadius = UDim.new(0, 5)
                ClosePickerCorner.Parent = ClosePickerButton

                ClosePickerButton.MouseButton1Click:Connect(function()
                    PickerFrame.Visible = false
                end)

                ClosePickerButton.MouseEnter:Connect(function()
                    Tween(ClosePickerButton, {BackgroundColor3 = Colors.AccentHover}, 0.1)
                end)

                ClosePickerButton.MouseLeave:Connect(function()
                    Tween(ClosePickerButton, {BackgroundColor3 = Colors.Accent}, 0.1)
                end)

                ColorButton.MouseButton1Click:Connect(function()
                    PickerFrame.Visible = not PickerFrame.Visible
                    if PickerFrame.Visible then
                        updatePickerPosition()
                    end
                end)

                MakeDraggable(PickerFrame, PickerHeader)

                function Colorpicker:Set(color)
                    Colorpicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    h, s, v = color:ToHSV()
                    HueSelector.Position = UDim2.new(h, -3, 0, -3)
                    Selector.Position = UDim2.new(s, -5, 1 - v, -5)
                    updatePalette()
                    callback(color)
                end

                return Colorpicker
            end

            function Section:CreateKeybind(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.F
                local callback = options.Callback or function() end

                local Keybind = {}
                Keybind.Value = default

                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Size = UDim2.new(1, 0, 0, 22)
                KeybindFrame.BackgroundColor3 = Colors.ElementBg
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Parent = SectionContent

                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 4)
                KeybindCorner.Parent = KeybindFrame

                local KeybindStroke = Instance.new("UIStroke")
                KeybindStroke.Color = Colors.Border
                KeybindStroke.Thickness = 1
                KeybindStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                KeybindStroke.Parent = KeybindFrame

                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Size = UDim2.new(1, -55, 1, 0)
                KeybindLabel.Position = UDim2.new(0, 8, 0, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Text = name
                KeybindLabel.TextColor3 = Colors.Text
                KeybindLabel.Font = Window.Font
                KeybindLabel.TextSize = Window.FontSize
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.Parent = KeybindFrame

                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Size = UDim2.new(0, 45, 0, 16)
                KeybindButton.Position = UDim2.new(1, -50, 0.5, -8)
                KeybindButton.BackgroundColor3 = Colors.BackgroundDarker
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Text = default.Name
                KeybindButton.TextColor3 = Colors.Accent
                KeybindButton.Font = Window.Font
                KeybindButton.TextSize = Window.FontSize - 2
                KeybindButton.AutoButtonColor = false
                KeybindButton.Parent = KeybindFrame
                
                table.insert(Window.AccentElements, {Type = "Text", Element = KeybindButton})

                local KeyCorner = Instance.new("UICorner")
                KeyCorner.CornerRadius = UDim.new(0, 3)
                KeyCorner.Parent = KeybindButton

                local KeyStroke = Instance.new("UIStroke")
                KeyStroke.Color = Colors.Border
                KeyStroke.Thickness = 1
                KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                KeyStroke.Parent = KeybindButton

                local listening = false

                KeybindFrame.MouseEnter:Connect(function()
                    if not listening then
                        Tween(KeybindFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                    end
                end)

                KeybindFrame.MouseLeave:Connect(function()
                    if not listening then
                        Tween(KeybindFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                    end
                end)

                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                    KeyStroke.Color = Colors.Accent
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            KeyStroke.Color = Colors.Border
                            listening = false
                        end
                    end

                    if not gameProcessed and input.KeyCode == Keybind.Value then
                        callback()
                    end
                end)

                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name
                end

                return Keybind
            end

            function Section:CreateViewport(options)
                options = options or {}
                local name = options.Name or "Preview"
                local height = options.Height or 200

                local Viewport = {
                    Model = nil,
                    ESPSettings = {
                        BoxEnabled = false,
                        BoxColor = Color3.fromRGB(255, 255, 255),
                        NameEnabled = false,
                        NameColor = Color3.fromRGB(255, 255, 255),
                        HealthEnabled = false,
                    }
                }

                local ViewportContainer = Instance.new("Frame")
                ViewportContainer.Size = UDim2.new(1, 0, 0, height + 30)
                ViewportContainer.BackgroundColor3 = Colors.ElementBg
                ViewportContainer.BorderSizePixel = 0
                ViewportContainer.Parent = SectionContent

                local ViewportCorner = Instance.new("UICorner")
                ViewportCorner.CornerRadius = UDim.new(0, 4)
                ViewportCorner.Parent = ViewportContainer

                local ViewportStroke = Instance.new("UIStroke")
                ViewportStroke.Color = Colors.Border
                ViewportStroke.Thickness = 1
                ViewportStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ViewportStroke.Parent = ViewportContainer

                local ViewportLabel = Instance.new("TextLabel")
                ViewportLabel.Size = UDim2.new(1, -10, 0, 25)
                ViewportLabel.Position = UDim2.new(0, 5, 0, 0)
                ViewportLabel.BackgroundTransparency = 1
                ViewportLabel.Text = name
                ViewportLabel.TextColor3 = Colors.Text
                ViewportLabel.Font = Window.Font
                ViewportLabel.TextSize = Window.FontSize
                ViewportLabel.TextXAlignment = Enum.TextXAlignment.Left
                ViewportLabel.Parent = ViewportContainer

                local ViewportFrame = Instance.new("ViewportFrame")
                ViewportFrame.Size = UDim2.new(1, -10, 1, -30)
                ViewportFrame.Position = UDim2.new(0, 5, 0, 25)
                ViewportFrame.BackgroundColor3 = Colors.BackgroundDarker
                ViewportFrame.BorderSizePixel = 0
                ViewportFrame.Parent = ViewportContainer

                local ViewportFrameCorner = Instance.new("UICorner")
                ViewportFrameCorner.CornerRadius = UDim.new(0, 3)
                ViewportFrameCorner.Parent = ViewportFrame

                local ViewportFrameStroke = Instance.new("UIStroke")
                ViewportFrameStroke.Color = Colors.Border
                ViewportFrameStroke.Thickness = 1
                ViewportFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ViewportFrameStroke.Parent = ViewportFrame

                -- ESP Overlay Frame (on top of viewport)
                local ESPOverlay = Instance.new("Frame")
                ESPOverlay.Size = UDim2.new(1, 0, 1, 0)
                ESPOverlay.BackgroundTransparency = 1
                ESPOverlay.Parent = ViewportFrame

                -- Box ESP Frame
                local BoxESP = Instance.new("Frame")
                BoxESP.Size = UDim2.new(0, 80, 0, 140)
                BoxESP.Position = UDim2.new(0.5, -40, 0.5, -70)
                BoxESP.BackgroundTransparency = 1
                BoxESP.Visible = false
                BoxESP.Parent = ESPOverlay

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(255, 255, 255)
                BoxStroke.Thickness = 2
                BoxStroke.Parent = BoxESP

                -- Name ESP Label
                local NameESP = Instance.new("TextLabel")
                NameESP.Size = UDim2.new(0, 100, 0, 16)
                NameESP.Position = UDim2.new(0.5, -50, 0.5, -90)
                NameESP.BackgroundTransparency = 1
                NameESP.Text = "PlayerName"
                NameESP.TextColor3 = Color3.fromRGB(255, 255, 255)
                NameESP.Font = Window.Font
                NameESP.TextSize = 12
                NameESP.TextStrokeTransparency = 0.5
                NameESP.Visible = false
                NameESP.Parent = ESPOverlay

                -- Health Bar Background
                local HealthBarBg = Instance.new("Frame")
                HealthBarBg.Size = UDim2.new(0, 4, 0, 140)
                HealthBarBg.Position = UDim2.new(0.5, -48, 0.5, -70)
                HealthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                HealthBarBg.BorderSizePixel = 0
                HealthBarBg.Visible = false
                HealthBarBg.Parent = ESPOverlay

                local HealthBarBgCorner = Instance.new("UICorner")
                HealthBarBgCorner.CornerRadius = UDim.new(0, 2)
                HealthBarBgCorner.Parent = HealthBarBg

                local HealthBarBgStroke = Instance.new("UIStroke")
                HealthBarBgStroke.Color = Color3.fromRGB(0, 0, 0)
                HealthBarBgStroke.Thickness = 1
                HealthBarBgStroke.Parent = HealthBarBg

                -- Health Bar Fill
                local HealthBarFill = Instance.new("Frame")
                HealthBarFill.Size = UDim2.new(1, 0, 0.75, 0) -- 75% health for demo
                HealthBarFill.Position = UDim2.new(0, 0, 0.25, 0)
                HealthBarFill.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
                HealthBarFill.BorderSizePixel = 0
                HealthBarFill.Parent = HealthBarBg

                local HealthBarFillCorner = Instance.new("UICorner")
                HealthBarFillCorner.CornerRadius = UDim.new(0, 2)
                HealthBarFillCorner.Parent = HealthBarFill

                -- Health Text
                local HealthText = Instance.new("TextLabel")
                HealthText.Size = UDim2.new(0, 30, 0, 12)
                HealthText.Position = UDim2.new(0.5, -58, 0.5, -6)
                HealthText.BackgroundTransparency = 1
                HealthText.Text = "75"
                HealthText.TextColor3 = Color3.fromRGB(60, 180, 75)
                HealthText.Font = Window.Font
                HealthText.TextSize = 10
                HealthText.TextXAlignment = Enum.TextXAlignment.Right
                HealthText.TextStrokeTransparency = 0.5
                HealthText.Visible = false
                HealthText.Parent = ESPOverlay

                local Camera = Instance.new("Camera")
                Camera.Parent = ViewportFrame
                ViewportFrame.CurrentCamera = Camera

                Viewport.Frame = ViewportFrame
                Viewport.Camera = Camera
                Viewport.BoxESP = BoxESP
                Viewport.BoxStroke = BoxStroke
                Viewport.NameESP = NameESP
                Viewport.HealthBarBg = HealthBarBg
                Viewport.HealthBarFill = HealthBarFill
                Viewport.HealthText = HealthText

                function Viewport:SetBoxESP(enabled, color)
                    Viewport.ESPSettings.BoxEnabled = enabled
                    if color then
                        Viewport.ESPSettings.BoxColor = color
                        BoxStroke.Color = color
                    end
                    BoxESP.Visible = enabled
                end

                function Viewport:SetNameESP(enabled, color)
                    Viewport.ESPSettings.NameEnabled = enabled
                    if color then
                        Viewport.ESPSettings.NameColor = color
                        NameESP.TextColor3 = color
                    end
                    NameESP.Visible = enabled
                end

                function Viewport:SetHealthESP(enabled)
                    Viewport.ESPSettings.HealthEnabled = enabled
                    HealthBarBg.Visible = enabled
                    HealthText.Visible = enabled
                end

                function Viewport:SetHealth(percent)
                    percent = math.clamp(percent, 0, 100) / 100
                    HealthBarFill.Size = UDim2.new(1, 0, percent, 0)
                    HealthBarFill.Position = UDim2.new(0, 0, 1 - percent, 0)
                    HealthText.Text = tostring(math.floor(percent * 100))
                    
                    -- Color based on health
                    local healthColor
                    if percent > 0.6 then
                        healthColor = Color3.fromRGB(60, 180, 75)
                    elseif percent > 0.3 then
                        healthColor = Color3.fromRGB(245, 166, 35)
                    else
                        healthColor = Color3.fromRGB(220, 53, 69)
                    end
                    HealthBarFill.BackgroundColor3 = healthColor
                    HealthText.TextColor3 = healthColor
                end

                function Viewport:SetPlayerName(playerName)
                    NameESP.Text = playerName or "PlayerName"
                end

                function Viewport:SetCharacter()
                    local player = Players.LocalPlayer
                    if not player or not player.Character then return end

                    -- Clear existing model
                    for _, child in pairs(ViewportFrame:GetChildren()) do
                        if child:IsA("Model") then
                            child:Destroy()
                        end
                    end

                    local character = player.Character
                    local oldArchivable = character.Archivable
                    
                    -- Clone character
                    character.Archivable = true
                    local clone = character:Clone()
                    character.Archivable = oldArchivable

                    -- Clean up clone
                    for _, obj in pairs(clone:GetDescendants()) do
                        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                            obj:Destroy()
                        elseif obj:IsA("Humanoid") then
                            obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                            obj:Destroy()
                        end
                    end

                    clone.Parent = ViewportFrame
                    Viewport.Model = clone

                    -- Set player name in ESP
                    Viewport:SetPlayerName(player.Name)

                    -- Position camera to face the character (character facing camera)
                    local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        -- Position character to face forward (toward camera)
                        local charPosition = Vector3.new(0, 0, 0)
                        humanoidRootPart.CFrame = CFrame.new(charPosition) * CFrame.Angles(0, math.rad(180), 0)
                        
                        -- Camera positioned in front of character, looking at it
                        Camera.CFrame = CFrame.new(charPosition + Vector3.new(0, 1, 5), charPosition + Vector3.new(0, 1, 0))
                    end

                    -- Rotation animation (slow spin)
                    local rotationConnection
                    rotationConnection = RunService.RenderStepped:Connect(function()
                        if clone and clone.Parent and clone:FindFirstChild("HumanoidRootPart") then
                            local hrp = clone.HumanoidRootPart
                            local currentCFrame = hrp.CFrame
                            hrp.CFrame = CFrame.new(currentCFrame.Position) * CFrame.Angles(0, currentCFrame.Rotation.Y + math.rad(0.5), 0)
                        else
                            rotationConnection:Disconnect()
                        end
                    end)

                    return clone
                end

                return Viewport
            end

            return Section
        end

        return Tab
    end

    function Window:CreateSettingsTab()
        local SettingsTab = Window:CreateTab("Settings", "settings")
        
        local AppearanceSection = SettingsTab:CreateSection("Appearance")
        
        AppearanceSection:CreateColorpicker({
            Name = "Accent Color",
            Default = Colors.Accent,
            Callback = function(color)
                Window:UpdateAccent(color)
            end
        })
        
        local fontNames = {}
        for _, fontData in ipairs(Fonts) do
            table.insert(fontNames, fontData.Name)
        end
        
        AppearanceSection:CreateDropdown({
            Name = "Font",
            Items = fontNames,
            Default = "Code",
            Callback = function(selected)
                for _, fontData in ipairs(Fonts) do
                    if fontData.Name == selected then
                        Window:UpdateFont(fontData.Font)
                        break
                    end
                end
            end
        })
        
        AppearanceSection:CreateSlider({
            Name = "Font Size",
            Min = 8,
            Max = 14,
            Default = 10,
            Increment = 1,
            Suffix = "px",
            Callback = function(size)
                Window:UpdateFontSize(size)
            end
        })
        
        local ConfigSection = SettingsTab:CreateSection("Config")
        
        ConfigSection:CreateButton({
            Name = "Save Config",
            Icon = "save",
            Callback = function()
                print("Config saved!")
            end
        })
        
        ConfigSection:CreateButton({
            Name = "Load Config",
            Icon = "folder-open",
            Callback = function()
                print("Config loaded!")
            end
        })
        
        ConfigSection:CreateDropdown({
            Name = "Config Slot",
            Items = {"Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5"},
            Default = "Slot 1",
            Callback = function(slot)
                print("Selected:", slot)
            end
        })
        
        local MiscSection = SettingsTab:CreateSection("Miscellaneous")
        
        MiscSection:CreateKeybind({
            Name = "Toggle UI",
            Default = Enum.KeyCode.Insert,
            Callback = function()
                ScreenGui.Enabled = not ScreenGui.Enabled
            end
        })
        
        MiscSection:CreateButton({
            Name = "Unload Cheat",
            Icon = "x",
            Callback = function()
                ScreenGui:Destroy()
                print("UI Unloaded!")
            end
        })
        
        return SettingsTab
    end

    return Window
end

return Library
