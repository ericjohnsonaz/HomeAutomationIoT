USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogValueGetExperiments') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogValueGetExperiments
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogValueGetExperiments >>>'
END
GO

CREATE PROC dbo.uspDeviceLogValueGetExperiments
 
AS

  SELECT DISTINCT Experiment
    FROM tDeviceLogValue

GO

IF OBJECT_ID('dbo.uspDeviceLogValueGetExperiments') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueGetExperiments >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueGetExperiments >>>'
GO

GRANT EXEC ON uspDeviceLogValueGetExperiments TO HomeTempGauges
GO