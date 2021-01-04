//
//  LocationRecorderPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/09.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import AzureSpatialAnchors
import Toast
import LGButton

class LocationRecorderPage: BindablePage, ARSpatialAnchorViewDelegate {
  private var viewModel: LocationRecorderViewModel!
  private let arView = ARSpatialAnchorView()
  private let saveView = LocationRecorderSaveView.create()
  private let placeholderNode = ARPlaceholderNode()
  
  static func create(viewModel: LocationRecorderViewModel) -> LocationRecorderPage {
    let page = LocationRecorderPage()
    page.viewModel = viewModel
    
    return page
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    arView.delegate = self
    arView.setup(config: Config.azureSpatialAnchors)
    
    view.addSubview(arView)
    view.fitChild(arView, keyboard: false)
    
    view.addSubview(saveView)
    saveView.isHidden = true
    saveView.translatesAutoresizingMaskIntoConstraints = false
    saveView.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor, constant: -30).isActive = true
    saveView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    saveView.widthAnchor.constraint(equalToConstant: 250).isActive = true
    saveView.heightAnchor.constraint(equalToConstant: 129).isActive = true
    saveView.save.subscribe({ [unowned self] ev in
      guard let name = ev.element else { return }
      self.saveLocation(name: name)
    }).disposed(by: disposeBag)
    
    viewModel.state.subscribe({ [weak self] ev in
      guard let state = ev.element, let this = self else { return }
      this.saveView.isHidden = true
      this.view.hideAllToasts()
      switch state {
      case .failed:
        this.view.makeToast("ARの初期化に失敗しました", duration: 3, position: .bottom, title: "エラー", image: nil, style: ToastStyle(), completion: { _ in
          this.dismiss(animated: true, completion: nil)
        })
      case .localizing(progress: let progress):
        this.view.makeToast("カメラを動かし続けてください", duration: .infinity, position: .bottom, title: "初期化中(\(Int(round(progress * 100)))%)", image: nil, style: ToastStyle(), completion: nil)
      case .localized:
        this.view.makeToast("配信を行いたい場所をタップしてください", duration: .infinity, position: .bottom, title: nil, image: nil, style: ToastStyle(), completion: nil)
      case .placed:
        UIView.animate(withDuration: 2) {
          this.saveView.isHidden = false
        }
      default:
        break
      }
    }).disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.onInitializing()
    arView.run(useLocation: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    arView.dispose()
  }
  
  private func saveLocation(name: String) {
    guard let transform = viewModel.currentTransform else { return }
    guard let rawImg = arView.currentFrame?.capturedImage else { return }
    guard let img = UIImage.fromBuffer(pixelBuffer: rawImg) else { return }
    
    arView.createCloudAnchor(transform: transform).subscribe({ [weak self] ev in
      guard let anchorOp = ev.element, let anchor = anchorOp, let this = self else { return }
      this.viewModel.save(location: name, anchorId: anchor.identifier, image: img).subscribe({ ev in
        guard ev.element != nil else { return }
      }).disposed(by: this.disposeBag)
    }).disposed(by: disposeBag)
  }
  
  // MARK: - ARSpatialAnchorViewDelegate
  func arView(_ view: ARSpatialAnchorView, didUpdate state: ARSpatialAnchorViewState) {
  }
  
  func arView(_ view: ARSpatialAnchorView, onUpdatedRecognizing readyProgress: Float, recommendedProgress: Float) {
    print("Ready \(readyProgress), Recommended \(recommendedProgress)")
    viewModel.onLocalizing(progress: recommendedProgress)
  }
  
  func arView(_ view: ARSpatialAnchorView, onTap transform: simd_float4x4) {
    guard viewModel.setTransform(transform) else { return }
    view.removeNodes()
    placeholderNode.simdWorldTransform = transform
    view.appendNode(node: ARNodeConfig(node: placeholderNode, trackCamera: true, cloudAnchor: nil))
  }
  
  func arView(_ view: ARSpatialAnchorView, onUpdated location: CLLocation) {
    viewModel.setLocation(location)
  }
  
  func arView(_ view: ARSpatialAnchorView, onRestored anchor: ASACloudSpatialAnchor) -> ARNodeConfig? {
    return nil
  }
}
