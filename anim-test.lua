local tween = require 'lib.tween'

local test = { value = 0}
local test_tween = tween.new(3, test, {value = 29},"outQuint")

function moving_dot(plant, partname, partnumber, index, color)
	-- plant:setAllPixel({0,0,0,0}, partname, partnumber)
	plant:setPixel(index, color, partname, partnumber)
end

function movinLerp(plant, index, part_name, part_number)
	plant:setAllPixel({0,0,0,0}, part_name, part_number)
	plant:setLerp(index, {102,0,204}, {255,0,102}, 16, part_name , part_number)
	plant:setLerp(index - 16, {255,0,102}, {102,0,204}, 16, part_name , part_number)
end


function start_breath(plant, counter)
	local value = ((math.cos(counter/10)+1)/2)
	local test = math.floor(value * 19)
	print(test)
	plant:setLerpBright(10, 1, 0, test, "Tiges" , 1)
	for i=test+10, 29 do
		plant:setPixel(i ,{0,0,0,0}, "Tiges", 1)
	end

end



function animation_test(plantoids)



	local plant = plantoids.plants[5]


	-- plant:setAllPixel({153/2,0,204/2,0}, "Tiges", 1)
	plant:setLerp(0, {255,0, 0}, {0, 255, 0}, 29, "Tiges", 1)

	-- movinLerp(plant, plantoids.counter%29, "Tiges", 1)
	-- start_breath(plant, plantoids.counter)

	-- plant:setLerpBright(0, 1, 0, 29, "Tiges" , 1)

	plant:sendAll(true)


	-- local color = color_wheel(plantoids.counter)



	-- test_tween:update(1/15)


    -- local temp = plantoids:getSensorValue("/plantoid/1/1/temp", 0)

	-- print(test.value)

    --
	-- plant:setAllPixel({0,0,0}, "Anneaux", 1)
	-- plant:setAllPixel({0,0,0}, "Anneaux", 2)
	-- plant:setAllPixel({0,0,0}, "Anneaux", 3)
	-- plant:setAllPixel({0,0,0}, "Anneaux", 4)
	-- plant:setAllPixel({0,0,0}, "Anneaux", 5)
	-- plant:setAllPixel({0,0,0}, "Anneaux", 6)
    --
    --
	-- movinLerp(plant, plantoids.counter%32, "Tiges", 1)
    --
	-- moving_dot(plant, "Anneaux", 1, plantoids.counter%32, color)
	-- moving_dot(plant, "Anneaux", 2, plantoids.counter%24, {0,0,100})
	-- moving_dot(plant, "Anneaux", 3, plantoids.counter%16, {0,0,100})
	-- moving_dot(plant, "Anneaux", 4, plantoids.counter%12, {0,0,100})
	-- moving_dot(plant, "Anneaux", 5, plantoids.counter%8, {0,0,100})
	-- moving_dot(plant, "Anneaux", 6, plantoids.counter%2, {0,0,100})


	-- plant:setAllPixel(color, "Tiges", 1)







  -- local color = color_wheel(plantoids.counter)
  --
  --
  -- if temp then
  --   local temp = temp / 40
  --   plant:setAllPixel({0,0,0,0}, "Anneaux", 1)
  --   plant:setAllPixel({0,0,0,10}, "Anneaux", 1, temp * 32)
  -- else
  --   plant:setAllPixel({10,0,0}, "Anneaux", 1)
  -- end
  --
  -- plant:setAllPixel({0,10,0}, "Anneaux", 2)
  -- plant:setAllPixel({0,0,10}, "Anneaux", 3)
  -- plant:setAllPixel({10,0,0}, "Anneaux", 4)
  -- plant:setAllPixel(color,    "Anneaux", 5)
  -- plant:setAllPixel({0,0,10}, "Anneaux", 6)
  --
  -- plant:sendAll(true) -- send all rgbw data to driver, ( true if update led)
  --
  --
  -- local plant = plantoids.plants[3]
  -- plant:setAllPixel({255,0,0},   "Petales", 1)
  -- plant:setAllPixel({0,255,0},   "Petales", 2)
  -- plant:setAllPixel({0,0,255},   "Petales", 3)
  -- plant:setAllPixel({255,255,0}, "Petales", 4)
  -- plant:setAllPixel({0,255,255}, "Petales", 5)
  -- plant:setAllPixel({255,0,255}, "Petales", 6)
  --
  -- plant:sendLerp(0, {255,0,0}, {0,0,255}, nil, "Tiges" , 1)
  -- plant:sendLerp(0, {255,0,0}, {0,0,255}, nil, "Tiges" , 2)
  --
  -- plant:sendPixels(0, {255,100,0}, nil, "Supports", 1)
  -- plant:sendPixels(0, {255,100,0}, nil, "Supports", 2)
  -- plant:sendPixels(0, {255,100,0}, nil, "Supports", 3)
  -- plant:sendPixels(0, {255,100,0}, nil, "Supports", 4)
  --
  -- plant:sendLerp(0,     {255,0,0}, {0,0,255}, 216/2, "Feuilles" , 1)
  -- plant:sendLerp(216/2, {0,0,255}, {255,0,0}, 216/2, "Feuilles" , 1)
  --
  -- plant:sendLerp(0,     {255,255,0}, {0,255,255}, 162/2, "Feuilles" , 2)
  -- plant:sendLerp(162/2, {0,255,255}, {255,255,0}, 162/2, "Feuilles" , 2)
  --
  -- plant:sendLerp(0,     {255,0,0}, {0,0,255}, 216/2, "Feuilles" , 3)
  -- plant:sendLerp(216/2, {0,0,255}, {255,0,0}, 216/2, "Feuilles" , 3)
  --
  -- plant:sendLerp(0,     {255,255,0}, {0,255,255}, 162/2, "Feuilles" , 4)
  -- plant:sendLerp(162/2, {0,255,255}, {255,255,0}, 162/2, "Feuilles" , 4)
  --
  -- plant:sendPixels(0, {0,0,0,100}, nil, "Spots", 1)
  --
  -- plant:setPixel(10, {0,0,255}, "Supports", 1) -- test invert
  -- plant:setPixel(10, {0,0,255}, "Supports", 2) -- test invert
  --
  -- plant:show()

end



return animation_test
