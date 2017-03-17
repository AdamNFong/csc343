insert into Assignment values 
(1, 'n/a1', '2015-12-12 12:12:12', 1, 5),
(2, 'n/a2', '2016-12-12 12:12:12', 1, 5),
(3, 'n/a3', '2016-12-12 12:12:12', 1, 5);


insert into AssignmentGroup values
(1, 1, 'sda'),
(2, 1, 'sdasd'),
(3, 1, 'sdasd'),
(4, 1, 'sdasd'),
(5, 1, 'asdasda'),
(6, 1, 'sdasd'),
(7, 1, 'sdasd'),
(8, 1, 'sdasd'),
(9, 1, 'sdasd'),
(10, 1, 'asdasd'),

(11, 2, 'sda'),
(12, 2, 'sdasd'),
(13, 2, 'sdasd'),
(14, 2, 'sdasd'),
(15, 2, 'asdasda'),
(16, 2, 'sdasd'),
(17, 2, 'sdasd'),
(18, 2, 'sdasd'),
(19, 2, 'sdasd'),
(20, 2, 'asdasd'),
(21, 3, 'asdasd');

insert into MarkusUser values
('fongadam', 'fong', 'adam', 'TA'),
('shethparth', 'sheth', 'parth', 'TA'),
('yeestephen', 'yee', 'stephen', 'TA'),
('s1', 's1', 's1', 'TA'),
('s2', 's2', 's2', 'TA'),
('s3', 's3', 's3', 'TA'),
('s4', 's4', 's4', 'TA'),
('s5', 's5', 's5', 'TA'),
('s6', 's6', 's6', 'TA'),
('s7', 's7', 's7', 'TA'),
('s8', 's8', 's8', 'TA'),
('s9', 's9', 's9', 'TA'),

('s10', 's10', 's10', 'TA'),
('s11', 's11', 's11', 'TA'),
('s12', 's12', 's12', 'TA'),
('s13', 's13', 's13', 'TA'),
('s14', 's14', 's14', 'TA'),
('s15', 's15', 's15', 'TA'),
('s16', 's16', 's16', 'TA'),
('s17', 's17', 's17', 'TA'),
('s18', 's18', 's18', 'TA'),
('s19', 's19', 's19', 'TA'),
('s20', 's20', 's20', 'TA'),
('s21', 's21', 's21', 'TA'),
('s22', 's22', 's22', 'TA');

insert into grader values 
(1 , 'fongadam'),
(2 , 'fongadam'),
(3 , 'fongadam'),
(4 , 'fongadam'),
(5 , 'fongadam'),
(11 , 'fongadam'),
(12 , 'fongadam'),
(13 , 'fongadam'),
(14 , 'fongadam'),
(15 , 'fongadam'),

(6,'shethparth'),
(7,'shethparth'),
(8,'shethparth'),
(9,'shethparth'),
(10,'shethparth'),

(16,'shethparth'),
(17,'shethparth'),
(18,'shethparth'),
(19,'shethparth'),

(20, 'yeestephen'),
(21, 'yeestephen');


insert into RubricItem values 
(1, 1, 'style', 10, 0.4),
(2, 1, 'correctness', 10, 0.6),
(3, 2, 'style', 10, 0.4),
(4, 2, 'correctness', 10, 0.6);
(3, 3, 'style', 10, 0.4),
(4, 3, 'correctness', 10, 0.6);

insert into Membership values 
('s1',1),
('s2',1),
('s3',2),
('s4',3),
('s5',4),
('s6',5),
('s7',6),
('s8',7),
('s9',8),
('s14',9),
('s15',10),


('s10',11),
('s11',12),
('s12',13),
('s13',14),
('s16',15),
('s17',16),
('s18',17),
('s19',18),
('s20',19),
('s21',20),
('s22',21);

insert into Result values
(1, 1, true),
(2, 2, true),
(3, 3, true),
(4, 4, true),
--(5, 5, true),

(6, 3, true),
(7, 4, true),
(8, 8, true),
(9, 5, true),
--(10, 1, true),

(11, 1, true),
(12, 3, true),
--(13, 10, true),
(14, 7, true),
--(15, 9, true),

(16, 9, true),
(17, 9, true),
(18, 9, true),
(19, 9, true);
--(20, 10, true);