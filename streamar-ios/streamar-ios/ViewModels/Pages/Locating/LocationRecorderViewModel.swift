//
//  LocationRecorderViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/09.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ARKit

enum LocationRecorderState: Equatable {
  case none
  case initializing
  case localizing(progress: Float)
  case localized
  case placed
  case saving
  case saved
  case failed
}

class LocationRecorderViewModel: ToastViewModelBase, LocatingViewModel {
  private let locationRelay = PublishRelay<Location>()
  private let stateRelay = BehaviorRelay(value: LocationRecorderState.none)
  private let transformRelay = BehaviorRelay<simd_float4x4?>(value: nil)
  private let gpsRelay = BehaviorRelay<CLLocation?>(value: nil)
  
  var location: Observable<Location> {
    return locationRelay.asObservable()
  }
  
  var state: Observable<LocationRecorderState> {
    return stateRelay.asObservable()
  }
  
  var transform: Observable<simd_float4x4?> {
    return transformRelay.asObservable()
  }
  
  var currentTransform: simd_float4x4? {
    return transformRelay.value
  }
  
  var isLocalized: Bool {
    switch stateRelay.value {
    case .localized:
      fallthrough
    case .placed:
      fallthrough
    case .saving:
      fallthrough
    case .saved:
      return true
    default:
      return false
    }
  }
  
  func onInitializing() {
    guard stateRelay.value == .none else { return }
    stateRelay.accept(.initializing)
  }
  
  func onLocalizing(progress: Float) {
    switch stateRelay.value {
    case .none:
      fallthrough
    case .initializing:
      fallthrough
    case .localizing(progress: _):
      if progress >= 1 {
        stateRelay.accept(.localized)
      } else {
        stateRelay.accept(.localizing(progress: progress / 1))
      }
    default:
      return
    }
  }
  
  func setTransform(_ transform: simd_float4x4) -> Bool {
    guard stateRelay.value == .localized || stateRelay.value == .placed else { return false }
    transformRelay.accept(transform)
    stateRelay.accept(.placed)
    return true
  }
  
  func setLocation(_ location: CLLocation) {
    gpsRelay.accept(location)
  }
  
  func save(location name: String, anchorId: String, image: UIImage) -> Observable<Location?> {
    guard stateRelay.value == .placed else {
      return Observable.just(nil)
    }
    stateRelay.accept(.saving)
    
    print("Saving place named \(name)")
    
    return Observable.create { [weak self] observer in
      guard let this = self else {
        observer.onNext(nil)
        observer.onCompleted()
        return Disposables.create()
      }
      
      this.gpsRelay.filter({ $0 != nil }).take(1).subscribe({ ev in
        if let error = ev.error {
          print(error.localizedDescription)
          self?.onFailed(restore: .placed)
          observer.onNext(nil)
          observer.onCompleted()
          return
        }
        
        guard let locationOp = ev.element, let location = locationOp else {
          print("There is no location available")
          observer.onNext(nil)
          observer.onCompleted()
          return
        }
        print("Coordinate : \(location.coordinate)")
        
        CLGeocoder().reverseGeocodeLocation(location)  { placemarks, error in
          if let error = error {
            print(error.localizedDescription)
            self?.onFailed(restore: .placed)
            observer.onNext(nil)
            observer.onCompleted()
            return
          }
          
          guard let postalCode = placemarks?.first?.postalCode else {
            print("Failed to retrieve postal code")
            self?.onFailed(restore: .placed)
            observer.onNext(nil)
            observer.onCompleted()
            return
          }
          print("Postal code : \(postalCode)")
          
          LocationClient.shared.append(name: name,
                                       anchorId: anchorId,
                                       postalCode: postalCode,
                                       location: location.coordinate,
                                       thumbnail: image
          ).subscribe({ ev in
            guard let location = ev.element else {
              observer.onNext(nil)
              observer.onCompleted()
              return
            }
            this.locationRelay.accept(location)
            print("Location appended")
          }).disposed(by: this.disposeBag)
        }
        
      }).disposed(by: this.disposeBag)
      
      return Disposables.create()
    }
  }
  
  private func onFailed(restore state: LocationRecorderState?) {
    stateRelay.accept(.failed)
    
    guard let state = state else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
      self?.stateRelay.accept(state)
    }
  }
}
