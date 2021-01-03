//
//  FindLocationPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/02.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxDataSources
import KeyboardGuide

class FindLocationPage: BindablePage {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchFieldWrapView: UIView!
  @IBOutlet weak var searchField: SearchField!
  @IBOutlet weak var searchSpacingView: UIView!
  @IBOutlet weak var searchSpacing: NSLayoutConstraint!
  
  private var viewModel: FindLocationViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureObserver()
    
    searchField.rx.text.bind(to: viewModel.query).disposed(by: disposeBag)
    
    let cellId = collectionView.registerCell(type: BroadcastCell.self)
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<LocationSection>(configureCell: { dataSource, view, indexPath, item in
      let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BroadcastCell
      cell.bind(location: item)
      return cell
    })
    
    viewModel.results
      .map({ [LocationSection(header: "", items: $0)] })
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.subscribe({ [unowned self] ev in
      guard let indexPath = ev.element else { return }
      let location = dataSource[indexPath]
      self.viewModel.select(location: location)
    }).disposed(by: disposeBag)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateKeyboardSpacing()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    searchFieldWrapView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
  }
  
  private func updateKeyboardSpacing() {
    let space = max(view.safeAreaInsets.bottom, view.keyboardSafeArea.insets.bottom)
    print(space)
    searchSpacing.constant = space
    view.layoutIfNeeded()
  }
  
  static func create(viewModel: FindLocationViewModel) -> FindLocationPage {
    let vc: FindLocationPage = ViewHelper.createViewController()
    vc.viewModel = viewModel
    
    return vc
  }
  
  // MARK: - Notification

  func configureObserver() {
    let notification = NotificationCenter.default
    notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                             name: UIResponder.keyboardWillShowNotification, object: nil)
    notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                             name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  @objc func keyboardWillShow(_ notification: Notification?) {
    guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    UIView.animate(withDuration: duration) {
      self.updateKeyboardSpacing()
    }
  }

  @objc func keyboardWillHide(_ notification: Notification?) {
    guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
    UIView.animate(withDuration: duration) {
      self.updateKeyboardSpacing()
    }
  }
}

class SearchField: UITextField {
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
    layer.masksToBounds = true
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 15.0, dy: 0.0)
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 15.0, dy: 0.0)
  }
  
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 15.0, dy: 0.0)
  }
}
