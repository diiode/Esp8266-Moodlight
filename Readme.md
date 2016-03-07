# Esp8266 Moodlight #
Esp8266 Moodlight - Moodlight with esp8266 webserver and BlinkM RGB LED.

This project creates a Lua HTTP webserver on an esp8266. It uses the NodeMCU Lua runtime and the corresponding API.
The webserver will serve an webpage where the user can control a BlinkM connected via I²C to the esp8266. The user can set the led color to:

 - Red
 - Green
 - Blue

The webpage is styled with Bootstrap and uses the Materialize theme.

## Wishlist ##

 - Finegrained RGB/HSV control. Maybe via a jquery color wheel.
 - MQTT support
 - MS Azure integration

## Links & external documentation ##

 - esp8266 & NodeMCU: [Home page](http://nodemcu.com/index_en.html)
     - NodeMCU Documentation: [Link](http://nodemcu.readthedocs.org/en/dev/)
         - Lua API
         - Flashing
         - Building firmware
         - Uploading code
 - Bootstrap: [Docs](http://getbootstrap.com/)
     - Material design theme: [github](http://fezvrasta.github.io/bootstrap-material-design/)
 - BlinkM: [Home page](http://thingm.com/products/blinkm/)
     - [Datasheet](http://thingm.com/fileadmin/thingm/downloads/BlinkM_datasheet.pdf)