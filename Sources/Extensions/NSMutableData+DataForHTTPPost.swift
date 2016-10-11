//
//  NSMutableData+DataForHTTPPost.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSMutableData {

    //todo rename?
    static func dataForHTTPPostWithData(_ data: Data, fileName: String, parameterName: String, boundary: String) -> Self {

        let result = self.init(capacity: data.count + 512)!

        result.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        result.append("Content-Disposition: form-data; name=\"\(parameterName)\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)

        result.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)

        result.append(data)

        result.append("\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)!)

        return result
    }

    //todo rename?
    func appendHTTPParameters(_ parameters: NSDictionary, boundary: NSString) {

        parameters.enumerateKeysAndObjects(options: []) { (key: Any, value: Any, stop: UnsafeMutablePointer<ObjCBool>) in

            self.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            self.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            self.append("\(value)".data(using: String.Encoding.utf8)!)
            self.append("\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        }
    }
}
