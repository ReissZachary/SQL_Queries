use f19ZackR;
go

CREATE SCHEMA Create_Views
go
------------------------------------------------------
CREATE VIEW Sal_Info
AS
	SELECT  e.emp_fname FirstName,
			e.emp_lname LastName,
			e.emp_title Title,
			2019 - YEAR(e.emp_hiredate) YearsEmployed,
			d.dept_name DeptName,
			sh.sal_amount Salary
	FROM Fall2018_Final.dbo.lgemployee e
	INNER JOIN Fall2018_Final.dbo.lgdepartment d
	ON(e.emp_num = d.emp_num)
	INNER JOIN Fall2018_Final.dbo.lgsalary_history sh
	ON(d.emp_num = sh.emp_num)

SELECT * from Sal_Info
---------------------------------------------------------
go
CREATE VIEW EmployeeCostPerDept
AS
	SELECT d.dept_name Department,
    SUM(sh.sal_amount) TotalPay,
    COUNT(e.emp_num) NumEmployees,
	SUM(sh.sal_amount)/COUNT(e.emp_num) payPerEmployee
	FROM Fall2018_Final.dbo.lgdepartment d
	INNER JOIN Fall2018_Final.dbo.lgemployee e
	ON (d.dept_num = e.dept_num)
	INNER JOIN Fall2018_Final.dbo.lgsalary_history sh
	ON (e.emp_num = sh.emp_num)
	WHERE sh.sal_end is null
	GROUP BY d.dept_name

SELECT * from EmployeeCostPerDept

---------------------------------------------------------
CREATE VIEW IncomeByBrand
as
	SELECT  b.brand_name Brand,
			COUNT(p.prod_sku) NumOfProducts,
			SUM(p.prod_price*l.line_qty) TotalSales
	FROM Fall2018_Final.dbo.lgproduct p
	INNER JOIN Fall2018_Final.dbo.lgbrand b
	ON(p.brand_id = b.brand_id)
	INNER JOIN Fall2018_Final.dbo.lgline l
	ON(p.prod_sku = l.prod_sku)
	GROUP BY b.brand_name

Select * from IncomeByBrand






































