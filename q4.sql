
CREATE VIEW assigned AS
	SELECT grader.username, assignmentGroup.assignment_id, count(group_id) as assigned 
	FROM grader JOIN assignmentGroup ON grader.group_id =assignmentGroup.group_id 
	GROUP BY grader.username, assignmentmentGroup.assignment_id;

CREATE VIEW gradedAssignments AS
	SELECT assignmentGroup.assignment_id , grade.group_id FROM grade JOIN assignmentGroup ON assignmentGroup.group_id = grade.group_id;

CREATE VIEW num-graded AS
	SELECT assign.username , assign.assignment_id, count(gA.group_id) as graded 
	FROM assigned assign LEFT JOIN gradedAssignments gA ON assign.assignment_id = gA.assignment_id 
	GROUP BY (assign.username, assign.assignment_id);

CREATE VIEW notGraded AS
	SELECT assign.username, assign.assignment_id , (assign.assigned - nG.graded) as noGrade 
	FROM assigned assign JOIN num-graded nG ON assigned.assigment_id = nG.assignment_id and assign.username = nG.username;

CREATE VIEW combined AS
	SELECT nG.assignment_id, nG.username, nG.graded, notG.noGrade FROM num-graded nG JOIN notGraded notG ON nG.username = notG.username and ng.assignment_id = notG.assignment_id;

CREATE VIEW outOF AS
        SELECT assignment_id, weight * out_of as partialTotal FROM RubricItem;

CREATE VIEW totalOutOf AS
        SELECT assignment_id, sum (partialTotal) as total FROM outOF oo GROUP BY assignment_id;

CREATE VIEW percent2group AS
        SELECT AssignmentGroup.group_id, mark / total as percent FROM AssignmentGroup JOIN Result JOIN totalOutOf too
        ON too.assignment_id = AssignmentGroup.assignment_id and Result.group_id = AssignmentGroup.group_id;


INSERT INTO q4 (SELECT c.assignment_id as assignment_id, c.username as username, graded as num_marked, noGrade as num_not_marked, min(p2g.percent) as min_mark, max(p2g.percent) as max_mark
       	FROM combined c LEFT JOIN percent2group p2g ON c.assignment_id = p2g.assignment_id GROUP BY c.assignment_id, c.username);


