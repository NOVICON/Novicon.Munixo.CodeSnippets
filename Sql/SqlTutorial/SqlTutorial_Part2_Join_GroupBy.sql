--
-- Verknüpfung von Tabellen mit JOIN
--

-- Einschränkung der Menge an zurückgegebenen Zeilen mit "TOP" gibt die angegebene Anzahl an Zeilen zurück und ist häufig zur Performanceoptimierung sinnvoll,
-- wenn nur die ältesten oder neuesten x Einträge benötigt werden.
SELECT 
TOP 10 * 
FROM OP_Invoices 
ORDER BY DocumentDate ASC

-- Unter MySQL/MariaDB:
SELECT 
FROM OP_Invoices 
ORDER BY DocumentDate ASC
LIMIT 10


-- NULL Werte verhalten sich anders als "normale" Werte. Da NULL "nicht definiert" bedeutet, funktioniert das nicht:
SELECT * FROM OP_Invoices WHERE DispatchModes = NULL
-- Stattdessen muss wie folgt abgefragt werden:
SELECT * FROM OP_Invoices WHERE DispatchModes IS NULL

-- Verknüpft man mehrere Tabellen übere einen "Inner Join", so werden nur die Zeilen ausgegeben, die auf "beiden Seiten" Werte haben.
-- Folglich werden keine Zeilen aus OP_Invoices ausgegeben, die in "DispatchModes" einen NULL Wert haben.
SELECT 
i.DocumentNumber, 
dm.ML_Name_de

FROM 
OP_Invoices i
INNER JOIN BAS_DispatchModes dm ON i.DispatchModes = dm.GUID

-- Möchte man alle Zeilen aus OP_Inovices ausgeben, auch wenn sie keine Versandart haben, muss ein "Left Join" verwendet werden.
-- Dieser zeigt alle Zeilen aus der "Linken" (also in der FROM Klausel zuerst genannten) Tabelle, auch wenn sie in der "rechten" Tabelle keine Daten haben.
-- Das "OUTER" ist optional, es genügt, "LEFT JOIN" zu schreiben.
SELECT 
i.DocumentNumber, 
ISNULL(dm.ML_Name_de, 'keine Versandart') DispatchMode

FROM 
OP_Invoices i
LEFT OUTER JOIN BAS_DispatchModes dm ON i.DispatchModes = dm.GUID

-- Vertauscht man die Reihenfolge der Tabellen, muss statt einem "Left Join" ein "Right Join" verwendet werden.
-- Funktioniert identisch wie oben, ist aber weniger intuitiv und daher nicht zu empfehlen.
SELECT 
i.DocumentNumber, 
dm.ML_Name_de

FROM 
BAS_DispatchModes dm
RIGHT OUTER JOIN OP_Invoices i ON i.DispatchModes = dm.GUID

-- Möchte man alle Zeilen aus beiden Tabellen ausgeben, muss ein "Full Outer Join" verwendet werden.
-- Es gibt nur wenige Fälle, wo dies sinnvoll ist.
SELECT 
i.DocumentNumber, 
dm.ML_Name_de

FROM 
BAS_DispatchModes dm
FULL OUTER JOIN OP_Invoices i ON i.DispatchModes = dm.GUID

-- Möchte man ein Kreuzprodukt, also alle möglichen Kombinationen aller Zeilen beider Tabellen ausgeben, kann dazu der "Cross Join" verwendet werden.
-- Dieser ist mit höchster Vorsicht zu genießen und nur zu verwenden, wenn man genau weiß, wofür. Meist muss dann für die nach "CROSS JOIN" angegebenen
-- Tabelle eine WHERE Bedingung hinzugefügt werden.
SELECT 
i.DocumentNumber, 
dm.ML_Name_de

FROM 
BAS_DispatchModes dm
CROSS JOIN OP_Invoices i

-- Sollen für die Tabellenverknüpfung mehrere Kriterien angegeben werden, können diese in der Join Klausel mit "AND" angefügt werden
SELECT 
i.DocumentNumber,
ip.Pos

FROM 
OP_Invoices i
INNER JOIN OP_InvoicePositions ip ON i.GUID = ip.Document
  AND ip.Level = 1 -- Es sollen nur normale Positionen, keine Setartikel-Positionen ausgegeben werden
  AND ip.Pos = 1 -- Es soll nur die erste Position im Beleg ausgegeben werden

ORDER BY
i.DocumentNumber,
ip.Pos

--
-- Anwenden von Aggregatfunktionen
--

-- Zeige mir nur Rechnungen, die mehr als eine Position haben
SELECT 
i.DocumentNumber,
ip.Pos

FROM 
OP_Invoices i
INNER JOIN OP_InvoicePositions ip ON i.GUID = ip.Document

WHERE 
i.GUID IN (SELECT Document FROM OP_InvoicePositions GROUP BY Document HAVING COUNT(*) > 1)
-- Hat die gleiche Funktion wie oben, nur evtl. etwas performanter
AND EXISTS (SELECT * FROM OP_InvoicePositions ip2 WHERE ip2.Document = ip.Document GROUP BY Document HAVING COUNT(*) > 1)

ORDER BY
i.DocumentNumber,
ip.Pos

-- Alternative mit GROUP BY, allerdings ist dann keine Anzeige der Belegpositionen mehr möglich.
SELECT 
i.DocumentNumber,
COUNT(*) CountStern,
COUNT(DISTINCT ip.ML_ProductName_de) CountDistinct

FROM 
OP_Invoices i
INNER JOIN OP_InvoicePositions ip ON i.GUID = ip.Document

GROUP BY
i.DocumentNumber

HAVING
COUNT(*) > 1

-- Aggregatfuntionen
SELECT 
i.DocumentNumber,
i.GrossAmount,
SUM(ip.RealGrossAmount) GrossAmount_Position,
i.GrossAmount - SUM(ip.RealGrossAmount) Checksumme,
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
i.DocumentNumber,
i.GrossAmount

-- Eine weitere Gruppierung nach Jahr und Monat, wie sie oft in Reports verwendet wird.
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

