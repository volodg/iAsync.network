//
//  HttpFlagChecker.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private let indexes = Set([301, 302, 303, 307])

final public class HttpFlagChecker {

    //todo rename?
    public static func isDownloadErrorFlag(_ statusCode: Int) -> Bool {

        let result =
            !isSuccessFlag (statusCode) &&
            !isRedirectFlag(statusCode)

        return result
    }

    //todo rename?
    public static func isRedirectFlag(_ statusCode: Int) -> Bool {

        return indexes.contains(statusCode)
    }

    //todo rename?
    public static func isSuccessFlag(_ statusCode: Int) -> Bool {
        return 200 == statusCode
    }
}
