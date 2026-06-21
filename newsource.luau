--========================================================--
-- AppleUI-Gen3 (Custom UI Library)
-- Core Library, Theme, Utilities, Icon Resolver
--========================================================--

local library = {}

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================--
-- THEME
--========================================================--

library.theme = {
    Background = Color3.fromRGB(22, 22, 22),
    Sidebar = Color3.fromRGB(18, 18, 18),
    Accent = Color3.fromRGB(0, 122, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(60, 60, 60),
    Corner = 8,
    Font = Enum.Font.GothamSemibold
}

--========================================================--
-- UTILITY: CREATE INSTANCE
--========================================================--

function library:New(class, props)
    local obj = Instance.new(class)

    for k, v in pairs(props) do
        obj[k] = v
    end

    return obj
end

--========================================================--
-- UTILITY: APPLY CORNER
--========================================================--

function library:Corner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or library.theme.Corner)
    return c
end

--========================================================--
-- UTILITY: APPLY STROKE
--========================================================--

function library:Stroke(color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or library.theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

--========================================================--
-- UTILITY: TWEEN
--========================================================--

function library:Tween(obj, info, props)
    TweenService:Create(obj, TweenInfo.new(info.Time or info, info.Style or Enum.EasingStyle.Quad, info.Direction or Enum.EasingDirection.Out), props):Play()
end

--========================================================--
-- ICON SYSTEM (Lucide‑style)
--========================================================--

-- Minimal embedded icon pack (you can expand later)
local LucideIcons = {
    ["search"] = "rbxassetid://3926305904", -- placeholder
    ["x"] = "rbxassetid://3926307971",
    ["check"] = "rbxassetid://3926305904",
    ["menu"] = "rbxassetid://3926307971",
    ["more"] = "rbxassetid://3926305904",
}

function library:GetIcon(name)
    return LucideIcons[name] or LucideIcons["menu"]
end

--========================================================--
-- UNIVERSAL ELEMENT API (BASE)
--========================================================--

library.ElementAPI = {}

function library.ElementAPI:SetText(obj, text)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.Text = text
    end
end

function library.ElementAPI:SetImage(obj, id)
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        obj.Image = id
    end
end

--========================================================--
-- ROOT GUI
--========================================================--

library.Root = library:New("ScreenGui", {
    Name = "AppleUI_Gen3",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Global
})

library.Root.Parent = PlayerGui


--========================================================--
-- WINDOW SYSTEM
--========================================================--

library.Windows = {}

function library:CreateWindow(title)
    title = title or "AppleUI Window"

    -- MAIN WINDOW FRAME
    local Window = self:New("Frame", {
        Name = title,
        Parent = self.Root,
        BackgroundColor3 = self.theme.Background,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    self:Corner(self.theme.Corner).Parent = Window
    self:Stroke(self.theme.Stroke, 1).Parent = Window

    -- TITLE BAR
    local TitleBar = self:New("Frame", {
        Name = "TitleBar",
        Parent = Window,
        BackgroundColor3 = self.theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 36),
        BorderSizePixel = 0
    })

    self:Corner(self.theme.Corner).Parent = TitleBar
    self:Stroke(self.theme.Stroke, 1).Parent = TitleBar

    -- TITLE TEXT
    local TitleLabel = self:New("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = self.theme.Font,
        Text = title,
        TextColor3 = self.theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- BUTTONS (Close, Minimize, Green)
    local ButtonHolder = self:New("Frame", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -95, 0, 0)
    })

    local function CreateTitleButton(name, color)
        local b = library:New("TextButton", {
            Parent = ButtonHolder,
            BackgroundColor3 = color,
            Size = UDim2.new(0, 20, 0, 20),
            Text = "",
            BorderSizePixel = 0
        })
        library:Corner(10).Parent = b
        return b
    end

    local CloseBtn = CreateTitleButton("Close", Color3.fromRGB(255, 95, 86))
    CloseBtn.Position = UDim2.new(0, 0, 0.5, -10)

    local MinBtn = CreateTitleButton("Minimize", Color3.fromRGB(255, 189, 46))
    MinBtn.Position = UDim2.new(0, 25, 0.5, -10)

    local GreenBtn = CreateTitleButton("Green", Color3.fromRGB(39, 201, 63))
    GreenBtn.Position = UDim2.new(0, 50, 0.5, -10)

    --========================================================--
    -- DRAGGING LOGIC
    --========================================================--

    local dragging = false
    local dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    --========================================================--
    -- BUTTON CALLBACKS
    --========================================================--

    CloseBtn.MouseButton1Click:Connect(function()
        Window.Visible = false
    end)

    MinBtn.MouseButton1Click:Connect(function()
        library:Tween(Window, 0.25, { Size = UDim2.new(0, 600, 0, 36) })
    end)

    GreenBtn.MouseButton1Click:Connect(function()
        if library.GreenCallback then
            library.GreenCallback(Window)
        end
    end)

    --========================================================--
    -- WINDOW API
    --========================================================--

    local api = {}

    function api:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end

    function api:Show()
        Window.Visible = true
    end

    function api:Hide()
        Window.Visible = false
    end

    function api:GetFrame()
        return Window
    end

    library.Windows[title] = api
    return api
end

--========================================================--
-- SECTION SYSTEM (Sidebar + Workareas)
--========================================================--

library.Sections = {}

function library:AttachSections(windowApi)
    local Window = windowApi:GetFrame()

    -- SIDEBAR
    local Sidebar = self:New("Frame", {
        Name = "Sidebar",
        Parent = Window,
        BackgroundColor3 = self.theme.Sidebar,
        Size = UDim2.new(0, 160, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BorderSizePixel = 0
    })

    self:Stroke(self.theme.Stroke, 1).Parent = Sidebar

    local SidebarList = self:New("UIListLayout", {
        Parent = Sidebar,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    -- WORKAREA
    local WorkArea = self:New("Frame", {
        Name = "WorkArea",
        Parent = Window,
        BackgroundColor3 = self.theme.Background,
        Size = UDim2.new(1, -170, 1, -46),
        Position = UDim2.new(0, 170, 0, 46),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    self:Stroke(self.theme.Stroke, 1).Parent = WorkArea

    local WorkAreaContainer = self:New("Folder", {
        Name = "SectionsContainer",
        Parent = WorkArea
    })

    -- SECTION API
    local sectionApi = {}

    function sectionApi:CreateSection(name)
        name = name or "Section"

        -- SIDEBAR BUTTON
        local Button = library:New("TextButton", {
            Parent = Sidebar,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Size = UDim2.new(1, -10, 0, 28),
            Position = UDim2.new(0, 5, 0, 0),
            Font = library.theme.Font,
            Text = name,
            TextColor3 = library.theme.Text,
            TextSize = 14,
            BorderSizePixel = 0
        })

        library:Corner(6).Parent = Button

        -- WORKAREA FRAME
        local SectionFrame = library:New("Frame", {
            Name = name,
            Parent = WorkAreaContainer,
            BackgroundColor3 = library.theme.Background,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            Visible = false
        })

        local SectionLayout = library:New("UIListLayout", {
            Parent = SectionFrame,
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })

        local api = {}

        function api:GetFrame()
            return SectionFrame
        end

        function api:AddDivider(text)
            local Divider = library:New("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 5, 0, 0),
                Font = library.theme.Font,
                Text = text or "",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return Divider
        end

        function api:Show()
            for _, child in ipairs(WorkAreaContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.Visible = false
                end
            end
            SectionFrame.Visible = true
        end

        -- SIDEBAR BUTTON BEHAVIOR
        Button.MouseButton1Click:Connect(function()
            api:Show()
        end)

        library.Sections[name] = api
        return api
    end

    function sectionApi:GetWorkArea()
        return WorkArea
    end

    windowApi.Sections = sectionApi
    return sectionApi
end

--========================================================--
-- NOTIFICATION SYSTEM
--========================================================--

library.Notifications = {}
library.NotificationIndex = 0

-- Holder GUI
library.NotificationHolder = library:New("Frame", {
    Name = "NotificationHolder",
    Parent = library.Root,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    ZIndex = 999999
})

local function CreateBaseNotification(height)
    library.NotificationIndex += 1

    local Frame = library:New("Frame", {
        Parent = library.NotificationHolder,
        BackgroundColor3 = library.theme.Sidebar,
        Size = UDim2.new(0, 300, 0, height),
        Position = UDim2.new(1, 310, 1, -(library.NotificationIndex * (height + 10))),
        BorderSizePixel = 0,
        ZIndex = 999999
    })

    library:Corner(8).Parent = Frame
    library:Stroke(library.theme.Stroke, 1).Parent = Frame

    return Frame
end

--========================================================--
-- TEMP NOTIFY (auto disappear)
--========================================================--

function library:TempNotify(text, duration)
    duration = duration or 3

    local Frame = CreateBaseNotification(40)

    local Label = library:New("TextLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 999999
    })

    -- Slide in
    library:Tween(Frame, 0.25, { Position = UDim2.new(1, -310, Frame.Position.Y.Scale, Frame.Position.Y.Offset) })

    task.delay(duration, function()
        -- Slide out
        library:Tween(Frame, 0.25, { Position = UDim2.new(1, 310, Frame.Position.Y.Scale, Frame.Position.Y.Offset) })
        task.wait(0.3)
        Frame:Destroy()
    end)
end

--========================================================--
-- NOTIFY (manual close)
--========================================================--

function library:Notify(text)
    local Frame = CreateBaseNotification(50)

    local Label = library:New("TextLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 999999
    })

    local Close = library:New("TextButton", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        Text = "×",
        Font = library.theme.Font,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 18,
        ZIndex = 999999
    })

    library:Tween(Frame, 0.25, { Position = UDim2.new(1, -310, Frame.Position.Y.Scale, Frame.Position.Y.Offset) })

    Close.MouseButton1Click:Connect(function()
        library:Tween(Frame, 0.25, { Position = UDim2.new(1, 310, Frame.Position.Y.Scale, Frame.Position.Y.Offset) })
        task.wait(0.3)
        Frame:Destroy()
    end)
end

--========================================================--
-- NOTIFY2 (title + description + icon)
--========================================================--

function library:Notify2(title, desc, icon)
    local Frame = CreateBaseNotification(70)

    local Icon = library:New("ImageLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0, 10),
        Image = icon or library:GetIcon("more"),
        ZIndex = 999999
    })

    local Title = library:New("TextLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 40, 0, 5),
        Font = library.theme.Font,
        Text = title,
        TextColor3 = library.theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 999999
    })

    local Desc = library:New("TextLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 40, 0, 28),
        Font = library.theme.Font,
        Text = desc,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 999999
    })

    library:Tween(Frame, 0.25, { Position = UDim2.new(1, -310, Frame.Position.Y.Scale, Frame.Position.Y.Offset) })

    task.delay(5, function()
        library:Tween(Frame, 0.25, { Position = UDim2.new(1, 310, Frame.Position.Y.Scale, Frame.Position.Y.Offset) })
        task.wait(0.3)
        Frame:Destroy()
    end)
end

--========================================================--
-- GREEN BUTTON CALLBACK SYSTEM
--========================================================--

-- The user can assign a function:
-- library:SetGreenButton(function(window) ... end)

library.GreenCallback = nil

function library:SetGreenButton(callback)
    if typeof(callback) == "function" then
        library.GreenCallback = callback
    else
        warn("[AppleUI] GreenButton callback must be a function")
    end
end

-- Internal use:
-- The window system already calls:
-- if library.GreenCallback then library.GreenCallback(Window) end
-- when the green button is clicked.

--========================================================--
-- SPOTLIGHT SEARCH SYSTEM
--========================================================--

library.Spotlight = {
    Enabled = false,
    Items = {}, -- { name = "Button1", callback = function() end }
    Keybind = Enum.KeyCode.LeftControl
}

-- MAIN OVERLAY
local SpotlightFrame = library:New("Frame", {
    Parent = library.Root,
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.4,
    Size = UDim2.new(1, 0, 1, 0),
    Visible = false,
    ZIndex = 999998
})

local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = game:GetService("Lighting")

-- SEARCH BOX
local SearchBox = library:New("TextBox", {
    Parent = SpotlightFrame,
    BackgroundColor3 = library.theme.Sidebar,
    Size = UDim2.new(0, 400, 0, 40),
    Position = UDim2.new(0.5, -200, 0.3, 0),
    Font = library.theme.Font,
    Text = "",
    PlaceholderText = "Search...",
    TextColor3 = library.theme.Text,
    TextSize = 16,
    BorderSizePixel = 0,
    ZIndex = 999999
})

library:Corner(8).Parent = SearchBox
library:Stroke(library.theme.Stroke, 1).Parent = SearchBox

-- RESULTS LIST
local Results = library:New("Frame", {
    Parent = SpotlightFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 400, 0, 200),
    Position = UDim2.new(0.5, -200, 0.3, 50),
    ZIndex = 999999
})

local ResultsList = library:New("UIListLayout", {
    Parent = Results,
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4)
})

--========================================================--
-- INTERNAL: UPDATE RESULTS
--========================================================--

local function UpdateResults(query)
    for _, child in ipairs(Results:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    if query == "" then return end

    for _, item in ipairs(library.Spotlight.Items) do
        if string.find(string.lower(item.name), string.lower(query)) then
            local Result = library:New("TextButton", {
                Parent = Results,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Size = UDim2.new(1, 0, 0, 28),
                Font = library.theme.Font,
                Text = item.name,
                TextColor3 = library.theme.Text,
                TextSize = 14,
                BorderSizePixel = 0,
                ZIndex = 999999
            })

            library:Corner(6).Parent = Result

            Result.MouseButton1Click:Connect(function()
                SpotlightFrame.Visible = false
                Blur.Size = 0
                item.callback()
            end)
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateResults(SearchBox.Text)
end)

--========================================================--
-- TOGGLE SPOTLIGHT
--========================================================--

local function ToggleSpotlight()
    library.Spotlight.Enabled = not library.Spotlight.Enabled

    if library.Spotlight.Enabled then
        SpotlightFrame.Visible = true
        SearchBox.Text = ""
        UpdateResults("")
        library:Tween(Blur, 0.2, { Size = 12 })
    else
        library:Tween(Blur, 0.2, { Size = 0 })
        task.wait(0.2)
        SpotlightFrame.Visible = false
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == library.Spotlight.Keybind then
        ToggleSpotlight()
    end
end)

--========================================================--
-- SPOTLIGHT API
--========================================================--

function library.Spotlight:AddItem(name, callback)
    table.insert(library.Spotlight.Items, {
        name = name,
        callback = callback
    })
end

function library.Spotlight:SetKeybind(key)
    library.Spotlight.Keybind = key
end

--========================================================--
-- CONTEXT MENU SYSTEM (Right‑Click Menu)
--========================================================--

library.ContextMenu = {
    Active = false,
    MenuFrame = nil
}

-- INTERNAL: CLOSE MENU
local function CloseContextMenu()
    if library.ContextMenu.MenuFrame then
        library:Tween(library.ContextMenu.MenuFrame, 0.15, { BackgroundTransparency = 1 })
        task.wait(0.15)
        library.ContextMenu.MenuFrame:Destroy()
        library.ContextMenu.MenuFrame = nil
    end
    library.ContextMenu.Active = false
end

--========================================================--
-- CREATE CONTEXT MENU
--========================================================--

function library:OpenContextMenu(options, position)
    -- options = { {text="Copy", callback=function() end}, ... }

    if library.ContextMenu.Active then
        CloseContextMenu()
    end

    library.ContextMenu.Active = true

    local Menu = library:New("Frame", {
        Parent = library.Root,
        BackgroundColor3 = library.theme.Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 160, 0, (#options * 28) + 10),
        Position = UDim2.new(0, position.X, 0, position.Y),
        BorderSizePixel = 0,
        ZIndex = 999999
    })

    library:Corner(6).Parent = Menu
    library:Stroke(library.theme.Stroke, 1).Parent = Menu

    library.ContextMenu.MenuFrame = Menu

    local List = library:New("UIListLayout", {
        Parent = Menu,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    -- Fade in
    library:Tween(Menu, 0.15, { BackgroundTransparency = 0 })

    for _, opt in ipairs(options) do
        local Btn = library:New("TextButton", {
            Parent = Menu,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Size = UDim2.new(1, -10, 0, 26),
            Position = UDim2.new(0, 5, 0, 0),
            Font = library.theme.Font,
            Text = opt.text,
            TextColor3 = library.theme.Text,
            TextSize = 14,
            BorderSizePixel = 0,
            ZIndex = 999999
        })

        library:Corner(4).Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            CloseContextMenu()
            if opt.callback then
                opt.callback()
            end
        end)
    end
end

--========================================================--
-- RIGHT‑CLICK LISTENER
--========================================================--

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        local mousePos = UserInputService:GetMouseLocation()

        library:OpenContextMenu({
            { text = "No actions", callback = function() end }
        }, mousePos)
    end
end)

-- Close menu when clicking anywhere else
UserInputService.InputBegan:Connect(function(input)
    if library.ContextMenu.Active and input.UserInputType == Enum.UserInputType.MouseButton1 then
        CloseContextMenu()
    end
end)

--========================================================--
-- SHADOW ENGINE (macOS‑style soft shadows)
--========================================================--

library.Shadows = {}

function library:ApplyShadow(parent, size)
    size = size or 12

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = parent
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217" -- soft blur shadow
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.45
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = parent.ZIndex - 1

    Shadow.Size = UDim2.new(1, size, 1, size)
    Shadow.Position = UDim2.new(0, -size/2, 0, -size/2)

    return Shadow
end

--========================================================--
-- VISIBILITY TOGGLE SYSTEM
--========================================================--

library.Visibility = {
    Keybind = Enum.KeyCode.RightControl,
    Hidden = false
}

function library.Visibility:Toggle()
    library.Visibility.Hidden = not library.Visibility.Hidden

    for _, windowApi in pairs(library.Windows) do
        local frame = windowApi:GetFrame()

        if library.Visibility.Hidden then
            -- Slide down + fade
            library:Tween(frame, 0.25, {
                Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset,
                                     frame.Position.Y.Scale, frame.Position.Y.Offset + 50),
                BackgroundTransparency = 1
            })
        else
            -- Slide up + fade in
            library:Tween(frame, 0.25, {
                Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset,
                                     frame.Position.Y.Scale, frame.Position.Y.Offset - 50),
                BackgroundTransparency = 0
            })
        end
    end
end

--========================================================--
-- KEYBIND LISTENER
--========================================================--

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == library.Visibility.Keybind then
        library.Visibility:Toggle()
    end
end)

function library.Visibility:SetKeybind(key)
    library.Visibility.Keybind = key
end

--========================================================--
-- EXPANDED UNIVERSAL ELEMENT API
--========================================================--

function library.ElementAPI:SetText(obj, text)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.Text = text
    end
end

function library.ElementAPI:SetImage(obj, id)
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        obj.Image = id
    end
end

function library.ElementAPI:SetVisible(obj, state)
    obj.Visible = state and true or false
end

function library.ElementAPI:SetColor(obj, color)
    if obj.BackgroundColor3 then
        obj.BackgroundColor3 = color
    end
    if obj.TextColor3 then
        obj.TextColor3 = color
    end
end

function library.ElementAPI:SetIcon(obj, iconName)
    local id = library:GetIcon(iconName)
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        obj.Image = id
    end
end

function library.ElementAPI:SetStroke(obj, color, thickness)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("UIStroke") then
            child.Color = color or child.Color
            child.Thickness = thickness or child.Thickness
            return
        end
    end

    -- If no stroke exists, create one
    library:Stroke(color, thickness).Parent = obj
end

function library.ElementAPI:SetCorner(obj, radius)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("UICorner") then
            child.CornerRadius = UDim.new(0, radius)
            return
        end
    end

    -- If no corner exists, create one
    library:Corner(radius).Parent = obj
end

function library.ElementAPI:SetSize(obj, x, y)
    obj.Size = UDim2.new(0, x, 0, y)
end

function library.ElementAPI:SetPosition(obj, x, y)
    obj.Position = UDim2.new(0, x, 0, y)
end

--========================================================--
-- ICON SYSTEM UPGRADE (Full Lucide Resolver)
--========================================================--

-- Lucide icon map (expandable)
-- You can add more icons here anytime.
library.Icons = {
    search = "rbxassetid://3926305904",
    x = "rbxassetid://3926307971",
    check = "rbxassetid://3926305904",
    menu = "rbxassetid://3926307971",
    more = "rbxassetid://3926305904",
    copy = "rbxassetid://3926307971",
    settings = "rbxassetid://3926305904",
    folder = "rbxassetid://3926307971",
    plus = "rbxassetid://3926305904",
    minus = "rbxassetid://3926307971",
    info = "rbxassetid://3926305904",
    alert = "rbxassetid://3926307971",
}

-- Cache for performance
library.IconCache = {}

function library:ResolveIcon(name)
    name = string.lower(name)

    -- Cached?
    if library.IconCache[name] then
        return library.IconCache[name]
    end

    -- Found?
    if library.Icons[name] then
        library.IconCache[name] = library.Icons[name]
        return library.Icons[name]
    end

    -- Fallback
    library.IconCache[name] = library.Icons["more"]
    return library.Icons["more"]
end

--========================================================--
-- AUTO‑INSERT ICON INTO ANY ELEMENT
--========================================================--

function library:InsertIcon(parent, iconName, size, color)
    local id = library:ResolveIcon(iconName)

    local Icon = library:New("ImageLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Image = id,
        Size = UDim2.new(0, size or 18, 0, size or 18),
        Position = UDim2.new(0, 8, 0.5, -((size or 18) / 2)),
        ImageColor3 = color or library.theme.Text,
        ZIndex = parent.ZIndex + 1
    })

    return Icon
end

--========================================================--
-- AUTO‑ALIGN TEXT WHEN ICON IS PRESENT
--========================================================--

function library:AlignTextWithIcon(textObj)
    if textObj:IsA("TextLabel") or textObj:IsA("TextButton") then
        textObj.Position = UDim2.new(0, 30, 0, 0)
        textObj.TextXAlignment = Enum.TextXAlignment.Left
    end
end

--========================================================--
-- BUTTON + ICON HELPER
--========================================================--

function library:CreateIconButton(parent, text, icon)
    local Btn = library:New("TextButton", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(1, -10, 0, 28),
        Position = UDim2.new(0, 5, 0, 0),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        BorderSizePixel = 0
    })

    library:Corner(6).Parent = Btn

    if icon then
        library:InsertIcon(Btn, icon, 16)
        library:AlignTextWithIcon(Btn)
    end

    return Btn
end

--========================================================--
-- END OF 10
--========================================================--

--========================================================--
-- SIDEBAR ICON SUPPORT + HIGHLIGHT ANIMATION
--========================================================--

library.Sidebar = {
    ActiveButton = nil
}

-- Highlight animation for sidebar buttons
local function HighlightButton(btn)
    if library.Sidebar.ActiveButton == btn then return end

    -- Reset previous
    if library.Sidebar.ActiveButton then
        library:Tween(library.Sidebar.ActiveButton, 0.15, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        })
    end

    library.Sidebar.ActiveButton = btn

    library:Tween(btn, 0.15, {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    })
end

-- Hover animation
local function Hover(btn)
    btn.MouseEnter:Connect(function()
        if library.Sidebar.ActiveButton ~= btn then
            library:Tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) })
        end
    end)

    btn.MouseLeave:Connect(function()
        if library.Sidebar.ActiveButton ~= btn then
            library:Tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) })
        end
    end)
end

--========================================================--
-- EXTEND SECTION CREATION TO SUPPORT ICONS
--========================================================--

function library.Sections:CreateSection(name, icon)
    name = name or "Section"

    local Sidebar = nil
    local WorkAreaContainer = nil

    -- Find sidebar + container
    for _, win in pairs(library.Windows) do
        local frame = win:GetFrame()
        Sidebar = frame:FindFirstChild("Sidebar")
        local WA = frame:FindFirstChild("WorkArea")
        if Sidebar and WA then
            WorkAreaContainer = WA:FindFirstChild("SectionsContainer")
            break
        end
    end

    if not Sidebar or not WorkAreaContainer then
        warn("[AppleUI] Cannot create section — sidebar not found")
        return
    end

    -- SIDEBAR BUTTON
    local Btn = library:New("TextButton", {
        Parent = Sidebar,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, 0),
        Font = library.theme.Font,
        Text = name,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        BorderSizePixel = 0
    })

    library:Corner(6).Parent = Btn
    Hover(Btn)

    -- ICON SUPPORT
    if icon then
        library:InsertIcon(Btn, icon, 16)
        library:AlignTextWithIcon(Btn)
    end

    -- WORKAREA FRAME
    local SectionFrame = library:New("Frame", {
        Parent = WorkAreaContainer,
        BackgroundColor3 = library.theme.Background,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        Visible = false
    })

    local Layout = library:New("UIListLayout", {
        Parent = SectionFrame,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    -- SECTION API
    local api = {}

    function api:GetFrame()
        return SectionFrame
    end

    function api:AddDivider(text)
        local Divider = library:New("TextLabel", {
            Parent = SectionFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 0),
            Font = library.theme.Font,
            Text = text or "",
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        return Divider
    end

    function api:Show()
        for _, child in ipairs(WorkAreaContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        SectionFrame.Visible = true
        HighlightButton(Btn)
    end

    -- BUTTON BEHAVIOR
    Btn.MouseButton1Click:Connect(function()
        api:Show()
    end)

    library.Sections[name] = api
    return api
end

--========================================================--
-- SECTION CONTENT ELEMENTS
--========================================================--

-- Every element is created inside a SectionFrame
-- using sectionApi:AddButton(), AddToggle(), AddSlider(), AddInput(), AddLabel()

--========================================================--
-- BUTTON
--========================================================--

function library.Sections:AddButton(sectionName, text, callback)
    local section = library.Sections[sectionName]
    if not section then return end

    local frame = section:GetFrame()

    local Btn = library:New("TextButton", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, 0),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        BorderSizePixel = 0
    })

    library:Corner(6).Parent = Btn
    library:Stroke(library.theme.Stroke, 1).Parent = Btn

    Btn.MouseEnter:Connect(function()
        library:Tween(Btn, 0.15, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) })
    end)

    Btn.MouseLeave:Connect(function()
        library:Tween(Btn, 0.15, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) })
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

--========================================================--
-- TOGGLE
--========================================================--

function library.Sections:AddToggle(sectionName, text, default, callback)
    local section = library.Sections[sectionName]
    if not section then return end

    local frame = section:GetFrame()

    local Holder = library:New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, 0)
    })

    local Label = library:New("TextLabel", {
        Parent = Holder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local ToggleBtn = library:New("Frame", {
        Parent = Holder,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BorderSizePixel = 0
    })

    library:Corner(10).Parent = ToggleBtn

    local Dot = library:New("Frame", {
        Parent = ToggleBtn,
        BackgroundColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BorderSizePixel = 0
    })

    library:Corner(8).Parent = Dot

    local state = default or false

    local function Update()
        if state then
            library:Tween(ToggleBtn, 0.15, { BackgroundColor3 = library.theme.Accent })
            library:Tween(Dot, 0.15, { Position = UDim2.new(1, -18, 0.5, -8) })
        else
            library:Tween(ToggleBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
            library:Tween(Dot, 0.15, { Position = UDim2.new(0, 2, 0.5, -8) })
        end
    end

    Update()

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            Update()
            if callback then callback(state) end
        end
    end)

    return ToggleBtn
end

--========================================================--
-- SLIDER
--========================================================--

function library.Sections:AddSlider(sectionName, text, min, max, default, callback)
    local section = library.Sections[sectionName]
    if not section then return end

    local frame = section:GetFrame()

    local Holder = library:New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 40),
        Position = UDim2.new(0, 5, 0, 0)
    })

    local Label = library:New("TextLabel", {
        Parent = Holder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Bar = library:New("Frame", {
        Parent = Holder,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 22),
        BorderSizePixel = 0
    })

    library:Corner(3).Parent = Bar

    local Fill = library:New("Frame", {
        Parent = Bar,
        BackgroundColor3 = library.theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0
    })

    library:Corner(3).Parent = Fill

    local value = default or min

    local function SetValue(v)
        v = math.clamp(v, min, max)
        value = v
        local pct = (v - min) / (max - min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        if callback then callback(v) end
    end

    SetValue(value)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local mouse = UserInputService:GetMouseLocation().X
                local rel = mouse - Bar.AbsolutePosition.X
                local pct = rel / Bar.AbsoluteSize.X
                SetValue(min + pct * (max - min))
            end)

            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)

    return Holder
end

--========================================================--
-- INPUT BOX
--========================================================--

function library.Sections:AddInput(sectionName, placeholder, callback)
    local section = library.Sections[sectionName]
    if not section then return end

    local frame = section:GetFrame()

    local Box = library:New("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, 0),
        Font = library.theme.Font,
        Text = "",
        PlaceholderText = placeholder or "",
        TextColor3 = library.theme.Text,
        TextSize = 14,
        BorderSizePixel = 0
    })

    library:Corner(6).Parent = Box
    library:Stroke(library.theme.Stroke, 1).Parent = Box

    Box.FocusLost:Connect(function()
        if callback then callback(Box.Text) end
    end)

    return Box
end

--========================================================--
-- LABEL
--========================================================--

function library.Sections:AddLabel(sectionName, text)
    local section = library.Sections[sectionName]
    if not section then return end

    local frame = section:GetFrame()

    local Label = library:New("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 0),
        Font = library.theme.Font,
        Text = text,
        TextColor3 = library.theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return Label
end

--========================================================--
-- WORKAREA LAYOUT ENGINE
--========================================================--

library.Layout = {}

-- Applies scrolling + padding + layout rules to a section frame
function library.Layout:Apply(sectionFrame)
    -- SCROLLING CONTAINER
    local Scroll = library:New("ScrollingFrame", {
        Parent = sectionFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    library:Stroke(library.theme.Stroke, 1).Parent = Scroll

    -- PADDING
    library:New("UIPadding", {
        Parent = Scroll,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    -- LAYOUT
    local Layout = library:New("UIListLayout", {
        Parent = Scroll,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    -- Replace original children into scroll area
    task.defer(function()
        for _, child in ipairs(sectionFrame:GetChildren()) do
            if child ~= Scroll then
                child.Parent = Scroll
            end
        end
    end)

    return Scroll
end

--========================================================--
-- AUTO‑APPLY LAYOUT TO ALL SECTIONS
--========================================================--

function library.Layout:ApplyToAll()
    for name, section in pairs(library.Sections) do
        local frame = section:GetFrame()
        if frame and not frame:FindFirstChildWhichIsA("ScrollingFrame") then
            library.Layout:Apply(frame)
        end
    end
end

--========================================================--
-- HOOK INTO SECTION CREATION
--========================================================--

local oldCreate = library.Sections.CreateSection

function library.Sections:CreateSection(name, icon)
    local api = oldCreate(self, name, icon)

    -- Apply layout after creation
    task.defer(function()
        local frame = api:GetFrame()
        library.Layout:Apply(frame)
    end)

    return api
end

--========================================================--
-- ANIMATION ENGINE (Quart, Spring, Ease Presets)
--========================================================--

library.Animations = {}

-- Default easing styles
library.Animations.Ease = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Quart = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

-- Spring-like animation (simulated using Back easing)
library.Animations.Spring = TweenInfo.new(
    0.35,
    Enum.EasingStyle.Back,
    Enum.EasingDirection.Out,
    0,      -- repeat
    false,  -- reverse
    0       -- delay
)

--========================================================--
-- UNIVERSAL ANIMATE FUNCTION
--========================================================--

function library:Animate(obj, preset, props)
    local info = library.Animations.Ease[preset] or preset or library.Animations.Ease.Smooth
    TweenService:Create(obj, info, props):Play()
end

--========================================================--
-- SPRING ANIMATION
--========================================================--

function library:Spring(obj, props)
    TweenService:Create(obj, library.Animations.Spring, props):Play()
end

--========================================================--
-- QUICK HELPERS
--========================================================--

function library:FadeIn(obj, duration)
    duration = duration or 0.25
    TweenService:Create(obj, TweenInfo.new(duration), { BackgroundTransparency = 0 }):Play()
end

function library:FadeOut(obj, duration)
    duration = duration or 0.25
    TweenService:Create(obj, TweenInfo.new(duration), { BackgroundTransparency = 1 }):Play()
end

function library:Pop(obj)
    obj.Size = obj.Size + UDim2.new(0, 4, 0, 4)
    library:Spring(obj, { Size = obj.Size - UDim2.new(0, 4, 0, 4) })
end

--========================================================--
-- WINDOW RESIZE SYSTEM (Green Button Maximize)
--========================================================--

library.Resize = {}

-- Stores original window size/position before maximizing
library.Resize.WindowState = {}

--========================================================--
-- MAXIMIZE / RESTORE LOGIC
--========================================================--

function library.Resize:Toggle(windowFrame)
    local state = library.Resize.WindowState[windowFrame]

    -- If no state saved → save original and maximize
    if not state then
        library.Resize.WindowState[windowFrame] = {
            Size = windowFrame.Size,
            Position = windowFrame.Position
        }

        library:Animate(windowFrame, "Quart", {
            Size = UDim2.new(0.9, 0, 0.85, 0),
            Position = UDim2.new(0.05, 0, 0.075, 0)
        })

        -- Call user callback if exists
        if library.GreenCallback then
            library.GreenCallback(windowFrame)
        end

    else
        -- Restore original
        library:Animate(windowFrame, "Quart", {
            Size = state.Size,
            Position = state.Position
        })

        library.Resize.WindowState[windowFrame] = nil
    end
end

--========================================================--
-- ATTACH TO GREEN BUTTON
--========================================================--

function library.Resize:Attach(windowFrame, greenButton)
    greenButton.MouseButton1Click:Connect(function()
        library.Resize:Toggle(windowFrame)
    end)
end

--========================================================--
-- HOOK INTO WINDOW CREATION
--========================================================--

local oldCreateWindow = library.CreateWindow

function library.CreateWindow(...)
    local api = oldCreateWindow(...)

    local frame = api:GetFrame()
    local green = frame:FindFirstChild("GreenButton")

    if green then
        library.Resize:Attach(frame, green)
    end

    return api
end

--========================================================--
-- SPLASH SCREEN SYSTEM (Animated Intro)
--========================================================--

library.Splash = {
    Enabled = true,
    Duration = 1.8,     -- how long before auto-hide
    FadeTime = 0.35     -- fade animation
}

function library.Splash:Show(titleText, subtitleText, icon)
    if not library.Splash.Enabled then return end

    -- MAIN SPLASH FRAME
    local Splash = library:New("Frame", {
        Parent = library.Root,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Size = UDim2.new(0, 260, 0, 120),
        Position = UDim2.new(0.5, -130, 0.5, -60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 999999
    })

    library:Corner(10).Parent = Splash
    library:ApplyShadow(Splash, 18)

    -- ICON (optional)
    if icon then
        local Icon = library:New("ImageLabel", {
            Parent = Splash,
            BackgroundTransparency = 1,
            Image = icon,
            Size = UDim2.new(0, 42, 0, 42),
            Position = UDim2.new(0.5, -21, 0, 12),
            ImageColor3 = library.theme.Text,
            ZIndex = 999999
        })
    end

    -- TITLE
    local Title = library:New("TextLabel", {
        Parent = Splash,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, icon and 60 or 30),
        Font = library.theme.Font,
        Text = titleText or "AppleUI",
        TextColor3 = library.theme.Text,
        TextSize = 20,
        ZIndex = 999999
    })

    -- SUBTITLE
    local Sub = library:New("TextLabel", {
        Parent = Splash,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, icon and 88 or 58),
        Font = library.theme.Font,
        Text = subtitleText or "Loading...",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 14,
        ZIndex = 999999
    })

    -- ANIMATE IN
    Splash.Position = UDim2.new(0.5, -130, 0.5, -80)
    library:Animate(Splash, "Quart", {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -130, 0.5, -60)
    })

    -- AUTO-HIDE
    task.delay(library.Splash.Duration, function()
        library:Animate(Splash, "Quart", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -130, 0.5, -40)
        })
        task.wait(library.Splash.FadeTime)
        Splash:Destroy()
    end)
end

--========================================================--
-- AUTO-SHOW SPLASH ON LIBRARY LOAD
--========================================================--

task.defer(function()
    library.Splash:Show("AppleUI Gen3", "Initializing...")
end)

--========================================================--
-- KEYBIND MANAGER (Global Hotkeys)
--========================================================--

library.Keybinds = {
    Registered = {},
    Debounce = {}
}

--========================================================--
-- REGISTER A NEW KEYBIND
--========================================================--

function library.Keybinds:Bind(key, callback)
    key = typeof(key) == "EnumItem" and key or Enum.KeyCode[key]

    if not key then
        warn("[AppleUI] Invalid keybind:", key)
        return
    end

    library.Keybinds.Registered[key] = callback
end

--========================================================--
-- UNBIND A KEY
--========================================================--

function library.Keybinds:Unbind(key)
    key = typeof(key) == "EnumItem" and key or Enum.KeyCode[key]
    library.Keybinds.Registered[key] = nil
end

--========================================================--
-- INPUT LISTENER
--========================================================--

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local key = input.KeyCode
    local callback = library.Keybinds.Registered[key]

    if callback then
        -- Debounce to prevent spam
        if library.Keybinds.Debounce[key] then return end
        library.Keybinds.Debounce[key] = true

        task.spawn(callback)

        task.delay(0.2, function()
            library.Keybinds.Debounce[key] = nil
        end)
    end
end)

--========================================================--
-- BUILT-IN DEFAULT HOTKEYS
--========================================================--

-- Toggle UI visibility (RightControl from Message 8)
library.Keybinds:Bind(library.Visibility.Keybind, function()
    library.Visibility:Toggle()
end)

-- Spotlight Search (Command+K style)
library.Keybinds:Bind(Enum.KeyCode.F, function()
    if library.Spotlight then
        library.Spotlight:Toggle()
    end
end)

--========================================================--
-- INTERNAL CLEANUP + OPTIMIZATION
--========================================================--

library.Optimize = {}

-- Track all created instances for cleanup
library.Optimize.Created = {}

--========================================================--
-- WRAP library:New TO TRACK INSTANCES
--========================================================--

local oldNew = library.New

function library:New(class, props)
    local obj = oldNew(self, class, props)
    table.insert(library.Optimize.Created, obj)
    return obj
end

--========================================================--
-- SAFE DESTROY
--========================================================--

function library.Optimize:SafeDestroy(obj)
    if obj and obj.Destroy then
        pcall(function()
            obj:Destroy()
        end)
    end
end

--========================================================--
-- CLEANUP UNUSED OBJECTS
--========================================================--

function library.Optimize:Cleanup()
    for i, obj in ipairs(library.Optimize.Created) do
        if obj == nil or obj.Parent == nil then
            library.Optimize.Created[i] = nil
        end
    end
end

--========================================================--
-- PERIODIC GC (every 10 seconds)
--========================================================--

task.spawn(function()
    while true do
        task.wait(10)
        library.Optimize:Cleanup()
    end
end)

--========================================================--
-- TWEEN OPTIMIZATION
--========================================================--

-- Prevent overlapping tweens on the same object
library.Optimize.ActiveTweens = {}

local oldTween = library.Tween

function library:Tween(obj, time, props)
    if library.Optimize.ActiveTweens[obj] then
        library.Optimize.ActiveTweens[obj]:Cancel()
    end

    local tween = TweenService:Create(obj, TweenInfo.new(time), props)
    library.Optimize.ActiveTweens[obj] = tween

    tween.Completed:Connect(function()
        if library.Optimize.ActiveTweens[obj] == tween then
            library.Optimize.ActiveTweens[obj] = nil
        end
    end)

    tween:Play()
    return tween
end

--========================================================--
-- MASS DESTROY (for unloading UI)
--========================================================--

function library.Optimize:DestroyAll()
    for _, obj in ipairs(library.Optimize.Created) do
        library.Optimize:SafeDestroy(obj)
    end
    library.Optimize.Created = {}
end

--========================================================--
-- FINAL INTEGRATION + PUBLIC API EXPORT
--========================================================--

-- Merge all subsystems into the main library table
library.API = {
    CreateWindow = library.CreateWindow,
    Sections = library.Sections,
    Notifications = library.Notifications,
    Spotlight = library.Spotlight,
    Visibility = library.Visibility,
    Resize = library.Resize,
    Animations = library.Animations,
    Utils = library.Utils,
    ElementAPI = library.ElementAPI,
    Layout = library.Layout,
    Keybinds = library.Keybinds,
    Optimize = library.Optimize
}

--========================================================--
-- INITIALIZATION ORDER
--========================================================--

function library:Initialize()
    -- Apply theme
    if library.theme and library.theme.Init then
        library.theme:Init()
    end

    -- Apply layout to all sections
    library.Layout:ApplyToAll()

    -- Run splash screen (Message 16)
    if library.Splash and library.Splash.Enabled then
        task.defer(function()
            library.Splash:Show("AppleUI Gen3", "Ready.")
        end)
    end
end

--========================================================--
-- SHUTDOWN / UNLOAD
--========================================================--

function library:Unload()
    -- Destroy all UI instances
    library.Optimize:DestroyAll()

    -- Remove blur if active
    if library._blur then
        library._blur:Destroy()
        library._blur = nil
    end

    -- Clear keybinds
    library.Keybinds.Registered = {}
    library.Keybinds.Debounce = {}

    -- Clear windows
    library.Windows = {}

    print("[AppleUI] Unloaded successfully.")
end

--========================================================--
-- RETURN PUBLIC API
--========================================================--

return library.API

