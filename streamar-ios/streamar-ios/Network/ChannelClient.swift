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
  private let multiplexServerEndpoint = "http://192.168.0.25:5000/"
  #endif
  
  #if RSD
  private let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  
  #if MBP
  private let multiplexServerEndpoint = "http://gimombp.local:5000/"
  #endif
  
  private lazy var channelsEndpoint: String = {
    return "\(multiplexServerEndpoint)broadcast/channels"
  }()
  
  private func getMediaEndpointUrl(id: String) -> URL {
    return URL(string: "\(multiplexServerEndpoint)broadcast/channels/\(id)/media")!
  }
  
  private lazy var channelsEndpointUrl: URL = {
    return URL(string: channelsEndpoint)!
  }()
  
  func createChannel(title: String, locationId: String, anchorId: String, width: Int, height: Int, completion: @escaping (Channel) -> Void) {
    let body: [String: String] = [ "title": title, "location": locationId, "anchorId": anchorId, "width": String(width), "height": String(height) ]
    request(channelsEndpointUrl, method: .post, parameters: body, headers: nil).response(completionHandler: { result in
      guard let response = result.data else {
        print(result.error?.localizedDescription)
        return
      }
      
      let decoder = JSONDecoder()
      guard let channel = try? decoder.decode(Channel.self, from: response) else {
        print("Invalid response")
        return
      }
      
      completion(channel)
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
  
  func getChannels(byLocation id: String) -> Observable<[Channel]> {
    let db = Firestore.firestore()
    
    return Observable.create({ observer in
      db.collection("broadcast/v1/channels").whereField("location", isEqualTo: id).order(by: "title").getDocuments(completion: { snapshot, error in
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
