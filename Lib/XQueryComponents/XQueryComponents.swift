//
//  NSDictionary+XQueryComponents.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private let queryComponentSeparator = "&"

public struct XQueryComponents {

    static public func toString(components: [String:[String]]) -> String {

        var result = [String]()

        for (key, values) in components {

            let encodedKey = key.stringByEncodingURLQueryComponents()

            if values.count > 0 {

                for value in values {

                    let encodedValue = value.stringByEncodingURLQueryComponents()
                    result.append("\(encodedKey)=\(encodedValue)")
                }
            } else {

                result.append("\(encodedKey)=")
            }
        }

        return result.joinWithSeparator(queryComponentSeparator)
    }

    static public func toData(components: [String:[String]]) -> NSData {

        return toString(components).dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
