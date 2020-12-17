using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using StreamarProc;

namespace StreamarBroadcaster.Utils
{
    public class ExtInf
    {
        public TimeSpan Duration { get; set; }
        
        public string FileName { get; set; }
    }

    public class StreamInfo
    {
        public DecodeFormat Format { get; set; }
        
        public string PlaylistName { get; set; }
    }
    
    public static class ManifestGenerator
    {
        public static string CreateMasterM3u8(IEnumerable<StreamInfo> streams)
        {
            var builder = new StringBuilder();
            builder.AppendLine("#EXTM3U");

            foreach (var stream in streams)
            {
                var videoSize = stream.Format.VideoBitrate / 8;
                var audioSize = stream.Format.AudioBitrate / 8;
                var bandwidth = videoSize + audioSize;
                
                builder.AppendLine($"#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH={bandwidth}");
                builder.AppendLine(stream.PlaylistName);
            }

            return builder.ToString();
        }
        
        public static string CreateStreamM3u8(TimeSpan targetDuration, int sequence, IList<ExtInf> media)
        {
            var builder = new StringBuilder();
            builder.AppendLine("#EXTM3U");
            builder.AppendLine("#EXT-X-TARGETDURATION:" + (int)Math.Round(targetDuration.TotalSeconds));
            builder.AppendLine("#EXT-X-VERSION:4");
            builder.AppendLine($"#EXT-X-MEDIA-SEQUENCE:{sequence}");
            builder.AppendLine($"#EXT-X-PLAYLIST-TYPE:EVENT");

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