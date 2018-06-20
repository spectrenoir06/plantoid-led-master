local socket = require("socket")
local inspect = require("inspect")

require "struct"

local LED_IP        = "192.168.12.50"
local LED_PORT      = 12345
local SERVER_PORT   = 8000

local TYPE_LED_RAW  = 0
local TYPE_GET_INFO = 1

local LED_FRAMERATE = 20


function decode_frac(bin)
	local frac = 0
	for i=#bin,1 do
		frac = (frac + string.sub(bin, i-1, i)) / 2
	end
	return frac
end

function decode_float(bin)
	local res = struct.unpack(">f", bin)
	return res
end

function decode_int(bin)
	local res = struct.unpack(">I", bin)
	return res
end


function next_string(astring)
	-- this is a workaraound because the lua pttern matching is
	-- not as powerful as pcre and I did not want to include another
	-- dependecy to an external re lib
	local pos = 0
	local num_nzero = 0
	local num_zero = 0
	local result = ""
	if astring == nil then
		-- ensure that string is not empty
		print("error: string is empty - probably malformated message")
	end
	-- we match every character with the help of gmatch
	for m in string.gmatch(astring, ".") do
		pos = pos + 1
		-- and then check if it is correctly padded with '\0's
		if m ~= '\0' and num_zero == 0 then
			num_nzero = (num_nzero + 1) % 4
			result = result .. m
		elseif num_zero ~= 0 and (num_zero + num_nzero) % 4 == 0 then
			return result, pos
		elseif m == '\0' then
			num_zero = num_zero + 1
			result = result .. m
		else
			return nil
		end
	end
end

function collect_decoding_from_message(t, data, message)
	table.insert(message, t)
	if t == 'i' then
		table.insert(message, decode_int(data))
		return string.sub(data, 5)
	elseif t == 'f' then
		table.insert(message, decode_float(data))
		return string.sub(data, 5)
	elseif t == 's' then
		local match, last = next_string(data)
		table.insert(message, match)
		return string.sub(data, last)
	elseif t == 'b' then
		local length = decode_int(data)
		table.insert(message, string.sub(data, 4, length))
		return string.sub(data, 4 + length + 1)
	end
end


function get_addr_from_data(data)
	local addr_raw_string,last = next_string(data)
	local result = ""
	if addr_raw_string == nil then
		-- if we could not find an addr something went wrong
		print("error: could not extract address from OSC message")
	end
	-- delete possible trailing zeros
	for t in string.gmatch(addr_raw_string, "[^%z]") do
		result = result .. t
	end
	return result, string.sub(data, last)
end

function get_types_from_data(data)
	local typestring, last = next_string(data)
	local result = {}
	if typestring == nil then
		return {}
	end
	-- split typestring into an iterable table
	for t in string.gmatch(typestring, "[^,%z]") do
		table.insert(result, t)
	end
	return result, string.sub(data, last)
end



function decode_message(data)
	local types, addr, tmp_data = nil
	local message = {}
	addr, tmp_data = get_addr_from_data(data)
	types, tmp_data = get_types_from_data(tmp_data)
	-- ensure that we at least found something
	if addr == nil or types == nil then
		return nil
	end
	for _,t in ipairs(types) do
		tmp_data = collect_decoding_from_message(t, tmp_data, message)
	end
	return message
end


local udp = assert(socket.udp())
udp:setsockname("*", SERVER_PORT)
udp:settimeout(0)

function send_led(c)
	local to_send = struct.pack('Bhh', TYPE_LED_RAW, 0, 30)
	for j=0,30 do
		to_send = to_send .. struct.pack('BBB',
			((math.sin((j+c) * 2 * math.pi + math.pi) + 1) / 2) * 20,
			((math.sin((j+c) * 2 * math.pi) + 1) / 2) * 20,
			((math.sin((j+c) * 2 * math.pi) + 1) / 2) * 100 + 40
		)
	end
	assert(udp:sendto(to_send, LED_IP, LED_PORT))
end

local counter = 0
local dt = 0.000001
local time = socket.gettime()

local timer_led = 0

sensors = {}

while true do
	dt = socket.gettime() - time
	time = socket.gettime()

	timer_led = timer_led + dt
	if timer_led > (1/LED_FRAMERATE) then
		send_led(counter/100)
		counter = counter + 1
		timer_led = 0
	end

	data, ip, port = udp:receivefrom() -- receive from led, adc and super collider
	if data then
		print("Received: ", ip, port, #data)
		local addr = get_addr_from_data(data)
		local value = decode_message(data)
		sensors[addr] = value[2];
		print(inspect(sensors))
	end
	socket.sleep(0.01)
end
