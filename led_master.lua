#!/usr/bin/env lua5.1

local signal    = require("posix.signal")
local Plantoids = require("class.Plantoids")
local curses    = require("curses")
local inspect   = require("lib.inspect")

local dt = 0.000001
local time = socket.gettime()

local mode = 0

local UI_counter = 0
local UI_framerate = 30

local replay_file = (arg[1] == "replay") and arg[2] or nil

local plants = Plantoids:new(replay_file)
plants.hide_print = true

signal.signal(signal.SIGINT, function(signum)
	io.write("\n")
	plants:stop()
	if plants.dump then
		-- if #plants.sensors == 0 then
		-- 	plants.dump_file:write(os.time(os.date("!*t")).."\n")
		-- end
	end
	curses.endwin()
	for k,v in ipairs(plants.log) do
		print(v)
	end

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
	scr:keypad()       -- Correctly catch arrow key presses.

	for i=0, curses.colors() do
		curses.init_pair(i + 1, i, -1)
	end
	return scr
end

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err (err)
	curses.endwin()
	for k,v in ipairs(plants.log) do
		print(v)
	end
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

			if mode == 0 then

				stdscr:attron(curses.A_BOLD)
				stdscr:attron(curses.A_UNDERLINE)
					stdscr:mvaddstr(1, 1, "Plantoid LEDs Master:")
				stdscr:attroff(curses.A_BOLD)
				stdscr:attroff(curses.A_UNDERLINE)

				local y = 3
				for k,v in ipairs(plants.plants) do
					local pixels_nb = 0
					local leds_nb = 0
					for l,w in pairs(v.segments) do
						pixels_nb = pixels_nb + w.size
						leds_nb = leds_nb + ((w.RGBW and 4 or 3)*w.size)
					end
					stdscr:attron(curses.A_BOLD)
						stdscr:mvaddstr(y, 1, "["..k.."]  "..v.name.."   pixels: "..pixels_nb..",  LEDs: "..leds_nb)
					stdscr:attroff(curses.A_BOLD)
					y = y + 1
					stdscr:attron(curses.A_BOLD)
						stdscr:mvaddstr(y, 4, "Leds:")
					stdscr:attroff(curses.A_BOLD)
					y = y + 1
					for l,w in pairs(v.segments) do
						stdscr:mvaddstr(y, 8, l..":")
						local cc
						if w.alive == 0 then
							cc = curses.color_pair(2)
						else
							cc = curses.color_pair(3)
						end
						stdscr:attron(cc)
							stdscr:mvaddstr(y, 27, w.remote.ip)
						stdscr:attroff(cc)
						-- if w.alive > 0 then
							stdscr:mvaddstr(y, 47, "V"..(w.dist_vers or "?"))
							stdscr:mvaddstr(y, 56, w.dist_size or w.size)
							stdscr:mvaddstr(y, 65, w.RGBW and "RGBW" or "RGB")
							stdscr:mvaddstr(y, 75, w.dist_name or "?")
						-- end
						y = y + 1
					end
					stdscr:attron(curses.A_BOLD)
						stdscr:mvaddstr(y, 4, "Sensors:")
					stdscr:attroff(curses.A_BOLD)
					y = y + 1
					for l,w in ipairs(v.sensors) do
						stdscr:mvaddstr(y, 8, "["..l.."]:")
						local cc
						if w.alive == 0 then
							cc = curses.color_pair(2)
						else
							cc = curses.color_pair(3)
						end
						stdscr:attron(cc)
							stdscr:mvaddstr(y, 27, w.remote.ip)
						stdscr:attroff(cc)
						if w.alive > 0 then
							stdscr:mvaddstr(y, 47, "V"..(w.dist_vers or "?"))
							stdscr:mvaddstr(y, 56, w.dist_name or "?")
							stdscr:mvaddstr(y, 75, w.dist_iptosend[1].."."..w.dist_iptosend[2].."."..w.dist_iptosend[3].."."..w.dist_iptosend[4])
						end
						-- y = y + 1
						-- stdscr:mvaddstr(y, 10, w:toString())
						y = y + 1
					end
					y = y + 1
				end

				stdscr:attron(curses.A_BOLD)
					stdscr:mvaddstr(y, 1, "Log:")
				stdscr:attroff(curses.A_BOLD)
					y = y + 2

				local ey, ex = stdscr:getmaxyx()
				local size = (ey - 3) - y
				-- print(size)

				for i = #plants.log - size, #plants.log do
					stdscr:mvaddstr(y, 2, plants.log[i])
					y = y + 1
				end

			elseif mode == 1 then
				local y = 1
				for k,v in ipairs(plants.plants) do
						stdscr:attron(curses.A_BOLD)
						stdscr:mvaddstr(y, 1, "["..k.."]  "..v.name)
					stdscr:attroff(curses.A_BOLD)
					y = y + 1

					for l,w in ipairs(v.sensors) do
						stdscr:mvaddstr(y, 4, "Temp:    "..w.data.temp); y=y+1
						stdscr:mvaddstr(y, 4, "Hum:     "..w.data.hum); y=y+1
						stdscr:mvaddstr(y, 4, "Sonar 1: "..w.data.sonar[1]); y=y+1
						stdscr:mvaddstr(y, 4, "Sonar 2: "..w.data.sonar[2]); y=y+2

						for i=1,8 do
							stdscr:mvaddstr(y, 4 + (i-1) * 12,   "ADC"..(i-1)..": "..w.data.adc[i]);
						end
						y = y + 2
					end
				end
			elseif mode == 2 then
				stdscr:attron(curses.A_BOLD)
					stdscr:mvaddstr(1, 1, "Log:")
				stdscr:attroff(curses.A_BOLD)

				local ey, ex = stdscr:getmaxyx()
				local size = ey - 6

				-- for k,v in ipairs(plants.log) do
				local y = 3
				for i = #plants.log - size, #plants.log do
					stdscr:mvaddstr(y, 2, plants.log[i])
					y = y + 1
				end
			end

			local y, x = stdscr:getmaxyx()

			stdscr:mvaddstr(y-1, 0, "Commande: "..cmd)

			stdscr:refresh()
		end

		local key = stdscr:getch()  -- Nonblocking; returns nil if no key was pressed.
		if key then
			UI_counter = 100
			if key == 13 then
				plants:printf(cmd)
				curses.endwin()
				plants:runCMD(cmd)
				cmd = ""
			elseif key == 263 then
				cmd = cmd:sub(1,#cmd-1)
			elseif key == 49 then
				mode = 0
			elseif key == 50 then
				mode = 1
			elseif key == 51 then
				mode = 2
			else
				if key >= 48 and key <= 57
				or key >= 65 and key <= 90
				or key >= 97 and key <= 122 then
					cmd = cmd .. string.char(key)
				end
			end
			last_key = key
			-- plants:printf("key = %d", key)
		end

		socket.sleep(0.0001)
	end
end

xpcall(main, err)

plants:stop()
