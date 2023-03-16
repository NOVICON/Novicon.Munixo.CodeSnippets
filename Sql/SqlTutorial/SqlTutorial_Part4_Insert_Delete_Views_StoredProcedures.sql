
-- Löschen von Daten
-- Zuerst ansehen, was man löschen möchte
SELECT * FROM BAS_ApplicationLogs WHERE YEAR(DateTime) < 2018

-- Das eigentliche Löschen führt man dann wieder, wie ein Update, innerhalb einer Transaktion aus
BEGIN TRANSACTION
SELECT COUNT(*) FROM BAS_ApplicationLogs
DELETE FROM BAS_ApplicationLogs WHERE YEAR(DateTime) < 2018
SELECT COUNT(*) FROM BAS_ApplicationLogs
COMMIT

-- Komplette Tabelle leeren
-- A) Mit Änderungsprotokollierung - langsam
DELETE FROM BAS_ApplicationLogs
-- B) Ohne Änderungsprotokollierung - schnell - !!ACHTUNG!!
TRUNCATE TABLE BAS_ApplicationLogs

-- BEGINN EXKURS
-- Werden in Munixo Datensätze in volltextindizierten Tabellen per SQL gelöscht, müssen diese auch aus der Volltextsuche entfernt werden.
-- Das funktioniert am Beispiel BAS_ApplicationLogs (Nur zum Beispiel, die Tabelle ist *nicht* volltextindiziert!) wie folgt:
INSERT INTO INT_GuidsToCreateIndex(RecordGUID, DBObject, ToDelete)
SELECT a.GUID RecordGUID, do.GUID DbObject, 1 ToDelete 
FROM BAS_ApplicationLogs a 
CROSS JOIN INT_DO do
WHERE YEAR(a.DateTime) < 2019 
AND do.Name = 'BAS_ApplicationLogs'
-- ENDE EXKURS

-- Einfügen von Daten
SELECT TOP 10 * FROM BAS_ApplicationLogs ORDER BY DateTime DESC

-- Mit Werten
INSERT INTO BAS_ApplicationLogs (GUID, ApplicationName, Type, DateTime, DateTimeMilliseconds, Username)
VALUES(NEWID(), 'Test', 'Info', GETDATE(), 0, 'Novicon')

-- Mit Select als Datenbasis
INSERT INTO BAS_ApplicationLogs (GUID, ApplicationName, Type, DateTime, DateTimeMilliseconds, Username, Description)
SELECT TOP 2 NEWID() GUID,  CONCAT(ApplicationName, '_Copy') ApplicationName, Type, GETDATE() DateTime, 1 DateTimeMilliseconds, Username Username, 'Copy' Description
FROM BAS_ApplicationLogs
ORDER BY DateTime DESC

GO

-- Sichten
CREATE VIEW View_OP_Invoices AS

SELECT 
YEAR(i.DocumentDate) Jahr,
MONTH(i.DocumentDate) Monat,
YEAR(i.DocumentDate) * 100 + MONTH(i.DocumentDate) Periode, -- Beispiel für die Bildung einer "Periode" aus YYYYMM
MIN(ip.RealGrossAmount) Min_GrossAmount,
MAX(ip.RealGrossAmount) Max_GrossAmount,
AVG(ip.RealGrossAmount) Avg_GrossAmount,
COUNT(*) Anzahl

FROM 
OP_Invoices i
INNER JOIN OP_InvoicePositions ip ON i.GUID = ip.Document
 AND ip.Level = 1
INNER JOIN OP_DocumentPosTypes dpt ON ip.PositionType = dpt.GUID
  AND dpt.Code = 'PRD' -- Gibt nur Positionen vom Typ "Artikel" aus

GROUP BY
YEAR(i.DocumentDate),
MONTH(i.DocumentDate)

SELECT * FROM View_OP_Invoices WHERE Anzahl > 1

-- Geändert wird eine Sicht/View mit ALTER VIEW [Viewname] AS [SQL Text]. Es wird also nur "CREATE" durch "ALTER" erstetzt.

-- Gespeicherte Prozeduren - TSQL (Transact SQL)
-- Sind "Programme" in der Datenbank.
-- Hier ein einfaches Beispiel zur Verwendung von Variablen. Diese können innerhalb der Prozedur in SELECT, INSERT, UPDATE, DELETE Befehlen verwendet werden.

DECLARE
@SearchString nvarchar(max) = 'PT Sans',
@ReplaceString nvarchar(max) = 'Roboto Light'

SELECT @SearchString, @ReplaceString

SET @SearchString = 'Arial'

SELECT @SearchString, @ReplaceString

SELECT *, @SearchString FROM BAS_Clients WHERE FontName = @SearchString

-- Das geht nicht
DECLARE @TableName nvarchar(255) = 'BAS_Clients'
SELECT * FROM @TableName

GO

-- CREATE PROCEDURE
-- Soll der TSQL Code in einer Prozedur gespeichert werden, ist er wie folgt abzuändern.
-- Die Prozedur hat zwei Variablen, innerhalb der Prozedur wird eine dritte Variable deklariert.
ALTER PROCEDURE SP_SearchReplaceTest (@SearchString nvarchar(max) = 'PT Sans', @ReplaceString nvarchar(max) = 'Roboto Light')

AS

DECLARE @something int

SET @something = ISNULL(@something, 1) * 2

SELECT @SearchString Search, @ReplaceString Replace, @something Something
