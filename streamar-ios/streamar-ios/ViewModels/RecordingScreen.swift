//
//  BroadcastScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct RecordingScreen: View {
  var previewMode: Bool = false
  @ObservedObject private var viewModel = RecordingViewModel()
  @State private var camera = CameraController(camera: .front)
  
  var body: some View {
    ZStack {
      if previewMode {
        Rectangle()
          .foregroundColor(.black)
          .edgesIgnoringSafeArea(.all)
      } else {
        CameraView(controller: camera)
          .edgesIgnoringSafeArea(.all)
      }
      VStack {
        Spacer()
        RecordButton(recording: $viewModel.isRecording, onTap: {
          self.viewModel.toggleRecording(controller: self.camera)
        })
      }.padding(.bottom)
    }
  }
}

struct BroadcastScreen_Previews: PreviewProvider {
  static var previews: some View {
      RecordingScreen(previewMode: true)
  }
}
