--
-- Setzt den ersten Wochentag auf Montag (Standard bei Default Einstellung "DE-Deutsch")
--
SET DATEFIRST 1

--
-- Verwendung der gebräuchlichsten SQL Funktionen
--
SELECT 
ProductNumber,
ML_Name_de,
ML_Description_de,
ISNULL(ML_Description_de, '') _Isnull,
LEFT(CAST(ML_Description_de AS nvarchar(max)), 10) _left,
LEFT(ML_Name_de, 10) _left2,
LEFT(CONCAT(ML_Name_de, '...........'), 10) _left_concat,
RIGHT(ML_Name_de, 1) _right,
CONCAT(ProductNumber, ' - ', ML_Name_de) _concat,
CONCAT('   ', ProductNumber, '   ') _concat_helper,
TRIM(CONCAT('   ', ProductNumber, '   ')) _trim,
LTRIM(CONCAT('   ', ProductNumber, '   ')) _ltrim,
RTRIM(CONCAT('   ', ProductNumber, '   ')) _rtrim,
REPLACE(ML_Name_de, ' ', '_') _replace,
CASE WHEN LEFT(ProductNumber, 1) = '0' THEN 'Gruppe 1' WHEN LEFT(ProductNumber, 1) = 'M' THEN 'Gruppe 2' ELSE 'Gruppe 3' END case1,
CASE LEFT(ProductNumber, 1) 
	WHEN '0' THEN 'Gruppe 1' 
	WHEN 'M' THEN 'Gruppe 2' 
	ELSE 'Gruppe 3' 
END case2,
AddNewDate,
CAST(AddNewDate AS Date) _date,
DATEPART(YEAR, AddNewDate) _datepart,
DATEDIFF(DAY, AddNewDate, ChangeDate) _datediff,
DATEADD(day, -1, GETDATE()) _dateadd, -- GETDATE() gibt die aktuelle Uhrzeit (mit Datum) zurück
EOMONTH(GETDATE()) _eomonth, -- Monatsende
EOMONTH(DATEADD(month, -1, EOMONTH(GETDATE()))) _dateadd_eomonth1, -- Vormonatsletzter
DATEADD(day, 1, EOMONTH(DATEADD(month, -1, GETDATE()))) _dateadd_eomonth2 -- Monatserster

FROM
BAS_Products

ORDER BY
ProductNumber

--
-- UPDATE
-- Wichtig:
-- 1. Updates immer innerhalb einer Transaktion ausführen und vor dem COMMIT sorgfältig prüfen, ob alles korrekt ausgeführt wurde
-- 2. Transaktionen immer zurückrollen oder committen und die Transaktion so kurz als möglich offen halten. Sie kann das System blockieren
-- 3. Bei Updates immer eine WHERE Bedingung verwenden und so wenige Zeilen als möglich updaten. Das hilft, Fehler zu vermeiden
--
BEGIN TRANSACTION

-- Daten vorher
SELECT ProductNumber, RIGHT(CONCAT('X', ProductNumber), 6) FROM BAS_Products WHERE LEN(ProductNumber) < 6

-- Datensätze aktualisieren
UPDATE BAS_Products
SET ProductNumber = RIGHT(CONCAT('X', ProductNumber), 6)
WHERE LEN(ProductNumber) < 6

-- Daten nachher
SELECT ProductNumber FROM BAS_Products WHERE LEN(ProductNumber) < 6

ROLLBACK
-- COMMIT

-- Update Tabelle 1 mit Daten aus Tabelle 2
-- Variante 1:
-- Verwenden eines "Subselects", der die Daten aus einer anderen Tabelle liest

BEGIN TRANSACTION

SELECT ML_Name_de FROM BAS_Products

UPDATE BAS_Products
SET ML_Name_de = CONCAT(ML_Name_de, ' (', (
  SELECT Code FROM BAS_Units u WHERE u.GUID = BAS_Products.BaseUnit
), ')')
WHERE LEN(ML_Name_de) <= 50

SELECT ML_Name_de FROM BAS_Products

ROLLBACK

-- Variante 2:
-- Update mit Inner Join: Basis ist ein Join, wie man ihn vom Lesen von Daten kennt

SELECT
p.ML_Name_de,
u.Code

FROM
BAS_Products p
INNER JOIN BAS_Units u ON p.BaseUnit = u.GUID

-- Der Select wird dann zu einem Update geändert:

BEGIN TRANSACTION

UPDATE p
SET 
p.ML_Name_de = CONCAT(p.ML_Name_de, ' (', u.Code, ')'),
p.ML_Description_de = CONCAT(p.ML_Description_de, ' (', u.Code, ')')

FROM
BAS_Products p
INNER JOIN BAS_Units u ON p.BaseUnit = u.GUID

WHERE 
LEN(p.ML_Name_de) <= 50

SELECT ML_Name_de FROM BAS_Products

ROLLBACK