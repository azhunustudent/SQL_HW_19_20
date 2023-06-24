USE Northwind;
GO

ALTER TABLE Orders ADD
  SubTotal MONEY NOT NULL DEFAULT(0),
  Bonus MONEY NOT NULL DEFAULT(0);
GO
  
DROP VIEW IF EXISTS vOrdersAll;
GO
CREATE VIEW  vOrdersAll 
AS
SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Employees.EmployeeID, Employees.LastName, Employees.FirstName, Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.Freight, Orders.SubTotal, CAST(SUM((OrderDetails.UnitPrice * OrderDetails.Quantity) * (1 - OrderDetails.Discount)) AS MONEY) AS OrderSum, Orders.Bonus
  FROM Orders
    LEFT OUTER JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
      LEFT OUTER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
        LEFT OUTER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
  GROUP BY Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Employees.EmployeeID, Employees.LastName, Employees.FirstName, Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.Freight, Orders.SubTotal, Orders.Bonus;
GO


-- INNER JOIN !

-- DROP VIEW IF EXISTS vOrdersAll;
-- GO
-- CREATE VIEW vOrdersAll
-- AS
-- SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Employees.EmployeeID, Employees.LastName, Employees.FirstName, Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.Freight, Orders.SubTotal,
    -- CAST(SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS MONEY) AS OrderSum,
    -- Orders.Bonus
  -- FROM  Orders INNER JOIN
    -- OrderDetails ON Orders.OrderID = OrderDetails.OrderID INNER JOIN
    -- Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
    -- Customers ON Orders.CustomerID = Customers.CustomerID
  -- GROUP BY Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Employees.EmployeeID, Employees.LastName, Employees.FirstName,  Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.Freight, Orders.SubTotal, Orders.Bonus;
-- GO


DROP VIEW IF EXISTS vOrderDetailsAll;
GO
CREATE VIEW vOrderDetailsAll
AS
SELECT Orders.OrderID, Orders.CustomerID, Orders.EmployeeID, Orders.OrderDate, Orders.RequiredDate, Products.ProductID, Products.ProductName, Products.SupplierID, Products.CategoryID, OrderDetails.UnitPrice, OrderDetails.Quantity, OrderDetails.Discount, CAST((OrderDetails.UnitPrice * OrderDetails.Quantity) * (1 - OrderDetails.Discount) AS money) AS LineTotal
  FROM OrderDetails
    INNER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
		INNER JOIN Products ON OrderDetails.ProductID = Products.ProductID
GO


DROP PROCEDURE IF EXISTS sp_EmployeeInsert;
GO
CREATE PROCEDURE sp_EmployeeInsert
  @lastName NVARCHAR(20),   
  @firstName NVARCHAR(20),
  @employeeID BIGINT OUTPUT
AS   
  SET NOCOUNT ON;  
  INSERT INTO Employees (LastName, FirstName) VALUES (@lastName, @firstName);
  SET @employeeID = SCOPE_IDENTITY();
GO


DROP PROCEDURE IF EXISTS sp_GetOrder;
GO
CREATE PROCEDURE sp_GetOrder
  @orderID INT,   
  @orderSum MONEY OUTPUT
AS   
  SET NOCOUNT ON;  

  SELECT OrderID, CustomerID, EmployeeID, OrderDate, SubTotal, Bonus FROM Orders
    WHERE OrderID =  @orderID;

  SELECT OrderID, ProductID, UnitPrice, Quantity, Discount FROM OrderDetails
    WHERE OrderID =  @orderID;

  SELECT @orderSum = CAST(SUM((OrderDetails.UnitPrice * OrderDetails.Quantity) * (1 - OrderDetails.Discount)) AS MONEY) 
    FROM OrderDetails      
    WHERE OrderID =  @orderID;
GO

-- DECLARE @orderSum MONEY;
-- EXEC sp_GetOrder 10255, @orderSum OUTPUT;
-- SELECT @orderSum  AS OrderSum;


DROP FUNCTION IF EXISTS dbo.udfGetOrderSum;
GO
CREATE FUNCTION dbo.udfGetOrderSum(@OrderId AS INT)
RETURNS MONEY
AS BEGIN
	DECLARE @OrderSum AS MONEY;
	SET @OrderSum = (SELECT SUM(UnitPrice*Quantity*(1 - Discount)) FROM dbo.OrderDetails WHERE OrderId = @OrderId);
  RETURN @OrderSum;
END;
GO



DROP TABLE IF EXISTS ShoppingCartDetails;
GO
DROP TABLE IF EXISTS ShoppingCarts;
GO
CREATE TABLE ShoppingCarts (
  ShoppingCartID INT IDENTITY(1,1) NOT NULL,
  CustomerID NCHAR(5) NOT NULL,
  CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_ShoppingCarts PRIMARY KEY CLUSTERED (ShoppingCartID),
  CONSTRAINT UW_ShoppingCarts UNIQUE (CustomerID),
  CONSTRAINT FK_ShoppingCarts_Customers FOREIGN KEY(CustomerID) REFERENCES Customers (CustomerID)
)
GO
CREATE TABLE ShoppingCartDetails (
	ShoppingCartDetailID INT IDENTITY(1,1) NOT NULL,
  ShoppingCartID INT NOT NULL,
	ProductID INT NOT NULL,
	ProductName NVARCHAR(40) NULL,
	UnitPrice MONEY NOT NULL,
	Quantity SMALLINT NOT NULL DEFAULT 1,
  Discount REAL NOT NULL DEFAULT 0.0,
  CONSTRAINT PK_ShoppingCartDetails PRIMARY KEY CLUSTERED (ShoppingCartDetailID),
  CONSTRAINT FK_ShoppingCartDetails_ShoppingCarts FOREIGN KEY(ShoppingCartID) REFERENCES ShoppingCarts (ShoppingCartID),
  CONSTRAINT FK_ShoppingCartDetails_Products FOREIGN KEY(ProductID) REFERENCES Products (ProductID),
)
GO