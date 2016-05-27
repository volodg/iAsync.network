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

        super.init(
            description: "J_HTTP_ERROR",
            domain     : "com.just_for_fun.library.http",
            code       : httpCode)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func isHttpNotChangedError() -> Bool {

        return code == 304
    }

    func isServiceUnavailableError() -> Bool {

        return code == 503
    }

    func isInternalServerError() -> Bool {

        return code == 500
    }

    func isNotFoundError() -> Bool {

        return code == 404
    }

    override public var errorLogDescription: String {

        return "\(self.dynamicType) : \(localizedDescription) Http code:\(code) context:\(context.description)"
    }
}
