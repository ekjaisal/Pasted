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

unit ServiceDatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StaticSQLite, MonoLexID;

type
  TServiceDatabase = class
  private
    FDB: TStaticSQLite;
    procedure EnsureSchema;
    procedure CleanupOldBackups;
  public
    constructor Create;
    destructor Destroy; override;
    property DB: TStaticSQLite read FDB;
  end;

implementation

constructor TServiceDatabase.Create;
var
  DBPath, ConfigDir: String;
begin
  inherited Create;
  ConfigDir := GetAppConfigDir(False);
  if not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  DBPath := IncludeTrailingPathDelimiter(ConfigDir) + 'Pasted.db';

  FDB := TStaticSQLite.Create(DBPath);
  EnsureSchema;
  CleanupOldBackups;
end;

destructor TServiceDatabase.Destroy;
begin
  if Assigned(FDB) then
  begin
    FDB.Exec('PRAGMA wal_checkpoint(TRUNCATE);');
    FDB.Exec('PRAGMA optimize;');
    FDB.Exec('VACUUM;');
    FDB.Exec('PRAGMA journal_mode=DELETE;');
    FDB.Free;
  end;
  inherited Destroy;
end;

procedure TServiceDatabase.EnsureSchema;
var
  Res: TDBResult;
begin
  FDB.Exec('CREATE TABLE IF NOT EXISTS collections (id TEXT PRIMARY KEY, name TEXT UNIQUE COLLATE NOCASE, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);');
  FDB.Exec('CREATE TABLE IF NOT EXISTS definitions (id TEXT PRIMARY KEY, collection_id TEXT, name TEXT, trigger_word TEXT UNIQUE COLLATE NOCASE, definition_text TEXT, last_triggered DATETIME, trigger_count INTEGER DEFAULT 0, FOREIGN KEY(collection_id) REFERENCES collections(id) ON DELETE CASCADE);');

  FDB.Exec('CREATE INDEX IF NOT EXISTS idx_def_monolexid ON definitions(id);');
  FDB.Exec('CREATE INDEX IF NOT EXISTS idx_def_collection_id ON definitions(collection_id);');

  FDB.Exec('CREATE INDEX IF NOT EXISTS idx_def_name ON definitions(name);');
  FDB.Exec('CREATE INDEX IF NOT EXISTS idx_def_trigger_word ON definitions(trigger_word);');
  FDB.Exec('CREATE INDEX IF NOT EXISTS idx_def_last_triggered ON definitions(last_triggered);');

  Res := FDB.Query('SELECT COUNT(*) FROM collections');
  if (Length(Res) > 0) and (StrToIntDef(Res[0][0], 0) = 0) then
    FDB.Exec('INSERT INTO collections (id, name) VALUES (' + QuotedStr(NewMonoLexID) + ', ''Default'');');
end;

procedure TServiceDatabase.CleanupOldBackups;
var
  SearchRec: TSearchRec;
  Dir: String;
  FileList: TStringList;
  i: Integer;
begin
  Dir := IncludeTrailingPathDelimiter(GetAppConfigDir(False));
  FileList := TStringList.Create;
  try
    if FindFirst(Dir + 'Pasted.db.bak_*', faAnyFile, SearchRec) = 0 then
    begin
      repeat
        FileList.Add(Dir + SearchRec.Name);
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;

    FileList.Sort;

    if FileList.Count > 5 then
    begin
      for i := 0 to FileList.Count - 6 do
        DeleteFile(FileList[i]);
    end;
  finally
    FileList.Free;
  end;
end;

end.