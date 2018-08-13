local Plantoids = require("class.Plantoids")

function love.load(arg)
	plants = Plantoids:new((arg[1] == "replay") and arg[2] or nil)
	width, height = love.graphics.getWidth(), love.graphics.getHeight()
	mode = 0
	local r,g,b = 0,0,0
	love.graphics.setLineWidth(1)
end

function love.draw()
	-- if love.system.getOS() == "Android" then
	-- 	love.graphics.translate(width/2, height/2)
	-- 	love.graphics.rotate(-math.pi / 2)
	-- 	love.graphics.translate(-height/2, -width/2)
	-- end

	-- love.graphics.print(love.graphics.getWidth().."/"..love.graphics.getHeight(), 0,0)

	local y = 10
	if mode == 0 then
		-- love.graphics.print(love.timer.getFPS(), 200, 5)
		for k,v in ipairs(plants.plants) do
			love.graphics.print("["..k.."]  "..v.name, 10, y)
			y = y + 20
			love.graphics.print("LEDs:", 30, y)
			y = y + 20
			for l,w in pairs(v.segments) do
				love.graphics.print(l..":", 50, y)
				if w.alive == 0 then
					love.graphics.setColor(1, 0, 0, 1)
				else
					love.graphics.setColor(0, 1, 0, 1)
				end
				love.graphics.print(w.remote.ip, 170, y)
				love.graphics.setColor(1, 1, 1, 1)
				if w.alive > 0 then
					love.graphics.print("V"..(w.dist_vers or "?"), 300, y)
					love.graphics.print(w.dist_size or "?", 370, y)
					love.graphics.print(w.dist_size or "?", 370, y)
					love.graphics.print(w.dist_name or "?", 500, y)
				end
				y = y + 20
			end
			love.graphics.print("Sensors:", 30, y)
			y = y + 20
			for l,w in ipairs(v.sensors) do
				love.graphics.print("["..l.."]:", 50, y)
				if w.alive == 0 then
					love.graphics.setColor(1, 0, 0, 1)
				else
					love.graphics.setColor(0, 1, 0, 1)
				end
				love.graphics.print(w.remote.ip, 170, y)
				love.graphics.setColor(1, 1, 1, 1)
				if w.alive > 0 then
					love.graphics.print("V"..(w.dist_vers or "?"), 300 , y)
					love.graphics.print(w.dist_name or "?", 370, y)
					love.graphics.print(w.dist_iptosend[1].."."..w.dist_iptosend[2].."."..w.dist_iptosend[3].."."..w.dist_iptosend[4], 500, y)
				end
				-- y = y + 20
				-- love.graphics.print((y, 10, w:toString())
				y = y + 20
			end
			y = y + 20
		end
	elseif mode == 1 then
		-- love.graphics.print(love.timer.getFPS(), 200, 5)
		for k,v in ipairs(plants.plants) do
			love.graphics.print("["..k.."]  "..v.name, 10, y)
			y = y + 20
			for l,w in ipairs(v.sensors) do
				love.graphics.print("["..l.."]:", 50, y)
				if w.alive == 0 then
					love.graphics.setColor(1, 0, 0, 1)
				else
					love.graphics.setColor(0, 1, 0, 1)
				end
				love.graphics.print(w.remote.ip, 100, y)
				love.graphics.setColor(1, 1, 1, 1)
				if w.alive > 0 then
					love.graphics.print("V"..(w.dist_vers or "?"), 300 , y)
					love.graphics.print(w.dist_name or "?", 370, y)
					love.graphics.print(w.dist_iptosend[1].."."..w.dist_iptosend[2].."."..w.dist_iptosend[3].."."..w.dist_iptosend[4], 500, y)
				end
				y = y + 20
				love.graphics.print("Temp: "..w.data.temp.." °C;  Hum: "..w.data.temp.." %", 70, y)
				y = y + 25
				love.graphics.setColor(1, 1, 1, 1)

				love.graphics.print("Sonar 1:", 70, y)
				love.graphics.rectangle("line", 70+60, y, 370, 12)
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.rectangle("fill", 70+60+1, y+1, (w.data.sonar[1] / 2000 * 370), 12-2)
				love.graphics.setColor(1, 1, 1, 1)
				y = y + 20

				love.graphics.print("Sonar 2:", 70, y)
				love.graphics.rectangle("line", 70+60, y, 370, 12)
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.rectangle("fill", 70+60+1, y+1, (w.data.sonar[2] / 2000 * 370), 12-2)
				love.graphics.setColor(1, 1, 1, 1)
				y = y + 25

				for i=0,3 do
					for j=0,1 do
						love.graphics.print("ADC "..i*2 + j..":", 70+1+(j*220), y)
						love.graphics.rectangle("line", 70+(j*220)+60, y, 150, 12)
						if (l == 2 and (i*2 + j) == 3) then
							love.graphics.setColor(0, 0, 1, 1)
						else
							love.graphics.setColor(1, 1, 0, 1)
						end
						love.graphics.rectangle("fill", 70+1+(j*220)+60, y+1, (w.data.adc[i*2 + j + 1] / 1024 * 148), 12-2)
						love.graphics.setColor(1, 1, 1, 1)
					end
					y = y + 20
				end

			end
			y = y + 20
		end
	else
		local v = plants.plants[mode-1]
		love.graphics.print("["..(mode-1).."]  "..v.name, 10, y)
		y = y + 20
		for l,w in pairs(v.parts) do
			love.graphics.print(l..":", 30, y)
			y = y + 20
			for m,x in ipairs(w) do
				love.graphics.print(x.size, 50, y)
				local rect_size = 10
				if (x.size * 10) > 500 then
					rect_size = 500 / x.size
				end
				love.graphics.rectangle("line", 80, y, rect_size*x.size, 14)
				for i=0, x.size-1 do
					local color = v:getPixel(i, l, m)
					-- print(i,l,m, color[1])
					if color then
						love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
					else
						love.graphics.setColor(0,0,0,1)
					end
					love.graphics.rectangle("fill", 80+i*rect_size, y, rect_size, 14)
					love.graphics.setColor(255,255,255,255)
					-- love.graphics.rectangle("line", 80+i*rect_size, y, rect_size, 10)
				end
				y = y + 20
			end
		end
	end
end

function love.update(dt)
	local finish = plants:update(dt)
	if finish then
		love.event.quit()
	end
end

function love.quit()
	plants:stop()
end

function love.mousepressed( x, y, button, istouch )
	print(x,y,button,istouch)
	mode = (mode + 1)%(#plants.plants+2)
end

function love.keypressed( key, scancode, isrepeat )
	print(key,scancode,isrepeat)
	if key == "escape" or key == "c" then
		love.event.quit()
	end
end
