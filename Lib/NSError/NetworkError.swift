//
//  NetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class NetworkError : UtilsError {

    public override class func iAsyncErrorsDomain() -> String {

        return "com.just_for_fun.network.library"
    }
}
