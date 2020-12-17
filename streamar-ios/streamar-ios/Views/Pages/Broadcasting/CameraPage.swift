//
//  CameraPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/12/10.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class CameraPage: BindablePage {
  private var viewModel: CameraViewModel!
  
  private var controller: CameraController {
    viewModel.controller
  }
  
  static func create(viewModel: CameraViewModel) -> CameraPage {
    let vc = CameraPage()
    vc.viewModel = viewModel
    return vc
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
    viewModel.start()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    viewModel.stop()
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
