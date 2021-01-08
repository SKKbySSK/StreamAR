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

class CameraController: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
  private let captureSession = AVCaptureSession()
  private var captureDevice: (camera: AVCaptureDevice, mic: AVCaptureDevice)?
  private var outputs: (audio: AVCaptureAudioDataOutput, video: AVCaptureVideoDataOutput)?
  private let outputQueue = DispatchQueue(label: "work.ksprogram.streamar.CameraQueue")
  
  var writer: BufferWriter?
  
  private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = .resizeAspectFill
    return previewLayer
  }()
  
  var layer: CALayer {
    return previewLayer
  }
  
  var resolution: (width: Int, height: Int)? {
    guard let camera = captureDevice?.camera else {
      return nil
    }
    
    let format = camera.activeFormat.formatDescription
    let dimensions = CMVideoFormatDescriptionGetPresentationDimensions(format, usePixelAspectRatio: true, useCleanAperture: true)
    
    switch getSuitableOrientation() {
    case .portrait:
      fallthrough
    case .portraitUpsideDown:
      return (Int(dimensions.height), Int(dimensions.width))
    default:
      return (Int(dimensions.width), Int(dimensions.height))
    }
  }
  
  override init() {
    super.init()
    
    prepareCamera()
    beginSession()
  }
  
  private func prepareCamera() {
    captureSession.sessionPreset = .hd1920x1080
    
    guard let camera = getDefaultCamera() else { return }
    guard let mic = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified) else { return }
    
    captureDevice = (camera, mic)
  }
  
  private func getDefaultCamera() -> AVCaptureDevice? {
    if let camera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .front) {
      return camera
    } else if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
      return camera
    } else if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
      return camera
    } else {
      return nil
    }
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
  }
  
  func startSession() {
    guard !captureSession.isRunning else { return }
    updateOutputOrientation()
    updatePreviewOrientation()
    captureSession.startRunning()
  }
  
  func endSession() {
    guard captureSession.isRunning else { return }
    captureSession.stopRunning()
  }
  
  private func updateOutputOrientation() {
    guard let videoConnection = self.outputs?.video.connection(with: .video) else { return }
    videoConnection.videoOrientation = getSuitableOrientation()
  }
  
  func updatePreviewOrientation() {
    guard let previewConnection = previewLayer.connection else { return }
    previewConnection.videoOrientation = getSuitableOrientation()
  }
  
  private func getSuitableOrientation() -> AVCaptureVideoOrientation {
    let orientation = UIApplication.shared.firstKeyWindow!.windowScene!.interfaceOrientation
    switch (orientation) {
    case .portrait:
      return .portrait
    case .landscapeRight:
      return .landscapeRight
    case .landscapeLeft:
      return .landscapeLeft
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
