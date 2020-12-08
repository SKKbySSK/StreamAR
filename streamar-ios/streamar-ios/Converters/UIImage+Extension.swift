//
//  UIImage+Extension.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/16.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import VideoToolbox

extension UIImage {
  static func fromBuffer(pixelBuffer: CVPixelBuffer) -> UIImage? {
    var cgImage: CGImage?
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
    
    guard let img = cgImage else {
      return nil
    }
    
    return UIImage(cgImage: img)
  }
}
