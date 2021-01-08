namespace StreamarBroadcaster.Media
{
  public class ChannelResourceHolder
  {
    public ChannelResourceBucket LiveBucket { get; } = new ChannelResourceBucket("Resources/Live", "ts", false);

    public ChannelResourceBucket VodBucket { get; } = new ChannelResourceBucket("Resources/Vod", "ts", true);
  }
}
