USE Northwind;

-- 1. Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE OR ALTER VIEW view_product_order_nguyen
AS
SELECT p.ProductID, SUM(Quantity) AS TotalOrderedQuantity
FROM Products p -- Not all products have an order detail so it is needed to start from the Products table to 'list all products'.
	LEFT JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductID

-- 2. Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
CREATE OR ALTER PROC sp_product_order_quantity_nguyen(
	@productID INT,
	@totalOrderedQuantity INT OUT
)
AS
BEGIN
	SELECT @totalOrderedQuantity = TotalOrderedQuantity FROM view_product_order_nguyen WHERE ProductID = @productID
END

-- 3. Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
CREATE OR ALTER PROC sp_product_order_city_nguyen(
	@productName VARCHAR(100)
)
AS
BEGIN
	SELECT TOP 5 o.ShipCity, SUM(od.Quantity) AS TotalOrderedQuantity
	FROM Products p
		JOIN [Order Details] od ON p.ProductID = od.ProductID
		JOIN Orders o ON od.OrderID = o.OrderID
	WHERE p.ProductName = @productName
	GROUP BY p.ProductID, o.ShipCity
	ORDER BY SUM(od.Quantity) DESC
END

-- 4. Create 2 new tables “people_your_last_name” “city_your_last_name”.
	CREATE TABLE city_nguyen(
		Id INT PRIMARY KEY IDENTITY(1, 1),
		City VARCHAR(100)
	)

	CREATE TABLE people_nguyen(
		Id INT PRIMARY KEY IDENTITY(1, 1),
		Name VARCHAR(100),
		City INT FOREIGN KEY REFERENCES city_nguyen(id)
	)

	-- City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}.
	INSERT INTO city_nguyen VALUES ('Seattle'), ('Green Bay')
	INSERT INTO people_nguyen VALUES
		('Aaron Rodgers', (SELECT Id FROM city_nguyen WHERE City = 'Green Bay')),
		('Russell Wilson', (SELECT Id FROM city_nguyen WHERE City = 'Seattle')),
		('Jody Nelson', (SELECT Id FROM city_nguyen WHERE City = 'Green Bay'))

	-- Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”.
	UPDATE city_nguyen SET City = 'Madison' WHERE City = 'Seattle'

	-- Create a view “Packers_your_name” lists all people from Green Bay.
	CREATE VIEW Packers_nguyen
	AS
	SELECT *
	FROM people_nguyen
	WHERE City = (SELECT Id FROM city_nguyen WHERE City = 'Green Bay')

	-- If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
	DROP TABLE people_nguyen, city_nguyen
	DROP VIEW Packers_nguyen

-- 5. Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
CREATE OR ALTER PROC sp_birthday_employees_nguyen
AS
BEGIN
	SELECT * INTO birthday_employees_your_nguyen
	FROM Employees
	WHERE MONTH(BirthDate) = 2
END

EXEC sp_birthday_employees_nguyen

SELECT * FROM birthday_employees_your_nguyen

DROP TABLE birthday_employees_your_nguyen

-- 6. How do you make sure two tables have the same data?
/*
First step is to compare the number of rows between the 2 tables, if they are not the same then we can just end there because we know that it doesn't have the same data.
If they are the same, then we can try to UNION between the 2 tables. The UNION result set should have the same number of rows as one of the 2 original table.
If the UNION result set doesn't have the same number of rows or an error is throw because of column mismatch, then we know that the 2 tables are not the same.
*/
