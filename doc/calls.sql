--Convert date format from 'dd/mm/yyyy' to 'yyyy-mm-dd'
UPDATE Ann
SET CDate=SUBSTR(CDate,7,4) || '-' || SUBSTR(CDate,4,2) || '-' || SUBSTR(CDate,1,2)

--Convert time format 'hh:mm:ss' to seconds
UPDATE Ann
SET CDuration=SUBSTR(CDuration,1,1)*24*60+SUBSTR(CDuration,3,2)*60+SUBSTR(CDuration,6,2)

--протяжённость самого долгого звонка
SELECT MAX(CDuration)
FROM Ann
WHERE CParty <> 'GPRS INTRANET'

--кол-во звонков в день
SELECT CDate, COUNT(CDate) AS Calls
FROM Ann
GROUP BY CDate
ORDER BY Calls DESC

--По какому номеру звонили больше в всего день
SELECT CDate, CParty, COUNT(CParty) AS Dest
FROM Ann
WHERE (CParty <> 'GPRS INTRANET') AND (NOT CParty LIKE '%SMS')
GROUP BY CDate, CParty
ORDER BY CDate, Dest DESC

--По какому номеру отправляли больше всего SMS в день
SELECT CDate, CParty, COUNT(CParty) AS Dest
FROM Ann
WHERE (CParty <> 'GPRS INTRANET') AND (CParty LIKE '%SMS')
GROUP BY CDate, CParty
ORDER BY CDate, Dest DESC

--Общая, макс и средняя прод-сть звонка/ов и их кол-во в день
SELECT CDate, SUM(CDuration)/60.0 AS TotalDuration, MAX(CDuration)/60.0, AVG(CDuration)/60.0, COUNT(CDuration)
FROM Ann
WHERE (CParty <> 'GPRS INTRANET') AND (NOT CParty LIKE '%SMS')
GROUP BY CDate
ORDER BY TotalDuration DESC

--К какой группе звонок был самым длинным в день
SELECT a.CDate AS 'Date', g.Groupname AS 'Group', MAX(CDuration) AS Duration
FROM Ann a
LEFT JOIN CallGroups g
ON a.CParty=g.CallParty
GROUP BY a.CDate
ORDER BY Duration DESC

--К какой группе звонили больше в день
SELECT a.CDate AS 'Date', g.Groupname AS 'Group', COUNT(CParty) AS Calls
FROM Ann a
LEFT JOIN CallGroups g
ON a.CParty=g.CallParty
GROUP BY a.CDate
ORDER BY Calls DESC