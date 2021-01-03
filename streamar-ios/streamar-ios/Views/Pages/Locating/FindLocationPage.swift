//
//  FindLocationPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/02.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxDataSources
import KeyboardGuide

class FindLocationPage: BindablePage {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  private var viewModel: FindLocationViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.rx.text.bind(to: viewModel.query).disposed(by: disposeBag)
    searchBar.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor).isActive = true
    
    let cellId = collectionView.registerCell(type: BroadcastCell.self)
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<LocationSection>(configureCell: { dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BroadcastCell
      cell.bind(location: item)
      return cell
    })
    
    viewModel.results
      .map({ [LocationSection(header: "", items: $0)] })
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.subscribe({ [unowned self] ev in
      guard let indexPath = ev.element else { return }
      let location = dataSource[indexPath]
      self.viewModel.select(location: location)
    }).disposed(by: disposeBag)
  }
  
  static func create(viewModel: FindLocationViewModel) -> FindLocationPage {
    let vc: FindLocationPage = ViewHelper.createViewController()
    vc.viewModel = viewModel
    
    return vc
  }
}
