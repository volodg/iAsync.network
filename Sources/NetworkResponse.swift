//
//  NetworkResponse.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

public struct NetworkResponse : CustomStringConvertible {

    public let params      : URLConnectionParams
    public let response    : HTTPURLResponse
    public var responseData: Data

    public var description: String {

        let responseStr: String
        if let response = responseData.toString() {
            responseStr = response
        } else {
            responseStr = "(???)"
        }

        return "<NetworkResponse: params:\(params) response.allHeaderFields:\(response.allHeaderFields) response.statusCode:\(response.statusCode) responseData:\(responseStr)>"
    }

    public init(params: URLConnectionParams, response: HTTPURLResponse, responseData: Data) {

        self.params       = params
        self.response     = response
        self.responseData = responseData
    }
}
