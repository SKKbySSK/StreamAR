//
//  ViewerPageBuilder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/27.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class ViewerPageBuilder {
  static func build() -> UIViewController {
    let vm = NearbyLocationsViewModel()
    let vc = NearbyLocationsPage.create(viewModel: vm)
    
    vm.location.subscribe({ [weak vc] ev in
      guard let vc = vc, let location = ev.element else { return }
      vc.navigationController?.pushViewController(ViewerPage.create(location: location), animated: true)
    }).disposed(by: vm.disposeBag)
    
    vc.navigationItem.largeTitleDisplayMode = .always
    vc.navigationItem.title = "近くで配信中"
    vc.navigationItem.hidesBackButton = true
    
    return vc
  }
}
