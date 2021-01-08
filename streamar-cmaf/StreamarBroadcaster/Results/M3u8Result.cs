using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace StreamarBroadcaster.Results
{
  class M3u8Result : IActionResult
  {
    private readonly string _m3u8;

    public M3u8Result(string m3u8)
    {
      _m3u8 = m3u8;
    }

    public async Task ExecuteResultAsync(ActionContext context)
    {
      context.HttpContext.Response.StatusCode = 200;
      context.HttpContext.Response.ContentType = "application/vnd.apple.mpegurl";
      await context.HttpContext.Response.WriteAsync(_m3u8);
    }
  }
}