USE [msdb]
GO

/****** Object:  Job [DeleteOldReservationsData]    Script Date: 12/23/2019 7:47:48 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/23/2019 7:47:48 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DeleteOldReservationsData', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'quali', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete]    Script Date: 12/23/2019 7:47:48 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
    USE [TestShell];    
    DECLARE @DataTableToDelete TABLE(    
    ReservationId uniqueidentifier,
	ExecutionJobId uniqueidentifier,
	ReservedTopologyId bigint
);

Insert into @DataTableToDelete (ReservationId, ExecutionJobId, ReservedTopologyId)
select ExecutionJob.ReservationId, ExecutionJob.Id, ReservedTopology.Id  from ExecutionJob
FULL join ReservedTopology on ReservedTopology.ReservationId = ExecutionJob.ReservationId
Where EndTime < DATEADD(Day, -1, GETUTCDATE())

DECLARE @r INT,@batch_size INT;
SET @batch_size = 5000;
SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;

	Delete TOP (@batch_size) from ReservedTopologyScripts
	where ReservedTopologyId in (select ReservedTopologyId from @DataTableToDelete)
	SET @r = @@ROWCOUNT;
 
  COMMIT TRANSACTION;
END

SET @r = 1;
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  TopologyResourceResolution
where ReservedTopologyId in (select ReservedTopologyId from @DataTableToDelete)
	SET @r = @@ROWCOUNT;
 
  COMMIT TRANSACTION;
END

SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ReservedTopologyResource
where ReservedTopologyId in (select ReservedTopologyId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END

SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ReservedTopology
where Id in (select ReservedTopologyId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ReservationTestShellDomain
where ResourceManagerReservationId in (select ReservationId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ReservationPermittedUser
where ReservationId in (select ReservationId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ReservedResource
where ReservationId in (select ReservationId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ResourceManagerReservation
where Id in (select ReservationId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  EventLog
where ReservationId in (select ReservationId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ExecutionJobItem
where ExecutionJobId in (select ExecutionJobId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  RuntimeServerReservation
where ExecutionJobId in (select ExecutionJobId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  ExecutionJob
where Id in (select ExecutionJobId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  CommandOutput
where Id in (select CommandOutputId from EventLog			
			where EventLog.ReservationId in (select ReservationId from @DataTableToDelete))
	SET @r = @@ROWCOUNT;		 
  COMMIT TRANSACTION;
END


SET @r = 1;
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
Delete TOP (@batch_size) from  EventLog 
where ReservationId in (select ReservationId from @DataTableToDelete)
 SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DeleteOldReservations', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191219, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6084efc7-ee04-4f3d-a5e5-bf1af554d52e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


