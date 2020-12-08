//
//  HomePageBuilder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class HomePageBuilder {
  static func build(auth: AuthViewModel) -> UIViewController {
    let vc = ViewerPageBuilder.build()
    let button = UIBarButtonItem(image: #imageLiteral(resourceName: "VideoCamera"), style: .done, action: {
      vc.present(BroadcastPageBuilder.build(), animated: true, completion: nil)
    })
    
    vc.navigationItem.rightBarButtonItem = button
    
    return vc
  }
}
