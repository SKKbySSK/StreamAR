//
//  BroadcastClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/15.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import Combine

class BroadcastClient {
  static let shared = BroadcastClient()
  let db = Firestore.firestore()
  
  func location(for id: String) -> Observable<Location> {
    Observable.create({ observer in
      self.db.collection("/broadcast/v1/locations").document(id).getDocument(completion: { snapshot, error in
        guard let snapshot = snapshot else {
          observer.onCompleted()
          return
        }
        
        guard let document = try! snapshot.data(as: LocationDocument.self) else { return }
        observer.onNext(Location(id: snapshot.documentID, document: document))
        observer.onCompleted()
      })
      
      return Disposables.create()
    })
  }
  
  func location(latitude: Double, longitude: Double, range: Double) -> Observable<[Location]> {
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
  
  func locationCombine(latitude: Double, longitude: Double, range: Double) -> Future<[Location], Never> {
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    return Future<[Location], Never> { promise in
      CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
        guard let postalCode = placemarks?.first?.postalCode, error == nil else {
          promise(.success([]))
          return
        }
        
        self.db.collection("/broadcast/v1/locations")
          .whereField("zip", isEqualTo: postalCode)
          .limit(to: 10)
          .getDocuments(completion: { snapshot, error in
            guard let snapshot = snapshot else {
              promise(.success([]))
              return
            }
            
            let locations: [Location] = snapshot.documents.compactMap({ doc in
              guard let document = try! doc.data(as: LocationDocument.self) else { return nil }
              return Location(id: doc.documentID, document: document)
            })
            
            promise(.success(locations))
          })
      }
    }
  }
  
  func findCombine(query: String) -> Future<[Location], Never> {
    return Future<[Location], Never> { promise in
      self.db.collection("/broadcast/v1/locations")
        .order(by: "name")
        .start(at: [query])
        .end(at: ["\(query)\u{f8ff}"])
        .getDocuments(completion: { snapshot, error in
          guard let snapshot = snapshot else {
            promise(.success([]))
            return
          }
          
          let locations: [Location] = snapshot.documents.compactMap({ doc in
            guard let document = try! doc.data(as: LocationDocument.self) else { return nil }
            return Location(id: doc.documentID, document: document)
          })
          
          promise(.success(locations))
        })
    }
  }
  
  func appendLocation(location: LocationDocument) -> Future<Location?, Never> {
    let docRef = self.db.collection("/broadcast/v1/locations").document()
    return Future<Location?, Never> { promise in
      try! docRef.setData(from: location, encoder: Firestore.Encoder()) { error in
          if let error = error {
            print(error)
            promise(.success(nil))
            return
          }
          
          promise(.success(Location(id: docRef.documentID, document: location)))
        }
    }
  }
}
