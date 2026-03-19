program Pasted;

{$mode objfpc}{$H+}

uses
  cmem,
  Interfaces, Windows, Messages, SysUtils, Forms, DataShared, AppBase, ServiceHook, AppIdentity,
  DialogAbout, DialogSearchQuick, DialogMove;

{$R *.res}

var
  hMutex: THandle;
  hExisting: HWND;
  i: Integer;
  IsQuitReq: Boolean;
begin
  IsQuitReq := False;
  for i := 1 to ParamCount do
  begin
    if SameText(ParamStr(i), '-quit') then IsQuitReq := True;
  end;

  hMutex := CreateMutex(nil, True, 'Pasted_Unique_Instance_Mutex_9988');

  if (hMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    hExisting := FindWindow(nil, 'Pasted');
    if hExisting <> 0 then
    begin
      if IsQuitReq then
        PostMessage(hExisting, WM_PASTED_QUIT, 0, 0)
      else
      begin
        PostMessage(hExisting, WM_PASTED_RESTORE, 0, 0);
        SetForegroundWindow(hExisting);
      end;
    end;

    if hMutex <> 0 then CloseHandle(hMutex);
    Halt;
  end;

  if IsQuitReq then
  begin
    if hMutex <> 0 then CloseHandle(hMutex);
    Halt;
  end;

  RequireDerivedFormResource := True;
  Application.Scaled := True;

  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}

  Application.Initialize;
  Application.CreateForm(TdmShared, dmShared);

  for i := 1 to ParamCount do
  begin
    if SameText(ParamStr(i), '-tray') then
    begin
      Application.ShowMainForm := False;
      Break;
    end;
  end;

  Application.CreateForm(TfrmAppBase, frmAppBase);
  Application.Run;

  if hMutex <> 0 then CloseHandle(hMutex);
end.