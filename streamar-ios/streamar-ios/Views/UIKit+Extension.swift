//
//  UIKit+Extension.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class ViewHelper {
  static func createView<T: UIView>() -> T {
    let className = String(describing: T.self)
    let views = UINib(nibName: className, bundle: nil).instantiate(withOwner: nil, options: nil)
    return views.first as! T
  }
  
  static func createViewController<T: UIViewController>() -> T {
    let className = String(describing: T.self)
    let storyboard = UIStoryboard(name: className, bundle: Bundle(for: T.self))
    return storyboard.instantiateInitialViewController() as! T
  }
}

extension UIView {
  func addFittedChild(_ child: UIView) {
    addSubview(child)
    child.translatesAutoresizingMaskIntoConstraints = false
    child.topAnchor.constraint(equalTo: topAnchor).isActive = true
    child.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    child.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    child.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
}
