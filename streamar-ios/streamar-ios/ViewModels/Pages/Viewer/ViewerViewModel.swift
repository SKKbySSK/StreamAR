//
//  ViewerViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/13.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SceneKit
import AzureSpatialAnchors

enum ViewerState: Equatable {
  case localizing(progress: Float)
  case localized
  case anchorLocated
  case channelSelected
}

class ViewerViewModel: ViewModelBase {
  private let channelClient = ChannelClient()
  private let canLocalizeRelay = BehaviorRelay(value: false)
  private let channelRelay = BehaviorRelay<Channel?>(value: nil)
  private let nodeRelay = BehaviorRelay<ARNodeConfig?>(value: nil)
  private let stateRelay = BehaviorRelay<ViewerState>(value: .localizing(progress: 0))
  private var appendedNodes: [ARNodeConfig] = []
  
  let location: Location
  
  init(location: Location) {
    self.location = location
    super.init()
  }
  
  var canLocalize: Observable<Bool> {
    return canLocalizeRelay.distinctUntilChanged().asObservable()
  }
  
  var state: Observable<ViewerState> {
    return stateRelay.distinctUntilChanged().asObservable()
  }
  
  var located: Observable<(ARNodeConfig, Channel)> {
    return Observable
      .combineLatest(nodeRelay.compactMap({ $0 }), channelRelay.compactMap({ $0 }))
      .do(onNext: { (node, channel) in
      for node in node.node.childNodes {
        let video = node as! ARVideoNode
        video.pause()
        video.removeFromParentNode()
      }
      
      let video = ARVideoNode(channel: channel)
      video.play()
      
      node.node.addChildNode(video)
      print("Located : \(channel.title)")
    })
  }
  
  func onRecognizingProgress(_ progress: Float) {
    print(progress)
    switch stateRelay.value {
    case .localizing(_):
      canLocalizeRelay.accept(progress >= 1)
      stateRelay.accept(progress >= 1 ? .localized : .localizing(progress: progress))
    default:
      break
    }
  }
  
  func onRestored(anchor: ASACloudSpatialAnchor) {
    let node = ARNodeConfig(node: SCNNode(), trackCamera: true, cloudAnchor: anchor)
    nodeRelay.accept(node)
    stateRelay.accept(.anchorLocated)
    print("Restored Anchor : \(anchor.identifier)")
  }
  
  func select(channel: Channel) {
    guard stateRelay.value == .anchorLocated || stateRelay.value == .channelSelected else {
      return
    }
    
    channelRelay.accept(channel)
    stateRelay.accept(.channelSelected)
  }
}
