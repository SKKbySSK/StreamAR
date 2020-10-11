//
//  Binding+Extension.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/19.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
  func invert() -> Binding<Bool> {
    return Binding(get: { return !self.wrappedValue }, set: { val in self.wrappedValue = !val })
  }
}
