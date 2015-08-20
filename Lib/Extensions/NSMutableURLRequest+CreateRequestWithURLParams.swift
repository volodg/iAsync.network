//
//  NSMutableURLRequest+CreateRequestWithURLParams.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {

     convenience init(params: JURLConnectionParams) {
    
        let inputStream = params.httpBodyStreamBuilder?()
        
        assert(!((params.httpBody != nil) && (inputStream != nil)))
        
        self.init(
            URL: params.url,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 60.0)
        
        let httpMethod = { () -> String in
            
            if params.httpMethod == nil && (params.httpBody != nil || inputStream != nil) {
                return "POST"
            }
            return params.httpMethod ?? "GET"
        }()
        
        self.HTTPBodyStream = inputStream
        if let httpBody = params.httpBody {
            self.HTTPBody = httpBody
        }
        
        self.allHTTPHeaderFields = params.headers
        self.HTTPMethod          = httpMethod
    }
}
