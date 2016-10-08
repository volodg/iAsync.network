//
//  UploadProgress.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

protocol UploadProgress : NSObjectProtocol {

    var progress: Double { get }
    var url     : URL { get }
    var headers : URLConnectionParams.HeadersType? { get }
}
