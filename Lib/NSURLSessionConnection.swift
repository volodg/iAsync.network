//
//  NSURLSessionConnection.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//
import iAsync_utils

import Foundation

internal class NSURLSessionConnection : NSObject, NSURLSessionDelegate {

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

    private let params: URLConnectionParams

    internal init(params: URLConnectionParams) {

        self.params = params
    }

    private var sessionTask: NSURLSessionTask?

    internal func start() {

        if params.url.fileURL {
            let path = params.url.path
            processLocalFileWithPath(path!)
            return
        }

        let request = NSMutableURLRequest(params: params)
        let task    = nativeConnection.dataTaskWithRequest(request)
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

    private var _downloadedBytesCount: Int64 = 0
    private(set) internal var downloadedBytesCount: Int64 {
        get {
            return _downloadedBytesCount
        }
        set (newValue) {
            _downloadedBytesCount = newValue
        }
    }

    private var _totalBytesCount: Int64 = 0
    private(set) internal var totalBytesCount: Int64 {
        get {
            return _totalBytesCount
        }
        set (newValue) {
            _totalBytesCount = newValue
        }
    }

    private var _nativeConnection: NSURLSession?
    private var nativeConnection: NSURLSession {

        if let nativeConnection = _nativeConnection {

            return nativeConnection
        }

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()

        configuration.timeoutIntervalForResource = 120.0

        let queue = NSOperationQueue.currentQueue()

        if queue == nil {
            fatalError("queue should be determined")
        }

        let nativeConnection = NSURLSession(
            configuration: configuration,
            delegate     : self,
            delegateQueue: queue)

        _nativeConnection = nativeConnection

        return nativeConnection
    }

    func finishLoading(error: ErrorWithContext?) {

        let finish = self.didFinishLoadingBlock

        cancel()
        finish?(error: error)
    }

    internal func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {

        if let error = error {
            let contextError = ErrorWithContext(error: error, context: #function)
            finishLoading(contextError)
        }
    }

    internal func URLSession(
        session : NSURLSession!,
        dataTask: NSURLSessionDataTask!,
        didReceiveResponse response: NSURLResponse,
        completionHandler: (NSURLSessionResponseDisposition) -> Void) {

        let httpResponse      = response as! NSHTTPURLResponse
        let strContentLength  = httpResponse.allHeaderFields["Content-Length"] as? NSNumber
        _totalBytesCount      = strContentLength?.longLongValue ?? 0
        _downloadedBytesCount = 0

        didReceiveResponseBlock?(response: httpResponse)

        completionHandler(.Allow)
    }

    internal func URLSession(
        session : NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveData data: NSData) {

        _downloadedBytesCount += data.length
        self.didReceiveDataBlock?(data: data)
    }

    internal func URLSession(
        session: NSURLSession,
        task   : NSURLSessionTask!,
        didCompleteWithError error: NSError?) {

        let contextError = error.flatMap { ErrorWithContext(error: $0, context: #function) }
        finishLoading(contextError)
    }

    internal func URLSession(
        session: NSURLSession,
        task: NSURLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64) {

        guard let didUploadDataBlock = self.didUploadDataBlock else { return }

        let totalBytesExpectedToWrite: Int64 = (totalBytesExpectedToSend == -1)
            ? params.totalBytesExpectedToWrite
            : Int64(totalBytesExpectedToSend)

        if totalBytesExpectedToWrite <= 0 {

            didUploadDataBlock(progress: 0)
            return
        }

        didUploadDataBlock(progress: Double(totalBytesSent)/Double(totalBytesExpectedToWrite))
    }

    internal func URLSession(
        session: NSURLSession,
        didReceiveChallenge challenge: NSURLAuthenticationChallenge,
        completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {

        if let callback = shouldAcceptCertificateBlock {

            callback(callback: completionHandler)
        } else {

            let credentials = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            completionHandler(.UseCredential, credentials)
        }
    }

    private func processLocalFileWithPath(path: String) {

        //STODO read file in separate thread
        //STODO read big files by chunks
        do {
            let data = try NSData(contentsOfFile: path, options: [])

            let response = NSHTTPURLResponse(URL: params.url, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: nil)!

            let dataTask = NSURLSessionDataTask()

            URLSession(
                nativeConnection,
                dataTask: dataTask,
                didReceiveResponse: response,
                completionHandler: { _ in })

            URLSession(nativeConnection, dataTask: dataTask, didReceiveData: data)

            URLSession(nativeConnection, task: dataTask, didCompleteWithError:nil)

        } catch let error as NSError {
            self.URLSession(self.nativeConnection, didBecomeInvalidWithError:error)
        }
    }

    deinit {
        cancel()
    }
}
