------------------------------------------------------------------------------------------
-- Always On AGs
------------------------------------------------------------------------------------------
ALTER AVAILABILITY GROUP [AG_123] MODIFY REPLICA ON 'SERVER1' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT)

ALTER AVAILABILITY GROUP [AG_123] FAILOVER

ALTER AVAILABILITY GROUP [AG_123] MODIFY REPLICA ON 'SERVER1' WITH (FAILOVER_MODE = MANUAL)
ALTER AVAILABILITY GROUP [AG_123] MODIFY REPLICA ON 'SERVER1' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)


------------------------------------------------------------------------------------------
-- powershell for cluster stuff
------------------------------------------------------------------------------------------
> Import-Module FailoverClusters
> Get-clusterGroup
> Move-clusterGroup "Cluster Group" -node Server2
> Move-clusterGroup "Available Storage" -node Server2
> Get-clusterGroup


> Get-ClusterQuorum
> Set-ClusterQuorum -NodeAndFileShareMajority \\full\unc\path

> Get-ClusterOwnerNode -Group "Cluster Group"
> Set-ClusterOwnerNode -Group "Cluster Group" -Owners Server2

------------------------------------------------------------------------------------------
-- DB or server setting that maybe are not the same
------------------------------------------------------------------------------------------
SELECT [name]
  , suser_sname(owner_sid)
  , is_broker_enabled
  , is_trustworthy_on
  , 'ALTER AUTHORIZATION ON DATABASE::' + QUOTENAME([name]) + 'TO sa;'
  , 'ALTER DATABASE ' + QUOTENAME([name]) + ' SET TRUSTWORTHY ON;'
  , *
FROM sys.databases
WHERE 1 = 1
--AND suser_sname(owner_sid) <> 'sa'
--AND [name] = 'Database1'

USE database1
GO

EXEC sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

------------------------------------------------------------------------------------------
-- Mirroring
------------------------------------------------------------------------------------------
USE master
GO

ALTER DATABASE database1 SET SAFETY FULL
ALTER DATABASE database1 SET PARTNER FAILOVER
