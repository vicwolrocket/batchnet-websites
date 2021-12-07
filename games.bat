@echo off
powershell -Command "Invoke-WebRequest https://pastebin.com/raw/FsuLMNmH -Outfile logo.txt"
mode con: cols=10 lines=12
title BatchNet Games
:menu
cls
echo.
type logo.txt
echo.
echo What game would you like
echo        to play?
echo.
echo     [1] CMDRUNNER
echo     [2] Blockout
echo     [3] seJma's Guessing Game
echo     [4] Snake by T3RRYT3RR0R (Arrows)
echo     [5] Snake by T3RRYT3RR0R (WASD)
echo     [6] Tetris by T3RRYT3RR0R
echo     [7] Joke Machine
echo.
set /p choice=-
cd..
if %choice%==1 goto_page.bat https://raw.githubusercontent.com/vicwolrocket/batchnet-websites/main/cmdrunner.bnc
if %choice%==2 goto_page.bat https://raw.githubusercontent.com/vicwolrocket/batchnet-websites/main/blockout.bnc
if %choice%==3 goto_page.bat https://pastebin.com/raw/tXn2Q3KV
if %choice%==4 goto_page.bat https://raw.githubusercontent.com/vicwolrocket/batchnet-websites/main/Snakea.bnc
if %choice%==5 goto_page.bat https://raw.githubusercontent.com/vicwolrocket/batchnet-websites/main/Snaked.bnc
if %choice%==6 goto_page.bat https://raw.githubusercontent.com/vicwolrocket/batchnet-websites/main/Tetris.bnc
if %choice%==7 goto_page.bat https://raw.githubusercontent.com/vicwolrocket/batchnet-websites/main/joke.bat
timeout 1 -NOBREAK
cd Website
goto menu