//
//  LocationFinder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/16.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct LocationFinder<Content>: View where Content: View {
  private let content: (Location) -> Content
  @State private var pushContent = false
  @ObservedObject var viewModel: LocationViewModel
  
  init(viewModel: LocationViewModel, @ViewBuilder content: @escaping (Location) -> Content) {
    self.viewModel = viewModel
    self.content = content
  }
  
  var body: some View {
    VStack {
      List(viewModel.nearbyLocations) { location in
        Text(location.name)
          .onTapGesture {
            self.viewModel.location = location
          }
      }.onAppear(perform: {
        self.viewModel.startUpdatingNearbyLocations()
      }).onDisappear(perform: {
        self.viewModel.stopUpdatingNearbyLocations()
      })
      Indicator(isAnimating: $viewModel.updatingLocation, style: .medium)
      
      if viewModel.location != nil {
        NavigationLink(destination: self.content(viewModel.location!), isActive: $viewModel.location.isNil().invert()) {
          EmptyView()
        }
      }
    }
  }
}
