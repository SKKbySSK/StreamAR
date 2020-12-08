//
//  LocatingViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift

protocol LocatingViewModel {
  var location: Observable<Location> { get }
}
