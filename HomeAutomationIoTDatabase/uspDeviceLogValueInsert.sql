USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogValueInsert') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogValueInsert
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogValueInsert >>>'
END
GO

CREATE PROC dbo.uspDeviceLogValueInsert

	@sensorName varchar(50) = NOTNULL,
	@location   varchar(50) = NOTNULL,
    @experiment varchar(50) = NOTNULL,
	@value      decimal(18,4) = NOTNULL,
	@updateSeconds int,
	@vccVoltage decimal(18,4) = NOTNULL,
	@wifiSignalStrength decimal(6,2),
	@freeHeap      int = null,
	@softwareVersion varchar(15),
	@response   varchar(max) = null
	 
AS


  Insert tDeviceLogValue (SensorName
						  ,Location
						  ,Experiment
						  ,Value
						  ,UpdateSeconds
						  ,VccVoltage
						  ,WiFiSignalStrength
						  ,SoftwareVersion
						  ,FreeHeap
						  ,Response)
				Select
				 		 @sensorName
						,@location
						,@experiment
						,@value
						,@updateSeconds
						,@vccVoltage
						,@wiFiSignalStrength
						,@softwareVersion
						,@freeHeap
						,@response

  return 777

GO

IF OBJECT_ID('dbo.uspDeviceLogValueInsert') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueInsert >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueInsert >>>'
GO

GRANT EXEC ON uspDeviceLogValueInsert TO HomeTempGauges
GO