CREATE PROCEDURE [InsertWithJSONSP]
(
   @OrderID        INT OUTPUT
 , @CustomerID     NCHAR(5)
 , @EmployeeID     INT
 , @OrderDate      DATETIME
 , @RequiredDate   DATETIME      = NULL
 , @ShippedDate    DATETIME      = NULL
 , @ShipVia        INT
 , @Freight        MONEY
 , @ShipName       NVARCHAR(40)
 , @ShipAddress    NVARCHAR(60)
 , @ShipCity       NVARCHAR(15)
 , @ShipRegion     NVARCHAR(15)  = NULL
 , @ShipPostalCode NVARCHAR(10)
 , @ShipCountry    NVARCHAR(15)
 , @Details        NVARCHAR(MAX)
)
AS
  BEGIN
    /* First step: Insert the new Orders row*/

    INSERT INTO [Orders]
      (
       [CustomerID]
     , [EmployeeID]
     , [OrderDate]
     , [RequiredDate]
     , [ShippedDate]
     , [ShipVia]
     , [Freight]
     , [ShipName]
     , [ShipAddress]
     , [ShipCity]
     , [ShipRegion]
     , [ShipPostalCode]
     , [ShipCountry]
      )
    VALUES
    (
      @CustomerID
    , @EmployeeID
    , @OrderDate
    , @RequiredDate
    , @ShippedDate
    , @ShipVia
    , @Freight
    , @ShipName
    , @ShipAddress
    , @ShipCity
    , @ShipRegion
    , @ShipPostalCode
    , @ShipCountry
    );
    /* Second step: Get the new inserted Order ID*/

    SET @OrderID = IDENT_CURRENT('[Orders]');
    /* Third step: Insert the Order Details rows from the JSON parameter*/

    INSERT INTO [Order Details]
      (
       [OrderID]
     , [ProductID]
     , [UnitPrice]
     , [Quantity]
     , [Discount]
      )
           SELECT 
              @OrderID /* Using the new Order ID*/

            , [Productid]
            , [UnitPrice]
            , [Quantity]
            , [Discount]
           FROM 
              OPENJSON(@Details) WITH([OrderID] [INT], [ProductID] [INT],
              [UnitPrice] [MONEY], [Quantity] [SMALLINT], [Discount]
              [REAL]);
  END;
GO