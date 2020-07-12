//
//  RecordingViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

class RecordingViewModel: ObservableObject {
  @Published var isRecording: Bool = false
  private var writer = BufferWriter()
  private var tempManager = TemporaryManager(directory: nil, prefix: "rec", type: .mov)
  
  func toggleRecording(controller: CameraController) {
    if !isRecording {
      guard let res = controller.resolution else { return }
      writer.record(width: res.width, height: res.height, url: tempManager.getPath(),
                    sampleUpdated: { self.onSampleUpdated(writer: $0, controller: controller) })
      controller.writer = writer
      isRecording = true
    } else {
      writer.stop(nextUrl: nil, completion: { url in
        controller.writer = nil
        DispatchQueue.main.async {
          self.isRecording = false
        }
      })
    }
  }
  
  private func onSampleUpdated(writer: BufferWriter, controller: CameraController) {
    guard writer.durationSeconds >= 5 else { return }
    
    writer.stop(nextUrl: self.tempManager.getPath(), completion: { url in
      print(url)
    })
  }
}
