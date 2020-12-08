//
//  ChannelCell.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import Nuke

class BroadcastCell: UICollectionViewCell {
  private var disposeBag: DisposeBag! = nil
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.fitChild(self)
    
    layer.cornerRadius = 10
    layer.masksToBounds = true
    
    titleLabel.text = ""
    descriptionLabel.text = ""
  }
  
  func bind(channel: Channel, channelLocation: Location, userLocation: Observable<CLLocation>) {
    disposeBag = DisposeBag()
    
    titleLabel.text = channel.title
    descriptionLabel.text = ""
    
    userLocation.subscribe({ e in
      guard let location = e.element else { return }
      let chanLoc = CLLocation(latitude: channelLocation.latitude, longitude: channelLocation.longitude)
      let distance = location.distance(from: chanLoc)
      self.descriptionLabel.text = "\(round(distance))m"
    }).disposed(by: disposeBag)
  }
  
  func bind(location: Location, userLocation: Observable<CLLocation>) {
    disposeBag = DisposeBag()
    
    titleLabel.text = location.name
    descriptionLabel.text = ""
    Nuke.loadImage(with: URL(string: location.thumbnailUrl)!, into: imageView)
    
    userLocation.subscribe({ e in
      guard let userLocation = e.element else { return }
      let chanLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
      let distance = userLocation.distance(from: chanLoc)
      self.descriptionLabel.text = "\(round(distance))m"
    }).disposed(by: disposeBag)
  }
  
  
}
