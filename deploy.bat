@echo off
title Telegram Clone - localhost:3000
color 0A
cls

echo.
echo  ==========================================
echo   TELEGRAM CLONE  ^|  http://localhost:3000
echo  ==========================================
echo.

:: ── Always run from the folder this .bat lives in ──────────
cd /d "%~dp0"

:: ── Try common Node.js install locations ───────────────────
if exist "C:\Program Files\nodejs\node.exe"       set "PATH=C:\Program Files\nodejs;%PATH%"
if exist "C:\Program Files (x86)\nodejs\node.exe" set "PATH=C:\Program Files (x86)\nodejs;%PATH%"
if exist "%APPDATA%\nvm\current\node.exe"          set "PATH=%APPDATA%\nvm\current;%PATH%"

:: ── Check Node.js is available ─────────────────────────────
node --version >nul 2>&1
if %errorlevel% neq 0 goto :installnode

for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VER=%%v
echo  [+] Node.js found: %NODE_VER%
goto :launch

:installnode
echo  [!] Node.js not found. Downloading installer...
echo.

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "NODE_URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
) else (
    set "NODE_URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x86.msi"
)
set "NODE_FILE=%TEMP%\node-installer.msi"

echo  [*] Downloading Node.js v20.11.1 LTS...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%NODE_FILE%'"
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Download failed. Check your internet connection.
    goto :fail
)

echo  [*] Installing Node.js silently (takes ~1 minute)...
msiexec /i "%NODE_FILE%" /quiet /norestart ADDLOCAL=ALL
echo  [*] Waiting for install to finish...
timeout /t 20 /nobreak >nul

set "PATH=C:\Program Files\nodejs;%PATH%"

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] Node installed but PATH not refreshed yet.
    echo  [!] CLOSE this window and run deploy.bat again.
    goto :fail
)

for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VER=%%v
echo  [+] Node.js installed: %NODE_VER%

:launch
:: ── Check server.cjs exists ────────────────────────────────
if not exist "server.cjs" (
    echo.
    echo  [ERROR] server.cjs not found.
    echo  [ERROR] Run deploy.bat from inside the project folder.
    goto :fail
)

:: ── Check dist folder exists (build) ───────────────────────
if not exist "dist\index.html" (
    echo.
    echo  [*] dist/ not found. Building project...
    call npm install
    call npm run build
    if not exist "dist\index.html" (
        echo  [ERROR] Build failed.
        goto :fail
    )
    echo  [+] Build complete.
)

:: ── Kill anything already on port 3000 ─────────────────────
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":3000 "') do (
    taskkill /PID %%p /F >nul 2>&1
)

echo.
echo  ==========================================
echo   Server starting on http://localhost:3000
echo   Press Ctrl+C to stop the server.
echo  ==========================================
echo.

:: ── Open browser after 2 seconds ───────────────────────────
start "" cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:3000"

:: ── Launch — zero runtime dependencies ─────────────────────
node server.cjs

echo.
echo  [!] Server stopped.
goto :done

:fail
echo.
pause
exit /b 1

:done
pause
exit /b 0
