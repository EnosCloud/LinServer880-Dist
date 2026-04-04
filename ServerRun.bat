@ECHO OFF
setlocal EnableExtensions
chcp 65001 >nul
COLOR 17

set "JAVA_CMD=%~1"
if not defined JAVA_CMD set "JAVA_CMD=java"

set "L1J_RAM=-server -Xms16384m -Xmx16384m -Xmn6144m -XX:MaxGCPauseMillis=50"
set "L1J_TIME=-Duser.timezone=Asia/Taipei"
set "L1J_PATH=-cp Server_Game.jar;jar\commons-logging-1.1.1.jar;jar\javolution-5.5.1.jar;jar\slf4j-reload4j-2.0.3.jar;jar\reload4j-1.2.26.jar;jar\mariadb-java-client-3.0.6.jar;jar\HikariCP-4.0.3.jar;jar\slf4j-api-2.0.3.jar;jar\netty-buffer-4.1.131.Final.jar;jar\netty-codec-4.1.131.Final.jar;jar\netty-common-4.1.131.Final.jar;jar\netty-handler-4.1.131.Final.jar;jar\netty-resolver-4.1.131.Final.jar;jar\netty-transport-4.1.131.Final.jar;jar\protobuf-3.21.7.jar;tools\quest_recover_classes com.lineage.Server"

:check_update
if exist update\Server_Game.jar goto move_zip
goto run_server

:move_zip
echo 偵測到更新包，正在套用更新...
del Server_Game.jar
move /Y update\Server_Game.jar Server_Game.jar >nul
goto run_server

:run_server
echo 伺服器即將啟動...
"%JAVA_CMD%" %L1J_RAM% %L1J_TIME% %L1J_PATH%
cls
goto check_update
