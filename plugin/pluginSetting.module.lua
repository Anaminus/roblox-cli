local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function encodeBase64(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function decodeBase64(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function serialize(t)
	local tt = type(t)
	if tt == 'string' then
		return string.format('%q',t)
	elseif tt == 'table' then
		local o = '{'
		local first = true
		if t[1] then
			first = false
			o=o .. serialize(t[1])
			for i = 2,#t do
				o=o .. ',' .. serialize(t[i])
			end
		end
		for k,v in pairs(t) do
			if type(k) == 'number' then
				if math.floor(k) ~= k or k < 1 or k > #t then
					if not first then o=o .. ',' end
					o=o .. '[' .. k .. ']=' .. serialize(v)
				end
			elseif type(k) == 'string' and k:match('^[%w_][%w%d_]*$') then
				if not first then o=o .. ',' end
				o=o .. k ..'=' .. serialize(v)
			else
				if not first then o=o .. ',' end
				o=o .. '[' .. serialize(k) .. ']=' .. serialize(v)
			end
			first = false
		end
		return o .. '}'
	elseif tt == 'function' or tt == 'thread' or tt == 'userdata' then
		return 'nil'
	else
		return tostring(t)
	end
end

local function dataGet(plugin)
	local data = plugin:GetSetting('data')
	if data == nil then return {} end
	data = decodeBase64(data)
	return loadstring('return ' .. data)()
end

local function dataSet(plugin,data)
	data = serialize(data)
	data = encodeBase64(data)
	plugin:SetSetting('data',data)
end

return function(plugin)
	return {
		Get = function(key)
			return dataGet(plugin)[key]
		end;
		Set = function(key,value)
			local data = dataGet(plugin)
			data[key] = value
			dataSet(plugin,data)
		end;
	}
end
