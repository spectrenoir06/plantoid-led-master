#!/usr/bin/env lua5.1

local signal    = require("posix.signal")
local Plantoids = require("class.Plantoids")
local curses    = require("curses")
local inspect   = require("lib.inspect")

local dt = 0.000001
local time = socket.gettime()

local UI_counter = 0
local UI_framerate = 15

local replay_file = (arg[1] == "replay") and arg[2] or nil

local plants = Plantoids:new(replay_file)
plants.hide_print = true

signal.signal(signal.SIGINT, function(signum)
	io.write("\n")
	plants:stop()
	if plants.dump then
		if #plants.sensors == 0 then
			plants.dump_file:write(os.time(os.date("!*t")).."\n")
		end
	end
	curses.endwin()
	os.exit(128 + signum)
end)

function init_ncurse()
	local scr = curses.initscr ()

	curses.cbreak ()
	curses.echo(false)	-- not noecho !
	curses.nl(false)	-- not nonl !
	scr:clear()
	-- curses.curs_set(0)  -- Hide the cursor.

	curses.start_color()
	curses.use_default_colors()
	scr:nodelay(true)  -- Make getch nonblocking.
	-- scr:keypad()       -- Correctly catch arrow key presses.

	for i=0, curses.colors() do
		curses.init_pair(i + 1, i, -1)
	end
	return scr
end

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err (err)
	curses.endwin()
	print(debug.traceback(err, 2))
	os.exit(2)
end

last_key = 0

function main()
	local stdscr = init_ncurse()
	local cmd = ""
	local finish = false

	while not finish do
		dt = socket.gettime() - time
		time = socket.gettime()

		finish = plants:update(dt)

		UI_counter = UI_counter + dt

		if UI_counter > (1 / UI_framerate) then
			UI_counter = 0

			stdscr:erase() -- use erase() not clear() to remove flickering

			stdscr:attron(curses.A_BOLD)
			stdscr:attron(curses.A_UNDERLINE)
				stdscr:mvaddstr(1, 1, "Plantoid LEDs Master:")
			stdscr:attroff(curses.A_BOLD)
			stdscr:attroff(curses.A_UNDERLINE)

			local y = 3
			for k,v in ipairs(plants.plants) do
				stdscr:attron(curses.A_BOLD)
					stdscr:mvaddstr(y, 1, "["..k.."]  "..v.name)
				stdscr:attroff(curses.A_BOLD)
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
						stdscr:mvaddstr(y, 23, w.remote.ip)
					stdscr:attroff(cc)
					if w.alive > 0 then
						stdscr:mvaddstr(y, 40, "V"..(w.dist_vers or "?"))
						stdscr:mvaddstr(y, 47, w.dist_size or "?")
						stdscr:mvaddstr(y, 52, w.dist_name or "?")
					end
					y = y + 1
				end
				y = y + 1
			end

			stdscr:attron(curses.A_BOLD)
				stdscr:mvaddstr(y, 1, "Log:")
				y = y + 2
			stdscr:attroff(curses.A_BOLD)
			for k,v in ipairs(plants.log) do
				stdscr:mvaddstr(y, 2, v)
				y = y + 1
			end
			y = y + 1

			stdscr:attron(curses.A_BOLD)
				stdscr:mvaddstr(y, 1, "Sensors:")
				y = y + 2
			stdscr:attroff(curses.A_BOLD)

			stdscr:mvaddstr(y, 0, inspect(plants.sensors))

			-- stdscr:mvaddstr(y, 2, inspect(plants.sensors))

			local y, x = stdscr:getmaxyx()

			-- stdscr:mvaddstr(y-2, 0, "'"..string.char(tonumber(last_key)).."'  "..last_key)
			stdscr:mvaddstr(y-1, 0, "Commande: "..cmd)

			local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.

			if key then
				if key == 13 then
					curses.endwin()
					plants:runCMD(cmd)
					cmd = ""
				elseif key == 127 then
					cmd = cmd:sub(1,#cmd-1)
				else
					if key >= 48 and key <= 57
					or key >= 65 and key <= 90
					or key >= 97 and key <= 122 then
						cmd = cmd .. string.char(key)
					end
				end
				last_key = key
			end
			stdscr:refresh()
		end

		socket.sleep(0.001)
	end
end

xpcall(main, err)

plants:stop()
