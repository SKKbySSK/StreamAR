using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using StreamarBroadcaster.Extensions;
using StreamarBroadcaster.Utils;
using StreamarProc;
using Xabe.FFmpeg;

namespace StreamarBroadcaster.Media
{
  public class ChannelResourceBucket
  {
    private SemaphoreSlim semaphore = new SemaphoreSlim(1, 1);
    private Dictionary<string, ChannelResource> resources = new Dictionary<string, ChannelResource>();

    public static DecodeFormat[] DecodeFormats { get; } = new[]
    {
            new DecodeFormat()
            {
                VideoBitrate = 500 * 1000,
                VideoSize = 480,
                AudioBitrate = 161 * 1000,
                AudioCodec = AudioCodec.aac,
                OutputFormat = Format.mpegts,
            },
            new DecodeFormat()
            {
                VideoBitrate = 500 * 1000 * 2,
                VideoSize = 720,
                AudioBitrate = 161 * 1000,
                AudioCodec = AudioCodec.aac,
                OutputFormat = Format.mpegts,
            },
            new DecodeFormat()
            {
                VideoBitrate = 500 * 1000 * 3,
                VideoSize = 1080,
                AudioBitrate = 161 * 1000,
                AudioCodec = AudioCodec.aac,
                OutputFormat = Format.mpegts,
            },
        };

    public string Directory { get; }

    public string FileType { get; }

    public ChannelResourceBucket(string directory, string fileType, bool scan)
    {
      Directory = directory;
      FileType = fileType;

      if (!System.IO.Directory.Exists(directory))
      {
        System.IO.Directory.CreateDirectory(directory);
      }

      if (scan)
      {
        ScanFiles();
      }
    }
    private void ScanFiles()
    {
      var channelDirs = System.IO.Directory.GetDirectories(Directory);

      resources.Clear();
      foreach (var channelDir in channelDirs)
      {
        var channelId = Path.GetFileName(channelDir);
        var resourcePath = Path.Combine(Directory, channelId, "resource.json");
        if (File.Exists(resourcePath))
        {
          using (var sr = new FileInfo(resourcePath).OpenText())
          {
            resources[channelId] = sr.ReadToEnd().Deserialize<ChannelResource>();
          }
        }
      }
    }

    public async Task DisposeChannelAsync(string channelId)
    {
      await semaphore.WaitAsync();
      resources.Remove(channelId);
      semaphore.Release();

      try
      {
        System.IO.Directory.Delete(Path.Combine(Directory, channelId), true);
        Console.WriteLine($"{channelId} resources were removed");
      }
      catch (Exception ex)
      {
        Console.WriteLine(ex);
      }
    }

    public async Task<List<MediaInfo>> GetMediaAfterAsync(string channelId, MediaInfo mediaInfo)
    {
      await semaphore.WaitAsync();

      try
      {
        if (resources.TryGetValue(channelId, out var resource))
        {
          var list = new List<MediaInfo>();
          var lastTime = mediaInfo.CreatedAt;

          foreach (var media in resource.Media.OrderBy(m => m.CreatedAt))
          {
            if (media.CreatedAt >= lastTime)
            {
              list.Add(media);
              lastTime = media.CreatedAt;
            }
          }

          return list;
        }

        return null;
      }
      catch (Exception e)
      {
        Console.WriteLine(e);
        throw;
      }
      finally
      {
        semaphore.Release();
      }
    }

    public async Task<MediaInfo> GetMediaAsync(string channelId, DateTime time)
    {
      await semaphore.WaitAsync();

      try
      {
        if (resources.TryGetValue(channelId, out var resource))
        {
          MediaInfo minInfo = null;
          double minDelta = double.MaxValue;
          foreach (var mediaInfo in resource.Media)
          {
            var deltaTime = mediaInfo.CreatedAt - time;
            if (minDelta > Math.Abs(deltaTime.TotalSeconds))
            {
              minInfo = mediaInfo;
              minDelta = Math.Abs(deltaTime.TotalSeconds);
            }
          }

          return minInfo;
        }

        return null;
      }
      catch (Exception e)
      {
        Console.WriteLine(e);
        throw;
      }
      finally
      {
        semaphore.Release();
      }
    }

    public async Task<MediaInfo[]> GetAllMediaAsync(string channelId)
    {
      await semaphore.WaitAsync();

      try
      {
        if (resources.TryGetValue(channelId, out var resource))
        {
          return resource.Media.ToArray();
        }

        return null;
      }
      catch (Exception e)
      {
        Console.WriteLine(e);
        throw;
      }
      finally
      {
        semaphore.Release();
      }
    }

    public async Task<MediaInfo> GetMediaAsync(string channelId, string fileName)
    {
      await semaphore.WaitAsync();

      try
      {
        if (resources.TryGetValue(channelId, out var resource))
        {
          foreach (var info in resource.Media)
          {
            var media = info.Files;
            if (Path.GetFileName(media[MediaResolution.HighQuality]) == fileName)
            {
              return info;
            }
            else if (Path.GetFileName(media[MediaResolution.HighDefinition]) == fileName)
            {
              return info;
            }
            else if (Path.GetFileName(media[MediaResolution.FullHighDefinition]) == fileName)
            {
              return info;
            }
          }
        }

        return null;
      }
      catch (Exception e)
      {
        Console.WriteLine(e);
        throw;
      }
      finally
      {
        semaphore.Release();
      }
    }

    public async Task<MediaInfo> SaveAsync(string channelId, string sourceFile, TimeSpan position)
    {
      var beginTime = DateTime.Now;
      var sourceType = Path.GetExtension(sourceFile).Trim('.');
      MediaInfo mediaInfo;

      try
      {
        var outDir = Path.Combine(Directory, channelId);

        if (!System.IO.Directory.Exists(outDir))
        {
          System.IO.Directory.CreateDirectory(outDir);
        }

        var uuid = Guid.NewGuid().ToString().Replace("-", "");
        var resolutions = new Dictionary<MediaResolution, string>();
        resolutions[MediaResolution.HighQuality] = Path.Combine(Directory, channelId, $"{uuid}.hq.{FileType}");
        resolutions[MediaResolution.HighDefinition] = Path.Combine(Directory, channelId, $"{uuid}.hd.{FileType}");
        resolutions[MediaResolution.FullHighDefinition] = Path.Combine(Directory, channelId, $"{uuid}.fhd.{FileType}");

        var media = await Converter.OpenAsync(sourceFile);

        var formats = new Dictionary<DecodeFormat, string>()
                {
                    { DecodeFormats[0], resolutions[MediaResolution.HighQuality] },
                    { DecodeFormats[1], resolutions[MediaResolution.HighDefinition] },
                    { DecodeFormats[2], resolutions[MediaResolution.FullHighDefinition] },
                };

        await Converter.ToMpegTsAsync(media, formats);
        // 3.2秒前後
        // Console.Write(conversionResults.Sum(res => res.Duration.TotalSeconds));

        mediaInfo = new MediaInfo(beginTime, position, media.Duration);
        mediaInfo.Files[MediaResolution.HighQuality] = resolutions[MediaResolution.HighQuality];
        mediaInfo.Files[MediaResolution.HighDefinition] = resolutions[MediaResolution.HighDefinition];
        mediaInfo.Files[MediaResolution.FullHighDefinition] = resolutions[MediaResolution.FullHighDefinition];
      }
      catch (Exception e)
      {
        Console.WriteLine(e);
        throw;
      }

      await semaphore.WaitAsync();

      try
      {
        ChannelResource resource;
        if (resources.TryGetValue(channelId, out var res))
        {
          resource = res;
        }
        else
        {
          resource = new ChannelResource(FileType);
          resources[channelId] = resource;
        }

        resource.Media.Add(mediaInfo);

        using (var jsonWriter = new StreamWriter(Path.Combine(Directory, channelId, "resource.json")))
        {
          jsonWriter.Write(resource.Serialize());
        }

        return mediaInfo;
      }
      catch (Exception e)
      {
        Console.WriteLine(e);
        throw;
      }
      finally
      {
        semaphore.Release();
      }
    }
  }
}