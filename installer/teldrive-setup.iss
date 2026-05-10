; TelDrive Easy - Windows Installer
; Compile with Inno Setup: ISCC.exe teldrive-setup.iss
; Produces: dist/TelDriveSetup-{version}.exe

#define MyAppName "TelDrive Easy"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Kaarthik Dass Arora"
#define MyAppURL "https://github.com/kaarthikdassarorasahabji-png/teldrive-easy"
#define MyAppExeName "teldrive.exe"

[Setup]
AppId={{8F2C4D7E-9B3A-4F5E-A1D2-7C6E8F9A0B1C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
DefaultDirName={autopf}\TelDrive
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
OutputDir=..\dist
OutputBaseFilename=TelDriveSetup-{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Bundled teldrive binary (downloaded at build time by build-installer.ps1)
Source: "build\teldrive.exe"; DestDir: "{app}"; Flags: ignoreversion
; Setup wizard (PowerShell)
Source: "setup-wizard.ps1";   DestDir: "{app}"; Flags: ignoreversion
; Friendly batch wrappers
Source: "Open-TelDrive.bat";  DestDir: "{app}"; Flags: ignoreversion
Source: "Stop-TelDrive.bat";  DestDir: "{app}"; Flags: ignoreversion
Source: "Uninstall-Service.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{commondesktop}\Open TelDrive";       Filename: "{app}\Open-TelDrive.bat";  IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\Open TelDrive";               Filename: "{app}\Open-TelDrive.bat";  IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\Stop TelDrive";               Filename: "{app}\Stop-TelDrive.bat"
Name: "{group}\Uninstall TelDrive Service";  Filename: "{app}\Uninstall-Service.bat"

[Run]
; Run the setup wizard on first install (PowerShell, visible window)
Filename: "powershell.exe"; \
    Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\setup-wizard.ps1"""; \
    Flags: postinstall waituntilterminated; \
    Description: "Set up TelDrive (recommended)"

[UninstallRun]
; Stop and remove the scheduled task on uninstall
Filename: "schtasks.exe"; Parameters: "/End /TN TelDrive";       Flags: runhidden; RunOnceId: "stoptask"
Filename: "schtasks.exe"; Parameters: "/Delete /TN TelDrive /F"; Flags: runhidden; RunOnceId: "deltask"
Filename: "taskkill.exe"; Parameters: "/F /IM teldrive.exe";     Flags: runhidden; RunOnceId: "killproc"

[UninstallDelete]
Type: filesandordirs; Name: "{commonappdata}\TelDrive"
