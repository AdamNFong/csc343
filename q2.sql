<!--Criteria 1 ->

CREATE VIEW shouldbe AS
	SELECT DISTINCT Grader.username, Assignment.assignemnt_id FROM Grader JOIN Assignment;

CREATE VIEW actual AS
	SELECT DISTINCT Grader.username, AssignmentGroup.assignment_id FROM Grader JOIN AssignmentGroup ON Grader.group_id = AssignmentGroup.group_id;

CREATE VIEW diff AS
	actual EXCEPT actual;

CREATE VIEW criterialI AS
	actual EXCEPT diff;

CREATE VIEW criteria1 AS
	SELECT c1.username FROM criteria1 c1;

<!--Criteria 2->

CREATE VIEW criteria2Int AS
	SELECT Grader.username FROM Grader JOIN AssiIgnmentGroup ON Grader.group_id = AssignmentGroup.group_id 
	GROUP BY Grader.username, AssignmentGroup.assignment_id 
	HAVING count(assignmentGroup.group_id) < 10;

CREATE VIEW criteria2 AS
	criteria EXCEPT criteria2Int;

<!--Criteria 3->

<!--START NEW QUERIES -->

CREATE VIEW outOf AS
	SELECT assignment_id, weight * out_of as partialTotal FROM RubricItem;

CREATE VIEW totalOutOf AS
	SELECT assignment_id, sum (partialTotal) as total FROM outOf oo GROUP BY assignment_id;

CREATE VIEW percent2group AS
	SELECT AssignmentGroup.assignment_id,AssignmentGroup.group_id, mark/total as percent FROM totalOutOf too JOIN AssignmentGroup JOIN Result 
	ON too.assignment_id = AssignmentGroup.assignment_id and AssignmentGroup.group_id = Result.group_id; 

<!--END NEW QUERIES-->

CREATE VIEW AGrade AS
	SELECT Grader.username, AssignmentGroup.assignment_id, p2g.percent FROM Membership JOIN AssignmentGroup JOIN percent2group p2g JOIN Grader 
	ON Membership.group_id = AssignmentGroup.group_id and AssignmentGroup.group_id = p2g.group_id and p2g.group_id = Grader.group_id;

CREATE VIEW averages AS
	SELECT AG.Username, AG.assignment_id, avg(AG.percent) as average FROM AGrade AG GROUP BY AG.username, AG.assignment_id;

CREATE VIEW dueDates AS
	SELECT av.username, av.assignment_id, av.average, Assignment.duedate FROM averages av JOIN Assignment ON av.assignment_id = Assignments.assignment_id;

CREATE VIEW allGraders AS
	SELECT dd.username FROM dueDates dd;

CREATE VIEW DecGrade AS
	SELECT d1.username FROM dueDates d1 JOIN dueDates d2 ON d1.username=d2.username and d1.assignment_id != d2.assignment_id and d1.average < d2.average and d1.duedate > d2.duedate;

CREATE VIEW criteria3 AS
	allGraders EXCEPT DecGraders;

CREATE VIEW allCriteria AS
	criteria2 INTERSECT criteria3;

CREATE VIEW allCGraderInfo AS
	SELECT aC.username, dD.assignment_id, dD.grade, dD.duedate FROM allCriteria aC JOIN dueDate dD ON dD.username = aC.username;

CREATE VIEW firstlast AS
	SELECT aCG.username, min(aCG.duedate) as mini, max(aCG.duedate) as maxi FROM allCGraderInfo aCG GROUP BY aCG.username;

CREATE VIEW firstlastInfo AS
	SELECT aCG.username, aCG.assignment_id, aCG.grade FROM allCGraderInfo aCG 
	JOIN firstlast fl ON (fl.mini = aCG.duedate or fl.maxi = aCG.duedate) and fl.username = aCG.username;

CREATE VIEW diffFirstLast AS
	SELECT fl1.username, (fl2.grade-fl1.grade) as Diff, fl1.assignment_id FROM firstlastInfo fl1 JOIN firstlastInfo fl2 
	ON fl1.username = fl2.username and fl1.grade < fl2.grade and fl1.assignment_id = fl2. assignment_id;

CREATE VIEW allaverage AS
	SELECT aCG.username, avg(aCG.grade) as Overallaverage FROM allCGraderInfo GROUP BY aCG.username;

CREATE VIEW finalUsers AS 
	SELECT dfl.username, aA.Overallaverage, dfl.Diff FROM diffFirstLast cfl JOIN allaverage aA ON cfl.username = aA.username;

INSERT INTO q2(SELECT (MarkusUser.firstname+' '+ MarkusUser.surname) as ta_name, fu.aOverallaverage as average_mark_all_assignments, fu.Diff as mark_change_first_last
FROM finalUsers fu JOIN MarkusUser ON MarkusUser.username = finalUsers.username WHERE MarkusUser.type ='TA');



