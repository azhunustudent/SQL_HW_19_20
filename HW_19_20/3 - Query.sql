USE Northwind;
GO

--Задача 1
--Создайте и протестируйте хранимую процедуру, возвращающую наименьший и наибольшие года сделанных заказов (Northwind).
DROP PROCEDURE IF EXISTS GetMinMaxYear;
GO

CREATE PROCEDURE GetMinMaxYear
	@minYear INT OUTPUT,
	@maxYear INT OUTPUT
AS
BEGIN
	SET @maxYear = (SELECT MAX(YEAR(OrderDate)) FROM Orders); 
	SET @minYear = (SELECT MIN(YEAR(OrderDate)) FROM Orders); 

	-- SELECT @minYear = MIN(YEAR(OrderDate)), 
	-- 	      @maxYear = MAX(YEAR(OrderDate))
	-- FROM Orders;

    SELECT @minYear AS [Min Year], @maxYear AS [Max Year];
END;
GO

DECLARE @minYear INT, @maxYear INT;
EXEC dbo.GetMinMaxYear @minYear, @maxYear;
GO
--SELECT MIN(YEAR(OrderDate)), MAX(YEAR(OrderDate)) FROM Orders

---------------------------------------------------------------------------------------------------------------

--Задача 2
--Создайте хранимую процедуру, возвращающую количество и общую сумму заказов по базе (Northwind).
DROP PROCEDURE IF EXISTS GetCountAndSumOrders;
GO

CREATE PROCEDURE GetCountAndSumOrders
  @count INT OUTPUT,
  @sum MONEY OUTPUT
AS 
BEGIN
	SET @count = (SELECT Count(DISTINCT OrderID) FROM OrderDetails); 
	SET @sum   = (SELECT SUM(UnitPrice*Quantity*(1.0-Discount)) FROM OrderDetails);

	SELECT @count AS [The Number of Orders], 
		   @sum AS [The Total Amount of Orders];
END;
GO

DECLARE @count INT, @sum MONEY;
EXEC GetCountAndSumOrders @count, @sum;
--SELECT DISTINCT COUNT(DISTINCT OrderID), SUM(UnitPrice * Quantity * (1 - Discount)) FROM OrderDetails;

---------------------------------------------------------------------------------------------------------------

--Задача 3
--В базе данных Northwind создайте функцию udfGetCountOrders, возвращающую общее количество заказов за заданный год.
DROP FUNCTION IF EXISTS udfGetCountOrders;
GO

CREATE FUNCTION udfGetCountOrders( @year INT )
RETURNS INT
AS
BEGIN
	DECLARE @countOrders INT;
	SET		@countOrders = (SELECT COUNT(OrderID) FROM dbo.Orders WHERE (YEAR(OrderDate) = @year));
	RETURN	@countOrders;
END;
GO

PRINT dbo.udfGetCountOrders(1996);
PRINT dbo.udfGetCountOrders(1997);
PRINT dbo.udfGetCountOrders(1998);