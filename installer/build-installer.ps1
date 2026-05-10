# build-installer.ps1
# Local-only builder for TelDriveSetup.exe
#
# Run from inside the installer/ folder:
#   powershell -ExecutionPolicy Bypass -File .\build-installer.ps1

$ErrorActionPreference = 'Stop'

# --- Paths ---
$Root         = Split-Path -Parent $PSScriptRoot
$InstallerDir = $PSScriptRoot
$BuildDir     = Join-Path $InstallerDir 'build'
$DistDir      = Join-Path $Root 'dist'
$IsccPath     = 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'

if (-not (Test-Path $IsccPath)) {
    throw "Inno Setup 6 not found at $IsccPath. Install from https://jrsoftware.org/isdl.php"
}

$UpstreamVersion = '1.8.3'
$ZipUrl = "https://github.com/tgdrive/teldrive/releases/download/$UpstreamVersion/teldrive-$UpstreamVersion-windows-amd64.zip"

if (-not (Test-Path $BuildDir)) { New-Item $BuildDir -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $DistDir))  { New-Item $DistDir  -ItemType Directory -Force | Out-Null }

# --- Step 1: Get Supabase URL from user ---
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  TelDrive Easy - local installer builder" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Paste your Supabase Postgres connection string."
Write-Host "Format: postgresql://postgres:PASSWORD@db.xxx.supabase.co:5432/postgres"
Write-Host ""

$SecureUrl   = Read-Host "Supabase URL" -AsSecureString
$SupabaseUrl = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureUrl))

if ($SupabaseUrl -notmatch '^postgres(ql)?://') {
    throw "Does not look like a postgres URL. Aborting."
}

# --- Step 2: Download upstream teldrive.exe ---
$TeldriveExe = Join-Path $BuildDir 'teldrive.exe'
if (-not (Test-Path $TeldriveExe)) {
    Write-Host ""
    Write-Host "Downloading teldrive $UpstreamVersion (Windows amd64)..." -ForegroundColor Yellow
    $ZipPath = Join-Path $BuildDir 'teldrive.zip'
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $BuildDir -Force
    Remove-Item $ZipPath
    if (-not (Test-Path $TeldriveExe)) {
        $found = Get-ChildItem $BuildDir -Filter 'teldrive*.exe' | Select-Object -First 1
        if ($found) { Move-Item $found.FullName $TeldriveExe }
        else { throw "Could not locate teldrive.exe in the downloaded zip." }
    }
    Write-Host "  [OK] teldrive.exe extracted" -ForegroundColor Green
} else {
    Write-Host "  [skip] teldrive.exe already present" -ForegroundColor DarkGray
}

# --- Step 3: Inject Supabase URL into wizard (in build/, never in repo) ---
$WizardSrc  = Join-Path $InstallerDir 'setup-wizard.ps1'
$Placeholder = "postgresql://postgres:REPLACE_WITH_YOUR_PASSWORD@db.bkcdidfqyaypifwtoyfs.supabase.co:5432/postgres"

$wizardText = Get-Content $WizardSrc -Raw
if ($wizardText -notmatch [regex]::Escape($Placeholder)) {
    throw "Placeholder not found in setup-wizard.ps1. Did you edit it?"
}
$wizardInjected = $wizardText.Replace($Placeholder, $SupabaseUrl)

# --- Step 4: Temporarily swap wizard, compile, restore ---
Write-Host ""
Write-Host "Compiling installer with Inno Setup..." -ForegroundColor Yellow

$IssPath = Join-Path $InstallerDir 'teldrive-setup.iss'
$BackupPath = Join-Path $BuildDir 'setup-wizard.original.ps1'
Copy-Item $WizardSrc $BackupPath -Force

try {
    Set-Content -Path $WizardSrc -Value $wizardInjected -Encoding UTF8 -NoNewline
    & $IsccPath $IssPath
    if ($LASTEXITCODE -ne 0) { throw "Inno Setup compilation failed (exit $LASTEXITCODE)" }
} finally {
    # Always restore the placeholder version
    Move-Item -Force $BackupPath $WizardSrc
}

# --- Done ---
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Build complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
$latest = Get-ChildItem $DistDir -Filter 'TelDriveSetup-*.exe' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latest) {
    Write-Host "  Output: $($latest.FullName)"
    Write-Host "  Size:   $([math]::Round($latest.Length/1MB,1)) MB"
}
Write-Host ""
Write-Host "Send this .exe DIRECTLY to friends (Drive / Telegram / WhatsApp)." -ForegroundColor Cyan
Write-Host "DO NOT commit it to the public repo - it contains your DB password." -ForegroundColor Yellow
Write-Host ""
