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

unit StaticSQLite;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

{$link ../vendor/sqlite3/sqlite3.o}
{$linklib kernel32}
{$linklib msvcrt}
{$linklib gcc}
{$linklib mingwex}
{$linklib m}

type
  TDBRow = array of String;
  TDBResult = array of TDBRow;
  TRowCallback = procedure(const Row: array of String) of object;

  TStaticSQLite = class
  private
    FHandle: Pointer;
  public
    constructor Create(const DBPath: String);
    destructor Destroy; override;
    procedure Exec(const SQL: String);
    function Query(const SQL: String): TDBResult;
    procedure QueryProc(const SQL: String; Callback: TRowCallback);
    function GetLastInsertID: Int64;
  end;

function sqlite3_initialize(): Integer; cdecl; external name 'sqlite3_initialize';
function sqlite3_open(filename: PAnsiChar; out ppDb: Pointer): Integer; cdecl; external name 'sqlite3_open';
function sqlite3_close(db: Pointer): Integer; cdecl; external name 'sqlite3_close';
function sqlite3_exec(db: Pointer; sql: PAnsiChar; callback: Pointer; arg: Pointer; out errmsg: PAnsiChar): Integer; cdecl; external name 'sqlite3_exec';
function sqlite3_prepare_v2(db: Pointer; zSql: PAnsiChar; nByte: Integer; out ppStmt: Pointer; pzTail: Pointer): Integer; cdecl; external name 'sqlite3_prepare_v2';
function sqlite3_step(pStmt: Pointer): Integer; cdecl; external name 'sqlite3_step';
function sqlite3_column_count(pStmt: Pointer): Integer; cdecl; external name 'sqlite3_column_count';
function sqlite3_column_text(pStmt: Pointer; iCol: Integer): PAnsiChar; cdecl; external name 'sqlite3_column_text';
function sqlite3_finalize(pStmt: Pointer): Integer; cdecl; external name 'sqlite3_finalize';
function sqlite3_last_insert_rowid(db: Pointer): Int64; cdecl; external name 'sqlite3_last_insert_rowid';

implementation

const
  SQLITE_OK = 0;
  SQLITE_ROW = 100;

function __mingw_raise_matherr(typ: Integer; name: PAnsiChar; a1, a2, rslt: Double): Integer; cdecl; public name '__mingw_raise_matherr';
begin
  if typ = 0 then;
  if name = nil then;
  if a1 = 0 then;
  if a2 = 0 then;
  if rslt = 0 then;
  Result := 0;
end;

constructor TStaticSQLite.Create(const DBPath: String);
begin
  sqlite3_initialize(); 
  if sqlite3_open(PAnsiChar(DBPath), FHandle) <> SQLITE_OK then
    raise Exception.Create('Database access failed.');

  Exec('PRAGMA journal_mode=WAL;');
  Exec('PRAGMA synchronous=NORMAL;');
  Exec('PRAGMA busy_timeout=5000;');
  Exec('PRAGMA foreign_keys=ON;');
  Exec('PRAGMA mmap_size = 0;');
  Exec('PRAGMA temp_store = 1;');
  Exec('PRAGMA cache_size = -200;');
end;

destructor TStaticSQLite.Destroy;
begin
  if Assigned(FHandle) then sqlite3_close(FHandle);
  inherited;
end;

procedure TStaticSQLite.Exec(const SQL: String);
var 
  Err: PAnsiChar;
begin
  Err := nil;
  sqlite3_exec(FHandle, PAnsiChar(SQL), nil, nil, Err);
end;

function TStaticSQLite.Query(const SQL: String): TDBResult;
var
  Stmt: Pointer;
  ColCount, RowIdx, ColIdx: Integer;
begin
  Result := nil;
  SetLength(Result, 0);
  if sqlite3_prepare_v2(FHandle, PAnsiChar(SQL), -1, Stmt, nil) = SQLITE_OK then
  begin
    ColCount := sqlite3_column_count(Stmt);
    RowIdx := 0;
    while sqlite3_step(Stmt) = SQLITE_ROW do
    begin
      SetLength(Result, RowIdx + 1);
      SetLength(Result[RowIdx], ColCount);
      for ColIdx := 0 to ColCount - 1 do
        Result[RowIdx][ColIdx] := String(sqlite3_column_text(Stmt, ColIdx));
      Inc(RowIdx);
    end;
    sqlite3_finalize(Stmt);
  end;
end;

procedure TStaticSQLite.QueryProc(const SQL: String; Callback: TRowCallback);
var
  Stmt: Pointer;
  ColCount, ColIdx: Integer;
  Row: array of String;
begin
  Row := nil;
  if sqlite3_prepare_v2(FHandle, PAnsiChar(SQL), -1, Stmt, nil) = SQLITE_OK then
  begin
    ColCount := sqlite3_column_count(Stmt);
    SetLength(Row, ColCount);
    while sqlite3_step(Stmt) = SQLITE_ROW do
    begin
      for ColIdx := 0 to ColCount - 1 do
        Row[ColIdx] := String(sqlite3_column_text(Stmt, ColIdx));
      if Assigned(Callback) then Callback(Row);
    end;
    sqlite3_finalize(Stmt);
  end;
end;

function TStaticSQLite.GetLastInsertID: Int64;
begin
  Result := sqlite3_last_insert_rowid(FHandle);
end;

end.