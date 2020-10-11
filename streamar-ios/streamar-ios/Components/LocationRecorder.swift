//
//  LocationRecorder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/19.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI
import SceneKit
import Combine

struct LocationRecorder<Content>: View where Content: View {
  private var content: (Location) -> Content
  @ObservedObject var viewModel: LocationViewModel
  @State private var running: Bool = false
  @State private var name: String = ""
  @State private var transform: simd_float4x4? = nil
  @State private var cancellables: [AnyCancellable] = []
  private let controller = SpatialAnchorRecordingViewController(config: Config.azureSpatialAnchors)
  
  init(viewModel: LocationViewModel, @ViewBuilder content: @escaping (Location) -> Content) {
    self.viewModel = viewModel
    self.content = content
  }
  
  var body: some View {
    VStack {
      TextField("Location", text: $name)
      NavigationLink("OK", destination: RecordingScreen())
        .frame(width: 100, height: nil, alignment: .center)
    }.padding()
  }
  
  @ViewBuilder
  func RecordingScreen() -> some View {
    ZStack {
      SpatialAnchorRecordingView(isRunning: $running, controller: controller, onTap: { transform in
        self.transform = transform
      }).onAppear {
        running = true
      }.onDisappear {
        running = false
      }.ignoresSafeArea(.all, edges: .all)
      
      if self.transform != nil {
        VStack {
          Spacer()
          Button("OK") {
            self.controller.createCloudAnchor(at: self.transform!, name: self.name).sink(receiveValue: { location in
              guard let location = location else { return }
              self.viewModel.location = location
            }).store(in: &cancellables)
          }
        }.padding()
      }
      
      if viewModel.location != nil {
        NavigationLink(destination: self.content(viewModel.location!), isActive: Binding.constant(true)) {
          EmptyView()
        }
      }
    }
  }
}
