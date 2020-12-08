//
//  ViewerPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/13.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import AzureSpatialAnchors
import ARKit

class ViewerPage: BindablePage, ARSpatialAnchorViewDelegate, ARHandDetectorDelegate {
  private let arView = ARSpatialAnchorView()
  private var viewModel: ViewerViewModel!
  
  static func create(location: Location) -> ViewerPage {
    let vc = ViewerPage()
    vc.viewModel = ViewerViewModel(location: location)
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    arView.delegate = self
    arView.handDelegate = self
    arView.setup(config: Config.azureSpatialAnchors)
    view.addFittedChild(arView)
    
    viewModel.canLocalize.subscribe({ [unowned self] ev in
      guard ev.element ?? false else { return }
      self.arView.localizeCloudAnchor(location: self.viewModel.location).subscribe({ success in
        guard let success = success.element else { return }
        if !success {
          print("Failed to initialize Azure Spatial Anchors!")
          self.navigationController?.popViewController(animated: true)
        }
      }).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
    
    viewModel.located.subscribe({ [unowned self] ev in
      guard let (nodeConfig, channel) = ev.element else { return }
      print("Located : \(channel.title)")
      self.arView.appendNode(node: nodeConfig)
    }).disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    arView.run()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    arView.dispose()
  }
  
  func arView(_ view: ARSpatialAnchorView, didUpdate state: ARSpatialAnchorViewState) {
    
  }
  
  func arView(_ view: ARSpatialAnchorView, onTap transform: simd_float4x4) {
    
  }
  
  func arView(_ view: ARSpatialAnchorView, onUpdated location: CLLocation) {
    
  }
  
  func arView(_ view: ARSpatialAnchorView, onUpdatedRecognizing readyProgress: Float, recommendedProgress: Float) {
    viewModel.onRecognizingProgress(recommendedProgress)
  }
  
  func arView(_ view: ARSpatialAnchorView, onRestored anchor: ASACloudSpatialAnchor) -> ARNodeConfig? {
//    let location = viewModel.location.anchorIds.first(where: { $0 == anchor.identifier })!
//    let node = ARVideoNode(location: location)
//    node.streamSize = CGSize(width: 1920, height: 1080)
//    node.geometrySize = 0.8
//    node.play()
//
//    return ARNodeConfig(node: node, trackCamera: true, cloudAnchor: anchor)
    viewModel.onRestored(anchor: anchor)
    return nil
  }
  
  func hand(_ view: ARSpatialAnchorView, _ detector: HandDetector, didTouch delta: CGPoint, index: CGPoint, thumb: CGPoint) {
    
  }
}
