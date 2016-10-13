//
//  HttpError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

final public class HttpError : NetworkError {

    private let context: CustomStringConvertible
    private let httpCode: CFIndex

    public required init(httpCode: CFIndex, context: CustomStringConvertible) {

        self.httpCode = httpCode
        self.context  = context

        super.init(description: "J_HTTP_ERROR")
    }

    func isHttpNotChangedError() -> Bool {

        return httpCode == 304
    }

    func isServiceUnavailableError() -> Bool {

        return httpCode == 503
    }

    func isInternalServerError() -> Bool {

        return httpCode == 500
    }

    func isNotFoundError() -> Bool {

        return httpCode == 404
    }

    override open var errorLogText: String {
        let result = "\(type(of: self)) : \(localizedDescription) Http code:\(httpCode) context:\(context.description)"
        return result
    }
}
