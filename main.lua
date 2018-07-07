local Plantoids = require("class.Plantoids")

function love.load(cmd, replay_file)
	plants = Plantoids:new((cmd == "replay") and replay_file or nil)
end

function love.draw()
	local y = 10
	love.graphics.print(love.timer.getFPS(), 200, 5)
	for k,v in ipairs(plants.plants) do
		love.graphics.print(k.."  "..v.name, 10, y)
		y = y + 20
		love.graphics.print("Remote:", 40, y)
		y = y + 20
		for l,w in pairs(v.segments) do
			love.graphics.print(l..":", 70, y)
			y = y + 20
			love.graphics.print("Alive: "..w.alive, 100, y)
			y = y + 20
			love.graphics.print("ip: "..w.remote.ip, 100, y)
			y = y + 20
			love.graphics.print("size: "..w.size, 100, y)
			y = y + 20
		end
		-- for l,w in pairs(v.parts) do
		-- 	love.graphics.print(l..":", 40, y)
		-- 	y = y + 20
		-- 	for m,x in ipairs(w) do
		-- 		love.graphics.print(x.size, 70, y)
		-- 		local rect_size = 10
		-- 		if x.size-1 > 100 then
		-- 			rect_size = 5
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
end

function love.update(dt)
	plants:update(dt)
end

function love.quit()
	plants:stop()
end
