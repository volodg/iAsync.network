//
//  AsyncStream+Network.swift
//  iAsync_network
//
//  Created by Gorbenko Vladimir on 05/02/16.
//  Copyright (c) 2016 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_reactiveKit

import ReactiveKit

struct network {

    static func chunkedDataStream(params: URLConnectionParams) -> AsyncStream<NSHTTPURLResponse, NetworkProgress, NSError> {

        return createStream { NetworkAsyncStream(params: params, errorTransformer: networkErrorAnalyzer(params)) }
    }

    static func dataStream() -> AsyncStream<NetworkResponse, Void, NSError>! {

        return nil
    }
}
