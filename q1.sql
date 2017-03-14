CREATE VIEW allInfo1 AS
	SELECT Assignment.assignment_id, AssignmentGroup.group_id FROM Assignment LEFT JOIN AssignmentGroup ON Assignment.assignmentID = AssignmentGroup.assignmentID;

CREATE VIEW allInfo AS
	SELECT aI1.assignment_id, Grade.grade FROM (allinfo1) aI1 LEFT JOIN Grade ON aI1.groupID = Grade.groupID;  

CREATE VIEW average AS
	SELECT aI.assignment_id, avg(aI.grade) as avgg FROM (allInfo) aI Group By aI.assinment_id;

CREATE VIEW 80to100nNoNulls AS
	SELECT aI.assignment_id FROM (allInfo) aI WHERE aI.grade>=80 and aI.grade <=100;

CREATE VIEW 80to100 AS
	SELECT aI.assignment_id, count(aI.grade) as num1 FROM (80to100NoNulls) nN RIGHT JOIN (allInfo) aI GROUP BY aI.assignment_id;  

CREATE VIEW 60to80nNoNulls AS
	SELECT aI.assignment_id FROM (allInfo) aI WHERE aI.grade>=60 and aI.grade <80;

CREATE VIEW 60to80 AS
	SELECT aI.assignment_id, count(aI.grade) as num2 FROM (60to80NoNulls) nN RIGHT JOIN (allInfo) aI GROUP BY aI.assignment_id;  

CREATE VIEW 50to60nNoNulls AS
	SELECT aI.assignment_id FROM (allInfo)aI WHERE aI.grade>=50 and aI.grade <60;

CREATE VIEW 50to60 AS
	SELECT aI.assignment_id, count(aI.grade) as num3 FROM (50to60NoNulls) nN RIGHT JOIN (allInfo) aI GROUP BY aI.assignment_id;  

CREATE VIEW 0to50nNoNulls AS
	SELECT aI.assignment_id FROM (allInfo)aI WHERE aI.grade <50;

CREATE VIEW 0to50 AS
	SELECT aI.assignment_id, count(aI.grade) as num3 FROM (0to50NoNulls) nN RIGHT JOIN (allInfo) aI GROUP BY aI.assignment_id;  

INSERT INTO q1(SELECT a.assignment as assignment_id, a.avgg as average_mark_percent, c1.num1 as num_80_100, c2.num2 as num_60_79, c3.num3 as num_50_59, c4.num4 as num_0_49 
	FROM average a, 80to100 c1, 60to80 c2, 50to60 c3, 0to50 c4 
	WHERE a.assignment_id = c1.assignment_id and c1.assignment_id = c2.assignment_id and c2.assignment_id = c3.assignment_id and c3.assignment_id = c4.assignment_id);  
