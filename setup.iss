[Setup]
AppId={{5D0E39F2-B09A-460B-8A8E-F43171B81640}}
AppName=Medical Clinic App
AppVersion=1.1
AppPublisher=Private Clinic Installer
DefaultDirName={autopf}\Medical Clinic App
DisableProgramGroupPage=yes
OutputDir=.\installers
OutputBaseFilename=MedicalClinicSetup
SetupIconFile=.\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: ".\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Note: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Medical Clinic App"; Filename: "{app}\medical_clinic.exe"
Name: "{autodesktop}\Medical Clinic App"; Filename: "{app}\medical_clinic.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\medical_clinic.exe"; Description: "{cm:LaunchProgram,Medical Clinic App}"; Flags: nowait postinstall skipifsilent
