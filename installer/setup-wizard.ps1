# TelDrive Easy - First-Run Setup Wizard
# Friend-testing build: shared Supabase, per-user Telegram credentials.
# Each user provides their OWN api_id + api_hash so Kaarthik's Telegram
# account is never used as a backend (no ban risk).

$ErrorActionPreference = 'Stop'

$ProgramData = Join-Path $env:ProgramData 'TelDrive'
$ConfigPath  = Join-Path $ProgramData 'config.toml'
$BinaryPath  = Join-Path ${env:ProgramFiles} 'TelDrive\teldrive.exe'

# === SHARED SUPABASE (embedded, friend-testing only) =========================
# This is the SAME database all friends connect to during the testing phase.
# Kaarthik's database, Kaarthik's cost. Files still go to each USER'S Telegram.
$SHARED_DB_URL = 'postgresql://postgres:REPLACE_WITH_YOUR_PASSWORD@db.bkcdidfqyaypifwtoyfs.supabase.co:5432/postgres'
# =============================================================================

function Write-Header($Text) {
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host ""
}

function Read-Required($Prompt, $Validate = $null) {
    while ($true) {
        $val = Read-Host $Prompt
        if ([string]::IsNullOrWhiteSpace($val)) {
            Write-Host "  [!] Required." -ForegroundColor Yellow; continue
        }
        if ($Validate -and ($val -notmatch $Validate)) {
            Write-Host "  [!] Wrong format. Try again." -ForegroundColor Yellow; continue
        }
        return $val.Trim()
    }
}

function New-HexKey { -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Max 256) }) }

# --- Welcome ---
Clear-Host
Write-Header "TelDrive Easy - by Kaarthik Dass Arora"

Write-Host "Hi! This wizard sets up your personal Telegram cloud drive."
Write-Host ""
Write-Host "You will need (free, ~3 minutes):"
Write-Host "  - A Telegram account"
Write-Host "  - A private Telegram channel (any name)"
Write-Host "  - Telegram api_id + api_hash from https://my.telegram.org"
Write-Host ""
Write-Host "Files you upload go into YOUR own Telegram channel."
Write-Host "Only YOU can access them. Even Kaarthik can't see them." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to begin"

# --- Step 1: Open my.telegram.org for them ---
Write-Header "Step 1 of 2 - Get your Telegram credentials"

Write-Host "Opening https://my.telegram.org in your browser..."
Write-Host ""
Write-Host "WHAT TO DO THERE:"
Write-Host "  1. Log in with your phone number (Telegram sends a code)"
Write-Host "  2. Click 'API development tools'"
Write-Host "  3. Fill in any name, e.g. 'TelDrive'. Platform = Desktop."
Write-Host "  4. Click 'Create application'"
Write-Host "  5. Copy the 'App api_id' (number) and 'App api_hash' (32-char string)"
Write-Host ""
Write-Host "    KEEP THESE PRIVATE - they're like passwords." -ForegroundColor Yellow
Write-Host ""

Start-Process "https://my.telegram.org"
Start-Sleep 2

$apiId   = Read-Required "Paste your api_id (numbers only)" '^\d+$'
$apiHash = Read-Required "Paste your api_hash (32 hex chars)" '^[0-9a-fA-F]{32}$'
$tgUser  = Read-Required "Your Telegram username (without the @)"

# --- Step 2: Create channel reminder ---
Write-Header "Step 2 of 2 - Telegram channel"

Write-Host "Open Telegram (phone or desktop) and create a NEW PRIVATE CHANNEL:"
Write-Host "  - Open Telegram -> tap pencil/compose -> New Channel"
Write-Host "  - Name: anything, e.g. 'My TelDrive Storage'"
Write-Host "  - Make it PRIVATE (not public)"
Write-Host "  - Skip adding members"
Write-Host ""
Write-Host "TelDrive will detect this channel automatically when you log in." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter once your channel exists"

# --- Generate config ---
Write-Header "Finalizing"

$jwtSecret = New-HexKey
$encKey    = New-HexKey

if (-not (Test-Path $ProgramData)) {
    New-Item -Path $ProgramData -ItemType Directory -Force | Out-Null
}

$config = @"
[db]
data-source = "$SHARED_DB_URL"
prepare-stmt = false

[db.pool]
enable = false

[jwt]
allowed-users = ["$tgUser"]
secret = "$jwtSecret"

[tg]
ntp = true
app-id = $apiId
app-hash = "$apiHash"

[tg.uploads]
encryption-key = "$encKey"
"@

Set-Content -Path $ConfigPath -Value $config -Encoding UTF8 -NoNewline
Write-Host "  [OK] config.toml written" -ForegroundColor Green

# Lock down config to current user
icacls $ConfigPath /inheritance:r /grant:r "${env:USERNAME}:(F)" "SYSTEM:(F)" 2>&1 | Out-Null

# Register 24/7 service
schtasks /Delete /TN "TelDrive" /F 2>$null | Out-Null
$taskCmd = "`"$BinaryPath`" run --config-file `"$ConfigPath`""
schtasks /Create /TN "TelDrive" /TR $taskCmd /SC ONSTART /RL HIGHEST /RU "$env:USERNAME" /F | Out-Null

$t = Get-ScheduledTask -TaskName 'TelDrive'
$t.Settings.RestartCount = 999
$t.Settings.RestartInterval = 'PT1M'
$t.Settings.ExecutionTimeLimit = 'PT0S'
$t.Settings.DisallowStartIfOnBatteries = $false
$t.Settings.StopIfGoingOnBatteries = $false
Set-ScheduledTask -TaskName 'TelDrive' -Settings $t.Settings | Out-Null

schtasks /Run /TN "TelDrive" 2>&1 | Out-Null
Write-Host "  [OK] TelDrive service started (runs 24/7, auto-restart on crash)" -ForegroundColor Green

Start-Sleep 5

Write-Header "All done!"
Write-Host "Your TelDrive: " -NoNewline
Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening in your browser - log in with your Telegram phone number."
Start-Process "http://localhost:8080"

Write-Host ""
Write-Host "Mobile apps coming soon. Stay tuned." -ForegroundColor Magenta
Write-Host ""
Write-Host "  - Made by Kaarthik Dass Arora" -ForegroundColor DarkGray
Write-Host ""
Read-Host "Press Enter to close"
