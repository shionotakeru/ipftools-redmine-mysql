@echo off
rem ----------------------------------------------------------------------------
rem    <Quantitative project management tool.>                                  
rem    Copyright (C) 2012 IPA, Japan.                                           
rem                                                                             
rem    This program is free software: you can redistribute it and/or modify     
rem    it under the terms of the GNU General Public License as published by     
rem    the Free Software Foundation, either version 3 of the License, or        
rem    (at your option) any later version.                                      
rem                                                                             
rem    This program is distributed in the hope that it will be useful,          
rem    but WITHOUT ANY WARRANTY; without even the implied warranty of           
rem    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
rem    GNU General Public License for more details.                             
rem                                                                             
rem    You should have received a copy of the GNU General Public License        
rem    along with this program.  If not, see <http://www.gnu.org/licenses/>.    
rem                                                                             
rem ----------------------------------------------------------------------------

call :SUB_DATETIME
set START_TIME=%yyyy%/%mm%/%dd% %hh%:%mi%:%ss%.%sss% [START]

rem ----------------------------------------------------------------------------
rem ���ݒ�V�F���C���N���[�h
rem ----------------------------------------------------------------------------
set BASEDIR=%~dp0
call :SUB_BATCH_BASE_DIR %BASEDIR%..\
call "%BATCH_BASE_DIR%\set-batch-env.bat"

rem ----------------------------------------------------------------------------
rem �o�b�`ID�擾
rem ----------------------------------------------------------------------------
set BAT_ID=%~n0
set BAT_UNQ_ID=%BAT_ID%


rem ----------------------------------------------------------------------------
rem �p�����[�^
rem [1] Redmine �v���W�F�N�g���ʎq
rem [2] �����r�W�����i�C��)
rem [3] �V���r�W�����i�C��)
rem ----------------------------------------------------------------------------
set PROJECT_ID=%1
set OLD_REV=%2
set NEW_REV=%3


rem ----------------------------------------------------------------------------
rem LOG_DIR : ���O�t�@�C���o�͐�
rem ----------------------------------------------------------------------------
set BATCH_FILE=%BATCH_BASE_DIR%\batch_date_file\batch_file
set BATCH_DIR=%BATCH_BASE_DIR%\batch_date_file

call :SUB_DATETIME
set TIMESTAMP=%yyyy%%mm%%dd%_%hh%%mi%%ss%_%sss%
set BATCHDATE=%yyyy%/%mm%/%dd%

if not "%PROJECT_ID%" == "" (
    set LOG_DIR=%BATCH_BASE_DIR%\log\%PROJECT_ID%
) else (
    set LOG_DIR=%BATCH_BASE_DIR%\log
)
if not exist %LOG_DIR% mkdir %LOG_DIR%
set LOG_FILE=%LOG_DIR%\%BAT_ID%_%TIMESTAMP%.log

echo %START_TIME% >> %LOG_FILE%

rem ----------------------------------------------------------------------------
rem KETTLE_HOME : KETTLE�z�[���f�B���N�g��(�f�t�H���g�̓��[�U�̃z�[���f�B���N�g��)
rem ----------------------------------------------------------------------------
set KETTLE_HOME=%BATCH_BASE_DIR%\pentaho
set KETTLE_PROP_FILE=%KETTLE_HOME%\.kettle\kettle.properties


rem ----------------------------------------------------------------------------
rem RUNJAVA : Java �R�}���h
rem ----------------------------------------------------------------------------
set RUNJAVA=%JAVA_HOME%\bin\java.exe


rem ----------------------------------------------------------------------------
rem CLASSPATH �ݒ�
rem ----------------------------------------------------------------------------
set CLASSPATH=%BASE_DIR%
set CLASSPATH=%CLASSPATH%;%BATCH_BASE_DIR%\commonJ
for %%i in (%BATCH_BASE_DIR%\commonJ\lib\*.jar) do call :SUB_SET_CLASSPATH %%i


rem ----------------------------------------------------------------------------
rem �R�}���h�p�����[�^����
rem ----------------------------------------------------------------------------
set CMD_LINE_ARGS=
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %PROJECT_ID%
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %OLD_REV%
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %NEW_REV%


rem ----------------------------------------------------------------------------
rem �o�b�`���s
rem ----------------------------------------------------------------------------
set MAINCLASS=jp.go.ipa.ipf.sourcescale.SourceScaleCountRedmineGit

rem echo Using RUNJAVA                 : %RUNJAVA%
rem echo Using CLASSPATH               : %CLASSPATH%
rem echo Using MAINCLASS               : %MAINCLASS%
rem echo Using CMD_LINE_ARGS           : %CMD_LINE_ARGS%
rem echo Using KETTLE_PROP_FILE        : %KETTLE_PROP_FILE%
rem echo Using REDMINE_PROJECT_ROOT    : %REDMINE_PROJECT_ROOT%
rem echo Using LOG_FILE                : %LOG_FILE%

%RUNJAVA% -classpath "%CLASSPATH%" %MAINCLASS% %CMD_LINE_ARGS% >> %LOG_FILE%
set RTN_CD=%ERRORLEVEL%

call :SUB_DATETIME
set END_TIME=%yyyy%/%mm%/%dd% %hh%:%mi%:%ss%.%sss% [END]
echo %END_TIME% >> %LOG_FILE%

rem echo RTN_CD:%RTN_CD%
exit %RTN_CD%


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

:SUB_SET_CLASSPATH
set CLASSPATH=%CLASSPATH%;%1
exit /b 0

