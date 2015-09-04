//
//  URLConnectionParams.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

public typealias JInputStreamBuilder = () -> NSInputStream

public enum HttpMethod : String {
    
    case CONNECT = "CONNECT"
    case DELETE  = "DELETE"
    case GET     = "GET"
    case HEAD    = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH   = "PATCH"
    case POST    = "POST"
    case PUT     = "PUT"
    case TRACE   = "TRACE"
}

//TODO should be struct
public struct URLConnectionParams : Printable {
    
    public typealias HeadersType = [String:String]
    
    public let url       : NSURL
    public let httpBody  : NSData?
    public let httpMethod: HttpMethod
    public let headers   : HeadersType?
    
    public let totalBytesExpectedToWrite: Int64
    public let httpBodyStreamBuilder    : JInputStreamBuilder?
    public let certificateCallback      : JShouldAcceptCertificateForHost?
    
    public init(
        url                      : NSURL,
        httpBody                 : NSData? = nil,
        httpMethod               : HttpMethod? = nil,
        headers                  : HeadersType? = nil,
        totalBytesExpectedToWrite: Int64 = 0,
        httpBodyStreamBuilder    : JInputStreamBuilder? = nil,
        certificateCallback      : JShouldAcceptCertificateForHost? = nil)
    {
        self.url        = url
        self.httpBody   = httpBody
        self.httpMethod = httpMethod ?? ( (httpBody != nil || httpBodyStreamBuilder != nil) ? .POST : .GET)
        self.headers    = headers
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        self.httpBodyStreamBuilder     = httpBodyStreamBuilder
        self.certificateCallback       = certificateCallback
    }
    
    public var description: String {
        
        let bodyStr: String
        if let httpBody = httpBody?.toString() {
            bodyStr = httpBody
        } else {
            bodyStr = "nil"
        }
        
        let headersStr: String
        if let headers = headers?.description {
            headersStr = headers
        } else {
            headersStr = "nil"
        }
        
        return "<URLConnectionParams url:\(url), httpBody:\(bodyStr), headers:\(headersStr)>"
    }
}
