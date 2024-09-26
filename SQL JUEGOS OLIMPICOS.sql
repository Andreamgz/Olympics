
SELECT * FROM athlete_events;

-- How many games have been held?
SELECT COUNT(distinct Year) AS total_juegos FROM athlete_events;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- List all the Olympic Games held so far
SELECT DISTINCT Games FROM athlete_events; 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Mention the total number of nations that participated in each Olympic Games
SELECT Games, COUNT(DISTINCT NOC) AS Num_PaísesxJO From athlete_events GROUP BY Games;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Which year saw the highest and lowest number of countries participating in the Olympics?
(SELECT Year, COUNT(DISTINCT NOC) AS NúmeroPaísesMAX From athlete_events GROUP BY Year ORDER BY NúmeroPaísesMax DESC LIMIT 1) 
UNION
(SELECT Year, COUNT(DISTINCT NOC) AS NúmeroPaísesMin From athlete_events GROUP BY Year ORDER BY NúmeroPaísesMin ASC LIMIT 1);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Which nation has participated in all the Olympic Games?
SELECT * FROM athlete_events;

SELECT NOC, COUNT(DISTINCT YEAR) AS Num_Participaciones From athlete_events GROUP BY NOC
HAVING Num_Participaciones = (SELECT COUNT(DISTINCT Year) FROM athlete_events);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Identify the sport that was played at all the Summer Olympics

CREATE TEMPORARY TABLE t1 (SELECT COUNT(DISTINCT games) AS total_juegos_verano FROM athlete_events WHERE season = 'Summer' ORDER BY games);

SELECT * FROM t1;

CREATE TEMPORARY TABLE t3 (SELECT sport, COUNT(games) AS Num_juegos
FROM (SELECT DISTINCT sport, games FROM athlete_events 
WHERE season = 'Summer' 
ORDER BY games) AS X 
GROUP BY sport);

Select * from t3;

SELECT t3.sport, t3.Num_Juegos FROM t3
INNER JOIN t1
ON t3.Num_juegos = t1.total_juegos_verano;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- IDENTIFY THE SPORT THAT WAS PLAYED IN ALL THE SUMMER GAMES
SELECT DISTINCT Sport
FROM athlete_events
WHERE Season = 'Summer'
GROUP BY Sport
HAVING COUNT(DISTINCT Year) = (SELECT COUNT(DISTINCT Year) FROM athlete_events
WHERE Season = 'Summer');


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- GET THE TOTAL NUMBER OF SPORTS PLAYED IN EACH GAME
SELECT * FROM athlete_events;

SELECT Games, COUNT(DISTINCT Sport) AS Total_Juegos FROM athlete_events GROUP BY Games;

-- Encuentra la proporción de atletas masculinos y femeninos que participaron en todos los JO--
SELECT * FROM athlete_events;


SELECT Year, 
	ROUND(MaleCount/TotalCount,2) AS Male_Proportion,
    ROUND(FemaleCount/TotalCount,2) AS Female_Proportion
FROM ( 
SELECT Year,
	COUNT(*) AS TotalCount,
    SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END) AS MaleCount,
    SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS FemaleCount
    FROM athlete_events
    GROUP BY Year) AS sq1
ORDER BY Year;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- FIND THE TOP 5 ATHLETES WHO HAVE WON THE MOST GOLD MEDALS--
CREATE TEMPORARY TABLE s1(
SELECT Name, COUNT(*) AS Total_medalla_oro FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
ORDER BY Total_medalla_oro DESC);

SELECT * FROM s1;

SELECT *
FROM (SELECT s1.*,
		DENSE_RANK () OVER(ORDER BY s1.Total_medalla_oro DESC) AS DRK
FROM s1) AS ranked
WHERE DRK <= 5;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- GET THE TOP 5 ATHLETES WHO HAVE WON THE MOST MEDALS (GOLD/SILVER/BRONZE) --

SELECT
	Name, 
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GOLD,
    SUM(CASE WHEN Medal = 'SILVER' THEN 1 ELSE 0 END) AS SILVER,
    SUM(CASE WHEN Medal = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE,
    COUNT(*) total_medals
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Name 
Order by Total_medals DESC 
LIMIT 5;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- THEY GET THE 5 MOST SUCCESSFUL COUNTRIES IN THE OLYMPIC GAMES -- 
SELECT *  FROM athlete_events;

SELECT
	Team AS Country, 
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GOLD,
    SUM(CASE WHEN Medal = 'SILVER' THEN 1 ELSE 0 END) AS SILVER,
    SUM(CASE WHEN Medal = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE,
    COUNT(*) total_medals
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team
Order by Total_medals DESC 
LIMIT 5;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- LIST THE TOTAL NUMBER OF GOLD, SILVER AND BRONZE MEDALS WON BY EACH COUNTRY --

SELECT
	Team AS Country, 
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GOLD,
    SUM(CASE WHEN Medal = 'SILVER' THEN 1 ELSE 0 END) AS SILVER,
    SUM(CASE WHEN Medal = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE,
    COUNT(*) AS total_medals
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team
ORDER BY Country;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- LIST THE TOTAL NUMBER OF OP AND BRO MEDALS FOR EACH COUNTRY IN RELATION TO EACH JOINT -- 
SELECT
	Team AS Country,
    Year AS Olimpic_year,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GOLD,
    SUM(CASE WHEN Medal = 'SILVER' THEN 1 ELSE 0 END) AS SILVER,
    SUM(CASE WHEN Medal = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team, Year
ORDER BY Country;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- IDENTIFY WHICH COUNTRY WON THE MOST OP AND B MEDALS IN EACH GAMES-- 

SELECT
	Year,
    Medal_Type,
    Winning_Country,
    Medal_Count,
    RANK() OVER(partition by Year, Medal_type Order by Medal_Count DESC) AS Country_Rank
FROM ( 
SELECT 
		Year,
        Team AS Winning_Country,
        Medal,
        COUNT(*) AS Medal_Count,
        CASE
			WHEN MEDAL = 'GOLD' THEN 'GOLD'
            WHEN MEDAL = 'SILVER' THEN 'SILVER'
            WHEN MEDAL = 'BRONZE' THEN 'BRONZE'
		END AS Medal_type
	From athlete_events
    WHERE Medal In ('Gold', 'Silver', 'Bronze')
    GROUP BY Year, Winning_Country, Medal) AS MedalCounts;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- IN WHICH SPORTS HAS INDIA WON THE MOST MEDALS? -- 

    SELECT Sport, Event,
             SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GOLD,
			 SUM(CASE WHEN Medal = 'SILVER' THEN 1 ELSE 0 END) AS SILVER,
			 SUM(CASE WHEN Medal = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE
             
FROM athlete_events
WHERE Team = 'India'  AND Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Sport, Event
Order by Gold  Desc, Silver Desc, Bronze DESC;
    
