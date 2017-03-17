-- Solo superior

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q3;

-- You must not change this table definition.
CREATE TABLE q3 (
	assignment_id integer,
	description varchar(100), 
	num_solo integer, 
	average_solo real,
	num_collaborators integer, 
	average_collaborators real, 
	average_students_per_submission real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

CREATE VIEW Alone AS
	SELECT assignment_id, AssignmentGroup.group_id FROM AssignmentGroup JOIN Membership ON Membership.group_id = AssignmentGroup.group_id 
	GROUP BY AssignmentGroup.group_id HAVING count(username)=1;

CREATE VIEW allassign AS
	SELECT assignment_id FROM Assignment;

CREATE VIEW solonulls AS
	SELECT aA.assignment_id, al.group_id FROM allassign aA LEFT JOIN Alone al ON aA.assignment_id = al.assignment_id;

CREATE VIEW numsoloq AS
	SELECT sn.assignment_id, count(group_id) as solocount FROM solonulls sn GROUP BY assignment_id;

--percents

CREATE VIEW outOF AS
	SELECT assignment_id, weight * out_of as partialTotal FROM RubricItem;

CREATE VIEW totalOutOf AS
	SELECT assignment_id, sum (partialTotal) as total FROM outOF oo GROUP BY assignment_id;

CREATE VIEW percent2group AS
	SELECT too.assignment_id, AssignmentGroup.group_id, (mark / total) * 100 as percent FROM AssignmentGroup, Result, totalOutOf too 
	WHERE too.assignment_id = AssignmentGroup.assignment_id and Result.group_id = AssignmentGroup.group_id;

CREATE VIEW grades AS
	SELECT sn.assignment_id, sn.group_id, p2g.percent FROM solonulls sn LEFT JOIN percent2group p2g ON sn.group_id = p2g.group_id ORDER by sn.assignment_id ASC;

CREATE VIEW averageq AS 
	SELECT assignment_id, avg(g.percent) as soloaverage FROM grades g GROUP BY assignment_id;

-- multi CHANGE
CREATE VIEW multi AS
	SELECT assignment_id, AssignmentGroup.group_id, username FROM AssignmentGroup JOIN Membership 
  ON Membership.group_id = AssignmentGroup.group_id;

CREATE VIEW multiCount AS
  SELECT assignment_id, group_id, count(username) as cUsername from multi m Group BY assignment_id, group_id;
  
CREATE VIEW multiusers AS
  SELECT assignment_id, m.group_id, username FROM multiCount m JOIN Membership on Membership.group_id = m.group_id WHERE m.cUsername >1;
----------

CREATE VIEW multinulls AS
	SELECT aA.assignment_id, m.group_id, m.username FROM allassign aA LEFT JOIN  multiusers m ON aA.assignment_id = m.assignment_id;

CREATE VIEW num_multiq AS
	SELECT assignment_id, count(username) as multicount FROM multinulls mn GROUP BY assignment_id;

CREATE VIEW DistinctGroups AS
	SELECT DISTINCT multin.assignment_id, multin.group_id FROM multinulls multin;

CREATE VIEW multigrades AS
	SELECT dg.assignment_id, dg.group_id, p2g.percent FROM DistinctGroups dg LEFT JOIN percent2group p2g ON dg.group_id = p2g.group_id;

CREATE VIEW averageMulti AS
	SELECT mg.assignment_id, avg(mg.percent) as multiaverage FROM multigrades mg GROUP BY mg.assignment_id;

CREATE VIEW solos AS
	SELECT aq.assignment_id, soloaverage, solocount FROM averageq aq JOIN numsoloq ns ON aq.assignment_id = ns.assignment_id;

CREATE VIEW multis AS
	SELECT nmu.assignment_id, multiaverage, multicount FROM averageMulti amu JOIN num_multiq nmu ON amu.assignment_id = nmu.assignment_id;

--last row
Create VIEW num_groups_per_assignment AS
  SELECT assignment_id, count(group_id) as groupCount FROM AssignmentGroup GROUP BY assignment_id; 

CREATE VIEW num_students AS
	SELECT assignment_id, count(username) as memCount FROM AssignmentGroup JOIN Membership ON Membership.group_id = AssignmentGroup.group_id GROUP BY assignment_id; 

CREATE VIEW average_num_students AS
	SELECT ns.assignment_id, (memCount*1.0)/(groupCount*1.0) as avgStuPerGroup FROM num_students ns, num_groups_per_assignment ngpa 
  WHERE ngpa.assignment_id = ns.assignment_id;

CREATE VIEW withoutDescription AS
	SELECT ss.assignment_id, ss.solocount as num_solo, ss.soloaverage as average_solo, ms.multicount as num_collaborators, ms.multiaverage as average_collaborators, ans.avgStuPerGroup as average_students_per_submission
       FROM solos ss, multis ms, average_num_students ans WHERE ss.assignment_id = ms.assignment_id and ms.assignment_id = ans.assignment_id;

INSERT INTO q3 SELECT wD.assignment_id, description, wD.num_solo, wD.average_solo, wD.num_collaborators, wD.average_collaborators, wD.average_students_per_submission FROM withoutDescription wD JOIN Assignment 
ON wD.assignment_id = Assignment.assignment_id;
