@echo off
echo Compiling SQLite3 for Windows x86_64...

gcc -c sqlite3.c -O2 -ffunction-sections -fdata-sections -DSQLITE_THREADSAFE=1 -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_OMIT_DEPRECATED -DSQLITE_OMIT_SHARED_CACHE -DSQLITE_OMIT_AUTOINIT -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_DQS=0 -DSQLITE_OMIT_DECLTYPE -DSQLITE_OMIT_PROGRESS_CALLBACK -DSQLITE_OMIT_AUTHORIZATION -o sqlite3.o

if %errorlevel% neq 0 (
    echo.
    echo Compilation failed!
    pause
    exit /b %errorlevel%
)

echo.
echo Compilation successful! sqlite3.o is ready.
pause