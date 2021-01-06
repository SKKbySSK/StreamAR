//
//  ChannelSelector.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/04.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChannelSelectorViewModel: ViewModelBase {
  private let selectedSubject = PublishSubject<Channel>()
  private let channelClient = ChannelClient()
  
  let location: Location
  
  init(location: Location) {
    self.location = location
  }
  
  var selected: Observable<Channel> {
    selectedSubject.asObservable()
  }
  
  var liveChannels: Observable<[Channel]> {
    channelClient.getChannels(byLocation: location.id, vod: false)
  }
  
  var vodChannels: Observable<[Channel]> {
    channelClient.getChannels(byLocation: location.id, vod: true)
  }
  
  var selectedChannel: Observable<Channel> {
    return selectedSubject.asObservable()
  }
  
  func select(channel: Channel) {
    selectedSubject.onNext(channel)
  }
}
