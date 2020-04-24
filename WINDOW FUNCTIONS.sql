
--From this lesson i keep: 
--1. partition by works *like* group by but is for window functions.
--Group by affects the number of rows returned,
--partition does not affect the num of rows returned but affects 
--how windows functions' result is calculationed. 
--2. To do an action on RANK create the rank inside a subquery then outer process the RANK.

1.
Show the lastName, party and votes for the constituency 'S14000024' in 2017.

SELECT lastName, party, votes
  FROM ge
 WHERE constituency = 'S14000024' AND yr = 2017
ORDER BY votes DESC

2.
Show the party and RANK for constituency S14000024 in 2017. List the output by party

SELECT party, votes,
       RANK() OVER (ORDER BY votes DESC) as posn
  FROM ge
 WHERE constituency = 'S14000024' AND yr = 2017
ORDER BY  party

3.
Use PARTITION to show the ranking of each party in S14000021 in each year. Include yr, party, votes and ranking (the party with the most votes is 1).

SELECT yr,party, votes, RANK() OVER (PARTITION BY yr ORDER BY votes DESC) as posn
FROM ge
WHERE constituency = 'S14000021'
ORDER BY party,yr


4.
Edinburgh constituencies are numbered S14000021 to S14000026.
Use PARTITION BY constituency to show the ranking of each party in Edinburgh in 2017. Order your results so the winners are shown first, then ordered by constituency.

SELECT ge.constituency, party, votes,
  RANK() OVER(PARTITION BY ge.constituency ORDER BY ge.votes DESC) 
   posn
 FROM ge
 WHERE ge.constituency BETWEEN 'S14000021' AND 'S14000026'
   AND yr  = 2017
ORDER BY posn, constituency

5.
Show the parties that won for each Edinburgh constituency in 2017.

SELECT t_posn.constituency, t_posn.party
FROM  
 (SELECT constituency, party, votes, 
 RANK()OVER(PARTITION BY constituency ORDER BY 
 votes DESC) posn
 FROM ge
 WHERE constituency BETWEEN 'S14000021' AND 'S14000026' AND yr  = 2017
 ORDER BY constituency ,votes DESC)
t_posn
WHERE t_posn.posn = 1

6.
You can use COUNT and GROUP BY to see how each party did in Scotland. Scottish constituencies start with 'S'
Show how many seats for each party in Scotland in 2017.

SELECT t_posn.party, COUNT(*)
FROM
 (SELECT party, RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) posn  
  FROM ge
  WHERE yr = 2017 AND constituency LIKE "S%"
  ORDER BY constituency, votes DESC
 )t_posn
WHERE t_posn.posn = 1
GROUP BY t_posn.party
