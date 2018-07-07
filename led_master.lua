#!/usr/bin/env lua

local signal    = require("posix.signal")
local Plantoids = require("class.Plantoids")

local dt = 0.000001
local time = socket.gettime()

local replay_file = (arg[1] == "replay") and arg[2] or nil

local plants = Plantoids:new(replay_file)

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
