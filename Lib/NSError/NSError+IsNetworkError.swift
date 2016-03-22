//
//  NSError+IsNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import CFNetwork

public extension NSError {

    var isNetworkError: Bool {

        if domain != NSURLErrorDomain { return false }

        guard let type = CFNetworkErrors(rawValue: CInt(code)) else { return false }

        return type == .CFURLErrorTimedOut
            || type == .CFURLErrorCannotFindHost
            || type == .CFURLErrorCannotConnectToHost
            || type == .CFURLErrorNetworkConnectionLost
            || type == .CFURLErrorNotConnectedToInternet
            || type == .CFURLErrorSecureConnectionFailed
    }

    var socketIsNoLongerUsable: Bool {

        return domain == NSPOSIXErrorDomain && Int32(code) == EBADF
    }

    var isActiveCallError: Bool {

        if domain != NSURLErrorDomain {
            return false
        }

        let type = CFNetworkErrors(rawValue: CInt(code))
        return type == .CFURLErrorCallIsActive
    }
}
