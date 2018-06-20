local socket = require("socket")

require "struct"

local LED_IP        = "192.168.12.50"
local LED_PORT      = 12345
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

while true do
	dt = socket.gettime() - time
	time = socket.gettime()

	timer_led = timer_led + dt
	if timer_led > (1/LED_FRAMERATE) then
		send_led(counter/100)
		counter = counter + 1
		timer_led = 0
	end

	data, ip, port = udp:receivefrom() -- receive from led, adc and super collider
	if data then
		print("Received: ", ip, port, #data)
		print(data)
		-- udp:sendto(data, ip, port)
	end
	socket.sleep(0.01)
end
