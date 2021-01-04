//
//  ChannelCell.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/04.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import Nuke
import RxSwift

class ChannelCell: UICollectionViewCell {
  private let disposeBag = DisposeBag()
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var userName: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.layer.masksToBounds = false
    contentView.layer.cornerRadius = 10
    contentView.clipsToBounds = true
    
    avatar.layer.masksToBounds = false
    avatar.layer.cornerRadius = avatar.bounds.width / 2
    avatar.clipsToBounds = true
  }
  
  func bind(channel: Channel) {
    label.text = channel.title
    avatar.image = nil
    userName.text = nil
    
    UserInfoClient.shared.getUserInfo(id: channel.user).subscribe({ [weak self] ev in
      guard let info = ev.element, let this = self else { return }
      
      if let thumbnail = info.thumbnail, thumbnail.count > 0 {
        let url = URL(string: thumbnail)!
        Nuke.loadImage(with: url, into: this.avatar)
      }
      
      this.userName.text = info.name
    }).disposed(by: disposeBag)
  }
}
