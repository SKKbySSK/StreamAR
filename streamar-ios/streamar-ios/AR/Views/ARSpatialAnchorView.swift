//
//  ARRecorderView.swift
//  
//
//  Created by Kaisei Sunaga on 2020/09/13.
//

import Foundation
import UIKit
import ARKit
import CoreLocation
import RxSwift
import RxCocoa

#if targetEnvironment(simulator)
#else
import AzureSpatialAnchors
#endif

struct AzureSpatialAnchorsConfig {
  var accountId: String
  var accountKey: String
  var domain: String
}

enum ARSpatialAnchorViewState {
  case initialized
  case ready
  case restoring
  case failed
}

struct ARNodeConfig {
  let node: SCNNode
  let trackCamera: Bool
  let cloudAnchor: ASACloudSpatialAnchor?
}

protocol ARSpatialAnchorViewDelegate: class {
  func arView(_ view: ARSpatialAnchorView, didUpdate state: ARSpatialAnchorViewState)
  func arView(_ view: ARSpatialAnchorView, onTap transform: simd_float4x4)
  func arView(_ view: ARSpatialAnchorView, onUpdated location: CLLocation)
  func arView(_ view: ARSpatialAnchorView, onUpdatedRecognizing readyProgress: Float, recommendedProgress: Float)
  func arView(_ view: ARSpatialAnchorView, onRestored anchor: ASACloudSpatialAnchor) -> ARNodeConfig?
}

protocol ARHandDetectorDelegate: class {
  func hand(_ view: ARSpatialAnchorView, _ detector: HandDetector, didTouch delta: CGPoint, index: CGPoint, thumb: CGPoint)
}

class ARSpatialAnchorView: UIView, ARSCNViewDelegate, ARSessionDelegate, ASACloudSpatialAnchorSessionDelegate, CLLocationManagerDelegate, HandDetectorDelegate {
  weak var delegate: ARSpatialAnchorViewDelegate?
  weak var handDelegate: ARHandDetectorDelegate?
  
  static var isSupported: Bool {
    return ARWorldTrackingConfiguration.isSupported
  }
  
  var pointOfView: SCNNode? {
    return scnView.pointOfView
  }
  
  var rootNode: SCNNode {
    return scnView.scene.rootNode
  }
  
  var currentFrame: ARFrame? {
    return scnView.session.currentFrame
  }
  
  private var cloudSession: ASACloudSpatialAnchorSession?
  private let scnView: ARSCNView
  private let locationManager = CLLocationManager()
  private let handDetector = HandDetector()
  private var tapGesture: UITapGestureRecognizer! = nil
  private var readyToProcess = false
  private var cloudAnchors: [ASACloudSpatialAnchor] = []
  private var nodes: [ARNodeConfig] = []
  
  override init(frame: CGRect) {
    state = .initialized
    scnView = ARSCNView()
    super.init(frame: frame)
    backgroundColor = UIColor.systemBackground
    
    if !ARSpatialAnchorView.isSupported {
      let unsupportedLabel = UILabel()
      unsupportedLabel.text = "このデバイスはAR機能をサポートしていません"
      addCenteredChild(unsupportedLabel)
      return
    }
    
    handDetector.delegate = self
    
    locationManager.delegate = self
    locationManager.distanceFilter = 20
    
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
    scnView.addGestureRecognizer(tapGesture)
    
    scnView.delegate = self
    scnView.session.delegate = self
    scnView.scene = SCNScene()
    scnView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(scnView)
    
    scnView.frame = bounds
    scnView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    scnView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    scnView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    scnView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func onTap(sender: UITapGestureRecognizer) {
    guard let result = hitTest(location: sender.location(in: scnView)).first else { return }
    delegate?.arView(self, onTap: result.worldTransform)
  }
  
  private(set) var state: ARSpatialAnchorViewState {
    didSet {
      print("[STATE] \(state)")
      delegate?.arView(self, didUpdate: state)
    }
  }
  
  private(set) var running: Bool = false
  
  // MARK: - Public Funcs
  func hitTest(location: CGPoint) -> [ARRaycastResult] {
    guard let query = scnView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .any) else { return [] }
    let results = scnView.session.raycast(query)
    return results
  }
  
  func setup(config: AzureSpatialAnchorsConfig) {
    guard ARSpatialAnchorView.isSupported else {
      return
    }
    
    guard state == .initialized else {
      return
    }
    
    guard let session = ASACloudSpatialAnchorSession() else {
      print("Failed to initialize ASACloudSpatialAnchorSession")
      state = .failed
      return
    }
    
    session.session = scnView.session
    session.logLevel = .information
    session.delegate = self
    session.configuration.accountId = config.accountId
    session.configuration.accountKey = config.accountKey
    session.configuration.accountDomain = config.domain
    cloudSession = session
    state  = .restoring
  }
  
  @discardableResult
  func run(useLocation: Bool) -> Bool {
    guard !running else {
      return true
    }
    
    guard ARSpatialAnchorView.isSupported else {
      return false
    }
    
    guard let session = cloudSession else {
      fatalError("You MUST call setup first")
    }
    
    session.start()
    
    if useLocation {
      locationManager.requestWhenInUseAuthorization()
    }
    
    scnView.debugOptions = .showFeaturePoints
    
    let config = ARWorldTrackingConfiguration()
    scnView.session.run(config)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
      self.readyToProcess = true
    })
    running = true
    return true
  }
  
  func pause() {
    guard running else {
      return
    }
    
    guard let session = cloudSession else {
      fatalError("You MUST call setup first")
    }
    session.stop()
    
    readyToProcess = false
    locationManager.stopUpdatingLocation()
    scnView.session.pause()
  }
  
  func dispose() {
    pause()
    for node in nodes {
      node.node.removeFromParentNode()
    }
    
    nodes.removeAll()
    
    guard let session = cloudSession else { return }
    cloudSession = nil
    session.dispose()
  }
  
  func createCloudAnchor(transform: simd_float4x4) -> Observable<ASACloudSpatialAnchor?> {
    guard let cloudSession = cloudSession else { return Observable.just(nil) }
    guard let cloudAnchor = ASACloudSpatialAnchor() else { return Observable.just(nil) }
    
    let observable = Observable<ASACloudSpatialAnchor?>.create { observer in
      let anchor = ARAnchor(transform: transform)
      
      let secondsInAWeek = 60 * 60 * 24 * 7 * 10
      let tenWeeksFromNow = Date(timeIntervalSinceNow: TimeInterval(secondsInAWeek))
      
      cloudAnchor.localAnchor = anchor
      cloudAnchor.expiration = tenWeeksFromNow
      
      print("Creating cloud anchor...")
      
      cloudSession.createAnchor(cloudAnchor, withCompletionHandler: { [weak self] error in
        if let error = error {
          observer.onError(error)
          return
        }
        
        print("Created cloud anchor \(String(describing: cloudAnchor.identifier))")
        self?.scnView.session.add(anchor: anchor)
        observer.onNext(cloudAnchor)
        observer.onCompleted()
      })
      
      return Disposables.create()
    }
    
    return observable.timeout(.seconds(10), scheduler: MainScheduler.instance)
  }
  
  func localizeCloudAnchor(location: Location) -> Observable<Bool> {
    guard let session = cloudSession else {
      return Observable.just(false)
    }
    
    return Observable.create({ observer in
      let ids = location.anchorIds
      guard let criteria = ASAAnchorLocateCriteria() else {
        observer.onNext(false)
        observer.onCompleted()
        return Disposables.create()
      }
      
      criteria.identifiers = ids
      session.createWatcher(criteria)
      observer.onNext(true)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func appendNode(node: ARNodeConfig) {
    scnView.scene.rootNode.addChildNode(node.node)
    nodes.append(node)
  }
  
  func removeNodes() {
    for node in nodes where node.cloudAnchor == nil {
      node.node.removeFromParentNode()
    }
    
    nodes.removeAll()
  }
  
  // MARK: - ARSCNViewDelegate
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    print(error)
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    guard let session = cloudSession else {
      return
    }
    
    session.reset()
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    guard let pov = scnView.pointOfView else { return }
    for nodeConfig in nodes where nodeConfig.trackCamera {
      let node = nodeConfig.node
      let pos = pov.simdWorldPosition
      node.simdLook(at: simd_float3(x: pos.x, y: node.simdWorldPosition.y, z: pos.z))
    }
    
    guard let session = cloudSession, readyToProcess else {
      return
    }
    
    session.processFrame(scnView.session.currentFrame)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    guard let delegate = delegate else {
      return nil
    }
    
    for cloudAnchor in cloudAnchors {
      if cloudAnchor.localAnchor.identifier == anchor.identifier {
        guard let nodeConfig = delegate.arView(self, onRestored: cloudAnchor) else {
          continue
        }
        
        nodes.append(nodeConfig)
        return nodeConfig.node
      }
    }
    
    return nil
  }
  
  // MARK: - ARSessionDelegate
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    guard handDetector.delegate != nil else { return }
    handDetector.request(imageBuffer: frame.capturedImage)
  }
  
  // MARK: - ASACloudSpatialAnchorSessionDelegate
  func onLogDebug(_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASAOnLogDebugEventArgs!) {
    if let message = args.message {
       // print("[LOG] \(message)")
    }
  }
  
  func anchorLocated(_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASAAnchorLocatedEventArgs!) {
    let sessionStatus = args.status
    
    print("Session Status : \(sessionStatus)")
    switch (sessionStatus) {
    case .alreadyTracked:
      state = .ready
    case .located:
      guard let anchor = args.anchor else { return }
      cloudAnchors.append(anchor)
      print("Cloud Anchor found! Identifier: \(anchor.identifier ?? "nil")")
      scnView.session.add(anchor: anchor.localAnchor)
    case .notLocated:
      state = .restoring
    case .notLocatedAnchorDoesNotExist:
      fallthrough
    default:
      state = .failed
    }
  }
  
  
  func sessionUpdated(_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASASessionUpdatedEventArgs!) {
    guard let status = args.status else { return }
    delegate?.arView(self, onUpdatedRecognizing: status.readyForCreateProgress, recommendedProgress: status.recommendedForCreateProgress)
  }
  
  func error (_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASASessionErrorEventArgs!) {
    if let errorMessage = args.errorMessage {
      print("Error code: \(args.errorCode), message: \(errorMessage)")
    }
  }
  
  func locateAnchorsCompleted(_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASALocateAnchorsCompletedEventArgs!) {
    state = .ready
  }
  
  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    delegate?.arView(self, onUpdated: location)
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard manager.authorizationStatus == .authorizedWhenInUse else {
      return
    }
    
    locationManager.startUpdatingLocation()
  }
  
  // MARK: - ARHandDetectorDelegate
  func hand(_ detector: HandDetector, didTouch delta: CGPoint, index: CGPoint, thumb: CGPoint) {
    handDelegate?.hand(self, detector, didTouch: delta, index: index, thumb: thumb)
  }
}
