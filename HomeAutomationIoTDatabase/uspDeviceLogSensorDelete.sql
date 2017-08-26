USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogSensorDelete') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogSensorDelete
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogSensorDelete >>>'
END
GO

CREATE PROC dbo.uspDeviceLogSensorDelete
  @deviceLogSensorId INT

AS

  UPDATE tDeviceLogSensor 
     SET IsActive = 0
   WHERE Id = @deviceLogSensorId 

GO

IF OBJECT_ID('dbo.uspDeviceLogSensorDelete') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogSensorDelete >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogSensorDelete >>>'
GO

GRANT EXEC ON uspDeviceLogSensorDelete TO HomeTempGauges
GO