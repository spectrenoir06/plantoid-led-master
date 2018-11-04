# plantoid-led-master

![Plantoid](/img/plant.jpg)
![Plantoid](/img/IMG_20180818_213449_769.jpg)
![console](/img/console.png)
![GUI](/img/led.png)

### dependence
```
lua5.1

luarocks5.1 install luasocket
luarocks5.1 install luaposix
luarocks5.1 install lcurses
luarocks5.1 install lpack
```

### runs serveur (console mode)
```
./led_master.lua
```
### replay dump
```
./led_master.lua replay dump/log.dump
```

### runs serveur with Love ( gui mode ) work on android and IOS
```
love .
```

## cmd
- update
- updateled
- updatesensor
- seteeprom

## change mode ( press key to change )

1. main page
2. Sensors
3. Logs

##

1. download and flash https://github.com/spectrenoir06/plantoid-led-driver on the ESP8266
2. read the ESP8266 IP on the serial console of arduino IDE
3. write the ESP8266 IP on map.lua
4. start `./led_master.lua`

##

1. download and flash https://github.com/spectrenoir06/plantoid-sensor-driver on the ESP8266
2. read the ESP8266 IP on the serial console of arduino IDE
3. write the ESP8266 IP on map.lua
4. start `./led_master.lua`
