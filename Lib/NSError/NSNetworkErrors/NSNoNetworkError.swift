//
//  NSNoNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

final public class NSNoNetworkError : NSNetworkError {

    override class func isMineNSNetworkError(error: NSError) -> Bool {
        return error.isNetworkError || error.socketIsNoLongerUsable
    }

    override public var localizedDescription: String {

        return NSLocalizedString(
            "J_NETWORK_NO_INTERNET_ERROR",
            bundle : NSBundle(forClass: self.dynamicType),
            comment:"")
    }

    override public func writeErrorWithLogger(context: AnyObject) {
        writeErrorToNSLog()
    }
}
