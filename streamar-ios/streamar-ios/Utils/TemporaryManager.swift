//
//  TemporaryManager.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

enum TemporaryFileType: String {
  case mov = "mov"
}

class TemporaryManager {
  let directory: URL
  let prefix: String?
  let type: TemporaryFileType
  var count = 0
  
  init(directory: URL?, prefix: String?, type: TemporaryFileType) {
    self.prefix = prefix
    self.type = type
    
    if let dir = directory {
      self.directory = dir
    } else {
      // TODO: いまはデバッグしやすいようファイルApp用にドキュメントに保存しているが、キャッシュディレクトリにする(Info.plistも)
      self.directory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    }
  }
  
  func getPath() -> URL {
    let uuid = NSUUID().uuidString
    count += 1
    let path = directory.appendingPathComponent("\(prefix ?? "")\(count).\(type.rawValue)")
    
    return path
  }
}
