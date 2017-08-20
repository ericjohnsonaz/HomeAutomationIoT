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
		Id int not null,
		SensorName varchar(50) not null,
		VccVoltage decimal(18,4) null,
		WiFiSignalStrength decimal(6,2) null,
		SoftwareVersion varchar(15) null,
		LastUpdated datetime not null
	)

  Insert into @SensorTable (Id
                           ,SensorName
                           ,VccVoltage
                           ,WiFiSignalStrength
                           ,SoftwareVersion
				           ,LastUpdated)
		  SELECT 
		DISTINCT dlv.Id 
		         ,dlv.SensorName
				 ,VccVoltage
				 ,WiFiSignalStrength
				 ,SoftwareVersion
				 ,Updated
			FROM tDeviceLogValue dlv
			JOIN (SELECT Max(id) as Id
						,SensorName
				   FROM  tDeviceLogValue
				GROUP BY  SensorName) maxDlv
			  ON dlv.id = maxDlv.id
			 AND dlv.SensorName = maxDlv.SensorName

	
  Insert tDeviceLogSensor(SensorName, LastUpdated, VccVoltage, WiFiSignalStrength, SoftwareVersion)
  Select s.SensorName, s.LastUpdated, s.VccVoltage, s.WiFiSignalStrength, s.SoftwareVersion
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
	    ,dls.VccVoltage = s.VccVoltage
		,dls.WiFiSignalStrength = s.WiFiSignalStrength
		,dls.SoftwareVersion = s.SoftwareVersion
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