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
  private let flushQueue = DispatchQueue(label: "work.ksprogram.streamar.VideoFlushQueue")
  private(set) var isRecording = false
  
  private var audioInput: AVAssetWriterInput?
  private var videoInput: AVAssetWriterInput?
  private var sampleTime: CMTime?
  private var audioFormat: CMFormatDescription?
  
  private var writer: AVAssetWriter? = nil
  private var nextUrl: URL?
  private var url: URL?
  private var size: (width: Int, height: Int)?
  
  private(set) var durationSeconds: Double = 0
  private(set) var totalDurationSeconds: Double = 0
  private var sampleUpdated: ((BufferWriter) -> Void)?
  
  func record(width: Int, height: Int, url: URL, sampleUpdated: ((BufferWriter) -> Void)?) {
    flushQueue.async {
      guard !self.isRecording else { return }
      if FileManager.default.fileExists(atPath: url.path) {
        try! FileManager.default.removeItem(at: url)
      }
      
      self.resetAllProps()
      self.size = (width, height)
      self.url = url
      self.writer = try! AVAssetWriter(url: url, fileType: .mov)
      self.durationSeconds = 0
      self.sampleUpdated = sampleUpdated
      self.isRecording = true
    }
  }
  
  func stop(nextUrl: URL?, completion: @escaping (URL, (duration: Double, position: Double)) -> Void) {
    flushQueue.async {
      guard self.isRecording else { return }
      guard let audio = self.audioInput, let video = self.videoInput, let writer = self.writer, let url = self.url else {
        print("Invalid State")
        self.resetAllProps()
        return
      }
      let position = self.totalDurationSeconds
      let duration = self.durationSeconds
      self.totalDurationSeconds += duration
      self.nextUrl = nextUrl
      
      if nextUrl == nil {
        self.isRecording = false
      }
      
      audio.markAsFinished()
      video.markAsFinished()
      
      writer.finishWriting {
        completion(url, (duration, position))
      }
    }
  }
  
  func writeAudio(buffer: CMSampleBuffer) {
    flushQueue.async {
      if self.audioInput == nil {
        guard let format = self.audioFormat ?? buffer.formatDescription else { return }
        self.initAudioInput(format: format)
      }
      
      self.autoStart(buffer: buffer)
      if self.audioInput!.isReadyForMoreMediaData {
        self.audioInput!.append(buffer)
      }
    }
  }
  
  func writeVideo(buffer: CMSampleBuffer) {
    flushQueue.async {
      if self.videoInput == nil {
        self.initVideoInput()
      }
      
      self.autoStart(buffer: buffer)
      if self.videoInput!.isReadyForMoreMediaData {
        self.videoInput!.append(buffer)
        
        let currentTimeStamp = buffer.presentationTimeStamp
        let duration = currentTimeStamp - self.sampleTime!
        if duration.isValid {
          self.durationSeconds = duration.seconds
          self.sampleUpdated?(self)
        }
      }
    }
  }
  
  private func resetAllProps() {
    self.sampleUpdated = nil
    self.audioFormat = nil
    self.durationSeconds = 0
    self.totalDurationSeconds = 0
    self.sampleTime = nil
    self.audioInput = nil
    self.videoInput = nil
    self.writer = nil
    self.size = nil
    self.url = nil
    self.nextUrl = nil
  }
  
  private func initAudioInput(format: CMFormatDescription) {
    audioFormat = format
    audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
      AVFormatIDKey: kAudioFormatLinearPCM,
    ], sourceFormatHint: format)
    audioInput!.expectsMediaDataInRealTime = true
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
    if let nextUrl = nextUrl, let format = audioFormat {
      if FileManager.default.fileExists(atPath: nextUrl.path) {
        try! FileManager.default.removeItem(at: nextUrl)
      }
      
      self.url = nextUrl
      self.nextUrl = nil
      
      self.sampleTime = nil
      self.writer = try! AVAssetWriter(url: nextUrl, fileType: .mov)
      self.durationSeconds = 0
      initAudioInput(format: format)
      initVideoInput()
    }
    
    guard sampleTime == nil, let audioInput = audioInput, let videoInput = videoInput, let writer = writer else { return }
    
    if (writer.canAdd(audioInput)) {
      writer.add(audioInput)
    } else {
      print("Failed to append audio input to writer")
    }
    
    if (writer.canAdd(videoInput)) {
      writer.add(videoInput)
    } else {
      print("Failed to append video input to writer")
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
