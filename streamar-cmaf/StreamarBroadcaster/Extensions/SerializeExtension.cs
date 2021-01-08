using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace StreamarBroadcaster.Extensions
{
  public static class SerializeExtension
  {
    public static string Serialize(this object obj)
    {
      var settings = new JsonSerializerSettings()
      {
        Formatting = Formatting.Indented,
        ContractResolver = new DefaultContractResolver
        {
          NamingStrategy = new CamelCaseNamingStrategy(true, false)
        },
      };

      return JsonConvert.SerializeObject(obj, settings);
    }

    public static T Deserialize<T>(this string json)
    {
      var obj = JsonConvert.DeserializeObject<T>(json, new JsonSerializerSettings()
      {
        ContractResolver = new DefaultContractResolver
        {
          NamingStrategy = new CamelCaseNamingStrategy()
        },
      });

      return obj;
    }
  }
}
