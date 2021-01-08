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
  [Route("broadcast")]
  [ApiController]
  public class BroadcastController : BroadcasterControllerBase
  {
    public BroadcastController(ChannelResourceHolder holder, ChannelManager channelManager) : base(holder, channelManager)
    {
    }

    [HttpPost]
    [Route("channels")]
    public Task<ActionResult<Channel>> CreateLiveChannelAsync()
    {
      return CreateChannelAsync(ChannelType.Live);
    }

    [HttpPost]
    [Route("vod")]
    public Task<ActionResult<Channel>> CreateVodChannelAsync()
    {
      return CreateChannelAsync(ChannelType.Vod);
    }

    [HttpGet]
    [Route("channels/{channelId}/media/master.m3u8")]
    public Task<IActionResult> GetLiveMasterAsync(string channelId)
    {
      return GetMasterAsync(channelId, ChannelType.Live);
    }

    [HttpGet]
    [Route("vod/{channelId}/media/master.m3u8")]
    public Task<IActionResult> GetVodMasterAsync(string channelId)
    {
      return GetMasterAsync(channelId, ChannelType.Vod);
    }

    [HttpGet]
    [Route("channels/{channelId}/media/{quality}.m3u8")]
    public Task<IActionResult> GetLivePlaylistAsync(string channelId, string quality)
    {
      return GetPlaylistAsync(channelId, ChannelType.Live, quality);
    }

    [HttpGet]
    [Route("vod/{channelId}/media/{quality}.m3u8")]
    public Task<IActionResult> GetVodPlaylistAsync(string channelId, string quality)
    {
      return GetPlaylistAsync(channelId, ChannelType.Vod, quality);
    }

    [HttpGet]
    [Route("channels/{channelId}/media/{quality}/{fileName}")]
    public Task<IActionResult> GetLiveMediaAsync(string channelId, string quality, string fileName)
    {
      return GetMediaAsync(channelId, ChannelType.Live, quality, fileName);
    }

    [HttpGet]
    [Route("vod/{channelId}/media/{quality}/{fileName}")]
    public Task<IActionResult> GetVodMediaAsync(string channelId, string quality, string fileName)
    {
      return GetMediaAsync(channelId, ChannelType.Vod, quality, fileName);
    }

    [HttpPost]
    [Route("channels/{channelId}/media")]
    public Task<ActionResult<ChannelResponse>> StoreLiveVideoAsync(string channelId, [FromQuery(Name = "pos")] double position, [FromQuery(Name = "type")] string type)
    {
      return StoreSegmentedVideoAsync(channelId, ChannelType.Live, position, type);
    }

    [HttpPost]
    [Route("vod/{channelId}/media")]
    public Task<ActionResult<ChannelResponse>> StoreVodVideoAsync(string channelId, [FromQuery(Name = "pos")] double position, [FromQuery(Name = "type")] string type)
    {
      return StoreSegmentedVideoAsync(channelId, ChannelType.Vod, position, type);
    }

    [HttpPost]
    [Route("vod/{channelId}/finalize")]
    public Task<IActionResult> FinalizeAsync(string channelId)
    {
      return FinalizeVodAsync(channelId);
    }

    [HttpDelete]
    [Route("channels/{channelId}/media")]
    public Task<ActionResult<ChannelResponse>> DeleteLiveChannelAsync(string channelId)
    {
      return DeleteChannelAsync(channelId, ChannelType.Live);
    }

    [HttpDelete]
    [Route("vod/{channelId}/media")]
    public Task<ActionResult<ChannelResponse>> DeleteVodChannelAsync(string channelId)
    {
      return DeleteChannelAsync(channelId, ChannelType.Vod);
    }
  }
}