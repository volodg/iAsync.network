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

internal func downloadStatusCodeResponseAnalyzer(context: Printable) -> UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer? {
    
    return { (response: NSHTTPURLResponse) -> AsyncResult<NSHTTPURLResponse, NSError> in
        
        let statusCode = response.statusCode
        
        if JHttpFlagChecker.isDownloadErrorFlag(statusCode) {
            let httpError = JHttpError(httpCode:statusCode, context:context)
            return AsyncResult.failure(httpError)
        }
        
        return AsyncResult.success(response)
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
    params: URLConnectionParams,
    responseAnalyzer: UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer?) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async {

    let factory = { () -> NetworkAsync in
        
        let asyncObj = NetworkAsync(
            params:params,
            responseAnalyzer:responseAnalyzer,
            errorTransformer:networkErrorAnalyzer(params))
        return asyncObj
    }
    
    let loader = AsyncBuilder.buildWithAdapterFactory(factory)
    return loader
}

func genericChunkedURLResponseLoader(params: URLConnectionParams) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async {
    
    return privateGenericChunkedURLResponseLoader(params, nil)
}

public func dataWithRespURLParamsLoader(
    params: URLConnectionParams,
    responseAnalyzer: UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer?) -> AsyncTypes<(NSHTTPURLResponse, NSData), NSError>.Async
{
    return { (
        progressCallback: AsyncProgressCallback?,
        stateCallback   : AsyncChangeStateCallback?,
        finishCallback  : AsyncTypes<(NSHTTPURLResponse, NSData), NSError>.DidFinishAsyncCallback?) -> JAsyncHandler in
        
        let loader = privateGenericChunkedURLResponseLoader(params, responseAnalyzer)
        
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
                case .Success(let v):
                    if responseData.length == 0 {
                        NSLog("!!!WARNING!!! request with params: \(params) got an empty response")
                    }
                    finishCallback(result: AsyncResult.success((v.value, responseData)))
                case .Failure(let error):
                    finishCallback(result: AsyncResult.failure(error.value))
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

public func genericDataURLResponseLoader(params: URLConnectionParams) -> AsyncTypes<NSData, NSError>.Async
{
    let loader = dataWithRespURLParamsLoader(params, nil)
    return bindSequenceOfAsyncs(loader, { asyncWithValue($0.1) } )
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
    
    return privateGenericChunkedURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params))
}

public func dataURLResponseLoader(
    url     : NSURL,
    postData: NSData?,
    headers : URLConnectionParams.HeadersType?) -> AsyncTypes<NSData, NSError>.Async
{
    let params = URLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    let loader = dataWithRespURLParamsLoader(params, downloadStatusCodeResponseAnalyzer(params))
    return bindSequenceOfAsyncs(loader, { asyncWithValue($0.1) } )
}

public func perkyDataURLResponseLoader(
    url     : NSURL,
    postData: NSData?,
    headers : URLConnectionParams.HeadersType?) -> AsyncTypes<NSData, NSError>.Async
{
    let params = URLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return genericDataURLResponseLoader(params)
}

public func perkyURLResponseLoader(
    url     : NSURL,
    postData: NSData?,
    headers : URLConnectionParams.HeadersType?) -> AsyncTypes<(NSHTTPURLResponse, NSData), NSError>.Async
{
    let params = URLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return dataWithRespURLParamsLoader(params, nil)
}
