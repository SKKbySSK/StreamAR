//
//  SwitchView.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct SwitchView<Content>: View where Content : View {
  @Binding var index: Int
  var contents: () -> [Content]
  
  var body: some View {
    contents()[index]
  }
}

struct SwitchView_Previews: PreviewProvider {
  static var previews: some View {
    SwitchView(index: Binding.constant(0)) {
      [
        Text("View #0"),
        Text("View #1")
      ]
    }
  }
}
