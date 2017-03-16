-- Distributions

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q1;

-- You must not change this table definition.
CREATE TABLE q1 (
	assignment_id integer,
	average_mark_percent real, 
	num_80_100 integer, 
	num_60_79 integer, 
	num_50_59 integer, 
	num_0_49 integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
CREATE VIEW allInfo1 AS
	SELECT Assignment.assignment_id, AssignmentGroup.group_id FROM Assignment LEFT JOIN AssignmentGroup ON Assignment.assignment_id = AssignmentGroup.assignment_id;

CREATE VIEW allInfo AS
	SELECT aI1.assignment_id, Result.mark FROM allInfo1 aI1 LEFT JOIN Result ON aI1.group_id = Result.group_id;  

CREATE VIEW allassign AS
  SELECT DISTINCT assignment_id FROM Assignment;
--percents

CREATE VIEW outOf AS
	SELECT assignment_id, out_of * weight as total FROM RubricItem;

CREATE VIEW totalOutOf AS
	SELECT assignment_id, sum(total) as ototal FROM outOf oo GROUP BY assignment_id;

CREATE VIEW percents AS
	SELECT aI.assignment_id, (aI.mark/too.ototal) * 100 as perc FROM allInfo aI JOIN totalOutOf too ON aI.assignment_id = too.assignment_id; 


CREATE VIEW average AS
	SELECT p.assignment_id, avg(p.perc) as avgg FROM percents p Group By p.assignment_id;

CREATE VIEW to100NoNulls AS
	SELECT assignment_id, perc FROM percents p WHERE p.perc>=80 and p.perc <=100;

CREATE VIEW to100 AS
	SELECT aa.assignment_id, count(nN.perc) as num1 FROM to100NoNulls nN RIGHT JOIN allassign aa ON aa.assignment_id = nN.assignment_id GROUP BY aa.assignment_id;  

CREATE VIEW to80NoNulls AS
	SELECT assignment_id,perc FROM percents p2 WHERE p2.perc>=60 and p2.perc <80;

CREATE VIEW to80 AS
	SELECT aa.assignment_id, count(nN.perc) as num2 FROM to80NoNulls nN RIGHT JOIN allassign aa ON aa.assignment_id = nN.assignment_id GROUP BY aa.assignment_id;  

CREATE VIEW to60NoNulls AS
	SELECT assignment_id, perc FROM percents p3 WHERE p3.perc>=50 and p3.perc <60;

CREATE VIEW to60 AS
	SELECT aa.assignment_id, count(nN.perc) as num3 FROM to60NoNulls nN RIGHT JOIN allassign aa ON aa.assignment_id = nN.assignment_id GROUP BY aa.assignment_id;  

CREATE VIEW to50NoNulls AS
	SELECT assignment_id, perc FROM percents p4 WHERE p4.perc <50;

CREATE VIEW to50 AS
	SELECT aa.assignment_id, count(nN.perc) as num4 FROM to50NoNulls nN RIGHT JOIN allassign aa ON aa.assignment_id = nN.assignment_id GROUP BY aa.assignment_id;   

INSERT INTO q1 SELECT a.assignment_id as assignment_id, a.avgg as average_mark_percent, c1.num1 as num_80_100, c2.num2 as num_60_79, c3.num3 as num_50_59, c4.num4 as num_0_49 
	FROM average a, to100 c1, to80 c2, to60 c3, to50 c4 
	WHERE a.assignment_id = c1.assignment_id and c1.assignment_id = c2.assignment_id and c2.assignment_id = c3.assignment_id and c3.assignment_id = c4.assignment_id;  
