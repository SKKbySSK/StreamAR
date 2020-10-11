//
//  HandTracker.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/21.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import Vision

protocol HandDetectorDelegate: class {
  func hand(_ detector: HandDetector, didTouch delta: CGPoint, index: CGPoint, thumb: CGPoint)
}

class HandDetector {
  private var nonDetectionFrame: Int = 0
  private var touching = false
  private var requesting = false
  
  weak var delegate: HandDetectorDelegate?
  
  func request(imageBuffer: CVPixelBuffer) {
    if requesting {
      return
    }
    requesting = true
    
    let request = VNDetectHumanHandPoseRequest(completionHandler: { (req, error) in
      self.requesting = false
      
      if let error = error {
        print(error)
        return
      }
      
      guard let observation = req.results?.first as? VNHumanHandPoseObservation else {
        if self.nonDetectionFrame >= 30 {
          self.nonDetectionFrame = 0
          self.touching = false
        }
        
        self.nonDetectionFrame += 1
        return
      }
      
      self.processObservation(observation)
    })
    
    let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, options: [:])
    try! handler.perform([request])
  }
  
  @discardableResult
  private func processObservation(_ observation: VNHumanHandPoseObservation) -> Bool {
    let thumb = try! observation.recognizedPoints(VNHumanHandPoseObservation.JointsGroupName.thumb)
    let indexFinger = try! observation.recognizedPoints(VNHumanHandPoseObservation.JointsGroupName.indexFinger)
    guard let thumbTipPoint = thumb[.thumbTip], let indexTipPoint = indexFinger[.indexTip] else { return false }
    guard thumbTipPoint.confidence > 0.5, indexTipPoint.confidence > 0.5 else { return false }
    
    let thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
    let indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
    
    let delta = CGPoint(x: thumbTip.x - indexTip.x, y: thumbTip.y - indexTip.y)
    let deltaLength = sqrt(pow(delta.x, 2) + pow(delta.y, 2))
    
    if !touching {
      if deltaLength <= 0.02 {
        touching = true
        delegate?.hand(self, didTouch: delta, index: indexTip, thumb: thumbTip)
      }
    }
    
    if touching, deltaLength >= 0.1 {
      touching = false
    }
    
    return true
  }
}
