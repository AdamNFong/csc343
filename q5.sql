CREATE VIEW GraderGroupCount AS
	SELECT username, count(Grader.group_id) as num_group, assignment_id FROM Grader JOIN AssignmentGroup ON AssignmentGroup.group_id = Grader.group_id GROUP BY username, assignment_id;

CREATE VIEW moreThan10 AS 
	SELECT assignment_id FROM GraderGroupCount a GROUP BY assignment_id HAVING (max(num_group) - min (num_group))>10;

INSERT INTO q5 (SELECT gGC.assignment_id, gGC.username, cGC.num_group as num_assigned FROM moreThan10 mt10 JOIN GraderGroupCount gGC ON gGC.assignment_id = mt10.assignment_id);

	
