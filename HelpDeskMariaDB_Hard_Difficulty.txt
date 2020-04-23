############
11.
SELECT sh.Manager, DATE_FORMAT(i.Call_date,"%Y-%m-%d, %H"), COUNT(DATE_FORMAT(i.Call_date,"%Y-%m-%d, %H"))
FROM Issue i
 JOIN Shift sh ON
 (DATE_FORMAT(i.Call_date,"%Y-%m-%d") 
  = DATE_FORMAT(sh.Shift_date,"%Y-%m-%d"))
WHERE i.call_date > "2017-08-12" AND i.call_date < "2017-08-13"
AND sh.Manager IS NOT NULL
AND
( sh.Shift_type = 'early'  AND
EXTRACT(HOUR FROM (i.Call_date)) BETWEEN 8 AND 13 -- Manager LB1 comes first from AE1 in shift_type table 
OR 
sh.Shift_type = 'late' AND
EXTRACT(HOUR FROM (i.Call_date)) BETWEEN 14 AND 20
)
GROUP BY sh.Manager, DATE_FORMAT(i.Call_date,"%Y-%m-%d, %H")
ORDER BY DATE_FORMAT(i.Call_date,"%Y-%m-%d, %H")

############

12
SELECT ROUND(0.2* COUNT(*),0)
INTO @count20PercRows
FROM(
 SELECT	Caller_id, COUNT(*) AS cc
 FROM Issue
 GROUP BY Caller_id
 ORDER BY COUNT(*) DESC
) AS count20PercRows;
SELECT @count20PercRows;

SET @all_calls := (
SELECT COUNT(*) AS cc 
FROM Issue
);
SELECT @all_calls;

PREPARE STMT FROM '
SELECT 100 * SUM(top20perc.calls_top20perc)/@all_calls
FROM(
 SELECT ca.caller_id, COUNT(ca.caller_id) calls_top20perc
 FROM Caller ca 
 JOIN Issue i ON (ca.caller_id = i.caller_id)
 GROUP BY ca.caller_id
 ORDER BY calls_top20perc DESC
 LIMIT ?) top20perc';

EXECUTE STMT USING @count20PercRows;

##############

13
SET @early_end := (SELECT end_time
FROM Shift_type
WHERE shift_type = "early"); 

SET @late_end := (SELECT end_time
FroM Shift_type
WHERE shift_type = "late");

SELECT t.company_name, company_calls
FROM(
 SELECT  cu.company_ref, cu.company_name, COUNT(ca.caller_id)  
 company_calls
 FROM Issue i 
  JOIN Caller ca ON (i.caller_id = ca.caller_id) 
  JOIN Customer cu ON (ca.company_ref = cu.company_ref)
  GROUP BY cu.company_ref, cu.company_name
  ORDER BY company_calls DESC
 )t 
WHERE t.company_ref NOT IN
 (SELECT cu.company_ref
 FROM Issue i 
 JOIN Caller ca ON (i.caller_id = ca.caller_id)
 JOIN Customer cu ON (ca.company_ref = cu.company_ref )
 WHERE SUBTIME(@early_end, DATE_FORMAT(i.call_date,"%H:%i")) 
 BETWEEN "00:00:00" AND "00:05:00"
 OR SUBTIME(@late_end, DATE_FORMAT(i.call_date,"%H:%i")) 
 BETWEEN "00:00:00" AND "00:05:00"
 GROUP BY ca.caller_id, cu.company_name
);
##############
14

SELECT tbl1.company_name, tbl1.caller_count, issue_count
FROM
	(SELECT cu.company_name,COUNT(ca.company_ref) AS caller_count
	FROM Customer cu
	JOIN Caller ca ON (cu.company_ref = ca.company_ref)
	GROUP BY cu.company_name
	) tbl1 
JOIN(
	SELECT cus.company_name,
       COUNT(DISTINCT(iss.caller_id)) AS issue_count
	FROM Customer cus
	JOIN Caller cal ON (cus.company_ref = cal.company_ref)
	JOIN Issue  iss ON (cal.caller_id = iss.caller_id)
	WHERE DATE(iss.call_date) = "2017-08-13"
	GROUP BY cus.company_name
	) tbl2
ON (tbl1.company_name = tbl2.company_name)
WHERE tbl1.caller_count = tbl2.issue_count;
 
#################

15
the online mysql/mariadb compiler of SQLZoo does not permit to CREATE VIEW, TEMPORARY tables, or INSERT with more than 
one row, as such i had to be more creative with long queries to distribute the logic and share it among the queries.

SET @seq_counter := 0;

SET @max_counts:= 
(
SELECT MAX(ttt_seq.labelling) + 1
	FROM (
		SELECT
		(CASE     
					WHEN  tt_seq.diff <= 10 
						  AND tt_seq.diff >= -10 THEN  
					@seq_counter := @seq_counter + 1           
					ELSE
					@seq_counter := 0 
								END
		 ) labelling
		FROM (
		  SELECT t_seq.call_date,
		  TIMESTAMPDIFF(MINUTE, t_seq.call_date_lead, 
                  t_seq.call_date) diff
		  FROM( SELECT iss.call_date,
				LEAD(call_date,1) OVER (ORDER BY iss.call_date) AS call_date_lead
			FROM Issue iss 
			ORDER BY iss.call_date
			) t_seq
		)tt_seq
	)ttt_seq
);

SELECT @max_counts;

SET @MaxSubseqLastCallDate:= (

SELECT ttt_seq.call_date_lead
FROM
	(
	
	SELECT  tt_seq.call_date_lead,
	(CASE     
				WHEN  tt_seq.diff <= 10 
						  AND tt_seq.diff >= -10 THEN  
				@seq_counter := @seq_counter + 1           
				ELSE
				@seq_counter := 0 
							END
	 ) labelling
	FROM (
	  SELECT  t_seq.call_date_lead,
	  TIMESTAMPDIFF(MINUTE, t_seq.call_date_lead, 
                  t_seq.call_date) diff
	  FROM( SELECT iss.call_date,
			LEAD(call_date,1) OVER (ORDER BY iss.call_date) AS call_date_lead
		FROM Issue iss 
		ORDER BY iss.call_date
	   ) t_seq
	)tt_seq
) ttt_seq
WHERE ttt_seq.labelling = @max_counts - 1
);

SELECT @MaxSubseqLastCallDate ;


SET @MaxSubseqLastID:= (

SELECT ttt_seq.caller_id
FROM
	(
	SELECT  tt_seq.caller_id,
	(CASE     
				WHEN  tt_seq.diff <= 10 
						  AND tt_seq.diff >= -10 THEN  
				@seq_counter := @seq_counter + 1           
				ELSE
				@seq_counter := 0 
							END
	 ) labelling
	FROM (
	  SELECT t_seq.caller_id,
	  TIMESTAMPDIFF(MINUTE, t_seq.call_date_lead, 
                  t_seq.call_date) diff
	  FROM( SELECT iss.caller_id, iss.call_date,
			LEAD(call_date,1) OVER (ORDER BY iss.call_date) AS call_date_lead
		FROM Issue iss 
		ORDER BY iss.call_date
	   ) t_seq
	)tt_seq
) ttt_seq
WHERE ttt_seq.labelling = @max_counts - 1
);

SELECT @MaxSubseqLastID;

SET @rownum := 0;

SET @last_rownumInMaxsequence := (SELECT iss_.rownum
		FROM ( SELECT iss.*, @rownum := @rownum +1 AS rownum FROM Issue iss ORDER BY iss.call_date )iss_ 
                WHERE iss_.call_date = @MaxSubseqLastCallDate
                AND
                iss_.caller_id = @MaxSubseqLastID + 1
                ORDER BY iss_.call_date

);
SELECT @last_rownumInMaxsequence;

SET @rownum := 0;

SET @first_dateInMaxSeq := 
(SELECT  iss__.call_date
FROM ( SELECT iss.*, @rownum := @rownum +1 AS rownum FROM Issue iss ORDER BY iss.call_date)iss__
WHERE iss__.rownum = @last_rownumInMaxsequence - @max_counts + 1
ORDER BY iss__.call_date
);

SET @rownum := 0;
SET @takenby :=
(SELECT  iss__.taken_by
FROM ( 
   SELECT iss.*, @rownum := @rownum + 1 AS rownum 
   FROM Issue iss 
   ORDER BY iss.call_date)iss__
WHERE iss__.rownum = (@last_rownumInMaxsequence - @max_counts)
ORDER BY iss__.call_date
);

SELECT @takenby taken_by, @first_dateInMaxSeq first_call , @MaxSubseqLastCallDate last_call, @max_counts counts
