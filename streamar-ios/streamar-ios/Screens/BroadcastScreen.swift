//
//  BroadcastScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/17.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct BroadcastScreen: View {
  @ObservedObject private var viewModel = BroadcastViewModel()
  
  @ViewBuilder
  var body: some View {
    LocationScreen() { location in
      ChannelScreen(location: location)
    }
  }
  
  @ViewBuilder
  func ChannelScreen(location: Location) -> some View {
    VStack {
      NavigationLink(destination: broadcast,
                     isActive: $viewModel.channel.isNotNil(),
                     label: { Text("aaaa") })
      VStack {
        TextField("タイトル", text: $viewModel.title)
        Divider()
      }
      .frame(minWidth: nil, idealWidth: nil, maxWidth: 400, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
      .padding()
      Button(action: {
        self.viewModel.createChannel(location: location, completion: { channel in
          print(channel.channelID)
        })
      }) {
        Text("作成")
      }
      .padding()
    }
  }
  
  @ViewBuilder
  var broadcast: some View {
    RecordingScreen(viewModel: RecordingViewModel(client: viewModel.channelClient, channel: viewModel.channel))
  }
}
