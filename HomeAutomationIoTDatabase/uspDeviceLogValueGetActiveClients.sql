USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogValueGetActiveClients') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogValueGetActiveClients
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogValueGetActiveClients >>>'
END
GO

CREATE PROC dbo.uspDeviceLogValueGetActiveClients
 
AS

  DECLARE @SensorTable TABLE
	(
		SensorName varchar(50) not null,
		LastUpdated datetime not null
	)

  Insert into @SensorTable (SensorName, LastUpdated)
  select distinct SensorName, Max(Updated)
    FROM tDeviceLogValue
	group by SensorName


  Insert tDeviceLogSensor(SensorName, LastUpdated)
  Select s.SensorName, s.LastUpdated
    from @SensorTable s
	LEFT
   OUTER
    JOIN tDeviceLogSensor dls
	  ON s.SensorName = dls.SensorName
   WHERE dls.id IS NULL


  DELETE tDeviceLogSensor
    FROM tDeviceLogSensor dls
	LEFT
   OUTER
    JOIN @SensorTable s
	  ON s.SensorName = dls.SensorName
   WHERE s.SensorName IS NULL
   
  UPDATE dls
     SET dls.LastUpdated = s.LastUpdated
    FROM tDeviceLogSensor dls
	JOIN @SensorTable s
	  ON dls.SensorName = s.SensorName


	    
  SELECT *
    FROM tDeviceLogSensor

GO

IF OBJECT_ID('dbo.uspDeviceLogValueGetActiveClients') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueGetActiveClients >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueGetActiveClients >>>'
GO

GRANT EXEC ON uspDeviceLogValueGetActiveClients TO HomeTempGauges
GO