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

unit DialogSearchQuick;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LCLType, Menus, VirtualTrees, AppFont, StaticSQLite
  {$IFDEF WINDOWS}, Windows{$ENDIF};

type
  PDialogSearchQuickData = ^TDialogSearchQuickData;
  TDialogSearchQuickData = record
    ID: String;
    Name: String;
    Trigger: String;
  end;

  TfrmDialogSearchQuick = class(TForm)
    edtSearch: TEdit;
    pnlSearch: TPanel;
    pnlSeparator: TPanel;
    pmnSuppress: TPopupMenu;
    vstResults: TVirtualStringTree;
    procedure edtSearchChange(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vstResultsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstResultsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure vstResultsClick(Sender: TObject);
    procedure vstResultsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FDB: TStaticSQLite;
    FSelectedID: String;
    procedure PerformSearch;
    procedure ExecuteSelected;
    procedure ProcessSearchRow(const Row: array of String);
    procedure UpdateInterfaceState;
  public
    class function Execute(ADB: TStaticSQLite): String;
  end;

var
  frmDialogSearchQuick: TfrmDialogSearchQuick;

implementation

uses
  ServiceHook;

{$R *.lfm}

class function TfrmDialogSearchQuick.Execute(ADB: TStaticSQLite): String;
var
  Dlg: TfrmDialogSearchQuick;
  StillActive: Boolean;
begin
  Result := '';
  Dlg := TfrmDialogSearchQuick.Create(nil);
  try
    Dlg.FDB := ADB;
    Dlg.FormStyle := fsStayOnTop;
    Dlg.FSelectedID := '';
    Dlg.Show;

    {$IFDEF WINDOWS}
    SetForegroundWindow(Dlg.Handle);
    {$ENDIF}

    while Dlg.Visible and not Application.Terminated do
    begin
      Application.ProcessMessages;

      {$IFDEF WINDOWS}
      StillActive := (GetForegroundWindow = Dlg.Handle);
      if not StillActive and (Dlg.FSelectedID = '') then
      begin
        Sleep(50);
        if GetForegroundWindow <> Dlg.Handle then Dlg.Close;
      end;
      {$ENDIF}

      Sleep(10);
    end;

    Result := Dlg.FSelectedID;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmDialogSearchQuick.FormCreate(Sender: TObject);
begin
  ApplyAppFont(Self);
  vstResults.NodeDataSize := SizeOf(TDialogSearchQuickData);
  UpdateInterfaceState;
end;

procedure TfrmDialogSearchQuick.FormShow(Sender: TObject);
begin
  if Assigned(GlobalEngine) then GlobalEngine.Stop;
  edtSearch.Clear;
  UpdateInterfaceState;
  edtSearch.SetFocus;
end;

procedure TfrmDialogSearchQuick.FormDeactivate(Sender: TObject);
begin
  if Visible and (FSelectedID = '') then
  begin
    Close;
  end;
end;

procedure TfrmDialogSearchQuick.FormDestroy(Sender: TObject);
begin
  if Assigned(GlobalEngine) then GlobalEngine.Start;
  vstResults.Clear;
end;

procedure TfrmDialogSearchQuick.UpdateInterfaceState;
begin
  if Trim(edtSearch.Text) = '' then
  begin
    pnlSeparator.Visible := False;
    vstResults.Visible := False;
    ClientHeight := pnlSearch.Height;
  end
  else
  begin
    pnlSeparator.Visible := True;
    vstResults.Visible := True;
    ClientHeight := 430;
  end;
end;

procedure TfrmDialogSearchQuick.PerformSearch;
var
  SVal, SQL: String;
begin
  if not Assigned(FDB) then Exit;
  if Trim(edtSearch.Text) = '' then
  begin
    vstResults.Clear;
    Exit;
  end;

  SVal := QuotedStr('%' + Trim(edtSearch.Text) + '%');
  SQL := 'SELECT id, name, trigger_word FROM definitions WHERE (name LIKE ' + SVal + ' OR trigger_word LIKE ' + SVal + ' OR definition_text LIKE ' + SVal + ') ORDER BY last_triggered DESC LIMIT 15';

  vstResults.BeginUpdate;
  try
    vstResults.Clear;
    FDB.QueryProc(SQL, @ProcessSearchRow);
  finally
    vstResults.EndUpdate;
  end;

  if vstResults.TotalCount > 0 then
  begin
    vstResults.FocusedNode := vstResults.GetFirst;
    vstResults.Selected[vstResults.FocusedNode] := True;
  end;
end;

procedure TfrmDialogSearchQuick.ProcessSearchRow(const Row: array of String);
var
  Node: PVirtualNode;
  Data: PDialogSearchQuickData;
begin
  if Length(Row) = 0 then;
  Node := vstResults.AddChild(nil);
  Data := vstResults.GetNodeData(Node);
  Data^.ID := Row[0];
  Data^.Name := Row[1];
  Data^.Trigger := Row[2];
end;

procedure TfrmDialogSearchQuick.ExecuteSelected;
var
  Data: PDialogSearchQuickData;
begin
  if vstResults.GetFirstSelected <> nil then
  begin
    Data := vstResults.GetNodeData(vstResults.GetFirstSelected);
    FSelectedID := Data^.ID;
    Close;
  end;
end;

procedure TfrmDialogSearchQuick.edtSearchChange(Sender: TObject);
begin
  UpdateInterfaceState;
  PerformSearch;
end;

procedure TfrmDialogSearchQuick.edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [] then;
  if Key = VK_DOWN then
  begin
    vstResults.SetFocus;
    if vstResults.GetFirstSelected = nil then
    begin
      vstResults.FocusedNode := vstResults.GetFirst;
      vstResults.Selected[vstResults.FocusedNode] := True;
    end;
    Key := 0;
  end
  else if Key = VK_RETURN then
  begin
    ExecuteSelected;
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    FSelectedID := '';
    Close;
    Key := 0;
  end;
end;

procedure TfrmDialogSearchQuick.vstResultsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [] then;
  if Key = VK_RETURN then
  begin
    ExecuteSelected;
    Key := 0;
  end
  else if Key = VK_UP then
  begin
    if vstResults.GetFirstSelected = vstResults.GetFirst then
    begin
      edtSearch.SetFocus;
      Key := 0;
    end;
  end
  else if Key = VK_ESCAPE then
  begin
    FSelectedID := '';
    Close;
    Key := 0;
  end;
end;

procedure TfrmDialogSearchQuick.vstResultsClick(Sender: TObject);
begin
  ExecuteSelected;
end;

procedure TfrmDialogSearchQuick.vstResultsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var
  Data: PDialogSearchQuickData;
begin
  if TextType = ttNormal then;
  Data := Sender.GetNodeData(Node);
  case Column of
    0: CellText := Data^.Name;
    1: CellText := Data^.Trigger;
  end;
end;

procedure TfrmDialogSearchQuick.vstResultsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PDialogSearchQuickData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

end.