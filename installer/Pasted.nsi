!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "WordFunc.nsh"

Unicode true
ManifestDPIAware true
ManifestSupportedOS Win10

!define APP_NAME "Pasted"
!define APP_VERSION "1.0.0"
!define APP_BUILD "204"
!define APP_PUBLISHER "Jaisal E. K."
!define APP_WEBSITE "https://pasted.jaisal.in"
!define APP_COPYRIGHT_YEAR "2026"
!define APP_COMMENT "Pass Trigger; Emit Definition"
!define APP_EXE "Pasted.exe"
!define APP_GUID "{A1F35CDC-6DDF-42A7-9C9C-064D794C3E52}"

Name "${APP_NAME}"
!system 'cmd.exe /c if not exist "..\releases" mkdir "..\releases"'
OutFile "..\releases\${APP_NAME}-v${APP_VERSION}-x64-Setup.exe"
InstallDir "$LOCALAPPDATA\Programs\${APP_NAME}"
RequestExecutionLevel user
SetCompressor lzma

SetFont "Arial" 9

VIProductVersion "${APP_VERSION}.${APP_BUILD}"
VIAddVersionKey /LANG=2057 "ProductName" "${APP_NAME}"
VIAddVersionKey /LANG=2057 "Comments" "${APP_COMMENT}"
VIAddVersionKey /LANG=2057 "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey /LANG=2057 "LegalCopyright" "© ${APP_COPYRIGHT_YEAR} ${APP_PUBLISHER}"
VIAddVersionKey /LANG=2057 "FileDescription" "${APP_NAME} Setup"
VIAddVersionKey /LANG=2057 "FileVersion" "${APP_VERSION}.${APP_BUILD}"
VIAddVersionKey /LANG=2057 "ProductVersion" "${APP_VERSION}"

BrandingText "${APP_PUBLISHER}"

!define MUI_ICON "..\Pasted.ico"
!define MUI_UNICON "..\Pasted.ico"
!define MUI_ABORTWARNING

!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange-uninstall.bmp"

!define MUI_WELCOMEPAGE_TEXT "Setup will guide you through the installation of ${APP_NAME}.$\r$\n$\r$\nClick Next to continue."

!define MUI_FONT_NAME "Arial"
!define MUI_FONT_SIZE "9"

!insertmacro MUI_PAGE_WELCOME

!define MUI_PAGE_CUSTOMFUNCTION_SHOW LicenseShow
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApplication
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

LangString ^BackBtn ${LANG_ENGLISH} "&Back"
LangString ^NextBtn ${LANG_ENGLISH} "&Next"

Function .onInit
  SetRegView 64
  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "DisplayVersion"
  ${If} $0 != ""
    ${VersionCompare} $0 "${APP_VERSION}" $1
    ${If} $1 == 1
      MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 "A newer version of ${APP_NAME} ($0) is already installed on this system.$\n$\nAre you sure you wish to downgrade to version ${APP_VERSION}?" IDYES +2
      Abort
    ${ElseIf} $1 == 0
      MessageBox MB_YESNO|MB_ICONQUESTION "Version ${APP_VERSION} of ${APP_NAME} is already installed.$\n$\nWould you like to reinstall it?" IDYES +2
      Abort
    ${EndIf}
  ${EndIf}
FunctionEnd

Function LicenseShow
  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1000
  CreateFont $1 "Consolas" 8 700
  SendMessage $0 0x0030 $1 1
FunctionEnd

Function CloseRunningInstance
  IfFileExists "$INSTDIR\${APP_EXE}" 0 Done
  Exec '"$INSTDIR\${APP_EXE}" -quit'
  StrCpy $0 0
  Loop:
    Sleep 500
    ClearErrors
    FileOpen $1 "$INSTDIR\${APP_EXE}" a
    IfErrors ContinueLoop
    FileClose $1
    Goto Done
  ContinueLoop:
    IntOp $0 $0 + 1
    IntCmp $0 10 Done Loop Done
  Done:
FunctionEnd

Section "Install"
  SetRegView 64

  Call CloseRunningInstance

  SetOutPath "$INSTDIR"
  File "..\bin\${APP_EXE}"
  File "..\LICENSE"
  File "..\NOTICE"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  SetShellVarContext current
  CreateShortcut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "DisplayIcon" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "URLInfoAbout" "${APP_WEBSITE}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "URLUpdateInfo" "${APP_WEBSITE}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "HelpLink" "${APP_WEBSITE}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "Comments" "${APP_COMMENT}"

  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "EstimatedSize" "$0"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetRegView 64

  Call un.CloseRunningInstance

  Delete "$INSTDIR\${APP_EXE}"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\NOTICE"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"

  SetShellVarContext current
  Delete "$SMPROGRAMS\${APP_NAME}.lnk"
  Delete "$DESKTOP\${APP_NAME}.lnk"

  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_GUID}"
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"
SectionEnd

Function un.CloseRunningInstance
  IfFileExists "$INSTDIR\${APP_EXE}" 0 Done
  Exec '"$INSTDIR\${APP_EXE}" -quit'
  StrCpy $0 0
  Loop:
    Sleep 500
    ClearErrors
    FileOpen $1 "$INSTDIR\${APP_EXE}" a
    IfErrors ContinueLoop
    FileClose $1
    Goto Done
  ContinueLoop:
    IntOp $0 $0 + 1
    IntCmp $0 10 Done Loop Done
  Done:
FunctionEnd

Function LaunchApplication
  System::Call 'user32::AllowSetForegroundWindow(i -1)'
  Exec '"$INSTDIR\${APP_EXE}"'
FunctionEnd