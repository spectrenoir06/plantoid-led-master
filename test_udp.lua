local socket = require("socket")
require "struct"

local udp = assert(socket.udp())
udp:settimeout(1)
assert(udp:setsockname("*", 0))

local ip		= "192.168.11.109"
local port		= 12345
local LED_RAW	= 0

while true do
	local t = 100
	for i=0,t do
		local to_send = struct.pack('Bhh', LED_RAW, 0, 30)
		for j=0,30 do
			to_send = to_send .. struct.pack('BBB',
				((math.sin(((j+i)%t/t) * 2 * math.pi + math.pi) + 1) / 2) * 50,
				((math.sin(((j+i)%t/t) * 2 * math.pi) + 1) / 2) * 10,
				((math.sin(((j+i)%t/t) * 2 * math.pi) + 1) / 2) * 255
			)
		end
		assert(udp:sendto(to_send, ip, port))
		socket.sleep(1/20)
	end
end
