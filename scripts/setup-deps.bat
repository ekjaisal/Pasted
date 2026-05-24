@echo off
setlocal EnableDelayedExpansion

echo Fetching latest SQLite3 amalgamation...

set "SQLITE-URL=https://www.sqlite.org"
set "SQLITE-TEMP-ZIP=%TEMP%\sqlite3-amalgamation.zip"
set "SQLITE-TEMP-DIR=%TEMP%\sqlite3-extract"

set "SQLITE-RELATIVE-URL="
if not exist "..\deps" mkdir "..\deps"
for /f "tokens=3 delims=," %%A in ('curl -s "%SQLITE-URL%/download.html" ^| findstr /i "sqlite-amalgamation-.*\.zip"') do (
    if "!SQLITE-RELATIVE-URL!"=="" set "SQLITE-RELATIVE-URL=%%A"
)

if "!SQLITE-RELATIVE-URL!"=="" (
    echo ERROR: Could not find amalgamation URL in SQLite download page.
    pause
    exit /b 1
)

set "SQLITE-DOWNLOAD-URL=%SQLITE-URL%/!SQLITE-RELATIVE-URL!"
echo Downloading: !SQLITE-DOWNLOAD-URL!

curl -L "!SQLITE-DOWNLOAD-URL!" -o "%SQLITE-TEMP-ZIP%"
if %errorlevel% neq 0 (
    echo ERROR: Download failed.
    del /q "%SQLITE-TEMP-ZIP%" 2>nul
    pause
    exit /b 1
)

if exist "%SQLITE-TEMP-DIR%" rmdir /s /q "%SQLITE-TEMP-DIR%"
mkdir "%SQLITE-TEMP-DIR%"
tar -xf "%SQLITE-TEMP-ZIP%" -C "%SQLITE-TEMP-DIR%"
if %errorlevel% neq 0 (
    echo ERROR: Extraction failed.
    del /q "%SQLITE-TEMP-ZIP%" 2>nul
    pause
    exit /b 1
)

set "SQLITE-AMALGAMATION-DIR="
for /d %%D in ("%SQLITE-TEMP-DIR%\sqlite-amalgamation-*") do set "SQLITE-AMALGAMATION-DIR=%%D"

copy /y "!SQLITE-AMALGAMATION-DIR!\sqlite3.c" ".\sqlite3.c" >nul
copy /y "!SQLITE-AMALGAMATION-DIR!\sqlite3.h" ".\sqlite3.h" >nul

del /q "%SQLITE-TEMP-ZIP%" 2>nul
rmdir /s /q "%SQLITE-TEMP-DIR%" 2>nul

echo Compiling SQLite3 for Windows x86-64...

gcc -c sqlite3.c -O2 -ffunction-sections -fdata-sections ^
    -DSQLITE_THREADSAFE=1 ^
    -DSQLITE_OMIT_LOAD_EXTENSION ^
    -DSQLITE_OMIT_DEPRECATED ^
    -DSQLITE_OMIT_SHARED_CACHE ^
    -DSQLITE_OMIT_AUTOINIT ^
    -DSQLITE_OMIT_DECLTYPE ^
    -DSQLITE_OMIT_PROGRESS_CALLBACK ^
    -DSQLITE_OMIT_AUTHORIZATION ^
    -DSQLITE_OMIT_COMPLETE ^
    -DSQLITE_OMIT_EXPLAIN ^
    -DSQLITE_OMIT_TRACE ^
    -DSQLITE_OMIT_BLOB_LITERAL ^
    -DSQLITE_OMIT_COMPOUND_SELECT ^
    -DSQLITE_OMIT_GENERATED_COLUMNS ^
    -DSQLITE_OMIT_UPSERT ^
    -DSQLITE_OMIT_COMPILEOPTION_DIAGS ^
    -DSQLITE_OMIT_JSON ^
    -DSQLITE_DEFAULT_MEMSTATUS=0 ^
    -DSQLITE_DQS=0 ^
    -DSQLITE_MAX_EXPR_DEPTH=0 ^
    -DSQLITE_LIKE_DOESNT_MATCH_BLOBS ^
    -o ../deps/sqlite3.o

if %errorlevel% neq 0 (
    echo ERROR: Compilation failed.
    del /q sqlite3.c sqlite3.h 2>nul
    pause
    exit /b 1
)

del /q sqlite3.c sqlite3.h 2>nul

echo Done. sqlite3.o is available in ../deps/.
pause