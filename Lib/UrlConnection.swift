//
//  URLConnection.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public protocol URLConnection : NSObjectProtocol
{
    func start()
    func cancel()
    
    var downloadedBytesCount: Int64 { get }
    var totalBytesCount     : Int64 { get }
    
    //callbacks cleared after finish of loading
    var didReceiveResponseBlock     : DidReceiveResponseHandler?      { get set }
    var didReceiveDataBlock         : DidReceiveDataHandler?          { get set }
    var didFinishLoadingBlock       : DidFinishLoadingHandler?        { get set }
    var didUploadDataBlock          : DidUploadDataHandler?           { get set }
    var shouldAcceptCertificateBlock: ShouldAcceptCertificateForHost? { get set }
}
