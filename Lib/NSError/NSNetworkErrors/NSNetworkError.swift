//
//  NSNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class NSNetworkError : NetworkError {

    let context: URLConnectionParams
    let nativeError: NSError

    public required init(context: URLConnectionParams, nativeError: NSError) {

        self.context     = context
        self.nativeError = nativeError

        super.init(description:"")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var localizedDescription: String {

        return NSLocalizedString(
            "J_NETWORK_GENERIC_ERROR",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
    }

    public static func createJNSNetworkErrorWithContext(
        context: URLConnectionParams, nativeError: NSError) -> NSNetworkError {

        let selfType: NSNetworkError.Type

        //select class for error
        let errorClasses: [NSNetworkError.Type] = [
            NSNoNetworkError.self
        ]

        let selfType_ = { () -> NSNetworkError.Type? in

            return errorClasses.indexOf { return $0.isMineNSNetworkError(nativeError) }.flatMap { errorClasses[$0] }
        }()

        if let selfType_ = selfType_ {
            selfType = selfType_
        } else {
            selfType = NSNetworkError.self
        }

        return selfType.init(context: context, nativeError: nativeError)
    }

    class func isMineNSNetworkError(error: NSError) -> Bool {
        return false
    }

    public override func copyWithZone(zone: NSZone) -> AnyObject {

        return self.dynamicType.init(context: context, nativeError: nativeError)
    }

    public override var errorLogDescription: String {

        return "\(self.dynamicType) : \(localizedDescription) nativeError:\(nativeError) context:\(context)"
    }
}
