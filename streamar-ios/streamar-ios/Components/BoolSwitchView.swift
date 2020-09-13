//
//  BoolSwitchView.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct BoolSwitchView<TrueContent, FalseContent>: View where TrueContent: View, FalseContent: View {
  @Binding var value: Bool
  var trueContent: () -> TrueContent
  var falseContent: () -> FalseContent
  
  init(value: Binding<Bool>, trueContent: @escaping () -> TrueContent, falseContent: @escaping () -> FalseContent) {
    self._value = value
    self.trueContent = trueContent
    self.falseContent = falseContent
  }
  
  @ViewBuilder
  var body: some View {
    if value {
      trueContent()
    } else {
      falseContent()
    }
  }
}

struct BoolSwitchView_Previews: PreviewProvider {
    static var previews: some View {
      BoolSwitchView(value: Binding.constant(false), trueContent: {
        Text("True")
      }, falseContent: {
        Text("False")
      })
    }
}
