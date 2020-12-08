//
//  BroadcastPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/12/08.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BroadcastPage: UINavigationController {
  private let disposeBag = DisposeBag()
  private let nearbyVM = NearbyLocationsViewModel()
  private let recorderVM = LocationRecorderViewModel()
  
  init() {
    let vc = NearbyLocationsPage.create(viewModel: nearbyVM)
    
    super.init(rootViewController: vc)
    
    vc.navigationItem.title = "配信スポットを選択"
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, action: {
      vc.dismiss(animated: true, completion: nil)
    })
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "新規作成", style: .plain, action: { [weak self] in
      self?.pushRecorderPage()
    })
    
    nearbyVM.location.concat(recorderVM.location).subscribe({ [weak self] ev in
      guard let location = ev.element, let this = self else { return }
      print("Selected -> \(location.id)")
      this.pushCreateChannelPage()
    }).disposed(by: disposeBag)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func pushRecorderPage() {
    let vc = LocationRecorderPage.create(viewModel: recorderVM)
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.navigationItem.title = "配信スポットを記録"
    
    pushViewController(vc, animated: true)
  }
  
  private func pushCreateChannelPage() {
    let vc = CreateChannelPage.create()
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.navigationItem.title = "配信チャンネルを作成"
    vc.navigationItem.hidesBackButton = true
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, action: {
      vc.dismiss(animated: true, completion: nil)
    })
    
    pushViewController(vc, animated: true)
  }
}
