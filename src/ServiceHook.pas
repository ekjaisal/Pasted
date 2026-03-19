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

unit ServiceHook;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, LCLIntf, LCLType, Clipbrd
  {$IFDEF WINDOWS}, Windows{$ENDIF};

type
  TOnSnippetTrigger = procedure(const Keyword, DefinitionID: String) of object;
  TOnKeyLog = function(const CurrentBuffer: String; out MatchedTrigger: String; out MatchedMonoLexID: String): Boolean of object;

  TServiceHook = class
  private
    FActive: Boolean;
    FSuspended: Boolean;
    FKeyBuffer: String;
    FOnKeyLog: TOnKeyLog;
    FOnTrigger: TOnSnippetTrigger;
    {$IFDEF WINDOWS}
    FHookHandle: HHOOK;
    {$ENDIF}
    procedure ClearBuffer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure Suspend;
    procedure Resume;
    procedure BufferReset;
    procedure ExecuteSubstitution(const Keyword, DefinitionID: String);

    property Active: Boolean read FActive;
    property Suspended: Boolean read FSuspended;
    property OnKeyLog: TOnKeyLog read FOnKeyLog write FOnKeyLog;
    property OnTrigger: TOnSnippetTrigger read FOnTrigger write FOnTrigger;
  end;

var
  GlobalEngine: TServiceHook;

implementation

{$IFDEF WINDOWS}
const
  WH_KEYBOARD_LL = 13;
  LLKHF_INJECTED = $00000010;

type
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;
  TKBDLLHOOKSTRUCT = record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;

function LowLevelKeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
type
  TBufferW = array[0..4] of WideChar;
var
  KeyHookStruct: PKBDLLHOOKSTRUCT absolute lParam;
  KeyState: TKeyboardState;
  BufferW: TBufferW;
  IsDown, CtrlDown, AltDown: Boolean;
  MatchedMonoLexID: String;
  TriggerWord: String;
  CharCount, i: Integer;
  UChar: Word;
begin
  BufferW := Default(TBufferW);

  if (nCode = HC_ACTION) and Assigned(GlobalEngine) and GlobalEngine.Active and not GlobalEngine.Suspended then
  begin
    if (KeyHookStruct^.flags and LLKHF_INJECTED) <> 0 then
    begin
      Result := CallNextHookEx(0, nCode, wParam, lParam);
      Exit;
    end;

    IsDown := (wParam = WM_KEYDOWN) or (wParam = WM_SYSKEYDOWN);

    if IsDown then
    begin
      CtrlDown := (GetAsyncKeyState(VK_CONTROL) and $8000) <> 0;
      AltDown := (GetAsyncKeyState(VK_MENU) and $8000) <> 0;

      if KeyHookStruct^.vkCode = VK_BACK then
      begin
        if Length(GlobalEngine.FKeyBuffer) > 0 then
          SetLength(GlobalEngine.FKeyBuffer, Length(GlobalEngine.FKeyBuffer) - 1);
      end
      else if KeyHookStruct^.vkCode in [VK_SPACE, VK_RETURN, VK_TAB, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_ESCAPE, VK_HOME, VK_END, VK_PRIOR, VK_NEXT] then
      begin
        GlobalEngine.ClearBuffer;
      end
      else if (KeyHookStruct^.vkCode = VK_SHIFT) or (KeyHookStruct^.vkCode = VK_LSHIFT) or (KeyHookStruct^.vkCode = VK_RSHIFT) or
              (KeyHookStruct^.vkCode = VK_CONTROL) or (KeyHookStruct^.vkCode = VK_LCONTROL) or (KeyHookStruct^.vkCode = VK_RCONTROL) or
              (KeyHookStruct^.vkCode = VK_MENU) or (KeyHookStruct^.vkCode = VK_LMENU) or (KeyHookStruct^.vkCode = VK_RMENU) or
              (KeyHookStruct^.vkCode = VK_CAPITAL) then
      begin
      end
      else if CtrlDown or AltDown then
      begin
        GlobalEngine.ClearBuffer;
      end
      else
      begin
        KeyState := Default(TKeyboardState);
        FillChar(KeyState, SizeOf(KeyState), 0);
        GetKeyboardState(KeyState);

        if (GetAsyncKeyState(VK_SHIFT) and $8000) <> 0 then KeyState[VK_SHIFT] := $80;
        if (GetAsyncKeyState(VK_CAPITAL) and $0001) <> 0 then KeyState[VK_CAPITAL] := $01;

        CharCount := ToUnicode(KeyHookStruct^.vkCode, KeyHookStruct^.scanCode, KeyState, @BufferW[0], Length(BufferW), 0);

        if CharCount > 0 then
        begin
          for i := 0 to CharCount - 1 do
          begin
            UChar := Word(BufferW[i]);
            if UChar >= 32 then
            begin
              GlobalEngine.FKeyBuffer := GlobalEngine.FKeyBuffer + UTF8Encode(UnicodeString(BufferW[i]));
              while Length(GlobalEngine.FKeyBuffer) > 150 do
                Delete(GlobalEngine.FKeyBuffer, 1, 1);
            end;
          end;

          if Assigned(GlobalEngine.FOnKeyLog) then
          begin
            MatchedMonoLexID := '';
            TriggerWord := '';
            if GlobalEngine.FOnKeyLog(GlobalEngine.FKeyBuffer, TriggerWord, MatchedMonoLexID) then
            begin
              GlobalEngine.ClearBuffer;
              GlobalEngine.ExecuteSubstitution(TriggerWord, MatchedMonoLexID);
              Result := 1;
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;
  Result := CallNextHookEx(0, nCode, wParam, lParam);
end;
{$ENDIF}

constructor TServiceHook.Create;
begin
  inherited Create;
  FActive := False;
  FSuspended := False;
  FKeyBuffer := '';
end;

destructor TServiceHook.Destroy;
begin
  Stop;
  inherited Destroy;
end;

procedure TServiceHook.Start;
begin
  if FActive then Exit;
  {$IFDEF WINDOWS}
  FHookHandle := SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc, HInstance, 0);
  FActive := (FHookHandle <> 0);
  {$ENDIF}
end;

procedure TServiceHook.Stop;
begin
  if not FActive then Exit;
  {$IFDEF WINDOWS}
  UnhookWindowsHookEx(FHookHandle);
  FHookHandle := 0;
  {$ENDIF}
  FActive := False;
end;

procedure TServiceHook.Suspend;
begin
  FSuspended := True;
end;

procedure TServiceHook.Resume;
begin
  FSuspended := False;
  ClearBuffer;
end;

procedure TServiceHook.ClearBuffer;
begin
  FKeyBuffer := '';
end;

procedure TServiceHook.BufferReset;
begin
  ClearBuffer;
end;

procedure TServiceHook.ExecuteSubstitution(const Keyword, DefinitionID: String);
begin
  if Assigned(FOnTrigger) then
    FOnTrigger(Keyword, DefinitionID);
end;

end.