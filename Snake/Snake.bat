@Echo off
==================================================
::: Snake by T3RRY Version 1.2 07/12/2020
::: To play, Download from https://drive.google.com/file/d/1_ivtZsSzxEiig3bdCurNFg7SqGES4T53/view?usp=sharing
::: Download contains:
::::::::::::::::::::::::::::::::::::::::::::::::::
::: Getkey.Exe by Antonio {https://stackoverflow.com/users/778560/aacini} for Extended key controls.
::: Snake.bat by T3RRY {https://stackoverflow.com/users/12343998/t3rr0r}
==================================================
rem /* Enable Codepage for unicode characters */
CHCP 65001 > nul
(Set \n=^^^

%= Macro Newline Do not Modify this code block =%)
(Set COMMENT=rem {i} ^^^

%= Macro Comment line. Do not modify this code block =%)
rem /* use wmic output with find to test if system is windows 10. Exit if not */
 wmic OS get OSArchitecture,caption | FIND "10" > nul || (ECHO/Windows 10 required for ascii escape codes & Exit /B)
rem /* Define Escape character */
 for /F "delims=#" %%a in ('"prompt #$E# & for %%a in (1) do rem"') do set "\E=%%a"
rem ------/* Getkeys controller. allows use of extended keys */
 For /F "Delims=" %%C in ('dir "%~dp0*GetKey.exe" /B /S') Do If not defined GetKey Set "GetKey="%%C" /n"
 Echo/%GetKey%|findstr.exe /LIC:"GetKey.exe" > nul || (Echo/GetKey.Exe not found in Directory. Game cannot be played without GetKey.exe &Pause &Exit /B 0)
rem /* Ensure array used to display screen elements is undefined. */
 (For /F "Tokens=1,2 Delims==" %%G in ('Set "}" 2^> Nul ')Do Set "%%~G=") 2> nul
rem /* game background data file */
If not exist "%TEMP%" (Set "Save.Dir=%~dp0")Else Set "Save.Dir=%TEMP%\"
 Set Background="%Save.Dir%%~n0_background.~tmp"
 Set Foreground="%Save.Dir%%~n0_foreground.~tmp"
 Set Score.Save="%Save.Dir%%~n0_highscore.~sav"
rem /* Console dimensions */
 Set /A ConWidth=80,ConHieght=26
 mode %ConWidth%,%ConHieght%
=============================================================================================
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: Macros to define Playfield Border and display
rem /* output defined }!y!;!x! coordinates to file to be typed for display; Hide cmd Cursor */
 Set "UPDATE.Background=Set /A ".End=!.Ymax! + 1" & ((For /F "Tokens=2* Delims==" %%G in ('Set "}"')Do (< nul Set /P "=%%~G") & < nul Set /P "=%\E%[!.END!;1H%\E%[0m%\E%[?25l")) >%Background% & Type %Background%"
::: Border cells are defined to }Ypos;Xpos for use in collision detection.
rem /* Usage: %Background.Border%{VTcolor}{.Xmin}{.Xmax}{.Ymin}{.Ymax}{.Char} */
 Set Background.Border=Set "Border=" ^& For %%n in (1 2)Do If %%n==2 (%\n%
  %COMMENT:{i}= reset arg Border and capture new value \n%
  For /F "Tokens=1,2,3,4,5,6 Delims={}" %%G in ("!Border!")Do If not "%%L" == "" (%\n%
  %COMMENT:{i}= if 6 args present store in return vars \n%
   Set ".Xmin=%%H"^&Set ".Xmax=%%I"^&Set ".Ymin=%%J"^&Set ".Ymax=%%K"^&Set ".Char=%%L"%\n%
  %COMMENT:{i}= Sides - for .Xmin .Xmax do for each in .Ymin to .Ymax Define border cell \n%
   For %%w in (%%H %%I)Do for /L %%h in (%%J,1,%%K)Do (%\n%
    Set "}%%h;%%w=%\E%[%%h;%%wH%\E%[%%~Gm%%~L"%\n%
  %COMMENT:{i}= Top + Base - for each in .Xmin to .Xmax do IF .Ymin or .Ymax Define border cell \n%
    For %%i in (%%J %%K)Do If %%h Equ %%i (%\n%
     For /L %%W in (%%H 1 %%I)Do (%\n%
      Set "}%%h;%%W=%\E%[%%h;%%WH%\E%[%%~Gm%%~L"%\n%
     )%\n%
    )%\n%
   )%\n%
  )Else (Echo/Missing Args for %%Background.Border%%^& Pause ^> nul)%\n%
 )Else Set Border=
::: Stores return values in Vars: .Xmin .Xmax .Ymin .Ymax .Char
=============================================================================================
:::::: SNAKE display macro. Show / Hide
 Set show.snake=For %%n in (1 2)Do if %%n==2 ( %\n%
  %COMMENT:{i}= Capture Args for {snake.head} and {snake.tail} \n%
  (For /F "Tokens=1,2 Delims={}" %%A in ("!Chars!")Do ( %\n%
  %COMMENT:{i}= Substitute hash value in head variable for {snake.head} and output \n%
   For %%h in ("!head:#=%%~A!")Do ( %\n%
    ^<nul Set /P "=%%~h%\E%[!.End!H" %\n%
   ) %\n%
   For %%t in (!tail!)Do ( %\n%
  %COMMENT:{i}= for each coordinate in tail list output {snake.tail} \n%
    ^<nul Set /P "=%\E%[%%~tH%\E%[!Tail.Color!m%%B%\E%[!.End!H%\E%[0m" %\n%
   ) %\n%
  %COMMENT:{i}= redirect all output to file and type once complete \n%
  ))^>%Foreground% ^& Type %foreground% %\n%
 )Else Set Chars=
=============================================================================================
::: Getkey key errorlevel returns:
:::::: Movement Macros with Collision detection.
 Set "Left={x}{-}"
 Set "Right={x}{+}"
 Set "Up={y}{-}"
 Set "Down={y}{+}"
 Set Move.Snake=For %%n in (1 2) Do if %%n==2 ( %\n%
  %COMMENT:{i}= Capture args for {axis.y.x}{vector+-}{snake.tail}{Pi.Char}\n%
  %COMMENT:{i}= Assume move vaild until proven false \n%
  Set "valid=1" %\n%
  For /F "Tokens=1,2,3,4 Delims={}" %%G in ("!Move.Dir!")Do If not "%%~J" == "" ( %\n%
   %COMMENT:{i}= define offset coords for evaluation of valid move \n%
   If /I "%%G" == "x" (Set /A "lx0=!x0!,ly0=!y0!,nx0= !x0! %%H 1")Else (Set /A "nx0=!x0!") %\n%
   If /I "%%G" == "y" (Set /A "lx0=!x0!,ly0=!y0!,ny0= !y0! %%H 1")Else (Set /A "ny0=!y0!") %\n%
   %COMMENT:{i}= test Cell definition \n%
   For /F "Delims=" %%p in ("!ny0!;!nx0!")Do If not "!{%%p!" == "" ( %\n%
    Set "valid=0" %\n%
    For /F "Delims=" %%v in ("!{%%p!")Do ( %\n%
     Set "Cell=%%v" %\n%
     %COMMENT:{i}= if true cell is tail gameover \n%
     Set "?tail=!Cell:%%I=!" %\n%
     If Not "!?Tail!" == "!Cell!" (Goto :Gameover) %\n%
    ) %\n%
    %COMMENT:{i}= If true cell is Pi makePi \n%
    Set "?tail=!Cell:%%J=!" %\n%
    If Not "!?Tail!" == "!Cell!" ( %\n%
     Set "{!fy!;!fx!="^& Set "fy="^& Set "fx=" %\n%
     Set "Valid=1" %\n%
     Set /A "Score+=50" %\n%
     If "!Delay!" == "0" Set /A "Score+=75" %\n%
     Call :makePi %\n%
     Set /A "tail.len+=1" %\n%
     Set "Tail="!y0!;!x0!",!Tail!" %\n%
     Set "{!ny0!;!nx0!=!Snake.Head!" %\n%
    ) %\n%
   ) %\n%
   %COMMENT:{i}= If cell not tail test next \n%
   If "!valid!" == "1" ( %\n%
    %COMMENT:{i}= If cell is border gameover \n%
    If !n%%G0! LEQ !.%%Gmin! (Goto :Gameover)else If !n%%G0! GEQ !.%%Gmax! (Goto :Gameover)Else ( %\n%
     %COMMENT:{i}= Erases last Head Pos \n%
     If "!Tail.len!" == "0" ( %\n%
      Set "{!y0!;!x0!=" %\n%
      ^<nul Set /P "=%\E%[!y0!;!x0!!H " %\n%
     )Else ( %\n%
      %COMMENT:{i}= Grow Tail \n%
      Set "Tail="!y0!;!x0!",!Tail!" %\n%
      Set "Tail.{i}=0" %\n%
      %COMMENT:{i}= Remove last Cell of tail ; define current tail cells \n%
      For %%r in (!Tail!)Do ( %\n%
       If !Tail.{i}! EQU !Tail.Len! ( %\n%
        Set "Tail=!Tail:,"%%~r"=,!" ^& Set "{%%~r="^&^<nul Set /P "=%\E%[%%~r!H " %\n%
       )Else ( %\n%
        Set "{%%~r=!Snake.Tail!" %\n%
        Set /A "Tail.{i}+=1" %\n%
       ) %\n%
      ) %\n%
     ) %\n%
     %COMMENT:{i}= Define new Head Pos \n%
     Set "{!ny0!;!nx0!=!Snake.Head!" %\n%
     Set /A "%%G0=!n%%G0!" %\n%
    ) %\n%
   ) %\n%
  ) %\n%
 )Else Set Move.Dir=
Set "Info=<nul Set /P "=%\E%[10;55HScore: !Score!%\E%[11;55HHigh Score:!HighScore!%\E%[12;55HPi Eaten:!Tail.Len!%\E%[15;55HDelay:%\E%[K + !Delay! -""
=============================================================================================
::::::::::::::::: End macro definition's 
=============================================================================================
:start
Title Snake by T3RRY & CLS
=============================================================================================
rem /*       Initialise Game variables */
 Set /A "Delay=20,x0=24,y0=12,tail.len=0,Score=0,HighScore=0" & REM snake head start position
 Set "head.color=35"&Set "tail.color=36" & Set "Tail="& REM snake properties
 Set "Snake.Head=@"&Set "Snake.Tail=#"
 Set "head=%\E%[!y0!;!x0!H%\E%[!head.color!m#%\E%[0m"
 Set "Pi.char=%\E%(0{%\E%(B" & set "Pi.color=32"
 Set "}2;55=%\E%[2;55H%\E%[33mControls:"
 Set "}3;55=%\E%[3;55H  ▲    - Up"
 Set "}4;55=%\E%[4;55H  ◄    - Left"
 Set "}5;55=%\E%[5;55H  ▼    - Down"
 Set "}6;55=%\E%[6;55H  ►    - Right"
 Set "}7;55=%\E%[7;55HSpace  - Pause"
 Set "}8;55=%\E%[8;55HEscape - Quit"
rem /* Reference variables for keypress errorlevel { translate errorcode from getkey } */
 Set "k-72=Up"&Set "k-80=Down"&Set "k-75=Left"&Set "k-77=Right"&Set "k32=space"&Set "k43=plus"&Set "k45=minus"&Set "k27=ESC"
rem /* Reference variables to get opposing momentum { prevent tail collision by direction change } */
 Set ".Left=Right"&Set ".Right=Left"&Set ".Up=Down"&Set ".Down=Up"
rem /* Space as pause key; Start game Paused */
 Set "Dir=Space"
==================================
rem /*           Enable Macro's */
 Setlocal EnableExtensions EnableDelayedExpansion
=============================================================================================
rem /* Generate border with desired {Color}{.Xmin}{.Xmax}{.Ymin}{.Ymax}{Character}*/
 %Background.Border%{48;2;150;100;70}{1}{50}{1}{25}{▒}
 %UPDATE.Background%
 Call :makePi
 If exist %Score.Save% (
  <%Score.Save% (Set /P "HighScore=")
 )Else >%Score.Save% Echo/!Score!
=============================================================================================
:gameloop
=========
rem /* Resume momentum possessed prior to Pause  { prevent tail collision by direction change } */
 If Defined Last.Dir If /I Not "!Dir!" == "Space" (
  Set "Dir=!Last.Dir!"
  Set "Last.Dir="
 )
 If !Score! GTR !HighScore! (
  Set "Highscore=!Score!"
  >%Score.Save% Echo/!Score!
 )
rem /* Expand macro displaying Controls ; Score info */
 %INFO%
=============================================================================================
rem /* Test move Doesn't oppose current momentum ; Expand Move.Snake macro with Direction Vector 
rem /* and variables containing Collision test Characters. { If not Paused } */
 If /I not "!Dir!" == "Space" For %%D in (!%Dir%!)Do %Move.Snake%%%D{%Snake.Tail%}{%Pi.char%}
=============================================================================================
 %Show.Snake%{!Snake.Head!}{!Snake.Tail!}
 %getKey%
 For %%e in (!Errorlevel!)Do If not "!k%%e!" == "" For %%v in (!Dir!)Do if not "!k%%e!" == "!.%%v!" (
  Set "Key=!k%%e!"
  If not defined Last.dir If /I "!Key!" == "Space" If /I not "!Dir!" == "!Space!" Set "Last.Dir=!Dir!"
  If /I "!Key!" == "plus" (If !Delay! LSS 150 (Set /A "Delay+=5")&Goto :gameloop)
  If /I "!Key!" == "minus" (If !Delay! GEQ 5 (Set /A "Delay-=5")&Goto :gameloop)
  Set "Dir=!k%%e!"
 )
 If "!Key!" == "" (goto :gameloop)
 If /I "!Key!" == "ESC" (goto :End)
rem /* Enact User Adjustable Delay { + - during gameplay } */
 If %Delay% GTR 0 ( For /L %%d in (1 1 !Delay!)Do Call :Delay 2> nul )Else Call :Delay 2> nul
Goto :gameloop
::: { END gameloop }
=============================================================================================
:Gameover
rem /* update screen elements to highlight death ; End the current session ; restart */
 Title Game over
 Set "Tail.Color=90"
 %Show.Snake%{%\E%[31m!Snake.Head!}{!Snake.Tail!}
 %Background.Border%{48;2;75;75;165}{1}{50}{1}{25}{X}
 %UPDATE.Background%
 Echo/|Choice.exe /N /C:n 2> nul
 Timeout /T 2 /NoBreak > nul
 Pause > Nul
 Del "%Save.Dir%%~n0*.~tmp"
 CLS
 Endlocal
Goto :Start
:End
rem /* restore cmd cursor */
 <nul Set /P "=%\E%[?25h"
 Endlocal
 Del "%Save.Dir%~n0*.~tmp"
 Goto :Eof
=============================================================================================
:makePi function
Setlocal enableDelayedExpansion
:confirmpos
 If not "!fy!" == "" If not "!fx!" == "" (
  <nul Set /P "=%\E%[!fy!;!fx!H %\E%[0m"
 )
 Set "fValid=1"
 Set /a fy=!random! %% (!.Ymax! - 2) + 2,fx=!random! %% (!.Xmax! - 2) + 2
 For /F "delims=" %%g in ("{!fy!;!fx!")Do If Not "!%%g!" == "" (Set "fValid=0")
 For /F "delims=" %%h in ("}!fy!;!fx!")Do If Not "!%%h!" == "" (Set "fValid=0")
 If "!fValid!" == "1" (
  <nul Set /P "=%\E%[!fy!;!fx!H%\E%[%Pi.color%m!Pi.char!%\E%[0m"
  Endlocal & Set "fy=%fy%" & Set "fy=%fx%" & Set "{%fy%;%fx%=%Pi.char%"
  Exit /B 0
 )
Goto :confirmpos