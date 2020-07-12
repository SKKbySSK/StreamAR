//
//  LoginScreen.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct LoginScreen: View {
  @EnvironmentObject var auth: Authorization
  @ObservedObject var viewModel: LoginViewModel
  
  var body: some View {
    VStack {
      VStack {
        TextField("メールアドレス", text: $viewModel.email)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
          .disabled(auth.status == .authorizing)
        Divider()
      }
      .frame(minWidth: nil, idealWidth: nil, maxWidth: 400, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
      .padding()
      VStack {
        SecureField("パスワード", text: $viewModel.password)
          .disabled(auth.status == .authorizing)
        Divider()
      }
      .frame(minWidth: nil, idealWidth: nil, maxWidth: 400, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
      .padding()
      HStack {
        Button(action: {
          self.viewModel.register()
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

struct LoginScreen_Previews: PreviewProvider {
  static var previews: some View {
    let auth = Authorization(client: DummyAuthClient(status: .notAuthorized))
    return Group {
      LoginScreen(viewModel: LoginViewModel(auth: auth))
    }.environmentObject(auth)
  }
}
