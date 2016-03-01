//
//  NetworkUploadProgressCallback.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

final public class NetworkUploadProgressCallback : NSObject, UploadProgress {

    public let params  : URLConnectionParams
    public let progress: Double

    public var url: NSURL {
        return params.url
    }

    public var headers: URLConnectionParams.HeadersType? {
        return params.headers
    }

    public init(params: URLConnectionParams, progress: Double) {

        self.params   = params
        self.progress = progress
    }
}
