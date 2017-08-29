USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectAll') IS NOT NULL
BEGIN
    DROP PROC dbo.uspDeviceLogValueSelectAll
    PRINT '<<< DROPPED PROC dbo.uspDeviceLogValueSelectAll >>>'
END
GO

CREATE PROC dbo.uspDeviceLogValueSelectAll
 
AS
  DECLARE @beginLastUpdated datetime
  DECLARE @endLastUpdated   datetime
  
  SET  @endLastUpdated = GetDate();
  SET  @beginLastUpdated = DateAdd(day, -2, @endLastUpdated) 

  SELECT *
    FROM tDeviceLogValue
   WHERE Updated between @beginLastUpdated and @endLastUpdated
  ORDER BY Updated desc

GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectAll') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueSelectAll >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueSelectAll >>>'
GO

GRANT EXEC ON uspDeviceLogValueSelectAll TO HomeTempGauges
GO