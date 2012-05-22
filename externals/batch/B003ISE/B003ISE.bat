@echo off

rem ----------------------------------------------------------------------------
rem 環境設定シェルインクルード
rem ----------------------------------------------------------------------------
set BASEDIR=%~dp0
call :SUB_BATCH_BASE_DIR %BASEDIR%..\
call "%BATCH_BASE_DIR%\set-batch-env.bat"

rem ----------------------------------------------------------------------------
rem パラメータ
rem [1] Trac プロジェクトID
rem ----------------------------------------------------------------------------
set PROJECT_ID=%1
if "%PROJECT_ID%" == "" (
    echo Arguments ProjectID is required.
    exit /b 1
)
set PROJECT_DIR=%RM_PROJECT_ROOT%\%PROJECT_ID%

rem ----------------------------------------------------------------------------
rem バッチ実行
rem ----------------------------------------------------------------------------
set ERR_FLAG=0

call %BATCH_BASE_DIR%\B004IOE\B004IOE_1.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_2.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_3.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_4.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_5.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_6.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_7.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_8.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

call %BATCH_BASE_DIR%\B004IOE\B004IOE_9.bat %PROJECT_ID%
if not %ERRORLEVEL% == 0 set ERR_FLAG=1

if %ERR_FLAG% == 0 (
	set RTN_CD=0
) else (
	set RTN_CD=1
)

exit /b %RTN_CD%


:SUB_DATETIME
set date_tmp=%date:/=%
set time_tmp=%time: =0%
set yyyy=%date_tmp:~0,4%
set yy=%date_tmp:~2,2%
set mm=%date_tmp:~4,2%
set dd=%date_tmp:~6,2%
set hh=%time_tmp:~0,2%
set mi=%time_tmp:~3,2%
set ss=%time_tmp:~6,2%
set sss=%time_tmp:~9,2%
set datetime=%yyyy%%mm%%dd%%hh%%mi%%ss%%sss%
set time_tmp=
set date_tmp=
exit /b 0

:SUB_BATCH_BASE_DIR
set BATCH_BASE_DIR=%~dp1
exit /b 0
