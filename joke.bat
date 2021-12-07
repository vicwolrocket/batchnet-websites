@echo off
title Joke Machine 2.0
color f9
if not exist logo.txt powershell -Command "Invoke-WebRequest https://pastebin.com/raw/wWN3krGS -Outfile logo.txt"
if not exist loading.txt powershell -Command "Invoke-WebRequest https://pastebin.com/raw/hWwDPuYt -Outfile loading.txt"
if exist joke.py del joke.py
echo import requests>>joke.py
echo url = 'https://icanhazdadjoke.com/'>>joke.py
echo headers = {'Accept': 'application/json'}>>joke.py
echo joke_msg = requests.get(url, headers=headers).json().get('joke')>>joke.py
echo f = open('joke.txt', 'w')>>joke.py
echo f.write(joke_msg)>>joke.py
echo f.close()>>joke.py

if not exist C:\Users\DaGreatAdminCake\AppData\Local\Programs\Python\Python310 goto inpy
if not exist C:\Users\DaGreatAdminCake\AppData\Local\Programs\Python\Python310\Lib\site-packages\requests py -m pip install requests
goto run

:inpy
powershell -Command "Invoke-WebRequest https://www.python.org/ftp/python/3.10.1/python-3.10.1-amd64.exe -Outfile install.exe"
install.exe

:run
cls
type logo.txt
echo.
echo.
type loading.txt
joke.py
cls
type logo.txt
echo.
echo.
type joke.txt
echo.
echo Press any key for another joke!
pause>nul
goto run