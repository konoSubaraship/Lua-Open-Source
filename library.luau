-- CS:GO Style UI Library - Enhanced Version
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

-- Notification System
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Size = UDim2.new(0, 300, 1, -20)
NotificationHolder.Position = UDim2.new(1, -310, 0, 10)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.Padding = UDim.new(0, 8)
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotificationLayout.Parent = NotificationHolder

-- Config System
local ConfigSystem = {
    Flags = {},
    Elements = {},
    ConfigFolder = "CSGOCheat",
    CurrentSlot = "Slot1"
}

function ConfigSystem:SetValue(flag, value)
    if flag and flag ~= "" then
        self.Flags[flag] = value
    end
end

function ConfigSystem:GetValue(flag)
    return self.Flags[flag]
end

function ConfigSystem:RegisterElement(flag, element)
    if flag and flag ~= "" then
        self.Elements[flag] = element
    end
end

function ConfigSystem:SaveConfig(slotName)
    slotName = slotName or self.CurrentSlot
    
    local configData = {}
    
    for flag, value in pairs(self.Flags) do
        if typeof(value) == "Color3" then
            configData[flag] = {
                Type = "Color3",
                R = math.floor(value.R * 255),
                G = math.floor(value.G * 255),
                B = math.floor(value.B * 255)
            }
        elseif typeof(value) == "EnumItem" then
            configData[flag] = {
                Type = "KeyCode",
                Name = value.Name
            }
        else
            configData[flag] = {
                Type = typeof(value),
                Value = value
            }
        end
    end
    
    local jsonData = HttpService:JSONEncode(configData)
    
    if writefile then
        local folderPath = self.ConfigFolder
        local filePath = folderPath .. "/" .. slotName .. ".json"
        
        if not isfolder(folderPath) then
            makefolder(folderPath)
        end
        
        writefile(filePath, jsonData)
        return true
    else
        warn("File system not supported")
        return false
    end
end

function ConfigSystem:LoadConfig(slotName)
    slotName = slotName or self.CurrentSlot
    
    if readfile then
        local folderPath = self.ConfigFolder
        local filePath = folderPath .. "/" .. slotName .. ".json"
        
        if isfile(filePath) then
            local success, jsonData = pcall(function()
                return readfile(filePath)
            end)
            
            if success and jsonData then
                local success2, configData = pcall(function()
                    return HttpService:JSONDecode(jsonData)
                end)
                
                if success2 and configData then
                    for flag, data in pairs(configData) do
                        local value
                        
                        if data.Type == "Color3" then
                            value = Color3.fromRGB(data.R, data.G, data.B)
                        elseif data.Type == "KeyCode" then
                            value = Enum.KeyCode[data.Name]
                        else
                            value = data.Value
                        end
                        
                        self.Flags[flag] = value
                        
                        local element = self.Elements[flag]
                        if element and element.Set then
                            element:Set(value)
                        end
                    end
                    return true
                end
            end
        end
    end
    
    return false
end

function ConfigSystem:GetConfigList()
    local configs = {}
    
    if isfolder and listfiles then
        local folderPath = self.ConfigFolder
        
        if isfolder(folderPath) then
            local files = listfiles(folderPath)
            for _, file in pairs(files) do
                local fileName = file:match("([^/\\]+)%.json$")
                if fileName then
                    table.insert(configs, fileName)
                end
            end
        end
    end
    
    if #configs == 0 then
        configs = {"Slot1", "Slot2", "Slot3", "Slot4", "Slot5"}
    end
    
    return configs
end

function ConfigSystem:DeleteConfig(slotName)
    if delfile and isfile then
        local filePath = self.ConfigFolder .. "/" .. slotName .. ".json"
        if isfile(filePath) then
            delfile(filePath)
            return true
        end
    end
    return false
end

Library.ConfigSystem = ConfigSystem

-- Utility Functions
local function Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateIcon(iconName, parent)
    local size = "48px"
    local iconData = LucideIcons[size] and LucideIcons[size][iconName]
    
    if not iconData then
        return nil
    end
    
    local imageId = iconData[1]
    local imageSize = iconData[2]
    local imageRect = iconData[3]
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. imageId
    icon.ImageRectSize = Vector2.new(imageSize[1], imageSize[2])
    icon.ImageRectOffset = Vector2.new(imageRect[1], imageRect[2])
    icon.Parent = parent
    
    return icon
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 63)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function AddPadding(parent, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = parent
    return padding
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

-- Enhanced Color Scheme (Gray/Dark theme)
local Colors = {
	Background = Color3.fromRGB(35, 35, 38),
	BackgroundDark = Color3.fromRGB(28, 28, 30),
	BackgroundDarker = Color3.fromRGB(22, 22, 24),
	Secondary = Color3.fromRGB(30, 30, 32),
	Tertiary = Color3.fromRGB(40, 40, 43),
	Border = Color3.fromRGB(60, 60, 63),
	BorderLight = Color3.fromRGB(70, 70, 73),
	Accent = Color3.fromRGB(173, 173, 173),
	AccentHover = Color3.fromRGB(203, 203, 203),
	AccentDark = Color3.fromRGB(88, 88, 88),
	Text = Color3.fromRGB(245, 245, 250),
	TextDark = Color3.fromRGB(180, 180, 185),
	TextMuted = Color3.fromRGB(140, 140, 145),
	Toggle = Color3.fromRGB(106, 106, 106),
	ToggleOff = Color3.fromRGB(50, 50, 53),
	Header = Color3.fromRGB(25, 25, 27),
	ElementBg = Color3.fromRGB(32, 32, 35),
	ElementHover = Color3.fromRGB(42, 42, 45),
	Success = Color3.fromRGB(70, 200, 85),
	Warning = Color3.fromRGB(255, 176, 45),
	Danger = Color3.fromRGB(240, 63, 79),
	Divider = Color3.fromRGB(55, 55, 60),
}

-- Available Fonts
local Fonts = {
    {Name = "Roboto", Font = Enum.Font.Roboto},
    {Name = "Roboto Mono", Font = Enum.Font.RobotoMono},
    {Name = "Ubuntu", Font = Enum.Font.Ubuntu},
    {Name = "Gotham", Font = Enum.Font.Gotham},
    {Name = "Code", Font = Enum.Font.Code},
}

local CurrentFont = Enum.Font.RobotoMono
local CurrentFontSize = 14
local TabTextSize = 14 -- Fixed tab text size

-- Notification Function
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local duration = options.Duration or 3
    local type_color = options.Type == "success" and Colors.Success or
                      options.Type == "warning" and Colors.Warning or
                      options.Type == "error" and Colors.Danger or
                      Colors.Accent

    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.BackgroundColor3 = Colors.BackgroundDark
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.Parent = NotificationHolder

    AddCorner(Notification, 6)
    local NotifStroke = AddStroke(Notification, type_color, 2)

    local NotifAccent = Instance.new("Frame")
    NotifAccent.Size = UDim2.new(0, 4, 1, 0)
    NotifAccent.BackgroundColor3 = type_color
    NotifAccent.BorderSizePixel = 0
    NotifAccent.Parent = Notification

    local NotifContent = Instance.new("Frame")
    NotifContent.Size = UDim2.new(1, -14, 1, -16)
    NotifContent.Position = UDim2.new(0, 14, 0, 8)
    NotifContent.BackgroundTransparency = 1
    NotifContent.Parent = Notification

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.Padding = UDim.new(0, 4)
    NotifLayout.Parent = NotifContent

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, 0, 0, 0)
    NotifTitle.AutomaticSize = Enum.AutomaticSize.Y
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = title
    NotifTitle.TextColor3 = type_color
    NotifTitle.Font = CurrentFont
    NotifTitle.TextSize = CurrentFontSize + 1
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.TextWrapped = true
    NotifTitle.LayoutOrder = 1
    NotifTitle.Parent = NotifContent

    local NotifDesc = Instance.new("TextLabel")
    NotifDesc.Size = UDim2.new(1, 0, 0, 0)
    NotifDesc.AutomaticSize = Enum.AutomaticSize.Y
    NotifDesc.BackgroundTransparency = 1
    NotifDesc.Text = description
    NotifDesc.TextColor3 = Colors.TextDark
    NotifDesc.Font = CurrentFont
    NotifDesc.TextSize = CurrentFontSize
    NotifDesc.TextXAlignment = Enum.TextXAlignment.Left
    NotifDesc.TextWrapped = true
    NotifDesc.LayoutOrder = 2
    NotifDesc.Parent = NotifContent

    -- Calculate height
    task.wait()
    local contentHeight = NotifLayout.AbsoluteContentSize.Y + 16
    Notification.Size = UDim2.new(1, 0, 0, contentHeight)

    -- Animate in
    Notification.Position = UDim2.new(0, 310, 0, 0)
    Tween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)

    -- Auto remove
    task.delay(duration, function()
        Tween(Notification, {Position = UDim2.new(0, 310, 0, 0)}, 0.3)
        task.wait(0.3)
        Notification:Destroy()
    end)
end

function Library:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "CHEAT MENU"
    local windowIcon = options.Icon or "layout-dashboard"
    local configFolder = options.ConfigFolder or "CSGOCheat"
    
    ConfigSystem.ConfigFolder = configFolder
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false
    Window.Font = CurrentFont
    Window.FontSize = CurrentFontSize
    Window.Accent = Colors.Accent
    Window.AccentElements = {}
    Window.Flags = ConfigSystem.Flags
    Window.TabButtons = {}

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    Window.MainFrame = MainFrame

    AddCorner(MainFrame, 8)
    AddStroke(MainFrame, Colors.Border, 1)

    -- Inner container
    local InnerContainer = Instance.new("Frame")
    InnerContainer.Name = "InnerContainer"
    InnerContainer.Size = UDim2.new(1, 0, 1, 0)
    InnerContainer.BackgroundTransparency = 1
    InnerContainer.ClipsDescendants = true
    InnerContainer.Parent = MainFrame

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Colors.Header
    Header.BorderSizePixel = 0
    Header.Parent = InnerContainer

    local HeaderBottom = Instance.new("Frame")
    HeaderBottom.Size = UDim2.new(1, 0, 0, 10)
    HeaderBottom.Position = UDim2.new(0, 0, 1, -10)
    HeaderBottom.BackgroundColor3 = Colors.Header
    HeaderBottom.BorderSizePixel = 0
    HeaderBottom.Parent = Header

    local HeaderBorder = Instance.new("Frame")
    HeaderBorder.Size = UDim2.new(1, 0, 0, 1)
    HeaderBorder.Position = UDim2.new(0, 0, 1, 0)
    HeaderBorder.BackgroundColor3 = Colors.Border
    HeaderBorder.BorderSizePixel = 0
    HeaderBorder.Parent = Header

    -- Window Icon
    local WindowIcon = CreateIcon(windowIcon, Header)
    if WindowIcon then
        WindowIcon.Position = UDim2.new(0, 12, 0.5, -8)
        WindowIcon.ImageColor3 = Colors.Accent
        table.insert(Window.AccentElements, {Type = "Icon", Element = WindowIcon})
    end

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Position = UDim2.new(0, WindowIcon and 34 or 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = windowName
    Title.TextColor3 = Colors.Text
    Title.Font = CurrentFont
    Title.TextSize = TabTextSize
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Control Buttons Container
    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Size = UDim2.new(0, 65, 0, 28)
    ControlsContainer.Position = UDim2.new(1, -70, 0.5, -14)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = Header

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 5)
    ControlsLayout.Parent = ControlsContainer

    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
    MinimizeButton.BackgroundColor3 = Colors.Secondary
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = ""
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.Parent = ControlsContainer

    AddCorner(MinimizeButton, 6)
    AddStroke(MinimizeButton, Colors.Border, 1)

    local MinimizeIcon = CreateIcon("minus", MinimizeButton)
    if MinimizeIcon then
        MinimizeIcon.Size = UDim2.new(0, 14, 0, 14)
        MinimizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        MinimizeIcon.ImageColor3 = Colors.TextDark
    end

    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Colors.ElementHover}, 0.15)
        if MinimizeIcon then MinimizeIcon.ImageColor3 = Colors.Text end
    end)

    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Colors.Secondary}, 0.15)
        if MinimizeIcon then MinimizeIcon.ImageColor3 = Colors.TextDark end
    end)

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 28, 0, 28)
    CloseButton.BackgroundColor3 = Colors.Secondary
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = ControlsContainer

    AddCorner(CloseButton, 6)
    AddStroke(CloseButton, Colors.Border, 1)

    local CloseIcon = CreateIcon("x", CloseButton)
    if CloseIcon then
        CloseIcon.Size = UDim2.new(0, 14, 0, 14)
        CloseIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        CloseIcon.ImageColor3 = Colors.TextDark
    end

    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Colors.Danger}, 0.15)
        if CloseIcon then CloseIcon.ImageColor3 = Colors.Text end
    end)

    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Colors.Secondary}, 0.15)
        if CloseIcon then CloseIcon.ImageColor3 = Colors.TextDark end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Resize Handle
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.Parent = MainFrame

    local ResizeIcon = CreateIcon("move-diagonal-2", ResizeHandle)
    if ResizeIcon then
        ResizeIcon.Size = UDim2.new(0, 12, 0, 12)
        ResizeIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
        ResizeIcon.ImageColor3 = Colors.TextMuted
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
                MinimizeIcon = CreateIcon("plus", MinimizeButton)
                if MinimizeIcon then
                    MinimizeIcon.Size = UDim2.new(0, 14, 0, 14)
                    MinimizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
                    MinimizeIcon.ImageColor3 = Colors.Text
                end
            end
        else
            Tween(MainFrame, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 420)}, 0.3)
            ResizeHandle.Visible = true
            if MinimizeIcon then
                MinimizeIcon:Destroy()
                MinimizeIcon = CreateIcon("minus", MinimizeButton)
                if MinimizeIcon then
                    MinimizeIcon.Size = UDim2.new(0, 14, 0, 14)
                    MinimizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
                    MinimizeIcon.ImageColor3 = Colors.Text
                end
            end
        end
    end)

    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = Colors.BackgroundDark
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = InnerContainer

    local TabBorder = Instance.new("Frame")
    TabBorder.Size = UDim2.new(1, 0, 0, 1)
    TabBorder.Position = UDim2.new(0, 0, 1, 0)
    TabBorder.BackgroundColor3 = Colors.Border
    TabBorder.BorderSizePixel = 0
    TabBorder.Parent = TabContainer

    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, -20, 1, -10)
    TabList.Position = UDim2.new(0, 10, 0, 5)
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
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabList

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -75)
    ContentContainer.Position = UDim2.new(0, 0, 0, 75)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = InnerContainer

    MakeDraggable(MainFrame, Header)
    MakeResizable(MainFrame, ResizeHandle, Window)

    function Window:UpdateFont(font)
        Window.Font = font
        
        for _, tab in pairs(Window.Tabs) do
            for _, element in pairs(tab.Content:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                    element.Font = font
                end
            end
        end
    end

    function Window:UpdateFontSize(size)
        Window.FontSize = size
        
        for _, tab in pairs(Window.Tabs) do
            for _, element in pairs(tab.Content:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                    if element.Name == "SectionLabel" then
                        element.TextSize = size + 2
                    elseif element.Parent.Name ~= "TabList" then -- Don't change tab text size
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
            math.min(1, color.R + 0.1),
            math.min(1, color.G + 0.1),
            math.min(1, color.B + 0.1)
        )
        Colors.AccentDark = Color3.new(
            math.max(0, color.R - 0.1),
            math.max(0, color.G - 0.1),
            math.max(0, color.B - 0.1)
        )
        Colors.Toggle = color
        
        if Window.CurrentTab then
            Window.CurrentTab.Button.BackgroundColor3 = color
        end
        
        for _, data in pairs(Window.AccentElements) do
            if data.Element and data.Element.Parent then
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
    end

    function Window:SaveConfig(slotName)
        return ConfigSystem:SaveConfig(slotName)
    end

    function Window:LoadConfig(slotName)
        return ConfigSystem:LoadConfig(slotName)
    end

    function Window:GetConfigList()
        return ConfigSystem:GetConfigList()
    end

    function Window:DeleteConfig(slotName)
        return ConfigSystem:DeleteConfig(slotName)
    end

    function Window:SetConfigSlot(slotName)
        ConfigSystem.CurrentSlot = slotName
    end

    function Window:CreateTab(tabName, iconName)
        local Tab = {}
        Tab.Name = tabName

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Size = UDim2.new(0, 0, 0, 28)
        TabButton.AutomaticSize = Enum.AutomaticSize.X
        TabButton.BackgroundColor3 = Colors.ElementBg
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabList

        AddCorner(TabButton, 6)
        local TabStroke = AddStroke(TabButton, Colors.Border, 1)

        local TabButtonPadding = Instance.new("UIPadding")
        TabButtonPadding.PaddingLeft = UDim.new(0, 10)
        TabButtonPadding.PaddingRight = UDim.new(0, 12)
        TabButtonPadding.Parent = TabButton

        local TabButtonLayout = Instance.new("UIListLayout")
        TabButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        TabButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        TabButtonLayout.Padding = UDim.new(0, 6)
        TabButtonLayout.Parent = TabButton

        local TabIcon
        if iconName then
            TabIcon = CreateIcon(iconName, TabButton)
            if TabIcon then
                TabIcon.Size = UDim2.new(0, 14, 0, 14)
                TabIcon.ImageColor3 = Colors.TextMuted
                TabIcon.LayoutOrder = 1
                Tab.Icon = TabIcon
            end
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(0, 0, 0, 28)
        TabLabel.AutomaticSize = Enum.AutomaticSize.X
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName:upper()
        TabLabel.TextColor3 = Colors.TextMuted
        TabLabel.Font = Window.Font
        TabLabel.TextSize = TabTextSize
        TabLabel.LayoutOrder = 2
        TabLabel.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Colors.Accent
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        table.insert(Window.AccentElements, {Type = "ScrollBar", Element = TabContent})

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent

        AddPadding(TabContent, 10, 10, 10, 10)

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
        end

        table.insert(Window.Tabs, Tab)

        function Tab:AddDivider()
            local Divider = Instance.new("Frame")
            Divider.Name = "Divider"
            Divider.Size = UDim2.new(1, 0, 0, 20)
            Divider.BackgroundTransparency = 1
            Divider.Parent = TabContent

            local DividerLine = Instance.new("Frame")
            DividerLine.Size = UDim2.new(1, -20, 0, 1)
            DividerLine.Position = UDim2.new(0, 10, 0.5, 0)
            DividerLine.BackgroundColor3 = Colors.Divider
            DividerLine.BorderSizePixel = 0
            DividerLine.Parent = Divider

            local DividerGradient = Instance.new("UIGradient")
            DividerGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            })
            DividerGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0),
                NumberSequenceKeypoint.new(0.8, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            DividerGradient.Parent = DividerLine

            return Divider
        end

        function Tab:AddLabeledDivider(text)
            local Divider = Instance.new("Frame")
            Divider.Name = "LabeledDivider"
            Divider.Size = UDim2.new(1, 0, 0, 24)
            Divider.BackgroundTransparency = 1
            Divider.Parent = TabContent

            local LeftLine = Instance.new("Frame")
            LeftLine.Size = UDim2.new(0.5, -50, 0, 1)
            LeftLine.Position = UDim2.new(0, 10, 0.5, 0)
            LeftLine.BackgroundColor3 = Colors.Divider
            LeftLine.BorderSizePixel = 0
            LeftLine.Parent = Divider

            local LeftGradient = Instance.new("UIGradient")
            LeftGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            })
            LeftGradient.Parent = LeftLine

            local RightLine = Instance.new("Frame")
            RightLine.Size = UDim2.new(0.5, -50, 0, 1)
            RightLine.Position = UDim2.new(0.5, 40, 0.5, 0)
            RightLine.BackgroundColor3 = Colors.Divider
            RightLine.BorderSizePixel = 0
            RightLine.Parent = Divider

            local RightGradient = Instance.new("UIGradient")
            RightGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            RightGradient.Parent = RightLine

            local DividerLabel = Instance.new("TextLabel")
            DividerLabel.Size = UDim2.new(0, 80, 1, 0)
            DividerLabel.Position = UDim2.new(0.5, -40, 0, 0)
            DividerLabel.BackgroundTransparency = 1
            DividerLabel.Text = text or "DIVIDER"
            DividerLabel.TextColor3 = Colors.TextMuted
            DividerLabel.Font = Window.Font
            DividerLabel.TextSize = Window.FontSize - 1
            DividerLabel.Parent = Divider

            return Divider
        end

        function Tab:AddSpacer(height)
            local Spacer = Instance.new("Frame")
            Spacer.Name = "Spacer"
            Spacer.Size = UDim2.new(1, 0, 0, height or 10)
            Spacer.BackgroundTransparency = 1
            Spacer.Parent = TabContent
            return Spacer
        end

        function Tab:CreateSection(sectionName)
            local Section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName
            SectionFrame.Size = UDim2.new(1, 0, 0, 35)
            SectionFrame.BackgroundColor3 = Colors.BackgroundDark
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabContent

            AddCorner(SectionFrame, 8)
            AddStroke(SectionFrame, Colors.Border, 1)

            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "Header"
            SectionHeader.Size = UDim2.new(1, 0, 0, 28)
            SectionHeader.BackgroundColor3 = Colors.BackgroundDarker
            SectionHeader.BorderSizePixel = 0
            SectionHeader.Parent = SectionFrame

            local SectionHeaderCorner = Instance.new("UICorner")
            SectionHeaderCorner.CornerRadius = UDim.new(0, 8)
            SectionHeaderCorner.Parent = SectionHeader

            local HeaderBottom = Instance.new("Frame")
            HeaderBottom.Size = UDim2.new(1, 0, 0, 10)
            HeaderBottom.Position = UDim2.new(0, 0, 1, -10)
            HeaderBottom.BackgroundColor3 = Colors.BackgroundDarker
            HeaderBottom.BorderSizePixel = 0
            HeaderBottom.Parent = SectionHeader

            local HeaderBorder = Instance.new("Frame")
            HeaderBorder.Size = UDim2.new(1, 0, 0, 1)
            HeaderBorder.Position = UDim2.new(0, 0, 1, 0)
            HeaderBorder.BackgroundColor3 = Colors.Border
            HeaderBorder.BorderSizePixel = 0
            HeaderBorder.Parent = SectionHeader

            local SectionIcon = CreateIcon("folder", SectionHeader)
            if SectionIcon then
                SectionIcon.Position = UDim2.new(0, 10, 0.5, -7)
                SectionIcon.Size = UDim2.new(0, 14, 0, 14)
                SectionIcon.ImageColor3 = Colors.Accent
                table.insert(Window.AccentElements, {Type = "Icon", Element = SectionIcon})
            end

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = "SectionLabel"
            SectionLabel.Size = UDim2.new(1, -40, 1, 0)
            SectionLabel.Position = UDim2.new(0, SectionIcon and 30 or 10, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = sectionName
            SectionLabel.TextColor3 = Colors.Text
            SectionLabel.Font = Window.Font
            SectionLabel.TextSize = Window.FontSize + 2
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionHeader

            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 1, -28)
            SectionContent.Position = UDim2.new(0, 0, 0, 28)
            SectionContent.BackgroundTransparency = 1
            SectionContent.Parent = SectionFrame

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 4)
            SectionLayout.Parent = SectionContent

            AddPadding(SectionContent, 8, 8, 6, 6)

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 40)
            end)

            function Section:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Size = UDim2.new(1, 0, 0, 12)
                Divider.BackgroundTransparency = 1
                Divider.Parent = SectionContent

                local DividerLine = Instance.new("Frame")
                DividerLine.Size = UDim2.new(1, 0, 0, 1)
                DividerLine.Position = UDim2.new(0, 0, 0.5, 0)
                DividerLine.BackgroundColor3 = Colors.Border
                DividerLine.BorderSizePixel = 0
                DividerLine.Parent = Divider

                return Divider
            end

            function Section:CreateCheckbox(options)
                options = options or {}
                local name = options.Name or "Checkbox"
                local flag = options.Flag or ""
                local default = options.Default or false
                local callback = options.Callback or function() end

                local Checkbox = {}
                Checkbox.Value = default
                Checkbox.Flag = flag

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, default)
                    ConfigSystem:RegisterElement(flag, Checkbox)
                end

                local CheckboxFrame = Instance.new("Frame")
                CheckboxFrame.Size = UDim2.new(1, 0, 0, 28)
                CheckboxFrame.BackgroundColor3 = Colors.ElementBg
                CheckboxFrame.BorderSizePixel = 0
                CheckboxFrame.Parent = SectionContent

                AddCorner(CheckboxFrame, 6)
                AddStroke(CheckboxFrame, Colors.Border, 1)

                local CheckboxButton = Instance.new("TextButton")
                CheckboxButton.Size = UDim2.new(1, 0, 1, 0)
                CheckboxButton.BackgroundTransparency = 1
                CheckboxButton.Text = ""
                CheckboxButton.Parent = CheckboxFrame

                local CheckboxLabel = Instance.new("TextLabel")
                CheckboxLabel.Size = UDim2.new(1, -40, 1, 0)
                CheckboxLabel.Position = UDim2.new(0, 10, 0, 0)
                CheckboxLabel.BackgroundTransparency = 1
                CheckboxLabel.Text = name
                CheckboxLabel.TextColor3 = Colors.Text
                CheckboxLabel.Font = Window.Font
                CheckboxLabel.TextSize = Window.FontSize
                CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                CheckboxLabel.Parent = CheckboxFrame

                local CheckboxBox = Instance.new("Frame")
                CheckboxBox.Size = UDim2.new(0, 18, 0, 18)
                CheckboxBox.Position = UDim2.new(1, -28, 0.5, -9)
                CheckboxBox.BackgroundColor3 = Colors.BackgroundDarker
                CheckboxBox.BorderSizePixel = 0
                CheckboxBox.Parent = CheckboxFrame

                AddCorner(CheckboxBox, 4)
                local BoxStroke = AddStroke(CheckboxBox, Colors.Border, 1)

                local CheckIcon = CreateIcon("check", CheckboxBox)
                if CheckIcon then
                    CheckIcon.Size = UDim2.new(0, 12, 0, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.ImageColor3 = Colors.Text
                    CheckIcon.Visible = default
                end

                local function updateVisual()
                    if Checkbox.Value then
                        CheckboxBox.BackgroundColor3 = Colors.Toggle
                        BoxStroke.Color = Colors.Toggle
                        if CheckIcon then CheckIcon.Visible = true end
                    else
                        CheckboxBox.BackgroundColor3 = Colors.BackgroundDarker
                        BoxStroke.Color = Colors.Border
                        if CheckIcon then CheckIcon.Visible = false end
                    end
                end

                updateVisual()

                CheckboxButton.MouseEnter:Connect(function()
                    Tween(CheckboxFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                end)

                CheckboxButton.MouseLeave:Connect(function()
                    Tween(CheckboxFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                end)

                CheckboxButton.MouseButton1Click:Connect(function()
                    Checkbox.Value = not Checkbox.Value
                    updateVisual()
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, Checkbox.Value)
                    end
                    
                    callback(Checkbox.Value)
                end)

                function Checkbox:Set(value)
                    Checkbox.Value = value
                    updateVisual()
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, value)
                    end
                    
                    callback(value)
                end

                function Checkbox:Get()
                    return Checkbox.Value
                end

                return Checkbox
            end

            function Section:CreateButton(options)
                options = options or {}
                local name = options.Name or "Button"
                local iconName = options.Icon
                local callback = options.Callback or function() end

                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                ButtonFrame.BackgroundColor3 = Colors.Accent
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Parent = SectionContent

                AddCorner(ButtonFrame, 6)
                AddStroke(ButtonFrame, Colors.Border, 1)
                table.insert(Window.AccentElements, {Type = "Background", Element = ButtonFrame})

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundTransparency = 1
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.Parent = ButtonFrame

                local ButtonContent = Instance.new("Frame")
                ButtonContent.Size = UDim2.new(1, 0, 1, 0)
                ButtonContent.BackgroundTransparency = 1
                ButtonContent.Parent = Button

                local ButtonLayout = Instance.new("UIListLayout")
                ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
                ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                ButtonLayout.Padding = UDim.new(0, 6)
                ButtonLayout.Parent = ButtonContent

                if iconName then
                    local ButtonIcon = CreateIcon(iconName, ButtonContent)
                    if ButtonIcon then
                        ButtonIcon.Size = UDim2.new(0, 14, 0, 14)
                        ButtonIcon.ImageColor3 = Colors.Text
                        ButtonIcon.LayoutOrder = 1
                    end
                end

                local ButtonLabel = Instance.new("TextLabel")
                ButtonLabel.Size = UDim2.new(0, 0, 0, 28)
                ButtonLabel.AutomaticSize = Enum.AutomaticSize.X
                ButtonLabel.BackgroundTransparency = 1
                ButtonLabel.Text = name
                ButtonLabel.TextColor3 = Colors.Text
                ButtonLabel.Font = Window.Font
                ButtonLabel.TextSize = Window.FontSize
                ButtonLabel.LayoutOrder = 2
                ButtonLabel.Parent = ButtonContent

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
                local flag = options.Flag or ""
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local suffix = options.Suffix or ""
                local callback = options.Callback or function() end

                local Slider = {}
                Slider.Value = default
                Slider.Flag = flag

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, default)
                    ConfigSystem:RegisterElement(flag, Slider)
                end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 38)
                SliderFrame.BackgroundColor3 = Colors.ElementBg
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = SectionContent

                AddCorner(SliderFrame, 6)
                AddStroke(SliderFrame, Colors.Border, 1)

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(0.6, 0, 0, 18)
                SliderLabel.Position = UDim2.new(0, 10, 0, 4)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Colors.Text
                SliderLabel.Font = Window.Font
                SliderLabel.TextSize = Window.FontSize
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local SliderValue = Instance.new("TextLabel")
                SliderValue.Size = UDim2.new(0.4, -10, 0, 18)
                SliderValue.Position = UDim2.new(0.6, 0, 0, 4)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(default) .. suffix
                SliderValue.TextColor3 = Colors.Accent
                SliderValue.Font = Window.Font
                SliderValue.TextSize = Window.FontSize
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                table.insert(Window.AccentElements, {Type = "Text", Element = SliderValue})

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -20, 0, 6)
                SliderBar.Position = UDim2.new(0, 10, 1, -14)
                SliderBar.BackgroundColor3 = Colors.BackgroundDarker
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame

                AddCorner(SliderBar, 3)

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Colors.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar
                
                table.insert(Window.AccentElements, {Type = "Background", Element = SliderFill})

                AddCorner(SliderFill, 3)

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
                    value = math.clamp(value, min, max)
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
                    Tween(SliderFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                end)

                function Slider:Set(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    SliderValue.Text = tostring(value) .. suffix
                    Tween(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.1)
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, value)
                    end
                    
                    callback(value)
                end

                function Slider:Get()
                    return Slider.Value
                end

                return Slider
            end

            function Section:CreateDropdown(options)
                options = options or {}
                local name = options.Name or "Dropdown"
                local flag = options.Flag or ""
                local items = options.Items or {}
                local default = options.Default or (items[1] or "None")
                local callback = options.Callback or function() end
                local searchable = options.Search ~= false -- Default true

                local Dropdown = {}
                Dropdown.Value = default
                Dropdown.Items = items
                Dropdown.Open = false
                Dropdown.Flag = flag

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, default)
                    ConfigSystem:RegisterElement(flag, Dropdown)
                end

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 28)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.ZIndex = 5
                DropdownFrame.Parent = SectionContent

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, 28)
                DropdownButton.BackgroundColor3 = Colors.ElementBg
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = ""
                DropdownButton.AutoButtonColor = false
                DropdownButton.ZIndex = 6
                DropdownButton.Parent = DropdownFrame

                AddCorner(DropdownButton, 6)
                local DropdownStroke = AddStroke(DropdownButton, Colors.Border, 1)
                DropdownStroke.ZIndex = 6

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Colors.TextDark
                DropdownLabel.Font = Window.Font
                DropdownLabel.TextSize = Window.FontSize
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.ZIndex = 6
                DropdownLabel.Parent = DropdownButton

                local DropdownValue = Instance.new("TextLabel")
                DropdownValue.Size = UDim2.new(0.5, -30, 1, 0)
                DropdownValue.Position = UDim2.new(0.5, 0, 0, 0)
                DropdownValue.BackgroundTransparency = 1
                DropdownValue.Text = default
                DropdownValue.TextColor3 = Colors.Accent
                DropdownValue.Font = Window.Font
                DropdownValue.TextSize = Window.FontSize
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
                DropdownValue.ZIndex = 6
                DropdownValue.Parent = DropdownButton
                
                table.insert(Window.AccentElements, {Type = "Text", Element = DropdownValue})

                local DropdownArrow = CreateIcon("chevron-down", DropdownButton)
                if DropdownArrow then
                    DropdownArrow.Size = UDim2.new(0, 14, 0, 14)
                    DropdownArrow.Position = UDim2.new(1, -22, 0.5, -7)
                    DropdownArrow.ImageColor3 = Colors.TextDark
                    DropdownArrow.ZIndex = 6
                end

                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Position = UDim2.new(0, 0, 0, 30)
                DropdownList.BackgroundColor3 = Colors.BackgroundDarker
                DropdownList.BorderSizePixel = 0
                DropdownList.Visible = false
                DropdownList.ZIndex = 50
                DropdownList.ClipsDescendants = true
                DropdownList.Parent = DropdownFrame

                AddCorner(DropdownList, 6)
                local ListStroke = AddStroke(DropdownList, Colors.Accent, 1)
                ListStroke.ZIndex = 50
                table.insert(Window.AccentElements, {Type = "Stroke", Element = ListStroke})

                -- Search box (if enabled)
                local SearchBox
                local searchOffset = 0
                if searchable then
                    searchOffset = 32
                    local SearchContainer = Instance.new("Frame")
                    SearchContainer.Size = UDim2.new(1, 0, 0, 28)
                    SearchContainer.BackgroundTransparency = 1
                    SearchContainer.ZIndex = 50
                    SearchContainer.Parent = DropdownList

                    SearchBox = Instance.new("TextBox")
                    SearchBox.Size = UDim2.new(1, -8, 0, 22)
                    SearchBox.Position = UDim2.new(0, 4, 0, 3)
                    SearchBox.BackgroundColor3 = Colors.ElementBg
                    SearchBox.BorderSizePixel = 0
                    SearchBox.Text = ""
                    SearchBox.PlaceholderText = "Search..."
                    SearchBox.TextColor3 = Colors.Text
                    SearchBox.PlaceholderColor3 = Colors.TextMuted
                    SearchBox.Font = Window.Font
                    SearchBox.TextSize = Window.FontSize - 1
                    SearchBox.ClearTextOnFocus = false
                    SearchBox.ZIndex = 51
                    SearchBox.Parent = SearchContainer

                    AddCorner(SearchBox, 4)
                    AddStroke(SearchBox, Colors.Border, 1)
                    AddPadding(SearchBox, 6, 6, 0, 0)

                    local SearchDivider = Instance.new("Frame")
                    SearchDivider.Size = UDim2.new(1, -8, 0, 1)
                    SearchDivider.Position = UDim2.new(0, 4, 1, 0)
                    SearchDivider.BackgroundColor3 = Colors.Border
                    SearchDivider.BorderSizePixel = 0
                    SearchDivider.ZIndex = 50
                    SearchDivider.Parent = SearchContainer
                end

                local ListContainer = Instance.new("ScrollingFrame")
                ListContainer.Size = UDim2.new(1, 0, 1, -searchOffset)
                ListContainer.Position = UDim2.new(0, 0, 0, searchOffset)
                ListContainer.BackgroundTransparency = 1
                ListContainer.BorderSizePixel = 0
                ListContainer.ScrollBarThickness = 3
                ListContainer.ScrollBarImageColor3 = Colors.Accent
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
                ListContainer.ZIndex = 50
                ListContainer.Parent = DropdownList
                
                table.insert(Window.AccentElements, {Type = "ScrollBar", Element = ListContainer})

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = ListContainer

                AddPadding(ListContainer, 4, 4, 4, 4)

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
                        local height = math.min(#Dropdown.Items * 26 + 8 + searchOffset, 130 + searchOffset)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 28 + height + 4)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
                        if DropdownArrow then
                            Tween(DropdownArrow, {Rotation = 180}, 0.2)
                        end
                        DropdownStroke.Color = Colors.Accent
                        DropdownButton.BackgroundColor3 = Colors.ElementHover
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        if DropdownArrow then
                            Tween(DropdownArrow, {Rotation = 0}, 0.2)
                        end
                        DropdownStroke.Color = Colors.Border
                        DropdownButton.BackgroundColor3 = Colors.ElementBg
                        task.delay(0.2, function()
                            if not Dropdown.Open then
                                DropdownList.Visible = false
                                if SearchBox then SearchBox.Text = "" end
                            end
                        end)
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
                        ItemButton.Size = UDim2.new(1, 0, 0, 24)
                        ItemButton.BackgroundColor3 = Colors.ElementBg
                        ItemButton.BorderSizePixel = 0
                        ItemButton.Text = item
                        ItemButton.TextColor3 = Colors.Text
                        ItemButton.Font = Window.Font
                        ItemButton.TextSize = Window.FontSize
                        ItemButton.AutoButtonColor = false
                        ItemButton.ZIndex = 50
                        ItemButton.Parent = ListContainer

                        AddCorner(ItemButton, 4)
                        AddStroke(ItemButton, Colors.Border, 1)

                        ItemButton.MouseButton1Click:Connect(function()
                            Dropdown.Value = item
                            DropdownValue.Text = item
                            Dropdown.Open = false
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                            if DropdownArrow then
                                Tween(DropdownArrow, {Rotation = 0}, 0.2)
                            end
                            DropdownStroke.Color = Colors.Border
                            DropdownButton.BackgroundColor3 = Colors.ElementBg
                            task.delay(0.2, function()
                                DropdownList.Visible = false
                                if SearchBox then SearchBox.Text = "" end
                            end)
                            
                            if flag ~= "" then
                                ConfigSystem:SetValue(flag, item)
                            end
                            
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

                if SearchBox then
                    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local searchText = SearchBox.Text:lower()
                        for _, child in pairs(ListContainer:GetChildren()) do
                            if child:IsA("TextButton") then
                                if searchText == "" or child.Text:lower():find(searchText) then
                                    child.Visible = true
                                else
                                    child.Visible = false
                                end
                            end
                        end
                    end)
                end

                function Dropdown:Set(value)
                    if table.find(Dropdown.Items, value) then
                        Dropdown.Value = value
                        DropdownValue.Text = value
                        
                        if flag ~= "" then
                            ConfigSystem:SetValue(flag, value)
                        end
                        
                        callback(value)
                    end
                end

                function Dropdown:Get()
                    return Dropdown.Value
                end

                Dropdown:Refresh()
                return Dropdown
            end

            function Section:CreateMultiDropdown(options)
                options = options or {}
                local name = options.Name or "Multi Dropdown"
                local flag = options.Flag or ""
                local items = options.Items or {}
                local default = options.Default or {}
                local callback = options.Callback or function() end
                local searchable = options.Search ~= false

                local MultiDropdown = {}
                MultiDropdown.Values = {}
                MultiDropdown.Items = items
                MultiDropdown.Open = false
                MultiDropdown.Flag = flag

                for _, v in pairs(default) do
                    MultiDropdown.Values[v] = true
                end

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, MultiDropdown.Values)
                    ConfigSystem:RegisterElement(flag, MultiDropdown)
                end

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 28)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.ZIndex = 5
                DropdownFrame.Parent = SectionContent

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, 28)
                DropdownButton.BackgroundColor3 = Colors.ElementBg
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = ""
                DropdownButton.AutoButtonColor = false
                DropdownButton.ZIndex = 6
                DropdownButton.Parent = DropdownFrame

                AddCorner(DropdownButton, 6)
                local DropdownStroke = AddStroke(DropdownButton, Colors.Border, 1)
                DropdownStroke.ZIndex = 6

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Colors.TextDark
                DropdownLabel.Font = Window.Font
                DropdownLabel.TextSize = Window.FontSize
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.ZIndex = 6
                DropdownLabel.Parent = DropdownButton

                local function getSelectedText()
                    local selected = {}
                    for item, _ in pairs(MultiDropdown.Values) do
                        table.insert(selected, item)
                    end
                    return #selected > 0 and table.concat(selected, ", ") or "None"
                end

                local DropdownValue = Instance.new("TextLabel")
                DropdownValue.Size = UDim2.new(0.5, -30, 1, 0)
                DropdownValue.Position = UDim2.new(0.5, 0, 0, 0)
                DropdownValue.BackgroundTransparency = 1
                DropdownValue.Text = getSelectedText()
                DropdownValue.TextColor3 = Colors.Accent
                DropdownValue.Font = Window.Font
                DropdownValue.TextSize = Window.FontSize
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
                DropdownValue.TextTruncate = Enum.TextTruncate.AtEnd
                DropdownValue.ZIndex = 6
                DropdownValue.Parent = DropdownButton
                
                table.insert(Window.AccentElements, {Type = "Text", Element = DropdownValue})

                local DropdownArrow = CreateIcon("chevron-down", DropdownButton)
                if DropdownArrow then
                    DropdownArrow.Size = UDim2.new(0, 14, 0, 14)
                    DropdownArrow.Position = UDim2.new(1, -22, 0.5, -7)
                    DropdownArrow.ImageColor3 = Colors.TextDark
                    DropdownArrow.ZIndex = 6
                end

                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Position = UDim2.new(0, 0, 0, 30)
                DropdownList.BackgroundColor3 = Colors.BackgroundDarker
                DropdownList.BorderSizePixel = 0
                DropdownList.Visible = false
                DropdownList.ZIndex = 50
                DropdownList.ClipsDescendants = true
                DropdownList.Parent = DropdownFrame

                AddCorner(DropdownList, 6)
                local ListStroke = AddStroke(DropdownList, Colors.Accent, 1)
                ListStroke.ZIndex = 50
                table.insert(Window.AccentElements, {Type = "Stroke", Element = ListStroke})

                local SearchBox
                local searchOffset = 0
                if searchable then
                    searchOffset = 32
                    local SearchContainer = Instance.new("Frame")
                    SearchContainer.Size = UDim2.new(1, 0, 0, 28)
                    SearchContainer.BackgroundTransparency = 1
                    SearchContainer.ZIndex = 50
                    SearchContainer.Parent = DropdownList

                    SearchBox = Instance.new("TextBox")
                    SearchBox.Size = UDim2.new(1, -8, 0, 22)
                    SearchBox.Position = UDim2.new(0, 4, 0, 3)
                    SearchBox.BackgroundColor3 = Colors.ElementBg
                    SearchBox.BorderSizePixel = 0
                    SearchBox.Text = ""
                    SearchBox.PlaceholderText = "Search..."
                    SearchBox.TextColor3 = Colors.Text
                    SearchBox.PlaceholderColor3 = Colors.TextMuted
                    SearchBox.Font = Window.Font
                    SearchBox.TextSize = Window.FontSize - 1
                    SearchBox.ClearTextOnFocus = false
                    SearchBox.ZIndex = 51
                    SearchBox.Parent = SearchContainer

                    AddCorner(SearchBox, 4)
                    AddStroke(SearchBox, Colors.Border, 1)
                    AddPadding(SearchBox, 6, 6, 0, 0)

                    local SearchDivider = Instance.new("Frame")
                    SearchDivider.Size = UDim2.new(1, -8, 0, 1)
                    SearchDivider.Position = UDim2.new(0, 4, 1, 0)
                    SearchDivider.BackgroundColor3 = Colors.Border
                    SearchDivider.BorderSizePixel = 0
                    SearchDivider.ZIndex = 50
                    SearchDivider.Parent = SearchContainer
                end

                local ListContainer = Instance.new("ScrollingFrame")
                ListContainer.Size = UDim2.new(1, 0, 1, -searchOffset)
                ListContainer.Position = UDim2.new(0, 0, 0, searchOffset)
                ListContainer.BackgroundTransparency = 1
                ListContainer.BorderSizePixel = 0
                ListContainer.ScrollBarThickness = 3
                ListContainer.ScrollBarImageColor3 = Colors.Accent
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
                ListContainer.ZIndex = 50
                ListContainer.Parent = DropdownList
                
                table.insert(Window.AccentElements, {Type = "ScrollBar", Element = ListContainer})

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = ListContainer

                AddPadding(ListContainer, 4, 4, 4, 4)

                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
                end)

                DropdownButton.MouseEnter:Connect(function()
                    if not MultiDropdown.Open then
                        Tween(DropdownButton, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                    end
                end)

                DropdownButton.MouseLeave:Connect(function()
                    if not MultiDropdown.Open then
                        Tween(DropdownButton, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                    end
                end)

                DropdownButton.MouseButton1Click:Connect(function()
                    MultiDropdown.Open = not MultiDropdown.Open
                    
                    if MultiDropdown.Open then
                        DropdownList.Visible = true
                        local height = math.min(#MultiDropdown.Items * 26 + 8 + searchOffset, 130 + searchOffset)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 28 + height + 4)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
                        if DropdownArrow then
                            Tween(DropdownArrow, {Rotation = 180}, 0.2)
                        end
                        DropdownStroke.Color = Colors.Accent
                        DropdownButton.BackgroundColor3 = Colors.ElementHover
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        if DropdownArrow then
                            Tween(DropdownArrow, {Rotation = 0}, 0.2)
                        end
                        DropdownStroke.Color = Colors.Border
                        DropdownButton.BackgroundColor3 = Colors.ElementBg
                        task.delay(0.2, function()
                            if not MultiDropdown.Open then
                                DropdownList.Visible = false
                                if SearchBox then SearchBox.Text = "" end
                            end
                        end)
                    end
                end)

                function MultiDropdown:Refresh(newItems)
                    for _, child in pairs(ListContainer:GetChildren()) do
                        if child:IsA("Frame") and child.Name == "MultiItem" then
                            child:Destroy()
                        end
                    end

                    MultiDropdown.Items = newItems or items

                    for _, item in pairs(MultiDropdown.Items) do
                        local ItemFrame = Instance.new("Frame")
                        ItemFrame.Name = "MultiItem"
                        ItemFrame.Size = UDim2.new(1, 0, 0, 24)
                        ItemFrame.BackgroundColor3 = Colors.ElementBg
                        ItemFrame.BorderSizePixel = 0
                        ItemFrame.ZIndex = 50
                        ItemFrame.Parent = ListContainer

                        AddCorner(ItemFrame, 4)
                        AddStroke(ItemFrame, Colors.Border, 1)

                        local ItemButton = Instance.new("TextButton")
                        ItemButton.Size = UDim2.new(1, 0, 1, 0)
                        ItemButton.BackgroundTransparency = 1
                        ItemButton.Text = ""
                        ItemButton.ZIndex = 51
                        ItemButton.Parent = ItemFrame

                        local ItemLabel = Instance.new("TextLabel")
                        ItemLabel.Size = UDim2.new(1, -30, 1, 0)
                        ItemLabel.Position = UDim2.new(0, 6, 0, 0)
                        ItemLabel.BackgroundTransparency = 1
                        ItemLabel.Text = item
                        ItemLabel.TextColor3 = Colors.Text
                        ItemLabel.Font = Window.Font
                        ItemLabel.TextSize = Window.FontSize
                        ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
                        ItemLabel.ZIndex = 51
                        ItemLabel.Parent = ItemFrame

                        local CheckBox = Instance.new("Frame")
                        CheckBox.Size = UDim2.new(0, 14, 0, 14)
                        CheckBox.Position = UDim2.new(1, -19, 0.5, -7)
                        CheckBox.BackgroundColor3 = Colors.BackgroundDarker
                        CheckBox.BorderSizePixel = 0
                        CheckBox.ZIndex = 51
                        CheckBox.Parent = ItemFrame

                        AddCorner(CheckBox, 3)
                        local CheckStroke = AddStroke(CheckBox, Colors.Border, 1)
                        CheckStroke.ZIndex = 51

                        local CheckIcon = CreateIcon("check", CheckBox)
                        if CheckIcon then
                            CheckIcon.Size = UDim2.new(0, 10, 0, 10)
                            CheckIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
                            CheckIcon.ImageColor3 = Colors.Text
                            CheckIcon.Visible = MultiDropdown.Values[item] or false
                            CheckIcon.ZIndex = 52
                        end

                        local function updateCheck()
                            if MultiDropdown.Values[item] then
                                CheckBox.BackgroundColor3 = Colors.Toggle
                                CheckStroke.Color = Colors.Toggle
                                if CheckIcon then CheckIcon.Visible = true end
                            else
                                CheckBox.BackgroundColor3 = Colors.BackgroundDarker
                                CheckStroke.Color = Colors.Border
                                if CheckIcon then CheckIcon.Visible = false end
                            end
                            DropdownValue.Text = getSelectedText()
                        end

                        updateCheck()

                        ItemButton.MouseButton1Click:Connect(function()
                            if MultiDropdown.Values[item] then
                                MultiDropdown.Values[item] = nil
                            else
                                MultiDropdown.Values[item] = true
                            end
                            updateCheck()
                            
                            if flag ~= "" then
                                ConfigSystem:SetValue(flag, MultiDropdown.Values)
                            end
                            
                            callback(MultiDropdown.Values)
                        end)

                        ItemButton.MouseEnter:Connect(function()
                            Tween(ItemFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                        end)

                        ItemButton.MouseLeave:Connect(function()
                            Tween(ItemFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                        end)
                    end
                end

                if SearchBox then
                    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local searchText = SearchBox.Text:lower()
                        for _, child in pairs(ListContainer:GetChildren()) do
                            if child:IsA("Frame") and child.Name == "MultiItem" then
                                local label = child:FindFirstChild("TextLabel")
                                if label then
                                    if searchText == "" or label.Text:lower():find(searchText) then
                                        child.Visible = true
                                    else
                                        child.Visible = false
                                    end
                                end
                            end
                        end
                    end)
                end

                function MultiDropdown:Set(values)
                    MultiDropdown.Values = values
                    MultiDropdown:Refresh()
                    DropdownValue.Text = getSelectedText()
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, values)
                    end
                    
                    callback(values)
                end

                function MultiDropdown:Get()
                    return MultiDropdown.Values
                end

                MultiDropdown:Refresh()
                return MultiDropdown
            end

            -- Continue in next message (colorpicker, keybind, textbox, label, paragraph)...

function Section:CreateColorpicker(options)
                options = options or {}
                local name = options.Name or "Color"
                local flag = options.Flag or ""
                local default = options.Default or Color3.fromRGB(255, 255, 255)
                local callback = options.Callback or function() end

                local Colorpicker = {}
                Colorpicker.Value = default
                Colorpicker.Flag = flag

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, default)
                    ConfigSystem:RegisterElement(flag, Colorpicker)
                end

                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, 0, 0, 28)
                ColorFrame.BackgroundColor3 = Colors.ElementBg
                ColorFrame.BorderSizePixel = 0
                ColorFrame.Parent = SectionContent

                AddCorner(ColorFrame, 6)
                AddStroke(ColorFrame, Colors.Border, 1)

                local ColorLabel = Instance.new("TextLabel")
                ColorLabel.Size = UDim2.new(1, -50, 1, 0)
                ColorLabel.Position = UDim2.new(0, 10, 0, 0)
                ColorLabel.BackgroundTransparency = 1
                ColorLabel.Text = name
                ColorLabel.TextColor3 = Colors.Text
                ColorLabel.Font = Window.Font
                ColorLabel.TextSize = Window.FontSize
                ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColorLabel.Parent = ColorFrame

                local ColorDisplayBg = Instance.new("Frame")
                ColorDisplayBg.Size = UDim2.new(0, 32, 0, 18)
                ColorDisplayBg.Position = UDim2.new(1, -42, 0.5, -9)
                ColorDisplayBg.BackgroundColor3 = Colors.BackgroundDarker
                ColorDisplayBg.BorderSizePixel = 0
                ColorDisplayBg.Parent = ColorFrame

                AddCorner(ColorDisplayBg, 4)
                AddStroke(ColorDisplayBg, Colors.Border, 1)

                local ColorDisplay = Instance.new("Frame")
                ColorDisplay.Size = UDim2.new(1, -6, 1, -6)
                ColorDisplay.Position = UDim2.new(0, 3, 0, 3)
                ColorDisplay.BackgroundColor3 = default
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.Parent = ColorDisplayBg

                AddCorner(ColorDisplay, 2)

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

                local PickerFrame = Instance.new("Frame")
                PickerFrame.Size = UDim2.new(0, 220, 0, 260)
                PickerFrame.BackgroundColor3 = Colors.Background
                PickerFrame.BorderSizePixel = 0
                PickerFrame.Visible = false
                PickerFrame.ZIndex = 100
                PickerFrame.Parent = ScreenGui

                AddCorner(PickerFrame, 8)
                AddStroke(PickerFrame, Colors.Accent, 2)

                local function updatePickerPosition()
                    local mainPos = Window.MainFrame.AbsolutePosition
                    local mainSize = Window.MainFrame.AbsoluteSize
                    PickerFrame.Position = UDim2.new(0, mainPos.X + mainSize.X + 10, 0, mainPos.Y)
                end

                local PickerHeader = Instance.new("Frame")
                PickerHeader.Size = UDim2.new(1, 0, 0, 28)
                PickerHeader.BackgroundColor3 = Colors.Header
                PickerHeader.BorderSizePixel = 0
                PickerHeader.ZIndex = 100
                PickerHeader.Parent = PickerFrame

                AddCorner(PickerHeader, 8)

                local PickerHeaderBottom = Instance.new("Frame")
                PickerHeaderBottom.Size = UDim2.new(1, 0, 0, 10)
                PickerHeaderBottom.Position = UDim2.new(0, 0, 1, -10)
                PickerHeaderBottom.BackgroundColor3 = Colors.Header
                PickerHeaderBottom.BorderSizePixel = 0
                PickerHeaderBottom.ZIndex = 100
                PickerHeaderBottom.Parent = PickerHeader

                local PickerTitle = Instance.new("TextLabel")
                PickerTitle.Size = UDim2.new(1, -20, 1, 0)
                PickerTitle.Position = UDim2.new(0, 10, 0, 0)
                PickerTitle.BackgroundTransparency = 1
                PickerTitle.Text = "COLOR PICKER"
                PickerTitle.TextColor3 = Colors.Accent
                PickerTitle.Font = Window.Font
                PickerTitle.TextSize = Window.FontSize
                PickerTitle.TextXAlignment = Enum.TextXAlignment.Left
                PickerTitle.ZIndex = 100
                PickerTitle.Parent = PickerHeader

                local PaletteFrame = Instance.new("Frame")
                PaletteFrame.Size = UDim2.new(1, -20, 0, 150)
                PaletteFrame.Position = UDim2.new(0, 10, 0, 38)
                PaletteFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                PaletteFrame.BorderSizePixel = 0
                PaletteFrame.ZIndex = 100
                PaletteFrame.Parent = PickerFrame

                AddCorner(PaletteFrame, 6)

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
                SaturationGradient.Parent = SaturationOverlay

                AddCorner(SaturationOverlay, 6)

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

                AddCorner(BrightnessOverlay, 6)

                local Selector = Instance.new("Frame")
                Selector.Size = UDim2.new(0, 12, 0, 12)
                Selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Selector.BorderSizePixel = 0
                Selector.ZIndex = 103
                Selector.Parent = PaletteFrame

                AddCorner(Selector, 6)
                AddStroke(Selector, Color3.fromRGB(0, 0, 0), 2)

                local HueSlider = Instance.new("Frame")
                HueSlider.Size = UDim2.new(1, -20, 0, 16)
                HueSlider.Position = UDim2.new(0, 10, 0, 196)
                HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSlider.BorderSizePixel = 0
                HueSlider.ZIndex = 100
                HueSlider.Parent = PickerFrame

                AddCorner(HueSlider, 4)

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
                HueSelector.Size = UDim2.new(0, 6, 1, 4)
                HueSelector.Position = UDim2.new(0, -3, 0, -2)
                HueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSelector.BorderSizePixel = 0
                HueSelector.ZIndex = 101
                HueSelector.Parent = HueSlider

                AddCorner(HueSelector, 3)
                AddStroke(HueSelector, Color3.fromRGB(0, 0, 0), 1)

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
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, color)
                    end
                    
                    callback(color)
                end

                local function updatePalette()
                    PaletteFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                end

                HueSelector.Position = UDim2.new(h, -3, 0, -2)
                Selector.Position = UDim2.new(s, -6, 1 - v, -6)
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
                        Selector.Position = UDim2.new(relX, -6, relY, -6)
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
                        Selector.Position = UDim2.new(relX, -6, relY, -6)
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
                    local mouse = UserInputService:GetMouseLocation()
                    local percent = math.clamp((mouse.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    h = percent
                    HueSelector.Position = UDim2.new(percent, -3, 0, -2)
                    updatePalette()
                    updateColor()
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueSelecting = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if hueSelecting and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouse = UserInputService:GetMouseLocation()
                        local percent = math.clamp((mouse.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                        h = percent
                        HueSelector.Position = UDim2.new(percent, -3, 0, -2)
                        updatePalette()
                        updateColor()
                    end
                end)

                local ClosePickerButton = Instance.new("TextButton")
                ClosePickerButton.Size = UDim2.new(1, -20, 0, 28)
                ClosePickerButton.Position = UDim2.new(0, 10, 1, -38)
                ClosePickerButton.BackgroundColor3 = Colors.Accent
                ClosePickerButton.BorderSizePixel = 0
                ClosePickerButton.Text = "CLOSE"
                ClosePickerButton.TextColor3 = Colors.Text
                ClosePickerButton.Font = Window.Font
                ClosePickerButton.TextSize = Window.FontSize
                ClosePickerButton.ZIndex = 100
                ClosePickerButton.AutoButtonColor = false
                ClosePickerButton.Parent = PickerFrame

                AddCorner(ClosePickerButton, 6)

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
                    HueSelector.Position = UDim2.new(h, -3, 0, -2)
                    Selector.Position = UDim2.new(s, -6, 1 - v, -6)
                    updatePalette()
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, color)
                    end
                    
                    callback(color)
                end

                function Colorpicker:Get()
                    return Colorpicker.Value
                end

                return Colorpicker
            end

            function Section:CreateKeybind(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local flag = options.Flag or ""
                local default = options.Default
                local callback = options.Callback or function() end

                local Keybind = {}
                Keybind.Value = default
                Keybind.Flag = flag

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, default)
                    ConfigSystem:RegisterElement(flag, Keybind)
                end

                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Size = UDim2.new(1, 0, 0, 28)
                KeybindFrame.BackgroundColor3 = Colors.ElementBg
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.Parent = SectionContent

                AddCorner(KeybindFrame, 6)
                AddStroke(KeybindFrame, Colors.Border, 1)

                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Size = UDim2.new(1, -70, 1, 0)
                KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Text = name
                KeybindLabel.TextColor3 = Colors.Text
                KeybindLabel.Font = Window.Font
                KeybindLabel.TextSize = Window.FontSize
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.Parent = KeybindFrame

                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Size = UDim2.new(0, 55, 0, 18)
                KeybindButton.Position = UDim2.new(1, -65, 0.5, -9)
                KeybindButton.BackgroundColor3 = Colors.BackgroundDarker
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Text = typeof(default) == 'string' and 'None' or default.Name
                KeybindButton.TextColor3 = Colors.Accent
                KeybindButton.Font = Window.Font
                KeybindButton.TextSize = Window.FontSize - 1
                KeybindButton.AutoButtonColor = false
                KeybindButton.Parent = KeybindFrame
                
                table.insert(Window.AccentElements, {Type = "Text", Element = KeybindButton})

                AddCorner(KeybindButton, 4)
                local KeyStroke = AddStroke(KeybindButton, Colors.Border, 1)

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
                    KeybindFrame.BackgroundColor3 = Colors.ElementHover
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                Keybind.Value = 'None'
                                KeybindButton.Text = "None"
                            elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                                Keybind.Value = input.KeyCode
                                KeybindButton.Text = input.KeyCode.Name
                                
                                if flag ~= "" then
                                    ConfigSystem:SetValue(flag, input.KeyCode)
                                end
                            end
                            KeyStroke.Color = Colors.Border
                            KeybindFrame.BackgroundColor3 = Colors.ElementBg
                            listening = false
                        end
                    elseif not gameProcessed and input.KeyCode == Keybind.Value then
                        callback()
                    end
                end)

                function Keybind:Set(key)
                    if typeof(key) == "EnumItem" then
                        Keybind.Value = key
                        KeybindButton.Text = typeof(key) == 'string' and "None" or key.Name
                        
                        if flag ~= "" then
                            ConfigSystem:SetValue(flag, key)
                        end
                    end
                end

                function Keybind:Get()
                    return Keybind.Value
                end

                return Keybind
            end

            function Section:CreateTextbox(options)
                options = options or {}
                local name = options.Name or "Textbox"
                local flag = options.Flag or ""
                local default = options.Default or ""
                local placeholder = options.Placeholder or "Enter text..."
                local callback = options.Callback or function() end

                local Textbox = {}
                Textbox.Value = default
                Textbox.Flag = flag

                if flag ~= "" then
                    ConfigSystem:SetValue(flag, default)
                    ConfigSystem:RegisterElement(flag, Textbox)
                end

                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Size = UDim2.new(1, 0, 0, 28)
                TextboxFrame.BackgroundColor3 = Colors.ElementBg
                TextboxFrame.BorderSizePixel = 0
                TextboxFrame.Parent = SectionContent

                AddCorner(TextboxFrame, 6)
                AddStroke(TextboxFrame, Colors.Border, 1)

                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Size = UDim2.new(0.4, 0, 1, 0)
                TextboxLabel.Position = UDim2.new(0, 10, 0, 0)
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Text = name
                TextboxLabel.TextColor3 = Colors.Text
                TextboxLabel.Font = Window.Font
                TextboxLabel.TextSize = Window.FontSize
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextboxLabel.Parent = TextboxFrame

                local TextboxInput = Instance.new("TextBox")
                TextboxInput.Size = UDim2.new(0.55, -10, 0, 18)
                TextboxInput.Position = UDim2.new(0.45, 0, 0.5, -9)
                TextboxInput.BackgroundColor3 = Colors.BackgroundDarker
                TextboxInput.BorderSizePixel = 0
                TextboxInput.Text = default
                TextboxInput.PlaceholderText = placeholder
                TextboxInput.TextColor3 = Colors.Text
                TextboxInput.PlaceholderColor3 = Colors.TextMuted
                TextboxInput.Font = Window.Font
                TextboxInput.TextSize = Window.FontSize
                TextboxInput.ClearTextOnFocus = false
                TextboxInput.Parent = TextboxFrame

                AddCorner(TextboxInput, 4)
                local InputStroke = AddStroke(TextboxInput, Colors.Border, 1)
                AddPadding(TextboxInput, 6, 6, 0, 0)

                TextboxFrame.MouseEnter:Connect(function()
                    Tween(TextboxFrame, {BackgroundColor3 = Colors.ElementHover}, 0.1)
                end)

                TextboxFrame.MouseLeave:Connect(function()
                    Tween(TextboxFrame, {BackgroundColor3 = Colors.ElementBg}, 0.1)
                end)

                TextboxInput.Focused:Connect(function()
                    InputStroke.Color = Colors.Accent
                end)

                TextboxInput.FocusLost:Connect(function(enterPressed)
                    InputStroke.Color = Colors.Border
                    Textbox.Value = TextboxInput.Text
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, TextboxInput.Text)
                    end
                    
                    callback(TextboxInput.Text, enterPressed)
                end)

                function Textbox:Set(value)
                    Textbox.Value = value
                    TextboxInput.Text = value
                    
                    if flag ~= "" then
                        ConfigSystem:SetValue(flag, value)
                    end
                    
                    callback(value, false)
                end

                function Textbox:Get()
                    return Textbox.Value
                end

                return Textbox
            end

            function Section:CreateLabel(text)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, 0, 0, 22)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = SectionContent

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text or "Label"
                Label.TextColor3 = Colors.TextMuted
                Label.Font = Window.Font
                Label.TextSize = Window.FontSize
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = LabelFrame

                local LabelObj = {}
                
                function LabelObj:Set(newText)
                    Label.Text = newText
                end

                return LabelObj
            end

            function Section:CreateParagraph(options)
                options = options or {}
                local title = options.Title or "Title"
                local content = options.Content or "Content"

                local ParagraphFrame = Instance.new("Frame")
                ParagraphFrame.Size = UDim2.new(1, 0, 0, 0)
                ParagraphFrame.AutomaticSize = Enum.AutomaticSize.Y
                ParagraphFrame.BackgroundColor3 = Colors.BackgroundDarker
                ParagraphFrame.BorderSizePixel = 0
                ParagraphFrame.Parent = SectionContent

                AddCorner(ParagraphFrame, 6)
                AddStroke(ParagraphFrame, Colors.Border, 1)

                local ParagraphLayout = Instance.new("UIListLayout")
                ParagraphLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ParagraphLayout.Padding = UDim.new(0, 4)
                ParagraphLayout.Parent = ParagraphFrame

                AddPadding(ParagraphFrame, 10, 10, 8, 8)

                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(1, 0, 0, 0)
                TitleLabel.AutomaticSize = Enum.AutomaticSize.Y
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Text = title
                TitleLabel.TextColor3 = Colors.Accent
                TitleLabel.Font = Window.Font
                TitleLabel.TextSize = Window.FontSize + 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.TextWrapped = true
                TitleLabel.LayoutOrder = 1
                TitleLabel.Parent = ParagraphFrame

                table.insert(Window.AccentElements, {Type = "Text", Element = TitleLabel})

                local ContentLabel = Instance.new("TextLabel")
                ContentLabel.Size = UDim2.new(1, 0, 0, 0)
                ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
                ContentLabel.BackgroundTransparency = 1
                ContentLabel.Text = content
                ContentLabel.TextColor3 = Colors.TextDark
                ContentLabel.Font = Window.Font
                ContentLabel.TextSize = Window.FontSize
                ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
                ContentLabel.TextWrapped = true
                ContentLabel.LayoutOrder = 2
                ContentLabel.Parent = ParagraphFrame

                local Paragraph = {}
                
                function Paragraph:Set(options)
                    if options.Title then
                        TitleLabel.Text = options.Title
                    end
                    if options.Content then
                        ContentLabel.Text = options.Content
                    end
                end

                return Paragraph
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
            Flag = "ui_accent_color",
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
            Flag = "ui_font",
            Items = fontNames,
            Default = "Roboto",
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
            Flag = "ui_font_size",
            Min = 10,
            Max = 18,
            Default = 14,
            Increment = 1,
            Suffix = "px",
            Callback = function(size)
                Window:UpdateFontSize(size)
            end
        })
        
        SettingsTab:AddDivider()
        
        local ConfigSection = SettingsTab:CreateSection("Configuration")
        
        local configSlotDropdown
        
        configSlotDropdown = ConfigSection:CreateDropdown({
            Name = "Config Slot",
            Items = ConfigSystem:GetConfigList(),
            Default = "Slot1",
            Callback = function(slot)
                ConfigSystem.CurrentSlot = slot
            end
        })
        
        ConfigSection:CreateTextbox({
            Name = "New Config",
            Placeholder = "Config name...",
            Callback = function(text, enterPressed)
                if enterPressed and text ~= "" then
                    ConfigSystem.CurrentSlot = text
                    local configs = ConfigSystem:GetConfigList()
                    if not table.find(configs, text) then
                        table.insert(configs, text)
                    end
                    configSlotDropdown:Refresh(configs)
                    configSlotDropdown:Set(text)
                end
            end
        })
        
        ConfigSection:AddDivider()
        
        ConfigSection:CreateButton({
            Name = "Save Config",
            Icon = "save",
            Callback = function()
                if Window:SaveConfig() then
                    Library:Notify({
                        Title = "Config Saved",
                        Description = "Configuration saved successfully!",
                        Type = "success",
                        Duration = 3
                    })
                end
            end
        })
        
        ConfigSection:CreateButton({
            Name = "Load Config",
            Icon = "folder-open",
            Callback = function()
                if Window:LoadConfig() then
                    Library:Notify({
                        Title = "Config Loaded",
                        Description = "Configuration loaded successfully!",
                        Type = "success",
                        Duration = 3
                    })
                else
                    Library:Notify({
                        Title = "Load Failed",
                        Description = "Could not load configuration",
                        Type = "error",
                        Duration = 3
                    })
                end
            end
        })
        
        ConfigSection:CreateButton({
            Name = "Delete Config",
            Icon = "trash-2",
            Callback = function()
                if Window:DeleteConfig(ConfigSystem.CurrentSlot) then
                    Library:Notify({
                        Title = "Config Deleted",
                        Description = "Configuration deleted!",
                        Type = "warning",
                        Duration = 3
                    })
                    configSlotDropdown:Refresh(ConfigSystem:GetConfigList())
                end
            end
        })
        
        SettingsTab:AddDivider()
        
        local MiscSection = SettingsTab:CreateSection("Miscellaneous")
        
        MiscSection:CreateKeybind({
            Name = "Toggle UI",
            Flag = "ui_toggle_key",
            Default = Enum.KeyCode.RightShift,
            Callback = function()
                ScreenGui.Enabled = not ScreenGui.Enabled
            end
        })
        
        MiscSection:AddDivider()
        
        MiscSection:CreateButton({
            Name = "Unload",
            Icon = "power",
            Callback = function()
                ScreenGui:Destroy()
            end
        })
        
        return SettingsTab
    end

    return Window
end

return Library

