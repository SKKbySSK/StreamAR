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
import RxSwift
import Toast

class ViewerPage: BindablePage, ARSpatialAnchorViewDelegate, ARHandDetectorDelegate {
  private let arView = ARSpatialAnchorView()
  private var viewModel: ViewerViewModel!
  private var selector: ChannelSelectorViewModel!
  private var selectorAnchor: NSLayoutConstraint!
  
  var selectorHeight: CGFloat {
    422 + view.safeAreaInsets.bottom
  }
  
  private lazy var selectorView: ChannelSelector = {
    let view = ChannelSelector.create(viewModel: selector)
    view.toggleButton.rx.tap.subscribe({ [unowned self] ev in
      if self.selectorView.isClosed {
        self.showSelector()
      } else {
        self.hideSelector(openable: true)
      }
    }).disposed(by: disposeBag)
    return view
  }()
  
  static func create(location: Location) -> ViewerPage {
    let vc = ViewerPage()
    vc.viewModel = ViewerViewModel(location: location)
    vc.selector = ChannelSelectorViewModel(location: location)
    return vc
  }
  
  private func configureSelectorView() {
    selectorView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(selectorView)
    selectorView.heightAnchor.constraint(equalToConstant: selectorHeight).isActive = true
    selectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    selectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    selectorAnchor = selectorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    selectorAnchor.constant = selectorHeight
    selectorAnchor.isActive = true
  }
  
  private func configureArView() {
    arView.delegate = self
    arView.handDelegate = self
    arView.setup(config: Config.azureSpatialAnchors)
    view.addFittedChild(arView)
  }
  
  private func configureToast() {
    viewModel.state.observeOn(MainScheduler.instance).subscribe({ [weak self] ev in
      guard let state = ev.element, let this = self else { return }
      this.view.hideAllToasts()
      switch state {
      case .localizing(progress: let progress):
        this.view.makeToast("カメラを動かし続けてください", duration: .infinity, position: .bottom, title: "初期化中(\(Int(round(progress * 100)))%)", image: nil, style: ToastStyle(), completion: nil)
      case .localized:
        this.view.makeToast("配信場所にカメラを向けてください", duration: .infinity, position: .bottom, title: nil, image: nil, style: ToastStyle(), completion: nil)
      case .anchorLocated:
        self?.showSelector()
        this.view.makeToast("見たい配信を選択してください", duration: 5, position: .top, title: nil, image: nil, style: ToastStyle(), completion: nil)
      default:
        break
      }
    }).disposed(by: disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureArView()
    configureSelectorView()
    configureToast()
    
    viewModel.canLocalize.subscribe({ [unowned self] ev in
      guard ev.element ?? false else { return }
      self.arView.localizeCloudAnchor(location: self.viewModel.location).subscribe({ [weak self] success in
        guard let success = success.element else { return }
        if success {
          print("Localized!")
        } else {
          print("Failed to initialize Azure Spatial Anchors!")
          self?.navigationController?.popViewController(animated: true)
        }
      }).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
    
    viewModel.located.subscribe({ [unowned self] ev in
      guard let (nodeConfig, _) = ev.element else { return }
      self.arView.appendNode(node: nodeConfig)
    }).disposed(by: disposeBag)
    
    selector.selectedChannel.subscribe({ [unowned self] ev in
      guard let channel = ev.element else { return }
      self.hideSelector(openable: true)
      self.viewModel.select(channel: channel)
    }).disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    arView.run(useLocation: false)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    arView.pause()
    arView.dispose()
  }
  
  func showSelector() {
    selectorAnchor.constant = 0
    UIView.animate(withDuration: 0.5, animations: {
      self.selectorView.isClosed = false
      self.view.layoutIfNeeded()
    })
  }
  
  func hideSelector(openable: Bool) {
    let offset = (openable ? selectorHeight - 80 : selectorHeight)
    selectorAnchor.constant = offset
    UIView.animate(withDuration: 0.5, animations: {
      self.selectorView.isClosed = true
      self.view.layoutIfNeeded()
    })
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
    viewModel.onRestored(anchor: anchor)
    return nil
  }
  
  func hand(_ view: ARSpatialAnchorView, _ detector: HandDetector, didTouch delta: CGPoint, index: CGPoint, thumb: CGPoint) {
    
  }
}
