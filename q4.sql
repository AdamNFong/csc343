-- Grader report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q4;

-- You must not change this table definition.
CREATE TABLE q4 (
	assignment_id integer,
	username varchar(25), 
	num_marked integer, 
	num_not_marked integer,
	min_mark real,
	max_mark real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

CREATE VIEW assigned AS
	SELECT grader.username, assignmentGroup.assignment_id, count(Grader.group_id) as assigned 
	FROM grader JOIN assignmentGroup ON grader.group_id =assignmentGroup.group_id 
	GROUP BY grader.username, assignmentGroup.assignment_id;

CREATE VIEW gradedAssignments AS
	SELECT assignmentGroup.assignment_id , Result.group_id FROM Result JOIN assignmentGroup ON assignmentGroup.group_id = Result.group_id;

CREATE VIEW GradedAssignmentsGraders AS
  SELECT gA.assignment_id, gA.group_id, username FROM gradedAssignments gA JOIN Grader ON gA.group_id = Grader.group_id; 

CREATE VIEW num_graded AS
	SELECT assign.username , assign.assignment_id, count(gA.group_id) as graded 
	FROM assigned assign LEFT JOIN gradedAssignmentsGraders gA ON assign.assignment_id = gA.assignment_id and gA.username = assign.username
	GROUP BY assign.username, assign.assignment_id;

CREATE VIEW notGraded AS
	SELECT assign.username, assign.assignment_id , (assign.assigned - nG.graded) as noGrade 
	FROM assigned assign JOIN num_graded nG ON assign.assignment_id = nG.assignment_id and assign.username = nG.username;

CREATE VIEW combined AS
	SELECT nG.assignment_id, nG.username, nG.graded, notG.noGrade FROM num_graded nG JOIN notGraded notG ON nG.username = notG.username and ng.assignment_id = notG.assignment_id;

CREATE VIEW outOF AS
        SELECT assignment_id, weight * out_of as partialTotal FROM RubricItem;

CREATE VIEW totalOutOf AS
        SELECT assignment_id, sum (partialTotal) as total FROM outOF oo GROUP BY assignment_id;

CREATE VIEW percent2group AS
        SELECT too.assignment_id ,AssignmentGroup.group_id, (mark / total)*100 as percent FROM AssignmentGroup, Result, totalOutOf too
        WHERE too.assignment_id = AssignmentGroup.assignment_id and Result.group_id = AssignmentGroup.group_id;

CREATE VIEW p2gUsers AS
        SELECT p2g.assignment_id, p2g.group_id, p2g.percent, username FROM percent2group p2g JOIN Grader ON Grader.group_id = p2g.group_id;

CREATE VIEW minmax AS
        SELECT p2gu.assignment_id, min (p2gu.percent) as mini, max (p2gu.percent) as maxi, username FROM p2gUsers p2gu GROUP BY assignment_id, username;
        
CREATE VIEW cminmax AS
        SELECT c.assignment_id, c.username, graded, noGrade, mini, maxi FROM minmax m RIGHT JOIN combined c ON m.assignment_id = c.assignment_id and m.username = c.username;

INSERT INTO q4 SELECT assignment_id, username, graded as num_marked, noGrade as num_not_marked, mini as min_mark, maxi as max_mark from cminmax;



