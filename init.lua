-- Network Variables --
ssid = "telenet-00DF1"
pass = "f8JMe0vKGBwG"

-- i2c Variables --
id = 0
sda = 1
scl = 2

-- Colors --
colors = {
	red = "red",
	blue = "blue",
	green = "green"
}

-- Set led --
function set_led(color)
	if color == colors.red then
		print("Set red")
		i2c.start(id)
		i2c.address(id, 0x09, i2c.TRANSMITTER)
		i2c.write(id, 0x6e)
		i2c.write(id, 0xff)
		i2c.write(id, 0x00)
		i2c.write(id, 0x00)
		i2c.stop(id)
	elseif color == colors.green then
		print("Set green")
		i2c.start(id)
		i2c.address(id, 0x09, i2c.TRANSMITTER)
		i2c.write(id, 0x6e)
		i2c.write(id, 0x00)
		i2c.write(id, 0xff)
		i2c.write(id, 0x00)
		i2c.stop(id)
	else
		print("Set blue")
		i2c.start(id)
		i2c.address(id, 0x09, i2c.TRANSMITTER)
		i2c.write(id, 0x6e)
		i2c.write(id, 0x00)
		i2c.write(id, 0x00)
		i2c.write(id, 0xff)
		i2c.stop(id)
	end
end

-- wait
tmr.alarm(1, 1000, 1, function()
	if wifi.sta.getip() == nil then
		print("Waiting for WiFi connection\n")
	else
		tmr.stop(1)
		print("ESP8266 mode is: " .. wifi.getmode())
		print("The module MAC address is: " .. wifi.ap.getmac())
		print("Config done, IP is " .. wifi.sta.getip())
	end
end)

-- serve webpage --
local function read_web_page(filename)
	file.open(filename, "r")
	local content = file.read()
	file.close()
	return content
end

-- Build and return a table of the http request data
function get_http_req (instr)
   local t = {}
   local first = nil
   local key, v, strt_ndx, end_ndx

   for str in string.gmatch (instr, "([^\n]+)") do
      -- First line in the method and path
      if (first == nil) then
         first = 1
         strt_ndx, end_ndx = string.find(str, "([^ ]+)")
         v = trim(string.sub(str, end_ndx + 2))
		 v_parsed = string.match(v, "(%S+) (%S+)")
         key = trim(string.sub(str, strt_ndx, end_ndx))
         t["METHOD"] = key
         t["REQUEST"] = v_parsed
      else -- Process and reamaining ":" fields
         strt_ndx, end_ndx = string.find(str, "([^:]+)")
         if (end_ndx ~= nil) then
            v = trim(string.sub(str, end_ndx + 2))
            key = trim(string.sub(str, strt_ndx, end_ndx))
			if (string.find(key, "=") ~= nil) then
				-- check if request data is posted data
				t["POST_DATA"] = key
			else
            	t[key] = v
			end
         end
      end
   end

   return t
end

-- String trim left and right
function trim (s)
  return (s:gsub ("^%s*(.-)%s*$", "%1"))
end

-- Web server --
local function connect(conn)
	print(domain)
	local query_data
	local webpage
	
	conn:on("receive",
		function (conn, req_data)
			-- Parse request
			query_data = get_http_req(req_data)
			print(query_data["METHOD"] .. " " .. " " .. query_data["User-Agent"])
			for k, v in pairs(query_data) do
				print(k, v)
			end
			
			if query_data["METHOD"] == "GET" then
				print("Got GET\n")
				webpage = read_web_page("blinkm.htmlgz")
				--print(webpage)
				conn:send("HTTP/1.1 200 OK\n")
                conn:send("Content-Encoding: gzip\n\n")
				conn:send(webpage)
				conn:close()
			elseif query_data["METHOD"] == "POST" then
				local key, color
				
				print("Got POST\n")
				if query_data["REQUEST"] == "/set-led" then
					-- parse post data
					key, color = query_data["POST_DATA"]:match("(%w+)=(%w+)")
					set_led(color)
					conn:send('HTTP/1.1 302 Found\n')
					conn:send('Location: /\n\n')
					conn:close()
				else				
					conn:send('HTTP/1.1 400 Bad Request\n\n')
					conn:close()
				end
			end
		end)
end

-- Init --
--- Setup Wifi ---
print("Setting up WiFi")
wifi.setphymode(wifi.PHYMODE_N)
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid, pass, 1)

--- Init i2c ---
i2c.setup(id, sda, scl, i2c.SLOW)
i2c.start(id)
i2c.address(id, 0x09, i2c.TRANSMITTER)
i2c.write(id, 0x6f)
i2c.write(id, 0x6e)
i2c.write(id, 0x00)
i2c.write(id, 0x00)
i2c.write(id, 0x00)
i2c.stop(id)

--- Start web server ---
svr = net.createServer(net.TCP)
svr:listen(80, connect)