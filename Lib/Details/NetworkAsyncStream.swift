//
//  NetworkAsyncStream.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils
import iAsync_reactiveKit

import ReactiveKit

internal typealias JNetworkErrorTransformer = (error: NSError) -> NSError

public enum NetworkProgress {

    case Download(NetworkResponseDataCallback)
    case Upload(NetworkUploadProgressCallback)
}

private var referrenceCount = 0

final class NetworkAsyncStream : AsyncStreamInterface {

    typealias Value = NSHTTPURLResponse
    typealias Next  = NetworkProgress
    typealias Error = NSError

    private let params          : URLConnectionParams
    private let errorTransformer: JNetworkErrorTransformer?

    private var connection: NSURLSessionConnection?

    deinit {
        referrenceCount -= 1
        print("referrenceCount: \(referrenceCount)")
    }

    init(params: URLConnectionParams, errorTransformer: JNetworkErrorTransformer?) {

        referrenceCount += 1
        print("referrenceCount: \(referrenceCount)")
        self.params           = params
        self.errorTransformer = errorTransformer
    }

    func asyncWithCallbacks(success onSuccess: Value -> Void, next: Next  -> Void, error onError: Error -> Void) {

        let connection  = NSURLSessionConnection(params: self.params)
        self.connection = connection

        connection.shouldAcceptCertificateBlock = self.params.certificateCallback

        unowned(unsafe) let unretainedSelf = self

        connection.didReceiveDataBlock = { (dataChunk: NSData) -> () in

            let progressData = NetworkResponseDataCallback(
                dataChunk           : dataChunk,
                downloadedBytesCount: connection.downloadedBytesCount,
                totalBytesCount     : connection.totalBytesCount)

            next(.Download(progressData))
        }

        connection.didUploadDataBlock = { (progress: Double) -> () in

            let uploadProgress = NetworkUploadProgressCallback(params: unretainedSelf.params, progress: progress)
            next(.Upload(uploadProgress))
        }

        var resultHolder: Value?

        let errorTransformer = self.errorTransformer

        let finishWithError = { (error: Error?) -> () in

            if let error = error {

                let passError: Error
                if let errorTransformer = errorTransformer {
                    passError = errorTransformer(error: error)
                } else {
                    passError = error
                }

                onError(passError)
                return
            }

            onSuccess(resultHolder!)
        }

        let finish = { (error: NSError?) -> Void in

            finishWithError(error)
        }

        connection.didFinishLoadingBlock = finish

        connection.didReceiveResponseBlock = { (response: NSHTTPURLResponse) -> () in

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
