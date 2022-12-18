/*
	Das ist ein
	mehrzeiliger
	Kommentar
*/

-- Das ist ein einzeiliger Kommentar

--
-- Syntax
--
SELECT
*
FROM
BAS_Cities

WHERE
Name = 'München'

-- Wie oben, nur klein geschrieben und mit Spaltenangabe
select
PostalCode, 
Name
-- Keine Sonderzeichen, Umlaute, Leerzeichen!
-- also nie 
-- [Postal Code],
-- maximal
-- Postal_Code

from
BAS_Cities

where
(Name = 'München'
or PostalCode >= 81371)
--and PostalCode not between 81371 and 81735

--
-- Strukturieren
-- 
SELECT
*
FROM
BAS_Cities

WHERE
Name = 'München'

ORDER BY
PostalCode DESC

--
-- Gruppieren
--
SELECT
Name,
COUNT(*)

FROM
BAS_Cities

WHERE
Name LIKE '%München%'
OR LEFT(Name, 1) = 'L'

GROUP BY
Name

--
-- Grupoieren mit Prüfung auf Eindeutigkeit
--
SELECT
Name,
COUNT(*)

FROM
BAS_Cities

WHERE
Name LIKE '%München%'
OR LEFT(Name, 1) = 'L'

GROUP BY
Name

HAVING
COUNT(*) > 1

ORDER BY
COUNT(*) DESC

--
-- Spalten Alias
--
SELECT
Name Ortsname,
COUNT(*) AS AnzahlPostleitzahlen

FROM
BAS_Cities

GROUP BY
Name

--
-- Tabellen verkn�pfen
--
SELECT
BAS_Cities.Name Ortsname,
BAS_Cities.PostalCode PLZ,
BAS_Countries.Name Land,
BAS_Currencies.ISOCode Waehrung

FROM
BAS_Cities
INNER JOIN BAS_Countries ON BAS_Cities.Country = BAS_Countries.GUID
INNER JOIN BAS_Currencies ON BAS_Countries.Currency = BAS_Currencies.GUID

WHERE
BAS_Cities.Name = 'München'

--
-- Tabellen Alias
--
SELECT
Cities.Name Ortsname,
Cities.PostalCode PLZ,
Countries.Name Land,
Currencies.ISOCode Waehrung

FROM
BAS_Cities Cities
INNER JOIN BAS_Countries AS Countries ON Cities.Country = Countries.GUID
INNER JOIN BAS_Currencies Currencies ON Countries.Currency = Currencies.GUID

WHERE
Cities.Name = 'München'
