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

local SERVER_PORT   = 8000
local UPDATE_SCREEN = true

local CMD_UDP_ALIVE  = 0
local CMD_UDP_SENSOR = 1
local CMD_UDP_OSC   = 47

function Plantoids:initialize(replay_file)
	self.osc     = {}
	self.plants  = {}

	self.log = {}
	self.log_index = 1
	for i=1,100 do self.log[i] = "" end

	self.socket = assert(socket.udp())
	self.socket:setsockname("0.0.0.0", SERVER_PORT)
	self.socket:settimeout(0)

	self.timer_led    = 0
	self.replay       = false
	self.replay_index = 1
	self.replay_dump  = {}
	self.time_start   = socket.gettime()
	self.counter      = 0

	self.timer_check  = 10

	local data = require("map")

	for k,v in ipairs(data) do
		self.plants[k] = Plantoid:new(v, self.socket, k)
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
				local sensor = self.plants[replay_data[2]].sensors[replay_data[3]]
				sensor.data = replay_data[4]

				animation.receiveSensor(self, sensor)
				sensor:sendToSC(CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT)
				self.replay_index = self.replay_index + 1
			end
		else
			print("Replay finish")
			return true
		end
	end

	local data, ip, port = self.socket:receivefrom()
	if data then
		local cmd = upack("B", data)
		-- self:printf("Received data from: %s %d  cmd: %d size: %d", ip, port, cmd, #data);
		if cmd == CMD_UDP_ALIVE then
			data = data:sub(2)
			local seg = self:getSegmentFromIp(ip)
			if seg then
				seg.alive = 2
				seg.dist_rgbw, seg.dist_size, seg.dist_vers, seg.dist_name = upack("BHss", data)
			else
				local sensor = self:getSensorFromIp(ip)
				sensor.alive = 2
				sensor.dist_iptosend[1], sensor.dist_iptosend[2] , sensor.dist_iptosend[3], sensor.dist_iptosend[4], sensor.dist_vers, sensor.dist_name = upack("BBBBss", data)
			end
		elseif cmd == CMD_UDP_SENSOR and not self.replay then
			data = data:sub(2)
			local plant,
			nb = upack("BB", data)
			if self.plants[plant] and self.plants[plant].sensors[nb] then
				local sensor = self.plants[plant].sensors[nb]
				sensor:updateSensor(data)
				animation.receiveSensor(self, sensor)
				if self.dump then
					self.dump_file:write((socket.gettime() - self.time_start)..";"..sensor:serialize().."\n")
				end
				sensor:sendToSC(CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT)
			else
				self:printf("Data from unknow sensor ( %d, %d )", plant, nb)
			end
		elseif cmd == CMD_UDP_OSC then
			local osc_addr  = osc.get_addr_from_data(data)
			local osc_data  = osc.decode(data)
			self.osc[osc_addr] = osc_data
			animation.receiveOSC(self, osc_addr, osc_data)
			if osc_addr:match("([^/]+)/") == "plantoid" then -- old osc sensor
				local name, plantoid_number, boitier_number, sensor_name = osc_addr:match("([^/]+)/([^/]+)/([^/]+)/([^/]+)")
				if self.plants[tonumber(plantoid_number)] and self.plants[tonumber(plantoid_number)].sensors[tonumber(boitier_number)] then
					local sensor = self.plants[tonumber(plantoid_number)].sensors[tonumber(boitier_number)]
					sensor:updateSensorOld(sensor_name, osc_data)
					animation.receiveSensor(self, sensor)
					if self.dump then
						self.dump_file:write((socket.gettime() - self.time_start)..";"..sensor:serialize().."\n")
					end
					sensor:sendToSC(CLIENT_MUSIC_IP, CLIENT_MUSIC_PORT)
				else
					self:printf("Data from unknow sensor ( %s, %s )", plantoid_number, plantoid_number)
				end
			end
		else
			self:printf("Unknow UDP packet Type %d, %s", cmd, data)
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
		local time,
		plant,
		nb,
		temp,
		hum,
		sonar_1,
		sonar_2,
		adc_0,
		adc_1,
		adc_2,
		adc_3,
		adc_4,
		adc_5,
		adc_6,
		adc_7 = line:match("([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+);([^,]+)")
		table.insert(lines, {
			tonumber(time),
			tonumber(plant),
			tonumber(nb),
			{
				temp = temp,
				hum = hum,
				sonar = {sonar_1, sonar_2},
				adc = {adc_0, adc_1, adc_2, adc_3, adc_4, adc_5, adc_6, adc_7}
			}
		})
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
		-- self.dump_file:close()
		-- if #self.sensors == 0 then
		-- 	print("dump empty remove")
		-- 	os.remove(self.dump_name)
		-- end
	end
	for k,plant in ipairs(self.plants) do
		plant:off()
	end
	self.socket:close();
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

function Plantoids:getSensorFromIp(ip)
	for k,v in ipairs(self.plants) do
		for l,w in ipairs(v.sensors) do
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
		for l,w in ipairs(v.sensors) do
			w:checkInfo()
		end
	end
end

function Plantoids:getSensorValue(addr, index)
	-- local s = self.sensors[addr]
	-- if s then
	-- 	if index then
	-- 		return s[index+1]
	-- 	else
	-- 		return s
	-- 	end
	-- end
end

function Plantoids:setEeprom()
	for k,v in ipairs(self.plants) do
		for l,w in pairs(v.segments) do
			w:setEeprom(v.name.."_"..l)
		end
		for l,w in ipairs(v.sensors) do
			w:setEeprom(v.name.."_"..l)
		end
	end
end

function Plantoids:updateLed(bin_file)
	for k,v in ipairs(self.plants) do
		for l,w in pairs(v.segments) do
			if w.alive > 0 then
				w.alive = 0
				w:updateEsp(bin_file)
			end
		end
	end
end

function Plantoids:updateSensor(bin_file)
	for k,v in ipairs(self.plants) do
		for l,w in ipairs(v.sensors) do
			if w.alive > 0 then
				w.alive = 0
				w:updateEsp(bin_file)
			end
		end
	end
end

function Plantoids:runCMD(cmd)
	if cmd == "updateled" then
		self:updateLed("bin/plantoid-led-driver.ino.bin")
	elseif cmd == "updatesensor" then
		self:updateSensor("bin/plantoid-sensor-driver.ino.bin")
	elseif cmd == "update" then
		self:updateLed("bin/plantoid-led-driver.ino.bin")
		self:updateSensor("bin/plantoid-sensor-driver.ino.bin")
	elseif cmd == "seteeprom" then
		self:setEeprom()
	end
end

function Plantoids:printf(fmt, ...)
	if not self.hide_print then
		print(string.format(fmt, ...))
	end
	local str = string.format(fmt, ...)
	for line in string.gmatch(str, '([^\n]+)') do
		table.insert(self.log, line)
		table.remove(self.log, 1)
	end
	self.log_index = self.log_index + 1
end

return Plantoids
