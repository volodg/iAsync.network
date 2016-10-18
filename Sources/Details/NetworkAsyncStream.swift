//
//  NetworkAsyncStream.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import protocol iAsync_reactiveKit.AsyncStreamInterface
import iAsync_utils

internal typealias JNetworkErrorTransformer = (_ error: UtilsError) -> UtilsError

public enum NetworkProgress {

    case download(NetworkResponseDataCallback)
    case upload(NetworkUploadProgressCallback)
}

final class NetworkAsyncStream : AsyncStreamInterface {

    typealias ValueT = HTTPURLResponse
    typealias NextT  = NetworkProgress
    typealias ErrorT = ErrorWithContext

    private let params          : URLConnectionParams
    private let errorTransformer: JNetworkErrorTransformer?

    private var connection: NSURLSessionConnection?

    init(params: URLConnectionParams, errorTransformer: JNetworkErrorTransformer?) {

        self.params           = params
        self.errorTransformer = errorTransformer
    }

    public func asyncWithCallbacks(
        success: @escaping (ValueT) -> Void,
        next   : @escaping (NextT)  -> Void,
        error  : @escaping (ErrorT) -> Void) {

        let connection  = NSURLSessionConnection(params: self.params)
        self.connection = connection

        connection.shouldAcceptCertificateBlock = self.params.certificateCallback

        unowned(unsafe) let unretainedSelf = self

        connection.didReceiveDataBlock = { dataChunk -> () in

            let progressData = NetworkResponseDataCallback(
                dataChunk           : dataChunk,
                downloadedBytesCount: connection.downloadedBytesCount,
                totalBytesCount     : connection.totalBytesCount)

            next(.download(progressData))
        }

        connection.didUploadDataBlock = { progress -> () in

            let uploadProgress = NetworkUploadProgressCallback(params: unretainedSelf.params, progress: progress)
            next(.upload(uploadProgress))
        }

        var resultHolder: ValueT?

        let errorTransformer = self.errorTransformer

        let finishWithError = { (errorVal: ErrorWithContext?) -> () in

            if let error_ = errorVal {

                let passError: UtilsError
                if let errorTransformer = errorTransformer {
                    passError = errorTransformer(error_.error)
                } else {
                    passError = error_.error
                }

                let errorWithContext = ErrorWithContext(utilsError: passError, context: error_.context)
                error(errorWithContext)
                return
            }

            if let resultHolder = resultHolder {

                success(resultHolder)
            } else {

                let error_ = UtilsError(description: "no resultHolder")
                let errorWithContext = ErrorWithContext(utilsError: error_, context: #function)
                error(errorWithContext)
            }
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
