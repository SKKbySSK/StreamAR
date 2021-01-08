using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Google.Cloud.Firestore;
using StreamarBroadcaster.Models;

namespace StreamarBroadcaster.Utils
{
  public enum ChannelType
  {
    Live,
    Vod
  }

  public class ChannelManager
  {
    private string GetCollectionPath(ChannelType type)
    {
      switch (type)
      {
        case ChannelType.Live:
          return "broadcast/v1/channels";
        case ChannelType.Vod:
          return "broadcast/v1/vod";
        default:
          return null;
      }
    }

    public async Task<Channel> CreateLiveAsync(CreateChannelRequest request, Func<string, string> manifestUrl)
    {
      var firestore = FirebaseManager.GetFirestore();
      var channelDoc = firestore.Collection(GetCollectionPath(ChannelType.Live)).Document();

      var channel = new Channel()
      {
        Id = channelDoc.Id,
        Title = request.Title,
        Location = request.Location,
        AnchorId = request.AnchorId,
        ManifestUrl = manifestUrl(channelDoc.Id),
        UpdatedAt = Timestamp.GetCurrentTimestamp(),
        CreatedAt = Timestamp.GetCurrentTimestamp(),
        Width = request.Width,
        Height = request.Height,
        User = request.User,
      };

      await channelDoc.SetAsync(channel);

      return channel;
    }

    public async Task<VodChannel> CreateVodAsync(CreateChannelRequest request, Func<string, string> manifestUrl)
    {
      var firestore = FirebaseManager.GetFirestore();
      var channelDoc = firestore.Collection(GetCollectionPath(ChannelType.Live)).Document();

      var channel = new VodChannel()
      {
        Id = channelDoc.Id,
        Title = request.Title,
        Location = request.Location,
        AnchorId = request.AnchorId,
        ManifestUrl = manifestUrl(channelDoc.Id),
        UpdatedAt = Timestamp.GetCurrentTimestamp(),
        CreatedAt = Timestamp.GetCurrentTimestamp(),
        Width = request.Width,
        Height = request.Height,
        User = request.User,
        Status = "uploading",
      };

      await channelDoc.SetAsync(channel);

      return channel;
    }

    public async Task FinalizeVodAsync(string channelId)
    {
      var firestore = FirebaseManager.GetFirestore();
      var channelDoc = firestore.Collection(GetCollectionPath(ChannelType.Live)).Document(channelId);

      await channelDoc.UpdateAsync(new Dictionary<string, object> {
        {"status", "ready"}
      });
    }

    public async Task DeleteAsync(string channelId, ChannelType type)
    {
      var firestore = FirebaseManager.GetFirestore();
      var channelDoc = firestore.Collection(GetCollectionPath(type)).Document(channelId);
      await channelDoc.DeleteAsync();
    }

    public async Task<Channel> GetAsync(string channelId, ChannelType type)
    {
      var firestore = FirebaseManager.GetFirestore();
      var snapshot = await firestore.Collection(GetCollectionPath(type)).Document(channelId).GetSnapshotAsync();
      return DocumentToChannel(snapshot);
    }

    public async Task<bool> ExistsAsync(string channelId, ChannelType type)
    {
      var firestore = FirebaseManager.GetFirestore();
      var snapshot = await firestore.Collection(GetCollectionPath(type)).Document(channelId).GetSnapshotAsync();
      return snapshot.Exists;
    }

    private Channel DocumentToChannel(DocumentSnapshot snapshot)
    {
      var channel = snapshot.ConvertTo<Channel>();
      channel.Id = snapshot.Id;

      return channel;
    }
  }
}