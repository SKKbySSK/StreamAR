//
//  ARPlaceholderNode.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import ARKit

class ARPlaceholderNode: SCNNode {
  override init() {
    super.init()
    let plane = SCNPlane(width: -1, height: 1)
    plane.firstMaterial?.diffuse.contents = UIColor.gray
    geometry = plane
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
