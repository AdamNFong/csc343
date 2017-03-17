-- Uneven workloads

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q5;

-- You must not change this table definition.
CREATE TABLE q5 (
	assignment_id integer,
	username varchar(25), 
	num_assigned integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW GraderGroupCount AS
	SELECT username, count(Grader.group_id) as num_group, assignment_id FROM Grader JOIN AssignmentGroup ON AssignmentGroup.group_id = Grader.group_id GROUP BY username, assignment_id;

CREATE VIEW moreThan10 AS 
	SELECT assignment_id FROM GraderGroupCount a GROUP BY assignment_id HAVING (max(num_group) - min (num_group))>3;

INSERT INTO q5 SELECT gGC.assignment_id, gGC.username, gGC.num_group as num_assigned FROM moreThan10 mt10 JOIN GraderGroupCount gGC ON gGC.assignment_id = mt10.assignment_id;

	
