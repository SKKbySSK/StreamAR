//
//  NearbyLocationsViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import CoreLocation
import RxCoreLocation
import RxSwift
import RxCocoa
import FirebaseFirestore

class NearbyLocationsViewModel: ViewModelBase, LocatingViewModel {
  private let db = Firestore.firestore()
  private let manager = CLLocationManager()
  private let locationRelay = PublishRelay<Location>()
  
  var userLocation: Observable<CLLocation> {
    return manager.rx.location
      .compactMap({ $0 })
  }
  
  var locations: Observable<[Location]> {
    return userLocation
      .flatMap({ self.findNearby(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude, range: 0.01) })
  }
  
  var location: Observable<Location> {
    return locationRelay.asObservable()
  }
  
  private func findNearby(latitude: Double, longitude: Double, range: Double) -> Observable<[Location]> {
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    return Observable.create({ observer in
      CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
        guard let postalCode = placemarks?.first?.postalCode, error == nil else {
          observer.onCompleted()
          return
        }
        
        self.db.collection("/broadcast/v1/locations")
          .whereField("zip", isEqualTo: postalCode)
          .limit(to: 10)
          .getDocuments(completion: { snapshot, error in
            guard let snapshot = snapshot else {
              observer.onCompleted()
              return
            }
            
            let locations: [Location] = snapshot.documents.compactMap({ doc in
              guard let document = try! doc.data(as: LocationDocument.self) else { return nil }
              return Location(id: doc.documentID, document: document)
            })
            
            observer.onNext(locations)
            observer.onCompleted()
          })
      }
      
      return Disposables.create()
    })
  }
  
  func run() {
    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()
  }
  
  func stop() {
    manager.stopUpdatingLocation()
  }
  
  func select(location: Location) {
    locationRelay.accept(location)
  }
}
