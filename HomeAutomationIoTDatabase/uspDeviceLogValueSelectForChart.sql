USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectForChart') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogValueSelectForChart
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogValueSelectForChart >>>'
END
GO

CREATE PROC dbo.uspDeviceLogValueSelectForChart
 
AS

  DECLARE @beginId INT
  DECLARE @endId   INT
  SELECT  @endId = MAX(Id)
	FROM tDeviceLogValue
  SET @beginId = @endId - 1000;


  SELECT  *
    FROM tDeviceLogValue
   WHERE Id between @beginId and @endId
  ORDER BY Updated asc

GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectForChart') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueSelectForChart >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueSelectForChart >>>'
GO

GRANT EXEC ON uspDeviceLogValueSelectForChart TO HomeTempGauges
GO