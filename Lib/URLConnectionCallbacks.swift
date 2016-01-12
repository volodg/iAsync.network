//
//  URLConnectionCallbacks.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias DidReceiveResponseHandler      = (response: NSHTTPURLResponse) -> ()
public typealias DidFinishLoadingHandler        = (error: NSError?) -> ()
public typealias DidReceiveDataHandler          = (data: NSData) -> ()
public typealias DidUploadDataHandler           = (progress: Double) -> ()
public typealias ShouldAcceptCertificateForHost = (callback: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) -> Void
