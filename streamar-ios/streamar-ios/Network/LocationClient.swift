//
//  LocationClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/15.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

class LocationClient {
  static let shared = LocationClient()
  let db = Firestore.firestore()
  let storage = Storage.storage()
  let disposeBag = DisposeBag()
  
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
  
  func append(name: String, anchorId: String, postalCode: String, location: CLLocationCoordinate2D, thumbnail: UIImage) -> Observable<Location> {
    Observable.create({ observer in
      let docRef = self.db.collection("/broadcast/v1/locations").document()
      LocationClient.shared.uploadImage(thumbnail, locationId: docRef.documentID).subscribe({ ev in
        guard let thumbUrl = ev.element else { return }
        let doc = LocationDocument(anchorIds: [anchorId], latitude: location.latitude, longitude: location.longitude, zip: postalCode, name: name, thumbnailUrl: thumbUrl)
        
        do {
          try docRef.setData(from: doc, encoder: Firestore.Encoder(), completion: { error in
            if let error = error {
              observer.onError(error)
              return
            }
          })
          
          observer.onNext(Location(id: docRef.documentID, document: doc))
          observer.onCompleted()
        } catch(let error) {
          observer.onError(error)
        }
      }).disposed(by: self.disposeBag)

      return Disposables.create()
    })
  }
  
  func uploadImage(_ image: UIImage, locationId: String) -> Observable<String> {
    Observable.create({ observer in
      let ref = self.storage.reference(withPath: "/images/locations/").child("\(locationId).jpg")
      let img = image.jpegData(compressionQuality: 0.95)!
      ref.putData(img, metadata: nil, completion: { metadata, error in
        if let error = error {
          observer.onError(error)
          return
        }
        
        ref.downloadURL(completion: { url, error in
          if let error = error {
            observer.onError(error)
            return
          }
          
          observer.onNext(url!.absoluteString)
          observer.onCompleted()
        })
      })
      
      return Disposables.create()
    })
  }
}
