local class = require 'lib.middleclass'

local lpack = require("pack")
local pack = string.pack
local upack = string.unpack

local Segment = class('Segment')

local TYPE_LED_RAW                 = 0
local TYPE_LED_RAW_AND_UPDATE      = 1
local TYPE_LED_RAW_RGBW            = 2
local TYPE_LED_RAW_RGBW_AND_UPDATE = 3
local TYPE_LED_UPDATE              = 4
local TYPE_GET_INFO                = 5

local MAX_UDP_SIZE = 1400
local MAX_UPDATE = 100

function init_tab(nb, color)
	local t  = {}
	for i=1,nb do
		t[i] = color or {0,0,0,0}
	end
	return t
end


function Segment:initialize(size, remote, socket)
	self.data = init_tab(size)
	self.remote = remote
	self.size = size
	self.RGBW = remote.RGBW
	self.socket  = socket
end


function Segment:setPixel(index, color)
	if index < 0 or index > (self.size - 1) then
		return false
	end
	if #color < 4 then
		color[4] = 0
	end
	self.data[index+1] = color
end

function Segment:send(off, size, update)
	print("send",off,size,update)
	local cmd = self.RGBW and TYPE_LED_RAW_RGBW or TYPE_LED_RAW
	local color = self.RGBW and "bbbb" or "bbb"
	if update then
		cmd = cmd + 1
	end
	local to_send = pack('bhh', cmd, off, size)
	for j=off+1, off + size do
		to_send = to_send .. pack(color, self.data[j][1], self.data[j][2], self.data[j][3], self.data[j][4] or 0)
	end
	assert(self.socket:sendto(to_send, self.remote.ip, self.remote.port))
end

function Segment:update()
	local nb_update = math.ceil(self.size / MAX_UPDATE)
	for i=1, nb_update-1 do
		self:send((i-1) * MAX_UPDATE, MAX_UPDATE, false)
	end
	local last_off = MAX_UPDATE * (nb_update-1)
	self:send(last_off, self.size - last_off, true)
end

return Segment
