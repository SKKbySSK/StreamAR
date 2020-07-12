//
//  RecordButton.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct RecordButton: View {
  @Binding var recording: Bool
  var onTap: () -> Void
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.black, lineWidth: 3)
        .frame(width: 60, height: 60, alignment: .center)
      Circle()
        .foregroundColor(.white)
        .frame(width: 60, height: 60, alignment: .center)
        .shadow(radius: 10)
      Rectangle()
        .cornerRadius(8)
        .foregroundColor(.red)
        .frame(width: 40, height: 40, alignment: .center)
      Circle()
        .foregroundColor(.red)
        .frame(width: 55, height: 55, alignment: .center)
        .scaleEffect(recording ? 0.4 : 1)
        .animation(.linear(duration: 0.3))
    }.onTapGesture(perform: {
      self.onTap()
    })
  }
}

struct RecordButton_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Rectangle().foregroundColor(.white).edgesIgnoringSafeArea(.all)
      RecordButton(recording: Binding.constant(true), onTap: {})
    }
  }
}
