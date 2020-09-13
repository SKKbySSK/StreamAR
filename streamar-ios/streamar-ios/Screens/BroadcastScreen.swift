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
    if viewModel.channel != nil {
      RecordingScreen(viewModel: RecordingViewModel(client: viewModel.channelClient, channel: viewModel.channel!))
    } else {
      VStack {
        VStack {
          TextField("タイトル", text: $viewModel.title)
          Divider()
        }
        .frame(minWidth: nil, idealWidth: nil, maxWidth: 400, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
        .padding()
        Button(action: {
          self.viewModel.createChannel(completion: { channel in
            print(channel.channelID)
          })
        }) {
          Text("作成")
        }
        .padding()
      }
    }
  }
}

struct BroadcastScreen_Previews: PreviewProvider {
  static var previews: some View {
    BroadcastScreen()
  }
}
