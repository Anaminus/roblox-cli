local defaults = {
	autoHide = true;
	historySave = false;
	historySize = 32;
	keybind = {
		focus = '\13';
		previous = '\22';
		next = '\23';
	};
}

local types = {
	autoHide = 'bool';
	historySave = 'bool';
	historySize = 'int';
	keybind = {
		focus = 'char';
		previous = 'char';
		next = 'char';
	};
}

local convert = {
	bool = function(v) return not not v end;
	int = function(v) return math.floor(tonumber(v) or 0) end;
	number = function(v) return tonumber(v) or 0 end;
	char = function(v) return tostring(v):sub(1,1) end;
	string = tostring;
}

local typeLookup = {}
local settingName = {}

local function merge(defaults,settings,types)
	typeLookup[settings] = types
	for k,v in pairs(defaults) do
		if type(v) == 'table' then
			if type(settings[k]) ~= 'table' then
				settings[k] = {}
			end
			settingName[settings[k]] = settingName[settings] .. '.' .. k
			merge(v,settings[k],types[k])
		else
			if settings[k] == nil then
				settings[k] = v
			end
		end
	end
	for k,v in pairs(settings) do
		if defaults[k] == nil then
			settings[k] = nil
		end
	end
end

local newindex=function()end
local wrapper
local lookup = {}
local wrappermt = {
	__index = function(w,k)
		local t = lookup[w]
		if not t then
			error('invalid setting table',2)
		end

		local v = t[k]

		if type(v) == 'table' then
			v = wrapper(v)
		elseif v == nil then
			error('`' .. tostring(k) .. '` is not a valid setting',2)
		end

		return v
	end;
	__newindex = function(w,k,v)
		local t = lookup[w]
		if not t then
			error('invalid setting table',2)
		end

		if type(t[k]) == 'table' then
			error('cannot set table',2)
		end

		if t[k] == nil then
			error('invalid setting `' .. tostring(k) .. '`',2)
		end

		v = convert[typeLookup[t][k]](v)
		t[k] = v
		newindex(t,k,v)
	end;
}

function wrapper(t)
	if lookup[t] then return lookup[t] end
	local w = setmetatable({},wrappermt)
	lookup[w] = t
	lookup[t] = w
	return w
end

return function(plugin)
	local pluginSetting = require(script.Parent.pluginSetting)(plugin)
	local settings = pluginSetting.Get('settings') or {}
	settingName[settings] = 'settings'
	merge(defaults,settings,types)

	local listeners = {}
	function newindex(t,k,v)
		pluginSetting.Set('settings',settings)
		local name = settingName[t] .. '.' .. k
		for i = 1,#listeners do
			listeners[i](name,v)
		end
	end

	pluginSetting.Set('settings',settings)

	return wrapper(settings),settings,function(listener)
		listeners[#listeners+1] = listener
	end
end
