//
//  NearbyLocationsPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources

enum SearchChannelSections {
  case location
}

struct LocationSection: AnimatableSectionModelType, IdentifiableType {
  typealias Identity = SearchChannelSections
  
  var identity: Identity {
    return .location
  }
  
  init(original: LocationSection, items: [Location]) {
    self = original
    self.items = items
  }
  
  typealias Item = Location
  
  var header: String
  var items: [Item]
}

class NearbyLocationsPage: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cellId = broadcastCellId = collectionView.registerCell(type: BroadcastCell.self)
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<LocationSection>(configureCell: { dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BroadcastCell
      cell.bind(location: item, userLocation: Observable.just())
      return cell
    })
  }
  
  static func create() -> NearbyLocationsPage {
    return ViewHelper.createViewController()
  }
}
