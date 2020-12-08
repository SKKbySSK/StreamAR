////
////  SpatialAnchorView.swift
////  streamar-ios
////
////  Created by Kaisei Sunaga on 2020/09/13.
////  Copyright © 2020 Kaisei Sunaga. All rights reserved.
////
//
//import SwiftUI
//import ARKit
//import RxCocoa
//import RxSwift
//import CoreLocation
//import AzureSpatialAnchors
//import Combine
//
//class SpatialAnchorRecordingViewController {
//  let config: AzureSpatialAnchorsConfig
//  fileprivate var view: ARSpatialAnchorView!
//  private var cancellables: [AnyCancellable] = []
//
//  init(config: AzureSpatialAnchorsConfig) {
//    self.config = config
//  }
//
//  func createCloudAnchor(at transform: simd_float4x4, name: String) -> AnyPublisher<Location?, Never> {
//    let locationFuture = Future<LocationDocument?, Never> { [weak self] promise in
//      guard let this = self, let loc = this.view.currentLocation else {
//        promise(.success(nil))
//        return
//      }
//
//      let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
//      CLGeocoder().reverseGeocodeLocation(location)  { placemarks, error in
//        guard let postalCode = placemarks?.first?.postalCode, error == nil else {
//          promise(.success(nil))
//          return
//        }
//
//        this.view.createCloudAnchor(transform: transform, completion: { anchor, error in
//          if let error = error {
//            print(error)
//            return
//          }
//
//          print("New Cloud Anchor : \(anchor.identifier)")
//          let location = LocationDocument(anchorId: anchor.identifier,
//                                          latitude: loc.latitude,
//                                          longitude: loc.longitude,
//                                          zip: postalCode, name: name, thumbnailUrl: "", manifestUrl: "")
//          promise(.success(location))
//        })
//      }
//    }
//
//    return locationFuture.flatMap({ location -> Future<Location?, Never> in
//      guard let location = location else {
//        return Future<Location?, Never> { $0(.success(nil)) }
//      }
//
//      return BroadcastClient.shared.appendLocation(location: location)
//    })
//    .eraseToAnyPublisher()
//  }
//
//  func appendNode(node: ARNodeConfig) {
//    view.appendNode(node: node)
//  }
//
//  func clearNode() {
//    view.removeNodes()
//  }
//}
//
//struct SpatialAnchorRecordingView: UIViewRepresentable {
//  @Binding var isRunning: Bool
//  let controller: SpatialAnchorRecordingViewController
//  let onTap: (simd_float4x4) -> Void
//  private let delegate: SpatialAnchorRecordingDelegate
//
//  init(isRunning: Binding<Bool>, controller: SpatialAnchorRecordingViewController, onTap: @escaping (simd_float4x4) -> Void) {
//    self._isRunning = isRunning
//    self.controller = controller
//    self.onTap = onTap
//    delegate = SpatialAnchorRecordingDelegate(onTap: onTap)
//  }
//
//  func makeUIView(context: Context) -> ARSpatialAnchorView {
//    let view = ARSpatialAnchorView()
//    controller.view = view
//    view.delegate = delegate
//    view.setup(config: controller.config)
//    if isRunning {
//      view.run()
//    }
//
//    return view
//  }
//
//  func updateUIView(_ uiView: ARSpatialAnchorView, context: Context) {
//    controller.view = uiView
//    uiView.delegate = delegate
//    if isRunning {
//      uiView.run()
//    } else {
//      uiView.pause()
//    }
//  }
//}
//
//private class SpatialAnchorRecordingDelegate: ARSpatialAnchorViewDelegate {
//  let disposeBag = DisposeBag()
//  let onTap: (simd_float4x4) -> Void
//
//  init (onTap: @escaping (simd_float4x4) -> Void) {
//    self.onTap = onTap
//  }
//
//  func arView(_ view: ARSpatialAnchorView, didUpdate state: ARSpatialAnchorViewState) {
//
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onTap transform: simd_float4x4) {
//    onTap(transform)
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onUpdated location: (longitude: Double, latitude: Double)) {
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onUpdatedRecognizing progress: Float) {
//  }
//
//  func arView(_ view: ARSpatialAnchorView, onRestored anchor: ASACloudSpatialAnchor) -> ARNodeConfig? {
//    return nil
//  }
//}
