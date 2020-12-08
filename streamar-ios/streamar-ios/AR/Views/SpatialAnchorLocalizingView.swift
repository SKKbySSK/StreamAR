////
////  SpatialAnchorLocalizingView.swift
////  streamar-ios
////
////  Created by Kaisei Sunaga on 2020/09/16.
////  Copyright © 2020 Kaisei Sunaga. All rights reserved.
////
//
//import Foundation
//import ARKit
//import SwiftUI
//import RxSwift
//import RxCocoa
//import AzureSpatialAnchors
//
//class SpatialAnchorLocalizingController {
//  fileprivate var view: ARSpatialAnchorView! = nil
//
//  func localize(locations: [Location]) -> Observable<Bool> {
//    view.localizeCloudAnchor(locations: locations)
//  }
//
//  @discardableResult
//  func localizeNeaby() -> Observable<Bool> {
//    guard let loc = view.currentLocation else {
//      return Observable.just(false)
//    }
//
//    return BroadcastClient.shared
//      .location(latitude: loc.latitude, longitude: loc.longitude, range: 0.05)
//      .flatMap({ self.view.localizeCloudAnchor(locations: $0) })
//  }
//}
//
//struct SpatialAnchorLocalizingView: UIViewRepresentable {
//  private let delegate: SpatialAnchorLocalizingDelegate
//
//  @Binding var isRunning: Bool
//  let config: AzureSpatialAnchorsConfig
//  let controller: SpatialAnchorLocalizingController
//
//  init(isRunning: Binding<Bool>, readyToLocalize: Binding<Bool>, config: AzureSpatialAnchorsConfig, controller: SpatialAnchorLocalizingController) {
//    self._isRunning = isRunning
//    self.config = config
//    self.controller = controller
//
//    delegate = SpatialAnchorLocalizingDelegate(readyToLocalize: readyToLocalize)
//  }
//
//  func makeUIView(context: Context) -> ARSpatialAnchorView {
//    let view = ARSpatialAnchorView()
//    view.delegate = delegate
//    view.handDelegate = delegate
//    view.setup(config: config)
//    if isRunning {
//      view.run()
//    }
//
//    controller.view = view
//    return view
//  }
//
//  func updateUIView(_ uiView: ARSpatialAnchorView, context: Context) {
//    uiView.delegate = delegate
//    uiView.handDelegate = delegate
//    controller.view = uiView
//
//    if isRunning {
//      uiView.run()
//    } else {
//      uiView.pause()
//    }
//  }
//}
//
//private class SpatialAnchorLocalizingDelegate: ARSpatialAnchorViewDelegate, ARHandDetectorDelegate {
//  private let videoPlayer = AVPlayer(url: URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!)
//
//  private let disposeBag = DisposeBag()
//  @Binding private var readyToLocalize: Bool
//
//  init(readyToLocalize: Binding<Bool>) {
//    self._readyToLocalize = readyToLocalize
//  }
//
//  func arView(_ view: ARSpatialAnchorView, didUpdate state: ARSpatialAnchorViewState) {
//
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onTap transform: simd_float4x4) {
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onUpdated location: (longitude: Double, latitude: Double)) {
//
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onUpdatedRecognizing progress: Float) {
//    readyToLocalize = progress >= 1
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onRestored anchor: ASACloudSpatialAnchor) -> ARNodeConfig? {
//    videoPlayer.play()
//
//    let plane = SCNPlane(width: 1, height: 1)
//    plane.firstMaterial?.isDoubleSided = true
//    plane.firstMaterial?.diffuse.contents = videoPlayer
//    return ARNodeConfig(node: SCNNode(geometry: plane), trackCamera: true, cloudAnchor: anchor)
//  }
//
//  func hand(_ view: ARSpatialAnchorView, _ detector: HandDetector, didTouch delta: CGPoint, index: CGPoint, thumb: CGPoint) {
//    let screen = UIScreen.main.bounds.size
//    let screenPoint = CGPoint(x: screen.width * index.x, y: screen.height * index.y)
//    guard let pov = view.pointOfView, let hit = view.hitTest(location: screenPoint).first else { return }
//
//    let povPos = pov.worldPosition
//    let hitWorldPos = hit.worldTransform.worldDecomposed.worldPosition
//
//    for hitResult in view.rootNode.hitTestWithSegment(from: povPos, to: hitWorldPos, options: [:]) {
//      print(hitResult.node)
//    }
//  }
//
//  func togglePlayPause() {
//    if videoPlayer.rate != 0, videoPlayer.error == nil {
//      videoPlayer.pause()
//    } else {
//      videoPlayer.play()
//    }
//  }
//}
