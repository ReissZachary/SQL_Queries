--1) employee_name, hire_date, years_employed
-- (assume they are still employed today) order by years_employed

SELECT	e.emp_fname + ' ' + e.emp_lname EmployeeName,
		emp_hiredate HireDate,
		2019 - YEAR(e.emp_hiredate) YearsEmployed
FROM lgemployee e 
order by  YearsEmployed desc

--------------------------------------------------------------------

--2) The average cost per employee per department

SELECT d.dept_name Department,
       SUM(sh.sal_amount) TotalPay,
	   COUNT(e.emp_num) NumEmployees,
	   SUM(sh.sal_amount)/COUNT(e.emp_num) payPerEmployee
FROM lgdepartment d
INNER JOIN lgemployee e
ON (d.dept_num = e.dept_num)
INNER JOIN lgsalary_history sh
ON (e.emp_num = sh.emp_num)
WHERE sh.sal_end is null
GROUP BY d.dept_name
ORDER BY 4 DESC

--------------------------------------------------------------------

--3)Which salesmen/women have been selling items below cost?

SELECT	e.emp_fname FirstName,
		e.emp_lname LastName,
		SUM(p.prod_price*l.line_qty) FullPrice,
		SUM(l.line_price*l.line_qty) DiscoutPrice,
		SUM((p.prod_price*l.line_qty) - (l.line_price*l.line_qty)) TotalDiscount
FROM lgemployee e
INNER JOIN lginvoice i
ON (e.emp_num = i.employee_id)
INNER JOIN lgline l
ON(i.inv_num = l.inv_num)
INNER JOIN lgproduct p
ON(l.prod_sku = p.prod_sku)
WHERE ((p.prod_price*l.line_qty) - (l.line_price*l.line_qty)) > 0
group by e.emp_fname, e.emp_lname
ORDER BY 5 DESC
