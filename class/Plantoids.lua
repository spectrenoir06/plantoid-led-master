local class    = require('lib.middleclass')
local Plantoid = require('class.Plantoid')

local json     = require("lib.json")
local inspect  = require("lib.inspect")
local socket   = require("socket")

require("lib.osc")
require("lib.utils")

local Plantoids = class('Plantoids')

local LED_FRAMERATE      = 15
local CLIENT_MUSIC_IP    = "127.0.0.1"       -- ip to connect to super collider
local CLIENT_MUSIC_PORT  = 57120             -- port to connect to super collider

local SERVER_SENSOR_PORT = 8000              -- port to listen to sensors OSC data
local SERVER_MUSIC_PORT  = 8001              -- port to listen to super collider OSC data
local SERVER_DATA_PORT   = 8002              -- port to listen to other data ( led info, cmd, ...)

function Plantoids:initialize(replay_file)
	self.sensors = {}
	self.plants  = {}

	self.udp = assert(socket.udp())
	self.udp:setsockname("*", SERVER_SENSOR_PORT)
	self.udp:settimeout(0)

	self.timer_led    = 0
	self.replay       = false
	self.replay_index = 1
	self.replay_dump  = {}
	self.time_start   = socket.gettime()
	self.counter      = 0

	local file = io.open("map.json", "r")
	local text = file:read("*a")
	local data = json.decode(text)
	file:close()

	for k,v in ipairs(data) do
		self.plants[k] = Plantoid:new(v, self.udp)
	end

	if replay_file then
		print("Start replay:", replay_file)
		self.replay_dump = self:load_dump(replay_file)
		self.replay = true
		self.replay_len = #self.replay_dump
	else
		self.replay = false
		print("start dump:", "log.dump")
		self.dump_file = io.open("dump/log.dump", "w")
		self.dump_file:write(os.time(os.date("!*t")).."\n")
	end

	return self
end

function Plantoids:update(dt)

	self.timer_led = self.timer_led + dt
	if self.timer_led > (1 / LED_FRAMERATE) then

		self:update_led()

		self.counter = self.counter + 1
		self.timer_led = 0
	end

	if self.replay then
		if self.replay_index < self.replay_len then
			local replay_data = self.replay_dump[self.replay_index]
			if replay_data[1] <= socket.gettime() - self.time_start then
				local sensor_addr  = replay_data[2]
				local sensor_index = replay_data[3]
				local sensor_value = replay_data[4]

				-- print(inspect(to_send))
				if self.sensors[sensor_addr] == nil then
					self.sensors[sensor_addr] = {}
				end
				self.sensors[sensor_addr][sensor_index + 1] = sensor_value
				os.execute("clear")
				print(inspect(self.sensors))

				local to_send = {
					sensor_addr,
					{
						'i', sensor_index,
						"f", sensor_value
					}
				}

				assert(self.udp:sendto(osc.encode(to_send), CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT))
				self.replay_index = self.replay_index + 1
			end
		else
			print("Replay finish")
			-- break
		end
	else
		local data, ip, port = self.udp:receivefrom() -- receive data from led, adc or super collider
		if data then
			assert(self.udp:sendto(data, CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT))
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
			-- print(socket.gettime() - time_start, addr, value[2])
			file:write((socket.gettime() - time_start)..";"..sensor_addr..";"..sensor_index..";"..sensor_value.."\n")
		end
	end
end

function Plantoids:load_dump(name)
	local file = io.open(name, "r")
	local lines = {}
	local lst_time = 0

	local timestamp = file:read()

	while true do
		local line = file:read()
		if line == nil then break end
		local time, address, index ,data = line:match("([^,]+);([^,]+);([^,]+);([^,]+)")
		lst_time = time
		table.insert(lines, {tonumber(time), address, tonumber(index), tonumber(data)})
	end
	file:close()
	return lines
end

function Plantoids:update_led()
	local plant = self.plants[1]

	local color = color_wheel(self.counter)

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

function Plantoids:stop()
	for k,plant in ipairs(self.plants) do
		plant:off()
	end
	self.udp:close();
end

return Plantoids