//
//  BufferWriter.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import AVFoundation

class BufferWriter {
  private(set) var isRecording = false
  
  private var audioInput: AVAssetWriterInput?
  private var videoInput: AVAssetWriterInput?
  private var sampleTime: CMTime?
  private var audioFormat: CMFormatDescription?
  
  private var writer: AVAssetWriter! = nil
  private var url: URL!
  private var size: (width: Int, height: Int)!
  
  private(set) var durationSeconds: Double = 0
  private var sampleUpdated: ((BufferWriter) -> Void)?
  
  func record(width: Int, height: Int, url: URL, sampleUpdated: ((BufferWriter) -> Void)?) {
    guard !isRecording else { return }
    if FileManager.default.fileExists(atPath: url.path) {
      try! FileManager.default.removeItem(at: url)
    }
    
    self.isRecording = true
    self.size = (width, height)
    self.url = url
    self.writer = try! AVAssetWriter(url: url, fileType: .mov)
    self.durationSeconds = 0
    self.sampleUpdated = sampleUpdated
  }
  
  func stop(nextUrl: URL?, completion: @escaping (URL) -> Void) {
    guard isRecording else { return }
    guard let audio = audioInput, let video = videoInput, let format = audioFormat else { return }
    let oldWriter = writer!
    
    if nextUrl != nil {
      self.url = nextUrl
      self.sampleTime = nil
      self.writer = try! AVAssetWriter(url: url, fileType: .mov)
      self.durationSeconds = 0
      initAudioInput(format: format)
      initVideoInput()
    }
    
    audio.markAsFinished()
    video.markAsFinished()
    
    oldWriter.finishWriting {
      let url = self.url!
      
      if nextUrl == nil {
        self.isRecording = false
        self.sampleUpdated = nil
        self.audioFormat = nil
        self.durationSeconds = 0
        self.sampleTime = nil
        self.writer = nil
        self.url = nil
        self.size = nil
      }
      
      completion(url)
    }
  }
  
  func writeAudio(buffer: CMSampleBuffer) {
    if audioInput == nil {
      guard let format = audioFormat ?? buffer.formatDescription else { return }
      initAudioInput(format: format)
    }
    
    autoStart(buffer: buffer)
    if audioInput!.isReadyForMoreMediaData {
      audioInput!.append(buffer)
    }
  }
  
  private func initAudioInput(format: CMFormatDescription) {
    audioFormat = format
    audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
      AVFormatIDKey: kAudioFormatLinearPCM,
    ], sourceFormatHint: format)
    audioInput!.expectsMediaDataInRealTime = true
  }
  
  func writeVideo(buffer: CMSampleBuffer) {
    if videoInput == nil {
      initVideoInput()
    }
    
    autoStart(buffer: buffer)
    if videoInput!.isReadyForMoreMediaData {
      videoInput!.append(buffer)
      
      let currentTimeStamp = buffer.presentationTimeStamp
      let duration = currentTimeStamp - sampleTime!
      if duration.isValid {
        durationSeconds = duration.seconds
        sampleUpdated?(self)
      }
    }
  }
  
  private func initVideoInput() {
    videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey : AVVideoCodecType.h264,
      AVVideoWidthKey: size!.width,
      AVVideoHeightKey: size!.height,
      AVVideoCompressionPropertiesKey : [
        AVVideoAverageBitRateKey : 2300000,
      ],
    ])
    videoInput!.expectsMediaDataInRealTime = true
  }
  
  private func autoStart(buffer: CMSampleBuffer) {
    guard sampleTime == nil, let audioInput = audioInput, let videoInput = videoInput else { return }
    
    if (writer.canAdd(audioInput)) {
      writer.add(audioInput)
    } else {
      print("Failed audio")
    }
    
    if (writer.canAdd(videoInput)) {
      writer.add(videoInput)
    } else {
      print("Failed video")
    }
    
    writer.startWriting()
    
    switch writer.status {
    case .writing:
      let sampleTime = buffer.presentationTimeStamp
      writer.startSession(atSourceTime: sampleTime)
      self.sampleTime = sampleTime
    default:
      break
    }
  }
}
