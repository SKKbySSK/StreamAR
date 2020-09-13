using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using StreamarBroadcaster.Models;

namespace StreamarBroadcaster.Extensions
{
    public static class StreamExtension
    {
        public static async Task<T> ReadAsJsonObject<T>(this Stream stream)
        {            
            using (var reader = new StreamReader(stream, Encoding.UTF8, leaveOpen: true))
            {
                var json = await reader.ReadToEndAsync();
                var request = json.Deserialize<T>();
                return request;
            }
        }
    }
}