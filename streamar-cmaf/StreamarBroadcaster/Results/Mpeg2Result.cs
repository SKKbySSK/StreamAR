using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace StreamarBroadcaster.Results
{
  class Mpeg2Result : IActionResult
  {
    private readonly Stream _stream;

    public Mpeg2Result(Stream stream)
    {
      _stream = stream;
    }

    public async Task ExecuteResultAsync(ActionContext context)
    {
      context.HttpContext.Response.StatusCode = 200;
      context.HttpContext.Response.ContentType = "video/mp2t";
      using (_stream)
      {
        await _stream.CopyToAsync(context.HttpContext.Response.Body);
      }
    }
  }
}