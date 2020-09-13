using Xabe.FFmpeg;

namespace StreamarProc
{
    public class DecodeFormat
    {
        public long VideoBitrate { get; set; }
        
        public VideoCodec VideoCodec { get; set; }
        
        public int VideoSize { get; set; }

        public double? VideoFrameRate { get; set; } = null;

        public RotateDegrees? VideoRotation { get; set; }
        
        public long AudioBitrate { get; set; }
        
        public AudioCodec AudioCodec { get; set; }
        
        public Format OutputFormat { get; set; }
        
        public string OutputPath { get; set; }

        public bool Overwrite { get; set; } = false;
    }
}
