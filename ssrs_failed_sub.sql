------------------------------------------------------------------------------------------------
-- Failed SSRS Subscription
------------------------------------------------------------------------------------------------
SELECT
  sc.ScheduleID
  , c.[name]
  , sb.[Description]
  , sb.DeliveryExtension
  , sb.LastStatus
  , sb.LastRunTime
  , c.[path]
  , 'EXEC msdb.dbo.sp_start_job @job_name = ''' + CAST(sc.ScheduleID AS VARCHAR(100)) + '''' AS tsql
FROM RepServ.dbo.ReportSchedule rs
INNER JOIN RepServ.dbo.Schedule sc ON rs.ScheduleID = sc.ScheduleID
INNER JOIN RepServ.dbo.Subscriptions sb ON rs.SubscriptionID = sb.SubscriptionID
INNER JOIN RepServ.dbo.[Catalog] c ON rs.ReportID = c.ItemID AND sb.Report_OID = c.ItemID
WHERE 1 = 1
AND (sb.LastStatus LIKE 'Failure%' OR sb.LastStatus LIKE 'Error%')
AND sb.LastRUnTime > DATEADD(D, -1, GETDATE())



------------------------------------------------------------------------------------------------
-- Failed Subscription By Name
------------------------------------------------------------------------------------------------
DECLARE @reportName varchar(100) = 'Report%'

SELECT
  sc.ScheduleID
  , c.[name]
  , sb.[Description]
  , sb.DeliveryExtension
  , sb.LastStatus
  , sb.LastRunTime
  , c.[path]
  , 'EXEC msdb.dbo.sp_start_job @job_name = ''' + CAST(sc.ScheduleID AS VARCHAR(100)) + '''' AS tsql
FROM RepServ.dbo.ReportSchedule rs
INNER JOIN RepServ.dbo.Schedule sc ON rs.ScheduleID = sc.ScheduleID
INNER JOIN RepServ.dbo.Subscriptions sb ON rs.SubscriptionID = sb.SubscriptionID
INNER JOIN RepServ.dbo.[Catalog] c ON rs.ReportID = c.ItemID AND sb.Report_OID = c.ItemID
WHERE 1 = 1
AND c.[name] LIKE @reportName
