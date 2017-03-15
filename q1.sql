CREATE VIEW allInfo1 AS
	SELECT Assignment.assignment_id, AssignmentGroup.group_id FROM Assignment LEFT JOIN AssignmentGroup ON Assignment.assignment_id = AssignmentGroup.assignment_id;

CREATE VIEW allInfo AS
	SELECT aI1.assignment_id, Result.mark FROM (allinfo1) aI1 LEFT JOIN Result ON aI1.group_id = Result.group_id;  

<!--percents-->

CREATE VIEW outOf AS
	SELECT assignment_id, out_of * weight as total FROM RubricItem;

CREATE VIEW totalOutOf AS
	SELECT assignment_id, sum (total) as ototal FROM outOf oo GROUP BY assignment_id;

CREATE VIEW percents AS
	SELECT aI.assignment_id, aI.mark/too.ototal as perc FROM allInfo aI JOIN totalOutOf too ON aI.assignment_id = too.assignment_id; 


CREATE VIEW average AS
	SELECT p.assignment_id, avg(p.perc) as avgg FROM (percents) p Group By p.assignment_id;

CREATE VIEW 80to100NoNulls AS
	SELECT assignment_id, perc FROM (percents) p WHERE p.perc>=80 and p.perc <=100;

CREATE VIEW 80to100 AS
	SELECT p.assignment_id, count(p.perc) as num1 FROM (80to100NoNulls) nN RIGHT JOIN (percents) p ON p.assignment_id = nN.assignment_id and p.perc = nN.perc GROUP BY p.assignment_id;  


	

CREATE VIEW 60to80nNoNulls AS
	SELECT assignment_id,perc FROM (percents) p2 WHERE p2.perc>=60 and p2.perc <80;

CREATE VIEW 60to80 AS
	SELECT p2.assignment_id, count(p2.perc) as num2 FROM (60to80NoNulls) nN RIGHT JOIN (percents) p2 ON p2.assignment_id = nN.assignment_id and p2.perc = nN.perc GROUP BY p2.assignment_id;  

CREATE VIEW 50to60nNoNulls AS
	SELECT assignment_id, perc FROM (percents)p3 WHERE p3.perc>=50 and p3.perc <60;

CREATE VIEW 50to60 AS
	SELECT p3.assignment_id, count(p3.perc) as num3 FROM (50to60NoNulls) nN RIGHT JOIN (percents) p3 ON p3.assignment_id = nN.assignment_id and p3.perc = nN.perc GROUP BY p4.assignment_id;  

CREATE VIEW 0to50nNoNulls AS
	SELECT assignment_id, perc FROM (percents)p4 WHERE p4.perc <50;

CREATE VIEW 0to50 AS
	SELECT p4.assignment_id, count(p4.perc) as num3 FROM (0to50NoNulls) nN RIGHT JOIN (percents) p4 ON p4.assignment_id = nN.assignment_id and p4.perc =nN.perc GROUP BY p4.assignment_id;   

INSERT INTO q1(SELECT a.assignment as assignment_id, a.avgg as average_mark_percent, c1.num1 as num_80_100, c2.num2 as num_60_79, c3.num3 as num_50_59, c4.num4 as num_0_49 
	FROM average a, 80to100 c1, 60to80 c2, 50to60 c3, 0to50 c4 
	WHERE a.assignment_id = c1.assignment_id and c1.assignment_id = c2.assignment_id and c2.assignment_id = c3.assignment_id and c3.assignment_id = c4.assignment_id);  
