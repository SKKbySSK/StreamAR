using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace StreamarBroadcaster.Utils
{
    public class ExtInf
    {
        public TimeSpan Duration { get; set; }
        
        public string FileName { get; set; }
    }
    
    public static class ManifestGenerator
    {
        public static string CreateMasterM3u8()
        {
            var builder = new StringBuilder();
            builder.AppendLine("#EXTM3U");

            return builder.ToString();
        }
        
        public static string CreateStreamM3u8(TimeSpan targetDuration, int sequence, IList<ExtInf> media)
        {
            var builder = new StringBuilder();
            builder.AppendLine("#EXTM3U");
            builder.AppendLine("#EXT-X-TARGETDURATION:" + (int)Math.Round(targetDuration.TotalSeconds));
            builder.AppendLine("#EXT-X-VERSION:4");
            builder.AppendLine($"#EXT-X-MEDIA-SEQUENCE:{sequence}");
            //builder.AppendLine($"#EXT-X-PLAYLIST-TYPE:EVENT");

            for (int i = 0; i < media.Count; i++)
            {
                var inf = media[i];
                builder.AppendLine($"#EXTINF:{inf.Duration.TotalSeconds},");
                builder.AppendLine(inf.FileName);
            }

            //builder.AppendLine("#EXT-X-ENDLIST");

            return builder.ToString();
        }
    }
}