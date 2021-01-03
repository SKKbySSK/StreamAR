//
//  UIKit+Extension.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import KeyboardGuide

class ViewHelper {
  static func createView<T: UIView>() -> T {
    let className = String(describing: T.self)
    let views = UINib(nibName: className, bundle: nil).instantiate(withOwner: nil, options: nil)
    return views.first as! T
  }
  
  static func createViewController<T: UIViewController>(_ storyboard: String? = nil) -> T {
    let storyboard = UIStoryboard(name: storyboard ?? String(describing: T.self), bundle: nil)
    return storyboard.instantiateInitialViewController() as! T
  }
}

extension UICollectionView {
  func registerCell<T: UICollectionViewCell>(type: T.Type) -> String {
    let className = String(describing: T.self)
    register(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: className)
    return className
  }
}

extension UIViewController {
  func addViewController(_ child: UIViewController) {
    addChild(child)
    child.view.frame = view.bounds
    view.addFittedChild(child.view)
    
    child.didMove(toParent: self)
  }
  
  func removeViewController(_ child: UIViewController) {
    child.willMove(toParent: nil)
    child.view.removeFromSuperview()
    child.removeFromParent()
  }
}

extension UIView {
  func addFittedChild(_ child: UIView, keyboard: Bool = false) {
    addSubview(child)
    fitChild(child, keyboard: keyboard)
  }
  
  func fitChild(_ child: UIView, keyboard: Bool = false) {
    child.translatesAutoresizingMaskIntoConstraints = false
    child.topAnchor.constraint(equalTo: topAnchor).isActive = true
    child.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    child.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    
    if (keyboard) {
      child.bottomAnchor.constraint(equalTo: keyboardSafeArea.layoutGuide.bottomAnchor).isActive = true
    } else {
      child.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
  }
  
  func addCenteredChild(_ child: UIView) {
    addSubview(child)
    child.translatesAutoresizingMaskIntoConstraints = false
    child.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    child.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }
  
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}

private var actionKey: Void?
extension UIBarButtonItem {
  private var _action: () -> () {
    get {
      return objc_getAssociatedObject(self, &actionKey) as! () -> ()
    }
    set {
      objc_setAssociatedObject(self, &actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  convenience init(image: UIImage?, style: UIBarButtonItem.Style, action: @escaping () -> ()) {
    self.init(image: image, style: style, target: nil, action: nil)
    self.target = self
    self.action = #selector(pressed)
    self._action = action
  }
  
  convenience init(title: String?, style: Style, action: @escaping () -> ()) {
    self.init(title: title, style: style, target: nil, action: nil)
    self.target = self
    self.action = #selector(pressed)
    self._action = action
  }
  
  @objc private func pressed(sender: UIBarButtonItem) {
    _action()
  }
}
