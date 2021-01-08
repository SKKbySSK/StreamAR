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
  private var location: Location!
  private var camera: CameraController!
  private var loading = false {
    didSet {
      createButton.isEnabled = !loading
      uploadButton.isEnabled = !loading
      
      if loading {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
      }
    }
  }
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var parentView: UIView!
  @IBOutlet weak var channelTitle: UITextField!
  @IBOutlet weak var createButton: LGButton!
  @IBOutlet weak var uploadButton: LGButton!
  
  static func create(location: Location, camera: CameraController) -> CreateChannelPage {
    let vc: CreateChannelPage = ViewHelper.createViewController()
    vc.location = location
    vc.camera = camera
    
    return vc
  }
  
  var channel: Observable<Channel> {
    return channelSubject.asObservable()
  }
  
  @IBAction func uploadVideo(_ sender: Any) {
    guard !loading else { return }
    let title = channelTitle.text ?? ""
    guard title.count > 0 else { return }
    
    loading = true
    let client = ChannelClient()
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
    guard !loading else { return }
    let title = channelTitle.text ?? ""
    guard title.count > 0, let res = camera.resolution else { return }
    
    loading = false
    let client = ChannelClient()
    client.createChannel(title: title, locationId: location.id, anchorId: location.anchorIds.first!, width: res.width, height: res.height).subscribe({ [weak self] ev in
      self?.loading = false
      guard let channel = ev.element else { return }
      self?.channelSubject.onNext(channel)
    }).disposed(by: disposeBag)
  }
}
