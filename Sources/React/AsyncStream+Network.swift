//
//  AsyncStream+Network.swift
//  iAsync_network
//
//  Created by Gorbenko Vladimir on 05/02/16.
//  Copyright © 2016 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils
import iAsync_reactiveKit

import enum ReactiveKit.Result
import protocol ReactiveKit.Disposable

public typealias NetworkStream = AsyncStream<NetworkResponse, NetworkProgress, ErrorWithContext>

public struct network {

    public static func chunkedDataStreamWith(params: URLConnectionParams) -> AsyncStream<HTTPURLResponse, NetworkProgress, ErrorWithContext> {

        return createStreamWith { NetworkAsyncStream(params: params, errorTransformer: networkErrorAnalyzerWith(context: params)) }
    }

    public static func dataStreamWith(params: URLConnectionParams) -> NetworkStream {

        return AsyncStream { observer -> Disposable in

            let stream = chunkedDataStreamWith(params: params)

            var responseData = Data()

            return stream.observe { event -> () in

                switch event {
                case .success(let value):
                    let result = NetworkResponse(params: params, response: value, responseData: responseData)
                    observer(.success(result))
                case .next(let chunk):
                    switch chunk {
                    case .download(let info):
                        responseData.append(info.dataChunk)
                    case .upload:
                        break
                    }
                    observer(.next(chunk))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
        }
    }

    public static func dataStreamWith(url: URL, postData: Data? = nil, headers: URLConnectionParams.HeadersType? = nil) -> NetworkStream {

        let params = URLConnectionParams(
            url                      : url,
            httpBody                 : postData,
            httpMethod               : nil,
            headers                  : headers,
            totalBytesExpectedToWrite: 0,
            httpBodyStreamBuilder    : nil,
            certificateCallback      : nil)

        return network.dataStreamWith(params: params)
    }

    public static func http200DataStreamWith(params: URLConnectionParams) -> NetworkStream {

        let stream = dataStreamWith(params: params)

        return stream.tryMap { response -> Result<NetworkResponse, ErrorWithContext> in

            let result = downloadStatusCodeResponseAnalyzerWith(context: params)(response.response)
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(response)
            }
        }
    }

    public static func http200DataStreamWith(url: URL, postData: Data?, headers: URLConnectionParams.HeadersType?) -> NetworkStream {

        let params = URLConnectionParams(
            url                      : url,
            httpBody                 : postData,
            httpMethod               : nil,
            headers                  : headers,
            totalBytesExpectedToWrite: 0,
            httpBodyStreamBuilder    : nil,
            certificateCallback      : nil)

        return network.http200DataStreamWith(params: params)
    }

    private static func downloadStatusCodeResponseAnalyzerWith(context: URLConnectionParams) -> (HTTPURLResponse) -> Result<HTTPURLResponse, ErrorWithContext> {

        return { (response: HTTPURLResponse) -> Result<HTTPURLResponse, ErrorWithContext> in

            let statusCode = response.statusCode

            if HttpFlagChecker.isDownloadErrorFlag(statusCode) {
                let httpError = HttpError(httpCode: statusCode, context: context)
                let contextError = ErrorWithContext(utilsError: httpError, context: #function)
                return .failure(contextError)
            }

            return .success(response)
        }
    }

    private static func networkErrorAnalyzerWith(context: URLConnectionParams) -> JNetworkErrorTransformer {

        return { error -> UtilsError in

            if let error = error as? NetworkError { return error }

            let resultError = NSNetworkError.createJNSNetworkErrorWithContext(context, nativeError: error)

            return resultError
        }
    }
}

public extension AsyncStreamType where NextT == NetworkProgress {

    public func netMapNext() -> AsyncStream<ValueT, Any, ErrorT> {
        return mapNext { info -> AnyObject in
            switch info {
            case .download(let chunk):
                return chunk
            case .upload(let chunk):
                return chunk
            }
        }
    }
}
