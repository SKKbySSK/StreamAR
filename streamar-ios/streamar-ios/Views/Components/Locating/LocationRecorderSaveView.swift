//
//  LocationRecorderSaveView.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/13.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import LGButton

class LocationRecorderSaveView: UIView {
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var saveButton: LGButton!
  private let saveRelay = PublishRelay<String>()
  
  var save: Observable<String> {
    return saveRelay.asObservable()
  }
  
  var enabled: Binder<Bool> {
    Binder(self, binding: { (view, value) in
      view.nameField.isEnabled = value
      view.saveButton.isEnabled = value
    })
  }
  
  static func create() -> LocationRecorderSaveView {
    let view: LocationRecorderSaveView = ViewHelper.createView()
    return view
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    layer.cornerRadius = 10
    clipsToBounds = true
  }
  
  @IBAction func onTapSave(_ sender: Any) {
    guard let name = nameField.text, name.count > 0 else { return }
    saveRelay.accept(name)
  }
}
