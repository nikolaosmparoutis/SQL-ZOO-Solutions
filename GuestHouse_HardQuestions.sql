
-- Question 11.
-- Methods i applied from top to down:
-- Used pivoting with case statements
-- self joins for row search of same value
-- nested self join for join with other table
-- creation of date ranges
-- comparison of date ranges
-- rows distinction using group by at the end (DISTINCT CASE did not produce the distinction)
-- (the online compiler does not allow to do DDL with temporary table).

SELECT 
(CASE WHEN t1.last_name = t2.last_name AND t1.first_name != t2.first_name THEN t1.last_name END) last_name,
(CASE WHEN t1.last_name = t2.last_name AND t1.first_name != t2.first_name THEN t1.first_name END) first_name_pers1,
(CASE WHEN t1.last_name = t2.last_name AND t1.first_name != t2.first_name THEN t2.first_name END) first_name_pers2
FROM 
(
 SELECT
 DISTINCT(t_same_ln.id),
 t_same_ln.last_name, 
 t_same_ln.first_name,
 b.booking_date,
 b.nights
 FROM
 (SELECT 
  g.id, 
  g.first_name, 
  g.last_name
  FROM guest as g JOIN guest gu 
  ON (g.last_name = gu.last_name) 
  WHERE g.id != gu.id
  ORDER BY g.last_name
  )t_same_ln
  JOIN booking b 
 ON(t_same_ln.id = b.guest_id)
)t1 
JOIN 
(
 SELECT
 DISTINCT(t_same_ln.id),
 t_same_ln.last_name, 
 t_same_ln.first_name,
 b.booking_date,
 b.nights
 FROM
 (SELECT 
  g.id, 
  g.first_name, 
  g.last_name
  FROM guest as g JOIN guest gu 
  ON (g.last_name = gu.last_name) 
  WHERE g.id != gu.id
  ORDER BY g.last_name
  )t_same_ln
  JOIN booking b 
  ON(t_same_ln.id = b.guest_id)
 )t2

ON (t1.last_name = t2.last_name)
AND t1.booking_date <=
 DATE_ADD(t2.booking_date, INTERVAL (t2.nights-1) DAY) 
AND DATE_ADD(t1.booking_date, INTERVAL (t1.nights-1) DAY) >=
 t2.booking_date
WHERE t1.id != t2.id
AND t1.first_name != t2.first_name

GROUP BY t1.last_name  
ORDER BY t1.last_name

