//
//  BroadcastViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/17.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

class BroadcastViewModel: ObservableObject {
  @Published var title: String = ""
  @Published var channel: Channel? = nil
  
  let channelClient = FirebaseChannelClient()
  
  func createChannel(completion: @escaping (Channel) -> Void) {
    channel = nil
    print("Channel \(channel?.title)")
    channelClient.createChannel(title: title, completion: { channel in
      print("Completion \(channel.title)")
      self.channel = channel
      completion(channel)
    })
  }
}
