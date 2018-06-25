#!/usr/bin/env lua

require("lib.osc")
local socket  = require("socket")
local inspect = require("lib.inspect")
local struct  = require("lib.struct")
local signal  = require("posix.signal")


local LED_IP             = "192.168.12.50"        -- ip to connect to led driver
local LED_PORT           = 12345                  -- port to connect to led driver

local CLIENT_MUSIC_IP    = "127.0.0.1"       -- ip to connect to super collider
local CLIENT_MUSIC_PORT  = 54321             -- port to connect to super collider

local SERVER_SENSOR_PORT = 8000              -- port to listen to sensors OSC data
local SERVER_MUSIC_PORT  = 8001              -- port to listen to super collider OSC data
local SERVER_DATA_PORT   = 8002              -- port to listen to other data ( led info, cmd, ...)

local TYPE_LED_RAW  = 0
local TYPE_LED_RAW_RGBW = 1
local TYPE_GET_INFO = 2

local LED_FRAMERATE = 20

local dt = 0.000001
local time = socket.gettime()

local timer_led = 0

sensors = {}

local replay = false
local replay_index = 1
local replay_dump = {}

local time_start_epoch = os.time(os.date("!*t"))
local time_start_cpu   = socket.gettime()

local counter = 0

local udp = assert(socket.udp())
udp:setsockname("*", SERVER_SENSOR_PORT)
udp:settimeout(0)


function send_led(c)
	local to_send = struct.pack('Bhh', TYPE_LED_RAW, 0, 93)
	for j=0,93 do
		local r, g, b = color_wheel(c*5)
		to_send = to_send .. struct.pack('BBB', r, g, b)
	end
	assert(udp:sendto(to_send, LED_IP, LED_PORT))
end

function load_dump(name)
	local file = io.open(name, "r")
	local lines = {}

	local timestamp = file:read()

	while true do
		line = file:read()
		if line == nil then break end
		time, address, data = line:match("([^,]+);([^,]+);([^,]+)")
		table.insert(lines, {tonumber(time), address, tonumber(data)})
	end
	file:close()
	return lines
end

function color_wheel(WheelPos)
	WheelPos = WheelPos % 255
	WheelPos = 255 - WheelPos
	if (WheelPos < 85) then
		return 255 - WheelPos * 3, 0, WheelPos * 3
	elseif (WheelPos < 170) then
		WheelPos = WheelPos - 85
		return 0, WheelPos * 3, 255 - WheelPos * 3
	else
		WheelPos = WheelPos - 170
		return WheelPos * 3, 255 - WheelPos * 3, 0
	end
end

signal.signal(signal.SIGINT, function(signum)
	io.write("\n")

	local to_send = struct.pack('Bhh', TYPE_LED_RAW, 0, 93)
	for j=0,93 do
		to_send = to_send .. struct.pack('BBB', 0, 0, 0)
	end
	assert(udp:sendto(to_send, LED_IP, LED_PORT))

	udp:close();
	-- put code to save some stuff here
	os.exit(128 + signum)
end)


if arg[1] == "replay" then
	print("Start replay:", arg[2])
	replay_dump = load_dump(arg[2])
	replay = true
	replay_len = #replay_dump
else
	replay = false
	print("start dump:", "log.dump")
	file = io.open("dump/log.dump", "w")
	file:write(time_start_epoch .. "\n")
end

while true do
	dt = socket.gettime() - time
	time = socket.gettime()

	timer_led = timer_led + dt
	if timer_led > (1 / LED_FRAMERATE) then
		send_led(counter)
		counter = counter + 1
		timer_led = 0
	end

	if replay then
		if replay_index < replay_len then
			while replay_dump[replay_index][1] <= socket.gettime() - time_start_cpu do
				local to_send = { replay_dump[replay_index][2], { 'f', replay_dump[replay_index][3]}}
				--print(inspect(to_send))
				sensors[replay_dump[replay_index][2]] = replay_dump[replay_index][3]
				os.execute("clear")
				print(inspect(sensors))
				assert(udp:sendto(osc.encode(to_send), CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT))
				replay_index = replay_index + 1
			end
		else
			print("Replay finish")
			break
		end
	else
		local data, ip, port = udp:receivefrom() -- receive data from led, adc or super collider
		if data then
			-- print("Received: ", ip, port, #data)
			local addr = osc.get_addr_from_data(data)
			local value = osc.decode(data)
			sensors[addr] = value[2]
			os.execute("clear")
			print(inspect(sensors))
			-- print(socket.gettime() - time_start_cpu, addr, value[2])
			file:write((socket.gettime() - time_start_cpu)..";"..addr..";"..value[2].."\n")
		end
	end
	socket.sleep(0.0001)
end
