//
//  LocationScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/19.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

enum LocationScreenMode {
  case query
  case nearby
  case create
}

struct LocationScreen<Content>: View where Content: View {
  @ObservedObject private var viewModel: LocationViewModel
  
  private var content: (Location) -> Content
  @State private var location: Location? = nil
  @State private var mode: LocationScreenMode? = nil
  
  init(@ViewBuilder content: @escaping (Location) -> Content) {
    self.content = content
    viewModel = LocationViewModel()
  }
  
  var body: some View {
    Group {
      VStack(alignment: HorizontalAlignment.center, spacing: 40) {
        NavigationLink("Search", destination: screen(for: .query))
        NavigationLink("Nearby", destination: screen(for: .nearby))
        NavigationLink("Create", destination: screen(for: .create))
      }
    }
    .navigationTitle("Locations")
  }
  
  @ViewBuilder
  private func screen(for mode: LocationScreenMode) -> some View {
    switch mode {
    case .query:
      LocationQuery(viewModel: viewModel) { location in
        self.content(location)
      }.navigationTitle("Search")
    case .nearby:
      LocationFinder(viewModel: viewModel) { location in
        self.content(location)
      }.navigationTitle("Nearby")
    case .create:
      LocationRecorder(viewModel: viewModel) { location in
        self.content(location)
      }.navigationTitle("Create")
    }
  }
}
