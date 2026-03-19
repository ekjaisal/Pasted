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

unit ServiceSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Registry, Forms;

type
  TServiceSettings = class
  public
    class function IsAutoStartEnabled: Boolean;
    class procedure SetAutoStart(Enable: Boolean);
  end;

implementation

const
  REG_RUN_KEY = 'Software\Microsoft\Windows\CurrentVersion\Run';

class function TServiceSettings.IsAutoStartEnabled: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  {$IFDEF WINDOWS}
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(REG_RUN_KEY) then
      Result := Reg.ValueExists(Application.Title);
  finally
    Reg.Free;
  end;
  {$ENDIF}
end;

class procedure TServiceSettings.SetAutoStart(Enable: Boolean);
var
  Reg: TRegistry;
begin
  {$IFDEF WINDOWS}
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(REG_RUN_KEY, True) then
    begin
      if Enable then
        Reg.WriteString(Application.Title, '"' + Application.ExeName + '" -tray')
      else
        Reg.DeleteValue(Application.Title);
    end;
  finally
    Reg.Free;
  end;
  {$ENDIF}
end;

end.