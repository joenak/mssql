------------------------------------------------------------
--kill by db
------------------------------------------------------------
USE [master]
DECLARE @dbname sysname = 'database1'
DECLARE @kill varchar(max) = ''

SELECT @kill = @kill + 'kill ' + CONVERT(VARCHAR(5), session_id) + ';'
FROM sys.dm_exec_sessions
WHERE database_id = db_id(@dbname)
AND session_id > 50
AND is_user_process = 1

--EXEC(@kill)

------------------------------------------------------------
--kill all
------------------------------------------------------------
USE [master]
DECLARE @dbname sysname = 'database1'
DECLARE @kill varchar(max) = ''

SELECT @kill = @kill + 'kill ' + CONVERT(VARCHAR(5), session_id) + ';'
FROM sys.dm_exec_sessions
WHERE session_id > 50
AND status = 'sleeping'
AND is_user_process = 1

--EXEC(@kill)
