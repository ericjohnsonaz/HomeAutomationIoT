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

 -- DECLARE @beginId INT
 -- DECLARE @endId   INT
 -- SELECT  @endId = MAX(Id)
	--FROM tDeviceLogValuer
 -- SET @beginId = @endId - 2000;

  DECLARE @beginLastUpdated datetime
  DECLARE @endLastUpdated   datetime
  
  SET  @endLastUpdated = GetDate();
  SET  @beginLastUpdated = DateAdd(day, -2, @endLastUpdated) 

  SELECT *
    FROM tDeviceLogValue
   WHERE Updated between @beginLastUpdated and @endLastUpdated
  ORDER BY Updated desc


  --SELECT  *
  --  FROM tDeviceLogValue
  -- WHERE Id between @beginId and @endId
  --ORDER BY Updated asc

GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectForChart') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueSelectForChart >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueSelectForChart >>>'
GO

GRANT EXEC ON uspDeviceLogValueSelectForChart TO HomeTempGauges
GO