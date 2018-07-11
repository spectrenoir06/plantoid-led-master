local class = require 'lib.middleclass'

local struct = require("lib.struct")
local pack = struct.pack
local upack = struct.unpack

local Segment = class('Segment')

local TYPE_LED_RAW                 = 0
local TYPE_LED_RAW_AND_UPDATE      = 1
local TYPE_LED_RAW_RGBW            = 2
local TYPE_LED_RAW_RGBW_AND_UPDATE = 3
local TYPE_LED_UPDATE              = 4
local TYPE_GET_INFO                = 5
local TYPE_LED_TEST                = 6
local TYPE_LED_RGBW_SET            = 7
local TYPE_LED_LERP                = 8
local TYPE_SET_MODE                = 9

local MAX_UPDATE_SIZE = 1280 -- max 1280 after the driver explode == 320 RGBW LEDs or 426 RGB LEDs

function init_tab(nb, color)
	local t = {}
	for i=1, nb do
		t[i] = color or {0,0,0,0}
	end
	return t
end

function Segment:initialize(remote, socket)
	self.data = init_tab(remote.size)
	self.remote = remote
	self.RGBW = remote.RGBW
	self.size = remote.size
	self.socket  = socket
	self.alive = 0
end

local floor = math.floor


----- Only update master -----


function Segment:setPixel(index, color)
	-- print("setPixel",index, self.size)
	if index >= 0 and index < self.size then
		self.data[index+1][1] = color[1]
		self.data[index+1][2] = color[2]
		self.data[index+1][3] = color[3]
		self.data[index+1][4] = color[4] or 0
	end
end

function Segment:setAllPixels(color)
	for i=0, self.size-1 do
		self:setPixel(i, color)
	end
end

function Segment:setLerp(off, color1, color2, size)
	color1[4] = color1[4] or 0
	color2[4] = color2[4] or 0

	local ir = (color2[1] - color1[1]) / size
	local ig = (color2[2] - color1[2]) / size
	local ib = (color2[3] - color1[3]) / size
	local iw = (color2[4] - color1[4]) / size
	for i=0, size-1 do
		self:setPixel(i + off, color1);
		color1[1] = color1[1] + ir
		color1[2] = color1[2] + ig
		color1[3] = color1[3] + ib
		color1[4] = color1[4] + iw
	end
end

function Segment:clear(off, size)
	off = off or 0
	size = size or self.size - off
	for i=0, size-1 do
		self:setPixel(i+off, {0,0,0,0})
	end
end


----- Update master and send to driver -----

function Segment:show()
	self:sendRawData(TYPE_LED_UPDATE, 0, 0, nil)
end

function Segment:sendPixels(off, color, size)
	size = size or 1
	for i=0, size-1 do
		self:setPixel(i + off, color)
	end
	self:sendRawData(TYPE_LED_RGBW_SET, off, size, pack("bbbb", color[1], color[2], color[3], color[4] or 0))
end

function Segment:sendAll(update)
	local max_update = math.floor(MAX_UPDATE_SIZE / 3)
	if self.RGBW then
		max_update = math.floor(MAX_UPDATE_SIZE / 4)
	end
	local nb_update = math.ceil(self.size / max_update)
	-- print("nb_update", nb_update)
	for i=0, nb_update-2 do
		self:sendRawRGBData(i * max_update, max_update, false)
	end
	local last_off = max_update * (nb_update-1)
	self:sendRawRGBData(last_off, self.size - last_off, update)
end

function Segment:sendLerp(off, color1, color2, size)
	self:sendRawData(TYPE_LED_LERP, off, size,
		pack("bbbbbbbb",
		color1[1], color1[2], color1[3], color1[4] or 0,
		color2[1], color2[2], color2[3], color2[4] or 0
	))
end

function Segment:off()
	self:sendPixels(0, {0,0,0,0}, self.size)
	self:show()
end


-------------------------------------


function Segment:sendRawData(cmd, off, size, data)
	-- print("send",off,size,update)
	if self.alive > 0 then
		local to_send = pack('bhh', cmd, off, size) .. (data or "")
		assert(self.socket:sendto(to_send, self.remote.ip, self.remote.port))
	end
end

function Segment:sendRawRGBData(off, size, update)
	-- print("send",off,size,update)
	if self.alive == 0 then return end
	local cmd = self.RGBW and TYPE_LED_RAW_RGBW or TYPE_LED_RAW
	local color = self.RGBW and "bbbb" or "bbb"
	if update then
		cmd = cmd + 1
	end
	local to_send = pack('bhh', cmd, off, size)
	for j=off, (off + size)-1 do
		-- print(j,off,size)
		-- print("",self.data[j][1], self.data[j][2], self.data[j][3], self.data[j][4] or 0)
		to_send = to_send .. pack(color, self.data[j+1][1], self.data[j+1][2], self.data[j+1][3], self.data[j+1][4] or 0)
	end
	assert(self.socket:sendto(to_send, self.remote.ip, self.remote.port))
end

function Segment:checkInfo()
	local to_send = pack('b', TYPE_GET_INFO)
	self.socket:sendto(to_send, self.remote.ip, self.remote.port)
	self.alive = self.alive - 1
	if self.alive < 0 then self.alive = 0 end
end

function Segment:setEeprom(hostname)
	local to_send = pack('bbhs', TYPE_SET_MODE, self.RGBW and 1 or 0, self.size, hostname)
	self.socket:sendto(to_send, self.remote.ip, self.remote.port)

end

function Segment:updateEsp(bin_file)
	os.execute("python bin/espota.py -i "..self.remote.ip.." -p 8266 --auth= -f "..bin_file.." -P 8266 -d")
end

return Segment
