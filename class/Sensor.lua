local class = require 'lib.middleclass'


local inspect  = require('lib.inspect')
local struct = require("lib.struct")
local pack = struct.pack
local upack = struct.unpack

local Sensor = class('Sensor')

local TYPE_GET_INFO = 5
local TYPE_SET_MODE = 9

function Sensor:initialize(remote, socket, plantoid_number, boitier_number)
	self.remote = remote
	self.socket  = socket
	self.plantoid_number = plantoid_number
	self.boitier_number  = boitier_number
	self.alive = 0
	self.data = {
		temp = 0,
		hum = 0,
		sonar = {0, 0},
		adc = {0, 0, 0, 0, 0, 0, 0, 0}
	}
	self.dist_iptosend = {}
end

local floor = math.floor

function Sensor:updateSensor(data)
	local plant,
	nb,
	_,
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
	adc_7 = upack("BBBhhHHHHHHHHHH", data)

	self.data = {
		temp = temp,
		hum = hum,
		sonar = {sonar_1, sonar_2},
		adc = {adc_0, adc_1, adc_2, adc_3, adc_4, adc_5, adc_6, adc_7}
	}
	-- print(inspect(self.data))
end

function Sensor:updateSensorOld(sensor_name, osc_data)
	if sensor_name == "temp" or sensor_name == "hum" then
		self.data[sensor_name] = tonumber(osc_data[4])
	elseif sensor_name == "sonar" then
		self.data[sensor_name][osc_data[2]+1] = tonumber(osc_data[4])
	elseif sensor_name == "analog" then
		self.data["adc"][osc_data[2]+1] = tonumber(osc_data[4])
	end
	-- print(inspect(self.data))
end


function Sensor:checkInfo()
	local to_send = pack('B', TYPE_GET_INFO)
	self.socket:sendto(to_send, self.remote.ip, self.remote.port)
	self.alive = self.alive - 1
	if self.alive < 0 then self.alive = 0 end
end

function Sensor:setEeprom(hostname)
	local ip = {192,168,0,33}
	local to_send = pack('BBBBBBBs', TYPE_SET_MODE, ip[1], ip[2], ip[3], ip[4], self.plantoid_number, self.boitier_number, hostname)
	self.socket:sendto(to_send, self.remote.ip, self.remote.port)
end

function Sensor:updateEsp(bin_file)
	os.execute("python bin/espota.py -i "..self.remote.ip.." -p 8266 --auth= -f "..bin_file.." -P 8266 -d")
end

function Sensor:toString()
	return string.format("Temp: %d; Hum: %d;  Son1: %d;  Son2: %d;  ADC0: %d; ADC1: %d; ADC2: %d; ADC3: %d",
		self.data.temp,
		self.data.hum,
		self.data.sonar[1], self.data.sonar[2],
		self.data.adc[1], self.data.adc[2], self.data.adc[3], self.data.adc[4]
	)
end

function Sensor:serialize()
	return string.format("%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d",
		self.plantoid_number,
		self.boitier_number,
		self.data.temp,
		self.data.hum,
		self.data.sonar[1], self.data.sonar[2],
		self.data.adc[1], self.data.adc[2], self.data.adc[3], self.data.adc[4],
		self.data.adc[5], self.data.adc[6], self.data.adc[7], self.data.adc[8]
	)
end

function Sensor:sendOSC(name, index, value, ip, port)
	local base_addr = "/plantoid/"..self.plantoid_number.."/"..self.boitier_number.."/"
	local to_send = {
		base_addr..name,
		{ 'i', index, "f", value }
	}
	self.socket:sendto(osc.encode(to_send), ip, port)
end

function Sensor:sendToSC(ip, port)
	self:sendOSC("temp",  0, self.data.temp,     ip, port);
	self:sendOSC("hum",   0, self.data.hum,      ip, port);
	self:sendOSC("sonar", 0, self.data.sonar[1], ip, port);
	self:sendOSC("sonar", 1, self.data.sonar[2], ip, port);
	for i=1,8 do
		self:sendOSC("analog", i-1, self.data.adc[i], ip, port);
	end
end

return Sensor
