//
//  UserScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/10.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct UserScreen: View {
  @EnvironmentObject var auth: Authorization
  
  var body: some View {
    Button(action: {
      self.auth.signOut()
    }) {
      Text("Sign Out")
    }
  }
}

struct UserScreen_Previews: PreviewProvider {
  static var previews: some View {
    UserScreen()
  }
}
