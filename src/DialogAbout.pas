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

unit DialogAbout;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, LCLIntf, LCLType, Buttons, Menus, AppFont, AppIdentity
  {$IFDEF WINDOWS}, Windows{$ENDIF};

type

  { TfrmDialogAbout }
  TfrmDialogAbout = class(TForm)
    btnClose: TButton;
    btnWebsite: TSpeedButton;
    btnRepository: TSpeedButton;
    btnSponsor: TSpeedButton;
    btnCopyright: TSpeedButton;
    memLicense: TMemo;
    memThirdParty: TMemo;
    memUserGuide: TMemo;
    ilDialogAboutIcon: TImageList;
    imgLogo: TPaintBox;
    lblAppName: TLabel;
    lblVersion: TLabel;
    lblTagline: TLabel;
    mniDialogAboutMemoSelectAll: TMenuItem;
    mniDialogAboutMemoCopy: TMenuItem;
    pnlIdentity: TPanel;
    pnlNameVersionTag: TPanel;
    pcAbout: TPageControl;
    pmnDialogAboutMemo: TPopupMenu;
    tsInfo: TTabSheet;
    tsUserGuide: TTabSheet;
    tsLicense: TTabSheet;
    tsThirdParty: TTabSheet;
    pnlInfoBg: TPanel;
    pnlGuideBg: TPanel;
    pnlLicenseBg: TPanel;
    pnlThirdPartyBg: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure imgLogoPaint(Sender: TObject);
    procedure LinkClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure memCaretHide(Sender: TObject);
    procedure mniDialogAboutMemoCopyClick(Sender: TObject);
    procedure mniDialogAboutMemoSelectAllClick(Sender: TObject);
    procedure pmnDialogAboutMemoPopup(Sender: TObject);
  private
    procedure LoadResourceText(const ResName: String; TargetMemo: TMemo);
  public
    class procedure Execute(ATabIndex: Integer = 0);
  end;

implementation

{$R *.lfm}

var
  FAboutInstance: TfrmDialogAbout = nil;

procedure TfrmDialogAbout.FormCreate(Sender: TObject);
begin
  ApplyAppFont(Self);

  lblAppName.Caption := APP_NAME;
  lblVersion.Caption := 'Version ' + APP_VERSION;
  lblTagline.Caption := APP_TAGLINE;

  LoadResourceText('USERGUIDE', memUserGuide);
  LoadResourceText('LICENSE', memLicense);
  LoadResourceText('NOTICE', memThirdParty);
end;

procedure TfrmDialogAbout.LoadResourceText(const ResName: String; TargetMemo: TMemo);
var
  rs: TResourceStream;
begin
  try
    rs := TResourceStream.Create(HInstance, ResName, LCLType.RT_RCDATA);
    try
      TargetMemo.Lines.LoadFromStream(rs);
    finally
      rs.Free;
    end;
  except
    TargetMemo.Text := 'Resource not found: ' + ResName;
  end;
end;

procedure TfrmDialogAbout.imgLogoPaint(Sender: TObject);
begin
  imgLogo.Canvas.Brush.Color := clWindow;
  imgLogo.Canvas.FillRect(imgLogo.ClientRect);

  RenderAppLogo(imgLogo.Canvas, 0, 0, imgLogo.Height);
end;

procedure TfrmDialogAbout.LinkClick(Sender: TObject);
begin
  if Sender = btnCopyright then OpenURL(DEV_URL)
  else if Sender = btnWebsite then OpenURL(APP_URL)
  else if Sender = btnRepository then OpenURL(APP_REPOSITORY)
  else if Sender = btnSponsor then OpenURL(DEV_SPONSOR);
end;

procedure TfrmDialogAbout.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDialogAbout.memCaretHide(Sender: TObject);
begin
  HideCaret(TMemo(Sender).Handle);
end;

procedure TfrmDialogAbout.mniDialogAboutMemoCopyClick(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnDialogAboutMemo.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnDialogAboutMemo.PopupComponent);
    if TargetMemo.CanFocus then TargetMemo.SetFocus;
    TargetMemo.CopyToClipboard;
  end;
end;

procedure TfrmDialogAbout.mniDialogAboutMemoSelectAllClick(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnDialogAboutMemo.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnDialogAboutMemo.PopupComponent);
    if TargetMemo.CanFocus then TargetMemo.SetFocus;
    TargetMemo.SelectAll;
  end;
end;

procedure TfrmDialogAbout.pmnDialogAboutMemoPopup(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnDialogAboutMemo.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnDialogAboutMemo.PopupComponent);
    mniDialogAboutMemoCopy.Enabled := TargetMemo.SelLength > 0;
    mniDialogAboutMemoSelectAll.Enabled := Length(TargetMemo.Text) > 0;
  end;
end;

class procedure TfrmDialogAbout.Execute(ATabIndex: Integer = 0);
begin
  if Assigned(FAboutInstance) then
  begin
    if (ATabIndex >= 0) and (ATabIndex < FAboutInstance.pcAbout.PageCount) then
      FAboutInstance.pcAbout.PageIndex := ATabIndex;
    FAboutInstance.BringToFront;
    {$IFDEF WINDOWS}
    SetForegroundWindow(FAboutInstance.Handle);
    {$ENDIF}
    Exit;
  end;

  FAboutInstance := TfrmDialogAbout.Create(nil);
  try
    if (ATabIndex >= 0) and (ATabIndex < FAboutInstance.pcAbout.PageCount) then
      FAboutInstance.pcAbout.PageIndex := ATabIndex;
    FAboutInstance.ActiveControl := FAboutInstance.btnClose;
    FAboutInstance.ShowModal;
  finally
    FAboutInstance.Free;
    FAboutInstance := nil;
  end;
end;

end.