//
//  URLConnectionParams.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import ReactiveKit_old//???

public typealias InputStreamBuilder = () -> Result<NSInputStream, NSError>

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

public struct URLConnectionParams : CustomStringConvertible {

    public typealias HeadersType = [String:String]

    public let url       : NSURL
    public let httpBody  : NSData?
    public let httpMethod: HttpMethod
    public let headers   : HeadersType?

    public let totalBytesExpectedToWrite: Int64
    public let httpBodyStreamBuilder    : InputStreamBuilder?
    public let certificateCallback      : ShouldAcceptCertificateForHost?

    public init(
        url                      : NSURL,
        httpBody                 : NSData? = nil,
        httpMethod               : HttpMethod? = nil,
        headers                  : HeadersType? = nil,
        totalBytesExpectedToWrite: Int64 = 0,
        httpBodyStreamBuilder    : InputStreamBuilder? = nil,
        certificateCallback      : ShouldAcceptCertificateForHost? = nil) {

        self.url        = url
        self.httpBody   = httpBody
        self.httpMethod = httpMethod ?? ( (httpBody != nil || httpBodyStreamBuilder != nil) ? .POST : .GET)
        self.headers    = headers
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        self.httpBodyStreamBuilder     = httpBodyStreamBuilder
        self.certificateCallback       = certificateCallback
    }

    public var description: String {

        let bodyStr = httpBody?.toString() ?? "nil"

        let headersStr = headers?.description ?? "nil"

        return "<URLConnectionParams url: \(url), httpBody: \(bodyStr), headers: \(headersStr)>"
    }
}
