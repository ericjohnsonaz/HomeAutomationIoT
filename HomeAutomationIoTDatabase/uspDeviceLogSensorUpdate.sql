USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogSensorUpdate') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogSensorUpdate
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogSensorUpdate >>>'
END
GO

CREATE PROC dbo.uspDeviceLogSensorUpdate
  @seconds INT

AS

  Update tDeviceLogSensor 
     set UpdateSeconds = @seconds,
	     Mode = 'Ludicrous'
   WHERE IsActive = 1


	EXEC uspDeviceLogValueGetActiveClients

  SELECT @seconds as RefreshSeconds

GO

IF OBJECT_ID('dbo.uspDeviceLogSensorUpdate') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogSensorUpdate >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogSensorUpdate >>>'
GO

GRANT EXEC ON uspDeviceLogSensorUpdate TO HomeTempGauges
GO