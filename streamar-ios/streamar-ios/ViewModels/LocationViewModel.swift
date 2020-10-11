//
//  LocationViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/19.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var cancellables: [AnyCancellable] = []
  @Published var location: Location? = nil
  
  @Published var querying: Bool = false
  @Published var query: String = ""
  @Published var queryLocations: [Location] = []
  
  @Published var updatingLocation: Bool = false
  @Published var currentLocation: CLLocation? = nil
  @Published var nearbyLocations: [Location] = []
  
  override init() {
    super.init()
    
    locationManager.delegate = self
    locationManager.distanceFilter = 20
    
    $query.debounce(for: .seconds(1), scheduler: ImmediateScheduler.shared)
      .flatMap({ [weak self] q -> Future<[Location], Never> in
        self?.querying = true
        return BroadcastClient.shared.findCombine(query: q)
      })
      .sink(receiveValue: { [weak self] loc in
        guard let this = self else { return }
        this.queryLocations = loc
        this.querying = false
      }).store(in: &cancellables)
  }
  
  func startUpdatingNearbyLocations() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func stopUpdatingNearbyLocations() {
    locationManager.stopUpdatingLocation()
    updatingLocation = false
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    
    BroadcastClient.shared
      .locationCombine(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, range: 0.03)
      .assign(to: &$nearbyLocations)
    
    currentLocation = location
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard manager.authorizationStatus == .authorizedWhenInUse else {
      stopUpdatingNearbyLocations()
      return
    }
    
    updatingLocation = true
    locationManager.startUpdatingLocation()
    
    Deferred { Just(Date()) }
      .append(Timer.publish(every: 10, on: .main, in: .common).autoconnect())
      .map({ (_: Date) in
        self.currentLocation?.coordinate
      })
      .compactMap({ $0 })
      .flatMap({ loc in
        BroadcastClient.shared.locationCombine(latitude: loc.latitude, longitude: loc.longitude, range: 0.03)
      })
      .sink(receiveValue: { [weak self] locations in
        self?.nearbyLocations = locations
      })
      .store(in: &cancellables)
  }
  
  deinit {
    cancellables.removeAll()
  }
}
