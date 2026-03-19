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

unit DialogMove;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, AppFont, StaticSQLite;

type

  { TfrmDialogMove }

  TfrmDialogMove = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    cmbCollection: TComboBox;
    lblCollection: TLabel;
    pnlAction: TPanel;
    pmnSuppress: TPopupMenu;

    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FDB: TStaticSQLite;
    FResolvedCollID: String;
    procedure LoadCollections;
  public
    class function Execute(ADB: TStaticSQLite; out ACollID: String): Boolean;
  end;

implementation

{$R *.lfm}

procedure TfrmDialogMove.FormCreate(Sender: TObject);
begin
  ApplyAppFont(Self);
end;

procedure TfrmDialogMove.LoadCollections;
var
  Res: TDBResult;
  i: Integer;
  ObjStr: PString;
begin
  cmbCollection.Items.Clear;
  if Assigned(FDB) then
  begin
    Res := FDB.Query('SELECT id, name FROM collections ORDER BY name ASC');
    for i := 0 to High(Res) do
    begin
      New(ObjStr);
      ObjStr^ := Res[i][0];
      cmbCollection.Items.AddObject(Res[i][1], TObject(ObjStr));
    end;
  end;
  if cmbCollection.Items.Count > 0 then cmbCollection.ItemIndex := 0;
end;

class function TfrmDialogMove.Execute(ADB: TStaticSQLite; out ACollID: String): Boolean;
var
  Dlg: TfrmDialogMove;
  i: Integer;
begin
  Result := False;
  Dlg := TfrmDialogMove.Create(nil);
  try
    Dlg.FDB := ADB;
    Dlg.LoadCollections;

    if Dlg.ShowModal = mrOk then
    begin
      ACollID := Dlg.FResolvedCollID;
      Result := True;
    end;
  finally
    for i := 0 to Dlg.cmbCollection.Items.Count - 1 do
      Dispose(PString(Dlg.cmbCollection.Items.Objects[i]));
    Dlg.Free;
  end;
end;

procedure TfrmDialogMove.btnSaveClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := cmbCollection.ItemIndex;
  if Idx < 0 then
  begin
    MessageDlg('Validation Error', 'Please select a valid collection.', mtWarning, [mbOK], 0);
    Exit;
  end;

  FResolvedCollID := PString(cmbCollection.Items.Objects[Idx])^;
  ModalResult := mrOk;
end;

procedure TfrmDialogMove.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.