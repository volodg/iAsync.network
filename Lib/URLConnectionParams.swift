//
//  URLConnectionParams.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import enum ReactiveKit.Result

public typealias InputStreamBuilder = () -> Result<InputStream, NSError>

public enum HttpMethod : String {

    case connect = "CONNECT"
    case delete  = "DELETE"
    case get     = "GET"
    case head    = "HEAD"
    case options = "OPTIONS"
    case patch   = "PATCH"
    case post    = "POST"
    case put     = "PUT"
    case trace   = "TRACE"
}

public struct URLConnectionParams : CustomStringConvertible {

    public typealias HeadersType = [String:String]

    public let url       : URL
    public let httpBody  : Data?
    public let httpMethod: HttpMethod
    public let headers   : HeadersType?

    public let totalBytesExpectedToWrite: Int64
    public let httpBodyStreamBuilder    : InputStreamBuilder?
    public let certificateCallback      : ShouldAcceptCertificateForHost?

    public init(
        url                      : URL,
        httpBody                 : Data? = nil,
        httpMethod               : HttpMethod? = nil,
        headers                  : HeadersType? = nil,
        totalBytesExpectedToWrite: Int64 = 0,
        httpBodyStreamBuilder    : InputStreamBuilder? = nil,
        certificateCallback      : ShouldAcceptCertificateForHost? = nil) {

        self.url        = url
        self.httpBody   = httpBody
        self.httpMethod = httpMethod ?? ( (httpBody != nil || httpBodyStreamBuilder != nil) ? .post : .get)
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
