using Google.Cloud.Firestore;

namespace StreamarBroadcaster.Models
{
    public class CreateChannelRequest
    {
        public string Title { get; set; }
    }
    
    public class ChannelResponse
    {
        public string ChannelId { get; set; }
        
        public string Title { get; set; }
        
        public string ManifestUrl { get; set; }
    }

    public class MediaSendRequest
    {
        public double DurationSec { get; set; }
        
        public string FileType { get; set; }
    }
    
    [FirestoreData]
    public class Channel
    {
        public string Id { get; set; }
        
        [FirestoreProperty]
        public string Title { get; set; }
        
        [FirestoreProperty]
        public Timestamp UpdatedAt { get; set; }
        
        [FirestoreProperty]
        public Timestamp CreatedAt { get; set; }
    }
}
