#!/usr/bin/env lua

require("lib.osc")
local socket  = require("socket")
local inspect = require("lib.inspect")
local struct  = require("lib.struct")
local signal  = require("posix.signal")
local json    = require("lib.json")

local Plantoid = require("class.Plantoid")
local Segment = require("class.Segment")

local file = io.open("map.json", "r")
local text = file:read("*a")
local data = json.decode(text)
file:close()

local CLIENT_MUSIC_IP    = "192.168.1.37"       -- ip to connect to super collider
local CLIENT_MUSIC_PORT  = 8000             -- port to connect to super collider

local SERVER_SENSOR_PORT = 8000              -- port to listen to sensors OSC data
local SERVER_MUSIC_PORT  = 8001              -- port to listen to super collider OSC data
local SERVER_DATA_PORT   = 8002              -- port to listen to other data ( led info, cmd, ...)

local LED_FRAMERATE = 15

local dt = 0.000001
local time = socket.gettime()

local timer_led = 0

sensors = {}

local replay       = false
local replay_index = 1
local replay_dump  = {}

local time_start_epoch = os.time(os.date("!*t"))
local time_start_cpu   = socket.gettime()

local counter = 0

local udp = assert(socket.udp())
udp:setsockname("*", SERVER_SENSOR_PORT)
udp:settimeout(0)

local plant = Plantoid:new(data[2], udp)

function SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
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
	print(SecondsToClock(lst_time))
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

	plant:off()

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
	-- print(time)
	dt = socket.gettime() - time
	time = socket.gettime()

	timer_led = timer_led + dt
	if timer_led > (1 / LED_FRAMERATE) then

		-- plant:setPixel(0, {0,255,0}, "Petales", 2)
		-- plant:setPixel(0, {0,0,255}, "Petales", 3)

		-- for petale_nb=1, 3 do
			-- local size = plant:getPartSize("Spots", 1)
			-- for i=0, size do
			-- 	plant:setPixel(i, color_wheel(i+counter/size*255), "Spots", 1)
			-- end
		-- end
		-- plant:show("Petales")
		-- for i=0,counter do
		-- 	plant:setPixel(i, {0,0,0,10}, "Spots", 1)
		-- end

		-- local test = counter % 30

		-- for i=0, test do
		-- 	plant:setPixel(i, {0,0,0,50}, "Spots", 1)
		-- end

		-- local t = {
		-- 	1,
		-- 	8,
		-- 	12,
		-- 	16,
		-- 	24,
		-- 	32,
		-- 	40,
		-- 	48,
		-- 	60,
		-- }

		-- local pos = 0 --counter % 60
		-- local pos_f = pos / 60
		-- local off = 0


		-- -- off = 181

		-- -- for k,v in ipairs(t) do
		-- 	local test = 8
		-- 	for i=1, test do
		-- 		off = off + t[i]
		-- 	end
		-- 	off = 183
		-- 	local k,v = 1, t[test]
		-- 	local s, e = pos_f*v, pos_f*v + v - 1
		-- 	print(k,v,off,pos_f,s,e)
		-- 	-- print(s,e)
		-- 	for i=s, e do
		-- 		print(i)
		-- 		if i > (pos_f*v + v/2) then
		-- 			plant:setPixel((i%v)+off, {255,0,0,0}, "Spots", 1)
		-- 		else
		-- 			plant:setPixel((i%v) + off, {0,255,0,0}, "Spots", 1)
		-- 		end
		-- 	end
		-- 	off = off + v
		-- -- end
		-- -- 	for i=pos_f*v, pos_f*v + v do
		-- -- 		if i > (pos_f*v+v/2) then
		-- -- 			plant:setPixel((i%v)+133, {255,0,0,0}, "Spots", 1)
		-- -- 		else
		-- -- 			plant:setPixel((i%v)+133, {0,255,0,0}, "Spots", 1)
		-- -- 		end
		-- -- 	end

		-- -- end
		local c  = color_wheel(counter)
		c[1] = c[1] / 4
		c[2] = c[2] / 4
		c[3] = c[3] / 4
		plant:setAllPixel(
			c,
			"Tiges",
			1
		)
		--plant:show("Tiges",1)
		-- plant.segments[1]:show("Spots", 1)
		-- plant:send(100, 100, true)
		-- print(plant:getPartSize("Spots",1))

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
					replay_dump[replay_index][2],
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
				-- os.execute("clear")
				-- print(inspect(sensors))

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
			print("Received: ", ip, port, #data);
			local sensor_addr  = osc.get_addr_from_data(data)
			local sensor_data  = osc.decode(data)
			local sensor_index = value[2]
			local sensor_value = value[4]

			if sensors[sensor_addr] == nil then
				sensors[sensor_addr] = {}
			end

			sensors[sensor_addr][sensor_index + 1] = sensor_value
			os.execute("clear")
			print(inspect(sensors))
			-- print(socket.gettime() - time_start_cpu, addr, value[2])
			file:write((socket.gettime() - time_start_cpu)..";"..addr..";"..sensor_index..";"..sensor_value.."\n")
		end
	end
	socket.sleep(0.001)
end
