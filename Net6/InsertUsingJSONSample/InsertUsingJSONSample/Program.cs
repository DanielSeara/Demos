
using Microsoft.Data.SqlClient;

using System.Reflection;
// Create the data to insert

Order order = new()
{
   CustomerID = "ALFKI",
   EmployeeID = 1,
   OrderDate = DateTime.UtcNow,
   RequiredDate = DateTime.UtcNow.AddDays(5),
   ShipAddress = "Obere Str. 57",
   ShipCity = "Berlin",
   Freight = 12.05F,
   ShipCountry = "Germany",
   ShipName = "Alfreds Futterkiste",
   ShipPostalCode = "12209",
   ShipRegion = null,
   ShipVia = 1
};
// Create the details. To Avoid a long code, just get it from a JSON sample
var details = System.Text.Json.JsonSerializer.Deserialize<OrderDetail[]>
   (InsertUsingJSONSample.Properties.Resources.Details);
SqlConnection con = new SqlConnection(InsertUsingJSONSample.Settings1.Default.ConString);
SqlCommand com = new SqlCommand("InsertWithJSONSP", con)
{
   CommandType = System.Data.CommandType.StoredProcedure
};
// Pass each entity property as parameter
foreach (PropertyInfo item in order.GetType().GetProperties())
{
   com.Parameters.AddWithValue("@" + item.Name, item.GetValue(order));

}
com.Parameters["@OrderId"].Direction = System.Data.ParameterDirection.InputOutput;
//Add the details as JSON
com.Parameters.AddWithValue("@Details", System.Text.Json.JsonSerializer.Serialize(details));
using (con)
{
   con.Open();
   int retValue = await com.ExecuteNonQueryAsync();
   int NewOrderID = (int)com.Parameters["@OrderId"].Value;
}
Console.Read();
