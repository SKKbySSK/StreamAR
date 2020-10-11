//
//  ARVideoNode.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/17.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation
import CoreVideo

class ARVideoNode: SCNNode {
  private let player: AVPlayer
  private let plane: SCNPlane
  
  let channel: Channel
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(channel: Channel) {
    self.channel = channel
    
    let maxSize = CGFloat(max(streamSize.width, streamSize.height))
    let w = CGFloat(streamSize.width) / maxSize
    let h = CGFloat(streamSize.height) / maxSize
    plane = SCNPlane(width: w, height: h)
    
    player = AVPlayer(url: URL(string: channel.manifestURL)!)
    super.init()
    
    plane.firstMaterial?.isDoubleSided = true
    plane.firstMaterial?.diffuse.contents = player
    geometry = plane
  }
  
  var geometrySize: CGFloat = 1 {
    didSet {
      let maxSize = CGFloat(max(streamSize.width, streamSize.height))
      let w = (CGFloat(streamSize.width) / maxSize) * geometrySize
      let h = (CGFloat(streamSize.height) / maxSize) * geometrySize
      plane.width = w
      plane.height = h
    }
  }
  
  var streamSize: CGSize = CGSize(width: 1920, height: 1080) {
    didSet {
      
    }
  }
  
  func play() {
    player.play()
  }
  
  func pause() {
    player.pause()
  }
  
  func toggle() {
    if player.rate != 0, player.error == nil {
      player.pause()
    } else {
      player.play()
    }
  }
}
