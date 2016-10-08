//
//  URLConnectionCallbacks.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

public typealias DidReceiveResponseHandler      = (_ response: HTTPURLResponse) -> ()
public typealias DidFinishLoadingHandler        = (_ error: ErrorWithContext?) -> ()
public typealias DidReceiveDataHandler          = (_ data: Data) -> ()
public typealias DidUploadDataHandler           = (_ progress: Double) -> ()
public typealias ShouldAcceptCertificateForHost = (_ callback: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
