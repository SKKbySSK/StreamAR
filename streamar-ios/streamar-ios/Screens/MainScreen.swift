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
  @ObservedObject var viewModel: MainViewModel
  
  var body: some View {
    VStack {
      VStack {
        TextField("メールアドレス", text: $viewModel.email)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
          .disabled(auth.status == .authorizing)
        Divider()
      }
      .padding()
      VStack {
        SecureField("パスワード", text: $viewModel.password)
          .disabled(auth.status == .authorizing)
        Divider()
      }
      .padding()
      HStack {
        Button(action: {
        }) {
          Text("新規登録")
        }
        .disabled(auth.status == .authorizing)
        .padding()
        Button(action: {
          self.viewModel.signIn()
        }) {
          Text("サインイン")
        }
        .disabled(auth.status == .authorizing)
        .padding()
      }
      Indicator(isAnimating: $auth.status.isAuthorizing(), style: .medium)
    }
  }
}

struct MainScreen_Previews: PreviewProvider {
  static var previews: some View {
    let auth = Authorization(client: DummyAuthClient(status: .notAuthorized))
    return Group {
      MainScreen(viewModel: MainViewModel(auth: auth))
    }.environmentObject(auth)
  }
}
