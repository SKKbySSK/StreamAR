//
//  TopScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI
import SwiftUIX

enum TopScreenTabs {
  case broadcast
  case viewer
  case user
}

struct TopScreen: View {
  @State var tab: TopScreenTabs = .broadcast
  @State private var runViewer = false
  
  @ObservedObject var viewModel = TopViewModel()
  
  var body: some View {
    NavigationView {
      TabView(selection: $tab) {
        tabs
          .onChange(of: tab, perform: { runViewer = ($0 == .viewer) })
      }
    }.navigationViewStyle(StackNavigationViewStyle())
  }
  
  @ViewBuilder
  var tabs: some View {
    BroadcastScreen()
      .tabItem {
        Text("Broadcast")
      }.tag(TopScreenTabs.broadcast)
    ViewerScreen(running: $runViewer)
      .tabItem{
        Text("View")
      }.tag(TopScreenTabs.viewer)
    UserScreen()
      .tabItem{
        Text("User")
      }.tag(TopScreenTabs.user)
  }
}

struct TopScreen_Previews: PreviewProvider {
    static var previews: some View {
        TopScreen()
    }
}
