using System;
using System.Collections.Generic;
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
            return await FFmpeg.GetMediaInfo(path);
        }
        
        public static async Task<IConversionResult[]> ConvertAsync(IMediaInfo mediaInfo, params DecodeFormat[] formats)
        {
            var streams = FindStream(mediaInfo);
            if (streams.Video == null || streams.Audio == null)
            {
                throw new InvalidOperationException("There is no stream");
            }

            var conversions = new List<IConversionResult>();
            foreach (var decodeFormat in formats)
            {
                var conv = await FFmpeg.Conversions.New()
                    .AddStream(streams.Video.SetCodec(decodeFormat.VideoCodec).SetSize(decodeFormat.VideoSize)
                        .SetFramerate(decodeFormat.VideoFrameRate ?? streams.Video.Framerate))
                    .SetVideoBitrate(decodeFormat.VideoBitrate)
                    .AddStream(streams.Audio.SetCodec(decodeFormat.AudioCodec))
                    .SetAudioBitrate(decodeFormat.AudioBitrate)
                    .SetOutput(decodeFormat.OutputPath)
                    .UseMultiThread(true)
                    .SetOverwriteOutput(decodeFormat.Overwrite)
                    .Start();

                conversions.Add(conv);
            }

            return conversions.ToArray();
        }
    }
}