@ECHO OFF
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
COLOR 17
pushd "%~dp0"

if /i "%~1"=="--elevated" shift

timeout /t 1 /nobreak >nul
cls
goto begin

:begin
title LinServer880 伺服器啟動

net session >nul 2>&1
if not "%errorlevel%"=="0" (
	echo 目前沒有管理員權限。
	choice /c YN /m "是否要立即提升為管理員權限"
	if errorlevel 2 (
		echo 已取消提升，批次檔將結束。
		pause >nul
		exit /b 1
	)
	powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:ComSpec -Verb RunAs -ArgumentList '/c','""%~f0"" --elevated' -WorkingDirectory '%~dp0'"
	exit /b
)

set "JAVA_CMD=java"
set "JAVA_VERSION="
for /f "tokens=3" %%V in ('java -version 2^>^&1 ^| findstr /i /c:"version"') do (
	set "JAVA_VERSION=%%~V"
)
set "JAVA_VERSION=!JAVA_VERSION:"=!"

if not defined JAVA_VERSION (
	echo 未找到可用的 Java 指令，請先安裝 Java 21。
	pause >nul
	exit /b 1
)


if "!JAVA_VERSION:~0,2!"=="21" (
	echo 已找到 Java 21：!JAVA_VERSION!
	echo 支援的發行版包含 Eclipse Adoptium、Oracle 等，只要版本為 21 即可。
	echo 此環境符合專案需求，按任意鍵開始執行專案...
	pause >nul
) else (
	echo 目前偵測到的 Java 版本為：!JAVA_VERSION!
	echo 此環境不符合 Java 21，是否仍要繼續執行。
	choice /c YN /m "按 Y 繼續啟動，按 N 取消"
	if errorlevel 2 (
		echo 已取消啟動。
		pause >nul
		exit /b 1
	)
)

echo 交由 ServerRun.bat 啟動伺服器循環...
call "%~dp001-ServerRun.bat" "%JAVA_CMD%"
exit /b %errorlevel%
