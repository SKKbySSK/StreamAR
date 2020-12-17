//
//  CameraViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/12/10.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CameraViewModel: ViewModelBase {
  private let channelClient = ChannelClient()
  private var writer = BufferWriter()
  private var tempManager = TemporaryManager(directory: nil, prefix: "rec", type: .mov)
  
  let channel: Channel
  let controller: CameraController
  
  private(set) var isRecording = false
  
  init(channel: Channel, controller: CameraController) {
    self.channel = channel
    self.controller = controller
    super.init()
  }
  
  func start() {
    guard !isRecording else { return }
    
    guard let res = controller.resolution else { return }
    writer.record(width: res.width, height: res.height, url: tempManager.getPath(), sampleUpdated: { [weak self] in
      guard let this = self else { return }
      this.onSampleUpdated(writer: $0, controller: this.controller)
    })
    
    controller.writer = writer
    isRecording = true
  }
  
  func stop() {
    guard isRecording else { return }
    
    writer.stop(nextUrl: nil, completion: { [weak self] url, time in
      guard let this = self else { return }
      
      this.channelClient.sendVideo(channelId: this.channel.id!, video: url, position: time.position, completion: this.onUploaded(_:_:))
      this.controller.writer = nil
      this.isRecording = false
    })
  }
  
  private func onSampleUpdated(writer: BufferWriter, controller: CameraController) {
    guard writer.durationSeconds >= 4.5 else { return }
    
    writer.stop(nextUrl: self.tempManager.getPath(), completion: { [weak self]  url, time in
      guard let this = self else { return }
      this.channelClient.sendVideo(channelId: this.channel.id!, video: url, position: time.position, completion: this.onUploaded(_:_:))
    })
  }
  
  private func onUploaded(_ url: URL, _ error: Error?) {
    do {
      try FileManager.default.removeItem(at: url)
    } catch let error {
      print(error.localizedDescription)
    }
    
    guard let error = error else {
      return
    }
    
    print(error.localizedDescription)
  }
}
