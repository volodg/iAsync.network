//
//  NSMutableURLRequest+CreateRequestWithURLParams.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    convenience init(params: URLConnectionParams) {
        
        let inputStream: NSInputStream?
        if let factory = params.httpBodyStreamBuilder {
            inputStream = factory()
        } else {
            inputStream = nil
        }
        
        assert(!((params.httpBody != nil) && (inputStream != nil)))
        
        self.init(
            URL: params.url,
            cachePolicy: .ReloadIgnoringLocalCacheData,
            timeoutInterval: 60.0)
        
        self.HTTPBodyStream = inputStream
        if params.httpBody != nil {
            self.HTTPBody = params.httpBody
        }
        
        self.allHTTPHeaderFields = params.headers
        self.HTTPMethod          = params.httpMethod.rawValue
    }
}
