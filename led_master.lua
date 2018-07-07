#!/usr/bin/env lua

require("lib.osc")
local socket  = require("socket")
local inspect = require("lib.inspect")
local signal  = require("posix.signal")
local json    = require("lib.json")

local Plantoid = require("class.Plantoid")
local Segment = require("class.Segment")

local file = io.open("map.json", "r")
local text = file:read("*a")
local data = json.decode(text)
file:close()

local CLIENT_MUSIC_IP    = "127.0.0.1"       -- ip to connect to super collider
local CLIENT_MUSIC_PORT  = 57120             -- port to connect to super collider

local SERVER_SENSOR_PORT = 8000              -- port to listen to sensors OSC data
local SERVER_MUSIC_PORT  = 8001              -- port to listen to super collider OSC data
local SERVER_DATA_PORT   = 8002              -- port to listen to other data ( led info, cmd, ...)

local LED_FRAMERATE = 15

local dt = 0.000001
local time = socket.gettime()

local timer_led = 0

local sensors = {}
local plants = {}


local replay       = false
local replay_index = 1
local replay_dump  = {}

local time_start_epoch = os.time(os.date("!*t"))
local time_start_cpu   = socket.gettime()

local counter = 0

local udp = assert(socket.udp())
udp:setsockname("*", SERVER_SENSOR_PORT)
udp:settimeout(0)

function update_led(c)
	local plant = plants[1]

	local color = color_wheel(c*3)

	plant:setAllPixel({10,0,0}, "Anneaux", 1)
	plant:setAllPixel({0,10,0}, "Anneaux", 2)
	plant:setAllPixel({0,0,10}, "Anneaux", 3)
	plant:setAllPixel({10,0,0}, "Anneaux", 4)
	plant:setAllPixel(color,    "Anneaux", 5)
	plant:setAllPixel({0,0,10}, "Anneaux", 6)

	plant:setPixel(8, color, "Anneaux", 1)

	-- seg:sendLerp(0,{100,0,0}, {0,100,0}, 32)


	plant:sendAll(true) -- send all rgbw data to driver, ( true if update led)
	-- plant:show()
end


function load_dump(name)
	local file = io.open(name, "r")
	local lines = {}
	local lst_time = 0

	local timestamp = file:read()

	while true do
		line = file:read()
		if line == nil then break end
		local time, address, index ,data = line:match("([^,]+);([^,]+);([^,]+);([^,]+)")
		lst_time = time
		table.insert(lines, {tonumber(time), address, tonumber(index), tonumber(data)})
	end
	file:close()
	return lines
end

function color_wheel(WheelPos)
	WheelPos = WheelPos % 255
	WheelPos = 255 - WheelPos
	if (WheelPos < 85) then
		return {255 - WheelPos * 3, 0, WheelPos * 3}
	elseif (WheelPos < 170) then
		WheelPos = WheelPos - 85
		return {0, WheelPos * 3, 255 - WheelPos * 3}
	else
		WheelPos = WheelPos - 170
		return {WheelPos * 3, 255 - WheelPos * 3, 0}
	end
end

signal.signal(signal.SIGINT, function(signum)
	io.write("\n")

	for k,plant in ipairs(plants) do
		plant:off()
	end
	udp:close();
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


for k,v in ipairs(data) do
	plants[k] = Plantoid:new(v, udp)
end

while true do
	dt = socket.gettime() - time
	time = socket.gettime()

	timer_led = timer_led + dt
	if timer_led > (1 / LED_FRAMERATE) then

		update_led(counter)

		counter = counter + 1
		timer_led = 0
	end

	if replay then
		if replay_index < replay_len then
			if replay_dump[replay_index][1] <= socket.gettime() - time_start_cpu then
				local sensor_addr  = replay_dump[replay_index][2]
				local sensor_index = replay_dump[replay_index][3]
				local sensor_value = replay_dump[replay_index][4]

				local to_send = {
					sensor_addr,
					{
						'i', sensor_index,
						"f", sensor_value
					}
				}
				-- print(inspect(to_send))
				if sensors[sensor_addr] == nil then
					sensors[sensor_addr] = {}
				end
				sensors[sensor_addr][sensor_index + 1] = sensor_value
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
			assert(udp:sendto(data, CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT))
			-- print("Received: ", ip, port, #data);
			local sensor_addr  = osc.get_addr_from_data(data)
			local sensor_data  = osc.decode(data)
			local sensor_index = sensor_data[2]
			local sensor_value = sensor_data[4]

			if sensors[sensor_addr] == nil then
				sensors[sensor_addr] = {}
			end

			sensors[sensor_addr][sensor_index + 1] = sensor_value
			os.execute("clear")
			print(inspect(sensors))
			-- print(socket.gettime() - time_start_cpu, addr, value[2])
			file:write((socket.gettime() - time_start_cpu)..";"..sensor_addr..";"..sensor_index..";"..sensor_value.."\n")
		end
	end
	socket.sleep(0.001)
end
