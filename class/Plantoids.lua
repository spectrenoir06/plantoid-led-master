local class    = require('lib.middleclass')
local Plantoid = require('class.Plantoid')

local json     = require("lib.json")
local inspect  = require("lib.inspect")
local socket   = require("socket")

local animation = require("animation")

require("lib.osc")
require("lib.utils")

local struct = require("lib.struct")
local pack = struct.pack
local upack = struct.unpack

local Plantoids = class('Plantoids')

local LED_FRAMERATE      = 15 -- Hz
local CHECK_REMOTES      = 3 -- secondes

local CLIENT_MUSIC_IP    = "127.0.0.1"       -- ip to connect to super collider
local CLIENT_MUSIC_PORT  = 57120             -- port to connect to super collider

local SERVER_OSC_PORT    = 8000              -- port to listen to sensors OSC data
local SERVER_DATA_PORT   = 8001              -- port to listen to other data ( led info, cmd, ...)

local UPDATE_SCREEN = true

local CMD_UDP_ALIVE = 0

function Plantoids:initialize(replay_file)
	self.sensors = {}
	self.music = {}
	self.plants  = {}

	self.log = {}
	self.log_index = 1
	for i=1,10 do self.log[i] = "" end

	self.socket_osc = assert(socket.udp())
	self.socket_osc:setsockname("0.0.0.0", SERVER_OSC_PORT)
	self.socket_osc:settimeout(0)

	self.socket_data = assert(socket.udp())
	self.socket_data:setsockname("0.0.0.0", SERVER_DATA_PORT)
	self.socket_data:settimeout(0)


	self.timer_led    = 0
	self.replay       = false
	self.replay_index = 1
	self.replay_dump  = {}
	self.time_start   = socket.gettime()
	self.counter      = 0

	self.timer_check  = 10

	local data = require("map")

	for k,v in ipairs(data) do
		self.plants[k] = Plantoid:new(v, self.socket_data)
	end

	if replay_file then
		print("Start replay:", replay_file)
		self.replay_dump = self:load_dump(replay_file)
		self.replay = true
		self.replay_len = #self.replay_dump
	else
		self.replay = false
		self.dump_name = "dump/log-"..os.date("%Y:%m:%d-%H:%M:%S")..".dump"
		self.dump_file = io.open(self.dump_name, "w")
		if self.dump_file then
			print("start dump:", self.dump_name)
			self.dump_file:write(os.time(os.date("!*t")).."\n")
			self.dump = true
		end
	end

	self:setEeprom()

	return self
end

function Plantoids:update(dt, dont_send_led)

	self.timer_led   = self.timer_led + dt
	self.timer_check = self.timer_check + dt

	if not dont_send_led and self.timer_led > (1 / LED_FRAMERATE) then
		self:update_led()
		self.counter = self.counter + 1
		self.timer_led = 0
	end

	if self.timer_check > CHECK_REMOTES then
		self:checkInfo()
		self.timer_check = 0
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

				local to_send = {
					sensor_addr,
					{
						'i', sensor_index,
						"f", sensor_value
					}
				}

				animation.receiveSensor(self, sensor_addr, to_send[2])
				self.socket_osc:sendto(osc.encode(to_send), CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT)
				self.replay_index = self.replay_index + 1
			end
		else
			print("Replay finish")
			return true
		end
	end

	local data, ip, port = self.socket_osc:receivefrom() -- receive data from adc or super collider
	if data then
		if ip == "127.0.0.1" then
			local osc_addr  = osc.get_addr_from_data(data)
			local osc_data  = osc.decode(data)
			-- self:printf("SC Data: addr='"..osc_addr.."'\tdata:"..inspect(osc_data))
			self.music[osc_addr] = osc_data
			animation.receiveSuperCollider(self, osc_addr, osc_data)
		elseif not self.replay then
			local sensor_addr  = osc.get_addr_from_data(data)
			local sensor_data  = osc.decode(data)
			local sensor_index = sensor_data[2]
			local sensor_value = sensor_data[4]

			if self.sensors[sensor_addr] == nil then
				self.sensors[sensor_addr] = {}
			end
			self.sensors[sensor_addr][sensor_index + 1] = sensor_value

			if self.dump then
				self.dump_file:write((socket.gettime() - self.time_start)..";"..sensor_addr..";"..sensor_index..";"..sensor_value.."\n")
			end
			animation.receiveSensor(self, sensor_addr, sensor_data)
			self.socket_osc:sendto(data, CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT)
		end
	end

	local data, ip, port = self.socket_data:receivefrom()
	if data then
		-- print("Received data from:", ip, port, #data);
		local cmd = upack("b", data)
		if cmd == CMD_UDP_ALIVE then
			local seg = self:getSegmentFromIp(ip)
			if seg then
				seg.alive = 2
				_, seg.dist_rgbw, seg.dist_size, seg.dist_vers, seg.dist_name = upack("bbhss", data)
			end
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

------------------- LED Controle ------------------------

function Plantoids:update_led()
	animation.led_animation(self)
end

---------------------------------------------------------------

function Plantoids:stop()
	if self.dump then
		if #self.sensors == 0 then
			print("dump empty remove")
			os.remove(self.dump_name)
		end
		self.dump_file:close()
	end
	for k,plant in ipairs(self.plants) do
		plant:off()
	end
	self.socket_osc:close();
	self.socket_data:close();
end

function Plantoids:getSegmentFromIp(ip)
	for k,v in ipairs(self.plants) do
		for l,w in pairs(v.segments) do
			if w.remote.ip == ip then
				return w
			end
		end
	end
end

function Plantoids:checkInfo()
	for k,v in ipairs(self.plants) do
		for l,w in pairs(v.segments) do
			w:checkInfo()
		end
	end
end

function Plantoids:getSensorValue(addr, index)
	local s = self.sensors[addr]
	if s then
		if index then
			return s[index+1]
		else
			return s
		end
	end
end

function Plantoids:setEeprom()
	for k,v in ipairs(self.plants) do
		for l,w in pairs(v.segments) do
			w:setEeprom(v.name.."_"..l)
		end
	end
end

function Plantoids:updateEsp(bin_file)
	for k,v in ipairs(self.plants) do
		for l,w in pairs(v.segments) do
			if w.alive > 0 then
				w.alive = 0
				w:updateEsp(bin_file)
			end
		end
	end
end

function Plantoids:runCMD(cmd)
	if cmd == "update" then
		self:updateEsp("bin/plantoid-led-driver.ino.bin")
	elseif cmd == "sendinfo" then
		self:setEeprom()
	end
end

function Plantoids:printf(fmt, ...)
	if not self.hide_print then
		print(string.format(fmt, ...))
	end
	table.insert(self.log, string.format(fmt, ...))
	table.remove(self.log, 1)
	self.log_index = self.log_index + 1
end

return Plantoids
