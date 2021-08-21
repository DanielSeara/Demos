using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
// Flags downloaded from https://flagpedia.net
namespace Globalization
{
   class Program
   {
      static void Main(string[] args)
      {
         char dot = '■';
         string schemaName = "Masters";
         string connectionString = "Data Source=.;Initial Catalog=<YourDatabase>;User ID=<UserId>;password=<Password>;Application Name=Globalization";
         if (args.Length == 0 || args.Length > 2)
         {
            Console.Clear();
            Console.WriteLine(Properties.Resources.MiniHelp);
            return;
         }
         for (int i = 0; i < args.Length; i += 2)
         {

            switch (args[i].ToLower())
            {
               case "-connectionstring":
                  connectionString = args[i + 1];
                  break;
               case "-schema":
                  schemaName = args[i + 1];
                  break;
               default:
                  Console.Clear();
                  Console.WriteLine(Properties.Resources.MiniHelp);
                  return;
            }
         }
         // Information about the coordinates of each country (from https://github.com/google/dspl/blob/master/samples/google/canonical/countries.csv)
         var GPSData = Properties.Resources.GPS.Split("\r\n");
         Dictionary<string, GPS> GpsPoints = new();
         CultureInfo cultureInfo = new(""); // use invariant culture to convert numbers
         for (int i = 1; i < GPSData.Length; i++)
         {
            var OneRow = GPSData[i].Split(",");
            if (!string.IsNullOrEmpty(OneRow[1]))
            {
               GpsPoints.Add(OneRow[0], new GPS() { Latitude = double.Parse(OneRow[1], cultureInfo), Longitude = double.Parse(OneRow[2], cultureInfo) });

            }
         }
         Console.Clear();
         Console.WriteLine("Going around the world looking for information...");
         var Cultures = (from CultureInfo el in CultureInfo.GetCultures(System.Globalization.CultureTypes.AllCultures)
                         select new Culture()
                         {
                            Name = el.Name,
                            EnglishName = el.EnglishName,
                            DisplayName = el.DisplayName,
                            NativeName = el.NativeName,
                            IetfLanguageTag = el.IetfLanguageTag,
                            LCID = el.LCID,
                            ThreeLetterISOLanguageName = el.ThreeLetterISOLanguageName,
                            TextInfo = el.TextInfo,
                            Calendar = el.Calendar,
                            DateTimeFormat = el.DateTimeFormat,
                            NumberFormat = el.NumberFormat,
                            ISO = el.ThreeLetterISOLanguageName,
                            Windows = el.ThreeLetterWindowsLanguageName,
                            IsNeutralCulture = el.IsNeutralCulture
                         }).ToList();
         //Each culture could have a Region (country) or not. 
         foreach (var item in Cultures)
         {
            try
            {
               item.Region = new RegionInfo(item.Name);

            }
            catch (Exception)
            {

               //throw;
            }
         }
         // Some regions are defined for continents, like Europe, LatinAmerica, etc. Those has no ISO region name and must be excluded
         // Some countries can have more than one culture. It is important to group those cases in just one instance by country
         var Countries = (from el in Cultures where el.Region != null && !string.IsNullOrEmpty(el.Region.ThreeLetterISORegionName) select el.Region).ToList().GroupBy(x => x.GeoId);
         // and map the languages for those that have more than one
         var LanguagesByCountry =
           (from el in Cultures where el.Region != null && !string.IsNullOrEmpty(el.Region.ThreeLetterISORegionName) orderby el.Region.GeoId select new { el.Name, el.Region.GeoId }).ToList();
         //Retrieve the sentences to drop and create the different database objects.
         var statements = Properties.Resources.CreateObjects.Replace("@SCHEMA@", schemaName).Split("GO");
         using SqlConnection con = new(connectionString);
         SqlCommand com = new();
         com.Connection = con;
         con.Open();
         Console.WriteLine($"Creating the database objects in [{con.Database}] on server [{con.DataSource}]");
         // Execute each sentence against the destination database 
         foreach (string item in statements.Where(x => !string.IsNullOrEmpty(x)))
         {
            com.CommandText = item;
            com.ExecuteNonQuery();
         }
         com.CommandText = "[Masters].[Languages_Insert]";
         com.CommandType = System.Data.CommandType.StoredProcedure;
         SqlCommandBuilder.DeriveParameters(com);
         Console.WriteLine("Languages");
         //Inserts each Culture as Language
         foreach (var el in Cultures)
         {
            com.Parameters["@ANSI_Code_Page"].Value = el.TextInfo.ANSICodePage;
            com.Parameters["@Culture"].Value = el.Name;
            com.Parameters["@DateTimeFormatJSON"].Value = ToJSON(el.DateTimeFormat);
            com.Parameters["@EBCDIC_Code_Page"].Value = el.TextInfo.EBCDICCodePage;
            com.Parameters["@English_Name"].Value = el.EnglishName;
            com.Parameters["@IsNeutralCulture"].Value = el.IsNeutralCulture;
            com.Parameters["@LCID"].Value = el.LCID;
            com.Parameters["@List_Separator"].Value = el.TextInfo.ListSeparator;
            com.Parameters["@Local_Name"].Value = el.NativeName;
            com.Parameters["@Mac_Code_Page"].Value = el.TextInfo.MacCodePage;
            com.Parameters["@NumberFormatJSON"].Value = ToJSON(el.NumberFormat);
            com.Parameters["@OEM_Code_Page"].Value = el.TextInfo.OEMCodePage;
            com.Parameters["@RightToLeft"].Value = el.TextInfo.IsRightToLeft;
            com.Parameters["@TextInfoJSON"].Value = ToJSON(el.TextInfo);
            com.ExecuteNonQuery();
            Console.Write(dot);
         }
         Console.WriteLine();
         Console.WriteLine("Countries");
         com.CommandText = "[Masters].[Countries_Insert]";
         com.CommandType = System.Data.CommandType.StoredProcedure;
         SqlCommandBuilder.DeriveParameters(com);
         //Inserts each Country
         foreach (var item in Countries)
         {
            var el = item.First();

            com.Parameters["@Currency_Name"].Value = el.CurrencyNativeName;
            com.Parameters["@Currency_Symbol"].Value = el.CurrencySymbol;
            com.Parameters["@English_Currency_Name"].Value = el.CurrencyEnglishName;
            com.Parameters["@English_Name"].Value = el.EnglishName;
            com.Parameters["@GeoId"].Value = el.GeoId;
            com.Parameters["@IsMetric"].Value = el.IsMetric;
            com.Parameters["@ISO"].Value = el.ThreeLetterISORegionName;
            com.Parameters["@ISOCurrency"].Value = el.ISOCurrencySymbol;
            com.Parameters["@Native_Name"].Value = el.NativeName;
            com.Parameters["@Windows"].Value = el.ThreeLetterWindowsRegionName;
            com.Parameters["@InUse"].Value = 0;
            var flag = Properties.Resources.ResourceManager.GetObject($"f_{el.Name.ToLower()}");
            com.Parameters["@Flag"].Value = flag;
            if (GpsPoints.ContainsKey(el.Name.ToUpper()))
            {
               var gPsPoint = GpsPoints[el.Name.ToUpper()];
               com.Parameters["@Latitude"].Value = gPsPoint.Latitude;
               com.Parameters["@Longitude"].Value = gPsPoint.Longitude;

            }
            else
            {
               com.Parameters["@Latitude"].Value = null;
               com.Parameters["@Longitude"].Value = null;

            }
            com.ExecuteNonQuery();
            Console.Write(dot);

         }
         Console.WriteLine();
         Console.WriteLine("Languages by Country");
         com.CommandText = "[Masters].[LanguagesByCountry_Insert]";
         com.CommandType = System.Data.CommandType.StoredProcedure;
         SqlCommandBuilder.DeriveParameters(com);
         // Inserts the mapping between languages and countries
         foreach (var el in LanguagesByCountry)
         {
            com.Parameters["@Culture"].Value = el.Name;
            com.Parameters["@GeoId"].Value = el.GeoId;
            com.Parameters["@InUse"].Value = 1;
            com.ExecuteNonQuery();
            Console.Write(dot);

         }
         con.Close();
      }

      private static object ToJSON(dynamic toConvert)
      {
         return System.Text.Json.JsonSerializer.Serialize(toConvert, toConvert.GetType());
      }
   }
}
