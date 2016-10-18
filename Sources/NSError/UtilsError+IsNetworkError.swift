//
//  UtilsError+IsNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import CFNetwork
import iAsync_utils

public extension UtilsError {

    var isNetworkError: Bool {

        guard let nsError = self as? WrapperOfNSError else { return false }

        if nsError.error.domain != NSURLErrorDomain { return false }

        guard let type = CFNetworkErrors(rawValue: CInt(nsError.error.code)) else { return false }

        return type == .cfurlErrorTimedOut
            || type == .cfurlErrorCannotFindHost
            || type == .cfurlErrorCannotConnectToHost
            || type == .cfurlErrorNetworkConnectionLost
            || type == .cfurlErrorNotConnectedToInternet
            || type == .cfurlErrorSecureConnectionFailed
    }

    var socketIsNoLongerUsable: Bool {

        guard let nsError = self as? WrapperOfNSError else { return false }

        return nsError.error.domain == NSPOSIXErrorDomain && Int32(nsError.error.code) == EBADF
    }

    var isActiveCallError: Bool {

        guard let nsError = self as? WrapperOfNSError else { return false }

        if nsError.error.domain != NSURLErrorDomain {
            return false
        }

        let type = CFNetworkErrors(rawValue: CInt(nsError.error.code))
        return type == .cfurlErrorCallIsActive
    }
}
