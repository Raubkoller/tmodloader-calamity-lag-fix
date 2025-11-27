@echo off

set "gameSubDir=My Games\Terraria"

REM Documents\My Games\Terraria 
for /f usebackq %%a in (
    `powershell -command "[Environment]::GetFolderPath('Personal')"`
) do (set "docs_folder=%%a")

set "myGamesPath=%docs_folder%\%gameSubDir%"

REM if terraria folder isn't found, check for Onedrive folder
IF NOT EXIST "%myGamesPath%" (
    setlocal enableDelayedExpansion
    set "foundPath="

    REM Check for OneDriveConsumer variable
    if not defined OneDriveConsumer (
        echo The environment variable %%OneDriveConsumer%% is not defined.
        pause
        exit
    )

    echo Looking for "%gameSubDir%" in subdirectories:
    echo %OneDriveConsumer%\*

    REM Check all directories in %OneDriveConsumer% for the presense of "My Games\Terraria"
    for /D %%d in ("%OneDriveConsumer%\*") do (
        
        set "targetPath=%%d\%gameSubDir%"

        REM Check if path exists
        if exist "!targetPath!" (
            set "foundPath=!targetPath!"
            goto FOUND
        )
    )

    :NOT_FOUND
    REM if folder still isn't found, exit
    ECHO Terraria folder not found at "%docs_folder%\%gameSubDir%" or "%OneDriveConsumer%\*\%gameSubDir%"
    pause
    endlocal
    exit

    :FOUND
    echo Found
    endlocal & set "myGamesPath=%foundPath%"
)

ECHO My Games Path: %myGamesPath%

set "file1=%myGamesPath%\config.json"
set "file2=%myGamesPath%\tModLoader\config.json"
ECHO Config File 1 Path: %file1%
ECHO Config File 2 Path: %file2%

set "key="MultiplayerNPCSmoothingRange""
set "new_value=0"	

setlocal enabledelayedexpansion
REM Process the terraria config
if exist "%file1%" (
    echo Updating file: %file1%
    attrib "%file1%" | find /i "R" >nul
    if not errorlevel 1 (
        attrib -r "%file1%"
        echo Removed read-only attribute from: %file1%
    )

    > "%file1%.temp" (
        set "modified=0"
        for /f "tokens=* delims=" %%i in ('findstr /n "^" "%file1%"') do (
            set "line=%%i"
            set "line=!line:*:=!"
            if !modified! equ 0 (
                echo !line! | findstr /c:%key% >nul
                if not errorlevel 1 (
                    set "line=  %key%: %new_value%,"
                    set "modified=1"
                )
            )
            echo !line!
        )
    )

    move /y "%file1%.temp" "%file1%" >nul

    REM Make the file read-only
    attrib +r "%file1%"
    echo Updated and made read-only: %file1%
) else (
    echo File not found: %file1%
    pause
)

REM Process the tmodLoader config
if exist "%file2%" (
    echo Updating file: %file2%
    attrib "%file2%" | find /i "R" >nul
    if not errorlevel 1 (
        attrib -r "%file2%"
        echo Removed read-only attribute from: %file2%
    )

    > "%file2%.temp" (
        set "modified=0"
        for /f "tokens=* delims=" %%i in ('findstr /n "^" "%file2%"') do (
            set "line=%%i"
            set "line=!line:*:=!"
            if !modified! equ 0 (
                echo !line! | findstr /c:%key% >nul
                if not errorlevel 1 (
                    set "line=  %key%: %new_value%,"
                    set "modified=1"
                )
            )
            echo !line!
        )
    )

    move /y "%file2%.temp" "%file2%" >nul

    REM Make the file read-only
    attrib +r "%file2%"
    echo Updated and made read-only: %file2%
) else (
    echo File not found: %file2%
    pause
)

endlocal
