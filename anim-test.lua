function moving_dot(plant, partname, partnumber, index)

  plant:sendPixels(0, {0,0,0,0}, nil, partname, partnumber)
  plant:sendPixels(index, {255,0,0,0}, 1, partname, partnumber)
  plant:show()

end




function animation_test(plantoids)

  local plant = plantoids.plants[1]

  moving_dot(plant, "Anneaux", 1, plantoids.counter%32)
  moving_dot(plant, "Anneaux", 2, plantoids.counter%24)
  moving_dot(plant, "Anneaux", 3, plantoids.counter%16)
  moving_dot(plant, "Anneaux", 4, plantoids.counter%12)
  moving_dot(plant, "Anneaux", 5, plantoids.counter%8)
  moving_dot(plant, "Anneaux", 6, plantoids.counter%2)






  -- local color = color_wheel(plantoids.counter)
  --
  -- local temp = plantoids:getSensorValue("/plantoid/1/1/temp", 0)
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