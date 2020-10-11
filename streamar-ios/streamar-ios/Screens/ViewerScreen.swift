//
//  ViewerScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/13.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI
import RxSwift

struct ViewerScreen: View {
  @Binding private var running: Bool
  @State private var status = "Localizing..."
  @State private var readyToLocalize = false
  private let disposeBag = DisposeBag()
  private let controller = SpatialAnchorLocalizingController()
  
  init(running: Binding<Bool>) {
    self._running = running
  }
  
  var body: some View {
    ZStack {
      SpatialAnchorLocalizingView(isRunning: $running, readyToLocalize: $readyToLocalize, config: Config.azureSpatialAnchors, controller: controller)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
        VStack {
          Spacer().frame(maxHeight: 10)
          Button(action: { self.controller.localizeNeaby().subscribe({ event in
            self.status = (event.element ?? false) ? "Localized!" : "Failed"
          }).disposed(by: self.disposeBag) }) {
            Text("Localize")
          }.disabled(!readyToLocalize)
          Spacer().frame(maxHeight: 10)
          Text(statusText)
          Spacer().frame(maxHeight: 10)
        }
        .frame(minWidth: 200)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(20)
        .padding(20)
      }
    }
    .navigationBarHidden(true)
  }
  
  private var statusText: String {
    if (readyToLocalize) {
      return "Ready"
    }
    
    return status
  }
}
