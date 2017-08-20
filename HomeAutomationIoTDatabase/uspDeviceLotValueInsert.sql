USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLotValueInsert') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLotValueInsert
    PRINT '<<< DROPPED PROC dbo.uspDeviceLotValueInsert >>>'
END
GO

CREATE PROC dbo.uspDeviceLotValueInsert

	@sensorName varchar(50) = NOTNULL,
	@location   varchar(50) = NOTNULL,
    @experiment varchar(50) = NOTNULL,
	@value      decimal(18,4) = NOTNULL,
	@vccVoltage decimal(18,4) = NOTNULL,
	@wifiSignalStrength decimal(6,2),
	@softwareVersion varchar(15),
	@response   varchar(max) = null
	 
AS


  Insert tDeviceLogValue (SensorName
						  ,Location
						  ,Experiment
						  ,Value
						  ,VccVoltage
						  ,WiFiSignalStrength
						  ,SoftwareVersion
						  ,Response)
				Select
				 		 @sensorName
						,@location
						,@experiment
						,@value
						,@vccVoltage
						,@wiFiSignalStrength
						,@softwareVersion
						,@response

  return 777

GO

IF OBJECT_ID('dbo.uspDeviceLotValueInsert') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLotValueInsert >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLotValueInsert >>>'
GO

GRANT EXEC ON uspDeviceLotValueInsert TO HomeTempGauges
GO