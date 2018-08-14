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

function movinLerp(plant, index, color1, color2, part_name, part_number)
	plant:clear(part_name, part_number)
	local size = plant:getPartSize(part_name, part_number)
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

function receiveOSC(plantoids, addr, data) -- call when receive osc data
	-- plantoids:printf("OSC Receive: %s, data: %s", addr, inspect(data))
end

function receiveSensor(plantoids, sensor) -- call when receive sensor data
	local plantoid_number = sensor.plantoid_number
	local boitier_number  = sensor.boitier_number
	-- plantoids:printf("Receive sensor: plant: %d  boitier: %d  temp: %d", plantoid_number, boitier_number, sensor.data.temp)
end

local test = 0
local on = true

function led_animation(plantoids) -- call at 15Hz ( 0.06666 seconde)

	local time = socket.gettime()

	-- plantoids:printf("counter = %d, test_value= %f",plantoids.counter, test_value) -- to print console

	local color = color_wheel(plantoids.counter)

-----------------------------------------------------------

	test_horloge(plantoids, color)

-----------------------------------------------------------

	-- local plant = plantoids.plants[2] -- plantoid
    --
	-- -- local osc_value = plantoids.osc["/music2light/ldrNote"] -- read save osc adresse data
    --
	-- local value = plantoids.plants[1].sensors[1].data.sonar[1] -- read sensor of plant 4 boitier 1 adc 0
    --
	-- if value then
	-- 	-- plantoids:printf(value)
	-- 	plant:clear("Tiges")
	-- 	plant:setLerp(0, rgb(255,0,0), rgb(0,0,0),value / 2000 * 38, "Tiges", 1)
	-- 	plant:setLerp(0, rgb(255,0,0), rgb(0,0,0),value / 2000 * 38, "Tiges", 2)
	-- else
	-- 	movinLerp(plant, plantoids.counter, rgb(0,255,0),   rgb(0,255,50),   "Tiges", 1)
	-- 	movinLerp(plant, plantoids.counter, rgb(0,255,0),   rgb(0,255,50),   "Tiges", 2)
	-- end

	-- 	start_breath(plant, plantoids.counter*2, 10, 35, "Tiges", 1)
	-- 	start_breath(plant, plantoids.counter*2, 10, 35, "Tiges", 2)

	-- 	plant:setFade(0, 0.6, nil, "Tiges", 1)
	-- 	moving_dot(plant, "Tiges", 1, plantoids.counter, color)

	-- 	plant:setFade(0, 0.6, nil, "Tiges", 2)
	-- 	moving_dot(plant, "Tiges", 2, plantoids.counter, color)
	-- end

	-- movinLerp(plant, plantoids.counter, rgb(255,0,0),   rgb(255,100,0),  "Petales", 1)
	-- movinLerp(plant, plantoids.counter, rgb(0,255,0),   rgb(0,255,50),   "Petales", 2)

	-- movinLerp(plant, plantoids.counter, rgb(0,0,255),   rgb(50,0,255),   "Petales", 4)
	-- movinLerp(plant, plantoids.counter, rgb(255,255,0), rgb(255,255,50), "Petales", 3)

	-- plant:sendAll(true)

	local plant = plantoids.plants[1]

	plant:setAllPixel(color,  "Tige_et_support", 1)
	plant:setAllPixel(color,  "Spots", 1)
	plant:setAllPixel(color,  "Feuilles", 1)
	plant:setAllPixel(color, "Petales", 1)

	-- plant:clear()
	-- moving_dot(plant, "Tige_et_support", 1, plantoids.counter, color)
	-- moving_dot(plant, "Feuilles", 1, plantoids.counter, color)
	-- moving_dot(plant, "Petales", 1, plantoids.counter, color)
	-- moving_dot(plant, "Spots", 1, plantoids.counter, color)



-----------------------------------------------------------

	local plant = plantoids.plants[2]

	plant:setAllPixel(rgb(255,0,0),   "Petales", 1)
	plant:setAllPixel(rgb(0,255,0),   "Petales", 2)
	plant:setAllPixel(rgb(0,0,255),   "Petales", 3)
	plant:setAllPixel(rgb(255,255,0), "Petales", 4)
	plant:setAllPixel(rgb(0,255,255), "Petales", 5)
	plant:setAllPixel(rgb(255,0,255), "Petales", 6)

	-- plant:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 1)
	-- plant:setLerp(0, rgb(255,0,0), rgb(0,0,255), nil, "Tiges" , 2)
    --
	-- plant:setFade(0, 0.6, nil, "Supports", 1)
	-- plant:setFade(0, 0.6, nil, "Supports", 2)
	-- plant:setFade(0, 0.6, nil, "Supports", 3)
	-- plant:setFade(0, 0.6, nil, "Supports", 4)
    --
	-- moving_dot(plant, "Supports", 1, plantoids.counter, color)
	-- moving_dot(plant, "Supports", 2, plantoids.counter, color)
	-- moving_dot(plant, "Supports", 3, plantoids.counter, color)
	-- moving_dot(plant, "Supports", 4, plantoids.counter, color)
    --
	-- plant:setLerp(0,     rgb(255,0,0), rgb(0,0,255), 216/2, "Feuilles" , 1)
	-- plant:setLerp(216/2, rgb(0,0,255), rgb(255,0,0), 216/2, "Feuilles" , 1)
    --
	-- plant:setLerp(0,     rgb(255,255,0), rgb(0,255,255), 162/2, "Feuilles" , 2)
	-- plant:setLerp(162/2, rgb(0,255,255), rgb(255,255,0), 162/2, "Feuilles" , 2)
    --
	-- plant:setLerp(0,     rgb(255,0,0), rgb(0,0,255), 216/2, "Feuilles" , 3)
	-- plant:setLerp(216/2, rgb(0,0,255), rgb(255,0,0), 216/2, "Feuilles" , 3)
    --
	-- plant:setLerp(0,     rgb(255,255,0), rgb(0,255,255), 162/2, "Feuilles" , 4)
	-- plant:setLerp(162/2, rgb(0,255,255), rgb(255,255,0), 162/2, "Feuilles" , 4)


	-- local plant = plantoids.plants[2]
	-- plant:setLerp(0, rgb(100,0,0), rgb(0,0,100), nil, "Spots" , 1)


	-- local plant = plantoids.plants[1]
		-- plant:setFade(0, 0.6, nil, "test", 1)
 		-- plant:setFade(0, 0.6, nil, "Feuilles", 1)
		-- moving_dot(plant, "test2", 1, plantoids.counter%103, color)

	-- plant:sendAll(true)

	-- local plant = plantoids.plants[3]
	-- plant:setLerp(0, rgb(100,0,0), rgb(0,0,100), nil, "Spots" , 1)
	-- plant:setLerp(0, rgb(100,0,0), rgb(0,0,100), nil, "Feuilles" , 1)

	-- plant:setFade(0, 0.80, nil, "Petales", 1)
	-- plant:setLerp(0, rgb(100,0,0), rgb(0,0,100), nil, "Tige_et_support" , 1)

	-- test = test + 1
    --
	-- if test == 20 then
	-- 	plant:clear("Petales")
	-- 	plant:setAllPixel(rgb(0,0,255),   "Petales", 1)
    --
	-- 	-- plantoids:printf("%d\n", test)
	-- 	test = 0
	-- else
	-- 	for i=1,50 do
	-- 		plant:setPixel(math.random(0, 500), rgb(0,0,0), "Petales", 1)
	-- 	end
	-- 	plant:setFade(0, 0.50, nil, "Petales", 1)
    --
	-- 	for i=1,499 do
	-- 		local pixel = plant:getPixel(i+1, "Petales", 1)
	-- 		if pixel then
	-- 			plant:setPixel(i, pixel, "Petales", 1)
	-- 		end
	-- 	end
    --
	-- end

	-- plant:setAllPixel(on and color or rgb(0,0,0),   "Feuilles", 1)
	-- plant:setAllPixel(on and color or rgb(0,0,0),   "Spots", 1)
	-- plant:setAllPixel(on and color or rgb(0,0,0),   "Tige_et_support", 1)
	-- plant:setAllPixel(on and color or rgb(0,0,0),   "Petales", 1)

	-- movinLerp(plant, plantoids.counter, rgb(0,0,255),   rgb(0,255,0),   "Petales", 1)

	for k,v in ipairs(plantoids.plants) do
		v:sendAll(true)
	end
	plantoids:printf("Time %f;  fps: %f", socket.gettime() - time, 1/(socket.gettime() - time))
end

return {
	led_animation = led_animation,
	receiveOSC    = receiveOSC,
	receiveSensor = receiveSensor
}
