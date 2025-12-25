@echo off
REM Windows batch script to create keys directory
REM This script handles the case where the path might be a file instead of a directory

if "%1"=="" (
    echo Error: No key save path provided
    exit /b 1
)

set KEY_SAVE_PATH=%1

REM Remove file if it exists with the same name as our directory
if exist "%KEY_SAVE_PATH%" (
    if not exist "%KEY_SAVE_PATH%\" (
        echo Removing file with same name as directory: %KEY_SAVE_PATH%
        del "%KEY_SAVE_PATH%"
    )
)

REM Create directory if it doesn't exist
if not exist "%KEY_SAVE_PATH%\" (
    echo Creating directory: %KEY_SAVE_PATH%
    mkdir "%KEY_SAVE_PATH%"
) else (
    echo Directory already exists: %KEY_SAVE_PATH%
)

REM Verify directory was created successfully
if exist "%KEY_SAVE_PATH%\" (
    echo Directory created/verified successfully: %KEY_SAVE_PATH%
    exit /b 0
) else (
    echo Error: Failed to create directory: %KEY_SAVE_PATH%
    exit /b 1
)