@echo off

rem ----------------------------------------------------------------------------
rem ���ݒ�V�F���C���N���[�h
rem ----------------------------------------------------------------------------
set BATCH_BASE_DIR=%~dp0

rem ----------------------------------------------------------------------------
rem LOG_DIR : ���O�t�@�C���o�͐�
rem ----------------------------------------------------------------------------
call :SUB_DATETIME
set TIMESTAMP=%yyyy%%mm%%dd%_%hh%%mi%%ss%_%sss%

set LOG_DIR=%BATCH_BASE_DIR%\log
if not exist %LOG_DIR% mkdir %LOG_DIR%
set LOG_FILE=%LOG_DIR%\ipf_data_collect_%TIMESTAMP%.log

rem ----------------------------------------------------------------------------
rem �G���[�t���O
rem ----------------------------------------------------------------------------
SET ERR_FLAG=0

rem ----------------------------------------------------------------------------
rem project_a �̃f�[�^���W
rem ----------------------------------------------------------------------------
call %BATCH_BASE_DIR%\B001ROE\B001ROE_1.bat project_a >> %LOG_FILE%
if %ERRORLEVEL% == 0 (
	call %BATCH_BASE_DIR%\B003ISE\B003ISE.bat project_a >> %LOG_FILE%
)
if not %ERRORLEVEL% == 0 (
	SET ERR_FLAG=1
)

rem ----------------------------------------------------------------------------
rem project_b �̃f�[�^���W
rem ----------------------------------------------------------------------------
rem call %BATCH_BASE_DIR%\B001ROE\B001ROE_1.bat project_b >> %LOG_FILE%
rem if %ERRORLEVEL% == 0 (
rem 	call %BATCH_BASE_DIR%\B003ISE\B003ISE.bat project_b >> %LOG_FILE%
rem )
rem if not %ERRORLEVEL% == 0 (
rem 	SET ERR_FLAG=1
rem )


rem ----------------------------------------------------------------------------
rem �o�b�`���t�t�@�C���X�V
rem ----------------------------------------------------------------------------
if %ERR_FLAG% == 0 (
	call %BATCH_BASE_DIR%\batch_date_update.bat >> %LOG_FILE%
	if not %ERRORLEVEL% == 0 (
		SET ERR_FLAG=1
	)
)

set RTN_CD=%ERR_FLAG%
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

