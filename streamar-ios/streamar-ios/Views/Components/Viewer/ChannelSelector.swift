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
  @IBOutlet weak var liveCollectionView: UICollectionView!
  @IBOutlet weak var vodCollectionView: UICollectionView!
  @IBOutlet weak var toggleButton: UIButton!
  private var viewModel: ChannelSelectorViewModel!
  private let disposeBag = DisposeBag()
  
  var isClosed: Bool = false {
    didSet {
      liveCollectionView.alpha = isClosed ? 0 : 1
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
    let cellId = liveCollectionView.registerCell(type: ChannelCell.self)
    _ = vodCollectionView.registerCell(type: ChannelCell.self)
    
    let liveDataSource = RxCollectionViewSectionedAnimatedDataSource<ChannelSection>(configureCell: { dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChannelCell
      cell.bind(channel: item)
      return cell
    })
    
    let vodDataSource = RxCollectionViewSectionedAnimatedDataSource<ChannelSection>(configureCell: { dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChannelCell
      cell.bind(channel: item)
      return cell
    })
    
    viewModel.liveChannels
      .map({ [ChannelSection(header: "チャンネル", items: $0)] })
      .bind(to: liveCollectionView.rx.items(dataSource: liveDataSource))
      .disposed(by: disposeBag)
    
    viewModel.vodChannels
      .map({ [ChannelSection(header: "チャンネル", items: $0)] })
      .bind(to: vodCollectionView.rx.items(dataSource: vodDataSource))
      .disposed(by: disposeBag)
    
    liveCollectionView.rx.itemSelected.subscribe({ [unowned self] ev in
      guard let indexPath = ev.element else { return }
      let channel = liveDataSource[indexPath]
      self.viewModel.select(channel: channel)
    }).disposed(by: disposeBag)
    
    vodCollectionView.rx.itemSelected.subscribe({ [unowned self] ev in
      guard let indexPath = ev.element else { return }
      let channel = vodDataSource[indexPath]
      self.viewModel.select(channel: channel)
    }).disposed(by: disposeBag)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.roundCorners(corners: [.topLeft, .topRight], radius: 10)
  }
}
