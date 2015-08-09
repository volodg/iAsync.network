//
//  JNetworkBlocksFunctions.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_async
import iAsync_utils

internal func downloadStatusCodeResponseAnalyzer(context: AnyObject) -> UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer? {
    
    return { (response: NSHTTPURLResponse) -> AsyncResult<NSHTTPURLResponse, NSError> in
        
        let statusCode = response.statusCode
        
        if JHttpFlagChecker.isDownloadErrorFlag(statusCode) {
            let httpError = JHttpError(httpCode:statusCode, context:context)
            return AsyncResult.failure(httpError)
        }
        
        return AsyncResult.success(response)
    }
}

internal func networkErrorAnalyzer(context: JURLConnectionParams) -> JNetworkErrorTransformer {
    
    return { (error: NSError) -> NSError in
        
        if let error = error as? JNetworkError {
            return error
        }
        
        let resultError = JNSNetworkError.createJNSNetworkErrorWithContext(context, nativeError: error)
        
        return resultError
    }
}

internal func privateGenericChunkedURLResponseLoader(
    params: JURLConnectionParams,
    responseAnalyzer: UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer?) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async {

    let factory = { () -> JNetworkAsync in
        
        let asyncObj = JNetworkAsync(
            params:params,
            responseAnalyzer:responseAnalyzer,
            errorTransformer:networkErrorAnalyzer(params))
        return asyncObj
    }
    
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    return loader
}

func genericChunkedURLResponseLoader(params: JURLConnectionParams) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async {
    
    return privateGenericChunkedURLResponseLoader(params, nil)
}

public func dataWithRespURLParamsLoader(
    params: JURLConnectionParams,
    responseAnalyzer: UtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse, NSError>.JAnalyzer?) -> AsyncTypes<(NSHTTPURLResponse, NSData), NSError>.Async
{
    return { (
        progressCallback: AsyncProgressCallback?,
        stateCallback   : AsyncChangeStateCallback?,
        finishCallback  : AsyncTypes<(NSHTTPURLResponse, NSData), NSError>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let loader = privateGenericChunkedURLResponseLoader(params, responseAnalyzer)
        
        let responseData = NSMutableData()
        let dataProgressCallback = { (progressInfo: AnyObject) -> () in
            
            if let progressInfo = progressInfo as? JNetworkResponseDataCallback {
                
                responseData.appendData(progressInfo.dataChunk)
            }
            
            progressCallback?(progressInfo: progressInfo)
        }
        
        //NSLog("start url: \(params.url)")
        
        var doneCallbackWrapper: AsyncTypes<NSHTTPURLResponse, NSError>.JDidFinishAsyncCallback?
        if let finishCallback = finishCallback {
            
            doneCallbackWrapper = { (result: AsyncResult<NSHTTPURLResponse, NSError>) -> () in
                
                //NSLog("done url: \(params.url) response: \(responseData.toString())  \n \n")
                //NSLog("done url: \(params.url)")
                
                switch result {
                case let .Success(v):
                    if responseData.length == 0 {
                        NSLog("!!!WARNING!!! request with params: \(params) got an empty response")
                    }
                    finishCallback(result: AsyncResult.success((v.value, responseData)))
                case let .Failure(error):
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

public func genericDataURLResponseLoader(params: JURLConnectionParams) -> AsyncTypes<NSData, NSError>.Async
{
    let loader = dataWithRespURLParamsLoader(params, nil)
    return bindSequenceOfAsyncs(loader, { asyncWithValue($0.1) } )
}

func chunkedURLResponseLoader(
    url     : NSURL,
    postData: NSData,
    headers : JURLConnectionParams.HeadersType?) -> AsyncTypes<NSHTTPURLResponse, NSError>.Async
{
    let params = JURLConnectionParams(
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
    headers : JURLConnectionParams.HeadersType?) -> AsyncTypes<NSData, NSError>.Async
{
    let params = JURLConnectionParams(
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
    headers : JURLConnectionParams.HeadersType?) -> AsyncTypes<NSData, NSError>.Async
{
    let params = JURLConnectionParams(
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
    headers : JURLConnectionParams.HeadersType?) -> AsyncTypes<(NSHTTPURLResponse, NSData), NSError>.Async
{
    let params = JURLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return dataWithRespURLParamsLoader(params, nil)
}
