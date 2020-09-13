//
//  AuthClientBase.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import Alamofire

class AuthClientBase {
  func request<Parameters: Encodable>(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) -> DataRequest {
    return AF.request(url, method: method, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers, interceptor: nil, requestModifier: nil)
  }
}
