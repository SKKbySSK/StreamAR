using Google.Cloud.Firestore;

namespace StreamarBroadcaster.Models
{
    public class CreateChannelRequest
    {
        public string Title { get; set; }
        
        public string Location { get; set; }
        
        public string AnchorId { get; set; }

        public double Width { get; set; }

        public double Height { get; set; }
        
        public string User { get; set; }
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
        
        [FirestoreProperty(Name = "title")]
        public string Title { get; set; }
        
        [FirestoreProperty(Name = "updatedAt")]
        public Timestamp UpdatedAt { get; set; } = Timestamp.GetCurrentTimestamp();
        
        [FirestoreProperty(Name = "createdAt")]
        public Timestamp CreatedAt { get; set; } = Timestamp.GetCurrentTimestamp();
        
        [FirestoreProperty(Name = "manifestUrl")]
        public string ManifestUrl { get; set; }
        
        [FirestoreProperty(Name = "location")]
        public string Location { get; set; }
        
        [FirestoreProperty(Name = "anchorId")]
        public string AnchorId { get; set; }

        [FirestoreProperty(Name = "width")]
        public double Width { get; set; }

        [FirestoreProperty(Name = "height")]
        public double Height { get; set; }
        
        [FirestoreProperty(Name = "user")]
        public string User { get; set; }
    }
}
