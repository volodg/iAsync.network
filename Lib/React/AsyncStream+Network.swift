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

public struct network {

    public static func chunkedDataStream(params: URLConnectionParams) -> AsyncStream<NSHTTPURLResponse, NetworkProgress, NSError> {

        return createStream { NetworkAsyncStream(params: params, errorTransformer: networkErrorAnalyzer(params)) }
    }

    public static func dataStream(params: URLConnectionParams) -> AsyncStream<NetworkResponse, Void, NSError>! {

        return create(producer: { observer -> DisposableType? in

            let stream = chunkedDataStream(params)

            let responseData = NSMutableData()

            return stream.observe(observer: { event -> () in

                switch event {
                case .Success(let value):
                    let result = NetworkResponse(params: params, response: value, responseData: responseData)
                    observer(.Success(result))
                case .Next(let chunk):
                    switch chunk {
                    case .Download(let info):
                        responseData.appendData(info.dataChunk)
                    case .Upload:
                        break
                    }
                case .Failure(let error):
                    observer(.Failure(error))
                }
            })
        })
    }
}
