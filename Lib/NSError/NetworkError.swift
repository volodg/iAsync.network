//
//  NetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

open class NetworkError : UtilsError {

    open override class func iAsyncErrorsDomain() -> String {

        return "com.just_for_fun.network.library"
    }
}
