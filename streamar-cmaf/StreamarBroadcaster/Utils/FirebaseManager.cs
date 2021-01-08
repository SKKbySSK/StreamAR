using System;
using Google.Cloud.Firestore;

namespace StreamarBroadcaster.Utils
{
  public static class FirebaseManager
  {
    public const string ProjectId = "streamar-6049f";

    private static FirestoreDb _db;

    private static T GetCacheOrCreate<T>(T value, Func<T> factory) where T : class
    {
      if (value == null)
      {
        value = factory();
      }

      return value;
    }

    public static FirestoreDb GetFirestore()
    {
      return GetCacheOrCreate(_db, () =>
      {
        _db = FirestoreDb.Create(ProjectId);
        return _db;
      });
    }
  }
}