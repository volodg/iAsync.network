//
//  NSMutableURLRequest+CreateRequestWithURLParams.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import let iAsync_utils.iAsync_utils_logger

import enum ReactiveKit.Result

//todo NS
extension NSMutableURLRequest {

    convenience init(params: URLConnectionParams) {

        let inputStream: InputStream?
        if let factory = params.httpBodyStreamBuilder {

            let streamResult = factory()

            if let error = streamResult.error {
                iAsync_utils_logger.logError("create stream error: \(error)", context: #function)
            }

            inputStream = streamResult.value
        } else {
            inputStream = nil
        }

        assert(!((params.httpBody != nil) && (inputStream != nil)))

        self.init(
            url            : params.url,
            cachePolicy    : .reloadIgnoringLocalCacheData,
            timeoutInterval: 60.0)

        self.httpBodyStream = inputStream
        if params.httpBody != nil {
            self.httpBody = params.httpBody
        }

        self.allHTTPHeaderFields = params.headers
        self.httpMethod          = params.httpMethod.rawValue
    }
}
