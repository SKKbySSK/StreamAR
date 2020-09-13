using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Google.Cloud.Firestore;
using StreamarBroadcaster.Models;

namespace StreamarBroadcaster.Utils
{
    public class ChannelManager
    {
        private List<Channel> channels = new List<Channel>();
        private SemaphoreSlim semphore = new SemaphoreSlim(1, 1);

        public IReadOnlyList<Channel> Channels => channels;

        public ChannelManager()
        {
            ReloadAsync().Wait();
        }
        
        public async Task ReloadAsync()
        {
            var db = FirebaseManager.GetFirestore();
            var snapshot = await db.Collection("broadcast/v1/channels").GetSnapshotAsync().ConfigureAwait(false);
            
            await semphore.WaitAsync();
            
            channels.Clear();
            channels.AddRange(snapshot.Select(DocumentToChannel));

            semphore.Release();
        }

        public async Task<Channel> CreateChannelAsync(CreateChannelRequest request)
        {
            var firestore = FirebaseManager.GetFirestore();
            var channelDoc = firestore.Collection("broadcast/v1/channels").Document();
            
            var channel = new Channel()
            {
                Id = channelDoc.Id,
                Title = request.Title,
                UpdatedAt = Timestamp.GetCurrentTimestamp(),
                CreatedAt = Timestamp.GetCurrentTimestamp()
            };
            
            await channelDoc.SetAsync(channel);
            
            await semphore.WaitAsync();
            
            channels.Add(channel);

            semphore.Release();

            return channel;
        }

        public Channel GetChannel(string channelId)
        {
            foreach (var channel in channels)
            {
                if (channel.Id == channelId)
                {
                    return channel;
                }
            }

            return null;
        }

        public bool CheckChannelExists(string channelId)
        {
            foreach (var channel in channels)
            {
                if (channel.Id == channelId)
                {
                    return true;
                }
            }

            return false;
        }

        private Channel DocumentToChannel(DocumentSnapshot snapshot)
        {
            return new Channel()
            {
                Id = snapshot.Id,
                Title = snapshot.GetValue<string>("Title"),
                CreatedAt = snapshot.GetValue<Timestamp>("CreatedAt"),
                UpdatedAt = snapshot.GetValue<Timestamp>("UpdatedAt"),
            };
        }
    }
}