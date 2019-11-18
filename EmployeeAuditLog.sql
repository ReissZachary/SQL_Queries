using f19ZackR

create schema HW_Oct16;

create table HW_Oct16.Employee(
	ID int primary key,
	Name varchar(50),
	Salary int,
	Bonus int
)

create table HW_Oct16.Employee_audit_log(
	Employee_id int,
	oName varchar(50),
	nName varchar(50),
	oSal int,
	nSal int,
	oBonus int,
	nBonus int,
	editedby varchar(50),
	editedTime datetime,
	Operation varchar(10)
)

--TRIGGER FOR INSERT AND DELETE
 create trigger HW_Oct16.Inserted
 on HW_Oct16.Employee
 for insert, delete
 as
 begin
 insert into HW_Oct16.Employee_audit_log(
	Employee_id,
	oName,
	nName,
	oSal,
	nSal,
	oBonus,
	nBonus,
	editedby,
	editedTime,
	Operation
	)
	select i.ID, Name, i.Name, Salary, i.Salary, Bonus, i.Bonus, ORIGINAL_LOGIN(), GETDATE(), 'INSERT'
	from inserted i
	union all
	select d.ID, Name, d.Name, Salary, d.Salary, Bonus, d.Bonus, ORIGINAL_LOGIN(), GETDATE(), 'DELETE'
	from deleted d
 end

 --TRIGGER FOR UPDATE
create trigger HW_Oct16.Updated
on HW_Oct16.Employee
for UPDATE
as
begin
insert into HW_Oct16.Employee_audit_log(
	Employee_id,
	oName,
	nName,
	oSal,
	nSal,
	oBonus,
	nBonus,
	editedby,
	editedTime,
	Operation
	)
	select i.ID, d.Name, i.Name, d.Salary, i.Salary, d.Bonus, i.Bonus, ORIGINAL_LOGIN(), GETDATE(), 'UPDATE'
	from inserted i
	inner join deleted d
	on (i.ID = d.ID)
end

insert into HW_OCT16.Employee values (1,'Stephen',10000,500),(2,'Bob',8000,250);
update HW_OCT16.Employee set Bonus=888 where id=1;
update HW_OCT16.Employee set Bonus=999 where id=1;
update HW_OCT16.Employee set Bonus=333 where id=2;
update HW_Oct16.Employee set Name = 'Steffon' where id = 1;
delete from HW_OCT16.Employee where id=2;

select * from HW_Oct16.Employee;
select * from HW_Oct16.Employee_audit_log;

drop table HW_Oct16.Employee;
drop table HW_Oct16.Employee_audit_log;
