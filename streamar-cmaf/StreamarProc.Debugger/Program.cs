using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Xabe.FFmpeg;

namespace StreamarProc.Debugger
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.Write("Path > ");
            var path = Console.ReadLine();

            var mediaInfo = await Converter.OpenAsync(path);
            foreach (var videoStream in mediaInfo.VideoStreams)
            {
                Console.WriteLine($"Video Stream");
                Console.WriteLine($"bitrate: {videoStream.Bitrate}bps");
                Console.WriteLine($"size: {videoStream.Width}x{videoStream.Height}");
                Console.WriteLine($"codec: {videoStream.Codec}");
                Console.WriteLine();
            }
            
            foreach (var audioStream in mediaInfo.AudioStreams)
            {
                Console.WriteLine($"Audio Stream");
                Console.WriteLine($"bitrate: {audioStream.Bitrate}");
                Console.WriteLine($"codec: {audioStream.Codec}");
                Console.WriteLine();
            }

            var fileName = Path.GetFileNameWithoutExtension(path);
            var ext = Path.GetExtension(path);

            var sw = new Stopwatch();
            sw.Start();
            var results = await Converter.ConvertAsync(mediaInfo, new DecodeFormat()
            {
                VideoBitrate = 2000 * 1000,
                VideoCodec = VideoCodec.h264,
                VideoSize = VideoSize.Hd480,
                AudioBitrate = 320 * 1000,
                AudioCodec = AudioCodec.mp3,
                OutputPath = $"{fileName}_480p.mp4",
                Overwrite = true,
            }, new DecodeFormat()
            {
                VideoBitrate = 4000 * 1000,
                VideoCodec = VideoCodec.h264,
                VideoSize = VideoSize.Hd720,
                AudioBitrate = 320 * 1000,
                AudioCodec = AudioCodec.mp3,
                OutputPath = $"{fileName}_720p.mp4",
                Overwrite = true,
            }, new DecodeFormat()
            {
                VideoBitrate = 7000 * 1000,
                VideoCodec = VideoCodec.h264,
                VideoSize = VideoSize.Hd1080,
                AudioBitrate = 320 * 1000,
                AudioCodec = AudioCodec.mp3,
                OutputPath = $"{fileName}_1080p.mp4",
                Overwrite = true,
            });
            sw.Stop();
            Console.WriteLine($"Elapsed: {sw.Elapsed}");
        }
    }
}