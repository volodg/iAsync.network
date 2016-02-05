//
//  AsyncStreamToAsync.swift
//  Pods
//
//  Created by Gorbenko Vladimir on 05/02/16.
//
//

import Foundation

import iAsync_async
import iAsync_utils
import iAsync_reactiveKit

import ReactiveKit

extension AsyncStreamType where Value == NetworkResponse, Next == NetworkProgress, Error == NSError {

    public func networkStreamToAsync() -> AsyncTypes<NetworkResponse, NSError>.Async {

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
