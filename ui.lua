local library = {}
local windowCount = 0
local sizes = {}
local listOffset = {}
local destroyed
local pastSliders = {}
local dropdowns = {}
local colorPickers = {}
local run = cloneref(game:GetService("RunService"))
local stepped = run.Stepped
local CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService = cloneref(game:GetService("TweenService"))


if CoreGui:FindFirstChild('TurtleUiLib') then
    CoreGui:FindFirstChild('TurtleUiLib'):Destroy()
    destroyed = true
end


local function protect_gui(obj)
    obj.Parent = CoreGui
end


local TurtleUiLib = Instance.new("ScreenGui")
TurtleUiLib.Name = "TurtleUiLib"
protect_gui(TurtleUiLib)



local function Lerp(a, b, c)
    return a + ((b - a) * c)
end

local player = cloneref(game:GetService("Players").LocalPlayer)
local mouse = player:GetMouse()

local function Dragify(dragHandle, dragTarget)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = dragTarget.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	run.RenderStepped:Connect(function()
		if dragging and dragInput then
			update(dragInput)
		end
	end)
end




local xOffset = 20
local uis = cloneref(game:GetService("UserInputService"))
local keybindConnection

function library:Destroy()
    TurtleUiLib:Destroy()
    if keybindConnection then keybindConnection:Disconnect() end
end

function library:Keybind(key)
    if keybindConnection then keybindConnection:Disconnect() end
    keybindConnection = uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode[key] then
            TurtleUiLib.Enabled = not TurtleUiLib.Enabled
        end
    end)
end


local colors = {
    primary = Color3.fromRGB(0, 120, 215),
    secondary = Color3.fromRGB(40, 40, 40),
    background = Color3.fromRGB(30, 30, 30),
    text = Color3.fromRGB(245, 246, 250),
    accent = Color3.fromRGB(0, 168, 255),
    slider = Color3.fromRGB(76, 209, 55),
    toggle = Color3.fromRGB(68, 189, 50),
    border = Color3.fromRGB(60, 60, 60)
}

function library:Window(name)
    windowCount = windowCount + 1
    local winCount = windowCount
    local zindex = winCount * 10

    local newX = xOffset + ((winCount - 1) * 240)
	local newY = 20


    local UiWindow = Instance.new("Frame")
    UiWindow.Name = name or "Window"
    UiWindow.Size = UDim2.new(0, 220, 0, 35)
    UiWindow.Position = UDim2.new(0, newX, 0, newY)

    UiWindow.BackgroundColor3 = colors.background
    UiWindow.BorderColor3 = colors.border
    UiWindow.BorderSizePixel = 0
    UiWindow.ZIndex = 2 + zindex
    UiWindow.ClipsDescendants = false
    UiWindow.Active = true
    UiWindow.Parent = TurtleUiLib

    local corner = Instance.new("UICorner", UiWindow)
    corner.CornerRadius = UDim.new(0, 6)

    local Header = Instance.new("Frame", UiWindow)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = colors.primary
    Header.BorderSizePixel = 0
    Header.ZIndex = 3 + zindex

    local HeaderText = Instance.new("TextLabel", Header)
    HeaderText.Text = name or "Window"
    HeaderText.Size = UDim2.new(1, -40, 1, 0)
    HeaderText.Position = UDim2.new(0, 10, 0, 0)
    HeaderText.TextColor3 = colors.text
    HeaderText.Font = Enum.Font.GothamSemibold
    HeaderText.TextSize = 14
    HeaderText.BackgroundTransparency = 1
    HeaderText.ZIndex = 4 + zindex
    HeaderText.TextXAlignment = Enum.TextXAlignment.Left

    local Minimise = Instance.new("TextButton", Header)
    Minimise.Size = UDim2.new(0, 20, 0, 20)
    Minimise.Position = UDim2.new(1, -30, 0, 5)
    Minimise.BackgroundTransparency = 1
    Minimise.Text = "-"
    Minimise.Font = Enum.Font.GothamBold
    Minimise.TextColor3 = colors.text
    Minimise.TextSize = 18
    Minimise.ZIndex = 4 + zindex

	local Window = Instance.new("ScrollingFrame", UiWindow)
	Window.Size = UDim2.new(1, 0, 1, -30)
	Window.Position = UDim2.new(0, 0, 0, 30)
    Window.BackgroundColor3 = colors.secondary
	Window.BorderSizePixel = 0
	Window.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Window.CanvasSize = UDim2.new(0, 0, 0, 0)
	Window.ScrollBarThickness = 0
	Window.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Window.ZIndex = 2 + zindex
	Window.ScrollingEnabled = false


Dragify(Header, UiWindow)


    sizes[winCount] = 0
    listOffset[winCount] = 10

    Minimise.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            Minimise.Text = "-"
            UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)
        else
            Minimise.Text = "+"
            UiWindow.Size = UDim2.new(0, 220, 0, 35)
        end
    end)

    local functions = {}

    function functions:Button(text, callback)
        text = text or "Button"
        callback = callback or function() end

        local button = Instance.new("TextButton", Window)
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Position = UDim2.new(0, 10, 0, listOffset[winCount])
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.Text = text
        button.Font = Enum.Font.Gotham
        button.TextColor3 = colors.text
        button.TextSize = 14
        button.ZIndex = 3 + zindex

        local corner = Instance.new("UICorner", button)
        corner.CornerRadius = UDim.new(0, 4)

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            callback()
        end)

        listOffset[winCount] = listOffset[winCount] + 35
        sizes[winCount] = listOffset[winCount]
        UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)
    end

function functions:Label(text, color, optional_height)
    if color == nil then
        color = colors.text
    end
    optional_height = optional_height or 5



    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = Window
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, listOffset[winCount] - optional_height)
    Label.Size = UDim2.new(1, -20, 0, 30)
    Label.Font = Enum.Font.Gotham
    Label.Text = text or "Label"
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.ZIndex = 2 + zindex


    if color == true then
        spawn(function()
            while wait() do
                local hue = tick() % 5 / 5
                Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
            end
        end)
    else
        Label.TextColor3 = color
    end


    listOffset[winCount] = listOffset[winCount] + 35
    sizes[winCount] = listOffset[winCount]
    UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)

    pastSliders[winCount] = false
end


function functions:Toggle(text, on, callback)
    callback = callback or function() end
    text = text or "Toggle"

    local yOffset = listOffset[winCount]

    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Name = "ToggleContainer"
    ToggleContainer.Parent = Window
    ToggleContainer.BackgroundTransparency = 1
    ToggleContainer.Position = UDim2.new(0, 10, 0, yOffset)
    ToggleContainer.Size = UDim2.new(1, -20, 0, 30)
    ToggleContainer.ZIndex = 3 + zindex

    local ToggleDescription = Instance.new("TextLabel")
    ToggleDescription.Name = "ToggleDescription"
    ToggleDescription.Parent = ToggleContainer
    ToggleDescription.BackgroundTransparency = 1
    ToggleDescription.Position = UDim2.new(0, 0, 0, 0)
    ToggleDescription.Size = UDim2.new(1, -40, 1, 0)
    ToggleDescription.Font = Enum.Font.Gotham
    ToggleDescription.Text = text
    ToggleDescription.TextColor3 = colors.text
    ToggleDescription.TextSize = 14
    ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDescription.ZIndex = 3 + zindex

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleContainer
    ToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    ToggleButton.Position = UDim2.new(1, -30, 0.5, -10)
    ToggleButton.Size = UDim2.new(0, 30, 0, 20)
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = ""
    ToggleButton.ZIndex = 3 + zindex
    ToggleButton.AutoButtonColor = false

    local toggleCorner = Instance.new("UICorner", ToggleButton)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local ToggleFiller = Instance.new("Frame")
    ToggleFiller.Name = "ToggleFiller"
    ToggleFiller.Parent = ToggleButton
    ToggleFiller.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
    ToggleFiller.Position = UDim2.new(0, on and 12 or 2, 0, 2)
    ToggleFiller.Size = UDim2.new(0, 16, 0, 16)
    ToggleFiller.Visible = on
    ToggleFiller.ZIndex = 4 + zindex

    local fillerCorner = Instance.new("UICorner", ToggleFiller)
    fillerCorner.CornerRadius = UDim.new(1, 0)

    local function updateToggle(state)
        if state then
            ToggleFiller.Visible = true
            TweenService:Create(ToggleFiller, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 12, 0, 2),
                BackgroundColor3 = colors.toggle
            }):Play()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        else
            TweenService:Create(ToggleFiller, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            }):Play()
            task.delay(0.2, function()
                ToggleFiller.Visible = false
                ToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            end)
        end
    end

    updateToggle(on)

    ToggleButton.MouseButton1Click:Connect(function()
        on = not on
        updateToggle(on)
        callback(on)
    end)

    listOffset[winCount] = listOffset[winCount] + 35
    sizes[winCount] = listOffset[winCount]
    UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)

    pastSliders[winCount] = false
end

function functions:Box(text,placeholdertext, callback)
    callback = callback or function() end
    text = text or "Input"
	placeholdertext = placeholdertext or "..."

    local yOffset = listOffset[winCount]

    local BoxContainer = Instance.new("Frame")
    BoxContainer.Name = "BoxContainer"
    BoxContainer.Parent = Window
    BoxContainer.BackgroundTransparency = 1
    BoxContainer.Position = UDim2.new(0, 10, 0, yOffset)
    BoxContainer.Size = UDim2.new(1, -20, 0, 30)
    BoxContainer.ZIndex = 3 + zindex

    local BoxDescription = Instance.new("TextLabel")
    BoxDescription.Name = "BoxDescription"
    BoxDescription.Parent = BoxContainer
    BoxDescription.BackgroundTransparency = 1
    BoxDescription.Position = UDim2.new(0, 0, 0, 0)
    BoxDescription.Size = UDim2.new(0, 80, 1, 0)
    BoxDescription.Font = Enum.Font.Gotham
    BoxDescription.Text = text
    BoxDescription.TextColor3 = colors.text
    BoxDescription.TextSize = 12
    BoxDescription.TextXAlignment = Enum.TextXAlignment.Left
    BoxDescription.ZIndex = 3 + zindex

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = BoxContainer
    TextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, 125, 0, 0)
    TextBox.Size = UDim2.new(.8, -80,1, 0)
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    TextBox.PlaceholderText = placeholdertext
    TextBox.Text = ""
    TextBox.TextColor3 = colors.text
    TextBox.TextSize = 11
    TextBox.ZIndex = 3 + zindex

    local boxCorner = Instance.new("UICorner", TextBox)
    boxCorner.CornerRadius = UDim.new(0, 4)

    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        callback(TextBox.Text, false)
    end)

    TextBox.FocusLost:Connect(function()
        callback(TextBox.Text, true)
    end)

    listOffset[winCount] = listOffset[winCount] + 35
    sizes[winCount] = listOffset[winCount]
    UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)

    pastSliders[winCount] = false
end


    
function functions:Slider(text, min, max, default,optional_height, callback)
    text = text or "Slider"
    min = min or 1
    max = max or 100
    default = default or math.floor((min + max) / 2)
    callback = callback or function() end
    optional_height = optional_height or 5
 
    if default > max then default = max elseif default < min then default = min end
 
 
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Name = "SliderContainer"
    SliderContainer.Parent = Window
    SliderContainer.BackgroundTransparency = 1
    SliderContainer.Position = UDim2.new(0, 10, 0, listOffset[winCount] - optional_height)
	listOffset[winCount] = listOffset[winCount] + 50
    SliderContainer.Size = UDim2.new(1, -20, 0, 40)
    SliderContainer.ZIndex = 2 + zindex
 
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = SliderContainer
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.Font = Enum.Font.Gotham
    Title.Text = text
    Title.TextColor3 = colors.text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 2 + zindex
 
    local Current = Instance.new("TextLabel")
    Current.Name = "Current"
    Current.Parent = SliderContainer
    Current.BackgroundTransparency = 1
    Current.Position = UDim2.new(1, -50, 0, 0)
    Current.Size = UDim2.new(0, 50, 0, 20)
    Current.Font = Enum.Font.Gotham
    Current.Text = tostring(default)
    Current.TextColor3 = colors.text
    Current.TextSize = 14
    Current.TextXAlignment = Enum.TextXAlignment.Right
    Current.ZIndex = 2 + zindex
 
    local Slider = Instance.new("Frame")
    Slider.Name = "Slider"
    Slider.Parent = SliderContainer
    Slider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Slider.BorderSizePixel = 0
    Slider.Position = UDim2.new(0, 0, 0, 22)
    Slider.Size = UDim2.new(1, 0, 0, 6)
    Slider.ZIndex = 2 + zindex
 
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = Slider
 
    local Filler = Instance.new("Frame")
    Filler.Name = "Filler"
    Filler.Parent = Slider
    Filler.BackgroundColor3 = colors.slider
    Filler.BorderSizePixel = 0
    Filler.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Filler.ZIndex = 2 + zindex
 
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = Filler
 
    local Handle = Instance.new("TextButton")
    Handle.Name = "Handle"
    Handle.Parent = Slider
    Handle.BackgroundColor3 = colors.text
    Handle.BorderSizePixel = 0
    Handle.Position = UDim2.new((default - min)/(max - min), -5, 0, -5)
    Handle.Size = UDim2.new(0, 14, 0, 14)
    Handle.Text = ""
    Handle.ZIndex = 3 + zindex
    Handle.AutoButtonColor = false
 
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = Handle
 
    local function SliderMovement(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragging = true
            local con
            con = stepped:Connect(function()
                if not dragging then con:Disconnect() return end
                local x = math.clamp(mouse.X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
                local percent = x / Slider.AbsoluteSize.X
                local value = math.clamp(Lerp(min, max, percent), min, max)
 
                Handle.Position = UDim2.new(0, x - 7, 0, -5)
                Filler.Size = UDim2.new(percent, 0, 1, 0)
                Current.Text = tostring(math.round(value))
                callback(math.round(value))
            end)
 
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
 
    Slider.InputBegan:Connect(SliderMovement)
    Handle.InputBegan:Connect(SliderMovement)
 
    sizes[winCount] = listOffset[winCount]
    UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)
 
    pastSliders[winCount] = true
end


function functions:Dropdown_multi(text, buttons, optional_height, callback)
    text = text or "Dropdown"
    buttons = buttons or {}
    callback = callback or function() end
    optional_height = optional_height or 5

    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Name = "DropdownContainer"
    DropdownContainer.Parent = Window
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Position = UDim2.new(0, 10, 0, listOffset[winCount] - optional_height)
    listOffset[winCount] = listOffset[winCount] + 50
    DropdownContainer.Size = UDim2.new(1, -20, 0, 30)
    DropdownContainer.ZIndex = 2 + zindex

    local Dropdown = Instance.new("TextButton")
    Dropdown.Name = "Dropdown"
    Dropdown.Parent = DropdownContainer
    Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Dropdown.BorderSizePixel = 0
    Dropdown.Size = UDim2.new(1, 0, 1, 0)
    Dropdown.Font = Enum.Font.Gotham
    Dropdown.Text = text
    Dropdown.TextColor3 = colors.text
    Dropdown.TextSize = 14
    Dropdown.ZIndex = 3 + zindex
    Dropdown.AutoButtonColor = false

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = Dropdown

    local DownSign = Instance.new("TextLabel")
    DownSign.Name = "DownSign"
    DownSign.Parent = Dropdown
    DownSign.BackgroundTransparency = 1
    DownSign.Position = UDim2.new(1, -25, 0, 0)
    DownSign.Size = UDim2.new(0, 20, 1, 0)
    DownSign.Font = Enum.Font.GothamBold
    DownSign.Text = "▼"
    DownSign.TextColor3 = colors.text
    DownSign.TextSize = 14
    DownSign.ZIndex = 4 + zindex

    Dropdown.MouseEnter:Connect(function()
        TweenService:Create(Dropdown, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        }):Play()
    end)

    Dropdown.MouseLeave:Connect(function()
        TweenService:Create(Dropdown, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }):Play()
    end)

    local DropdownFrame = Instance.new("ScrollingFrame")
    DropdownFrame.Name = "DropdownFrame"
    DropdownFrame.Parent = UiWindow:FindFirstAncestorOfClass("ScreenGui")
    DropdownFrame.Active = true
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Position = UDim2.new(0, DropdownContainer.AbsolutePosition.X, 0, DropdownContainer.AbsolutePosition.Y + DropdownContainer.AbsoluteSize.Y)
    DropdownFrame.Size = UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, 0)
    DropdownFrame.Visible = false
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    DropdownFrame.ScrollBarThickness = 4
    DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    DropdownFrame.ZIndex = 5 + zindex
    DropdownFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = DropdownFrame

    table.insert(dropdowns, DropdownFrame)

    Dropdown.MouseButton1Click:Connect(function()
        for _, v in pairs(dropdowns) do
            if v ~= DropdownFrame then
                v.Visible = false
                if v.Parent:FindFirstChild("DownSign") then
                    v.Parent.DownSign.Text = "▼"
                end
            end
        end

        DropdownFrame.Visible = not DropdownFrame.Visible
        DownSign.Text = DropdownFrame.Visible and "▲" or "▼"

        if DropdownFrame.Visible then
            local count = 0
            for _, v in ipairs(DropdownFrame:GetChildren()) do
                if v:IsA("TextButton") then count = count + 1 end
            end
            DropdownFrame.Size = UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, math.min(count * 32, 160))
            DropdownFrame.Position = UDim2.new(0, DropdownContainer.AbsolutePosition.X, 0, DropdownContainer.AbsolutePosition.Y + DropdownContainer.AbsoluteSize.Y)
        else
            DropdownFrame.Size = UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, 0)
        end
    end)

    local dropFunctions = {}
    local canvasSize = 0
    local selectedButtons = {}

    function dropFunctions:Button(info)
        local name = typeof(info) == "table" and info.Text or tostring(info)
        local icon = typeof(info) == "table" and info.Icon or nil

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = DropdownFrame
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0, 5, 0, canvasSize + 5)
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.Font = Enum.Font.Gotham
        Button.TextColor3 = colors.text
        Button.TextSize = 14
        Button.Text = name
        Button.ZIndex = 6 + zindex
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        if icon then
            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Parent = Button
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0, 5, 0.5, -8)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Image = icon
            Icon.ZIndex = 7 + zindex
            Button.Text = "     " .. name
        end

        Button.MouseEnter:Connect(function()
            if not selectedButtons[name] then
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                }):Play()
            end
        end)

        Button.MouseLeave:Connect(function()
            if not selectedButtons[name] then
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
            end
        end)

        Button.MouseButton1Click:Connect(function()
            local isSelected = selectedButtons[name]

            if isSelected then
                selectedButtons[name] = nil
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
            else
                selectedButtons[name] = Button
                Button.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
            end

            local selectedNames = {}
            for key, _ in pairs(selectedButtons) do
                table.insert(selectedNames, key)
            end

            if #selectedNames == 1 then
                Dropdown.Text = selectedNames[1]
            else
                Dropdown.Text = #selectedNames .. " Selected"
            end

            callback(selectedNames)
        end)

        canvasSize = canvasSize + 35
    end

    function dropFunctions:Remove(name)
        for _, v in ipairs(DropdownFrame:GetChildren()) do
            if v:IsA("TextButton") and v.Text:match(name) then
                v:Destroy()
                selectedButtons[name] = nil
                break
            end
        end

        canvasSize = 0
        for _, v in ipairs(DropdownFrame:GetChildren()) do
            if v:IsA("TextButton") then
                v.Position = UDim2.new(0, 5, 0, canvasSize + 5)
                canvasSize = canvasSize + 35
            end
        end
    end

    function dropFunctions:GetSelected()
        local selected = {}
        for name, _ in pairs(selectedButtons) do
            table.insert(selected, name)
        end
        return selected
    end

    function dropFunctions:Clear()
        for _, btn in pairs(selectedButtons) do
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end
        selectedButtons = {}
    end

    for _, v in pairs(buttons) do
        dropFunctions:Button(v)
    end

    sizes[winCount] = listOffset[winCount]
    UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)

    return dropFunctions
end



function functions:Dropdown(text, buttons, optional_height, callback)
    text = text or "Dropdown"
    buttons = buttons or {}
    callback = callback or function() end
    optional_height = optional_height or 5

    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Name = "DropdownContainer"
    DropdownContainer.Parent = Window
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Position = UDim2.new(0, 10, 0, listOffset[winCount] - optional_height)
    listOffset[winCount] = listOffset[winCount] + 50
    DropdownContainer.Size = UDim2.new(1, -20, 0, 30)
    DropdownContainer.ZIndex = 2 + zindex

    local Dropdown = Instance.new("TextButton")
    Dropdown.Name = "Dropdown"
    Dropdown.Parent = DropdownContainer
    Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Dropdown.BorderSizePixel = 0
    Dropdown.Size = UDim2.new(1, 0, 1, 0)
    Dropdown.Font = Enum.Font.Gotham
    Dropdown.Text = text
    Dropdown.TextColor3 = colors.text
    Dropdown.TextSize = 14
    Dropdown.ZIndex = 3 + zindex
    Dropdown.AutoButtonColor = false

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = Dropdown

    local DownSign = Instance.new("TextLabel")
    DownSign.Name = "DownSign"
    DownSign.Parent = Dropdown
    DownSign.BackgroundTransparency = 1
    DownSign.Position = UDim2.new(1, -25, 0, 0)
    DownSign.Size = UDim2.new(0, 20, 1, 0)
    DownSign.Font = Enum.Font.GothamBold
    DownSign.Text = "▼"
    DownSign.TextColor3 = colors.text
    DownSign.TextSize = 14
    DownSign.ZIndex = 4 + zindex

    Dropdown.MouseEnter:Connect(function()
        TweenService:Create(Dropdown, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        }):Play()
    end)

    Dropdown.MouseLeave:Connect(function()
        TweenService:Create(Dropdown, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }):Play()
    end)

    local DropdownFrame = Instance.new("ScrollingFrame")
    DropdownFrame.Name = "DropdownFrame"
    DropdownFrame.Parent = UiWindow:FindFirstAncestorOfClass("ScreenGui")
    DropdownFrame.Active = true
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Position = UDim2.new(0, DropdownContainer.AbsolutePosition.X, 0, DropdownContainer.AbsolutePosition.Y + DropdownContainer.AbsoluteSize.Y)
    DropdownFrame.Size = UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, 0)
    DropdownFrame.Visible = false
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    DropdownFrame.ScrollBarThickness = 4
    DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    DropdownFrame.ZIndex = 5 + zindex
    DropdownFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = DropdownFrame

    table.insert(dropdowns, DropdownFrame)

local RunService = game:GetService("RunService")

Dropdown.MouseButton1Click:Connect(function()
    for _, v in pairs(dropdowns) do
        if v ~= DropdownFrame then
            v.Visible = false
            if v.Parent:FindFirstChild("DownSign") then
                v.Parent.DownSign.Text = "▼"
            end
        end
    end

    DropdownFrame.Visible = not DropdownFrame.Visible
    DownSign.Text = DropdownFrame.Visible and "▲" or "▼"

    if DropdownFrame.Visible then
        -- Defer to next frame to get correct positioning
        RunService.RenderStepped:Wait()

        local count = 0
        for _, v in ipairs(DropdownFrame:GetChildren()) do
            if v:IsA("TextButton") then count = count + 1 end
        end

        local absPos = DropdownContainer.AbsolutePosition
        local absSize = DropdownContainer.AbsoluteSize
        DropdownFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y)
        DropdownFrame.Size = UDim2.new(0, absSize.X, 0, math.min(count * 32, 160))
    else
        DropdownFrame.Size = UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, 0)
    end
end)


    local dropFunctions = {}
    local canvasSize = 0
    local selectedButton = nil

    function dropFunctions:Button(info)
        local name = typeof(info) == "table" and info.Text or tostring(info)
        local icon = typeof(info) == "table" and info.Icon or nil

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = DropdownFrame
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0, 5, 0, canvasSize + 5)
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.Font = Enum.Font.Gotham
        Button.TextColor3 = colors.text
        Button.TextSize = 14
        Button.Text = name
        Button.ZIndex = 6 + zindex
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        if icon then
            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Parent = Button
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0, 5, 0.5, -8)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Image = icon
            Icon.ZIndex = 7 + zindex
            Button.Text = "     " .. name
        end

        Button.MouseEnter:Connect(function()
            if Button ~= selectedButton then
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                }):Play()
            end
        end)

        Button.MouseLeave:Connect(function()
            if Button ~= selectedButton then
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
            end
        end)

        Button.MouseButton1Click:Connect(function()
            if selectedButton then
                TweenService:Create(selectedButton, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
            end

            selectedButton = Button
            Button.BackgroundColor3 = Color3.fromRGB(76, 209, 55)

            Dropdown.Text = name
            DropdownFrame.Visible = false
            DownSign.Text = "▼"

            callback(name)
        end)

        canvasSize = canvasSize + 35
    end

    function dropFunctions:Remove(name)
        for _, v in ipairs(DropdownFrame:GetChildren()) do
            if v:IsA("TextButton") and v.Text:match(name) then
                if selectedButton == v then
                    selectedButton = nil
                end
                v:Destroy()
                break
            end
        end

        canvasSize = 0
        for _, v in ipairs(DropdownFrame:GetChildren()) do
            if v:IsA("TextButton") then
                v.Position = UDim2.new(0, 5, 0, canvasSize + 5)
                canvasSize = canvasSize + 35
            end
        end
    end

    function dropFunctions:GetSelected()
        return Dropdown.Text
    end

    function dropFunctions:Clear()
        if selectedButton then
            TweenService:Create(selectedButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
            selectedButton = nil
        end
    end

    for _, v in pairs(buttons) do
        dropFunctions:Button(v)
    end

    sizes[winCount] = listOffset[winCount]
    UiWindow.Size = UDim2.new(0, 220, 0, sizes[winCount] + 35)

    return dropFunctions
end



    return functions
end

return library
