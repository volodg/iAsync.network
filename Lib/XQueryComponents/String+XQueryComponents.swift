//
//  String+XQueryComponents.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 13.10.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

extension String {

    public static var digits: String {
        return "0123456789"
    }

    public static var lowercase: String {
        return "abcdefghijklmnopqrstuvwxyz"
    }

    public static var uppercase: String {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }

    public static var letters: String {
        return lowercase + uppercase
    }

    public static var uriQueryValueAllowed: String {
        return "!$\'()*+,-.;?@_~" + letters + digits
    }
}

public extension String {

    func stringByDecodingURLQueryComponents() -> String? {

        return stringByRemovingPercentEncoding
    }

    func stringByEncodingURLQueryComponents() -> String {

        let query  = NSCharacterSet(charactersInString: String.uriQueryValueAllowed)
        let result = stringByAddingPercentEncodingWithAllowedCharacters(query)
        return result ?? self
    }

    func dictionaryFromQueryComponents() -> [String:[String]] {

        var result = [String:[String]]()

        for keyValuePairString in componentsSeparatedByString("&") {

            let keyValuePairArray = keyValuePairString.componentsSeparatedByString("=") as [String]

            // Verify that there is at least one key, and at least one value.  Ignore extra = signs
            if keyValuePairArray.count < 2 {
                continue
            }

            let decodedKey = keyValuePairArray[0]
            guard let key = decodedKey.stringByDecodingURLQueryComponents() else {

                iAsync_utils_logger.logError("can not decode key: \(decodedKey)", context: #function)
                continue
            }

            let decodedVal = keyValuePairArray[1]
            guard let value = decodedVal.stringByDecodingURLQueryComponents() else {

                iAsync_utils_logger.logError("can not decode val: \(decodedVal)", context: #function)
                continue
            }

            var results = result[key] ?? [String]() // URL spec says that multiple values are allowed per key

            results.append(value)

            result[key] = results
        }

        return result
    }
}
