//
//  HttpFlagChecker.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private let indexes = Set([301, 302, 303, 307])

final public class HttpFlagChecker {

    public static func isDownloadErrorFlag(statusCode: Int) -> Bool {

        let result =
            !isSuccessFlag (statusCode) &&
            !isRedirectFlag(statusCode)

        return result
    }

    public static func isRedirectFlag(statusCode: Int) -> Bool {

        return indexes.contains(statusCode)
    }

    public static func isSuccessFlag(statusCode: Int) -> Bool {
        return 200 == statusCode
    }
}
