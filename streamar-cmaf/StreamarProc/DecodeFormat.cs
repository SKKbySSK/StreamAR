using Xabe.FFmpeg;

namespace StreamarProc
{
    public class DecodeFormat
    {
        public long VideoBitrate { get; set; }
        
        public VideoCodec VideoCodec { get; set; }
        
        public VideoSize VideoSize { get; set; }

        public double? VideoFrameRate { get; set; } = null;
        
        public long AudioBitrate { get; set; }
        
        public AudioCodec AudioCodec { get; set; }
        
        public string OutputPath { get; set; }

        public bool Overwrite { get; set; } = false;
    }
}
