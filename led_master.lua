#!/usr/bin/env lua

local signal    = require("posix.signal")
local Plantoids = require("class.Plantoids")

local dt = 0.000001
local time = socket.gettime()

local plants = Plantoids:new("dump/bretagne4.dump")

signal.signal(signal.SIGINT, function(signum)
	io.write("\n")
	plants:stop()
	os.exit(128 + signum)
end)

while true do
	dt = socket.gettime() - time
	time = socket.gettime()

	plants:update(dt)

	socket.sleep(0.001)
end
