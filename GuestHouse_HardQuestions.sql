https://sqlzoo.net/wiki/Guest_House_Assessment_Hard

-- Question 11.
-- Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening? 
-- Show the last name and both first names. Do not include duplicates.

-- **Methods i applied from top to down:**
-- Used pivoting with case statements
-- self joins for row search of same value
-- nested self join for join with other table
-- creation of date ranges
-- comparison of date ranges using exclusion from the upper and lower bounds.
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

####################
--Question 12.
--Check out per floor. The first digit of the room number indicates the floor – e.g. 
--room 201 is on the 2nd floor. For each day of the week beginning 2016-11-14 show
--how many rooms are being vacated that day by floor number. Show all days in the correct order.

-- **Hacks used to solve this:**
-- 1. To find the floor we cannot use substring_index because there is not delmiter. 
--   room_no is an id so is an integer so if i find the number of digits in id 
--   (ex 101) = 3 digits and if i create the 100 (using zero padding with RPAD)
--   and i do the division 101/100 = 1.01 i created the delimiter, then using 
--   substring_index i get the first digit (floor number).
-- 2. To pivot i used  CASE statements although without sum we get dublicates in 
--   checkout dates and is not the the requested format so i did a trick which is like 
--   doing WITH ROLL UP topically for each group of checkouts. 
--   Used the SUM taking into advantage the existence of numbers and NULLS 
--   (delete every SUM and check it)

SELECT checkout,
SUM((CASE WHEN floor = 1 THEN crooms END)) 1st_floor,
SUM((CASE WHEN floor = 2 THEN crooms END)) 2nd_floor,
SUM((CASE WHEN floor = 3 THEN crooms END)) 3rd_floor
FROM
(
SELECT DATE_ADD(b.booking_date, INTERVAL b.nights DAY) checkout, 
SUBSTRING_INDEX(b.room_no / RPAD('1',LENGTH(b.room_no),'0'),'.',1) floor,
COUNT(b.room_no) crooms
FROM booking b 
GROUP BY floor, checkout
HAVING checkout >= "2016-11-14"
ORDER BY checkout
)t
GROUP BY checkout

####################
--Question 13. 
--Free rooms? List the rooms that are free on the day 25th Nov 2016.

-- Main idea: find the used rooms with time range inside the target date and exclude them from the total rooms table. 
-- A second solution is using LEFT JOIN
-- ...room LEFT JOIN (SELECT b.room_no FROM booking b WHERE same as below)t ON ..ids.. WHERE t.room_no IS NULL
-- to get the difference between the two tables with respect to the first table: like (A-B) where A ⊇ B 

SELECT r.id
FROM room r
EXCEPT
SELECT r.id
FROM room r
JOIN booking b
ON(b.room_no = r.id)
WHERE b.booking_date <= '2016-11-25' AND
DATE_ADD(b.booking_date,INTERVAL b.nights DAY) 
   > '2016-11-25'
   
  #################### 
 -- Question 14.
 --Single room for three nights required. 
 --A customer wants a single room for three consecutive nights. Find the first available date in December 2016.
 
 -- Main strategy step by step:
 -- We cannot use EXCEPT because we have to provide more columns to a user than the available columns in room table 
 -- so we use LEFT JOIN,  LEAD with PARTITION BY ID to find the next afailable date for each room ID after the checkout for this room id
 -- We examine the cASE if the dirrerence next booking - last checkout > 3 or if there is not next booking date 
 -- so the room is free, then we get the first available room id and the rest usefull info 
 
SELECT ttt.free_room, ttt.checkout, closest_booking, ttt.room_type
FROM
(
SELECT tt.id, tt.room_type, tt.booking_date, tt.closest_booking, tt.checkout
,(CASE WHEN TIMESTAMPDIFF(DAY,tt.checkout,tt.closest_booking) > 3 OR tt.closest_booking IS NULL THEN tt.id END)free_room
FROM
(
SELECT r.id, r.room_type, t.booking_date, t.closest_booking, t.checkout
FROM room r
LEFT JOIN 
(
SELECT b.room_no, b.room_type_requested, b.booking_date, DATE_ADD(b.booking_date, INTERVAL b.nights DAY) checkout, 
        LEAD(b.booking_date, 1) OVER (
        PARTITION BY b.room_no
        ORDER BY b.booking_date
        ) closest_booking
FROM room r JOIN booking b 
ON (r.id = b.room_no)
WHERE YEAR(b.booking_date) = '2016' AND MONTH(b.booking_date) = '12' AND b.room_type_requested = 'single'
ORDER BY b.booking_date
)t
ON (r.id = t.room_no)
WHERE t.room_no IS NOT NULL
ORDER BY t.booking_date
)tt
)ttt
WHERE ttt.free_room IS NOT NULL
ORDER BY ttt.booking_date ASC
LIMIT 1

#################### 
-- Question 15.
-- Their Database is obsolete or fault and does not support the MAKEDATE or DAYOFWEEK or DAYNAME as a proper MySQL DB / MariaDB 
-- to solve this problem. 
 
