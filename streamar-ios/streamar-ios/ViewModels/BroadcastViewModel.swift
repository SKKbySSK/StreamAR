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
  
  func createChannel(location: Location, completion: @escaping (Channel) -> Void) {
    channel = nil
    channelClient.createChannel(title: title, completion: { channel in
      self.channel = channel
      completion(channel)
    })
  }
}
