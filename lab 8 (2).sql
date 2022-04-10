-- schema creation
CREATE SCHEMA stored_proc_tutorial;

-- table creation
CREATE TABLE studentMarks (stud_id SMALLINT(5) NOT NULL AUTO_INCREMENT PRIMARY KEY, total_marks INT, grade VARCHAR(5));
 
 
-- insert sample data
INSERT INTO studentMarks(total_marks, grade) VALUES(450, 'A'), (480, 'A+'), (490, 'A++'), (440, 'B+'),(400, 'C+'),(380,'C')
,(250, 'D'),(200,'E'),(100,'F'),(150,'F'),(220, 'E');

-- Q1
DELIMITER //
create procedure get_details_sid(in sid smallint)
begin
select * from studentmarks where stud_id=sid;
end //
DELIMITER ;

call get_details_sid(4);


-- Q2
DELIMITER //
create procedure get_details_grade(in grade varchar(5))
begin
select * from studentmarks s where s.grade=grade;
end //
DELIMITER ;

call get_details_grade('A');


-- Q3
Delimiter //
create procedure get_avg_marks(out avg_marks int)
begin
select avg(total_marks) into avg_marks
from studentmarks;
end //
Delimiter ;

-- call the function by snding the variable
call get_avg_marks(@avg_marks);
call get_avg_marks(@avg_marks);
-- now select the custom name that you sent
select @avg_marks as avg_marks;

-- Q4
delimiter ??
create procedure get_min(in g varchar(5), out min_m int)
begin
select min(total_marks) into min_m
from (	select total_marks 
		from studentmarks 
		where grade=g ) s;
end ??
Delimiter ;

call get_min('F', @min_m);
select @min_m as min_marks;

-- Q5
delimiter //
create procedure inc_counter
(
inout counter int,
in inc int
)
begin
set counter=counter+inc;
end //
delimiter ;

set @counter = 1;
call inc_counter(@counter,6);
select @counter as counter;

-- Q6
delimiter //
create procedure update_m(in sid int, inout inc int)
begin
select total_marks+inc into inc 
from studentmarks 
where stud_id=sid;
end //
delimiter ;


set @inc = 10;
call update_m(4,@inc);
select @inc as updated_marks;

-- Q7
delimiter //
create procedure get_count(out count_stud int)
begin
select count(stud_id) into count_stud
from (select * from studentmarks
	   having total_marks<(
							select avg(total_marks) 
                            from studentmarks
							)
	 ) s;
end //
delimiter ;

call get_count(@count_stud);
select @count_stud;

-- Q 8
delimiter //
create procedure get_marks(in sid int, out marks int)
select total_marks into marks from studentmarks where stud_id=sid;
end //
delimiter ;

delimiter //
create procedure eval_grade(in sid int, out res varchar(4))
begin
call get_marks(sid,@marks);
select 'FAIL' into res;
select 'PASS' into res where @marks > (select avg(total_marks) from studentmarks);
end //
delimiter ;

call eval_grade(1,@res);
select @res;

-- Q 9
delimiter //
create procedure eval_class(in sid int, out res_class varchar(20))
begin
select 'FAILED' INTO res_class;
SELECT 'SECOND CLASS' INTO res_class WHERE sid IN 
(select stud_id from studentmarks where total_marks between 300 and 399);
select 'FIRST CLASS' INTO res_class where sid in
(select stud_id from studentmarks where total_marks >= 400); 
end //
delimiter ;

call eval_class(3,@res_class);
select @res_class;

-- 10
delimiter //
create procedure insert_record
(
in sid int,
in t_mar int, 
in g varchar(5),
out count_rows int
)
begin
declare exit handler for 1062 
select 'duplicate key occured' as Message;
insert into studentmarks 
values (sid, t_mar, g);
select count(*) into count_rows from studentmarks;
end //
delimiter ;

call insert_record(3,450,"A",@count_rows);
select @count_rows; 

delimiter //
create procedure insert_record_1
(in sid int,
in t_mar int, 
in g varchar(5),
out count_rows int
)
begin
declare valid int default 1;
declare continue handler for 1062
set vaild = 0;
if valid = 1 then
insert into studentmarks 
values (sid, t_mar, g);
end if;
select count(*) into count_rows from studentmarks;
end //
delimiter ;

call insert_record(3,450,"A",@count_rows);
select @count_rows;








