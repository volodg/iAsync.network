//
//  String+XQueryComponents.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 13.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

public extension String {

    func stringByDecodingURLQueryComponents() -> String? {

        return stringByRemovingPercentEncoding
    }

    func stringByEncodingURLQueryComponents() -> String {

        //old one variant - " <>#%'\";?:@&=+$/,{}|\\^~[]`-*!()"
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
        let charactersToLeaveUnescaped = "[]." as CFStringRef

        let str = self as NSString

        let result = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            str as CFString,
            charactersToLeaveUnescaped,
            charactersToBeEscaped,
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) as NSString

        return result as String
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
