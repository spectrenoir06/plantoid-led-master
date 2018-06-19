local socket = require("socket")
require "struct"

local udp = assert(socket.udp())
udp:settimeout(1)
assert(udp:setsockname("*", 0))

local ip		= "192.168.11.109"
local port		= 12345
local LED_RAW	= 0

while true do

	for i=0,30 do
		local to_send = struct.pack('Bhh', LED_RAW, 0, 30)
		for j=0,30 do
			to_send = to_send .. struct.pack('BBB', 0, 0, (math.sin((j-i/60)*2*math.pi) + 1) * 100 + 50)
		end
		assert(udp:sendto(to_send, ip, port))
		socket.sleep(1/20)
	end
end
