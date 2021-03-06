//
//  NetworkResponseDataCallback.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

final public class NetworkResponseDataCallback {

    public let dataChunk: Data

    public let downloadedBytesCount: Int64
    public let totalBytesCount: Int64

    public init(dataChunk: Data, downloadedBytesCount: Int64, totalBytesCount: Int64) {

        self.dataChunk            = dataChunk
        self.downloadedBytesCount = downloadedBytesCount
        self.totalBytesCount      = totalBytesCount
    }
}
