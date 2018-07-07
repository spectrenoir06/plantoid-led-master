local Plantoids = require("class.Plantoids")

function love.load(cmd, replay_file)
	plants = Plantoids:new((cmd == "replay") and replay_file or nil)
	width, height = love.graphics.getWidth(), love.graphics.getHeight()
end

function love.draw()
	if love.system.getOS() == "Android" then
		love.graphics.translate(width/2, height/2)
		love.graphics.rotate(-math.pi / 2)
		love.graphics.translate(-height/2, -width/2)
	end

	local y = 10
	-- love.graphics.print(love.timer.getFPS(), 200, 5)
	for k,v in ipairs(plants.plants) do
		love.graphics.print("["..k.."]  "..v.name, 10, y)
		y = y + 20
		for l,w in pairs(v.segments) do
			love.graphics.print(l..":", 30, y)
			if w.alive == 0 then
				love.graphics.setColor(1, 0, 0, 1)
			else
				love.graphics.setColor(0, 1, 0, 1)
			end
			love.graphics.print(w.remote.ip, 150, y)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print("size: "..w.size, 270, y)
			-- love.graphics.print("Alive: "..w.alive, 30, y)
			y = y + 20
		end
		y = y + 20
	end

	-- for l,w in pairs(v.parts) do
	-- 	love.graphics.print(l..":", 40, y)
	-- 	y = y + 20
	-- 	for m,x in ipairs(w) do
	-- 		love.graphics.print(x.size, 70, y)
	-- 		local rect_size = 10
	-- 		if x.size-1 > 100 then
	-- 			rect_size =  2
	-- 		end
	-- 		love.graphics.rectangle("line", 100, y, rect_size*x.size, 10)
	-- 		for i=0, x.size-1 do
	-- 			local color = v:getPixel(i, l, m)
	-- 			-- print(i,l,m, color[1])
	-- 			if color then
	-- 				love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
	-- 				love.graphics.rectangle("fill", 100+i*rect_size, y, rect_size, 10)
	-- 			end
	-- 			love.graphics.setColor(255,255,255,255)
	-- 		end
	-- 		y = y + 20
	-- 	end
	-- end
end

function love.update(dt)
	plants:update(dt)
end

function love.quit()
	plants:stop()
end
