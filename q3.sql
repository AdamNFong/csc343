CREATE VIEW Alone AS
	SELECT assignment_id, AssignmentGroup.group_id FROM AssignmentGroup JOIN Membership ON Membership.group_id = AssignmentGroup.group_id 
	GROUP BY AssignmentID.group_id HAVING count(username)=1;

CREATE VIEW allassign AS
	SELECT assignment_id FROM Assignment;

CREATE VIEW solonulls AS
	SELECT * FROM allassign aA LEFT JOIN Alone al ON aA.assignment_id = al.assignment_id;

CREATE VIEW numsoloq AS
	SELECT sn.assignment_id, count(group_id) as solocount FROM solonulls sn GROUP BY assignment_id;

--percents

CREATE VIEW outOF AS
	SELECT assignment_id, weight * out_of as partialTotal FROM RubricItem;

CREATE VIEW totalOutOf AS
	SELECT assignment_id, sum (partialTotal) as total FROM outOF oo GROUP BY assignment_id;

CREATE VIEW percent2group AS
	SELECT assignment_id, group_id, mark / total as percent FROM AssignmentGroup JOIN Result JOIN totalOutOf too 
	ON too.assignment_id = AssignmentGroup.assignment_id and Result.group_id = AssignmentGroup.group_id;

CREATE VIEW grades AS
	SELECT sn.assignment_id, sn.group_id, p2g.percent FROM solonulls sn LEFT JOIN percent2group p2g ON sn.group_id = p2g.group_id;

CREATE VIEW averageq AS 
	SELECT assignment_id, avg(p2g.percent) as soloaverage FROM percent2group p2g GROUP BY assignment_id;

-- multi CHANGE
CREATE VIEW multi AS
	SELECT assignment_id, AssignmentGroup.group_id, username FROM AssignmentGroup JOIN Membership ON Membership.group_id = AssignmentGroup.group_id 
	GROUP BY assignment_id, AssignmentGroup.group_id HAVING count(username)>1;

CREATE VIEW multinulls AS
	SELECT * FROM allassign aA LEFT JOIN  multi m ON aA.assignment_id = m.assignment_id;

CREATE VIEW num_multiq AS
	SELECT assignment_id, count(username) as multicount FROM multinulls mn GROUP BY assignment_id;

CREATE VIEW DistinctGroups AS
	SELECT DISTINCT multin.assignment_id, multin.group_id FROM multinulls multin;

CREATE VIEW multigrades AS
	SELECT dg.assignment_id, group_id, p2g.percent FROM DistinctGroup dg LEFT JOIN percent2group p2g ON dg.group_id = p2g.group_id;

CREATE VIEW averageMulti AS
	SELECT mg.assignment_id, avg(mg.percent) as multiaverage FROM multigrades mg GROUP BY mg.assignment_id;

CREATE VIEW solos AS
	SELECT * FROM averageq aq JOIN numsoloq ns ON aq.assignment_id = ns.assignment_id;

CREATE VIEW multis AS
	SELECT * FROM averageMulti amu JOIN num_multiq nmu ON amu.assignment_id = nmu.assignment_id;

--last row

CREATE VIEW num_students AS
	SELECT assignment_id, count(username) as memCount FROM AssignmentGroup JOIN Membership ON Membership.group_id = AssignmentGroup.group_id GROUP BY assignment_id; 

CREATE VIEW average_num_students AS
	SELECT assignment_id, avg(memCount) as avgStuPerGroup FROM num_students ns GROUP BY assignment_id;

CREATE VIEW withoutDescription AS
	SELECT ss.assignment_id, ss.solocount as num_solo, ss.soloaverage as average_solo, ms.multicount as num_collaborators, ms.multiaverage as average_collaborators, ans.avgStuPerGroup as average_students_per_group
       FROM solos ss, multis ms, average_num_student ans WHERE ss.assignment_id = ms.assignment_id and ms.assignment_id = ans.assignment_id;

INSERT INTO q3 (SELECT wD.assignment_id, description, wD.num_solo, wD.average_solo, wD.num_collaborators, wD.average_collaborators, wD.average_students_per_group FROM withoutDescription wD JOIN Assignment 
ON wD.assignment_id = Assignment.assignment_id);
