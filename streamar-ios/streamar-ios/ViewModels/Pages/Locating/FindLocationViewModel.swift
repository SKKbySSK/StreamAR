//
//  FindLocationViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/02.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FindLocationViewModel: LocatingViewModel {
  private let client = LocationClient()
  private let locationRelay = PublishRelay<Location>()
  
  var location: Observable<Location> {
    return locationRelay.asObservable()
  }
  
  var results: Observable<[Location]> {
    query.compactMap({ $0 })
      .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
      .flatMap({ self.client.find(by: $0) })
      .asObservable()
  }
  
  let query = BehaviorRelay<String?>(value: "")
  
  func select(location: Location) {
    locationRelay.accept(location)
  }
}
