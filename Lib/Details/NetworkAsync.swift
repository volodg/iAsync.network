//
//  NetworkAsync.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_async
import iAsync_utils

internal typealias JNetworkErrorTransformer = (error: NSError) -> NSError

final internal class NetworkAsync : AsyncInterface {

    typealias ErrorT = NSError
    typealias ValueT = NSHTTPURLResponse
    
    private let params          : URLConnectionParams
    private let responseAnalyzer: UtilsBlockDefinitions2<ValueT, ValueT, ErrorT>.Analyzer?
    private let errorTransformer: JNetworkErrorTransformer?
    
    private var connection : NSURLSessionConnection?
    
    init(
        params          : URLConnectionParams,
        responseAnalyzer: UtilsBlockDefinitions2<ValueT, ValueT, ErrorT>.Analyzer?,
        errorTransformer: JNetworkErrorTransformer?)
    {
        self.params           = params
        self.responseAnalyzer = responseAnalyzer
        self.errorTransformer = errorTransformer
    }

    func asyncWithResultCallback(
        finishCallback  : AsyncTypes<ValueT, ErrorT>.DidFinishAsyncCallback,
        stateCallback   : AsyncChangeStateCallback,
        progressCallback: AsyncProgressCallback)
    {
        let connection  = NSURLSessionConnection(params: self.params)
        self.connection = connection

        connection.shouldAcceptCertificateBlock = self.params.certificateCallback

        unowned(unsafe) let unretainedSelf = self

        connection.didReceiveDataBlock = { (dataChunk: NSData) -> () in

            let progressData = NetworkResponseDataCallback(
                dataChunk: dataChunk,
                downloadedBytesCount: connection.downloadedBytesCount,
                totalBytesCount: connection.totalBytesCount)

            progressCallback(progressInfo: progressData)
        }

        connection.didUploadDataBlock = { (progress: Double) -> () in

            let uploadProgress = NetworkUploadProgressCallback(params: unretainedSelf.params, progress: progress)
            progressCallback(progressInfo: uploadProgress)
        }

        var resultHolder: ValueT?

        let errorTransformer = self.errorTransformer

        let finishWithError = { (error: AsyncResult<ValueT, ErrorT>?) -> () in

            if let error = error {

                let passError = { () -> AsyncResult<ValueT, ErrorT> in

                    return errorTransformer.flatMap { error.mapError($0) } ?? error
                }()

                finishCallback(result: passError)
                return
            }

            finishCallback(result: .Success(resultHolder!))
        }

        let finish = { (error: NSError?) -> Void in

            if let error = error {
                finishWithError(.Failure(error))
            } else {
                finishWithError(nil)
            }
        }

        connection.didFinishLoadingBlock = finish

        connection.didReceiveResponseBlock = { (response: NSHTTPURLResponse) -> () in

            if let responseAnalyzer = unretainedSelf.responseAnalyzer {

                let result = responseAnalyzer(object: response)

                switch result {
                case .Success(let value):
                    resultHolder = value
                case .Failure(let error):
                    unretainedSelf.forceCancel()
                    finish(error)
                case .Interrupted:
                    unretainedSelf.forceCancel()
                    finishWithError(.Interrupted)
                case .Unsubscribed:
                    unretainedSelf.forceCancel()
                    finishWithError(.Unsubscribed)
                }
                return
            }

            resultHolder = response
        }

        connection.start()
    }

    func doTask(task: AsyncHandlerTask) {

        if let connection = connection {

            connection.didReceiveDataBlock          = nil
            connection.didFinishLoadingBlock        = nil
            connection.didReceiveResponseBlock      = nil
            connection.didUploadDataBlock           = nil
            connection.shouldAcceptCertificateBlock = nil

            //TODO maybe always cancel?
            if task == .Cancel {
                connection.cancel()
                self.connection = nil
            }
        }
    }

    private func forceCancel() {

        doTask(.Cancel)
    }

    var isForeignThreadResultCallback: Bool {
        return false
    }
}
