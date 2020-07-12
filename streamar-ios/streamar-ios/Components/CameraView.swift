//
//  CameraView.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
  var controller: CameraController
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIViewController {
    return CameraViewController(controller: controller)
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CameraView>) {
  }
}

class CameraViewController: UIViewController {
  private let controller: CameraController!
  
  init(controller: CameraController) {
    self.controller = controller
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.controller = nil
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.layer.addSublayer(controller.layer)
    controller.layer.frame = view.layer.bounds
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    controller.resumeSession()
    controller.updateOrientation()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    controller.endSession()
    controller.updateOrientation()
  }
  
  override func viewWillLayoutSubviews() {
    controller.layer.frame = view.layer.bounds
    controller.updateOrientation()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    controller.layer.frame = view.layer.bounds
    controller.updateOrientation()
  }
}
