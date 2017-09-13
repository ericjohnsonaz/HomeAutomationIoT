USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectForChart') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogValueSelectForChart
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogValueSelectForChart >>>'
END
GO

CREATE PROC dbo.uspDeviceLogValueSelectForChart
	@startIsoDate datetime
   ,@endIsoDate   datetime
AS

  SELECT *
    FROM tDeviceLogValue
   WHERE Updated between @startIsoDate and @endIsoDate
  ORDER BY Updated desc

GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectForChart') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueSelectForChart >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueSelectForChart >>>'
GO

GRANT EXEC ON uspDeviceLogValueSelectForChart TO HomeTempGauges
GO