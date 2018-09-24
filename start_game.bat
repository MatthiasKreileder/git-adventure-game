@echo off
::
:: Copyright 2018 Bloomberg Finance L.P.
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
::


:: The purpose of this script is to install the 'git hook' scripts and
:: put the user int the initial branch.

set DIR=%~dp0

copy %DIR%\.game_data\hooks\* %DIR%\.git\hooks\ >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Could not setup hooks!
    exit /b 1
)

:: We need to create another repository that we can remote to.  Ask the user
:: for an appropriate place to locate this repository.
cls && more %DIR%\.game_data\start_game.txt

:loop
call :get_user_folder folder || goto loop

mkdir %DIR%\.game_data\state >nul 2>&1
if not exist %DIR%\.game_data\state (
    echo ERROR: Could not setup game state storage!
    exit /b 1
)

if exist %DIR%\.game_data\state\spare_folder (
    del %DIR%\.game_data\state\spare_folder >nul 2>&1
)
echo %folder% > %DIR%\.game_data\state\spare_folder
if %errorlevel% neq 0 (
    echo ERROR: Could not setup game state!
    exit /b 1
)

echo.
echo Thank you for your patience!  The forest gates creaks slowly open...
echo.
timeout 4
cls

git checkout 00_enter_the_forest
goto :eof

:: Obtains a folder outside the repository from the user for us to store some
:: additional data in.
:get_user_folder
pushd %DIR%\..
set default_folder=%CD%\git-adventure-data
popd

set /P folder="Directory [%default_folder%]: "
if [%folder%] == [] set folder=%default_folder%

echo.%folder%|findstr /I ^%DIR%
if %errorlevel% equ 0 (
    echo Folder may not be a subdirectory of this repository!
    echo Please try again...
    set folder=
    exit /b 1
)

if exist %folder% (
    echo ERROR: Folder [%folder%] already exist!
    echo Please try again...
    set folder=
    exit /b 1
)

mkdir "%folder%" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Could not create folder [%folder%]!
    echo Please try again...
    set folder=
    exit /b 1
)

set %1=%folder%
goto :eof
