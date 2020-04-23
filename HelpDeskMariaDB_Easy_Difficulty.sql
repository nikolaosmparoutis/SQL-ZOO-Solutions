Helpdesk Easy Questions
##################
1.
There are three issues that include the words "index" and "Oracle". Find the call_date for each of them

SELECT call_date, call_ref
FROM Issue
WHERE Detail like "%index%" and Detail like "%Oracle%"

+---------------------+----------+
| call_date           | call_ref |
+---------------------+----------+
| 2017-08-12 16:00:00 |     1308 |
| 2017-08-16 14:54:00 |     1697 |
| 2017-08-16 19:12:00 |     1731 |
+---------------------+----------+

##################
2.
Samantha Hall made three calls on 2017-08-14. Show the date and time for each

SELECT i.call_date, c.first_name, c.last_name 
FROM Issue i JOIN Caller c ON (i.Caller_id = c.Caller_id)
WHERE c.first_name = "Samantha" AND c.last_name = "Hall" 
AND 
i.call_date LIKE "%2017-08-14%"
GROUP BY i.call_date

+---------------------+------------+-----------+
| call_date           | first_name | last_name |
+---------------------+------------+-----------+
| 2017-08-14 10:10:00 | Samantha   | Hall      |
| 2017-08-14 10:49:00 | Samantha   | Hall      |
| 2017-08-14 18:18:00 | Samantha   | Hall      |
+---------------------+------------+-----------+

##################
3.
There are 500 calls in the system (roughly). Write a query that shows the number that have each status.

SELECT i.status,COUNT(i.status) Volume
FROM Issue i
GROUP BY i.status

+--------+--------+
| status | Volume |
+--------+--------+
| Closed |    486 |
| Open   |     10 |
+--------+--------+

##################
4.
Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?

SELECT COUNT(i.assigned_to) mlcc
FROM Issue i JOIN Staff s ON (i.assigned_to = s.staff_code)
   JOIN Level lv ON(s.level_code = lv.level_code)
WHERE lv.Manager IS NOT NULL


+------+
| mlcc |
+------+
|   51 |
+------+

##################
5.
Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.

SELECT sh.shift_date, sh.shift_type, st.first_name, st.last_name
FROM Shift sh JOIN Staff st ON (sh.Manager = st.staff_code)
ORDER BY sh.shift_date

+------------+------------+------------+-----------+
| Shift_date | Shift_type | first_name | last_name |
+------------+------------+------------+-----------+
| 2017-08-12 | Early      | Logan      | Butler    |
| 2017-08-12 | Late       | Ava        | Ellis     |
| 2017-08-13 | Early      | Ava        | Ellis     |
| 2017-08-13 | Late       | Ava        | Ellis     |
| 2017-08-14 | Early      | Logan      | Butler    |
| 2017-08-14 | Late       | Logan      | Butler    |
| 2017-08-15 | Early      | Logan      | Butler    |
| 2017-08-15 | Late       | Logan      | Butler    |
| 2017-08-16 | Early      | Logan      | Butler    |
| 2017-08-16 | Late       | Logan      | Butler    |
+------------+------------+------------+-----------+