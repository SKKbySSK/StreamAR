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
  @IBOutlet weak var imageIndicatorView: UIActivityIndicatorView!
  @IBOutlet weak var labelBgView: UIView!
  @IBOutlet weak var labelStackView: UIStackView!
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
  
  func bind(location: Location) {
    disposeBag = DisposeBag()
    
    labelBgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    labelStackView.removeArrangedSubview(descriptionLabel)
    titleLabel.text = location.name
    Nuke.loadImage(with: URL(string: location.thumbnailUrl)!, options: .shared, into: imageView, progress: nil, completion: { [weak self] result in
      self?.imageIndicatorView.stopAnimating()
    })
  }
  
  func bind(location: Location, userLocation: Observable<CLLocation>) {
    disposeBag = DisposeBag()
    
    titleLabel.text = location.name
    descriptionLabel.text = ""
    Nuke.loadImage(with: URL(string: location.thumbnailUrl)!, options: .shared, into: imageView, progress: nil, completion: { [weak self] result in
      self?.imageIndicatorView.stopAnimating()
    })
    
    userLocation.subscribe({ [weak self] e in
      guard let userLocation = e.element else { return }
      let chanLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
      let distance = userLocation.distance(from: chanLoc)
      self?.descriptionLabel.text = "\(round(distance))m"
    }).disposed(by: disposeBag)
  }
}
