//
//  CALayerView.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import SwiftUI

struct CALayerView: UIViewControllerRepresentable {
  var layer: CALayer
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
    let viewController = UIViewController()
    
    viewController.view.layer.addSublayer(layer)
    layer.frame = viewController.view.layer.frame
    
    return viewController
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
    layer.frame = uiViewController.view.layer.frame
  }
}
