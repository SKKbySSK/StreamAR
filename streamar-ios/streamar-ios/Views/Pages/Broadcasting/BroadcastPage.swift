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
import MaterialComponents

class BroadcastPage: UINavigationController {
  private var disposeBag: DisposeBag! = DisposeBag()
  private let nearbyVM = NearbyLocationsViewModel()
  private let recorderVM = LocationRecorderViewModel()
  private let findVM = FindLocationViewModel()
  private let cameraController = CameraController(camera: .front)
  
  init() {
    let vc = NearbyLocationsPage.create(viewModel: nearbyVM)
    super.init(rootViewController: vc)
    configureRootViewController(vc)
    
    Observable.of(nearbyVM.location, findVM.location, recorderVM.location)
      .merge()
      .subscribe({ [weak self] ev in
      guard let location = ev.element, let this = self else { return }
      print("Selected -> \(location.id)")
      this.pushCreateChannelPage(location: location)
    }).disposed(by: disposeBag)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureRootViewController(_ vc: NearbyLocationsPage) {
    let fab = MDCFloatingButton(shape: .default)
    let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28))!
    fab.setImage(image.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
    fab.translatesAutoresizingMaskIntoConstraints = false
    
    fab.rx.tap.subscribe({ [unowned self] ev in
      self.pushRecorderPage()
    }).disposed(by: disposeBag)
    
    vc.view.addSubview(fab)
    
    let safeArea = vc.view.safeAreaLayoutGuide
    fab.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10).isActive = true
    fab.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10).isActive = true
    fab.heightAnchor.constraint(equalToConstant: 64).isActive = true
    fab.widthAnchor.constraint(equalToConstant: 64).isActive = true
    
    vc.navigationItem.title = "配信スポットを選択"
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, action: {
      vc.dismiss(animated: true, completion: nil)
    })
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, action: { [unowned self] in
      self.pushFindPage()
    })
  }
  
  private func pushFindPage() {
    let vc = FindLocationPage.create(viewModel: findVM)
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.navigationItem.title = "配信スポットを検索"
    
    pushViewController(vc, animated: true)
  }
  
  private func pushRecorderPage() {
    let vc = LocationRecorderPage.create(viewModel: recorderVM)
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.navigationItem.title = "配信スポットを記録"
    
    pushViewController(vc, animated: true)
  }
  
  private func pushCreateChannelPage(location: Location) {
    let vc = CreateChannelPage.create(location: location, camera: cameraController)
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.navigationItem.title = "配信チャンネルを作成"
    
    vc.channel.subscribe({ [weak self] ev in
      guard let channel = ev.element else { return }
      self?.pushCameraPage(channel: channel)
    }).disposed(by: disposeBag)
    
    pushViewController(vc, animated: true)
  }
  
  private func pushCameraPage(channel: Channel) {
    let channelClient = ChannelClient()
    let viewModel = CameraViewModel(channel: channel, controller: cameraController)
    let vc = CameraPage.create(viewModel: viewModel)
    
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.navigationItem.title = channel.title
    vc.navigationItem.hidesBackButton = true
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "終了", style: .plain, action: {
      channelClient.deleteChannel(channel: channel, completion: { _ in
        print("Deleted: \(channel)")
      })
      vc.dismiss(animated: true, completion: nil)
    })
    
    pushViewController(vc, animated: true)
  }
}
