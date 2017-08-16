USE HomeAutomationIoT
GO

IF OBJECT_ID('dbo.ReplaceME') IS NOT NULL
BEGIN
    DROP PROC dbo.ReplaceME
    PRINT '<<< DROPPED PROC dbo.ReplaceME >>>'
END
GO

CREATE PROC dbo.ReplaceME

--Parameters Here
 
AS

--Code Here

GO

IF OBJECT_ID('dbo.ReplaceME') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.ReplaceME >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.ReplaceME >>>'
GO

GRANT EXEC ON ReplaceME TO HomeTempGauges
GO