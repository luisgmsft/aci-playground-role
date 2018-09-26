 REM ***** Set script start timestamp *****
 set timehour=%time:~0,2%
 set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%-%timehour: =0%%time:~3,2%
 set "log=install.cmd started %timestamp%."

 REM ***** Needed to correctly install OLEDB x64, otherwise you may see an out of disk space error *****
 set TMP=%PathToOLEDBSetup%
 set TEMP=%PathToOLEDBSetup%

 REM ***** Setup OLEDB Setup filename *****
 set "oledbsetupfile=AccessDatabaseEngine_X64.exe"
 goto logtimestamp

 :logtimestamp
 REM ***** Setup LogFile with timestamp *****
 md "%PathToOLEDBSetup%\log"
 set startuptasklog="%PathToOLEDBSetup%log\startuptasklog-%timestamp%.txt"
 set oledbsetuplog="%PathToOLEDBSetup%log\OLEDBSetupLog-%timestamp%.txt"
 echo %log% >> %startuptasklog%
 echo ComputeEmulatorRunning set to: %ComputeEmulatorRunning% >> %startuptasklog%
 echo Logfile generated at: %startuptasklog% >> %startuptasklog%
 echo %log% >> %oledbsetuplog%
 echo Logfile generated at: %oledbsetuplog% >> %startuptasklog%
 echo TMP set to: %TMP% >> %startuptasklog%
 echo TEMP set to: %TEMP% >> %startuptasklog%

 REM ***** Installing OLEDB x64 *****
 echo Installing .NET with commandline: start /wait %~dp0%oledbsetupfile% /passive%  /chainingpackage "CloudService Startup Task" >> %startuptasklog%
 start /wait %~dp0%oledbsetupfile% 
/extract:%PathToOLEDBSetup%\log /passive /quiet /log:%oledbsetuplog%  "CloudService Startup Task" >> %startuptasklog% 2>>&1
 if %ERRORLEVEL%== 0 goto end
     echo OLEDB x64 installer exited with code %ERRORLEVEL% >> %startuptasklog%    

 :end
 echo install.cmd completed: %date:~-4,4%%date:~-10,2%%date:~-7,2%-%timehour: =0%%time:~3,2% >> %startuptasklog%

 :exit
 EXIT /B 0