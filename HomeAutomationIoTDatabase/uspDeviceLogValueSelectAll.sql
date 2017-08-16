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
  DECLARE @beginId INT
  DECLARE @endId   INT
  SELECT  @endId = MAX(Id)
	FROM tDeviceLogValue
  SET @beginId = @endId - 500;

  SELECT top 500 *
    FROM tDeviceLogValue
   WHERE Id between @beginId and @endId
  ORDER BY Updated desc

GO

IF OBJECT_ID('dbo.uspDeviceLogValueSelectAll') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.uspDeviceLogValueSelectAll >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.uspDeviceLogValueSelectAll >>>'
GO

GRANT EXEC ON uspDeviceLogValueSelectAll TO HomeTempGauges
GO