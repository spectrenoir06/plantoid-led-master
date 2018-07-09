--[[

	Plandoids:getSensorValue(adresse, value)

	Plantoid:setPixel(index_led, color, part_name, part_number)
	Plantoid:setAllPixel(color, part_name, part_number)
	Plantoid:sendAll(update, part_name(opt), part_number(opt))
	Plantoid:getPixel(index_led, part_name, part_number)

	Plantoid:setLerp(off, color1, color2, size, part_name, part_number)
	Plantoid:setLerpBright(off, bright1, bright2, size, part_name, part_number)

	Plantoid:show(part_name, part_number)
	Plantoid:clear(part_name, part_number)
	Plantoid:sendAll(update, part_name, part_number)

]]--

function moving_dot(plant, part_name, part_number, index, color)
	plant:clear(part_name, part_number)
	plant:setPixel(index, color, part_name, part_number)
end

function movinLerp(plant, index, color1, color2, part_name, part_number)
	plant:clear(part_name, part_number)
	plant:setLerp(index,    color1, color2, 15, part_name, part_number)
	plant:setLerp(index+15, color2, color1, 15, part_name, part_number)

	plant:setLerp(index-15, color2, color1, 15, part_name, part_number)
	plant:setLerp(index-30, color1, color2, 15, part_name, part_number)
end


function start_breath(plant, counter)
	local value = ((math.cos(counter/10)+1)/2)
	local test = math.floor(value * 19)
	plant:setLerpBright(10, 1, 0, test, "Tiges" , 1)
	for i=test+10, 29 do
		plant:setPixel(i ,{0,0,0,0}, "Tiges", 1)
	end

end

function test_horloge(plantoids)
	local plant = plantoids.plants[1]
	local color = color_wheel(plantoids.counter)
	local ctn = (plantoids.counter % 32)/32

	moving_dot(plant, "Anneaux", 1, ctn*32, color)
	moving_dot(plant, "Anneaux", 2, ctn*24, color)
	moving_dot(plant, "Anneaux", 3, ctn*16, color)
	moving_dot(plant, "Anneaux", 4, ctn*12, color)
	moving_dot(plant, "Anneaux", 5, ctn*8, color)
	plant:setAllPixel(color, "Anneaux", 6)

	plant:sendAll(true, "Anneaux")
end



function led_animation(plantoids)

	test_horloge(plantoids)

	local plant = plantoids.plants[5]

	-- plant:setLerp(0, {255,0, 0}, {0, 255, 0}, 29, "Tiges", 1)

	movinLerp(plant, plantoids.counter%30, {255,0,0}, {0,0,255}, "Tiges", 1)
	-- start_breath(plant, plantoids.counter)

	-- plant:setLerpBright(0, 1, 0, 29, "Tiges" , 1)

	plant:sendAll(true)




	-- local temp = plantoids:getSensorValue("/plantoid/1/1/temp", 0)

	-- plant:clear("Anneaux")

	-- plant:setAllPixel({0,100,0}, "Anneaux", 2)

	-- plant:setAllPixel(color, "Tiges", 1)



	-- local color = color_wheel(plantoids.counter)
    --
    --
	-- if temp then
	-- 	local temp = temp / 40
	-- 	plant:setAllPixel({0,0,0,0}, "Anneaux", 1)
	-- 	plant:setAllPixel({0,0,0,10}, "Anneaux", 1, temp * 32)
	-- else
	-- 	plant:setAllPixel({10,0,0}, "Anneaux", 1)
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
	-- plant:setLerp(0, {255,0,0}, {0,0,255}, nil, "Tiges" , 1)
	-- plant:setLerp(0, {255,0,0}, {0,0,255}, nil, "Tiges" , 2)
    --
	-- plant:sendPixels(0, {255,100,0}, nil, "Supports", 1)
	-- plant:sendPixels(0, {255,100,0}, nil, "Supports", 2)
	-- plant:sendPixels(0, {255,100,0}, nil, "Supports", 3)
	-- plant:sendPixels(0, {255,100,0}, nil, "Supports", 4)
    --
	-- plant:setLerp(0,     {255,0,0}, {0,0,255}, 216/2, "Feuilles" , 1)
	-- plant:setLerp(216/2, {0,0,255}, {255,0,0}, 216/2, "Feuilles" , 1)
    --
	-- plant:setLerp(0,     {255,255,0}, {0,255,255}, 162/2, "Feuilles" , 2)
	-- plant:setLerp(162/2, {0,255,255}, {255,255,0}, 162/2, "Feuilles" , 2)
    --
	-- plant:setLerp(0,     {255,0,0}, {0,0,255}, 216/2, "Feuilles" , 3)
	-- plant:setLerp(216/2, {0,0,255}, {255,0,0}, 216/2, "Feuilles" , 3)
    --
	-- plant:setLerp(0,     {255,255,0}, {0,255,255}, 162/2, "Feuilles" , 4)
	-- plant:setLerp(162/2, {0,255,255}, {255,255,0}, 162/2, "Feuilles" , 4)
    --
	-- plant:sendPixels(0, {0,0,0,100}, nil, "Spots", 1)
    --
	-- plant:setPixel(10, {0,0,255}, "Supports", 1) -- test invert
	-- plant:setPixel(10, {0,0,255}, "Supports", 2) -- test invert

	-- plant:show()

end



return led_animation
