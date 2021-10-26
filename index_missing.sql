SELECT
  d.statement
  , g.avg_total_user_cost * (g.avg_user_impact / 100.0) * (g.user_seeks + g.user_scans)
  , 'CREATE INDEX [MIX_' + CONVERT(varchar, g.index_group_handle) + '_' + CONVERT(varchar, d.index_handle)
      + '_' + LEFT(PARSENAME(d.statement, 1), 32) + '] ON ' + d.statement + ' (' + ISNULL(d.equality_columns,'')
      + CASE WHEN d.equality_columns IS NOT NULL AND d.inequality_columns IS NOT NULL THEN ',' ELSE '' END
      + ISNULL(d.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + d.included_columns + ')', '') as createTSQL
  , g.*
  , d.database_id
  , d.object_id
FROM sys.dm_db_missing_index_groups g
INNER JOIN sys.dm_db_missing_index_group_stats s
  ON g.group_handle = s.index_group_handle
INNER JOIN sys.dm_db_missing_index_details d
  ON g.index_handle = d.index_handle
WHERE 1 = 1
AND g.avg_total_user_cost * (g.avg_user_impact / 100.0) * (g.user_seeks + g.user_scans) > 10
ORDER BY 1
