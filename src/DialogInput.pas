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

unit DialogInput;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Clipbrd, LCLType, Menus, AppFont;

type

  { TfrmDialogInput }

  TfrmDialogInput = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    edtInput: TEdit;
    lblPrompt: TLabel;
    mniDialogInputReadingOrder: TMenuItem;
    mniDialogInputSelectAll: TMenuItem;
    mniDialogInputSep1: TMenuItem;
    mniDialogInputCut: TMenuItem;
    mniDialogInputPaste: TMenuItem;
    mniDialogInputCopy: TMenuItem;
    pnlAction: TPanel;
    pmnDialogInput: TPopupMenu;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure mniDialogInputCopyClick(Sender: TObject);
    procedure mniDialogInputCutClick(Sender: TObject);
    procedure mniDialogInputPasteClick(Sender: TObject);
    procedure mniDialogInputReadingOrderClick(Sender: TObject);
    procedure mniDialogInputSelectAllClick(Sender: TObject);
    procedure pmnDialogInputPopup(Sender: TObject);
  public
    class function Execute(const ATitle, APrompt, ADefault: String; out AResult: String): Boolean;
  end;

implementation

{$R *.lfm}

procedure TfrmDialogInput.FormCreate(Sender: TObject);
begin
  ApplyAppFont(Self);
end;

procedure TfrmDialogInput.FormShow(Sender: TObject);
begin
  edtInput.SetFocus;
end;

class function TfrmDialogInput.Execute(const ATitle, APrompt, ADefault: String; out AResult: String): Boolean;
var
  Dlg: TfrmDialogInput;
begin
  Result := False;
  Dlg := TfrmDialogInput.Create(nil);
  try
    Dlg.Caption := ATitle;
    Dlg.lblPrompt.Caption := APrompt;
    Dlg.edtInput.Text := ADefault;
    Dlg.edtInput.SelectAll;

    if Dlg.ShowModal = mrOk then
    begin
      AResult := Trim(Dlg.edtInput.Text);
      Result := True;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmDialogInput.btnSaveClick(Sender: TObject);
begin
  if Trim(edtInput.Text) = '' then
  begin
    MessageDlg('Validation Error', 'The collection name cannot be empty.', mtWarning, [mbOK], 0);
    edtInput.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TfrmDialogInput.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmDialogInput.mniDialogInputCopyClick(Sender: TObject);
begin
  if (pmnDialogInput.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogInput.PopupComponent).CopyToClipboard;
end;

procedure TfrmDialogInput.mniDialogInputCutClick(Sender: TObject);
begin
  if (pmnDialogInput.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogInput.PopupComponent).CutToClipboard;
end;

procedure TfrmDialogInput.mniDialogInputPasteClick(Sender: TObject);
begin
  if (pmnDialogInput.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogInput.PopupComponent).PasteFromClipboard;
end;

procedure TfrmDialogInput.mniDialogInputReadingOrderClick(Sender: TObject);
var
  TargetEdit: TCustomEdit;
begin
  if (pmnDialogInput.PopupComponent is TCustomEdit) then
  begin
    TargetEdit := TCustomEdit(pmnDialogInput.PopupComponent);
    if TargetEdit.BidiMode = bdRightToLeft then
      TargetEdit.BidiMode := bdLeftToRight
    else
      TargetEdit.BidiMode := bdRightToLeft;
  end;
end;

procedure TfrmDialogInput.mniDialogInputSelectAllClick(Sender: TObject);
begin
  if (pmnDialogInput.PopupComponent is TCustomEdit) then
    TCustomEdit(pmnDialogInput.PopupComponent).SelectAll;
end;

procedure TfrmDialogInput.pmnDialogInputPopup(Sender: TObject);
var
  TargetEdit: TCustomEdit;
begin
  if (pmnDialogInput.PopupComponent is TCustomEdit) then
  begin
    TargetEdit := TCustomEdit(pmnDialogInput.PopupComponent);
    mniDialogInputReadingOrder.Checked := TargetEdit.BidiMode = bdRightToLeft;
    mniDialogInputSelectAll.Enabled := Length(TargetEdit.Text) > 0;
    mniDialogInputCut.Enabled := TargetEdit.SelLength > 0;
    mniDialogInputCopy.Enabled := TargetEdit.SelLength > 0;
    mniDialogInputPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
  end;
end;

end.