//
//  NSNetworkError.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

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
        
        var selfType: NSNetworkError.Type!
        
        //select class for error
        let errorClasses: [NSNetworkError.Type] =
        [
            NSNoInternetNetworkError.self
        ]
        
        selfType = { () -> NSNetworkError.Type! in
            
            if let index = errorClasses.indexOf({ return $0.isMineNSNetworkError(nativeError) }) {
                return errorClasses[index]
            }
            return nil
        }()

        if selfType == nil {
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