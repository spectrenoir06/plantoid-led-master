#!/usr/bin/env lua

local socket = require("socket")
local inspect = require("inspect")
local osc = require "osc"
require "struct"

local LED_IP        = "192.168.12.50"
local LED_PORT      = 12345

local MUSIC_IP        = "127.0.0.1"
local MUSIC_PORT      = 54321

local SERVER_PORT   = 8000

local TYPE_LED_RAW  = 0
local TYPE_GET_INFO = 1

local LED_FRAMERATE = 20

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

local time_start_epoch = os.time(os.date("!*t"))
local time_start_cpu   = socket.gettime()

local replay = false
local replay_index = 1
local replay_dump = {}

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

if arg[1] == "replay" then
	print("Start replay:", arg[2])
	replay_dump = load_dump(arg[2])
	replay = true
	replay_len = #replay_dump
else
	replay = false
	print("start dump:","log.dump")
	file = io.open("log.dump", "w")
	file:write(time_start_epoch .. "\n")
end

while true do
	dt = socket.gettime() - time
	time = socket.gettime()

	timer_led = timer_led + dt
	if timer_led > (1 / LED_FRAMERATE) then
		send_led(counter/100)
		counter = counter + 1
		timer_led = 0
	end

	if replay then
		if replay_index < replay_len then
			if replay_dump[replay_index][1] <= socket.gettime() - time_start_cpu then
				local to_send = { replay_dump[replay_index][2], { 'f', replay_dump[replay_index][3]}}
				print(inspect(to_send))
				assert(udp:sendto(osc.encode(to_send), MUSIC_IP, MUSIC_PORT))
				replay_index = replay_index + 1
			end
		else
			print("Replay finish")
			break
		end
	else
		local data, ip, port = udp:receivefrom() -- receive from led, adc and super collider
		if data then
			-- print("Received: ", ip, port, #data)
			local addr = osc.get_addr_from_data(data)
			local value = osc.decode(data)
			sensors[addr] = value[2]
			print(socket.gettime() - time_start_cpu, addr, value[2])
			file:write((socket.gettime() - time_start_cpu)..";"..addr..";"..value[2].."\n")
		end
	end
	socket.sleep(0.0001)
end
