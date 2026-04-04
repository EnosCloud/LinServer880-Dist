@ECHO OFF
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
COLOR 17

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

set "JAVA_CMD="
set "JAVA_VERSION="
for /f "delims=" %%J in ('where java 2^>nul') do (
	for /f "tokens=3" %%V in ('"%%J" -version 2^>^&1 ^| findstr /i /c:"version"') do (
		set "JAVA_VERSION=%%~V"
	)
	if defined JAVA_VERSION (
		if "!JAVA_VERSION:~0,2!"=="21" (
			set "JAVA_CMD=%%J"
			goto java_found
		)
	)
	set "JAVA_VERSION="
)

:java_found
if defined JAVA_CMD (
	echo 已找到 Java 21：!JAVA_VERSION!
	echo 支援的發行版包含 Eclipse Adoptium、Oracle 等，只要版本為 21 即可。
	echo 此環境符合專案需求，按任意鍵開始執行專案...
	pause >nul
) else (
	echo 未找到符合專案需求的 Java 21 環境 [請安裝 Java 21 後再重新啟動]
	echo 支援的發行版包含 Eclipse Adoptium、Oracle 等，只要版本為 21 即可。
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
