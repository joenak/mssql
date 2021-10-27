SELECT
  s.[name] as schemaName
  , t.[name] as tableName
  , c.[name] as columnName
  , c.sytem_type_id as columnDataType
  , c.seed_value as identitySeed
  , c.increment_value as identityIncrement
  , c.last_value as last_value
  , 'DBCC CHECKIDENT(''' + s.[name] + '.' + t.[name] + ''', reseed, '
      + CONVERT(VARCHAR, ISNULL(CONVERT(BIGINT, c.last_value), 1) + 1000000) + ')' as tsqlCmd
FROM sys.identity_columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id




SELECT
  'DBCC CHECKIDENT(''Meta.' + a.tableName + ''', reseed, 1)' as tsqlCmd
FROM
  (
    SELECT
      t.[name] as tableName
      , p.rows as rowCount
    FROM sys.tables t
    INNER JOIN sys.partitions p ON t.object_id = p.object_id
    WHERE t.name LIKE 'SequenceClass%'
    AND t.is_ms_shipped = 0
    AND p.rows = 0
    GROUP BY t.[name], p.rows
  ) a
