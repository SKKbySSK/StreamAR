using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Net.Http.Headers;
using Newtonsoft.Json;
using StreamarBroadcaster.Extensions;
using StreamarBroadcaster.Media;
using StreamarBroadcaster.Models;
using StreamarBroadcaster.Utils;

namespace StreamarBroadcaster.Controllers
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

    class Mpeg2Result: IActionResult
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
    
    [Route("broadcast")]
    [ApiController]
    public class BroadcastController : BroadcasterControllerBase
    {
        private ChannelResourceBucket _bucket;
        private ChannelManager _channelManager;
        
        public BroadcastController(ChannelResourceBucket bucket, ChannelManager channelManager)
        {
            _bucket = bucket;
            _channelManager = channelManager;
        }
        
        [HttpPost]
        [Route("channels")]
        public async Task<ActionResult<Channel>> CreateChannel()
        {
            var request = await Request.Body.ReadAsJsonObject<CreateChannelRequest>();

            if (string.IsNullOrWhiteSpace(request.Title))
            {
                return new BadRequestResult();
            }

            var channel = await _channelManager.CreateChannelAsync(request, (id) => GetRelativeUrl($"/broadcast/channels/{id}/media/master.m3u8").AbsoluteUri);
            Console.WriteLine(channel.ManifestUrl);
            return new ActionResult<Channel>(channel);
        }

        [HttpGet]
        [Route("channels/{channelId}")]
        public async Task<ActionResult<ChannelResponse>> GetChannel(string channelId)
        {
            var channel = _channelManager.GetChannel(channelId);
            if (channel == null)
            {
                return new NotFoundResult();
            }
            
            return new ActionResult<ChannelResponse>(new ChannelResponse()
            {
                ChannelId = channelId,
                Title = channel.Title,
                ManifestUrl = GetRelativeUrl($"/broadcast/channels/{channelId}/media/master.m3u8").AbsoluteUri,
            });
        }

        [HttpGet]
        [Route("channels/{channelId}/media/master.m3u8")]
        public async Task<IActionResult> GetChannelMaster(string channelId)
        {
            if (!_channelManager.CheckChannelExists(channelId))
            {
                return new NotFoundResult();
            }

            var streams = new StreamInfo[]
            {
                new StreamInfo()
                {
                    Format = ChannelResourceBucket.DecodeFormats[0],
                    PlaylistName = "hq.m3u8",
                }, 
                new StreamInfo()
                {
                    Format = ChannelResourceBucket.DecodeFormats[1],
                    PlaylistName = "hd.m3u8",
                }, 
                new StreamInfo()
                {
                    Format = ChannelResourceBucket.DecodeFormats[2],
                    PlaylistName = "fhd.m3u8",
                }, 
            };
            
            return new M3u8Result(ManifestGenerator.CreateMasterM3u8(streams));
        }

        [HttpGet]
        [Route("channels/{channelId}/media/{quality}.m3u8")]
        public async Task<IActionResult> GetChannelPlaylist(string channelId, string quality)
        {
            var res = StringToResolution(quality);

            if (res == null)
            {
                return new NotFoundResult();
            }

            if (!_channelManager.CheckChannelExists(channelId))
            {
                return new NotFoundResult();
            }

            var mediaList = await _bucket.GetAllMediaAsync(channelId) ?? new MediaInfo[0];
            int sequence = Math.Max(mediaList.Length - 6, 0);
            sequence = 0;

            var extInf = new List<ExtInf>();
            foreach (var mediaInfo in mediaList.OrderBy(m => m.Position).Skip(sequence))
            {
                extInf.Add(new ExtInf()
                {
                    Duration = mediaInfo.Duration,
                    FileName = $"{quality}/{Path.GetFileName(mediaInfo.Files[res.Value])}"
                });
            }

            return new M3u8Result(ManifestGenerator.CreateStreamM3u8(TimeSpan.FromSeconds(5), sequence, extInf));
        }

        [HttpGet]
        [Route("channels/{channelId}/media/{quality}/{fileName}")]
        public async Task<IActionResult> GetChannelMedia(string channelId, string quality, string fileName)
        {
            var res = StringToResolution(quality);

            if (res == null)
            {
                return new NotFoundResult();
            }
            
            var media = await _bucket.GetMediaAsync(channelId, fileName);

            if (media == null)
            {
                return new NotFoundResult();
            }

            return new Mpeg2Result(new FileStream(media.Files[res.Value], FileMode.Open, FileAccess.Read));
        }

        private static MediaResolution? StringToResolution(string quality)
        {
            MediaResolution? res = null;
            switch (quality)
            {
                case "hq":
                    res = MediaResolution.HighQuality;
                    break;
                case "hd":
                    res = MediaResolution.HighDefinition;
                    break;
                case "fhd":
                    res = MediaResolution.FullHighDefinition;
                    break;
            }

            return res;
        }

        [HttpPost]
        [Route("channels/{channelId}/media")]
        public async Task<ActionResult<ChannelResponse>> SendVideo(string channelId, [FromQuery(Name = "pos")] double position, [FromQuery(Name = "type")] string type)
        {
            if (!_channelManager.CheckChannelExists(channelId))
            {
                return new NotFoundResult();
            }

            var tempFileName = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}.{type}");
            using (var fs = new FileStream(tempFileName, FileMode.Create))
            {
                await Request.Body.CopyToAsync(fs);
            }
            
            _ = SaveVideoAsync(channelId, position, tempFileName);
            
            return new OkResult();
        }
        
        [HttpDelete]
        [Route("channels/{channelId}/media")]
        public async Task<ActionResult<ChannelResponse>> SendVideo(string channelId)
        {
            if (!_channelManager.CheckChannelExists(channelId))
            {
                return new NotFoundResult();
            }

            await _channelManager.DeleteChannelAsync(channelId);
            await _bucket.DisposeChannelAsync(channelId);

            return new OkResult();
        }

        private async Task SaveVideoAsync(string channelId, double position, string tempFileName)
        {
            await _bucket.SaveAsync(channelId, tempFileName, TimeSpan.FromSeconds(position));
            System.IO.File.Delete(tempFileName);
        }
    }
}