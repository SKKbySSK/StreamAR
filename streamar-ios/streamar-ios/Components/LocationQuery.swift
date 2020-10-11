//
//  LocationQuery.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/19.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI
import SwiftUIX

struct LocationQuery<Content>: View where Content: View {
  @Environment(\.presenter) var presenter
  private var content: (Location) -> Content
  @ObservedObject var viewModel: LocationViewModel
  
  init(viewModel: LocationViewModel, @ViewBuilder content: @escaping (Location) -> Content) {
    self.viewModel = viewModel
    self.content = content
  }
  
  var body: some View {
    VStack {
      TextField("Search", text: $viewModel.query).padding()
      List(viewModel.queryLocations) { location in
        NavigationLink(destination: self.content(location), isActive: navigationBinding(location: location)) {
          Text(location.name)
        }.onTapGesture {
          viewModel.location = location
        }
      }
      Indicator(isAnimating: $viewModel.querying, style: .medium)
    }
  }
  
  func navigationBinding(location: Location) -> Binding<Bool> {
    Binding(
      get: { self.viewModel.location == location },
      set: { active in
        if active {
          self.viewModel.location = location
        } else {
          self.viewModel.location = nil
        }
      }
    )
  }
}
