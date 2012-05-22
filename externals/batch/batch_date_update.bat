@echo off

rem ----------------------------------------------------------------------------
rem 環境設定シェルインクルード
rem ----------------------------------------------------------------------------
set BATCH_BASE_DIR=%~dp0
call "%BATCH_BASE_DIR%\set-batch-env.bat"

rem ----------------------------------------------------------------------------
rem バッチID取得
rem ----------------------------------------------------------------------------
set BAT_ID=%~n0
set BAT_UNQ_ID=%BAT_ID%

rem ----------------------------------------------------------------------------
rem Kettle ジョブファイル名
rem ----------------------------------------------------------------------------
set JOB_FILES=P002.kjb

rem ----------------------------------------------------------------------------
rem LOG_LEVEL : ログレベル
rem  Error    : Only show errors
rem  Nothing  : Don't show any output
rem  Minimal  : Only use minimal logging
rem  Basic    : This is the default basic logging level
rem  Detailed : Give detailed logging output
rem  Debug    : For debugging purposes, very detailed output.
rem  Rowlevel : Logging at a row level, this can generate a lot of data.
rem ----------------------------------------------------------------------------
set LOG_LEVEL=Basic

rem ----------------------------------------------------------------------------
rem システム日付取得
rem ----------------------------------------------------------------------------
call :SUB_DATETIME
set TIMESTAMP=%yyyy%%mm%%dd%_%hh%%mi%%ss%_%sss%

rem ----------------------------------------------------------------------------
rem バッチ日付ファイル
rem ----------------------------------------------------------------------------
set BATCH_FILE=%BATCH_BASE_DIR%\batch_date_file\batch_file
set BATCH_DIR=%BATCH_BASE_DIR%\batch_date_file
if not exist %BATCH_DIR% mkdir %BATCH_DIR%

rem ----------------------------------------------------------------------------
rem RESULT_DIR : 結果ファイル出力先
rem ----------------------------------------------------------------------------
set RESULT_DIR=%BATCH_BASE_DIR%\result
if not exist %RESULT_DIR% mkdir %RESULT_DIR%

rem ----------------------------------------------------------------------------
rem LOG_DIR : ログファイル出力先
rem ----------------------------------------------------------------------------
set LOG_DIR=%BATCH_BASE_DIR%\log
if not exist %LOG_DIR% mkdir %LOG_DIR%
set LOG_FILE=%LOG_DIR%\%BAT_ID%_%TIMESTAMP%.log

rem ----------------------------------------------------------------------------
rem ERR_FILE_PATH : エラーリストファイル出力先
rem ----------------------------------------------------------------------------
set ERR_FILE_PATH=%BATCH_BASE_DIR%\errlist\%BAT_ID%
if not exist %ERR_FILE_PATH% mkdir %ERR_FILE_PATH%

rem ----------------------------------------------------------------------------
rem PENTAHO_JAVA_HOME : Pentaho 用 Java ホームディレクトリ
rem ----------------------------------------------------------------------------
if not "%JAVA_HOME%" == "" set PENTAHO_JAVA_HOME=%JAVA_HOME%

rem ----------------------------------------------------------------------------
rem KETTLE_HOME : KETTLEホームディレクトリ(デフォルトはユーザのホームディレクトリ)
rem ----------------------------------------------------------------------------
set KETTLE_HOME=%BATCH_BASE_DIR%\pentaho

rem ----------------------------------------------------------------------------
rem バッチ処理で利用するファイルのパス
rem ----------------------------------------------------------------------------
set MSG_FILE=%RESULT_DIR%\%BAT_ID%_%TIMESTAMP%.msg
set OK_FILE=%RESULT_DIR%\%BAT_UNQ_ID%.ok
set ERR_FILE=%RESULT_DIR%\%BAT_UNQ_ID%.err
set BATCH_DATE_FILE=%BATCH_FILE%

rem ----------------------------------------------------------------------------
rem 結果ファイル削除(Pentahoのファイル削除が遅いため)
rem ----------------------------------------------------------------------------
del /f %OK_FILE%
del /f %ERR_FILE%

rem ----------------------------------------------------------------------------
rem コマンドパラメータ生成
rem ----------------------------------------------------------------------------

set CMD_LINE_ARGS=

echo Using RESULT_DIR           : %RESULT_DIR%
echo Using LOG_DIR              : %LOG_DIR%
echo Using LOG_FILE             : %LOG_FILE%
echo Using PENTAHO_JAVA_HOME    : %PENTAHO_JAVA_HOME%
echo Using PENTAHO_HOME         : %PENTAHO_HOME%
echo Using EXEC_KITCHEN         : %EXEC_KITCHEN%
echo Using KETTLE_HOME          : %KETTLE_HOME%
echo Using RM_PROJECT_ROOT      : %RM_PROJECT_ROOT%
echo Using CMD_LINE_ARGS        : %CMD_LINE_ARGS%

rem ----------------------------------------------------------------------------
rem Kitchen 実行
rem ----------------------------------------------------------------------------
for %%i in (%JOB_FILES%) do (
    echo Run KETTLE_JOB_FILE : %KETTLE_HOME%\job\%%i
    call %EXEC_KITCHEN% /file:"%KETTLE_HOME%\job\%%i" %CMD_LINE_ARGS% /level:%LOG_LEVEL% >> %LOG_FILE%
    if not ERRORLEVEL 0 goto :break
)

:break

set RTN_CD=%ERRORLEVEL%

if exist %MSG_FILE% type %MSG_FILE%
if exist %MSG_FILE% del %MSG_FILE%

echo RTN_CD:%RTN_CD%
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

