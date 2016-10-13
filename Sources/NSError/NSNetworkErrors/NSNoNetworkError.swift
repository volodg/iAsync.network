//
//  NSNoNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

final public class NSNoNetworkError : NSNetworkError {

    //todo rename?
    override class func isMineNSNetworkError(_ error: UtilsError) -> Bool {
        return error.isNetworkError || error.socketIsNoLongerUsable
    }

    override public var localizedDescription: String {

        return NSLocalizedString(
            "J_NETWORK_NO_INTERNET_ERROR",
            bundle : Bundle(for: type(of: self)),
            comment:"")
    }
}

public extension LoggedObject where Self : NSNoNetworkError {

    var logTarget: LogTarget { return LogTarget.console }
}
