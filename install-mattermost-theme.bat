@echo off
setlocal
chcp 65001 >nul
title Mattermost Telegram Theme - Installer

rem ============================================================
rem  ONLY THING TO EDIT: the public URL of the script file.
rem  It must end with .user.js and be reachable by every user.
rem  The same URL must be in the script header as @updateURL and
rem  @downloadURL; then Tampermonkey updates it automatically
rem  whenever you raise @version and re-upload the file.
rem ============================================================
set "SCRIPT_URL=https://raw.githubusercontent.com/ashahmohammadi/MatterMost-Theme/main/mattermost-telegram-theme.user.js"

set "TM_CHROME=dhdgffkkebhmkfjojejmpbldmpobfkfo"
set "TM_EDGE=iikmkjmpaadaobahmlepeloendndfphd"
set "CHROME_UPD=https://clients2.google.com/service/update2/crx"
set "EDGE_UPD=https://edge.microsoft.com/extensionwebstorebase/v1/crx"

echo.
echo  ===== Mattermost Telegram Theme =====
echo.
echo  This installs the Tampermonkey extension in your browser and then
echo  opens the theme so Tampermonkey can add it. Updates are automatic.
echo.
echo   1) Google Chrome
echo   2) Microsoft Edge
echo   3) Both
echo   4) Firefox (manual: opens the add-on page)
echo.
choice /c 1234 /n /m "  Your browser [1-4]: "
set "PICK=%errorlevel%"

if "%PICK%"=="4" (
    start "" "https://addons.mozilla.org/firefox/addon/tampermonkey/"
    echo.
    echo  Click "Add to Firefox", then press any key here.
    pause >nul
    start "" firefox "%SCRIPT_URL%"
    echo  In the page that opens, click Install.
    pause
    exit /b 0
)

if "%PICK%"=="1" reg add "HKCU\Software\Policies\Google\Chrome\ExtensionInstallForcelist" /v 9101 /t REG_SZ /d "%TM_CHROME%;%CHROME_UPD%" /f >nul
if "%PICK%"=="3" reg add "HKCU\Software\Policies\Google\Chrome\ExtensionInstallForcelist" /v 9101 /t REG_SZ /d "%TM_CHROME%;%CHROME_UPD%" /f >nul
if "%PICK%"=="2" reg add "HKCU\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" /v 9101 /t REG_SZ /d "%TM_EDGE%;%EDGE_UPD%" /f >nul
if "%PICK%"=="3" reg add "HKCU\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" /v 9101 /t REG_SZ /d "%TM_EDGE%;%EDGE_UPD%" /f >nul

echo.
echo  Step 1 done: Tampermonkey is queued for installation.
echo.
echo  Now CLOSE ALL browser windows, open the browser again and wait
echo  about one minute until the Tampermonkey icon appears.
echo.
echo  Chrome only: open chrome://extensions, click Tampermonkey "Details"
echo  and turn on "Allow User Scripts" (required by Chrome).
echo.
echo  When that is ready, press any key to install the theme.
pause >nul

if "%PICK%"=="1" start "" chrome "%SCRIPT_URL%"
if "%PICK%"=="2" start "" msedge "%SCRIPT_URL%"
if "%PICK%"=="3" start "" chrome "%SCRIPT_URL%"

echo.
echo  In the Tampermonkey page that opens, click Install.
echo  Then reload Mattermost. Done.
echo.
pause
endlocal
