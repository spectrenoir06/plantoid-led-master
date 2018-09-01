local inspect = require "lib.inspect"
local socket = require "socket"

--[[

	Plantoid:setPixel(index_led, color, part_name, part_number)
	Plantoid:setAllPixel(color, part_name, part_number)
	Plantoid:getPixel(index_led, part_name, part_number)
	Plantoid:setFade(off, bright, size, part_name, part_number)
	Plantoid:sendAll(update, part_name(opt), part_number(opt))

	Plantoid:setLerp(off, color1, color2, size(opt), part_name, part_number)
	Plantoid:setLerpBright(off, bright1, bright2, size(opt), part_name, part_number)

	Plantoid:show(part_name, part_number)
	Plantoid:clear(part_name, part_number)
	Plantoid:sendAll(update, part_name, part_number)

]]--

function rgb(r,g,b)
	return {r,g,b}
end

function courbe(value)
	return ((math.cos((value/100)*math.pi*2)+1)/2)
end

function moving_dot(plant, part_name, part_number, index, color)
	-- plant:clear(part_name, part_number)
	local size = plant:getPartSize(part_name, part_number)
	index = index%size
	plant:setPixel(index, color, part_name, part_number)
end

function movinLerp(plant, index, color1, color2, part_name, part_number, size)
	-- plant:clear(part_name, part_number)
	size = size and size or plant:getPartSize(part_name, part_number)
	index = index % (size)
	plant:setLerp(index, color1, color2, math.floor(size/2+.5), part_name, part_number)
	plant:setLerp(index+size/2, color2, color1, math.floor(size/2+.5), part_name, part_number)

	plant:setLerp(index-size/2, color2, color1, math.floor(size/2+.5), part_name, part_number)
	plant:setLerp(index-size, color1, color2, math.floor(size/2+.5), part_name, part_number)
end

function comete(plant, part_name, part_number, index, color, fade)
	plant:setFade(0, fade or 0.5, nil, part_name, part_number)
	moving_dot(plant, part_name, part_number, index, color)
end

function start_breath(plant, counter, off, size_max, part_name, part_number)
	local value = math.floor(courbe(counter) * (size_max))
	plant:setLerpBright(off, 1, 0, value, part_name, part_number)
	for i=value, size_max do
		plant:setPixel(i+off ,{0,0,0,0}, part_name, part_number)
	end
end

function test_horloge(plantoids, color)
	local plant = plantoids.plants[4]
	local ctn = (plantoids.counter % 32)/32

	comete(plant, "Anneaux", 1, ctn*32, color, 0.5)
	comete(plant, "Anneaux", 2, ctn*24, color, 0.4)
	comete(plant, "Anneaux", 3, ctn*16, color, 0.3)
	comete(plant, "Anneaux", 4, ctn*12, color, 0.2)
	comete(plant, "Anneaux", 5, ctn*8, color, 0.1)
	plant:setAllPixel(color, "Anneaux", 6)

	plant:sendAll(true)
end

function spark(plantoids, plant, part_name, part_number, counter, color, part_size, pixel_to_remove, fade)
	fade = fade or 0.50
	pixel_to_remove = pixel_to_remove or 50
	local part_size = plant:getPartSize(part_name, part_number)
	if counter == 0 then
		plant:clear(part_name, part_number)
		plant:setAllPixel(color, part_name, part_number)
	else
		for i=1, pixel_to_remove do
			plant:setPixel(math.random(0, part_size), rgb(0,0,0), part_name, part_number)
		end
		plant:setFade(0, 0.50, nil, part_name, part_number)
		for i=1, part_size do
			if math.random(0, 1) == 0 then
				local pixel = plant:getPixel(i+1, part_name, part_number)
				if pixel then
					plant:setPixel(i, pixel, part_name, part_number)
				end
			else
				local pixel = plant:getPixel(i-1, part_name, part_number)
				if pixel then
					plant:setPixel(i, pixel, part_name, part_number)
				end
			end
		end
	end
end

function rainbow(plantoids, plant, part_name, part_number, density, counter, value)
	value = value or 1
	local part_size = plant:getPartSize(part_name, part_number)
	for i=0,part_size do
		local color = color_wheel((i*density)+counter)
		local tmp =  {
			color[1] * value,
			color[2] * value,
			color[3] * value
		}
		plant:setPixel(i, tmp, part_name, part_number)
	end
end

function receiveOSC(plantoids, addr, data) -- call when receive osc data
	plantoids:printf("OSC Receive: %s, data: %s", addr, inspect(data))
end

function receiveSensor(plantoids, sensor) -- call when receive sensor data
	local plantoid_number = sensor.plantoid_number
	local boitier_number  = sensor.boitier_number
	-- plantoids:printf("Receive sensor: plant: %d  boitier: %d  temp: %d", plantoid_number, boitier_number, sensor.data.temp)
end

local fire = 0

local test = 0
local ailes_moyen_1 = 0
local ailes_moyen_2 = 0
local on = true
local spark_color = {255,0,0}

function led_animation(plantoids) -- call at 15Hz ( 0.06666 seconde)

	local time = socket.gettime()

	-- plantoids:printf("counter = %d, test_value= %f",plantoids.counter, test_value) -- to print console

	local color	 		= color_wheel(plantoids.counter*3)
	local color_weak	= {color[1]/255*100,color[2]/255*100,color[3]/255*100}

	local plantoid_petit = plantoids.plants[1]
	local plantoid_moyen = plantoids.plants[2]
	local plantoid_grand = plantoids.plants[3]

	-- print(inspect(plantoids.plants[1].sensors[1]))
	if plantoids.plants[1].sensors[1].data.adc[1] < 500 then
		test = 0
		spark_color = rgb(255,0,0)
	end
	if plantoids.plants[1].sensors[1].data.adc[2] < 500 then
		test = 0
		spark_color = rgb(0,0,255)
	end
	spark(plantoids, plantoids.plants[1], "Feuilles", 1, test, spark_color, nil, 50, 0.5)
	test = test + 1


	if test > 10 then
		plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Feuilles" , 1)
	end


	if plantoids.plants[2].sensors[1].data.adc[1] < 500 then
		ailes_moyen_1 = 0
	end
	if plantoids.plants[2].sensors[1].data.adc[2] < 500 then
		ailes_moyen_2 = 0
	end
	spark(plantoids, plantoids.plants[2], "Feuilles_L", 1, ailes_moyen_1,  rgb(255,0,0), nil, 50, 0.5)
	spark(plantoids, plantoids.plants[2], "Feuilles_R", 1, ailes_moyen_2, rgb(0,0,255), nil, 50, 0.5)
	ailes_moyen_1 = ailes_moyen_1 + 1
	ailes_moyen_2 = ailes_moyen_2 + 1


	if ailes_moyen_1 > 10 then
		plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Feuilles_L" , 1)
	end
	if ailes_moyen_2 > 10 then
		plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Feuilles_R" , 1)
	end

-----------------------------------------------------------

	test_horloge(plantoids, color)

-----------------------------------------------------------


	-- local osc_value = plantoids.osc["/music2light/ldrNote"] -- read save osc adresse data
	-- local value = plantoids.plants[1].sensors[1].data.sonar[1] -- read sensor of plant 4 boitier 1 adc 0

	-- if value then
	-- 	-- plantoids:printf(value)
	-- 	plant:clear("Tiges")
	-- 	plant:setLerp(0, rgb(255,0,0), rgb(0,0,0),value / 2000 * 38, "Tiges", 1)
	-- 	plant:setLerp(0, rgb(255,0,0), rgb(0,0,0),value / 2000 * 38, "Tiges", 2)
	-- else
	-- 	movinLerp(plant, plantoids.counter, rgb(0,255,0),   rgb(0,255,50),   "Tiges", 1)
	-- 	movinLerp(plant, plantoids.counter, rgb(0,255,0),   rgb(0,255,50),   "Tiges", 2)
	-- end

-----------------------------------------------------------

	-- plantoid_petit:setAllPixel(color, "Spots", 1)
	movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Spots", 1, 1000)

	-- plantoid_petit:setAllPixel(rgb(0,255,0),	"Supports", 1)
	-- plantoid_petit:setAllPixel(rgb(255,255,0),	"Supports", 2)
	-- plantoid_petit:setAllPixel(rgb(0,0,255),	"Supports", 3)
	-- plantoid_petit:setAllPixel(rgb(0,255,255),	"Supports", 4)


	movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Supports", 1)
	movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Supports", 2)
	movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Supports", 3)
	movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Supports", 4)


	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 1)
	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 2)
	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 3)
	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 4)

	-- plantoid_petit:setAllPixel(rgb(255,0,0),	"Tiges", 1)
	-- plantoid_petit:setAllPixel(rgb(255,255,0),	"Tiges", 2)
	-- plantoid_petit:setAllPixel(rgb(0,255,0),	"Tiges", 3)
	-- plantoid_petit:setAllPixel(rgb(255,0,0),	"Tiges", 4)

	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 1)
	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 2)
	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 3)
	plantoid_petit:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 4)

	-- movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Tiges", 1)
	-- movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Tiges", 2)
	-- movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Tiges", 3)
	-- movinLerp(plantoid_petit, plantoids.counter, rgb(255,0,0), rgb(0,0,255), "Tiges", 4)

	-- plantoid_petit:setAllPixel(rgb(255,0,255),	"Feuilles", 1)



-----------------------------------------------------------

	-- plantoid_moyen:setAllPixel(rgb(0,255,255),	"Petales", 1)
	-- plantoid_moyen:setAllPixel(rgb(255,0,0),		"Petales", 2)
	-- plantoid_moyen:setAllPixel(rgb(0,255,0),		"Petales", 3)
	-- plantoid_moyen:setAllPixel(rgb(0,0,255),		"Petales", 4)
	-- plantoid_moyen:setAllPixel(rgb(255,255,0),	"Petales", 5)
	-- plantoid_moyen:setAllPixel(rgb(255,0,255),	"Petales", 6)

	-- plantoid_moyen:setAllPixel(color,	"Petales", 1)
	-- plantoid_moyen:setAllPixel(color,	"Petales", 2)
	-- plantoid_moyen:setAllPixel(color,	"Petales", 3)
	-- plantoid_moyen:setAllPixel(color,	"Petales", 4)
	-- plantoid_moyen:setAllPixel(color,	"Petales", 5)
	-- plantoid_moyen:setAllPixel(color,	"Petales", 6)

-- plantoid_moyen:setAllPixel(color_wheel(plantoids.counter),	"Spots", 1)
	-- movinLerp(plantoid_moyen, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Spots", 1, 1000)

	rainbow(plantoids, plantoid_moyen, "Spots", 1, 0.2, plantoids.counter, 0.2)

	-- plantoid_moyen:setAllPixel(color,   "Feuilles_L", 1)
	-- plantoid_moyen:setAllPixel(color,   "Feuilles_L", 2)
	-- plantoid_moyen:setAllPixel(color,   "Feuilles_R", 1)
	-- plantoid_moyen:setAllPixel(color,   "Feuilles_R", 2)

	-- plantoid_moyen:setAllPixel(color,   "Petales", 1)



	rainbow(plantoids, plantoid_moyen, "Petales", 1, 1.0, plantoids.counter)
	rainbow(plantoids, plantoid_moyen, "Petales", 2, 1.0, plantoids.counter)
	rainbow(plantoids, plantoid_moyen, "Petales", 3, 1.0, plantoids.counter)
	rainbow(plantoids, plantoid_moyen, "Petales", 4, 1.0, plantoids.counter)
	rainbow(plantoids, plantoid_moyen, "Petales", 5, 1.0, plantoids.counter)
	rainbow(plantoids, plantoid_moyen, "Petales", 6, 1.0, plantoids.counter)

	-- plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 1)
	-- plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 2)
	-- plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 3)
	-- plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 4)

	movinLerp(plantoid_moyen, plantoids.counter, rgb(0,0,100), rgb(100,0,0), "Tiges", 1, 200)
	movinLerp(plantoid_moyen, plantoids.counter, rgb(0,0,100), rgb(100,0,0), "Tiges", 2, 200)
	movinLerp(plantoid_moyen, plantoids.counter, rgb(0,0,100), rgb(100,0,0), "Tiges", 3, 200)
	movinLerp(plantoid_moyen, plantoids.counter, rgb(0,0,100), rgb(100,0,0), "Tiges", 4, 200)

	plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 1)
	plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 2)
	plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 3)
	plantoid_moyen:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 4)


	-- spark(plantoids, plantoid_petit, "Spots", 1, 20, rgb(255,0,0), nil, 50, 0.5)


	-- plantoid_moyen:setAllPixel(color,   "Tiges", 1)
	-- plantoid_moyen:setAllPixel(color,   "Feuilles_R", 1)
	plantoid_moyen:setAllPixel(color,   "Feuilles_R", 2)
	-- plantoid_moyen:setAllPixel(color,   "Feuilles_L", 1)
	plantoid_moyen:setAllPixel(color,   "Feuilles_L", 2)

	-- plantoid_moyen:setAllPixel(color,   "Tiges", 1)
	-- plantoid_moyen:setAllPixel(rgb(255,255,255),   "Feuilles", 2)

	-- plantoid_moyen:setAllPixel(color, "Tiges", 1)


	-- movinLerp(plantoid_moyen, 0, color_wheel(plantoids.counter*3+128), color_wheel(plantoids.counter*3+0), "Feuilles_L", 1)
	-- movinLerp(plantoid_moyen, 0, color_wheel(plantoids.counter*3+128), color_wheel(plantoids.counter*3+0), "Feuilles_L", 2)
	-- movinLerp(plantoid_moyen, 0, color_wheel(plantoids.counter*3+128), color_wheel(plantoids.counter*3+0), "Feuilles_R", 1)
	-- movinLerp(plantoid_moyen, 0, color_wheel(plantoids.counter*3+128), color_wheel(plantoids.counter*3+0), "Feuilles_R", 2)


	-- rainbow(plantoids, plantoid_grand, "Petales", 1, 0.5, plantoids.counter)
	-- rainbow(plantoids, plantoid_grand, "Petales", 2, 0.5, plantoids.counter)
	-- rainbow(plantoids, plantoid_grand, "Petales", 3, 0.5, plantoids.counter)
	-- rainbow(plantoids, plantoid_grand, "Petales", 4, 0.5, plantoids.counter)
	-- rainbow(plantoids, plantoid_grand, "Petales", 5, 0.5, plantoids.counter)

	-- plantoid_grand:setAllPixel(rgb(255,0,0), "Petales", 1)
	-- plantoid_grand:setAllPixel(rgb(0,255,0), "Petales", 2)
	-- plantoid_grand:setAllPixel(rgb(0,0,255), "Petales", 3)
	-- plantoid_grand:setAllPixel(rgb(255,0,0), "Petales", 4)
	-- plantoid_grand:setAllPixel(rgb(0,255,0), "Petales", 5)



	-- plantoid_grand:setAllPixel(color, "Spots", 1)


	-- movinLerp(plantoid_grand, plantoids.counter, {100,100,0}, {100,0,0}, "Petales", 1,240)
	-- movinLerp(plantoid_grand, plantoids.counter, {100,100,0}, {100,0,0}, "Petales", 2,240)
	-- movinLerp(plantoid_grand, plantoids.counter, {100,100,0}, {100,0,0}, "Petales", 3,240)
	-- movinLerp(plantoid_grand, plantoids.counter, {100,100,0}, {100,0,0}, "Petales", 4,240)
	-- movinLerp(plantoid_grand, plantoids.counter, {100,100,0}, {100,0,0}, "Petales", 5,240)

	-- movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Spots", 1, 1000)
	rainbow(plantoids, plantoid_grand, "Spots", 1, 0.2, plantoids.counter, 0.15)


	rainbow(plantoids, plantoid_grand, "Petales", 1, 0.3, plantoids.counter,0.3)
	rainbow(plantoids, plantoid_grand, "Petales", 2, 0.3, plantoids.counter,0.3)
	rainbow(plantoids, plantoid_grand, "Petales", 3, 0.3, plantoids.counter,0.3)
	rainbow(plantoids, plantoid_grand, "Petales", 4, 0.3, plantoids.counter,0.3)
	rainbow(plantoids, plantoid_grand, "Petales", 5, 0.3, plantoids.counter,0.3)
	-- rainbow(plantoids, plantoid_grand, "Petales", 4, 1.0, plantoids.counter)

	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_L", 1)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_L", 2)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_L", 3)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_L", 4)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_L", 5)


	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_L", 1, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_L", 2, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_L", 3, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_L", 4, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_L", 5, 100)

	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_R", 1, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_R", 2, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_R", 3, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_R", 4, 100)
	-- movinLerp(plantoid_grand, plantoids.counter, {255,0,0}, {0,0,255}, "Feuilles_R", 5, 100)

	rainbow(plantoids, plantoid_grand, "Feuilles_R", 1, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_R", 2, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_R", 3, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_R", 4, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_R", 5, 0.3, plantoids.counter)


	rainbow(plantoids, plantoid_grand, "Feuilles_L", 1, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_L", 2, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_L", 3, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_L", 4, 0.3, plantoids.counter)
	rainbow(plantoids, plantoid_grand, "Feuilles_L", 5, 0.3, plantoids.counter)

	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_L", 1)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_L", 2)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_L", 3)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_L", 4)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_L", 5)

	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_L", 1)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_L", 2)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_L", 3)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_L", 4)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_L", 5)

	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_L", 1)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_L", 2)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_L", 3)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_L", 4)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_L", 5)

	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_R", 1)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_R", 2)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_R", 3)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_R", 4)
	-- plantoid_grand:setPixel(fire-2, rgb(0,0,0), "Feuilles_R", 5)

	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_R", 1)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_R", 2)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_R", 3)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_R", 4)
	plantoid_grand:setPixel(fire-1, rgb(0,0,0), "Feuilles_R", 5)


	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_R", 1)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_R", 2)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_R", 3)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_R", 4)
	plantoid_grand:setPixel(fire, rgb(0,0,0), "Feuilles_R", 5)


	fire = fire + 3

	fire = fire % 100




	-- movinLerp(plantoid_grand, plantoids.counter, {255,255,0}, {255,0,0}, "Supports", 1, 1000)


	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(255,0,0), nil, "Tiges" , 1)
	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(255,0,0), nil, "Tiges" , 2)
	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(255,0,0), nil, "Tiges" , 3)
	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(255,0,0), nil, "Tiges" , 4)

	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Tiges", 1, 200)
	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Tiges", 2, 200)
	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Tiges", 3, 200)
	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Tiges", 4, 200)


	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Supports", 1, 200)
	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Supports", 2, 200)
	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Supports", 3, 200)
	movinLerp(plantoid_grand, plantoids.counter, rgb(255,0,0), rgb(255,255,0), "Supports", 4, 200)

	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 1)
	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 2)
	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 3)
	-- plantoid_grand:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Supports" , 4)



	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_R", 1)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_R", 2)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_R", 3)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_R", 4)
	-- plantoid_grand:setLerp(0, {255,255,0}, {255,0,0}, nil, "Feuilles_R", 5)


	-- plantoid_grand:setAllPixel({100,100,100}, "Petales", 1)
	-- plantoid_grand:setAllPixel({100,100,100}, "Petales", 2)
	-- plantoid_grand:setAllPixel({100,100,100}, "Petales", 3)
	-- plantoid_grand:setAllPixel({100,100,100}, "Petales", 4)
	-- plantoid_grand:setAllPixel({100,100,100}, "Petales", 5)

	-- plantoid_grand:setAllPixel({255,0,0}, "Petales", 1)

	for k,v in ipairs(plantoids.plants) do
		v:sendAll(true)
	end
	-- plantoids:printf("Time %f;  fps: %f", socket.gettime() - time, 1/(socket.gettime() - time))
end

return {
	led_animation = led_animation,
	receiveOSC    = receiveOSC,
	receiveSensor = receiveSensor
}
