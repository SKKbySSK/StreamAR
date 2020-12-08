//
//  ChannelCreatePage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/12/08.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import LGButton

class CreateChannelPage: BindablePage {
  private let channelSubject = PublishSubject<Channel>()
  @IBOutlet weak var parentView: UIView!
  @IBOutlet weak var channelTitle: UITextField!
  @IBOutlet weak var createButton: LGButton!
  
  static func create() -> CreateChannelPage {
    let vc: CreateChannelPage = ViewHelper.createViewController()
    return vc
  }
  
  var channel: Observable<Channel> {
    return channelSubject.asObservable()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    parentView.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor).isActive = true
    
    channelTitle.rx.text.subscribe({ [unowned self] ev in
      guard let title = ev.element else { return }
      let count = title?.count ?? 0
      self.createButton.isEnabled = (count > 0)
    }).disposed(by: disposeBag)
  }
  
  @IBAction func onTap(_ sender: Any) {
  }
}