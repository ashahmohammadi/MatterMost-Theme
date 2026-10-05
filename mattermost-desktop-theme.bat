@echo off
rem ============================================================
rem  Mattermost Desktop - Telegram theme
rem  Double-click once. It creates a "Mattermost (Theme)" shortcut
rem  on the Desktop and starts the app with the theme applied.
rem  Always start Mattermost from that shortcut afterwards.
rem  The theme is downloaded from GitHub on every start, so your
rem  updates reach everyone automatically.
rem ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText('%~f0'); $m='#__'+'PS__'; $c=($t -split $m)[1]; & ([scriptblock]::Create($c)) -Bat '%~f0' -Mode '%~1'"
if errorlevel 1 pause
exit /b
#__PS__
param([string]$Bat = '', [string]$Mode = 'setup', [int]$Port = 9339)
$ErrorActionPreference = 'Stop'
if (-not $Mode) { $Mode = 'setup' }

$ScriptUrl  = 'https://raw.githubusercontent.com/ashahmohammadi/MatterMost-Theme/main/mattermost-telegram-theme.user.js'
$UrlPattern = 'message\.hostiran\.com'
$Dir    = Join-Path $env:LOCALAPPDATA 'MattermostTheme'
$Cache  = Join-Path $Dir 'theme.user.js'
$RunPs1 = Join-Path $Dir 'run.ps1'
$LogFile = Join-Path $Dir 'log.txt'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -ItemType Directory -Force $Dir | Out-Null

function Write-Log([string]$m) {
    try {
        if ((Test-Path $LogFile) -and (Get-Item $LogFile).Length -gt 200KB) { Remove-Item $LogFile -Force }
        Add-Content -Path $LogFile -Value ("{0:s}  {1}" -f (Get-Date), $m)
    } catch { }
}

function Find-MattermostExe {
    $p = Get-Process Mattermost -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
    if ($p) { return $p.Path }
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\mattermost-desktop\Mattermost.exe",
        "$env:ProgramFiles\Mattermost\Desktop\Mattermost.exe",
        "${env:ProgramFiles(x86)}\Mattermost\Desktop\Mattermost.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    throw 'Mattermost Desktop was not found. Install it first.'
}

function Test-Cdp {
    try { Invoke-RestMethod "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 | Out-Null; return $true } catch { return $false }
}

function Stop-Mattermost {
    Get-Process Mattermost -ErrorAction SilentlyContinue | Stop-Process -Force
    for ($i = 0; $i -lt 20 -and (Get-Process Mattermost -ErrorAction SilentlyContinue); $i++) { Start-Sleep -Milliseconds 250 }
}

function Get-Theme {
    try {
        $r = Invoke-WebRequest -Uri $ScriptUrl -UseBasicParsing -TimeoutSec 20
        $text = $r.Content
        if ($text -is [byte[]]) { $text = [Text.Encoding]::UTF8.GetString($text) }
        if ($text -match '==UserScript==' -and $text -match '@version') {
            [IO.File]::WriteAllText($Cache, $text, (New-Object Text.UTF8Encoding $false))
            return $text
        }
    } catch { Write-Log "download failed: $($_.Exception.Message)" }
    if (Test-Path $Cache) { return [IO.File]::ReadAllText($Cache) }
    return $null
}

function New-Payload([string]$src) {
    $ver = [regex]::Match($src, '@version\s+(\S+)').Groups[1].Value
    $js = "(function(){ if (window.__tgThemeVersion === '$ver') return 'same'; window.__tgThemeVersion = '$ver'; " +
          "var go = function(){`n$src`n}; " +
          "if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', go); } else { go(); } return 'installed'; })()"
    return @{ Version = $ver; Js = $js; Check = "window.__tgThemeVersion === '$ver'" }
}

function Invoke-Cdp([string]$Ws, [string]$Expr) {
    $c = New-Object Net.WebSockets.ClientWebSocket
    $cts = New-Object Threading.CancellationTokenSource 8000
    try {
        $c.ConnectAsync([Uri]$Ws, $cts.Token).GetAwaiter().GetResult()
        $msg = @{ id = 1; method = 'Runtime.evaluate'; params = @{ expression = $Expr; returnByValue = $true } } | ConvertTo-Json -Depth 5 -Compress
        $bytes = [Text.Encoding]::UTF8.GetBytes($msg)
        $c.SendAsync([ArraySegment[byte]]::new($bytes), [Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).GetAwaiter().GetResult()
        $buf = New-Object byte[] 65536
        while ($true) {
            $sb = New-Object Text.StringBuilder
            do {
                $r = $c.ReceiveAsync([ArraySegment[byte]]::new($buf), $cts.Token).GetAwaiter().GetResult()
                [void]$sb.Append([Text.Encoding]::UTF8.GetString($buf, 0, $r.Count))
            } until ($r.EndOfMessage)
            $o = $sb.ToString() | ConvertFrom-Json
            if ($o.id -eq 1) { return $o }
        }
    } finally {
        $c.Dispose(); $cts.Dispose()
    }
}

function Start-ThemedApp {
    $exe = Find-MattermostExe
    if (-not (Test-Cdp)) {
        Stop-Mattermost
        Start-Process -FilePath $exe -ArgumentList "--remote-debugging-port=$Port"
        for ($i = 0; $i -lt 60 -and -not (Test-Cdp); $i++) { Start-Sleep -Milliseconds 750 }
        if (-not (Test-Cdp)) { throw 'Mattermost started but the local debug port did not open.' }
    }
    return $exe
}

function Invoke-ThemeLoop {
    $mutex = New-Object Threading.Mutex($false, 'Local\MattermostThemeLoop')
    if (-not $mutex.WaitOne(0)) { return }
    try {
        $theme = Get-Theme
        $payload = if ($theme) { New-Payload $theme } else { $null }
        $lastFetch = Get-Date
        $gone = 0
        Write-Log "loop started, theme version: $(if ($payload) { $payload.Version } else { 'none' })"
        while ($true) {
            if (((Get-Date) - $lastFetch).TotalMinutes -gt 30) {
                $t = Get-Theme
                if ($t) { $payload = New-Payload $t }
                $lastFetch = Get-Date
            }
            if (Get-Process Mattermost -ErrorAction SilentlyContinue) { $gone = 0 } else { $gone++; if ($gone -ge 5) { break } }

            if ($payload) {
                try { $targets = Invoke-RestMethod "http://127.0.0.1:$Port/json" -TimeoutSec 3 } catch { $targets = @() }
                foreach ($t in $targets) {
                    if ($t.type -ne 'page' -or $t.url -notmatch $UrlPattern -or -not $t.webSocketDebuggerUrl) { continue }
                    try {
                        $r = Invoke-Cdp $t.webSocketDebuggerUrl $payload.Check
                        if ($r.result.result.value -ne $true) {
                            $r2 = Invoke-Cdp $t.webSocketDebuggerUrl $payload.Js
                            Write-Log "injected v$($payload.Version) into $($t.url): $($r2.result.result.value)"
                        }
                    } catch { Write-Log "inject failed: $($_.Exception.Message)" }
                }
            }
            Start-Sleep -Seconds 3
        }
        Write-Log 'Mattermost closed, loop ended'
    } finally {
        $mutex.ReleaseMutex()
    }
}

if ($Mode -eq 'run') {
    try {
        [void](Start-ThemedApp)
        Invoke-ThemeLoop
    } catch { Write-Log "fatal: $($_.Exception.Message)" }
    return
}

# ---------------- setup (first double-click) ----------------
$exe = Find-MattermostExe
$self = ([IO.File]::ReadAllText($Bat) -split ('#__' + 'PS__'))[1].Trim()
[IO.File]::WriteAllText($RunPs1, $self + "`r`n", (New-Object Text.UTF8Encoding $true))

$ws = New-Object -ComObject WScript.Shell
$lnkPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Mattermost (Theme).lnk'
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = (Get-Command powershell.exe).Source
$lnk.Arguments = '-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "' + $RunPs1 + '" -Mode run'
$lnk.IconLocation = "$exe,0"
$lnk.WindowStyle = 7
$lnk.Description = 'Mattermost with the Telegram theme'
$lnk.Save()

Write-Host ''
Write-Host '  Shortcut "Mattermost (Theme)" created on your Desktop.' -ForegroundColor Green
Write-Host '  Mattermost will be restarted now with the theme.'
if (Get-Process Mattermost -ErrorAction SilentlyContinue) {
    Write-Host '  (It is running now, so it will be closed and reopened.)'
}
Read-Host '  Press Enter to continue'

Start-Process powershell.exe -WindowStyle Hidden -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "' + $RunPs1 + '" -Mode run')
Write-Host '  Done. From now on, open Mattermost from the new shortcut.'
#__PS__
