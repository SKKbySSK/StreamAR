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

class ViewerViewModel: ViewModelBase {
  private let channelClient = ChannelClient()
  private let canLocalizeRelay = BehaviorRelay(value: false)
  private let nodesRelay = BehaviorRelay<[ARNodeConfig]>(value: [])
  private let locatedRelay = PublishRelay<(ARNodeConfig, Channel)>()
  private var appendedNodes: [ARNodeConfig] = []
  
  let location: Location
  
  init(location: Location) {
    self.location = location
    super.init()
    
    Observable.combineLatest(channelClient.getChannels(byLocation: location.id), nodesRelay).subscribe({ [weak self] ev in
      guard let this = self else { return }
      guard let (channels, nodes) = ev.element else { return }
      
      for node in nodes where !this.appendedNodes.contains(where: { $0.cloudAnchor!.identifier == node.cloudAnchor!.identifier }) {
        guard let channel = channels.first(where: { $0.anchorId == node.cloudAnchor!.identifier }) else { continue }
        let video = ARVideoNode(channel: channel)
        video.play()
        
        node.node.addChildNode(video)
        this.appendedNodes.append(node)
        this.locatedRelay.accept((node, channel))
      }
    }).disposed(by: disposeBag)
  }
  
  var canLocalize: Observable<Bool> {
    return canLocalizeRelay.distinctUntilChanged().asObservable()
  }
  
  var located: Observable<(ARNodeConfig, Channel)> {
    return locatedRelay.asObservable()
  }
  
  func onRecognizingProgress(_ progress: Float) {
    canLocalizeRelay.accept(progress >= 1)
    print(progress)
  }
  
  func onRestored(anchor: ASACloudSpatialAnchor) -> ARNodeConfig {
    let node = ARNodeConfig(node: SCNNode(), trackCamera: true, cloudAnchor: anchor)
    var nodes = nodesRelay.value
    nodes.append(node)
    
    nodesRelay.accept(nodes)
    
    return node
  }
}
