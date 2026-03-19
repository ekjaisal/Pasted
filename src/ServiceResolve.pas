{
 BSD 3-Clause License
 ____________________
 
 Copyright © 2026, Jaisal E. K.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

unit ServiceResolve;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, Generics.Collections, StaticSQLite, ServiceHook
  {$IFDEF WINDOWS}, Windows{$ENDIF};

{$IFDEF WINDOWS}
type
  TClipboardFormatData = record
    Format: UINT;
    Data: THandle;
  end;
{$ENDIF}

type
  TServiceResolve = class;

  TSubstitutionThread = class(TThread)
  private
    FTriggerWord: String;
    FResolver: TServiceResolve;
  protected
    procedure Execute; override;
    procedure TriggerRestore;
  public
    constructor Create(const ATriggerWord: String; AResolver: TServiceResolve);
  end;

  TServiceResolve = class
  private
    FDB: TStaticSQLite;
    FTriggerMap: specialize TDictionary<String, String>;
    FLastTriggeredWord: String;
    FLastTriggeredMonoLexID: String;
    {$IFDEF WINDOWS}
    FClipboardBackup: array of TClipboardFormatData;
    {$ENDIF}

    function ProcessDynamicContent(const InputText: String): String;
    procedure ProcessSubstitutionAsync;
    procedure ProcessResolveRow(const Row: array of String);
  public
    constructor Create(ADB: TStaticSQLite);
    destructor Destroy; override;

    procedure RebuildIndex;
    function OnKeyLogResolve(const CurrentBuffer: String; out MatchedTrigger: String; out MatchedMonoLexID: String): Boolean;
    procedure OnSnippetTriggered(const Keyword, DefinitionID: String);
    procedure RestoreClipboard;
  end;

implementation

{$IFDEF WINDOWS}
const
  INPUT_KEYBOARD = 1;
  KEYEVENTF_KEYUP = $0002;
  VK_V = $56;

type
  PGUIThreadInfo = ^TGUITHREADINFO;
  TGUITHREADINFO = record
    cbSize: DWORD;
    flags: DWORD;
    hwndActive: HWND;
    hwndFocus: HWND;
    hwndCapture: HWND;
    hwndMenuOwner: HWND;
    hwndMoveSize: HWND;
    hwndCaret: HWND;
    rcCaret: TRect;
  end;

  TKeyboardInput = record
    wVk: WORD;
    wScan: WORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;

  TInput = record
    Itype: DWORD;
    ki: TKeyboardInput;
    padding: array[0..7] of Byte;
  end;

function SendInput(cInputs: UINT; pInputs: Pointer; cbSize: Integer): UINT; stdcall; external 'user32.dll';
function GetGUIThreadInfo(idThread: DWORD; pgui: PGUIThreadInfo): BOOL; stdcall; external 'user32.dll';

function CloneClipboardHandle(Format: UINT; Data: THandle): THandle;
var
  DataSize: SIZE_T;
  DataPtr, NewDataPtr: Pointer;
begin
  Result := 0;
  if Data = 0 then Exit;

  if Format = CF_BITMAP then
  begin
    Result := CopyImage(Data, 0, 0, 0, $0004);
  end
  else if Format = CF_ENHMETAFILE then
  begin
    Result := CopyEnhMetaFile(Data, nil);
  end
  else if (Format = CF_PALETTE) or (Format = CF_METAFILEPICT) then
  begin
    Result := 0;
  end
  else
  begin
    DataSize := GlobalSize(Data);
    if DataSize > 0 then
    begin
      Result := GlobalAlloc(GMEM_MOVEABLE, DataSize);
      if Result <> 0 then
      begin
        DataPtr := GlobalLock(Data);
        NewDataPtr := GlobalLock(Result);
        if (DataPtr <> nil) and (NewDataPtr <> nil) then
          Move(DataPtr^, NewDataPtr^, DataSize);
        if DataPtr <> nil then GlobalUnlock(Data);
        if NewDataPtr <> nil then GlobalUnlock(Result);
      end;
    end;
  end;
end;
{$ENDIF}

constructor TSubstitutionThread.Create(const ATriggerWord: String; AResolver: TServiceResolve);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FTriggerWord := ATriggerWord;
  FResolver := AResolver;
end;

procedure TSubstitutionThread.Execute;
{$IFDEF WINDOWS}
var
  i, InputCount, BackspacesNeeded, CurrentIdx: Integer;
  Inputs: array of TInput;
  ReleaseLShift, ReleaseRShift, ReleaseLCtrl, ReleaseRCtrl, ReleaseLAlt, ReleaseRAlt, ReleaseLWin, ReleaseRWin: Boolean;
  CurrentFG: HWND;
  TargetPID, OurPID, TargetThreadID: DWORD;
  WaitTimeout: Integer;
  GUIInfo: TGUITHREADINFO;

  procedure AddKey(VK: WORD; KeyUp: Boolean; Extended: Boolean = False);
  begin
    Inputs[CurrentIdx].Itype := INPUT_KEYBOARD;
    Inputs[CurrentIdx].ki.wVk := VK;
    Inputs[CurrentIdx].ki.wScan := MapVirtualKey(VK, 0);
    Inputs[CurrentIdx].ki.dwFlags := 0;
    if Extended then Inputs[CurrentIdx].ki.dwFlags := Inputs[CurrentIdx].ki.dwFlags or $0001;
    if KeyUp then Inputs[CurrentIdx].ki.dwFlags := Inputs[CurrentIdx].ki.dwFlags or KEYEVENTF_KEYUP;
    Inc(CurrentIdx);
  end;

begin
  OurPID := GetCurrentProcessId();
  WaitTimeout := 0;

  if Length(FTriggerWord) = 0 then
  begin
    repeat
      CurrentFG := GetForegroundWindow();
      if CurrentFG <> 0 then
        TargetThreadID := GetWindowThreadProcessId(CurrentFG, @TargetPID)
      else
      begin
        TargetPID := 0;
        TargetThreadID := 0;
      end;

      if TargetPID = OurPID then
      begin
        Sleep(10);
        Inc(WaitTimeout, 10);
      end;
    until (TargetPID <> OurPID) or (WaitTimeout > 500);

    if (CurrentFG <> 0) and (TargetPID <> OurPID) then
    begin
      WaitTimeout := 0;
      GUIInfo.cbSize := SizeOf(TGUITHREADINFO);
      repeat
        if GetGUIThreadInfo(TargetThreadID, @GUIInfo) and (GUIInfo.hwndFocus <> 0) then Break;
        Sleep(10);
        Inc(WaitTimeout, 10);
      until WaitTimeout > 250;
    end;

    Sleep(50);
  end
  else
  begin
    Sleep(40);
  end;

  Inputs := nil;

  ReleaseLShift := (GetAsyncKeyState(VK_LSHIFT) and $8000) <> 0;
  ReleaseRShift := (GetAsyncKeyState(VK_RSHIFT) and $8000) <> 0;
  ReleaseLCtrl := (GetAsyncKeyState(VK_LCONTROL) and $8000) <> 0;
  ReleaseRCtrl := (GetAsyncKeyState(VK_RCONTROL) and $8000) <> 0;
  ReleaseLAlt := (GetAsyncKeyState(VK_LMENU) and $8000) <> 0;
  ReleaseRAlt := (GetAsyncKeyState(VK_RMENU) and $8000) <> 0;
  ReleaseLWin := (GetAsyncKeyState(VK_LWIN) and $8000) <> 0;
  ReleaseRWin := (GetAsyncKeyState(VK_RWIN) and $8000) <> 0;

  InputCount := 0;
  if ReleaseLShift then Inc(InputCount);
  if ReleaseRShift then Inc(InputCount);
  if ReleaseLCtrl then Inc(InputCount);
  if ReleaseRCtrl then Inc(InputCount);
  if ReleaseLAlt then Inc(InputCount);
  if ReleaseRAlt then Inc(InputCount);
  if ReleaseLWin then Inc(InputCount);
  if ReleaseRWin then Inc(InputCount);

  if InputCount > 0 then
  begin
    SetLength(Inputs, InputCount);
    FillChar(Inputs[0], SizeOf(TInput) * InputCount, 0);
    CurrentIdx := 0;

    if ReleaseLShift then AddKey(VK_LSHIFT, True);
    if ReleaseRShift then AddKey(VK_RSHIFT, True);
    if ReleaseLCtrl then AddKey(VK_LCONTROL, True);
    if ReleaseRCtrl then AddKey(VK_RCONTROL, True, True);
    if ReleaseLAlt then AddKey(VK_LMENU, True);
    if ReleaseRAlt then AddKey(VK_RMENU, True, True);
    if ReleaseLWin then AddKey(VK_LWIN, True, True);
    if ReleaseRWin then AddKey(VK_RWIN, True, True);

    SendInput(InputCount, @Inputs[0], SizeOf(TInput));
    Sleep(20);
  end;

  if Length(FTriggerWord) > 0 then
  begin
    BackspacesNeeded := Length(FTriggerWord) - 1;
    if BackspacesNeeded > 0 then
    begin
      SetLength(Inputs, BackspacesNeeded * 2);
      FillChar(Inputs[0], SizeOf(TInput) * (BackspacesNeeded * 2), 0);
      CurrentIdx := 0;
      for i := 0 to BackspacesNeeded - 1 do
      begin
        AddKey(VK_BACK, False);
        AddKey(VK_BACK, True);
      end;
      SendInput(BackspacesNeeded * 2, @Inputs[0], SizeOf(TInput));
      Sleep(20);
    end;
  end;

  SetLength(Inputs, 4);
  FillChar(Inputs[0], SizeOf(TInput) * 4, 0);
  CurrentIdx := 0;

  AddKey(VK_CONTROL, False);
  AddKey(VK_V, False);
  AddKey(VK_V, True);
  AddKey(VK_CONTROL, True);

  SendInput(4, @Inputs[0], SizeOf(TInput));

  Sleep(300);

  Synchronize(@TriggerRestore);
end;
{$ENDIF}

procedure TSubstitutionThread.TriggerRestore;
begin
  if Assigned(FResolver) then FResolver.RestoreClipboard;
  if Assigned(ServiceHook.GlobalEngine) then ServiceHook.GlobalEngine.Resume;
end;

constructor TServiceResolve.Create(ADB: TStaticSQLite);
begin
  inherited Create;
  FDB := ADB;
  FTriggerMap := specialize TDictionary<String, String>.Create;
  {$IFDEF WINDOWS}
  SetLength(FClipboardBackup, 0);
  {$ENDIF}
end;

destructor TServiceResolve.Destroy;
begin
  FTriggerMap.Free;
  inherited Destroy;
end;

procedure TServiceResolve.RebuildIndex;
var
  Res: TDBResult;
begin
  if not Assigned(FDB) then Exit;

  FTriggerMap.Clear;
  Res := FDB.Query('SELECT COUNT(*) FROM definitions');
  if Length(Res) > 0 then
    FTriggerMap.Capacity := StrToIntDef(Res[0][0], 0);

  FDB.QueryProc('SELECT trigger_word, id FROM definitions', @ProcessResolveRow);
end;

function TServiceResolve.OnKeyLogResolve(const CurrentBuffer: String; out MatchedTrigger: String; out MatchedMonoLexID: String): Boolean;
var
  i: Integer;
  SearchTrigger: String;
begin
  Result := False;
  MatchedTrigger := '';
  MatchedMonoLexID := '';
  for i := 1 to Length(CurrentBuffer) do
  begin
    MatchedTrigger := Copy(CurrentBuffer, i, Length(CurrentBuffer) - i + 1);
    SearchTrigger := LowerCase(MatchedTrigger);
    if FTriggerMap.TryGetValue(SearchTrigger, MatchedMonoLexID) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TServiceResolve.ProcessResolveRow(const Row: array of String);
begin
  if Length(Row) = 0 then;
  FTriggerMap.AddOrSetValue(LowerCase(Row[0]), Row[1]);
end;

function TServiceResolve.ProcessDynamicContent(const InputText: String): String;
var
  CurrentPos, PStart, PEnd: Integer;
  Tag, Replacement: String;
  IsHandled: Boolean;
begin
  Result := InputText;
  CurrentPos := 1;

  repeat
    PStart := PosEx('${', Result, CurrentPos);
    if PStart = 0 then Break;

    if (PStart > 1) and (Result[PStart - 1] = '\') then
    begin
      Delete(Result, PStart - 1, 1);
      CurrentPos := PStart + 1;
      Continue;
    end;

    PEnd := PosEx('}', Result, PStart);
    if PEnd = 0 then
    begin
      CurrentPos := PStart + 1;
      Continue;
    end;

    Tag := Copy(Result, PStart + 2, PEnd - (PStart + 2));
    Replacement := '';
    IsHandled := False;

    try
      Replacement := FormatDateTime(Tag, Now);
      IsHandled := True;
    except
      IsHandled := False;
    end;

    if IsHandled then
    begin
      Delete(Result, PStart, (PEnd - PStart) + 1);
      Insert(Replacement, Result, PStart);
      CurrentPos := PStart + Length(Replacement);
    end
    else
    begin
      CurrentPos := PEnd + 1;
    end;
  until False;
end;

procedure TServiceResolve.OnSnippetTriggered(const Keyword, DefinitionID: String);
begin
  FLastTriggeredWord := Keyword;
  FLastTriggeredMonoLexID := DefinitionID;
  TThread.Queue(nil, @ProcessSubstitutionAsync);
end;

procedure TServiceResolve.ProcessSubstitutionAsync;
var
  Res: TDBResult;
  DefinitionText: String;
  {$IFDEF WINDOWS}
  Format, FmtExclude, FmtHistory, FmtIgnore: UINT;
  Data, NewData, HText, HEx1, HEx2, HEx3: THandle;
  DataPtr: Pointer;
  PDW: PDWORD;
  WStr: UnicodeString;
  Retries: Integer;
  Success: Boolean;
  {$ENDIF}
begin
  if not Assigned(FDB) then Exit;

  Res := FDB.Query('SELECT definition_text FROM definitions WHERE id = ' + QuotedStr(FLastTriggeredMonoLexID));
  if Length(Res) = 0 then Exit;

  DefinitionText := ProcessDynamicContent(Res[0][0]);

  {$IFDEF WINDOWS}
  SetLength(FClipboardBackup, 0);
  Retries := 0;
  Success := False;

  while (Retries < 25) and not Success do
  begin
    if OpenClipboard(0) then
    begin
      try
        Format := EnumClipboardFormats(0);
        while Format <> 0 do
        begin
          Data := GetClipboardData(Format);
          if Data <> 0 then
          begin
            NewData := CloneClipboardHandle(Format, Data);
            if NewData <> 0 then
            begin
              SetLength(FClipboardBackup, Length(FClipboardBackup) + 1);
              FClipboardBackup[High(FClipboardBackup)].Format := Format;
              FClipboardBackup[High(FClipboardBackup)].Data := NewData;
            end;
          end;
          Format := EnumClipboardFormats(Format);
        end;
        Success := True;
      finally
        CloseClipboard;
      end;
    end
    else
    begin
      Sleep(10);
      Inc(Retries);
    end;
  end;

  WStr := UnicodeString(DefinitionText);
  HText := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, (Length(WStr) + 1) * SizeOf(WideChar));
  if HText <> 0 then
  begin
    DataPtr := GlobalLock(HText);
    if DataPtr <> nil then
    begin
      Move(PWideChar(WStr)^, DataPtr^, Length(WStr) * SizeOf(WideChar));
      GlobalUnlock(HText);
    end;
  end;

  FmtExclude := RegisterClipboardFormat('ExcludeClipboardContentFromMonitorUI');
  FmtHistory := RegisterClipboardFormat('CanIncludeInClipboardHistory');
  FmtIgnore := RegisterClipboardFormat('Clipboard Viewer Ignore');

  HEx1 := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, SizeOf(DWORD));
  if HEx1 <> 0 then
  begin
    PDW := GlobalLock(HEx1);
    if PDW <> nil then
    begin
      PDW^ := 0;
      GlobalUnlock(HEx1);
    end;
  end;

  HEx2 := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, SizeOf(DWORD));
  if HEx2 <> 0 then
  begin
    PDW := GlobalLock(HEx2);
    if PDW <> nil then
    begin
      PDW^ := 0;
      GlobalUnlock(HEx2);
    end;
  end;

  HEx3 := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, 1);

  Retries := 0;
  Success := False;
  while (Retries < 25) and not Success do
  begin
    if OpenClipboard(0) then
    begin
      EmptyClipboard;
      if HText <> 0 then if SetClipboardData(CF_UNICODETEXT, HText) <> 0 then HText := 0;
      if (FmtExclude <> 0) and (HEx1 <> 0) then if SetClipboardData(FmtExclude, HEx1) <> 0 then HEx1 := 0;
      if (FmtHistory <> 0) and (HEx2 <> 0) then if SetClipboardData(FmtHistory, HEx2) <> 0 then HEx2 := 0;
      if (FmtIgnore <> 0) and (HEx3 <> 0) then if SetClipboardData(FmtIgnore, HEx3) <> 0 then HEx3 := 0;
      CloseClipboard;
      Success := True;
    end
    else
    begin
      Sleep(10);
      Inc(Retries);
    end;
  end;

  if HText <> 0 then GlobalFree(HText);
  if HEx1 <> 0 then GlobalFree(HEx1);
  if HEx2 <> 0 then GlobalFree(HEx2);
  if HEx3 <> 0 then GlobalFree(HEx3);
  {$ENDIF}

  if Success then
  begin
    if Assigned(ServiceHook.GlobalEngine) then ServiceHook.GlobalEngine.Suspend;
    TSubstitutionThread.Create(FLastTriggeredWord, Self);
    FDB.Exec('UPDATE definitions SET trigger_count = trigger_count + 1, last_triggered = CURRENT_TIMESTAMP WHERE id = ' + QuotedStr(FLastTriggeredMonoLexID));
  end;
end;

procedure TServiceResolve.RestoreClipboard;
{$IFDEF WINDOWS}
var
  i, Retries: Integer;
  Success: Boolean;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  if Length(FClipboardBackup) = 0 then Exit;

  Success := False;
  Retries := 0;

  while (Retries < 30) and not Success do
  begin
    if OpenClipboard(0) then
    begin
      try
        EmptyClipboard;
        for i := Low(FClipboardBackup) to High(FClipboardBackup) do
        begin
          if FClipboardBackup[i].Data <> 0 then
          begin
            if SetClipboardData(FClipboardBackup[i].Format, FClipboardBackup[i].Data) = 0 then
            begin
              if FClipboardBackup[i].Format = CF_BITMAP then
                DeleteObject(FClipboardBackup[i].Data)
              else if FClipboardBackup[i].Format = CF_ENHMETAFILE then
                DeleteEnhMetaFile(FClipboardBackup[i].Data)
              else
                GlobalFree(FClipboardBackup[i].Data);
            end;
          end;
        end;
        Success := True;
      finally
        CloseClipboard;
      end;
    end
    else
    begin
      Sleep(20);
      Inc(Retries);
    end;
  end;

  if not Success then
  begin
    for i := Low(FClipboardBackup) to High(FClipboardBackup) do
    begin
      if FClipboardBackup[i].Data <> 0 then
      begin
        if FClipboardBackup[i].Format = CF_BITMAP then
          DeleteObject(FClipboardBackup[i].Data)
        else if FClipboardBackup[i].Format = CF_ENHMETAFILE then
          DeleteEnhMetaFile(FClipboardBackup[i].Data)
        else
          GlobalFree(FClipboardBackup[i].Data);
      end;
    end;
  end;

  SetLength(FClipboardBackup, 0);
  {$ENDIF}
end;

end.