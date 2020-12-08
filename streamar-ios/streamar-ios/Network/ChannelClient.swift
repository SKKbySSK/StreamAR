//
//  ChannelClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseFirestore
import RxSwift

class ChannelClient: AuthClientBase {
  #if LSD
  private let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  #if RSD
  private let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  #if MBP
  private let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  
  private let endpoint = "http://gimombp.local:5000/broadcast/channels"
  private let endpointUrl: URL
  
  override init() {
    endpointUrl = URL(string: endpoint)!
    
    super.init()
  }
  
  func createChannel(title: String, completion: @escaping (Channel) -> Void) {
//    request(endpointUrl, method: .post, parameters: [ "title": title ], headers: nil).response(completionHandler: { result in
//      guard let response = result.data else {
//        print(result.error?.localizedDescription)
//        return
//      }
//      guard let channel = try? Channel(data: response) else {
//        print("Invalid response")
//        return
//      }
//      
//      completion(channel)
//    })
  }
  
  func sendVideo(channelId: String, video: URL, position: Double) {
    let url = URL(string: "\(endpoint)/\(channelId)/media?pos=\(position)&type=\(video.pathExtension)")!
    AF.upload(video, to: url).response(completionHandler: { result in
      guard let error = result.error else { return }
      print(error.localizedDescription)
    })
  }
  
  func getChannels(byLocation id: String) -> Observable<[Channel]> {
    let db = Firestore.firestore()
    
    return Observable.create({ observer in
      db.collection("broadcast/v1/channels").whereField("location", isEqualTo: id).getDocuments(completion: { snapshot, error in
        guard let snapshot = snapshot else {
          observer.onCompleted()
          return
        }
        
        let channels: [Channel] = snapshot.documents.compactMap({ doc in
          guard var document = try! doc.data(as: Channel.self) else { return nil }
          document.id = doc.documentID
          return document
        })
        
        observer.onNext(channels)
        observer.onCompleted()
      })
      
      return Disposables.create()
    })
  }
}
