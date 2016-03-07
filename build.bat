REM ---------------------------------------------------
REM  Copy file and concatenate credentials to init.lua
REM ---------------------------------------------------
copy /b credentials.lua+webserver_blinkm.lua init.lua

REM ---------------------------------------------------
REM  !SUPERHACK!
REM  gzip html to compress file to fit in ESP8266
REM ---------------------------------------------------
7z.exe a -tgzip blinkm.htmlgz blinkm.html
