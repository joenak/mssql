SELECT
  i.object_id
  , OBJECT_NAME(i.object_id) as tableName
  , OBJECT_SCHEMA_NAME(i.object_id) as schemaName
  , i.name as indexName
  , s.user_updates
  , s.user_seeks
  , s.user_scans
  , s.user_lookups
  , i.index_id
  , CASE
      WHEN s.user_updates = 0 THEN 0
      ELSE CONVERT(DECIMAL(18,2), (s.user_seeks + s.user_scans + s.user_loolups)) / CONVERT(DECIMAL(18,2), s.user_updates)
    END
  , z.index_size_kb
  , CONVERT(DECIMAL(18,2), z.index_size_kb) / 1024 / 1024 as index_size_gb
  , 'SET DEADLOCK_PRIORITY -5; SET LOCK_TIMEOUT 1000; DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + '.' + QUOTENAME(OBJECT_NAME(i.object_id)) as dropSQL
  , SUBSTRING(
      (SELECT ', ' + AC.[name]
      FROM sys.[tables] t
      INNER JOIN sys.[indexes] i2
        ON t.[object_id] = i2.[object_id]
      INNER JOIN sys.[index_columns] ic
        ON i2.[object_id] = ic.[object_id]
        AND i2.[index_id] = ic.[index_id]
      INNER JOIN sys.[all_columns] ac
        ON t.[object_id] = ac.[object_id]
        AND ic.[column_id] = ac.[column_id]
      WHERE i.[object_id] = i2.[object_id]
      AND i.[index_id] = i2.[index_id]
      AND ic.is_included_column = 0
      ORDER By ic.key_ordinal
      FOR
      XML PATH('') ), 2, 8000) as keyCols
    , SUBSTRING(
      (SELECT ', ' + AC.[name]
      FROM sys.[tables] t
      INNER JOIN sys.[indexes] i2
        ON t.[object_id] = i2.[object_id]
      INNER JOIN sys.[index_columns] ic
        ON i2.[object_id] = ic.[object_id]
        AND i2.[index_id] = ic.[index_id]
      INNER JOIN sys.[all_columns] ac
        ON t.[object_id] = ac.[object_id]
        AND ic.[column_id] = ac.[column_id]
      WHERE i.[object_id] = i2.[object_id]
      AND i.[index_id] = i2.[index_id]
      AND ic.is_included_column = 1
      ORDER By ic.key_ordinal
      FOR
      XML PATH('') ), 2, 8000) as includeCols
FROM sys.indexes i
INNER JOIN sys.[tables] t on t.[object_id] = i.[object_id]
INNER JOIN sys.[schemas] sc on sc.[schema_id] = t.[schema_id]
INNER JOIN
  (
  SELECT i.object_id
        , i.index_id
        , SUM(s.[used_page_count]) * 8 AS index_size_kb
  FROM sys.db_db_partition_stats s
  INNER JOIN sys.indexes i
    ON s.object_id = i.object_id
    AND s.index_id = i.index_id
  GROUP BY i.object_id, i.index_id
  ) z ON i.object_id = z.object_id
    AND i.index_id = z.index_id
LEFT JOIN sys.dm_db_index_usage_stats s
  ON s.object_id = i.object_id
  AND i.index_id = s.index_id
  AND s.database_id = db_id()
WHERE 1 = 1
AND OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1
AND OBJECT_NAME(i.object_id) = 'table'
AND OBJECT_SCHEMA_NAME(i.object_id) = 'schema'
ORDER BY 6 DESC
