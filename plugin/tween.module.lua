--[[

Given the following method call:

	object:TweenPosition(...)

Replace it with:

	tween.Position(object, ...)

Available functions:
	- Size
	- Position
	- SizeAndPosition
	- Rotation

]]

-- Coerce a value to a given enum. Like most parts of the ROBLOX API, this
-- accepts valid strings/intgers. A default value may also be specified.
local toEnum do
	local cache = {}
	function toEnum(value,enum,default)
		local map = cache[enum]
		if not map then
			map = {}
			local items = enum:GetEnumItems()
			for i = 1,#items do
				local item = items[i]
				map[item] = item
				map[item.Name] = item
				map[item.Value] = item
			end
			cache[enum] = map
		end

		value = map[value]

		if value == nil then
			return map[default]
		end

		return value
	end
end

-- Implementation of EasingDirection
local directionMethod = {
	[Enum.EasingDirection.In] = function(t,f)
		return f(t)
	end;
	[Enum.EasingDirection.Out] = function(t,f)
		return 1- f(1 - t)
	end;
	[Enum.EasingDirection.InOut] = function(t,f)
		if t <= 0.5 then
			return f(2*t)/2
		else
			return (2-f(2*(1-t)))/2
		end
	end;
}

-- Implementation of EasingStyle. Not 1:1 with ROBLOX's tween functions.
local styleMethod = {
	-- matches mathematically
	[Enum.EasingStyle.Linear] = function(x)
		return x
	end;
	-- does not match, but very similar
	[Enum.EasingStyle.Sine] = function(x)
		return x^2 + x^2.6 - x^3
	end;
	-- close enough
	[Enum.EasingStyle.Back] = function(x)
		return x^2 * ((1.75 + 1) * x - 1.75)
	end;
	-- matches mathematically
	[Enum.EasingStyle.Quad] = function(x)
		return x^2
	end;
	-- matches mathematically
	[Enum.EasingStyle.Quart] = function(x)
		return x^4
	end;
	-- matches mathematically
	[Enum.EasingStyle.Quint] = function(x)
		return x^5
	end;
	-- appears to match perfectly
	[Enum.EasingStyle.Bounce] = function(x)
		x = x < 0 and -x or x
		local a = 0
		local b = 1
		while true do
			if x >= (7 - 4 * a) / 11 then
				return -((11 - 6 * a - 11 * x) / 4)^2 + b^2
			end
			a = a + b
			b = b / 2
		end
	end;
	-- does not match, but looks way better
	[Enum.EasingStyle.Elastic] = function(x)
		return 2^(8 * (x-1)) * math.sin(2.5*math.pi*x)
	end;
}

-- Holds functions that interpolate from one value to another given t, per
-- property name.
local propertyMethod = {}

function propertyMethod.Position(s,e,t)
	return UDim2.new(
		s.X.Scale+(e.X.Scale-s.X.Scale)*t,
		s.X.Offset+(e.X.Offset-s.X.Offset)*t,
		s.Y.Scale+(e.Y.Scale-s.Y.Scale)*t,
		s.Y.Offset+(e.Y.Offset-s.Y.Offset)*t
	)
end

propertyMethod.Size = propertyMethod.Position

function propertyMethod.Rotation(s,e,t)
	return s+(e-s)*t
end

-- holds a mutex state per object, per property
local states = {
	Position = {};
	Size = {};
	Rotation = {};
}

local step = Game:GetService('RunService').RenderStepped

function tweenBase(prop,object,endValue,easingDirection,easingStyle,time,override,callback)
	-- check if the given property is already being tweened
	local state = states[prop][object]
	if state then
		if override then
			-- end that tween to make way for this one
			state[1] = false
			states[prop][object] = nil
		else
			return false
		end
	end

	easingDirection = toEnum(easingDirection,Enum.EasingDirection,'Out')
	easingStyle = toEnum(easingStyle,Enum.EasingStyle,'Quad')
	time = time or 1

	-- A bool within a table is used so that the value remains unique to this
	-- thread.
	local state = {true}
	states[prop][object] = state

	local dirMethod = directionMethod[easingDirection]
	local styleMethod = styleMethod[easingStyle]
	local propMethod = propertyMethod[prop]

	local startValue = object[prop]
	local startTime = tick()
	Spawn(function()
		while true do
			-- This this state was overridden, cancel the tween
			if not state[1] then
				if callback then
					-- Tail call! This entire thread gets cleaned up before
					-- the callback runs.
					return callback(Enum.TweenStatus.Canceled)
				end
				return
			end

			local dt = (tick()-startTime)/time
			if dt > 1 then break end

			local t = dirMethod(dt,styleMethod)
			object[prop] = propMethod(startValue,endValue,t)

			step:wait()
		end

		object[prop] = endValue

		states[prop][object] = nil

		if callback then
			return callback(Enum.TweenStatus.Completed)
		end
	end)

	return true
end

return {
	Position = function(...)
		return tweenBase('Position',...)
	end;
	Size = function(...)
		return tweenBase('Size',...)
	end;
	SizeAndPosition = function(object,size,position,dir,style,time,override,callback)
		if not override then
			-- fail if one or the other would fail
			if states.Size[object] or states.Position[object] then
				return false
			end
		end

		tweenBase('Size',object,size,dir,style,time,override,callback)
		tweenBase('Position',object,position,dir,style,time,override,callback)
		return true
	end;
	Rotation = function(...)
		return tweenBase('Rotation',...)
	end;
}
