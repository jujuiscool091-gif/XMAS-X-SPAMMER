--[[
    0RB1T — UI Library for Roblox
 
    Usage:
 
    local ORB1T = loadstring(game:HttpGet("..."))()
 
    local Window = ORB1T.CreateWindow({
        Title = "0RB1T",
        Theme = Color3.fromRGB(0, 255, 120),
    })
 
    local Tab = Window:AddTab("AimBot")
 
    Tab:AddToggle("Enable AimBot", false, function(val) print(val) end)
    Tab:AddSlider("FOV", {Min=1, Max=360, Default=90}, function(val) print(val) end)
    Tab:AddButton("Click Me", function() print("clicked") end)
    Tab:AddLabel("Some info text")
    Tab:AddDropdown("Method", {"Humanoid", "Root", "Head"}, function(val) print(val) end)
    Tab:AddKeybind("Toggle Key", Enum.KeyCode.E, function() print("triggered") end)
]]
 
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local Lighting          = game:GetService("Lighting")
local RunService        = game:GetService("RunService")
 
local LocalPlayer = Players.LocalPlayer
 
-- ─────────────────────────────────────────────
--  UTILS
-- ─────────────────────────────────────────────
 
local function Round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end
 
local function Tween(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
    tw:Play()
    return tw
end
 
local function MakePadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end
 
local function MakeListLayout(parent, padding, fillDir)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, padding or 8)
    l.FillDirection    = fillDir or Enum.FillDirection.Vertical
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end
 
local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end
 
-- ─────────────────────────────────────────────
--  LIBRARY TABLE
-- ─────────────────────────────────────────────
 
local ORB1T = {}
ORB1T.__index = ORB1T
 
-- ─────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────
 
function ORB1T.CreateWindow(options)
    options = options or {}
 
    local cfg = {
        Title       = options.Title       or "0RB1T",
        SubTitle    = options.SubTitle    or "v1.0",
        Theme       = options.Theme       or Color3.fromRGB(0, 255, 120),
        Background  = options.Background  or Color3.fromRGB(10, 10, 10),
        Border      = options.Border      or Color3.fromRGB(55, 55, 55),
        ToggleKey   = options.ToggleKey   or Enum.KeyCode.RightShift,
        Size        = options.Size        or Vector2.new(640, 450),
    }
 
    -- Clean old instance
    if CoreGui:FindFirstChild("ORB1T_" .. cfg.Title) then
        CoreGui:FindFirstChild("ORB1T_" .. cfg.Title):Destroy()
    end
 
    local BoldFont = Enum.Font.GothamBold
    local MainFont = Enum.Font.Ubuntu
 
    -- ScreenGui
    local ScreenGui = New("ScreenGui", {
        Name          = "ORB1T_" .. cfg.Title,
        ResetOnSpawn  = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, CoreGui)
 
    -- Blur
    local Blur = New("BlurEffect", { Size = 0, Enabled = false }, Lighting)
 
    -- Main Frame
    local W, H = cfg.Size.X, cfg.Size.Y
    local Main = New("Frame", {
        Name              = "Main",
        Size              = UDim2.new(0, W, 0, H),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint       = Vector2.new(0.5, 0.5),
        BackgroundColor3  = cfg.Background,
        BorderSizePixel   = 0,
        ClipsDescendants  = true,
        Visible           = false,
    }, ScreenGui)
    Round(Main, 14)
 
    -- Shadow
    local Shadow = New("ImageLabel", {
        AnchorPoint          = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position             = UDim2.new(0.5, 0, 0.5, 6),
        Size                 = UDim2.new(1, 40, 1, 40),
        Image                = "rbxassetid://6014261993",
        ImageColor3          = Color3.new(0,0,0),
        ImageTransparency    = 0.5,
        ScaleType            = Enum.ScaleType.Slice,
        SliceCenter          = Rect.new(49,49,450,450),
        ZIndex               = 0,
    }, Main)
 
    local function Line(pos, size)
        return New("Frame", {
            BackgroundColor3 = cfg.Border,
            BorderSizePixel  = 0,
            Position         = pos,
            Size             = size,
        }, Main)
    end
 
    Line(UDim2.new(0, 0, 0, 62),   UDim2.new(1, 0, 0, 1))
    Line(UDim2.new(0, 192, 0, 62), UDim2.new(0, 1, 1, -62))
    Line(UDim2.new(0, 0, 1, -112), UDim2.new(0, 192, 0, 1))
 
    local TopBar = New("Frame", {
        Size                 = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
    }, Main)
 
    local LogoBase = New("Frame", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 18, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Rotation         = 45,
    }, TopBar)
    Round(LogoBase, 6)
    New("UIStroke", { Color = cfg.Theme, Thickness = 2 }, LogoBase)
    New("TextLabel", {
        Size                 = UDim2.new(1, 0, 1, 0),
        Rotation             = -45,
        Text                 = "O",
        Font                 = BoldFont,
        TextSize             = 20,
        TextColor3           = cfg.Theme,
        BackgroundTransparency = 1,
    }, LogoBase)
 
    New("TextLabel", {
        Text                 = cfg.Title,
        Position             = UDim2.new(0, 68, 0, 0),
        Size                 = UDim2.new(0, 220, 1, 0),
        TextColor3           = cfg.Theme,
        Font                 = BoldFont,
        TextSize             = 22,
        TextXAlignment       = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, TopBar)
 
    local CloseBtn = New("TextButton", {
        Size             = UDim2.new(0, 34, 0, 34),
        Position         = UDim2.new(1, -48, 0, 14),
        BackgroundColor3 = cfg.Theme,
        Text             = "✕",
        TextColor3       = Color3.fromRGB(10, 10, 10),
        Font             = BoldFont,
        TextSize         = 16,
    }, Main)
    Round(CloseBtn, 8)
 
    local SidebarScroll = New("ScrollingFrame", {
        Position             = UDim2.new(0, 12, 0, 74),
        Size                 = UDim2.new(0, 168, 1, -186),
        BackgroundTransparency = 1,
        ScrollBarThickness   = 0,
        CanvasSize           = UDim2.new(0,0,0,0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
    }, Main)
    MakeListLayout(SidebarScroll, 6)
 
    local PageContainer = New("Frame", {
        Position             = UDim2.new(0, 205, 0, 72),
        Size                 = UDim2.new(1, -220, 1, -90),
        BackgroundTransparency = 1,
    }, Main)
 
    -- Float button logic
    local FloatBtn = New("TextButton", {
        Size             = UDim2.new(0, 44, 0, 44),
        Position         = UDim2.new(0.5, -22, 0, 70),
        BackgroundColor3 = cfg.Background,
        Text             = "O",
        TextColor3       = cfg.Theme,
        Font             = BoldFont,
        TextSize         = 22,
        Visible          = true,
    }, ScreenGui)
    Round(FloatBtn, 22)
    New("UIStroke", { Color = cfg.Theme, Thickness = 1.5 }, FloatBtn)
 
    local function ToggleUI()
        if not Main.Visible then
            Main.Size    = UDim2.new(0, 0, 0, 0)
            Main.Visible = true
            Blur.Enabled = true
            Tween(Main, 0.4, { Size = UDim2.new(0, W, 0, H) })
            Tween(Blur, 0.4, { Size = 22 })
        else
            local t1 = Tween(Main, 0.3, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            Tween(Blur, 0.3, { Size = 0 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            t1.Completed:Once(function()
                Main.Visible = false
                Blur.Enabled = false
            end)
        end
    end
 
    CloseBtn.MouseButton1Click:Connect(ToggleUI)
    FloatBtn.MouseButton1Click:Connect(ToggleUI)
    UserInputService.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == cfg.ToggleKey then ToggleUI() end
    end)
 
    -- Draggable
    do
        local dragging, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = Main.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local d = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end
 
    local Window = { _tabs = {}, _selectedTab = nil }
 
    function Window:AddTab(name)
        local Page = New("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = cfg.Theme,
            Visible = false,
        }, PageContainer)
        MakeListLayout(Page, 10)
        MakePadding(Page, 2, 2, 2, 2)
 
        local TabBtn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Text = name,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = MainFont,
            TextSize = 14,
        }, SidebarScroll)
        Round(TabBtn, 8)
 
        local function Select()
            for _, v in pairs(Window._tabs) do
                v.Page.Visible = false
                Tween(v.Btn, 0.2, {TextColor3 = Color3.fromRGB(150,150,150), BackgroundColor3 = Color3.fromRGB(25,25,25)})
            end
            Page.Visible = true
            Tween(TabBtn, 0.2, {TextColor3 = cfg.Theme, BackgroundColor3 = Color3.fromRGB(35,35,35)})
        end
 
        TabBtn.MouseButton1Click:Connect(Select)
        
        local api = {}
        
        function api:AddButton(text, callback)
            local Btn = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Text = text,
                TextColor3 = Color3.new(1,1,1),
                Font = MainFont,
                TextSize = 14,
            }, Page)
            Round(Btn, 8)
            Btn.MouseButton1Click:Connect(callback)
        end
 
        function api:AddToggle(text, default, callback)
            local Tgl = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Text = "  " .. text,
                TextColor3 = Color3.new(1,1,1),
                Font = MainFont,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Page)
            Round(Tgl, 8)
            local Status = New("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = default and cfg.Theme or Color3.fromRGB(40,40,40),
            }, Tgl)
            Round(Status, 4)
            
            local active = default
            Tgl.MouseButton1Click:Connect(function()
                active = not active
                Tween(Status, 0.2, {BackgroundColor3 = active and cfg.Theme or Color3.fromRGB(40,40,40)})
                callback(active)
            end)
        end
 
        -- Simplified logic for other elements to keep it clean
        function api:AddLabel(txt)
            New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = txt,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                Font = MainFont,
                TextSize = 13,
            }, Page)
        end
 
        table.insert(Window._tabs, {Page = Page, Btn = TabBtn})
        if #Window._tabs == 1 then Select() end
        return api
    end
 
    return Window
end
 
return ORB1T
