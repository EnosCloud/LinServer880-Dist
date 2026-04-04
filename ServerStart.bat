@ECHO OFF
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
COLOR 17

if /i "%~1"=="--elevated" shift

timeout /t 1 /nobreak >nul
cls
goto begin

:check_update
if exist update\Server_Game.jar goto move_zip
goto begin

:move_zip
echo 偵測到更新包，正在套用更新...
del Server_Game.jar
move /Y update\Server_Game.jar Server_Game.jar
goto begin

:begin
title 880TEST - LinServer880 伺服器啟動

net session >nul 2>&1
if not "%errorlevel%"=="0" (
	echo 目前沒有管理員權限。
	choice /c YN /m "是否要立即提升為管理員權限"
	if errorlevel 2 (
		echo 已取消提升，批次檔將結束。
		pause >nul
		exit /b 1
	)
	powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList '--elevated' -WorkingDirectory '%~dp0'"
	exit /b
)

set "JAVA_CMD="
set "JAVA_VERSION="
for /f "tokens=3" %%V in ('java -version 2^>^&1 ^| findstr /i /c:"version"') do (
	set "JAVA_VERSION=%%~V"
)

if defined JAVA_VERSION if "!JAVA_VERSION:~0,2!"=="21" (
	set "JAVA_CMD=java"
)

if defined JAVA_CMD (
	echo 已找到 Java 21：!JAVA_VERSION!
	echo 支援的發行版包含 Eclipse Adoptium、Oracle 等，只要版本為 21 即可。
	echo 此環境符合專案需求，按任意鍵開始執行專案...
	pause >nul
) else (
	if defined JAVA_VERSION (
		echo 目前偵測到的 Java 版本為：!JAVA_VERSION!
		echo 此環境不符合專案需求，請安裝或切換至 Java 21 後再重新執行。
	) else (
		echo 未找到可用的 Java 指令，請先安裝 Java 21。
	)
	pause >nul
	exit /b 1
)

set "L1J_RAM=-server -Xms16384m -Xmx16384m -Xmn6144m -XX:MaxGCPauseMillis=50"
set "L1J_TIME=-Duser.timezone=Asia/Taipei"
set "L1J_PATH=-cp Server_Game.jar;jar\commons-logging-1.1.1.jar;jar\javolution-5.5.1.jar;jar\slf4j-reload4j-2.0.3.jar;jar\reload4j-1.2.26.jar;jar\mariadb-java-client-3.0.6.jar;jar\HikariCP-4.0.3.jar;jar\slf4j-api-2.0.3.jar;jar\netty-buffer-4.1.131.Final.jar;jar\netty-codec-4.1.131.Final.jar;jar\netty-common-4.1.131.Final.jar;jar\netty-handler-4.1.131.Final.jar;jar\netty-resolver-4.1.131.Final.jar;jar\netty-transport-4.1.131.Final.jar;jar\protobuf-3.21.7.jar;tools\quest_recover_classes com.lineage.Server"

echo 伺服器即將啟動...
"%JAVA_CMD%" %L1J_RAM% %L1J_TIME% %L1J_PATH%

cls
goto check_update
