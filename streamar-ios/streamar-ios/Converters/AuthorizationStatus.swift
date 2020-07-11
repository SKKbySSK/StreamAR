//
//  AuthorizationStatus.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding where Value == AuthorizationStatus {
  func isAuthorizing() -> Binding<Bool> {
    return Binding<Bool>(get: { return self.wrappedValue == .authorizing }, set: { _ in })
  }
  
  func isAuthorized() -> Binding<Bool> {
    return Binding<Bool>(get: { return self.wrappedValue == .authorized }, set: { _ in })
  }
  
  func isNotAuthorized() -> Binding<Bool> {
    return Binding<Bool>(get: { return self.wrappedValue == .notAuthorized }, set: { _ in })
  }
}
