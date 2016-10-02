//
//  AsyncStream+Network.swift
//  iAsync_network
//
//  Created by Gorbenko Vladimir on 05/02/16.
//  Copyright © 2016 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils
import struct iAsync_reactiveKit.AsyncStream
import func iAsync_reactiveKit.create
import func iAsync_reactiveKit.createStream

import enum ReactiveKit.Result
import protocol ReactiveKit.Disposable

public typealias NetworkStream = AsyncStream<NetworkResponse, NetworkProgress, ErrorWithContext>

public struct network {

    public static func chunkedDataStream(params: URLConnectionParams) -> AsyncStream<NSHTTPURLResponse, NetworkProgress, ErrorWithContext> {

        return createStream { NetworkAsyncStream(params: params, errorTransformer: networkErrorAnalyzer(params)) }
    }

    public static func dataStream(params: URLConnectionParams) -> NetworkStream {

        return AsyncStream { observer -> Disposable in

            let stream = chunkedDataStream(params)

            let responseData = NSMutableData()

            return stream.observe { event -> () in

                switch event {
                case .success(let value):
                    let result = NetworkResponse(params: params, response: value, responseData: responseData)
                    observer(.success(result))
                case .next(let chunk):
                    switch chunk {
                    case .Download(let info):
                        responseData.appendData(info.dataChunk)
                    case .Upload:
                        break
                    }
                    observer(.next(chunk))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
        }
    }

    public static func dataStream(url: NSURL, postData: NSData?, headers: URLConnectionParams.HeadersType?) -> NetworkStream {

        let params = URLConnectionParams(
            url                      : url,
            httpBody                 : postData,
            httpMethod               : nil,
            headers                  : headers,
            totalBytesExpectedToWrite: 0,
            httpBodyStreamBuilder    : nil,
            certificateCallback      : nil)

        return network.dataStream(params)
    }

    public static func http200DataStream(params: URLConnectionParams) -> NetworkStream {

        let stream = dataStream(params)

        return stream.tryMap { response -> Result<NetworkResponse, ErrorWithContext> in

            let result = downloadStatusCodeResponseAnalyzer(params)(response.response)
            switch result {
            case .failure(let error):
                return .failure(error)
            case .Success:
                return .success(response)
            }
        }
    }

    public static func http200DataStream(url: NSURL, postData: NSData?, headers: URLConnectionParams.HeadersType?) -> NetworkStream {

        let params = URLConnectionParams(
            url                      : url,
            httpBody                 : postData,
            httpMethod               : nil,
            headers                  : headers,
            totalBytesExpectedToWrite: 0,
            httpBodyStreamBuilder    : nil,
            certificateCallback      : nil)

        return network.http200DataStream(params)
    }

    private static func downloadStatusCodeResponseAnalyzer(context: URLConnectionParams) -> NSHTTPURLResponse -> Result<NSHTTPURLResponse, ErrorWithContext> {

        return { (response: NSHTTPURLResponse) -> Result<NSHTTPURLResponse, ErrorWithContext> in

            let statusCode = response.statusCode

            if HttpFlagChecker.isDownloadErrorFlag(statusCode) {
                let httpError = HttpError(httpCode: statusCode, context: context)
                let contextError = ErrorWithContext(error: httpError, context: #function)
                return .failure(contextError)
            }

            return .success(response)
        }
    }

    private static func networkErrorAnalyzer(context: URLConnectionParams) -> JNetworkErrorTransformer {

        return { error -> NSError in

            if let error = error as? NetworkError { return error }

            let resultError = NSNetworkError.createJNSNetworkErrorWithContext(context, nativeError: error)

            return resultError
        }
    }
}

public extension AsyncStream where Next == NetworkProgress {

    public func netMapNext() -> AsyncStream<Value, AnyObject, Error> {
        return mapNext { info -> AnyObject in
            switch info {
            case .Download(let chunk):
                return chunk
            case .Upload(let chunk):
                return chunk
            }
        }
    }
}
