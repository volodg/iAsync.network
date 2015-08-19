//
//  JURLConnectionCallbacks.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias JDidReceiveResponseHandler      = (response: NSHTTPURLResponse) -> ()
public typealias JDidFinishLoadingHandler        = (error: NSError?) -> ()
public typealias JDidReceiveDataHandler          = (data: NSData) -> ()
public typealias JDidUploadDataHandler           = (progress: Double) -> ()
public typealias JShouldAcceptCertificateForHost = (callback: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) -> Void
