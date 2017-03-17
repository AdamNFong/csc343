

-- Getting soft

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q2;

-- You must not change this table definition.
CREATE TABLE q2 (
	ta_name varchar(100),
	average_mark_all_assignments real,
	mark_change_first_last real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

CREATE VIEW shouldbe AS
	SELECT DISTINCT Grader.username, Assignment.assignment_id FROM Grader, Assignment;

CREATE VIEW actual AS
	SELECT DISTINCT Grader.username, AssignmentGroup.assignment_id FROM Grader JOIN AssignmentGroup ON Grader.group_id = AssignmentGroup.group_id;

CREATE VIEW diff AS
  SELECT * from shouldbe
  EXCEPT
	SELECT * from actual;
 
 CREATE VIEW diff2 AS
   SELECT distinct username from grader
   EXCEPT
   SELECT d.username from diff d;
        
CREATE VIEW criteria1 AS
	SELECT distinct dif.username FROM diff2 dif;

--Criteria 2->

CREATE VIEW criteria2Int AS
	SELECT Grader.username FROM Grader, AssignmentGroup, Assignment 
  where Grader.group_id = AssignmentGroup.group_id and AssignmentGroup.assignment_id = Assignment.assignment_id
	GROUP BY Grader.username, AssignmentGroup.assignment_id 
	HAVING count(assignmentGroup.group_id) < 10;

CREATE VIEW criteria2 AS
	Select * From criteria1 c 
  EXCEPT 
  SELECT * from criteria2Int c2I;

--Criteria 3->

--START NEW QUERIES -->

CREATE VIEW outOf AS
	SELECT assignment_id, weight * out_of as partialTotal FROM RubricItem;

CREATE VIEW totalOutOf AS
	SELECT assignment_id, sum (partialTotal) as total FROM outOf oo GROUP BY assignment_id;

CREATE VIEW percent2group1 AS
	SELECT AssignmentGroup.assignment_id, AssignmentGroup.group_id, total FROM totalOutOf too JOIN AssignmentGroup ON too.assignment_id = AssignmentGroup.assignment_id;
  
 CREATE VIEW percent2group AS
	SELECT p2g1.assignment_id, p2g1.group_id, (mark/total)*100 as percent FROM percent2group1 p2g1 JOIN Result ON p2g1.group_id = Result.group_id; 

--END NEW QUERIES-->

 CREATE VIEW AGrade AS
	SELECT Grader.username, AssignmentGroup.assignment_id, p2g.percent FROM Membership, AssignmentGroup, percent2group p2g, Grader 
	WHERE Membership.group_id = AssignmentGroup.group_id and AssignmentGroup.group_id = p2g.group_id and p2g.group_id = Grader.group_id;

CREATE VIEW averages AS
	SELECT AG.Username, AG.assignment_id, avg(AG.percent) as average FROM AGrade AG GROUP BY AG.username, AG.assignment_id;

CREATE VIEW dueDates AS
	SELECT av.username, av.assignment_id, av.average, Assignment.due_date FROM averages av JOIN Assignment ON av.assignment_id = Assignment.assignment_id;

CREATE VIEW allGraders AS
	SELECT dd.username FROM dueDates dd;

CREATE VIEW DecGrade AS
	SELECT d1.username FROM dueDates d1 JOIN dueDates d2 ON d1.username=d2.username and d1.assignment_id != d2.assignment_id and d1.average < d2.average and d1.due_date > d2.due_date;

CREATE VIEW criteria3 AS
	Select * from allGraders ag 
  EXCEPT 
  Select * from DecGrade dg;

CREATE VIEW allCriteria AS
	select * from criteria2 a
  INTERSECT 
  select * from criteria3 b;

CREATE VIEW allCGraderInfo AS
	SELECT aC.username, dD.assignment_id, dD.average as grade, dD.due_date FROM allCriteria aC JOIN dueDates dD ON dD.username = aC.username;

CREATE VIEW firstlast AS
	SELECT aCG.username, min(aCG.due_date) as mini, max(aCG.due_date) as maxi FROM allCGraderInfo aCG GROUP BY aCG.username;

CREATE VIEW firstlastInfo AS
	SELECT aCG.username, aCG.assignment_id, aCG.grade FROM allCGraderInfo aCG 
	JOIN firstlast fl ON (fl.mini = aCG.due_date or fl.maxi = aCG.due_date) and fl.username = aCG.username;

CREATE VIEW diffFirstLast AS
	SELECT fl1.username, (fl2.grade-fl1.grade) as Diff, fl1.assignment_id FROM firstlastInfo fl1 JOIN firstlastInfo fl2 
	ON fl1.username = fl2.username and fl1.grade < fl2.grade and fl1.assignment_id != fl2. assignment_id;

CREATE VIEW allaverage AS
	SELECT aCG.username, avg(aCG.grade) as Overallaverage FROM allCGraderInfo aCG GROUP BY aCG.username;

CREATE VIEW finalUsers AS 
	SELECT dfl.username, aA.Overallaverage, dfl.Diff FROM diffFirstLast dfl JOIN allaverage aA ON dfl.username = aA.username;

INSERT INTO q2 SELECT CONCAT (MarkusUser.firstname, ' ', MarkusUser.surname) as ta_name, fu.Overallaverage as average_mark_all_assignments, fu.Diff as mark_change_first_last
FROM finalUsers fu JOIN MarkusUser ON MarkusUser.username = fu.username WHERE MarkusUser.type ='TA';



