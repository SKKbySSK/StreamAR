//
//  TopScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct TopScreen: View {
  @ObservedObject var viewModel = TopViewModel()
  
  var body: some View {
    NavigationView {
      TabView {
        RecordingScreen()
          .tabItem({
            Text("Broadcast")
          })
        Text("Viewer Screen")
          .tabItem({
            Text("View")
          })
        Text("User Screen")
          .tabItem({
            Text("User")
          })
      }
    }.navigationViewStyle(StackNavigationViewStyle())
  }
}

struct TopScreen_Previews: PreviewProvider {
    static var previews: some View {
        TopScreen()
    }
}
