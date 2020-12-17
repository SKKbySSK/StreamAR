//
//  CameraController.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/12/10.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum CameraType {
  case front
  case back
}

class CameraController: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
  private let captureSession = AVCaptureSession()
  private var captureDevice: (camera: AVCaptureDevice, mic: AVCaptureDevice)?
  private var outputs: (audio: AVCaptureAudioDataOutput, video: AVCaptureVideoDataOutput)?
  private let outputQueue = DispatchQueue(label: "work.ksprogram.streamar.CameraQueue")
  
  var writer: BufferWriter?
  
  private var previewLayer: AVCaptureVideoPreviewLayer!
  var layer: CALayer {
    return previewLayer
  }
  
  var resolution: (width: Int, height: Int)? {
    guard let camera = captureDevice?.camera else {
      return nil
    }
    
    let dimensions = CMVideoFormatDescriptionGetDimensions(camera.activeFormat.formatDescription)
    
    switch getSuitableOrientation() {
    case .portrait:
      fallthrough
    case .portraitUpsideDown:
      return (Int(dimensions.height), Int(dimensions.width))
    default:
      return (Int(dimensions.width), Int(dimensions.height))
    }
  }
  
  init(camera: CameraType) {
    super.init()
    
    prepareCamera(camera: camera)
    beginSession()
  }
  
  private func prepareCamera(camera: CameraType) {
    captureSession.sessionPreset = .hd1920x1080
    
    var position: AVCaptureDevice.Position
    switch camera {
    case .back:
      position = .back
    case .front:
      position = .front
    }
    
    guard let camera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first else {
      return
    }
    guard let mic = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first else {
      return
    }
    
    captureDevice = (camera, mic)
  }
  
  private func beginSession() {
    guard let device = captureDevice else {
      return
    }
    
    do {
      let cameraInput = try AVCaptureDeviceInput(device: device.camera)
      let micInput = try AVCaptureDeviceInput(device: device.mic)
      
      captureSession.addInput(cameraInput)
      captureSession.addInput(micInput)
    } catch {
      print(error.localizedDescription)
    }
    
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
    videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
    videoOutput.alwaysDiscardsLateVideoFrames = false
    
    let audioOutput = AVCaptureAudioDataOutput()
    audioOutput.setSampleBufferDelegate(self, queue: outputQueue)
    
    captureSession.addOutput(videoOutput)
    captureSession.addOutput(audioOutput)
    outputs = (audioOutput, videoOutput)
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = .resizeAspectFill
    updateOrientation()
  }
  
  func resumeSession() {
    guard !captureSession.isRunning else { return }
    captureSession.startRunning()
  }
  
  func endSession() {
    guard captureSession.isRunning else { return }
    captureSession.stopRunning()
  }
  
  func updateOrientation() {
    if let con = previewLayer.connection, con.isVideoOrientationSupported {
      con.videoOrientation = getSuitableOrientation()
    }
    
    changeVideoOrientation(getSuitableOrientation())
  }
  
  private func changeVideoOrientation(_ orientation: AVCaptureVideoOrientation) {
    guard writer?.isRecording ?? true else { return }
    guard let connection = self.outputs?.video.connection(with: .video) else {
      return
    }
    
    if (connection.isVideoOrientationSupported) {
      connection.videoOrientation = orientation
    }
  }
  
  private func getSuitableOrientation() -> AVCaptureVideoOrientation {
    let orientation: UIDeviceOrientation = UIDevice.current.orientation
    switch (orientation) {
    case .portrait:
      return .portrait
    case .landscapeRight:
      return .landscapeLeft
    case .landscapeLeft:
      return .landscapeRight
    case .portraitUpsideDown:
      return .portraitUpsideDown
    default:
      return .portrait
    }
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let writer = self.writer, let outputs = self.outputs, writer.isRecording else {
      return
    }
    
    if (output == outputs.audio) {
      writer.writeAudio(buffer: sampleBuffer)
    }
    
    if (output == outputs.video) {
      writer.writeVideo(buffer: sampleBuffer)
    }
  }
  
  func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
  }
}
