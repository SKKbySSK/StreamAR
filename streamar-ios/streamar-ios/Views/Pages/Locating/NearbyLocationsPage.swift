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
import RxSwift

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
  
  init(header: String, items: [Location]) {
    self.header = header
    self.items = items
  }
  
  typealias Item = Location
  
  var header: String
  var items: [Item]
}

class NearbyLocationsPage: BindablePage {
  @IBOutlet weak var collectionView: UICollectionView!
  private var viewModel: NearbyLocationsViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cellId = collectionView.registerCell(type: BroadcastCell.self)
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<LocationSection>(configureCell: { [unowned self] dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BroadcastCell
      cell.bind(location: item, userLocation: self.viewModel.userLocation)
      return cell
    })
    
    viewModel.locations
      .map({ [LocationSection(header: "近く", items: $0)] })
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.subscribe({ [unowned self] ev in
      guard let indexPath = ev.element else { return }
      let location = dataSource[indexPath]
      self.viewModel.select(location: location)
    }).disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.run()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.stop()
  }
  
  static func create(viewModel: NearbyLocationsViewModel) -> NearbyLocationsPage {
    let vc: NearbyLocationsPage = ViewHelper.createViewController()
    vc.viewModel = viewModel
    
    return vc
  }
}
