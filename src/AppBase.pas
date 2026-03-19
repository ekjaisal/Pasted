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

unit AppBase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, VirtualTrees, Menus, LCLIntf, Clipbrd, Buttons,
  AppFont, AppIdentity, ServiceHook, MonoLexID, DialogDefinition, 
  DialogInput, DialogAbout, StaticSQLite, ServiceResolve,
  ServiceDatabase, ServiceSettings, DialogSearchQuick, DialogMove
  {$IFDEF WINDOWS}, Windows{$ENDIF};

{$IFDEF WINDOWS}
const
  WM_POWERBROADCAST = $0218;
  WM_WTSSESSION_CHANGE = $02B1;
{$ENDIF}

const
  COLLECTION_ALL_ID = 'ALL_ITEMS_VIRTUAL_ID';

type
  PCollectionData = ^TCollectionData;
  TCollectionData = record
    ID: String;
    Name: String;
    Count: Integer;
  end;

  PTriggerData = ^TTriggerData;
  TTriggerData = record
    ID: String;
    Name: String;
    Trigger: String;
    CollectionName: String;
    LastUsed: String;
  end;

  { TfrmAppBase }

  TfrmAppBase = class(TForm)
    btnCollectionAdd: TButton;
    btnTriggerAdd: TButton;
    btnTriggerEdit: TButton;
    btnTriggerDelete: TButton;
    cbxAutoStart: TCheckBox;
    edtSearch: TEdit;
    IdleTimer: TTimer;
    lblStatus: TLabel;
    lblAutoStart: TLabel;
    mniTreeCollectionExport: TMenuItem;
    mniTreeCollectionSep1: TMenuItem;
    mniTreeTriggerDelete: TMenuItem;
    mniTreeTriggerSep: TMenuItem;
    mniTreeTriggerMove: TMenuItem;
    mniTreeTriggerEdit: TMenuItem;
    mniMemoPreviewReadingOrder: TMenuItem;
    mniMemoPreviewSep: TMenuItem;
    mniMemoPreviewSelectAll: TMenuItem;
    mniMemoPreviewCopy: TMenuItem;
    mniTrayPauseResume: TMenuItem;
    mniTrigger: TMenuItem;
    mniHelpSponsor: TMenuItem;
    mniHelpLicense: TMenuItem;
    mniHelpThirdParty: TMenuItem;
    mniHelpAbout: TMenuItem;
    mniTriggerImport: TMenuItem;
    mniTriggerExport: TMenuItem;
    mniData: TMenuItem;
    mniDataBackup: TMenuItem;
    mniDataRestore: TMenuItem;
    mniHelp: TMenuItem;
    mniHelpGuide: TMenuItem;
    mniHelpWebsite: TMenuItem;
    mniControlExit: TMenuItem;
    mniControlPauseResume: TMenuItem;
    mniControl: TMenuItem;
    mnuAppBase: TMainMenu;
    memPreview: TMemo;
    mniTreeCollectionDelete: TMenuItem;
    mniTreeCollectionRename: TMenuItem;
    mniTrayAbout: TMenuItem;
    mniTraySepOne: TMenuItem;
    mniTrayExit: TMenuItem;
    mniTrayShow: TMenuItem;
    btnTriggerMove: TButton;
    dlgRestore: TOpenDialog;
    dlgImport: TOpenDialog;
    pmnTray: TPopupMenu;
    pnlLeft: TPanel;
    pnlCollectionAction: TPanel;
    pnlMiddle: TPanel;
    pnlSearch: TPanel;
    pnlPreview: TPanel;
    pnlPreviewAction: TPanel;
    pmnCollection: TPopupMenu;
    dlgBackup: TSaveDialog;
    dlgExport: TSaveDialog;
    btnRefresh: TSpeedButton;
    pmnPreview: TPopupMenu;
    pmnSuppress: TPopupMenu;
    pmnTrigger: TPopupMenu;
    splLeft: TSplitter;
    splMiddle: TSplitter;
    SearchTimer: TTimer;
    TrayIcon: TTrayIcon;
    vstCollection: TVirtualStringTree;
    vstTrigger: TVirtualStringTree;

    procedure btnRefreshClick(Sender: TObject);
    procedure btnTriggerMoveClick(Sender: TObject);
    procedure cbxAutoStartChange(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure edtSearchEnter(Sender: TObject);
    procedure edtSearchExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure IdleTimerTimer(Sender: TObject);
    procedure mniTreeCollectionDeleteClick(Sender: TObject);
    procedure mniTreeCollectionExportClick(Sender: TObject);
    procedure mniTreeCollectionRenameClick(Sender: TObject);
    procedure mniControlExitClick(Sender: TObject);
    procedure mniControlPauseResumeClick(Sender: TObject);
    procedure mniDataBackupClick(Sender: TObject);
    procedure mniDataRestoreClick(Sender: TObject);
    procedure mniHelpAboutClick(Sender: TObject);
    procedure mniHelpGuideClick(Sender: TObject);
    procedure mniHelpLicenseClick(Sender: TObject);
    procedure mniHelpSponsorClick(Sender: TObject);
    procedure mniHelpThirdPartyClick(Sender: TObject);
    procedure mniHelpWebsiteClick(Sender: TObject);
    procedure mniMemoPreviewCopyClick(Sender: TObject);
    procedure mniMemoPreviewReadingOrderClick(Sender: TObject);
    procedure mniMemoPreviewSelectAllClick(Sender: TObject);
    procedure mniTrayAboutClick(Sender: TObject);
    procedure mniTrayExitClick(Sender: TObject);
    procedure mniTrayShowClick(Sender: TObject);
    procedure mniTriggerExportClick(Sender: TObject);
    procedure mniTriggerImportClick(Sender: TObject);
    procedure pmnCollectionPopup(Sender: TObject);
    procedure pmnPreviewPopup(Sender: TObject);
    procedure pmnTriggerPopup(Sender: TObject);
    procedure SearchTimerTimer(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure vstCollectionGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstCollectionFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstCollectionChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstCollectionCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstCollectionHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure vstTriggerChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstTriggerFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstTriggerGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstTriggerCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstTriggerHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure btnCollectionAddClick(Sender: TObject);
    procedure btnTriggerAddClick(Sender: TObject);
    procedure btnTriggerEditClick(Sender: TObject);
    procedure btnTriggerDeleteClick(Sender: TObject);
    procedure memPreviewCaretHide(Sender: TObject);
  private
    FRealExit: Boolean;
    FServiceDB: TServiceDatabase;
    FResolver: TServiceResolve;
    FFS: TFormatSettings;
    
    procedure RefreshTriggerList;
    procedure LoadCollections;
    procedure UpdatePreview;
    procedure UpdateAutoStartStatus; 
    procedure ProcessCollectionRow(const Row: array of String);
    procedure ProcessTriggerRow(const Row: array of String);
    procedure SelectCollectionByID(const ACollectionID: String);
    procedure SelectTriggerByID(const ATriggerID: String);
    procedure WMHotKey(var Msg: TMessage); message WM_HOTKEY;
    procedure WMRestore(var Msg: TMessage); message WM_PASTED_RESTORE;
    procedure WMQuit(var Msg: TMessage); message WM_PASTED_QUIT;
    {$IFDEF WINDOWS}
    procedure WMPowerBroadcast(var Msg: TMessage); message WM_POWERBROADCAST;
    procedure WMSessionChange(var Msg: TMessage); message WM_WTSSESSION_CHANGE;
    {$ENDIF}
  public
    procedure DumpMemory;
  end;

var
  frmAppBase: TfrmAppBase;

implementation

uses
  fpjson, jsonparser, Generics.Collections;

{$R *.lfm}

{$IFDEF WINDOWS}
const
  PBT_APMSUSPEND = $0004;
  PBT_APMRESUMEAUTOMATIC = $0012;
  PBT_APMRESUMESUSPEND = $0007;

  WTS_SESSION_UNLOCK = $8;
  NOTIFY_FOR_THIS_SESSION = 0;

function WTSRegisterSessionNotification(hWnd: HWND; dwFlags: DWORD): BOOL; stdcall; external 'wtsapi32.dll';
function WTSUnRegisterSessionNotification(hWnd: HWND): BOOL; stdcall; external 'wtsapi32.dll';

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

function GetGUIThreadInfo(idThread: DWORD; pgui: PGUIThreadInfo): BOOL; stdcall; external 'user32.dll';
{$ENDIF}

procedure TfrmAppBase.FormCreate(Sender: TObject);
begin
  ApplyAppFont(Self);
  FRealExit := False;

  FFS := DefaultFormatSettings;
  FFS.DateSeparator := '-';
  FFS.TimeSeparator := ':';
  FFS.ShortDateFormat := 'yyyy-mm-dd';
  FFS.LongTimeFormat := 'hh:nn:ss';

  FServiceDB := TServiceDatabase.Create;
  FResolver := TServiceResolve.Create(FServiceDB.DB);

  TrayIcon.Icon.Assign(Application.Icon);
  vstCollection.NodeDataSize := SizeOf(TCollectionData);
  vstTrigger.NodeDataSize := SizeOf(TTriggerData);

  GlobalEngine := TServiceHook.Create;
  GlobalEngine.OnKeyLog := @FResolver.OnKeyLogResolve;
  GlobalEngine.OnTrigger := @FResolver.OnSnippetTriggered;

  FResolver.RebuildIndex;

  GlobalEngine.Start;

  LoadCollections;
  RefreshTriggerList;
  UpdatePreview;
  UpdateAutoStartStatus;

  {$IFDEF WINDOWS}
  RegisterHotKey(Handle, 1, MOD_ALT, VK_OEM_1);
  RegisterHotKey(Handle, 2, MOD_CONTROL or MOD_ALT, VK_OEM_1);

  WTSRegisterSessionNotification(Handle, NOTIFY_FOR_THIS_SESSION);
  {$ENDIF}

  if not Application.ShowMainForm then
    DumpMemory;
end;

procedure TfrmAppBase.FormDestroy(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  WTSUnRegisterSessionNotification(Handle);
  UnregisterHotKey(Handle, 1);
  UnregisterHotKey(Handle, 2);
  {$ENDIF}
  if Assigned(GlobalEngine) then begin GlobalEngine.Stop; GlobalEngine.Free; end;
  if Assigned(FResolver) then FResolver.Free;
  if Assigned(FServiceDB) then FServiceDB.Free;
end;

procedure TfrmAppBase.IdleTimerTimer(Sender: TObject);
begin
  DumpMemory;
  IdleTimer.Enabled := False;
end;

procedure TfrmAppBase.mniTreeCollectionDeleteClick(Sender: TObject);
var
  Data: PCollectionData;
  Node: PVirtualNode;
  Count: Integer;
  Msg: String;
begin
  Count := vstCollection.SelectedCount;
  if Count = 0 then
  begin
    MessageDlg('Selection Error', 'Please select at least one collection to delete.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if Count = 1 then
    Msg := 'Are you sure you wish to delete this collection and all its triggers?'
  else
    Msg := Format('Are you sure you wish to delete these %d collections and all their triggers?', [Count]);

  if MessageDlg('Delete Collection', Msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FServiceDB.DB.Exec('BEGIN TRANSACTION;');
    try
      Node := vstCollection.GetFirstSelected;
      while Assigned(Node) do
      begin
        Data := vstCollection.GetNodeData(Node);
        if Data^.ID <> COLLECTION_ALL_ID then
          FServiceDB.DB.Exec('DELETE FROM collections WHERE id = ' + QuotedStr(Data^.ID));
        Node := vstCollection.GetNextSelected(Node);
      end;
      FServiceDB.DB.Exec('COMMIT;');
    except
      FServiceDB.DB.Exec('ROLLBACK;');
      raise;
    end;

    LoadCollections;
    SelectCollectionByID(COLLECTION_ALL_ID);

    GlobalEngine.Stop;
    FResolver.RebuildIndex;
    GlobalEngine.BufferReset;
    GlobalEngine.Start;
  end;
end;

procedure TfrmAppBase.mniTreeCollectionExportClick(Sender: TObject);
var
  Res: TDBResult;
  i: Integer;
  JSONArr: TJSONArray;
  JSONObj: TJSONObject;
  FileStream: TFileStream;
  JSONStr: String;
  Node: PVirtualNode;
  Data: PCollectionData;
  HasAllNode: Boolean;
  IdList: String;
  SQL: String;
begin
  if vstCollection.SelectedCount = 0 then Exit;

  dlgExport.Title := 'Export Collections';
  dlgExport.FileName := 'Pasted_Collection_Export_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.json';

  if dlgExport.Execute then
  begin
    HasAllNode := False;
    IdList := '';

    Node := vstCollection.GetFirstSelected;
    while Assigned(Node) do
    begin
      Data := vstCollection.GetNodeData(Node);
      if Data^.ID = COLLECTION_ALL_ID then HasAllNode := True;
      if IdList <> '' then IdList := IdList + ',';
      IdList := IdList + QuotedStr(Data^.ID);
      Node := vstCollection.GetNextSelected(Node);
    end;

    if HasAllNode then
      SQL := 'SELECT d.name, d.trigger_word, d.definition_text, c.name FROM definitions d LEFT JOIN collections c ON d.collection_id = c.id'
    else
      SQL := 'SELECT d.name, d.trigger_word, d.definition_text, c.name FROM definitions d LEFT JOIN collections c ON d.collection_id = c.id WHERE d.collection_id IN (' + IdList + ')';

    JSONArr := TJSONArray.Create;
    try
      Res := FServiceDB.DB.Query(SQL);
      for i := 0 to High(Res) do
      begin
        JSONObj := TJSONObject.Create;
        JSONObj.Add('name', Res[i][0]);
        JSONObj.Add('trigger', Res[i][1]);
        JSONObj.Add('definition', Res[i][2]);
        JSONObj.Add('collection', Res[i][3]);
        JSONArr.Add(JSONObj);
      end;

      JSONStr := JSONArr.FormatJSON();

      try
        FileStream := TFileStream.Create(dlgExport.FileName, fmCreate or fmShareExclusive);
        try
          FileStream.WriteBuffer(Pointer(JSONStr)^, Length(JSONStr));
        finally
          FileStream.Free;
        end;
        MessageDlg('Export Successful', Format('Successfully exported %d triggers.', [Length(Res)]), mtInformation, [mbOK], 0);
      except
        on E: EFCreateError do
          MessageDlg('Export Error', 'Could not save the export file. Please verify directory permissions.', mtError, [mbOK], 0);
        on E: Exception do
          MessageDlg('Export Error', 'An unexpected error occurred during export: ' + E.Message, mtError, [mbOK], 0);
      end;

    finally
      JSONArr.Free;
    end;
  end;
end;

procedure TfrmAppBase.mniTreeCollectionRenameClick(Sender: TObject);
var
  Data: PCollectionData;
  NewName: String;
  Res: TDBResult;
  TargetID: String;
begin
  if vstCollection.SelectedCount <> 1 then Exit;

  Data := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
  if Data^.ID = COLLECTION_ALL_ID then Exit;

  TargetID := Data^.ID;

  if TfrmDialogInput.Execute('Rename Collection', 'Enter new name', Data^.Name, NewName) then
  begin
    if SameText(Data^.Name, NewName) then Exit;

    Res := FServiceDB.DB.Query('SELECT id FROM collections WHERE name = ' + QuotedStr(NewName) + ' COLLATE NOCASE');

    if Length(Res) = 0 then
    begin
      FServiceDB.DB.Exec('UPDATE collections SET name = ' + QuotedStr(NewName) + ' WHERE id = ' + QuotedStr(TargetID));
      LoadCollections;
      SelectCollectionByID(TargetID);
    end
    else
    begin
      MessageDlg('Validation Error', 'A collection with this name already exists.', mtWarning, [mbOK], 0);
    end;
  end;
end;

procedure TfrmAppBase.mniControlExitClick(Sender: TObject);
begin
  FRealExit := True;
  Application.Terminate;
end;

procedure TfrmAppBase.mniControlPauseResumeClick(Sender: TObject);
begin
  if GlobalEngine.Active then
  begin
    GlobalEngine.Stop;
    mniControlPauseResume.Caption := 'Resume Activity';
    mniControlPauseResume.ImageIndex := 11;
    mniTrayPauseResume.Caption := 'Resume Activity';
    mniTrayPauseResume.ImageIndex := 11;
    lblStatus.Caption := 'Status: Paused';
  end
  else
  begin
    GlobalEngine.Start;
    mniControlPauseResume.Caption := 'Pause Activity';
    mniControlPauseResume.ImageIndex := 10;
    mniTrayPauseResume.Caption := 'Pause Activity';
    mniTrayPauseResume.ImageIndex := 10;
    lblStatus.Caption := 'Status: Active';
  end;
end;

procedure TfrmAppBase.mniDataBackupClick(Sender: TObject);
var
  TestStream: TFileStream;
begin
  dlgBackup.Title := 'Back Up Database';
  dlgBackup.FileName := 'Pasted_Backup_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.db';

  if dlgBackup.Execute then
  begin
    try
      TestStream := TFileStream.Create(dlgBackup.FileName, fmCreate or fmShareExclusive);
      TestStream.Free;
      SysUtils.DeleteFile(dlgBackup.FileName);

      FServiceDB.DB.Exec('VACUUM INTO ' + QuotedStr(dlgBackup.FileName) + ';');

      if FileExists(dlgBackup.FileName) then
        MessageDlg('Backup Successful', 'Data has been successfully backed up.', mtInformation, [mbOK], 0)
      else
        MessageDlg('Backup Error', 'Pasted could not write to the destination.', mtError, [mbOK], 0);
    except
      on E: EFCreateError do
        MessageDlg('Backup Error', 'Could not create the backup. Please verify directory permissions.', mtError, [mbOK], 0);
      on E: Exception do
        MessageDlg('Backup Error', 'An unexpected error occurred during backup: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmAppBase.mniDataRestoreClick(Sender: TObject);
var
  DBPath: String;
  BackupPath: String;
  InStream, OutStream: TFileStream;
  TempDB: TStaticSQLite;
  Res: TDBResult;
begin
  if MessageDlg('Confirm Restore', 'Restoring will overwrite the current data. Do you wish to proceed?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  dlgRestore.Title := 'Restore Database';
  if dlgRestore.Execute then
  begin
    DBPath := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) + 'Pasted.db';

    if SameText(dlgRestore.FileName, DBPath) then
    begin
      MessageDlg('Restore Error', 'You cannot restore using the currently active database file.', mtError, [mbOK], 0);
      Exit;
    end;

    try
      TempDB := TStaticSQLite.Create(dlgRestore.FileName);
      try
        Res := TempDB.Query('SELECT COUNT(*) FROM collections');
        if Length(Res) = 0 then
        begin
          MessageDlg('Restore Error', 'The selected file is not a valid Pasted database or is corrupted.', mtError, [mbOK], 0);
          Exit;
        end;
      finally
        TempDB.Free;
      end;
    except
      MessageDlg('Restore Error', 'Could not open the selected file. It may be corrupted or inaccessible.', mtError, [mbOK], 0);
      Exit;
    end;

    GlobalEngine.Stop;

    if Assigned(FResolver) then FreeAndNil(FResolver);
    if Assigned(FServiceDB) then FreeAndNil(FServiceDB);

    BackupPath := DBPath + '.bak_' + FormatDateTime('yyyymmdd_hhnnss', Now);

    if FileExists(DBPath) then
      RenameFile(DBPath, BackupPath);

    try
      InStream := TFileStream.Create(dlgRestore.FileName, fmOpenRead or fmShareDenyWrite);
      try
        OutStream := TFileStream.Create(DBPath, fmCreate);
        try
          OutStream.CopyFrom(InStream, 0);
        finally
          OutStream.Free;
        end;
      finally
        InStream.Free;
      end;
      MessageDlg('Restore Successful', 'Data has been successfully restored.', mtInformation, [mbOK], 0);
    except
      on E: Exception do
      begin
        if FileExists(BackupPath) then
          RenameFile(BackupPath, DBPath);
        MessageDlg('Restore Error', 'Failed to restore the database file: ' + E.Message, mtError, [mbOK], 0);
      end;
    end;

    FServiceDB := TServiceDatabase.Create;
    FResolver := TServiceResolve.Create(FServiceDB.DB);
    GlobalEngine.OnKeyLog := @FResolver.OnKeyLogResolve;
    GlobalEngine.OnTrigger := @FResolver.OnSnippetTriggered;

    FResolver.RebuildIndex;

    LoadCollections;
    RefreshTriggerList;

    GlobalEngine.Start;
    DumpMemory;
  end;
end;

procedure TfrmAppBase.mniHelpAboutClick(Sender: TObject);
begin
  TfrmDialogAbout.Execute(0);
  DumpMemory;
end;

procedure TfrmAppBase.mniHelpGuideClick(Sender: TObject);
begin
  TfrmDialogAbout.Execute(1);
  DumpMemory;
end;

procedure TfrmAppBase.mniHelpLicenseClick(Sender: TObject);
begin
  TfrmDialogAbout.Execute(2);
  DumpMemory;
end;

procedure TfrmAppBase.mniHelpSponsorClick(Sender: TObject);
begin
  OpenURL(DEV_SPONSOR);
end;

procedure TfrmAppBase.mniHelpThirdPartyClick(Sender: TObject);
begin
  TfrmDialogAbout.Execute(3);
  DumpMemory;
end;

procedure TfrmAppBase.mniHelpWebsiteClick(Sender: TObject);
begin
  OpenURL(APP_URL);
end;

procedure TfrmAppBase.mniMemoPreviewCopyClick(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnPreview.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnPreview.PopupComponent);
    if TargetMemo.CanFocus then TargetMemo.SetFocus;
    TargetMemo.CopyToClipboard;
  end;
end;

procedure TfrmAppBase.mniMemoPreviewReadingOrderClick(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnPreview.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnPreview.PopupComponent);
    if TargetMemo.BidiMode = bdRightToLeft then
      TargetMemo.BidiMode := bdLeftToRight
    else
      TargetMemo.BidiMode := bdRightToLeft;
  end;
end;

procedure TfrmAppBase.mniMemoPreviewSelectAllClick(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnPreview.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnPreview.PopupComponent);
    if TargetMemo.CanFocus then TargetMemo.SetFocus;
    TargetMemo.SelectAll;
  end;
end;

{$IFDEF WINDOWS}
procedure TfrmAppBase.WMPowerBroadcast(var Msg: TMessage);
begin
  if Msg.wParam = PBT_APMSUSPEND then
  begin
    if Assigned(GlobalEngine) then GlobalEngine.Stop;
  end
  else if (Msg.wParam = PBT_APMRESUMEAUTOMATIC) or (Msg.wParam = PBT_APMRESUMESUSPEND) then
  begin
    if Assigned(GlobalEngine) then GlobalEngine.Start;
  end;
  Msg.Result := 1;
end;

procedure TfrmAppBase.WMSessionChange(var Msg: TMessage);
begin
  if Msg.wParam = WTS_SESSION_UNLOCK then
  begin
    if Assigned(GlobalEngine) then
    begin
      GlobalEngine.Stop;
      GlobalEngine.Start;
    end;
  end;
  Msg.Result := 0;
end;
{$ENDIF}

procedure TfrmAppBase.WMHotKey(var Msg: TMessage);
var
  SelectedID: String;
  {$IFDEF WINDOWS}
  TargetWnd: HWND;
  TargetThreadID, TargetProcessID: DWORD;
  TargetProcessHandle: THandle;
  GUIInfo: TGUITHREADINFO;
  WaitCount: Integer;
  {$ENDIF}
begin
  if not GlobalEngine.Active then Exit;

  if (Msg.wParam = 1) or (Msg.wParam = 2) then
  begin
    try
      {$IFDEF WINDOWS}
      TargetWnd := GetForegroundWindow();
      {$ENDIF}

      if Assigned(FServiceDB) then
        SelectedID := TfrmDialogSearchQuick.Execute(FServiceDB.DB)
      else
        SelectedID := '';

      if SelectedID <> '' then
      begin
        {$IFDEF WINDOWS}
        if TargetWnd <> 0 then
        begin
          SetForegroundWindow(TargetWnd);
          TargetThreadID := GetWindowThreadProcessId(TargetWnd, @TargetProcessID);

          TargetProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, TargetProcessID);
          if TargetProcessHandle <> 0 then
          begin
            WaitForInputIdle(TargetProcessHandle, 1000);
            CloseHandle(TargetProcessHandle);
          end;

          GUIInfo.cbSize := SizeOf(TGUITHREADINFO);
          WaitCount := 0;
          while WaitCount < 250 do
          begin
            if GetForegroundWindow() = TargetWnd then
            begin
              if GetGUIThreadInfo(TargetThreadID, @GUIInfo) and (GUIInfo.hwndFocus <> 0) then Break;
            end;
            Sleep(1);
            Inc(WaitCount);
          end;
          Sleep(100);
        end;
        {$ENDIF}
        GlobalEngine.ExecuteSubstitution('', SelectedID);
      end;
    finally
      DumpMemory;
    end;
  end;
end;

procedure TfrmAppBase.WMRestore(var Msg: TMessage);
begin
  if Msg.Msg = 0 then;
  mniTrayShowClick(nil);
end;

procedure TfrmAppBase.SelectCollectionByID(const ACollectionID: String);
var
  Node: PVirtualNode;
  Data: PCollectionData;
begin
  Node := vstCollection.GetFirst;
  while Assigned(Node) do
  begin
    Data := vstCollection.GetNodeData(Node);
    if Data^.ID = ACollectionID then
    begin
      vstCollection.ClearSelection;
      vstCollection.Selected[Node] := True;
      vstCollection.FocusedNode := Node;
      vstCollection.ScrollIntoView(Node, True);
      Break;
    end;
    Node := vstCollection.GetNext(Node);
  end;
end;

procedure TfrmAppBase.WMQuit(var Msg: TMessage);
begin
  if Msg.Msg = 0 then;
  FRealExit := True;
  Close;
end;

procedure TfrmAppBase.SelectTriggerByID(const ATriggerID: String);
var
  Node: PVirtualNode;
  Data: PTriggerData;
begin
  Node := vstTrigger.GetFirst;
  while Assigned(Node) do
  begin
    Data := vstTrigger.GetNodeData(Node);
    if Data^.ID = ATriggerID then
    begin
      vstTrigger.ClearSelection;
      vstTrigger.Selected[Node] := True;
      vstTrigger.FocusedNode := Node;
      vstTrigger.ScrollIntoView(Node, True);
      Break;
    end;
    Node := vstTrigger.GetNext(Node);
  end;
end;

procedure TfrmAppBase.DumpMemory;
begin
  if Assigned(FServiceDB) then FServiceDB.DB.Exec('PRAGMA shrink_memory;');
  {$IFDEF WINDOWS}
  SetProcessWorkingSetSize(GetCurrentProcess(), PtrUInt(-1), PtrUInt(-1));
  {$ENDIF}
end;

procedure TfrmAppBase.ProcessTriggerRow(const Row: array of String);
var
  Node: PVirtualNode;
  Data: PTriggerData;
  DT: TDateTime;
begin
  if Length(Row) = 0 then;
  Node := vstTrigger.AddChild(nil);
  Data := vstTrigger.GetNodeData(Node);
  Data^.ID := Row[0];
  Data^.Name := Row[1];
  Data^.Trigger := Row[2];
  Data^.CollectionName := Row[3];
  
  if (Row[4] <> '') and TryStrToDateTime(Row[4], DT, FFS) then
    Data^.LastUsed := FormatDateTime('yyyy-mm-dd hh:nn:ss', UniversalTimeToLocal(DT))
  else
    Data^.LastUsed := Row[4];
end;

procedure TfrmAppBase.ProcessCollectionRow(const Row: array of String);
var
  Node: PVirtualNode;
  Data: PCollectionData;
begin
  if Length(Row) = 0 then;
  Node := vstCollection.AddChild(nil);
  Data := vstCollection.GetNodeData(Node);
  Data^.ID := Row[0];
  Data^.Name := Row[1];
  Data^.Count := StrToIntDef(Row[2], 0);
end;

procedure TfrmAppBase.RefreshTriggerList;
var
  SQL, SVal, SearchFilter: String;
  CollData: PCollectionData;
  SelectedCollID: String;
  SortField, SortOrder: String;
begin
  SelectedCollID := COLLECTION_ALL_ID;
  if vstCollection.GetFirstSelected <> nil then
  begin
    CollData := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
    SelectedCollID := CollData^.ID;
  end;

  if Trim(edtSearch.Text) <> '' then
  begin
    SVal := QuotedStr('%' + Trim(edtSearch.Text) + '%');
    SearchFilter := ' AND (d.name LIKE ' + SVal + ' OR d.trigger_word LIKE ' + SVal + ' OR d.definition_text LIKE ' + SVal + ')';
  end
  else
    SearchFilter := '';

  case vstTrigger.Header.SortColumn of
    1: SortField := 'd.trigger_word';
    2: SortField := 'c.name';
    3: SortField := 'd.last_triggered';
    else SortField := 'd.name';
  end;

  if vstTrigger.Header.SortDirection = sdAscending then SortOrder := ' ASC' else SortOrder := ' DESC';

  SQL := 'SELECT d.id, d.name, d.trigger_word, c.name, d.last_triggered FROM definitions d LEFT JOIN collections c ON d.collection_id = c.id WHERE 1=1' + SearchFilter;

  if SelectedCollID <> COLLECTION_ALL_ID then
    SQL := SQL + ' AND d.collection_id = ' + QuotedStr(SelectedCollID);

  SQL := SQL + ' ORDER BY ' + SortField + SortOrder;

  vstTrigger.BeginUpdate;
  try
    vstTrigger.Clear;
    FServiceDB.DB.QueryProc(SQL, @ProcessTriggerRow);
  finally
    vstTrigger.EndUpdate;
  end;

  IdleTimer.Enabled := False;
  IdleTimer.Enabled := True;
end;

procedure TfrmAppBase.UpdateAutoStartStatus;
begin
  cbxAutoStart.OnChange := nil;
  cbxAutoStart.Checked := TServiceSettings.IsAutoStartEnabled;
  if cbxAutoStart.Checked then lblAutoStart.Caption := 'Enabled on system start-up'
  else lblAutoStart.Caption := 'Disabled on system start-up';
  cbxAutoStart.OnChange := @cbxAutoStartChange;
end;

procedure TfrmAppBase.cbxAutoStartChange(Sender: TObject);
begin
  TServiceSettings.SetAutoStart(cbxAutoStart.Checked);
  if cbxAutoStart.Checked then lblAutoStart.Caption := 'Enabled on system start-up'
  else lblAutoStart.Caption := 'Disabled on system start-up';
end;

procedure TfrmAppBase.btnTriggerMoveClick(Sender: TObject);
var
  TargetCollID: String;
  Node: PVirtualNode;
  Data: PTriggerData;
  UpdatesPending: Boolean;
  CurrentCollID, FinalRouteID: String;
  CollData: PCollectionData;
begin
  if vstTrigger.GetFirstSelected = nil then
  begin
    MessageDlg('Selection Error', 'Please select at least one trigger to move.', mtWarning, [mbOK], 0);
    Exit;
  end;

  CurrentCollID := COLLECTION_ALL_ID;
  if vstCollection.GetFirstSelected <> nil then
  begin
    CollData := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
    CurrentCollID := CollData^.ID;
  end;

  if TfrmDialogMove.Execute(FServiceDB.DB, TargetCollID) then
  begin
    UpdatesPending := False;
    FServiceDB.DB.Exec('BEGIN TRANSACTION;');
    try
      Node := vstTrigger.GetFirstSelected;
      while Assigned(Node) do
      begin
        Data := vstTrigger.GetNodeData(Node);
        FServiceDB.DB.Exec('UPDATE definitions SET collection_id = ' + QuotedStr(TargetCollID) + ' WHERE id = ' + QuotedStr(Data^.ID));
        UpdatesPending := True;
        Node := vstTrigger.GetNextSelected(Node);
      end;
      FServiceDB.DB.Exec('COMMIT;');
    except
      FServiceDB.DB.Exec('ROLLBACK;');
      raise;
    end;

    if UpdatesPending then
    begin
      if CurrentCollID = COLLECTION_ALL_ID then
        FinalRouteID := COLLECTION_ALL_ID
      else
        FinalRouteID := TargetCollID;

      LoadCollections;
      SelectCollectionByID(FinalRouteID);
    end;
  end;
end;

procedure TfrmAppBase.btnRefreshClick(Sender: TObject);
begin
  RefreshTriggerList;
  UpdatePreview;
end;

procedure TfrmAppBase.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not FRealExit then begin CanClose := False; Hide; DumpMemory; end else CanClose := True;
end;

procedure TfrmAppBase.FormShow(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  BringWindowToTop(Handle);
  SetForegroundWindow(Handle);
  {$ENDIF}
  Application.BringToFront;
end;

procedure TfrmAppBase.FormWindowStateChange(Sender: TObject);
begin 
  if WindowState = wsMinimized
  then DumpMemory; 
end;

procedure TfrmAppBase.TrayIconDblClick(Sender: TObject);
begin
  mniTrayShowClick(nil);
end;

procedure TfrmAppBase.mniTrayShowClick(Sender: TObject);
begin
  Application.ShowMainForm := True;
  if WindowState = wsMinimized then
    WindowState := wsNormal;
  WindowState := wsMaximized;
  Show;
  {$IFDEF WINDOWS}
  SetForegroundWindow(Handle);
  BringWindowToTop(Handle);
  {$ENDIF}
  Application.BringToFront;
end;

procedure TfrmAppBase.mniTriggerExportClick(Sender: TObject);
var
  Res: TDBResult;
  i: Integer;
  JSONArr: TJSONArray;
  JSONObj: TJSONObject;
  FileStream: TFileStream;
  JSONStr: String;
begin
  dlgExport.Title := 'Export Triggers';
  dlgExport.FileName := 'Pasted_Export_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.json';

  if dlgExport.Execute then
  begin
    JSONArr := TJSONArray.Create;
    try
      Res := FServiceDB.DB.Query('SELECT d.name, d.trigger_word, d.definition_text, c.name FROM definitions d LEFT JOIN collections c ON d.collection_id = c.id');
      for i := 0 to High(Res) do
      begin
        JSONObj := TJSONObject.Create;
        JSONObj.Add('name', Res[i][0]);
        JSONObj.Add('trigger', Res[i][1]);
        JSONObj.Add('definition', Res[i][2]);
        JSONObj.Add('collection', Res[i][3]);
        JSONArr.Add(JSONObj);
      end;

      JSONStr := JSONArr.FormatJSON();
      
      try
        FileStream := TFileStream.Create(dlgExport.FileName, fmCreate or fmShareExclusive);
        try
          FileStream.WriteBuffer(Pointer(JSONStr)^, Length(JSONStr));
        finally
          FileStream.Free;
        end;
        MessageDlg('Export Successful', Format('Successfully exported %d triggers.', [Length(Res)]), mtInformation, [mbOK], 0);
      except
        on E: EFCreateError do
          MessageDlg('Export Error', 'Could not save the export file. Please verify directory permissions.', mtError, [mbOK], 0);
        on E: Exception do
          MessageDlg('Export Error', 'An unexpected error occurred during export: ' + E.Message, mtError, [mbOK], 0);
      end;

    finally
      JSONArr.Free;
    end;
  end;
end;

procedure TfrmAppBase.mniTriggerImportClick(Sender: TObject);
var
  FileStream: TFileStream;
  JSONData: TJSONData;
  JSONArr: TJSONArray;
  JSONObj: TJSONObject;
  i: Integer;
  TName, TTrigger, TDef, TCollName, TargetCollID: String;
  SuccessCount, SkipCount, BatchCount: Integer;
  Parser: TJSONParser;
  CurrentCollID: String;
  CollData: PCollectionData;
  CollCache: specialize TDictionary<String, String>;
  TrigCache: specialize TDictionary<String, Boolean>;
  Res: TDBResult;
  BatchSQL: String;
  ImportMsg: String;
begin
  dlgImport.Title := 'Import Triggers';
  if dlgImport.Execute then
  begin
    CurrentCollID := COLLECTION_ALL_ID;
    if vstCollection.GetFirstSelected <> nil then
    begin
      CollData := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
      CurrentCollID := CollData^.ID;
    end;

    SuccessCount := 0;
    SkipCount := 0;
    BatchCount := 0;
    BatchSQL := '';
    JSONData := nil;

    try
      FileStream := TFileStream.Create(dlgImport.FileName, fmOpenRead or fmShareDenyWrite);
    except
      MessageDlg('Import Error', 'Could not open the selected file.', mtError, [mbOK], 0);
      Exit;
    end;

    CollCache := specialize TDictionary<String, String>.Create;
    TrigCache := specialize TDictionary<String, Boolean>.Create;

    try
      Res := FServiceDB.DB.Query('SELECT name, id FROM collections');
      for i := 0 to High(Res) do
        CollCache.AddOrSetValue(LowerCase(Res[i][0]), Res[i][1]);

      Res := FServiceDB.DB.Query('SELECT trigger_word FROM definitions');
      for i := 0 to High(Res) do
        TrigCache.AddOrSetValue(LowerCase(Res[i][0]), True);

      Parser := TJSONParser.Create(FileStream, []);
      try
        try
          JSONData := Parser.Parse;
        except
          MessageDlg('Import Error', 'The selected file is corrupted or not a valid JSON document.', mtError, [mbOK], 0);
          Exit;
        end;

        if Assigned(JSONData) and (JSONData is TJSONArray) then
        begin
          JSONArr := TJSONArray(JSONData);
          FServiceDB.DB.Exec('BEGIN TRANSACTION;');
          try
            for i := 0 to JSONArr.Count - 1 do
            begin
              if JSONArr.Items[i] is TJSONObject then
              begin
                JSONObj := TJSONObject(JSONArr.Items[i]);
                TName := JSONObj.Get('name', 'Untitled');
                TTrigger := JSONObj.Get('trigger', '');
                TDef := JSONObj.Get('definition', '');
                TCollName := JSONObj.Get('collection', 'Default');

                if Trim(TCollName) = '' then TCollName := 'Default';
                if Trim(TTrigger) = '' then Continue;

                if TrigCache.ContainsKey(LowerCase(TTrigger)) then
                begin
                  Inc(SkipCount);
                  Continue;
                end;

                if not CollCache.TryGetValue(LowerCase(TCollName), TargetCollID) then
                begin
                  TargetCollID := NewMonoLexID;
                  FServiceDB.DB.Exec('INSERT INTO collections (id, name) VALUES (' + QuotedStr(TargetCollID) + ',' + QuotedStr(TCollName) + ')');
                  CollCache.AddOrSetValue(LowerCase(TCollName), TargetCollID);
                end;

                BatchSQL := BatchSQL + '(' + QuotedStr(NewMonoLexID) + ',' + QuotedStr(TargetCollID) + ',' + QuotedStr(TName) + ',' + QuotedStr(TTrigger) + ',' + QuotedStr(TDef) + '),';
                Inc(BatchCount);
                Inc(SuccessCount);
                TrigCache.AddOrSetValue(LowerCase(TTrigger), True);

                if BatchCount >= 500 then
                begin
                  SetLength(BatchSQL, Length(BatchSQL) - 1);
                  FServiceDB.DB.Exec('INSERT INTO definitions (id, collection_id, name, trigger_word, definition_text) VALUES ' + BatchSQL);
                  BatchSQL := '';
                  BatchCount := 0;
                end;
              end;
            end;

            if BatchCount > 0 then
            begin
              SetLength(BatchSQL, Length(BatchSQL) - 1);
              FServiceDB.DB.Exec('INSERT INTO definitions (id, collection_id, name, trigger_word, definition_text) VALUES ' + BatchSQL);
            end;

            FServiceDB.DB.Exec('COMMIT;');
          except
            FServiceDB.DB.Exec('ROLLBACK;');
            raise;
          end;
        end
        else
        begin
          MessageDlg('Import Error', 'The file does not contain a valid array of triggers.', mtError, [mbOK], 0);
          Exit;
        end;

      finally
        if Assigned(JSONData) then JSONData.Free;
        Parser.Free;
      end;
    finally
      CollCache.Free;
      TrigCache.Free;
      FileStream.Free;
    end;

    LoadCollections;
    SelectCollectionByID(CurrentCollID);

    GlobalEngine.Stop;
    FResolver.RebuildIndex;
    GlobalEngine.BufferReset;
    GlobalEngine.Start;

    if SkipCount > 0 then
      ImportMsg := Format('Successfully imported %d triggers.' + sLineBreak + 'Skipped %d triggers to prevent duplicates.', [SuccessCount, SkipCount])
    else
      ImportMsg := Format('Successfully imported %d triggers.', [SuccessCount]);

    MessageDlg('Import Successful', ImportMsg, mtInformation, [mbOK], 0);
    DumpMemory;
  end;
end;

procedure TfrmAppBase.pmnCollectionPopup(Sender: TObject);
var
  HasAllNode: Boolean;
  Node: PVirtualNode;
  Data: PCollectionData;
  SelCount: Integer;
begin
  HasAllNode := False;
  SelCount := vstCollection.SelectedCount;
  Node := vstCollection.GetFirstSelected;

  while Assigned(Node) do
  begin
    Data := vstCollection.GetNodeData(Node);
    if Data^.ID = COLLECTION_ALL_ID then HasAllNode := True;
    Node := vstCollection.GetNextSelected(Node);
  end;

  mniTreeCollectionRename.Enabled := (SelCount = 1) and not HasAllNode;
  mniTreeCollectionDelete.Enabled := (SelCount > 0) and not HasAllNode;
  mniTreeCollectionExport.Enabled := (SelCount > 0);

  if SelCount > 1 then
  begin
    mniTreeCollectionDelete.Caption := 'Delete Collections';
    mniTreeCollectionExport.Caption := 'Export Collections';
  end
  else
  begin
    mniTreeCollectionDelete.Caption := 'Delete Collection';
    mniTreeCollectionExport.Caption := 'Export Collection';
  end;
end;

procedure TfrmAppBase.pmnPreviewPopup(Sender: TObject);
var
  TargetMemo: TMemo;
begin
  if (pmnPreview.PopupComponent is TMemo) then
  begin
    TargetMemo := TMemo(pmnPreview.PopupComponent);
    mniMemoPreviewReadingOrder.Checked := TargetMemo.BidiMode = bdRightToLeft;
    mniMemoPreviewCopy.Enabled := TargetMemo.SelLength > 0;
    mniMemoPreviewSelectAll.Enabled := Length(TargetMemo.Text) > 0;
  end;
end;

procedure TfrmAppBase.pmnTriggerPopup(Sender: TObject);
var
  SelCount: Integer;
begin
  SelCount := vstTrigger.SelectedCount;

  if SelCount = 0 then
  begin
    mniTreeTriggerEdit.Enabled := False;
    mniTreeTriggerMove.Enabled := False;
    mniTreeTriggerDelete.Enabled := False;
  end
  else
  begin
    mniTreeTriggerEdit.Enabled := (SelCount = 1);
    mniTreeTriggerMove.Enabled := True;
    mniTreeTriggerDelete.Enabled := True;
  end;
end;

procedure TfrmAppBase.SearchTimerTimer(Sender: TObject);
begin
  SearchTimer.Enabled := False;
  RefreshTriggerList;
end;

procedure TfrmAppBase.mniTrayExitClick(Sender: TObject);
begin
  FRealExit := True;
  Application.Terminate;
end;

procedure TfrmAppBase.mniTrayAboutClick(Sender: TObject);
begin
  TfrmDialogAbout.Execute;
  DumpMemory;
end;

procedure TfrmAppBase.LoadCollections;
var 
  Res: TDBResult; 
  Node: PVirtualNode; 
  Data: PCollectionData; 
  TotalCount: Integer;
begin
  vstCollection.BeginUpdate;
  try
    vstCollection.Clear;
    
    TotalCount := 0;
    Res := FServiceDB.DB.Query('SELECT COUNT(*) FROM definitions');
    if Length(Res) > 0 then TotalCount := StrToIntDef(Res[0][0], 0);

    Node := vstCollection.AddChild(nil);
    Data := vstCollection.GetNodeData(Node);
    Data^.ID := COLLECTION_ALL_ID;
    Data^.Name := 'All';
    Data^.Count := TotalCount;
    
    FServiceDB.DB.QueryProc('SELECT id, name, (SELECT COUNT(*) FROM definitions d WHERE d.collection_id = c.id) FROM collections c', @ProcessCollectionRow);
  finally
    vstCollection.EndUpdate;
    vstCollection.SortTree(vstCollection.Header.SortColumn, vstCollection.Header.SortDirection);
  end;
end;

procedure TfrmAppBase.vstCollectionGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var Data: PCollectionData; 
begin 
  if TextType = ttNormal then;
  Data := Sender.GetNodeData(Node); 
  if Column = 0 then CellText := Data^.Name else CellText := IntToStr(Data^.Count); 
end;

procedure TfrmAppBase.vstCollectionFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var Data: PCollectionData;
begin 
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

procedure TfrmAppBase.vstCollectionChange(Sender: TBaseVirtualTree; Node: PVirtualNode); 
begin 
  if Assigned(Node) then;
  RefreshTriggerList; 
end;

procedure TfrmAppBase.vstCollectionHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
begin
  if Sender.SortColumn = HitInfo.Column then
  begin
    if Sender.SortDirection = sdAscending then Sender.SortDirection := sdDescending
    else Sender.SortDirection := sdAscending;
  end
  else
  begin
    Sender.SortColumn := HitInfo.Column;
    Sender.SortDirection := sdAscending;
  end;
  Sender.Treeview.SortTree(HitInfo.Column, Sender.SortDirection);
end;

procedure TfrmAppBase.vstCollectionCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var 
  Data1, Data2: PCollectionData;
  DirectionMod: Integer;
begin
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);
  
  if TVirtualStringTree(Sender).Header.SortDirection = sdAscending then DirectionMod := 1 else DirectionMod := -1;
  if Data1^.ID = COLLECTION_ALL_ID then begin Result := -1 * DirectionMod; Exit; end;
  if Data2^.ID = COLLECTION_ALL_ID then begin Result := 1 * DirectionMod; Exit; end;

  case Column of
    0: Result := CompareText(Data1^.Name, Data2^.Name);
    1: 
    begin
      if Data1^.Count > Data2^.Count then Result := 1
      else if Data1^.Count < Data2^.Count then Result := -1
      else Result := 0;
    end;
  end;
end;

procedure TfrmAppBase.vstTriggerGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var Data: PTriggerData;
begin
  if TextType = ttNormal then;
  Data := Sender.GetNodeData(Node);
  case Column of
    0: CellText := Data^.Name;
    1: CellText := Data^.Trigger;
    2: CellText := Data^.CollectionName;
    3: CellText := Data^.LastUsed;
  end;
end;

procedure TfrmAppBase.vstTriggerFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var Data: PTriggerData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

procedure TfrmAppBase.vstTriggerChange(Sender: TBaseVirtualTree; Node: PVirtualNode); 
begin 
  if Assigned(Node) then;
  UpdatePreview; 
end;

procedure TfrmAppBase.vstTriggerHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
begin
  if Sender.SortColumn = HitInfo.Column then
  begin
    if Sender.SortDirection = sdAscending then Sender.SortDirection := sdDescending
    else Sender.SortDirection := sdAscending;
  end
  else
  begin
    Sender.SortColumn := HitInfo.Column;
    Sender.SortDirection := sdAscending;
  end;
  RefreshTriggerList;
end;

procedure TfrmAppBase.vstTriggerCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var Data1, Data2: PTriggerData;
begin
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);
  
  case Column of
    0: Result := CompareText(Data1^.Name, Data2^.Name);
    1: Result := CompareText(Data1^.Trigger, Data2^.Trigger);
    2: Result := CompareText(Data1^.CollectionName, Data2^.CollectionName);
    3: Result := CompareText(Data1^.LastUsed, Data2^.LastUsed);
  end;
end;

procedure TfrmAppBase.edtSearchEnter(Sender: TObject); begin GlobalEngine.Stop; end;
procedure TfrmAppBase.edtSearchExit(Sender: TObject); begin GlobalEngine.Start; end;

procedure TfrmAppBase.edtSearchChange(Sender: TObject);
begin
  SearchTimer.Enabled := False;
  SearchTimer.Enabled := True;
end;

procedure TfrmAppBase.UpdatePreview;
var
  Res: TDBResult;
  Data: PTriggerData;
begin
  if vstTrigger.SelectedCount > 1 then
  begin
    memPreview.Text := 'Multiple triggers selected.';
    Exit;
  end;

  if vstTrigger.GetFirstSelected <> nil then
  begin
    Data := vstTrigger.GetNodeData(vstTrigger.GetFirstSelected);
    Res := FServiceDB.DB.Query('SELECT definition_text FROM definitions WHERE id = ' + QuotedStr(Data^.ID));
    if Length(Res) > 0 then memPreview.Text := Res[0][0] else memPreview.Text := 'Select a trigger to view its definition.';
  end else memPreview.Text := 'Select a trigger to view its definition.';
end;

procedure TfrmAppBase.memPreviewCaretHide(Sender: TObject);
begin
  HideCaret(TMemo(Sender).Handle);
end;

procedure TfrmAppBase.btnCollectionAddClick(Sender: TObject);
var 
  NewCollName: String; 
  Res: TDBResult;
  NewID: String;
begin
  if TfrmDialogInput.Execute('New Collection', 'Collection Name', '', NewCollName) then
  begin
    Res := FServiceDB.DB.Query('SELECT id FROM collections WHERE name = ' + QuotedStr(NewCollName) + ' COLLATE NOCASE');
    if Length(Res) = 0 then
    begin
      NewID := NewMonoLexID;
      FServiceDB.DB.Exec('INSERT INTO collections (id, name) VALUES (' + QuotedStr(NewID) + ',' + QuotedStr(NewCollName) + ')');
      LoadCollections;
      SelectCollectionByID(NewID);
    end else MessageDlg('Validation Error', 'A collection with this name already exists.', mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmAppBase.btnTriggerAddClick(Sender: TObject);
var
  N, T, D, C: String;
  CurrentCollID, TargetCollID: String;
  Data: PCollectionData;
  NewID: String;
begin
  CurrentCollID := COLLECTION_ALL_ID;
  if vstCollection.GetFirstSelected <> nil then
  begin
    Data := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
    CurrentCollID := Data^.ID;
  end;

  N := ''; T := ''; D := ''; C := '';

  if CurrentCollID <> COLLECTION_ALL_ID then
    C := CurrentCollID;

  if TfrmDialogDefinition.Execute(FServiceDB.DB, 'New Trigger', '', N, T, D, C) then
  begin
    NewID := NewMonoLexID;
    FServiceDB.DB.Exec('INSERT INTO definitions (id, collection_id, name, trigger_word, definition_text) VALUES (' + QuotedStr(NewID) + ',' + QuotedStr(C) + ',' + QuotedStr(N) + ',' + QuotedStr(T) + ',' + QuotedStr(D) + ')');

    if CurrentCollID = COLLECTION_ALL_ID then
      TargetCollID := COLLECTION_ALL_ID
    else
      TargetCollID := C;

    LoadCollections;
    SelectCollectionByID(TargetCollID);
    SelectTriggerByID(NewID);

    GlobalEngine.Stop;
    FResolver.RebuildIndex;
    GlobalEngine.BufferReset;
    GlobalEngine.Start;
  end;
end;

procedure TfrmAppBase.btnTriggerEditClick(Sender: TObject);
var
  N, T, D, C, ID: String;
  Res: TDBResult;
  Data: PTriggerData;
  CurrentCollID, TargetCollID: String;
  CollData: PCollectionData;
begin
  if vstTrigger.SelectedCount <> 1 then
  begin
    MessageDlg('Selection Error', 'Please select a trigger to edit.', mtWarning, [mbOK], 0);
    Exit;
  end;

  CurrentCollID := COLLECTION_ALL_ID;
  if vstCollection.GetFirstSelected <> nil then
  begin
    CollData := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
    CurrentCollID := CollData^.ID;
  end;

  Data := vstTrigger.GetNodeData(vstTrigger.GetFirstSelected);
  ID := Data^.ID;

  Res := FServiceDB.DB.Query('SELECT name, trigger_word, definition_text, collection_id FROM definitions WHERE id = ' + QuotedStr(ID));
  if Length(Res) = 0 then Exit;

  N := Res[0][0];
  T := Res[0][1];
  D := Res[0][2];
  C := Res[0][3];

  if TfrmDialogDefinition.Execute(FServiceDB.DB, 'Edit Trigger', ID, N, T, D, C) then
  begin
    FServiceDB.DB.Exec('UPDATE definitions SET collection_id=' + QuotedStr(C) + ', name=' + QuotedStr(N) + ', trigger_word=' + QuotedStr(T) + ', definition_text=' + QuotedStr(D) + ' WHERE id=' + QuotedStr(ID));

    if CurrentCollID = COLLECTION_ALL_ID then
      TargetCollID := COLLECTION_ALL_ID
    else
      TargetCollID := C;

    LoadCollections;
    SelectCollectionByID(TargetCollID);
    SelectTriggerByID(ID);

    GlobalEngine.Stop;
    FResolver.RebuildIndex;
    GlobalEngine.BufferReset;
    GlobalEngine.Start;
  end;
end;

procedure TfrmAppBase.btnTriggerDeleteClick(Sender: TObject);
var
  Data: PTriggerData;
  Node: PVirtualNode;
  Count: Integer;
  Msg: String;
  CurrentCollID: String;
  CollData: PCollectionData;
begin
  Count := vstTrigger.SelectedCount;
  
  if Count = 0 then
  begin
    MessageDlg('Selection Error', 'Please select at least one trigger to delete.', mtWarning, [mbOK], 0);
    Exit;
  end;

  CurrentCollID := COLLECTION_ALL_ID;
  if vstCollection.GetFirstSelected <> nil then
  begin
    CollData := vstCollection.GetNodeData(vstCollection.GetFirstSelected);
    CurrentCollID := CollData^.ID;
  end;

  if Count = 1 then
    Msg := 'Are you sure you wish to delete this trigger?'
  else
    Msg := Format('Are you sure you wish to delete the %d selected triggers?', [Count]);

  if MessageDlg('Delete Trigger', Msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FServiceDB.DB.Exec('BEGIN TRANSACTION;');
    try
      Node := vstTrigger.GetFirstSelected;
      while Assigned(Node) do
      begin
        Data := vstTrigger.GetNodeData(Node);
        FServiceDB.DB.Exec('DELETE FROM definitions WHERE id = ' + QuotedStr(Data^.ID));
        Node := vstTrigger.GetNextSelected(Node);
      end;
      FServiceDB.DB.Exec('COMMIT;');
    except
      FServiceDB.DB.Exec('ROLLBACK;');
      raise;
    end;

    LoadCollections;
    SelectCollectionByID(CurrentCollID);

    GlobalEngine.Stop;
    FResolver.RebuildIndex;
    GlobalEngine.BufferReset;
    GlobalEngine.Start;
  end;
end;

end.
