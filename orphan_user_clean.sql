IF OBJECT_ID('tempdb.dbo.#cleanup') IS NOT NULL
  DROP TABLE #cleanup

CREATE TABLE #cleanup (
    database_name sysname,
    user_name sysname,
    tsql nvarchar(max)
  )

DECLARE @tsql NVARCHAR(max)

SET @tsql = 'USE ?;
  INSERT INTO #cleanup
  SELECT DB_NAME()
      , u.[name]
      , ''USER '' + QUOTENAME(DB_NAME()) + ''; DROP USER '' + QUTOENAME(u.[name]) AS tsql
  FROM master.dbo.syslogins l
  RIGHT OUTER JOIN sysusers u ON l.sid = u.sid
  WHERE l.sid IS NULL
  AND isSqlRole <> 1
  AND isAppRole <> 1
  AND u.[name] NOT IN (''guest'', ''INFORMATION_SCHEMA'', ''SYS'')''

EXEC master.dbo.sp_msforeachdb @tsql

SELECT *
FROM #cleanup

DROP TABLE #cleanup  
