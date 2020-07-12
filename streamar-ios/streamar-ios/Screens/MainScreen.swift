//
//  MainScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
  @EnvironmentObject var auth: Authorization
  
  var body: some View {
    BoolSwitchView(value: $auth.status.isAuthorized(), trueContent: {
      TopScreen()
    }, falseContent: {
      LoginScreen(viewModel: LoginViewModel(auth: self.auth))
    })
  }
}

struct MainScreen_Previews: PreviewProvider {
  static var previews: some View {
    let auth = Authorization(client: DummyAuthClient(status: .notAuthorized))
    return Group {
      MainScreen()
    }.environmentObject(auth)
  }
}
