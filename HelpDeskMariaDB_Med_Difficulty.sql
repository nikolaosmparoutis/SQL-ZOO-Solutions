Helpdesk Medium Questions
#################
6.
List the Company name and the number of calls for those companies with more than 18 calls.

SELECT  cu.company_name, COUNT(i.caller_id) num_calls
FROM  Customer cu 
 JOIN Caller ca ON (cu.company_ref=ca.company_ref)
 JOIN Issue i ON (ca.Caller_id=i.caller_id)
GROUP BY (cu.company_name)
HAVING COUNT(i.caller_id) > 18

Submit SQLRestore default
+------------------+----+
| Company_name     | cc |
+------------------+----+
| Gimmick Inc.     | 22 |
| Hamming Services | 19 |
| High and Co.     | 20 |
+------------------+----+

#################
7.
Find the callers who have never made a call. Show first name and last name

SELECT first_name, last_name
FROM  Customer cu JOIN Caller ca ON (cu.company_ref=ca.company_ref)
WHERE ca.caller_id NOT IN (
 SELECT ca.caller_id 
 FROM  Customer cu 
 JOIN Caller ca ON (cu.company_ref=ca.company_ref)
 JOIN Issue i ON (ca.Caller_id=i.caller_id)
)

+------------+-----------+
| first_name | last_name |
+------------+-----------+
| David      | Jackson   |
| Ethan      | Phillips  |
+------------+-----------+

#################
8.
For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5

SELECT cu.company_name, ca.first_name, ca.last_name, COUNT(ca.caller_id)
FROM Customer cu 
JOIN Caller ca ON (cu.company_ref = ca.company_ref)
JOIN Issue i ON (ca.caller_id=i.caller_id)
GROUP BY cu.company_name, ca.first_name, ca.last_name
HAVING COUNT(ca.caller_id) < 5

+--------------------+------------+-----------+----+
| Company_name       | first_name | last_name | nc |
+--------------------+------------+-----------+----+
| Pitiable Shipping  | Ethan      | McConnell |  4 |
| Rajab Group        | Emily      | Cooper    |  4 |
| Somebody Logistics | Ethan      | Phillips  |  2 |
+--------------------+------------+-----------+----+

#################
9.
For each shift show the number of staff assigned. Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').

SELECT sh.shift_date, sh.shift_type, COUNT(st.staff_code) num_workers
FROM Shift sh LEFT 
JOIN Staff st ON (
sh.Manager = st.staff_code OR
sh.Operator = st.staff_code OR
sh.Engineer1 = st.staff_code OR
sh.Engineer2 = st.staff_code )
GROUP BY sh.shift_date, sh.shift_type
ORDER BY sh.shift_date

+------------+------------+----+
| Shift_date | Shift_type | cw |
+------------+------------+----+
| 2017-08-12 | Early      |  4 |
| 2017-08-12 | Late       |  4 |
| 2017-08-13 | Early      |  3 |
| 2017-08-13 | Late       |  2 |
| 2017-08-14 | Early      |  4 |
| 2017-08-14 | Late       |  4 |
| 2017-08-15 | Early      |  4 |
| 2017-08-15 | Late       |  4 |
| 2017-08-16 | Early      |  4 |
| 2017-08-16 | Late       |  4 |
+------------+------------+----+

#################
10.
Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when.

SELECT  st.first_name,st.last_name, iss.call_date
FROM Issue iss 
 JOIN Caller cal ON (iss.caller_id = cal.caller_id)
 JOIN Staff st ON (st.staff_code = iss.taken_by)
WHERE iss.caller_id =
(SELECT distinct(ca.caller_id)
 FROM Caller ca 
 JOIN Issue i ON (ca.caller_id = i.caller_id)
 WHERE  ca.first_name = "Harry"
 )
AND iss.call_date = (
  SELECT recent_date.call_date 
  FROM Issue recent_date 
  JOIN Caller c_harry 
  ON (recent_date.caller_id = c_harry.caller_id)
  WHERE c_harry.first_name = "Harry"
  ORDER BY recent_date.call_date DESC
  LIMIT 1
  )

+------------+-----------+---------------------+
| first_name | last_name | call_date           |
+------------+-----------+---------------------+
| Emily      | Best      | 2017-08-16 10:25:00 |
+------------+-----------+---------------------+
