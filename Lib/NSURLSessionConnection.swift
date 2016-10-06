//
//  NSURLSessionConnection.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//
import iAsync_utils

import Foundation

internal class NSURLSessionConnection : NSObject, URLSessionDelegate {

    func clearCallbacks() {

        didReceiveResponseBlock      = nil
        didReceiveDataBlock          = nil
        didFinishLoadingBlock        = nil
        didUploadDataBlock           = nil
        shouldAcceptCertificateBlock = nil
    }

    internal var didReceiveResponseBlock     : DidReceiveResponseHandler?
    internal var didReceiveDataBlock         : DidReceiveDataHandler?
    internal var didFinishLoadingBlock       : DidFinishLoadingHandler?
    internal var didUploadDataBlock          : DidUploadDataHandler?
    internal var shouldAcceptCertificateBlock: ShouldAcceptCertificateForHost?

    fileprivate let params: URLConnectionParams

    internal init(params: URLConnectionParams) {

        self.params = params
    }

    fileprivate var sessionTask: URLSessionTask?

    internal func start() {

        if params.url.isFileURL {
            processLocalFileWithPath(params.url.path)
            return
        }

        let request = NSMutableURLRequest(params: params) as URLRequest
        let task    = nativeConnection.dataTask(with: request)
        sessionTask = task

        task.resume()
    }

    internal func cancel() {

        clearCallbacks()

        guard let nativeConnection = _nativeConnection else { return }

        sessionTask?.cancel()
        sessionTask = nil
        _nativeConnection = nil
        nativeConnection.invalidateAndCancel()
    }

    fileprivate var _downloadedBytesCount: Int64 = 0
    fileprivate(set) internal var downloadedBytesCount: Int64 {
        get {
            return _downloadedBytesCount
        }
        set (newValue) {
            _downloadedBytesCount = newValue
        }
    }

    fileprivate var _totalBytesCount: Int64 = 0
    fileprivate(set) internal var totalBytesCount: Int64 {
        get {
            return _totalBytesCount
        }
        set (newValue) {
            _totalBytesCount = newValue
        }
    }

    fileprivate var _nativeConnection: Foundation.URLSession?
    fileprivate var nativeConnection: Foundation.URLSession {

        if let nativeConnection = _nativeConnection {

            return nativeConnection
        }

        let configuration = URLSessionConfiguration.default

        configuration.timeoutIntervalForResource = 120.0

        let queue = OperationQueue.current

        if queue == nil {
            fatalError("queue should be determined")
        }

        let nativeConnection = Foundation.URLSession(
            configuration: configuration,
            delegate     : self,
            delegateQueue: queue)

        _nativeConnection = nativeConnection

        return nativeConnection
    }

    func finishLoading(_ error: ErrorWithContext?) {

        let finish = self.didFinishLoadingBlock

        cancel()
        finish?(error)
    }

    internal func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {

        if let error = error {
            let contextError = ErrorWithContext(error: error as NSError, context: #function)
            finishLoading(contextError)
        }
    }

    internal func URLSession(
        _ session : Foundation.URLSession!,
        dataTask: URLSessionDataTask!,
        didReceiveResponse response: URLResponse,
        completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {

        if let httpResponse = response as? HTTPURLResponse {

            let strContentLength  = httpResponse.allHeaderFields["Content-Length"] as? NSNumber
            _totalBytesCount      = strContentLength?.int64Value ?? 0
            _downloadedBytesCount = 0

            didReceiveResponseBlock?(httpResponse)
        } else {

            iAsync_utils_logger.logError("unexpected response: \(response)", context: #function)
        }

        completionHandler(.allow)
    }

    internal func URLSession(
        _ session : Foundation.URLSession,
        dataTask: URLSessionDataTask,
        didReceiveData data: Data) {

        _downloadedBytesCount += data.count
        self.didReceiveDataBlock?(data)
    }

    internal func URLSession(
        _ session: Foundation.URLSession,
        task   : URLSessionTask!,
        didCompleteWithError error: NSError?) {

        let contextError = error.flatMap { ErrorWithContext(error: $0, context: #function) }
        finishLoading(contextError)
    }

    internal func URLSession(
        _ session: Foundation.URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64) {

        guard let didUploadDataBlock = self.didUploadDataBlock else { return }

        let totalBytesExpectedToWrite: Int64 = (totalBytesExpectedToSend == -1)
            ? params.totalBytesExpectedToWrite
            : Int64(totalBytesExpectedToSend)

        if totalBytesExpectedToWrite <= 0 {

            didUploadDataBlock(0)
            return
        }

        didUploadDataBlock(Double(totalBytesSent)/Double(totalBytesExpectedToWrite))
    }

    internal func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let callback = shouldAcceptCertificateBlock {

            callback(completionHandler)
        } else {

            if let trust = challenge.protectionSpace.serverTrust {
                let credentials = URLCredential(trust: trust)
                completionHandler(.useCredential, credentials)
            } else {

                assert(false)
            }
        }
    }

    fileprivate func processLocalFileWithPath(_ path: String) {

        //STODO read file in separate thread
        //STODO read big files by chunks
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [])

            let dataTask = URLSessionDataTask()

            if let response = HTTPURLResponse(url: params.url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil) {

                URLSession(
                    nativeConnection,
                    dataTask: dataTask,
                    didReceiveResponse: response,
                    completionHandler: { _ in })
            } else {

                iAsync_utils_logger.logError("can not create HTTPURLResponse", context: #function)
            }

            URLSession(nativeConnection, dataTask: dataTask, didReceiveData: data)

            URLSession(nativeConnection, task: dataTask, didCompleteWithError:nil)

        } catch let error as NSError {
            self.urlSession(self.nativeConnection, didBecomeInvalidWithError:error)
        }
    }

    deinit {
        cancel()
    }
}
