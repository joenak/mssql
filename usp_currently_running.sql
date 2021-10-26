CREATE PROCEDURE [dbo].[usp_Currently_Running]
AS

SET NOCOUNT ON

BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT TOP 100
			  [Spid]	= session_Id
			, [blkID]	= blocking_session_id
			, sp.cpu
			, [Database] = DB_NAME(sp.dbid)
			, [User] = nt_username
			, [Status] = er.status
			, [Wait] = wait_type
			, [WaitResource] = er.wait_resource
			, [last_batch Wait] = LastWaitType
			, [Individual Query] = SUBSTRING (qt.text,  er.statement_start_offset/2, (CASE
																						WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
																						ELSE er.statement_end_offset
																						END - er.statement_start_offset)/2)
			, [Parent Query] = qt.text
			, Program = program_name
			, Jobiid  = CAST(
								CASE
								WHEN PATINDEX('%Job %', program_name) > 0 THEN SUBSTRING(program_name, PATINDEX('%Job %', program_name) + 4, 34)
								ELSE NULL
							END  AS NVARCHAR(36))
			, Hostname
			, nt_domain
			, start_time
			, DATEDIFF(MINUTE,start_time,GETDATE()) DateDiff_Minutes
			, QueryPlan	= qp.query_plan
	FROM	sys.dm_exec_requests er
	INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
	CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)AS qt
	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle)AS qp
	WHERE session_Id > 50
	AND session_Id NOT IN (@@SPID)
	ORDER BY 1, 2

END
