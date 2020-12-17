using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Xabe.FFmpeg;

namespace StreamarProc
{
    public static class Converter
    {
        private static (IVideoStream Video, IAudioStream Audio) FindStream(IMediaInfo mediaInfo, int audioChannels = 2)
        {
            IVideoStream video = null;
            foreach (var videoStream in mediaInfo.VideoStreams)
            {
                if (video == null || videoStream.Bitrate > video.Bitrate)
                {
                    video = videoStream;
                }
            }

            IAudioStream audio = null;
            foreach (var audioStream in mediaInfo.AudioStreams)
            {
                if (audio == null || (audioStream.Bitrate > audio.Bitrate && audioStream.Channels == audioChannels))
                {
                    audio = audioStream;
                }
            }

            return (video, audio);
        }
        
        public static async Task<IMediaInfo> OpenAsync(string path)
        {
            return await FFmpeg.GetMediaInfo(new FileInfo(path).FullName);
        }
        
        public static async Task<IConversionResult[]> ToMpegTsAsync(IMediaInfo mediaInfo, Dictionary<DecodeFormat, string> formats)
        {
            var streams = FindStream(mediaInfo);
            if (streams.Video == null || streams.Audio == null)
            {
                throw new InvalidOperationException("There is no stream");
            }

            var conversions = new List<IConversionResult>();
            foreach (var decodeFormat in formats)
            {
                var format = decodeFormat.Key;
                var output = decodeFormat.Value;
                var scale = format.VideoSize / (double)Math.Min(streams.Video.Width, streams.Video.Height);
                var width = streams.Video.Width * scale;
                var height = streams.Video.Height * scale;
                var video = streams.Video;

                video = video.SetSize((int) width, (int) height);
                var conv = await FFmpeg.Conversions.New()
                    .Start($"-i \"{mediaInfo.Path}\" -c copy -c:a aac -hls_segment_type mpegts -y \"{output}\"");

                conversions.Add(conv);
            }

            return conversions.ToArray();
        }
    }
}