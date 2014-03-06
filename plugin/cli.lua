local version = '1.0.1'

local pluginSetting = require(script.Parent.pluginSetting)(plugin)
local settingsWrapper,settings,settingChanged = require(script.Parent.settings)(plugin)

local super = setmetatable({},{__index=getfenv(1)})
local env = setmetatable({},{__index=super})
local init = pluginSetting.Get('env') or {}

-- Initialize variables in the order of their dependencies
do
	local function run(name,func)
		local f,err = loadstring(func,'cmd')
		if f then
			setfenv(f,env)
			local success,err = ypcall(f)
			if not success then
				-- If the call requires a missing global, return that global
				local var = err:match("global '([%w_][%w%d_]*)' %(a nil value%)$")
				if var then return var end
				print('init(' .. name .. ') error: ' .. err:match('^%[string ".-"%]:.-: (.*)$'))
			end
		else
			print('init(' .. name .. ') error: ' .. err:match('^%[string ".-"%]:.-: (.*)$'))
		end
	end

	local a = {}
	for name in pairs(init) do
		a[#a+1] = name
	end

	local i = 1
	while #a > 0 and i <= #a do
		local n = a[i]
		-- If the call was successful, or the call depends on some other
		-- global not in the list, then remove it.
		if not init[run(n,init[n])] then
			table.remove(a,i)
			i = 1
		else
			i = i + 1
		end
	end

	if #a > 0 then
		print('init error: could not initialize variables; one or more cyclic dependencies exist')
	end
end

local saveKey
local proxy = setmetatable({},{
	__index=env;
	__newindex = function(t,k,v)
		if type(k) == 'string' and k:match('^[%w_][%w%d_]*$') then
			saveKey = k
		end
		env[k] = v
	end;
})

local function runInput(input)
	local f,err = loadstring(input,'cmd')
	if not f then
		print('error: ' .. err:match('^%[string ".-"%]:.-: (.*)$')) --error: [string "cmd"]:1: '=' expected near '<eof>'
		return
	end

	setfenv(f,proxy)

	local success,err = ypcall(f)
	if not success then
		print('error: ' .. (err:match('^%[string ".-"%]:.-: (.*)$') or err))
		return
	end

	if saveKey then
		local name,value = input:match('^%s-([%w_][%w%d_]*)%s-=%s-(.+)%s-$')
		if name == saveKey then
			if value == 'nil' then
				print('removed `' .. name .. '` from persisting environment')
				init[name] = nil
			else
				if init[name] then
					print('updated `' .. name .. '` in persisting environment')
				else
					print('added `' .. name .. '` to persisting environment')
				end
				init[name] = input
			end
			pluginSetting.Set('env',init)
		end
	end
	saveKey = nil
end

----------------------------------------------------------------
----------------------------------------------------------------

local tween = require(script.Parent.tween)
local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = 'CLI'
	ScreenGui.Archivable = false
	local InputFrame = Instance.new("Frame", ScreenGui)
		InputFrame.Name = "InputFrame"
		InputFrame.Position = UDim2.new(0,2,1,-26)
		InputFrame.Size = UDim2.new(1,-4,0,24)
		InputFrame.BackgroundColor3 = Color3.new(0,0,0)
		InputFrame.BorderColor3 = Color3.new(1,1,1)
		local Input = Instance.new("TextBox", InputFrame)
			Input.Name = "Input"
			Input.BackgroundTransparency = 1
			Input.Position = UDim2.new(0,16,0,0)
			Input.Size = UDim2.new(1,-64,1,0)
			Input.BackgroundColor3 = Color3.new(0,0,0)
			Input.BorderColor3 = Color3.new(1,1,1)
			Input.Text = ""
			Input.TextXAlignment = Enum.TextXAlignment.Left
			Input.FontSize = Enum.FontSize.Size18
			Input.Font = Enum.Font.SourceSans
			Input.TextColor3 = Color3.new(1,1,1)
			Input.ClearTextOnFocus = false
		local FocusButton = Instance.new("ImageButton", InputFrame)
			FocusButton.Name = "FocusButton"
			FocusButton.BackgroundTransparency = 1
			FocusButton.Size = UDim2.new(0,16,1,0)
			FocusButton.BackgroundColor3 = Color3.new(0,0,0)
			FocusButton.BorderColor3 = Color3.new(1,1,1)
			FocusButton.AutoButtonColor = false
			local InputIcon = Instance.new("Frame", FocusButton)
				InputIcon.Name = "InputIcon"
				InputIcon.BorderSizePixel = 0
				InputIcon.Rotation = 45
				InputIcon.Position = UDim2.new(0,4,0.5,-4)
				InputIcon.Size = UDim2.new(0,8,0,8)
				InputIcon.BackgroundColor3 = Color3.new(1,1,1)
				InputIcon.BorderColor3 = Color3.new(1,1,1)
				local Frame = Instance.new("Frame", InputIcon)
					Frame.BorderSizePixel = 0
					Frame.Position = UDim2.new(-0.25,0,0.25,0)
					Frame.Size = UDim2.new(1,0,1,0)
					Frame.BackgroundColor3 = Color3.new(0,0,0)
					Frame.BorderColor3 = Color3.new(1,1,1)
		local PreviousButton = Instance.new("ImageButton", InputFrame)
			PreviousButton.Name = "PreviousButton"
			PreviousButton.Position = UDim2.new(1,-45,0,2)
			PreviousButton.Size = UDim2.new(0,20,1,-4)
			PreviousButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
			PreviousButton.BackgroundColor3 = Color3.new(0,0,0)
			PreviousButton.BorderColor3 = Color3.new(1,1,1)
			PreviousButton.AutoButtonColor = false
			local InputIcon1 = Instance.new("Frame", PreviousButton)
				InputIcon1.Name = "InputIcon"
				InputIcon1.Rotation = -45
				InputIcon1.BorderSizePixel = 0
				InputIcon1.Position = UDim2.new(0.5,-4,0.5,-2)
				InputIcon1.Size = UDim2.new(0,8,0,8)
				InputIcon1.BackgroundColor3 = Color3.new(1,1,1)
				InputIcon1.BorderColor3 = Color3.new(1,1,1)
				local Frame1 = Instance.new("Frame", InputIcon1)
					Frame1.BorderSizePixel = 0
					Frame1.Position = UDim2.new(-0.25,0,0.25,0)
					Frame1.Size = UDim2.new(1,0,1,0)
					Frame1.BackgroundColor3 = Color3.new(0,0,0)
					Frame1.BorderColor3 = Color3.new(1,1,1)
		local NextButton = Instance.new("ImageButton", InputFrame)
			NextButton.Name = "NextButton"
			NextButton.Position = UDim2.new(1,-22,0,2)
			NextButton.Size = UDim2.new(0,20,1,-4)
			NextButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
			NextButton.BackgroundColor3 = Color3.new(0,0,0)
			NextButton.BorderColor3 = Color3.new(1,1,1)
			NextButton.AutoButtonColor = false
			local InputIcon2 = Instance.new("Frame", NextButton)
				InputIcon2.Name = "InputIcon"
				InputIcon2.Rotation = 135
				InputIcon2.BorderSizePixel = 0
				InputIcon2.Position = UDim2.new(0.5,-4,0.5,-6)
				InputIcon2.Size = UDim2.new(0,8,0,8)
				InputIcon2.BackgroundColor3 = Color3.new(1,1,1)
				InputIcon2.BorderColor3 = Color3.new(1,1,1)
				local Frame2 = Instance.new("Frame", InputIcon2)
					Frame2.BorderSizePixel = 0
					Frame2.Position = UDim2.new(-0.25,0,0.25,0)
					Frame2.Size = UDim2.new(1,0,1,0)
					Frame2.BackgroundColor3 = Color3.new(0,0,0)
					Frame2.BorderColor3 = Color3.new(1,1,1)

local barVisible,visibleId do
	visibleId = 0
	local function resetVisibleId(status)
		if status == Enum.TweenStatus.Completed then
			visibleId = 0
		end
	end

	local function showBar()
		tween.Position(FocusButton,UDim2.new(0,0,0,0),'Out','Quad',0,true,nil)
		FocusButton.Position = UDim2.new(0,0,0,0)
		FocusButton.Size = UDim2.new(0,16,1,0)
		FocusButton.BackgroundTransparency = 1
		tween.Position(InputFrame,UDim2.new(0,2,1,-26),'Out','Quad',0.1,true,resetVisibleId)
	end

	local function hideBar()
		tween.Position(InputFrame,UDim2.new(0,2,1,1),'In','Quad',0.1,false,function(status)
			if status == Enum.TweenStatus.Completed then
				FocusButton.BackgroundTransparency = 0
				FocusButton.Position = UDim2.new(0,64,0,0)
				FocusButton.Size = UDim2.new(0,16,0,16)
				tween.Position(FocusButton,UDim2.new(0,64,0,-22),'Out','Quad',0.25,false,resetVisibleId)
			end
		end)
	end

	function barVisible(visible,dlay)
		if not visible and not settings.autoHide then return end

		local cid = visibleId + 1
		visibleId = cid
		if dlay then
			delay(dlay,function()
				if visibleId ~= cid then return end
				(visible and showBar or hideBar)()
			end)
		else
			(visible and showBar or hideBar)()
		end
	end
end

plugin:Activate(false)
local Mouse = plugin:GetMouse()

local history = settings.historySave and pluginSetting.Get('history') or {}
local historyPtr = #history + 1
local historyMax = settings.historySize

settingChanged(function(k,v)
	if k == 'settings.historySize' then
		historyMax = v
		while #history > historyMax do
			table.remove(history,1)
		end
		if settings.historySave then
			pluginSetting.Set('history',history)
		end
	end
end)

settingChanged(function(k,v)
	if k == 'settings.historySave' then
		if v then
			pluginSetting.Set('history',history)
		else
			pluginSetting.Set('history',nil)
		end
	end
end)

local buffer = ''
local updateBuffer = true

local function handleInput(input)
	if input ~= "" and input ~= history[#history] then
		history[#history+1] = input
		if #history > historyMax then
			table.remove(history,1)
		end
		if settings.historySave then
			pluginSetting.Set('history',history)
		end
	end
	historyPtr = #history + 1

	runInput(input)
end

local function saveInBuffer(input)
	buffer = input
end

local function previous()
	barVisible(true)
	if #history == 0 then return end
	historyPtr = historyPtr > 1 and historyPtr-1 or 1

	if history[historyPtr] then
		updateBuffer = false
		Input.Text = tostring(history[historyPtr])
		updateBuffer = true
	end
end

local function next()
	barVisible(true)
	if #history == 0 then return end
	if historyPtr < #history then
		historyPtr = historyPtr + 1
		updateBuffer = false
		Input.Text = tostring(history[historyPtr])
		updateBuffer = true
	else -- recall data in buffer
		historyPtr = #history + 1
		updateBuffer = false
		Input.Text = tostring(buffer)
		updateBuffer = true
	end
end

Input.FocusLost:connect(function(enter)
	-- if enter was not pressed, then next time, resume from previous input
	if enter then
		local input = Input.Text
		Input.Text = ""
		Input:CaptureFocus()
		handleInput(input)
	elseif Input.Text == "" then
		barVisible(false,0.5)
	end
end)

Input.Changed:connect(function(p)
	if p == 'Text' and updateBuffer then
		saveInBuffer(Input.Text)
	end
end)

Mouse.KeyDown:connect(function(key)
	if key == settings.keybind.focus then
		barVisible(true)
		Input:CaptureFocus()
	elseif key == settings.keybind.previous then
		previous()
	elseif key == settings.keybind.next then
		next()
	end
end)

PreviousButton.MouseButton1Down:connect(previous)
NextButton.MouseButton1Down:connect(next)

FocusButton.MouseButton1Down:connect(function()
	barVisible(true)
	Input:CaptureFocus()
end)

ScreenGui.Parent = Game:GetService('CoreGui')
if settings.autoHide then
	InputFrame.Position = UDim2.new(0,2,1,1)
	barVisible(false)
end

----------------------------------------------------------------
----------------------------------------------------------------

function super.recall(key)
	if key == nil then
		print('Variables:')
		local sorted = {}
		for k in pairs(init) do
			sorted[#sorted+1] = k
		end
		table.sort(sorted)
		for i = 1,#sorted do
			print('  - `' .. tostring(sorted[i]) .. '`')
		end
		return
	end

	if not init[key] then
		print('`' .. tostring(key) .. '` does not exist')
		return
	end

	Input.Text = init[key]
end

super.help = require(script.Parent.help);

super.cli = {
	settings = settingsWrapper;
	init = init;
	history = history;
	version = version;
}

if not pluginSetting.Get('notFirstRun') then
	pluginSetting.Set('notFirstRun',true)
	Input.Text = [[help('usage')]]
end
