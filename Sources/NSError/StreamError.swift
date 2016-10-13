//
//  StreamError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

final public class StreamError : NetworkError {

    let streamError: CFStreamError
    fileprivate let context: CustomStringConvertible

    required public init(streamError: CFStreamError, context: CustomStringConvertible) {

        self.streamError = streamError
        self.context     = context

        let description = "JNETWORK_CF_STREAM_ERROR"

        super.init(description: description)
    }

    override open var errorLogText: String {

        let result = "\(type(of: self)) : \(localizedDescription) nativeError domain:\(streamError.domain) error_code:\(streamError.error) context:\(context)"
        return result
    }
}
