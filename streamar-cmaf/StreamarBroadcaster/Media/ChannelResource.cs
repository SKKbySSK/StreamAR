using System.Collections.Generic;
using System.IO;

namespace StreamarBroadcaster.Media
{
  public class ChannelResource
  {
    public ChannelResource(string fileType, List<MediaInfo> media = null)
    {
      Media = media ?? new List<MediaInfo>();
      FileType = fileType;
    }

    public List<MediaInfo> Media { get; }

    public string FileType { get; }
  }
}