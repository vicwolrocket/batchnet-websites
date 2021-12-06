@echo off
title Joke Machine
:main
cls
echo.
echo Generating joke...
echo.
powershell -Command "Invoke-WebRequest bit.ly/apijokesafe -Outfile joke.txt"
cls
echo.
type joke.txt
echo.
echo.
echo.
echo Press any key for another joke!
pause>nul
goto main