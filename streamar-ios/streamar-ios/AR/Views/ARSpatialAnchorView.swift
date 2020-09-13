//
//  ARRecorderView.swift
//  
//
//  Created by Kaisei Sunaga on 2020/09/13.
//

import Foundation
import UIKit
import AzureSpatialAnchors
import ARKit

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

protocol ARSpatialAnchorViewDelegate: class {
  func arView(_ view: ARSpatialAnchorView, didUpdate state: ARSpatialAnchorViewState)
}

class ARSpatialAnchorView: UIView, ASACloudSpatialAnchorSessionDelegate {
  weak var delegate: ARSpatialAnchorViewDelegate?
  
  private var cloudSession: ASACloudSpatialAnchorSession?
  private let scnView: ARSCNView
  
  override init(frame: CGRect) {
    state = .initialized
    scnView = ARSCNView()
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private(set) var state: ARSpatialAnchorViewState {
    didSet {
      delegate?.arView(self, didUpdate: state)
    }
  }
  
  func restore(config: AzureSpatialAnchorsConfig) {
    guard let session = ASACloudSpatialAnchorSession() else {
      print("Failed to initialize ASACloudSpatialAnchorSession")
      state = .failed
      return
    }
    
    cloudSession = session
    session.session = scnView.session
    session.logLevel = .information
    session.delegate = self
    session.configuration.accountId = config.accountId
    session.configuration.accountKey = config.accountKey
    session.configuration.accountDomain = config.domain
    session.start()
    state  = .restoring
  }
  
  internal func anchorLocated(_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASAAnchorLocatedEventArgs!) {
    let sessionStatus = args.status
    
    switch (sessionStatus) {
    case .alreadyTracked:
      state = .ready
      break
    case .located:
      let anchor = args.anchor!
      print("Cloud Anchor found! Identifier: \(anchor.identifier ?? "nil")")
    case .notLocated:
      state = .restoring
      break
    case .notLocatedAnchorDoesNotExist:
      fallthrough
    default:
      state = .failed
      break
    }
  }
  
  func locateAnchorsCompleted(_ cloudSpatialAnchorSession: ASACloudSpatialAnchorSession!, _ args: ASALocateAnchorsCompletedEventArgs!) {
    state = .ready
  }
}
