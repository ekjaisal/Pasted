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

unit DialogDefinition;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Clipbrd, LCLType, Menus, AppFont, StaticSQLite, MonoLexID;

type

  { TfrmDialogDefinition }

  TfrmDialogDefinition = class(TForm)
    btnSave, btnCancel: TButton;
    cmbCollection: TComboBox;
    edtName, edtTrigger: TEdit;
    lblName, lblTrigger, lblCollection, lblDefinition: TLabel;
    memDefinition: TMemo;
    mniDialogDefinitionSep3: TMenuItem;
    mniDialogDefinitionReadingOrder: TMenuItem;
    mniDialogDefinitionSelectAll: TMenuItem;
    mniDialogDefinitionSep2: TMenuItem;
    mniDialogDefinitionPaste: TMenuItem;
    mniDialogDefinitionCopy: TMenuItem;
    mniDialogDefinitionCut: TMenuItem;
    pnlAction: TPanel;
    pmnDialogDefinition: TPopupMenu;
    pmnSuppress: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure mniDialogDefinitionCopyClick(Sender: TObject);
    procedure mniDialogDefinitionCutClick(Sender: TObject);
    procedure mniDialogDefinitionPasteClick(Sender: TObject);
    procedure mniDialogDefinitionReadingOrderClick(Sender: TObject);
    procedure mniDialogDefinitionSelectAllClick(Sender: TObject);
    procedure pmnDialogDefinitionPopup(Sender: TObject);
  private
    FDefinitionID: String;
    FDB: TStaticSQLite;
    FResolvedCollID: String;
    procedure LoadCollections(const SelectedID: String);
    function ValidateInput: Boolean;
  public
    class function Execute(ADB: TStaticSQLite; const ATitle: String; const ADefID: String; var AName, ATrigger, ADefText, ACollID: String): Boolean;
  end;

implementation

{$R *.lfm}

procedure TfrmDialogDefinition.FormCreate(Sender: TObject);
begin
  ApplyAppFont(Self);
end;

procedure TfrmDialogDefinition.FormShow(Sender: TObject);
begin
  edtName.SetFocus;
end;

procedure TfrmDialogDefinition.LoadCollections(const SelectedID: String);
var 
  Res: TDBResult; 
  i, Target: Integer;
  ObjStr: PString;
begin
  cmbCollection.Items.Clear; Target := 0;
  if Assigned(FDB) then
  begin
    Res := FDB.Query('SELECT id, name FROM collections ORDER BY name ASC');
    for i := 0 to High(Res) do
    begin
      New(ObjStr);
      ObjStr^ := Res[i][0];
      cmbCollection.Items.AddObject(Res[i][1], TObject(ObjStr));
      if Res[i][0] = SelectedID then Target := i;
    end;
  end;
  if cmbCollection.Items.Count > 0 then cmbCollection.ItemIndex := Target;
end;

function TfrmDialogDefinition.ValidateInput: Boolean;
var Res: TDBResult;
begin
  Result := False;
  edtName.Text := Trim(edtName.Text);
  edtTrigger.Text := Trim(edtTrigger.Text);
  memDefinition.Text := Trim(memDefinition.Text);
  
  if edtName.Text = '' then begin MessageDlg('Validation Error', 'A name is required.', mtWarning, [mbOK], 0); Exit; end;
  if edtTrigger.Text = '' then begin MessageDlg('Validation Error', 'A trigger is required.', mtWarning, [mbOK], 0); Exit; end;
  if Trim(cmbCollection.Text) = '' then begin MessageDlg('Validation Error', 'A collection name is required.', mtWarning, [mbOK], 0); Exit; end;
  if memDefinition.Text = '' then begin MessageDlg('Validation Error', 'Definition text is required.', mtWarning, [mbOK], 0); Exit; end;
  
  if Assigned(FDB) then
  begin
    Res := FDB.Query('SELECT 1 FROM definitions WHERE trigger_word = ' + QuotedStr(edtTrigger.Text) + ' AND id <> ' + QuotedStr(FDefinitionID));
    if Length(Res) > 0 then begin MessageDlg('Validation Error', 'This trigger already exists.', mtWarning, [mbOK], 0); Exit; end;
  end;
  Result := True;
end;

class function TfrmDialogDefinition.Execute(ADB: TStaticSQLite; const ATitle: String; const ADefID: String; var AName, ATrigger, ADefText, ACollID: String): Boolean;
var
  Dlg: TfrmDialogDefinition;
  i: Integer;
begin
  Result := False;
  Dlg := TfrmDialogDefinition.Create(nil);
  try
    Dlg.FDB := ADB;
    Dlg.Caption := ATitle;
    Dlg.FDefinitionID := ADefID;
    Dlg.edtName.Text := AName;
    Dlg.edtTrigger.Text := ATrigger;
    Dlg.memDefinition.Text := ADefText;
    Dlg.LoadCollections(ACollID);

    if Dlg.ShowModal = mrOk then
    begin
      AName := Dlg.edtName.Text;
      ATrigger := Dlg.edtTrigger.Text;
      ADefText := Dlg.memDefinition.Text;
      ACollID := Dlg.FResolvedCollID;
      Result := True;
    end;
  finally
    for i := 0 to Dlg.cmbCollection.Items.Count - 1 do
      Dispose(PString(Dlg.cmbCollection.Items.Objects[i]));
    Dlg.Free;
  end;
end;

procedure TfrmDialogDefinition.btnSaveClick(Sender: TObject);
var
  CollName: String;
  Res: TDBResult;
begin
  if not ValidateInput then Exit;

  CollName := Trim(cmbCollection.Text);
  
  Res := FDB.Query('SELECT id FROM collections WHERE name = ' + QuotedStr(CollName) + ' COLLATE NOCASE');
  
  if Length(Res) > 0 then
  begin
    FResolvedCollID := Res[0][0];
  end
  else
  begin
    FResolvedCollID := NewMonoLexID;
    FDB.Exec('INSERT INTO collections (id, name) VALUES (' + QuotedStr(FResolvedCollID) + ',' + QuotedStr(CollName) + ')');
  end;

  ModalResult := mrOk;
end;

procedure TfrmDialogDefinition.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmDialogDefinition.mniDialogDefinitionCopyClick(Sender: TObject);
begin
  if (pmnDialogDefinition.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogDefinition.PopupComponent).CopyToClipboard;
end;

procedure TfrmDialogDefinition.mniDialogDefinitionCutClick(Sender: TObject);
begin
  if (pmnDialogDefinition.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogDefinition.PopupComponent).CutToClipboard;
end;

procedure TfrmDialogDefinition.mniDialogDefinitionPasteClick(Sender: TObject);
begin
  if (pmnDialogDefinition.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogDefinition.PopupComponent).PasteFromClipboard;
end;

procedure TfrmDialogDefinition.mniDialogDefinitionReadingOrderClick(Sender: TObject);
var
  TargetEdit: TCustomEdit;
begin
  if (pmnDialogDefinition.PopupComponent is TCustomEdit) then
  begin
    TargetEdit := TCustomEdit(pmnDialogDefinition.PopupComponent);
    if TargetEdit.BidiMode = bdRightToLeft then
      TargetEdit.BidiMode := bdLeftToRight
    else
      TargetEdit.BidiMode := bdRightToLeft;
  end;
end;

procedure TfrmDialogDefinition.mniDialogDefinitionSelectAllClick(Sender: TObject);
begin
  if (pmnDialogDefinition.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogDefinition.PopupComponent).SelectAll;
end;

procedure TfrmDialogDefinition.pmnDialogDefinitionPopup(Sender: TObject);
var
  TargetEdit: TCustomEdit;
begin
  if (pmnDialogDefinition.PopupComponent is TCustomEdit) then
  begin
    TargetEdit := TCustomEdit(pmnDialogDefinition.PopupComponent);
    
    mniDialogDefinitionReadingOrder.Visible := (TargetEdit <> edtTrigger);
    mniDialogDefinitionSep3.Visible := (TargetEdit <> edtTrigger);
    
    mniDialogDefinitionReadingOrder.Checked := TargetEdit.BidiMode = bdRightToLeft;
    mniDialogDefinitionSelectAll.Enabled := Length(TargetEdit.Text) > 0;
    mniDialogDefinitionCut.Enabled := TargetEdit.SelLength > 0;
    mniDialogDefinitionCopy.Enabled := TargetEdit.SelLength > 0;
    mniDialogDefinitionPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
  end;
end;

end.