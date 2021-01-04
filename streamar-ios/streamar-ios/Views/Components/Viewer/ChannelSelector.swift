//
//  ChannelSelector.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/04.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

enum SearchChannelSections {
  case channel
}

struct ChannelSection: AnimatableSectionModelType, IdentifiableType {
  typealias Identity = SearchChannelSections
  
  var identity: Identity {
    return .channel
  }
  
  init(original: ChannelSection, items: [Channel]) {
    self = original
    self.items = items
  }
  
  init(header: String, items: [Channel]) {
    self.header = header
    self.items = items
  }
  
  typealias Item = Channel
  
  var header: String
  var items: [Item]
}

class ChannelSelector: UIVisualEffectView {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toggleButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  private var viewModel: ChannelSelectorViewModel!
  private let disposeBag = DisposeBag()
  
  var isClosed: Bool = false {
    didSet {
      collectionView.alpha = isClosed ? 0 : 1
      if isClosed {
        toggleButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
      } else {
        toggleButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
      }
    }
  }
  
  static func create(viewModel: ChannelSelectorViewModel) -> ChannelSelector {
    let view: ChannelSelector = ViewHelper.createView()
    view.viewModel = viewModel
    view.onInitialized()
    
    return view
  }
  
  private func onInitialized() {
    let cellId = collectionView.registerCell(type: ChannelCell.self)
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<ChannelSection>(configureCell: { dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChannelCell
      cell.bind(channel: item)
      return cell
    })
    
    viewModel.channels
      .map({ [ChannelSection(header: "チャンネル", items: $0)] })
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.subscribe({ [unowned self] ev in
      guard let indexPath = ev.element else { return }
      let channel = dataSource[indexPath]
      self.viewModel.select(channel: channel)
    }).disposed(by: disposeBag)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.roundCorners(corners: [.topLeft, .topRight], radius: 10)
  }
}
