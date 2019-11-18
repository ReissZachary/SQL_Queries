use f19ZackR
create schema HW6;

--Team Members: Jaaron Nielsen, Caleb Morales, Zachary Reiss

--PART 1--
create table HW6.Student (
	Student_ID int PRIMARY KEY,
	Student_Name varchar(80),
	Student_Major varchar(30),
	Student_HairColor varchar(30)
	);

--drop table HW6.Student;

--Table that changes student_ID to null when studnet is deleted form student table
create table HW6.LibraryCard(
	Card_ID int PRIMARY KEY,
	Issue_Date date,
	is_ActiveFlag bit,
	Student_ID int
	CONSTRAINT fk_Student_ID
    FOREIGN KEY (Student_ID)
    REFERENCES HW6.Student(Student_ID)
    ON DELETE SET NULL
	);

--drop table HW6.LibraryCard;

--inserting students into student table
insert into HW6.Student
values(1, 'Student A', 'English', 'Brown');
insert into HW6.Student
values(2, 'Student B', 'Computer Science', 'Blonde');
insert into HW6.Student
values(3, 'Student C', 'Math', 'Blue');

select * from HW6.Student;

--inserting cards into librarycard table
insert into HW6.LibraryCard
values (1, NULL, NULL, 1);
insert into HW6.LibraryCard
values (2, '2019-09-01', 0, 2);
insert into HW6.LibraryCard
values (3, '2019-10-10', 1, 2);
insert into HW6.LibraryCard
values (4, '2019-09-01', 1, 3);

select * from HW6.LibraryCard;

delete from HW6.Student
where Student_Name = 'Student C';
--Error Message before changing library table and trying to delete student--
--The DELETE statement conflicted with the REFERENCE constraint "FK__LibraryCa__Stude__2180FB33". The conflict occurred in database "f19ZackR", table "HW6.LibraryCard", column 'Student_ID'.

insert into HW6.LibraryCard
values (5, '2019-09-01', 1, 99);
--Error Message when trying to add a library card that doesn't have a student--
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK__LibraryCa__Stude__245D67DE". The conflict occurred in database "f19ZackR", table "HW6.Student", column 'Student_ID'.


select s.Student_Name,lc.* from HW6.student s full outer join HW6.librarycard lc on (s.student_id=lc.Student_ID) order by s.Student_Name;



create table HW6.LibraryCard(
	Card_ID int PRIMARY KEY,
	Issue_Date date,
	is_ActiveFlag bit,
	Student_ID int FOREIGN KEY REFERENCES HW6.Student(Student_ID)
	);