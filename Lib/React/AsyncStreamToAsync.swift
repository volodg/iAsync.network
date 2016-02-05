//
//  AsyncStreamToAsync.swift
//  iAsync_network
//
//  Created by Gorbenko Vladimir on 05/02/16.
//  Copyright (c) 2016 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_async
import iAsync_reactiveKit

extension AsyncStreamType where Next == NetworkProgress, Error == NSError {

    public func networkStreamToAsync() -> AsyncTypes<Value, NSError>.Async {

        return mapNext { info -> AnyObject in
            switch info {
            case .Download(let chunk):
                return chunk
            case .Upload(let chunk):
                return chunk
            }
        }.streamToAsync()
    }
}
