//
//  AuthorizationProvider.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import SwiftUI

struct AuthorizationProvider<Content: View>: View {
  let auth: Authorization
  let content: (Authorization) -> Content
  
  init(auth: Authorization, @ViewBuilder content: @escaping (Authorization) -> Content) {
    self.auth = auth
    self.content = content
  }

  var body: some View {
    self.content(auth)
  }
}

struct AuthorizationProvider_Previews: PreviewProvider {
    static var previews: some View {
      let auth = Authorization(client: DummyAuthClient(status: .authorized))
      
      return AuthorizationProvider(auth: auth, content: { _ in
        Text("Authorization Provider")
      })
    }
}
