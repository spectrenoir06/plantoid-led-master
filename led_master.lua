#!/usr/bin/env lua5.1

local signal    = require("posix.signal")
local Plantoids = require("class.Plantoids")
local curses    = require("curses")
local inspect   = require("lib.inspect")



local function printf (fmt, ...)
	return print (string.format (fmt, ...))
end

local dt = 0.000001
local time = socket.gettime()

local replay_file = (arg[1] == "replay") and arg[2] or nil

local plants = Plantoids:new(replay_file)

signal.signal(signal.SIGINT, function(signum)
	io.write("\n")
	plants:stop()
	curses.endwin()
	os.exit(128 + signum)
end)


local stdscr = curses.initscr ()

curses.cbreak ()
curses.echo(false)	-- not noecho !
curses.nl(false)	-- not nonl !
stdscr:clear()
curses.curs_set(0)  -- Hide the cursor.

curses.start_color()
curses.use_default_colors()
stdscr:nodelay(true)  -- Make getch nonblocking.
-- stdscr:keypad()       -- Correctly catch arrow key presses.

for i=0, curses.colors() do
	curses.init_pair(i + 1, i, -1)
end

local cmd = ""
local finish = false

while not finish do
	dt = socket.gettime() - time
	time = socket.gettime()

	local status, err = pcall(function() finish = plants:update(dt) end)
	if not status then
		curses.endwin()
		print("error", status,err)
		break
	end

	stdscr:erase() -- use erase() not clear() to remove flickering

	stdscr:attron(curses.A_BOLD)
	stdscr:attron(curses.A_UNDERLINE)
	stdscr:mvaddstr(1, 1, "Plantoid LEDs Master:")

	stdscr:attroff(curses.A_BOLD)
	stdscr:attroff(curses.A_UNDERLINE)

	local y = 3
	for k,v in ipairs(plants.plants) do
		stdscr:mvaddstr(y, 1, "["..k.."]  "..v.name)
		y = y + 1
		for l,w in pairs(v.segments) do
			stdscr:mvaddstr(y, 4, l..":")
			local cc
			if w.alive == 0 then
				cc = curses.color_pair(2)
			else
				cc = curses.color_pair(3)
			end
			stdscr:attron(cc)
				stdscr:mvaddstr(y, 26, w.remote.ip)
			stdscr:attroff(cc)
			if w.alive > 1 then
				stdscr:mvaddstr(y, 45, "V"..(w.dist_vers or "?"))
				stdscr:mvaddstr(y, 55, w.dist_size or "?")
				stdscr:mvaddstr(y, 65, w.dist_name or "?")
			end
			y = y + 1
		end
		y = y + 1
	end
	stdscr:mvaddstr(y, 0, "Sensor:\n"..inspect(plants.sensors).."\n\nMusic:\n"..inspect(plants.music))

	local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.

	if key == tostring('q'):byte(1) or cmd == "quit" then  -- The q key quits.
		curses.endwin()
		plants:stop()
		os.exit(0)
	end

	if key == 13 then
		cmd = ""
		stdscr:mvaddstr(0, 0, "Commande: ")
		stdscr:refresh()
		stdscr:nodelay(false)
		curses.echo(true)
		curses.curs_set(1)
		while (42) do
			local key = stdscr:getch()
			if key == 13 then break end
			cmd = cmd..string.char(key)
		end
		stdscr:nodelay(true)
		curses.echo(false)	-- not noecho !
		curses.curs_set(0)  -- Hide the cursor.
		curses.endwin()
		plants:runCMD(cmd)
	end

	stdscr:refresh()
	socket.sleep(0.001)
end

curses.endwin()
plants:stop()
