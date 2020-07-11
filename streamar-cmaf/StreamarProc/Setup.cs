using Xabe.FFmpeg;

namespace StreamarProc
{
    public static class Setup
    {
        public static void SetupFFmpeg(string directory, string ffmpegName = "ffmpeg", string ffprobeName = "ffprobe")
        {
            FFmpeg.SetExecutablesPath(directory, ffmpegName, ffprobeName);
        }
    }
}
