//
//  JNetworkBlocksFunctions.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_async
import iAsync_utils

public struct NetworkResponse : CustomStringConvertible {
    
    public let params      : URLConnectionParams
    public let response    : NSHTTPURLResponse
    public let responseData: NSData
    
    public var description: String {
        
        let responseStr: String
        if let response = responseData.toString() {
            responseStr = response
        } else {
            responseStr = "(???)"
        }
        
        return "<NetworkResponse: params:\(params) response:\(response) responseData:\(responseStr)>"
    }
    
    public init(
        params      : URLConnectionParams,
        response    : NSHTTPURLResponse,
        responseData: NSData)
    {
        self.params       = params
        self.response     = response
        self.responseData = responseData
    }
}

internal func downloadStatusCodeResponseAnalyzer(context: CustomStringConvertible) -> UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer? {
    
    return { (response: NSHTTPURLResponse) -> AsyncResult<NSHTTPURLResponse, NSError> in
        
        let statusCode = response.statusCode
        
        if JHttpFlagChecker.isDownloadErrorFlag(statusCode) {
            let httpError = JHttpError(httpCode:statusCode, context:context)
            return .Failure(httpError)
        }
        
        return .Success(response)
    }
}

internal func networkErrorAnalyzer(context: URLConnectionParams) -> JNetworkErrorTransformer {
    
    return { (error: NSError) -> NSError in
        
        if let error = error as? JNetworkError {
            return error
        }
        
        let resultError = JNSNetworkError.createJNSNetworkErrorWithContext(context, nativeError: error)
        
        return resultError
    }
}

internal func privateGenericChunkedURLResponseLoader(
    params params: URLConnectionParams,
    responseAnalyzer: UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer?) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async {

    let factory = { () -> NetworkAsync in
        
        let asyncObj = NetworkAsync(
            params          : params,
            responseAnalyzer: responseAnalyzer,
            errorTransformer: networkErrorAnalyzer(params))
        return asyncObj
    }
    
    let loader = AsyncBuilder.buildWithAdapterFactory(factory)
    return loader
}

func genericChunkedURLResponseLoader(params: URLConnectionParams) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async {
    
    return privateGenericChunkedURLResponseLoader(params: params, responseAnalyzer: nil)
}

public func genericDataURLResponseLoader(
    params params: URLConnectionParams,
    responseAnalyzer: UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer?) -> AsyncTypes<NetworkResponse, NSError>.Async
{
    return { (
        progressCallback: AsyncProgressCallback?,
        stateCallback   : AsyncChangeStateCallback?,
        finishCallback  : AsyncTypes<NetworkResponse, NSError>.DidFinishAsyncCallback?) -> JAsyncHandler in
        
        let loader = privateGenericChunkedURLResponseLoader(params: params, responseAnalyzer: responseAnalyzer)
        
        let responseData = NSMutableData()
        let dataProgressCallback = { (progressInfo: AnyObject) -> () in
            
            if let progressInfo = progressInfo as? JNetworkResponseDataCallback {
                
                responseData.appendData(progressInfo.dataChunk)
            }
            
            progressCallback?(progressInfo: progressInfo)
        }
        
        //NSLog("start url: \(params.url)")
        
        var doneCallbackWrapper: AsyncTypes<NSHTTPURLResponse, NSError>.DidFinishAsyncCallback?
        if let finishCallback = finishCallback {
            
            doneCallbackWrapper = { (result: AsyncResult<NSHTTPURLResponse, NSError>) -> () in
                
                //NSLog("done url: \(params.url) response: \(responseData.toString())  \n \n")
                //NSLog("done url: \(params.url)")
                
                switch result {
                case .Success(let value):
                    if responseData.length == 0 {
                        NSLog("!!!WARNING!!! request with params: \(params) got an empty response")
                    }
                    let result = NetworkResponse(params: params, response: value, responseData: responseData)
                    finishCallback(result: .Success(result))
                case .Failure(let error):
                    finishCallback(result: .Failure(error))
                case .Interrupted:
                    finishCallback(result: .Interrupted)
                case .Unsubscribed:
                    finishCallback(result: .Unsubscribed)
                }
            }
        }
        
        return loader(
            progressCallback: dataProgressCallback,
            stateCallback   : stateCallback,
            finishCallback  : doneCallbackWrapper)
    }
}

func chunkedURLResponseLoader(
    url     : NSURL,
    postData: NSData,
    headers : URLConnectionParams.HeadersType?) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async
{
    let params = URLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return privateGenericChunkedURLResponseLoader(params: params, responseAnalyzer: downloadStatusCodeResponseAnalyzer(params))
}

public func dataURLResponseLoader(
    url     : NSURL,
    postData: NSData?,
    headers : URLConnectionParams.HeadersType?) -> AsyncTypes<NetworkResponse, NSError>.Async
{
    let params = URLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return genericDataURLResponseLoader(params: params, responseAnalyzer: downloadStatusCodeResponseAnalyzer(params))
}

public func perkyDataURLResponseLoader(
    url     : NSURL,
    postData: NSData?,
    headers : URLConnectionParams.HeadersType?) -> AsyncTypes<NetworkResponse, NSError>.Async
{
    let params = URLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return genericDataURLResponseLoader(params: params, responseAnalyzer: nil)
}
