SELECT * FROM IPL_Data


-- Count the number of matches won by each team:

SELECT winner, COUNT(*) AS total_wins 
FROM IPL_Data 
GROUP BY winner
ORDER BY total_wins DESC ;


-- Find the location where maximum matches were played:

SELECT TOP 1 location, COUNT(*) AS total_matches 
FROM IPL_Data 
GROUP BY location
ORDER BY total_matches DESC 


-- Number of matches stadium in each stadium:

SELECT stadium, COUNT(*) AS total_matches 
FROM IPL_Data 
GROUP BY stadium
ORDER BY total_matches DESC 



-- Find the player with the most 'Man of the Match' awards:

SELECT TOP 1 man_of_match, COUNT(*) AS total_awards 
FROM IPL_Data 
GROUP BY man_of_match 
ORDER BY total_awards DESC 



-- Find out the percentage of matches won by the toss-winning team:

SELECT 
    COUNT(CASE WHEN toss_won = winner THEN 1 END) * 100.0 / COUNT(*) AS percentage
FROM IPL_Data



-- Using CTE To find the number of matches where the team batting first won and their percentage

WITH BattingFirstWins AS (
    SELECT 
        COUNT(*) AS batting_first_wins,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM IPL_Data WHERE winner IS NOT NULL) AS percentage
    FROM IPL_Data
    WHERE winner IS NOT NULL AND team1 = winner
)
SELECT batting_first_wins, percentage
FROM BattingFirstWins;




-- Using CTE to calculate the number of matches won by each team :

WITH TeamWins AS (
    SELECT 
        team AS team_name,
        COUNT(*) AS total_wins
    FROM (
        SELECT winner AS team
        FROM IPL_Data
        WHERE winner IS NOT NULL
        UNION ALL
        SELECT team2 AS team
        FROM IPL_Data
        WHERE winner IS NOT NULL AND team1 = winner
    ) AS teams
    GROUP BY team
)
SELECT team_name, total_wins 
FROM TeamWins
ORDER BY total_wins DESC;



--Using temporary table to find the matches where the toss-winning team also won the match:

DROP TABLE IF EXISTS #TossWinner

CREATE TABLE #TossWinner (
    match_number INT,
    toss_won VARCHAR(50),
    winner VARCHAR(50)
);

INSERT INTO #TossWinner
SELECT match_number, toss_won, winner
FROM IPL_Data
WHERE toss_won = winner;

SELECT * FROM #TossWinner;



-- Toss Decision Analysis using CTE :

WITH TossDecisionAnalysis AS (
    SELECT 
        toss_won,
        COUNT(*) AS total_toss_wins,
        SUM(CASE WHEN toss_decision = 'bat' THEN 1 ELSE 0 END) AS bat_decisions,
        SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) AS field_decisions,
        (SUM(CASE WHEN toss_decision = 'bat' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS bat_decision_percentage,
        (SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS field_decision_percentage
    FROM 
        IPL_Data
    GROUP BY 
        toss_won
)
SELECT 
    toss_won,
    total_toss_wins,
    bat_decisions,
    bat_decision_percentage,
    field_decisions,
    field_decision_percentage
FROM 
    TossDecisionAnalysis
