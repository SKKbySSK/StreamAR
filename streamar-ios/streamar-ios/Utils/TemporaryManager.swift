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
    let path = directory.appendingPathComponent("\(prefix ?? "")\(uuid).\(type.rawValue)")
    
    return path
  }
}
