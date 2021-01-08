using System.Threading;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StreamarBroadcaster.Extensions;
using StreamarBroadcaster.Media;
using StreamarBroadcaster.Models;
using StreamarBroadcaster.Results;
using StreamarBroadcaster.Utils;

namespace StreamarBroadcaster.Controllers
{
  public abstract class BroadcasterControllerBase : ControllerBase
  {
    private ChannelResourceHolder holder;

    private ChannelManager channelManager;

    private Dictionary<string, List<Task>> saveTasks { get; } = new Dictionary<string, List<Task>>();

    private SemaphoreSlim saveTasksSemaphore { get; } = new SemaphoreSlim(1, 1);

    protected BroadcasterControllerBase(ChannelResourceHolder holder, ChannelManager channelManager)
    {
      this.holder = holder;
      this.channelManager = channelManager;
    }

    private ChannelResourceBucket GetBucket(ChannelType type)
    {
      switch (type)
      {
        case ChannelType.Live:
          return holder.LiveBucket;
        case ChannelType.Vod:
          return holder.VodBucket;
        default:
          return null;
      }
    }

    private MediaResolution? StringToResolution(string quality)
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

    protected async Task<ActionResult<Channel>> CreateChannelAsync(ChannelType type)
    {
      var request = await Request.Body.ReadAsJsonObject<CreateChannelRequest>();

      if (string.IsNullOrWhiteSpace(request.Title))
      {
        return new BadRequestResult();
      }

      Channel channel;

      switch (type)
      {
        case ChannelType.Live:
          channel = await channelManager.CreateLiveAsync(request, (id) => $"/broadcast/channels/{id}/media/master.m3u8");
          break;
        case ChannelType.Vod:
          channel = await channelManager.CreateVodAsync(request, (id) => $"/broadcast/vod/{id}/media/master.m3u8");
          break;
        default:
          return new BadRequestResult();
      }

      Console.WriteLine(channel.ManifestUrl);
      return new ActionResult<Channel>(channel);
    }

    protected async Task<IActionResult> GetMasterAsync(string channelId, ChannelType type)
    {
      if (!await channelManager.ExistsAsync(channelId, type))
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

    protected async Task<IActionResult> GetPlaylistAsync(string channelId, ChannelType type, string quality)
    {
      var res = StringToResolution(quality);

      if (res == null)
      {
        return new NotFoundResult();
      }

      if (!await channelManager.ExistsAsync(channelId, type))
      {
        return new NotFoundResult();
      }

      var mediaList = await GetBucket(type).GetAllMediaAsync(channelId) ?? new MediaInfo[0];
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

    protected async Task<IActionResult> GetMediaAsync(string channelId, ChannelType type, string quality, string fileName)
    {
      var res = StringToResolution(quality);

      if (res == null)
      {
        return new NotFoundResult();
      }

      var media = await GetBucket(type).GetMediaAsync(channelId, fileName);

      if (media == null)
      {
        return new NotFoundResult();
      }

      return new Mpeg2Result(new FileStream(media.Files[res.Value], FileMode.Open, FileAccess.Read));
    }

    protected async Task<ActionResult<ChannelResponse>> StoreSegmentedVideoAsync(string channelId, ChannelType type, double position, string videoType)
    {
      if (!await channelManager.ExistsAsync(channelId, type))
      {
        return new NotFoundResult();
      }

      var tempFileName = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}.{videoType}");
      using (var fs = new FileStream(tempFileName, FileMode.Create))
      {
        await Request.Body.CopyToAsync(fs).ConfigureAwait(false);
      }

      var saveTask = SaveVideoAsync(channelId, position, tempFileName);

      if (type == ChannelType.Live)
      {
        await saveTasksSemaphore.WaitAsync();
        if (saveTasks.TryGetValue(channelId, out var tasks))
        {
          tasks.Add(saveTask);
        }
        else
        {
          saveTasks[channelId] = new List<Task>(new[] { saveTask });
        }
        saveTasksSemaphore.Release();
      }

      async Task SaveVideoAsync(string channelId, double position, string tempFileName)
      {
        await GetBucket(type).SaveAsync(channelId, tempFileName, TimeSpan.FromSeconds(position));
        System.IO.File.Delete(tempFileName);
      }

      return new OkResult();
    }

    protected async Task<IActionResult> FinalizeVodAsync(string channelId)
    {
      List<Task> tasks = null;
      await saveTasksSemaphore.WaitAsync();
      saveTasks.TryGetValue(channelId, out tasks);
      saveTasksSemaphore.Release();

      if (tasks != null)
      {
        await Task.WhenAll(tasks);
      }

      await channelManager.FinalizeVodAsync(channelId);

      return new OkResult();
    }

    protected async Task<ActionResult<ChannelResponse>> DeleteChannelAsync(string channelId, ChannelType type)
    {
      if (!await channelManager.ExistsAsync(channelId, type))
      {
        return new NotFoundResult();
      }

      await channelManager.DeleteAsync(channelId, type);
      await GetBucket(type).DisposeChannelAsync(channelId);

      return new OkResult();
    }
  }
}