//
//  ChannelClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import Alamofire

protocol ChannelClient {
  func createChannel(title: String, completion: @escaping (Channel) -> Void)
  func sendVideo(channelId: String, video: URL, position: Double)
}

class FirebaseChannelClient: AuthClientBase, ChannelClient {
  
  private let endpoint = "http://gimombp.local:5000/broadcast/channels"
  private let endpointUrl: URL
  
  override init() {
    endpointUrl = URL(string: endpoint)!
    
    super.init()
  }
  
  func createChannel(title: String, completion: @escaping (Channel) -> Void) {
    request(endpointUrl, method: .post, parameters: [ "title": title ], headers: nil).response(completionHandler: { result in
      guard let response = result.data else {
        print(result.error?.localizedDescription)
        return
      }
      guard let channel = try? Channel(data: response) else {
        print("Invalid response")
        return
      }
      
      completion(channel)
    })
  }
  
  func sendVideo(channelId: String, video: URL, position: Double) {
    let url = URL(string: "\(endpoint)/\(channelId)/media?pos=\(position)&type=\(video.pathExtension)")!
    AF.upload(video, to: url).response(completionHandler: { result in
      guard let error = result.error else { return }
      print(error.localizedDescription)
    })
  }
}

class DummyChannelClient: ChannelClient {
  func createChannel(title: String, completion: @escaping (Channel) -> Void) {
    
  }
  
  func sendVideo(channelId: String, video: URL, position: Double) {
    
  }
  
  
}
