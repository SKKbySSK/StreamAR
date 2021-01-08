using System;
using System.Collections.Generic;
using System.IO;

namespace StreamarBroadcaster.Media
{
  public enum MediaResolution
  {
    FullHighDefinition,
    HighDefinition,
    HighQuality,
  }

  public class MediaInfo
  {
    public MediaInfo(DateTime createdAt, TimeSpan position, TimeSpan duration)
    {
      CreatedAt = createdAt;
      Position = position;
      Duration = duration;
    }

    public DateTime CreatedAt { get; }

    public TimeSpan Position { get; }

    public TimeSpan Duration { get; }

    public Dictionary<MediaResolution, string> Files { get; } = new Dictionary<MediaResolution, string>();
  }
}