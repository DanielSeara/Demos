public record OrderDetail
{
   public int OrderID { get; set; }
   public int Quantity { get; set; }
   public int ProductID { get; set; }
   public float UnitPrice { get; set; }
   public float Discount { get; set; }
}



public record Order
{
   public int OrderID { get; set; }
   public string CustomerID { get; set; }
   public int EmployeeID { get; set; }
   public DateTime OrderDate { get; set; }
   public DateTime RequiredDate { get; set; }
   public DateTime? ShippedDate { get; set; }
   public int ShipVia { get; set; }
   public float Freight { get; set; }
   public string ShipName { get; set; }
   public string ShipAddress { get; set; }
   public string ShipCity { get; set; }
   public string ShipPostalCode { get; set; }
   public string ShipCountry { get; set; }
   public string? ShipRegion { get; set; }
}

