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

    static func chunkedDataStream(params: URLConnectionParams) -> AsyncStream<NSHTTPURLResponse, NSData, NSError>! {

//        let factory = { () -> NetworkAsyncStream in
//            return NetworkAsyncStream(params: params, errorTransformer: networkErrorAnalyzer(params))
//        }

        //return streamBuilder<NetworkAsyncStream>.createStream(factory)
        return nil
    }

    static func dataStream() -> AsyncStream<NetworkResponse, Void, NSError>! {

        return nil
    }
}
