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

internal func downloadStatusCodeResponseAnalyzer(context: AnyObject) -> JUtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse>.JAnalyzer? {
    
    return { (response: NSHTTPURLResponse) -> Result<NSHTTPURLResponse> in
        
        let statusCode = response.statusCode
        
        if JHttpFlagChecker.isDownloadErrorFlag(statusCode) {
            let httpError = JHttpError(httpCode:statusCode, context:context)
            return Result.error(httpError)
        }
        
        return Result.value(response)
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
    responseAnalyzer: JUtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse>.JAnalyzer?) -> JAsyncTypes<NSHTTPURLResponse>.JAsync {

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

func genericChunkedURLResponseLoader(params: JURLConnectionParams) -> JAsyncTypes<NSHTTPURLResponse>.JAsync {
    
    return privateGenericChunkedURLResponseLoader(params, nil)
}

internal func privateGenericDataURLResponseLoader(
    params: JURLConnectionParams,
    responseAnalyzer: JUtilsBlockDefinitions2<NSHTTPURLResponse, NSHTTPURLResponse>.JAnalyzer?) -> JAsyncTypes<(NSHTTPURLResponse, NSData)>.JAsync
{
    return { (
        progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JAsyncTypes<(NSHTTPURLResponse, NSData)>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let loader = privateGenericChunkedURLResponseLoader(params, responseAnalyzer)
        
        let responseData = NSMutableData()
        let dataProgressCallback = { (progressInfo: AnyObject) -> () in
            
            if let progressInfo = progressInfo as? JNetworkResponseDataCallback {
                
                responseData.appendData(progressInfo.dataChunk)
            }
            
            progressCallback?(progressInfo: progressInfo)
        }
        
        /*NSArray *skipPt = @[@"profile/profileapi/changes", @"/info/api/report", @"/api/addDeviceProfileId"];
        
        if ([skipPt all:^BOOL(id object) {
        return ![[params.url description] containsString:object];
        }])*/
        //NSLog("start url: \(params.url)")
        
        var doneCallbackWrapper: JAsyncTypes<NSHTTPURLResponse>.JDidFinishAsyncCallback?
        if let finishCallback = finishCallback {
            
            doneCallbackWrapper = { (result: Result<NSHTTPURLResponse>) -> () in
                
                /*if ([skipPt all:^BOOL(id object) {
                return ![[params.url description] containsString:object];
                }])*/
                //NSLog("done url: \(params.url) response: \(responseData.toString())  \n \n")
                //NSLog("done url: \(params.url)")
                
                switch result {
                case let .Value(v):
                    if responseData.length == 0 {
                        NSLog("!!!WARNING!!! request with params: \(params) got an empty response")
                    }
                    finishCallback(result: Result.value((v.value, responseData)))
                case let .Error(error):
                    finishCallback(result: Result.error(error))
                }
            }
        }
        
        return loader(
            progressCallback: dataProgressCallback,
            stateCallback   : stateCallback,
            finishCallback  : doneCallbackWrapper)
    }
}

public func genericDataURLResponseLoader(params: JURLConnectionParams) -> JAsyncTypes<NSData>.JAsync
{
    let loader = privateGenericDataURLResponseLoader(params, nil)
    return bindSequenceOfAsyncs(loader, { asyncWithResult($0.1) } )
}

func chunkedURLResponseLoader(
    url     : NSURL,
    postData: NSData,
    headers : JURLConnectionParams.HeadersType?) -> JAsyncTypes<NSHTTPURLResponse>.JAsync
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
    headers : JURLConnectionParams.HeadersType?) -> JAsyncTypes<NSData>.JAsync
{
    let params = JURLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    let loader = privateGenericDataURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params))
    return bindSequenceOfAsyncs(loader, { asyncWithResult($0.1) } )
}

func perkyDataURLResponseLoader(
    url     : NSURL,
    postData: NSData?,
    headers : JURLConnectionParams.HeadersType?) -> JAsyncTypes<NSData>.JAsync
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
    headers : JURLConnectionParams.HeadersType?) -> JAsyncTypes<(NSHTTPURLResponse, NSData)>.JAsync
{
    let params = JURLConnectionParams(
        url                      : url,
        httpBody                 : postData,
        httpMethod               : nil,
        headers                  : headers,
        totalBytesExpectedToWrite: 0,
        httpBodyStreamBuilder    : nil,
        certificateCallback      : nil)
    
    return privateGenericDataURLResponseLoader(params, nil)
}
