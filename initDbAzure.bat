@echo off

REM Initialize variables
set "server_name="
set "database_name="
set "user_name="
set "password="

REM Parse command-line arguments
:parse_args
IF "%~1"=="" GOTO end_parse_args

IF /I "%~1"=="-S" (
    SET "server_name=%~2"
    SHIFT
) ELSE IF /I "%~1"=="-D" (
    SET "database_name=%~2"
    SHIFT
) ELSE IF /I "%~1"=="-U" (
    SET "user_name=%~2"
    SHIFT
)

SHIFT
GOTO parse_args
:end_parse_args

REM Check if required parameters are provided
IF "%server_name%"=="" (
    echo Error: Server name ^(-S^) is required.
    GOTO usage
)

IF "%database_name%"=="" (
    echo Error: Database name ^(-D^) is required.
    GOTO usage
)

REM If the -U parameter is provided, prompt for the password using -P
IF NOT "%user_name%"=="" (
    SET /P "password=Enter password for user %user_name%: "
)




REM Construct the sqlcmd command string variable without empty variables
set "user-name-password="

REM Add the -U option if username is not empty
if not "%user_name%"=="" set "user-name-password=-U %user_name% -P %password%"

:main_script
start "" /B cmd /c "az login && echo Done>login_complete.tmp"

REM Wait until the login_complete.tmp file is created, indicating 'az login' has finished.
:wait_loop1
if not exist login_complete.tmp (
    timeout /t 1 /nobreak >nul
    goto wait_loop1
)
del "login_complete.tmp"

start "" /B cmd /c "az sql db create -n %database_name% -s azure-server -g appsvc_linux_Sweden -e Basic && echo Done>createDb_complete.tmp"

REM Wait until the createDb_complete.tmp file is created, indicating 'az login' has finished.
:wait_loop2
if not exist createDb_complete.tmp (
    timeout /t 1 /nobreak >nul
    goto wait_loop2
)
del "createDb_complete.tmp"






set "sqlScripts=Color Column Row FigureType Figure BoardConfiguration BoardConfigurationToFigure Game NotationLog"
set "sqlData=Color Column Row FigureType Figure BoardConfiguration BoardConfigurationToFigure"

for %%f in (%sqlScripts%) do (
	sqlcmd -S %server_name% %user-name-password% -d %database_name% -i "sql-scripts/%%f.sql"
)

for %%f in (%sqlData%) do (
	sqlcmd -S %server_name% %user-name-password% -d %database_name% -i "sql-data/%%f.sql"
)



GOTO :EOF




:usage
echo.
echo Usage: script_with_parameters.bat -S server_name -D database_name [-U user_name]
echo.
echo   -S     Specifies the SQL Server name.
echo   -D     Specifies the database name.
echo   -U     Specifies the user name (optional). If provided, the script will prompt for the password using -P.
echo.
echo Common usage examle: ./initDbAzure -S azure-server.database.windows.net -D ChessDb -U mrevening
echo Common errors: Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Cannot open server 'azure-server' requested by the login. Client with IP address '' is not allowed to access the server.  To enable access, use the Azure Management Portal or run sp_set_firewall_rule on the master database to create a firewall rule for this IP address or address range.  It may take up to five minutes for this change to take effect..
echo Solution: log in to ssms 
echo Common error: Msg 2714, Level 16, State 6, Server azure-server, Line 2 There is already an object named 'Color' in the database.
echo Solution: db already exists
GOTO :EOF