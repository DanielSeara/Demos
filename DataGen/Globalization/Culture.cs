using System.Globalization;

namespace Globalization
{


   public class Culture
   {
      public string Id { get; set; }
      public string Name { get; set; }
      public string EnglishName { get; set; }
      public string DisplayName { get; set; }
      public string NativeName { get; set; }
      public string IetfLanguageTag { get; set; }
      public int LCID { get; set; }
      public string ThreeLetterISOLanguageName { get; set; }
      public RegionInfo Region { get; internal set; }
      public TextInfo TextInfo { get; internal set; }
      public Calendar Calendar { get; internal set; }
      public DateTimeFormatInfo DateTimeFormat { get; internal set; }
      public NumberFormatInfo NumberFormat { get; internal set; }
      public string ISO { get; internal set; }
      public string Windows { get; internal set; }
      public bool IsNeutralCulture { get; internal set; }
   }

}
