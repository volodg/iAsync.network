//
//  NSError+IsNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import CFNetwork

public extension NSError {

    var isNetworkError: Bool {

        if domain != NSURLErrorDomain { return false }

        guard let type = CFNetworkErrors(rawValue: CInt(code)) else { return false }

        return type == .cfurlErrorTimedOut
            || type == .cfurlErrorCannotFindHost
            || type == .cfurlErrorCannotConnectToHost
            || type == .cfurlErrorNetworkConnectionLost
            || type == .cfurlErrorNotConnectedToInternet
            || type == .cfurlErrorSecureConnectionFailed
    }

    var socketIsNoLongerUsable: Bool {

        return domain == NSPOSIXErrorDomain && Int32(code) == EBADF
    }

    var isActiveCallError: Bool {

        if domain != NSURLErrorDomain {
            return false
        }

        let type = CFNetworkErrors(rawValue: CInt(code))
        return type == .cfurlErrorCallIsActive
    }
}
