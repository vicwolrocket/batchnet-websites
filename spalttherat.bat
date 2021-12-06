@echo off
if /i "%1"=="Attrib" (
goto checkhighscore.txt
)
if /i "%1"=="Countermode" (
goto countermode
)
title Splat-The-Rat
setlocal enabledelayedexpansion
for %%I in (%0) do set filename=%%~sI
if exist highscore.txt (
start /MIN CMD.exe /c "%FILENAME% Attrib"
)
if exist info.dat del info.dat
:menu
title Splat-The-Rat
cls
echo Main Menu
echo ---------
echo.
echo To play a game, enter 1
echo For instructions, enter 2
echo For Highscores, enter 3
echo To exit, enter 4
set menu=
set /p menu=""
if not defined menu goto menu
if %menu%==1 (goto startgame)
if %menu%==2 (goto instructions)
if %menu%==3 (goto Displayscores)
if %menu%==4 (exit /b)
goto menu

:checkhighscore.txt
attrib highscore.txt | find "SHR" >nul
if %errorlevel%==0 (exit)
attrib highscore.txt +S +H +R
exit

:instructions
cls
echo Splat The Rat
echo -------------
echo The aim of the game is to hit the rat with your club as soon as it
echo pops out of its hole. You can try hitting the rat
echo with the quickest reaction time, or hit as many rats in a row as
echo possible. Your score is recorded in the same directory as the game
echo file.
echo.
echo.
echo Press any key for the next page
pause>nul
cls
echo Splat The Rat
echo -------------
echo As soon as you start the game one extra window will appear, titled
echo 'Rat Window' this window shows the activity of the rat. As soon as
echo the window appears it should be dragged away from the original
echo Bat Window to allow you to see both. You should then click on the
echo Bat Window to allow you to use your bat.
echo.
echo.
echo Press any key for the next page
pause>nul
cls
echo Splat The Rat
echo -------------
echo To hit the rat, have the Bat Window selected, and press any key as soon
echo as you see the rat appear on the Rat Window.
echo.
echo.
echo Press any key to go to the main menu.
pause>nul
goto menu


:displayscores
cls
if not exist highscore.txt (
echo No high scores yet.
echo.
echo Press any key to return to menu
pause>nul
goto menu
)
find /i "Fastest-Single-Reaction=" Highscore.txt >nul
set count=%errorlevel%
find /i "Most-Rats-Hit=" Highscore.txt >nul
set /a count= %count% + %errorlevel%
find /i "Best-Average-Reaction=" Highscore.txt >nul
set /a count= %count% + %errorlevel%
if %count%==3 (
echo High Score File Incorrect
echo.
echo Press any key to return to menu
pause>nul
goto menu
)
echo High Scores
echo -----------
echo.
type highscore.txt | find /i "fastest-Single-Reaction"
type highscore.txt | find /i "Most-Rats-Hit"
type highscore.txt | find /i "Best-Average-Reaction"
echo.
echo.
echo Press any key to return to menu
pause>nul
goto menu



:startgame
title Bat Window
cls
set fastestreaction=999
set SN=0
set totalmil=0
set offset=10
echo nul >info.dat
start cmd /c "%filename% Countermode"
Echo Move the Rat window so you can see both windows, then click
echo this window.
echo.
echo Press any key to begin the game
pause>nul
echo START >info.dat
cls
echo Press Any Key To Swing Your Bat!
Pause>nul
set swingtime=%time:~2%
echo Y%SN%-%swingtime% >>info.dat


:result
find /i "w%SN%" info.dat >nul
if %errorlevel%==0 (
cls
set /a sn= %SN% + 1
goto Swingagain
)
find /i "l" info.dat >nul
if %errorlevel%==0 (
cls
echo Game Over
goto gotresult
)
goto result

:swingagain
echo Good Hit
if %sn%==1 (
echo Got 1 rat so far
) else (
echo Got %sn% rats so far
)

:processreactiontime
if %sn% geq 11 set offset=11
if %sn% geq 101 set offset=12
set x=1
for /f %%A in (info.dat) do set data=%%A & call :Setswingtime
set x=1
for /f %%A in (info.dat) do set data=%%A & call :Setfalltime
set /a CFN= ( %sn% * 3 ) - 1
set /a CSN= %sn% * 3
set truefalltime=!falltime%CFN%!
set truefalltime=!truefalltime:~%offset%,2!
set trueswingtime=!swingtime%CSN%!
set trueswingtime=!trueswingtime:~%offset%,2!
if /i %trueswingtime%==08 (
set trueswingtime=8
)
if /i %trueswingtime%==09 (
set trueswingtime=9
)
if /i %truefalltime%==08 (
set truefalltime=8
)
if /i %truefalltime%==09 (
set truefalltime=9
)
set /a reactionmil= %trueswingtime% - %truefalltime%
if /i %reactionmil% lss 0 (
set /a reactionmil= %reactionmil% + 100
)
if /i %reactionmil% leq 9 (
echo Your reaction time was 0.0%reactionmil% Seconds
) else (
echo Your reaction time was 0.%reactionmil% Seconds
)
goto continueswingagain

:setswingtime
set Swingtime%x%=%data%
set /a x= %x% + 1
exit /b

:setfalltime
set falltime%x%=%data%
set /a x= %x% + 1
exit /b

:continueswingagain
echo.
echo Press Any Key To Swing Your Bat
pause>nul
set swingtime=%time:~2%
echo Y%SN%-%swingtime% >>info.dat
set /a totalmil= %totalmil% + %reactionmil%
if not defined fastestreaction (set fastestreaction=%reactionmil%)
if /i %fastestreaction% gtr %reactionmil% (
set fastestreaction=%reactionmil%
)
goto result


:Gotresult
if %sn% equ 0 (
echo Sorry, you didn't get any rats
goto moreresults
)
if %sn% equ 1 (
echo Sorry, you only got one rat
goto Moreresults
)
if /i %sn% leq 3 (
echo Sorry, you only got %sn% rats
) else (
echo Well done, you got %sn% rats
)
:moreresults
find /i info.dat "LL" >nul
if /i %errorlevel% equ 0 (
Echo On that last one, you were too slow, he got away.
) else (
echo On that last one, you swung too soon.
)
IF %sn%==0 goto end
:processrats
set /a averagetime= %totalmil% / %sn%
echo You got %sn% rats
echo Your average reaction time was 0.%averagetime% seconds
if /i %fastestreaction% leq 9 (
echo Your reaction time was 0.0%fastestreaction% Seconds
) else (
echo Your reaction time was 0.%fastestreaction% Seconds
)
if not exist highscore.txt goto noscorelist
goto scorelistexists

:noscorelist
set most=1
set best=1
set fastest=1
goto changescore

:scorelistexists
set most=
set fastest=
set best=
find /i "Most-Rats-Hit" Highscore.txt >nul
if /i NOT %errorlevel% equ 0 (
set Most=1
)
find /i "Fastest-Single-Reaction" Highscore.txt >nul
if /i NOT %errorlevel% equ 0 (
set Fastest=1
)
find /i "Best-Average-reaction" Highscore.txt >nul
if /i NOT %errorlevel% equ 0 (
set Best=1
)
goto Mustcompare

:Mustcompare
for /f %%A in (highscore.txt) do set data=%%A & call :RHset
set sorted=
for /f %%A in (highscore.txt) do set data=%%A & call :BAset
set sorted=
for /f %%A in (highscore.txt) do set data=%%A & call :FRset
set sorted=
set oldRH=%oldRH:~20%
set oldBA=%oldBA:~30,2%
set oldFR=%oldFR:~32,2%
goto comparetime

:rhset
set variable=OldRH
set keyword=Most
call :sortvariables
exit /b

:baset
set variable=OldBA
set keyword=Best
call :sortvariables
exit /b

:frset
set variable=OldFR
set keyword=Fastest
call :sortvariables
exit /b

:sortvariables
if defined sorted (goto endsortvariables)
set %variable%=%data%
echo !%variable%! | find /i "%keyword%" >nul
if NOT errorlevel 1 (
set sorted=1
) else (
set %variable%=
)
:endsortvariables
exit /b

:comparetime
if defined fastest goto alreadyfastest
if /i %fastestreaction% lss %oldfr% (
set fastest=1
)
:alreadyfastest
if defined Most goto alreadymost
if /i %oldRH% lss %SN% (
set Most=1
)
:alreadymost
if defined best goto alreadybest
if /i %averagetime% lss %OldBA% (
set Best=1
)
:alreadybest
if defined best goto Changescore
if defined most goto Changescore
if defined fastest goto Changescore
goto end

:changescore
echo.
Echo New High Score!
echo ---------------
echo New Score In:
echo.
if defined most (
echo Most Rats Hit
)
if defined best (
echo Best Average Time
)
if defined fastest (
echo Fastest Single Reaction
)
echo.
set initials=
echo Please Enter Your Initials (3 Characters Maximum)
set /p initials=""
IF NOT defined initials (
cls
goto changescore
)
if "%initials:~1%"=="" (
set initials=%initials%--
)
if "%initials:~2%"=="" (
set initials=%initials%-
)
set initials=%initials:~0,3%

if defined most goto editmost
goto checkeditbest

:editmost
if /i %fastestreaction% leq 9 (
set fastestreaction=0%fastestreaction%
)
if exist highscore.txt (
type highscore.txt | find /i /v "most-rats-hit" >Highscore
attrib highscore.txt -s -h -r
type highscore >Highscore.txt
attrib highscore.txt +s +h +r
del highscore
attrib highscore.txt -s -h -r
echo %initials%---Most-Rats-Hit=%sn% >>Highscore.txt
attrib highscore.txt +s +h +r
) else (
echo %initials%---Most-Rats-Hit=%sn% >>Highscore.txt
attrib highscore.txt +s +h +r
)

:checkeditbest
if defined best goto editbest
goto checkeditfastest

:editbest
if exist highscore.txt (
type highscore.txt | find /i /v "best-average-reaction" >Highscore
attrib highscore.txt -s -h -r
type highscore >Highscore.txt
attrib highscore.txt +s +h +r
del highscore
attrib highscore.txt -s -h -r
echo %initials%---Best-Average-Reaction=0.%averagetime% >>Highscore.txt
attrib highscore.txt +s +h +r
) else (
echo %initials%---Best-Average-Reaction=0.%averagetime% >>Highscore.txt
attrib highscore.txt +s +h +r
)

:checkeditfastest
if defined fastest goto editfastest
goto scoresedited

:editfastest
if exist highscore.txt (
type highscore.txt | find /i /v "Fastest-Single-Reaction" >Highscore
attrib highscore.txt -s -h -r
type highscore >Highscore.txt
attrib highscore.txt +s +h +r
del highscore
attrib highscore.txt -s -h -r
echo %initials%---Fastest-Single-Reaction=0.%fastestreaction% >>Highscore.txt
attrib highscore.txt +s +h +r
) else (
echo %initials%---Fastest-Single-Reaction=0.%fastestreaction% >>Highscore.txt
attrib highscore.txt +s +h +r
)

:Scoresedited
echo Scores Saved
echo.
goto end


:end
del info.dat
pause>nul

:playagain
echo Go to menu? (Y/N)
:playagain1
set choice=
set /p choice=""
if /i "%choice:~0,1%"=="Y" (
goto menu
)
if /i "%choice:~0,1%"=="N" (
exit /b
)
goto playagain


::###################################################################

:COUNTERMODE
@echo off
color f0
title Rat Window
setlocal enabledelayedexpansion
echo Move this window so you can see both windows.
echo Have the Bat window selected and press any key to begin the game
:waittostart
type info.dat | find /i "start" >nul
if %errorlevel%==0 (goto TimeTostart) else (goto waittostart)
:TimeToStart
set timestart=%time:~2%
echo X%timestart% >info.dat
set SN=-1
set w=0
cls
goto timesetup


:1
find info.dat "Y%sn%" >nul
if %errorlevel%==0 goto stop
if /i %time:~6,2% equ %timechange% goto ShowRat
goto noRats

:ShowRat
set ztime%sn%=Z%sn%-%time:~2%
cls
call :showrat
set w=1
set timechange=CHANGE_DONE
echo !ztime%sn%! >>info.dat

:noRats
if /i %time:~6,2% equ %timeback% (
cls
call :norat
echo.
echo You missed the rat!
echo Swing your bat to end the game.
set w=0
set timeback=CHANGE_DONE
set L=L
)
goto 1

:STOP
if /i %w%==1 (
echo W%sn% >>info.dat
) else (
echo L%L% >>info.dat
exit /b
)

:Timesetup
cls
call :norat
set w=0
set /a sn= %sn% + 1
set timestart=%time:~2%
set timechange=%timestart:~4,2%
if /i %timechange% equ 08 (set timechange=8)
if /i %timechange% equ 09 (set timechange=9)
set /a timechange= %timechange% + 2 + %random:~1,1%
if %timechange% geq 60 (
set /a timechange= %timechange% - 60
)
set /a timeback= %timechange% + 1
if %timeback% geq 60 (
set /a timeback=%timeback% - 60
)
if /i %timechange% equ 8 (
set timechange=08
)
if /i %timechange% equ 9 (
set timechange=09
)
if /i %timeback% equ 8 (
set timeback=08
)
if /i %timeback% equ 9 (
set timeback=09
)

goto 1


:NORAT
echo __ __ __ __ __ __ __ __ __
echo [__][__][__][__][__][__][__][__][__]
echo _][__][__][__][__][__][__][__][__][_
echo [__][__][__][__][__][__][__][__][__]
echo _][__][__][__][__][__][__][__][__][_
echo [__][__][__][__][__][__][__][__][__]
echo _][__][__][__][__][__][__][__][__][_
echo [__][__][__][__][__][__][__][__][__]
echo ____________________________________
exit /b

:showrat
echo __ __ __ __ __ __ __ __ __
echo [__][__][__][__][__][__][__][__][__]
echo _][__][__][__][__][__][__][__][__][_
echo [__][__][__] __ __ _][__][__][__]
echo _][__][__] (_.)__(._) __][__][__][_
echo [__][__][__] (- -) _][__][__][__]
echo _][__][__][ --{()}-- [__][__][__][_
echo [__][__][__] (____) _][__][__][__]
echo ______________''__''________________
exit /b