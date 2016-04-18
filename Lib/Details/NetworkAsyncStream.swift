//
//  NetworkAsyncStream.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import protocol iAsync_reactiveKit.AsyncStreamInterface
import iAsync_utils

import ReactiveKit

internal typealias JNetworkErrorTransformer = (error: NSError) -> NSError

public enum NetworkProgress {

    case Download(NetworkResponseDataCallback)
    case Upload(NetworkUploadProgressCallback)
}

final class NetworkAsyncStream : AsyncStreamInterface {

    typealias Value = NSHTTPURLResponse
    typealias Next  = NetworkProgress
    typealias Error = ErrorWithContext

    private let params          : URLConnectionParams
    private let errorTransformer: JNetworkErrorTransformer?

    private var connection: NSURLSessionConnection?

    init(params: URLConnectionParams, errorTransformer: JNetworkErrorTransformer?) {

        self.params           = params
        self.errorTransformer = errorTransformer
    }

    func asyncWithCallbacks(success onSuccess: Value -> Void, next: Next  -> Void, error onError: Error -> Void) {

        let connection  = NSURLSessionConnection(params: self.params)
        self.connection = connection

        connection.shouldAcceptCertificateBlock = self.params.certificateCallback

        unowned(unsafe) let unretainedSelf = self

        connection.didReceiveDataBlock = { dataChunk -> () in

            let progressData = NetworkResponseDataCallback(
                dataChunk           : dataChunk,
                downloadedBytesCount: connection.downloadedBytesCount,
                totalBytesCount     : connection.totalBytesCount)

            next(.Download(progressData))
        }

        connection.didUploadDataBlock = { progress -> () in

            let uploadProgress = NetworkUploadProgressCallback(params: unretainedSelf.params, progress: progress)
            next(.Upload(uploadProgress))
        }

        var resultHolder: Value?

        let errorTransformer = self.errorTransformer

        let finishWithError = { (error: ErrorWithContext?) -> () in

            if let error = error {

                let passError: NSError
                if let errorTransformer = errorTransformer {
                    passError = errorTransformer(error: error.error)
                } else {
                    passError = error.error
                }

                let errorWithContext = ErrorWithContext(error: passError, context: error.context)
                onError(errorWithContext)
                return
            }

            onSuccess(resultHolder!)
        }

        let finish = { (error: ErrorWithContext?) in

            finishWithError(error)
        }

        connection.didFinishLoadingBlock = finish

        connection.didReceiveResponseBlock = { response -> () in

            resultHolder = response
        }

        connection.start()
    }

    func cancel() {

        guard let connection = connection else { return }

        self.connection = nil

        connection.didReceiveDataBlock          = nil
        connection.didFinishLoadingBlock        = nil
        connection.didReceiveResponseBlock      = nil
        connection.didUploadDataBlock           = nil
        connection.shouldAcceptCertificateBlock = nil

        connection.cancel()
    }
}
