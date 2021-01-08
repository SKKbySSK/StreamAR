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
import FirebaseAuth
import RxSwift
import RxCocoa
import RxDataSources

class ChannelClient: AuthClientBase {
  #if LSD
  static let multiplexServerEndpoint = "http://192.168.0.22:5000/"
  #endif
  
  #if RSD
  static let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  
  #if MBP
  static let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  
  private lazy var channelsEndpoint: String = {
    return "\(ChannelClient.multiplexServerEndpoint)broadcast/channels"
  }()
  
  private func getMediaEndpointUrl(id: String) -> URL {
    return URL(string: "\(ChannelClient.multiplexServerEndpoint)broadcast/channels/\(id)/media")!
  }
  
  private lazy var channelsEndpointUrl: URL = {
    return URL(string: channelsEndpoint)!
  }()
  
  func createChannel(title: String, locationId: String, anchorId: String, width: Int, height: Int) -> Observable<Channel> {
    let user = Auth.auth().currentUser!
    let body: [String: String] = [
      "title": title,
      "location": locationId,
      "anchorId": anchorId,
      "width": String(width),
      "height": String(height),
      "user": user.uid
    ]
    
    return Observable.create({ observer in
      self.request(self.channelsEndpointUrl, method: .post, parameters: body, headers: nil).response(completionHandler: { result in
        guard let response = result.data else {
          observer.onError(result.error!)
          return
        }
        
        let decoder = JSONDecoder()
        do {
          let channel = try decoder.decode(Channel.self, from: response)
          observer.onNext(channel)
          observer.onCompleted()
        } catch let error {
          observer.onError(error)
        }
      })
      
      return Disposables.create()
    })
  }
  
  func deleteChannel(channel: Channel, completion: @escaping (Channel) -> Void) {
    let url = getMediaEndpointUrl(id: channel.id!)
    request(url, method: .delete, parameters: Dictionary<String, String>(), headers: nil).response(completionHandler: { result in
      if let error = result.error {
        print(error.localizedDescription)
      }
      
      completion(channel)
    })
  }
  
  func sendVideo(channelId: String, video: URL, position: Double, completion: @escaping (URL, Error?) -> Void) {
    let url = URL(string: "\(channelsEndpoint)/\(channelId)/media?pos=\(position)&type=\(video.pathExtension)")!
    AF.upload(video, to: url).response(completionHandler: { result in
      completion(video, result.error)
    })
  }
  
  func getChannels(byLocation id: String, vod: Bool) -> Observable<[Channel]> {
    let db = Firestore.firestore()
    let collection = "broadcast/v1/" + (vod ? "vod" : "channels")
    return Observable.create({ observer in
      db.collection(collection).whereField("location", isEqualTo: id).order(by: "title").getDocuments(completion: { snapshot, error in
        guard let snapshot = snapshot else {
          print(error!.localizedDescription)
          observer.onCompleted()
          return
        }
        
        observer.onNext(snapshot.documents.compactMap({ Channel.fromSnapshot($0) }))
        observer.onCompleted()
      })
      
      return Disposables.create()
    })
  }
}
