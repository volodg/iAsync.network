//
//  FormDataBuilder.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

final public class FormDataBuilder {

    public static func formDataForParams(boundary: String, params: [String:String], ending: String = "--") -> NSData {

        let result = NSMutableData()

        for (key, value) in params {

            autoreleasepool {

                autoreleasepool {
                    let boundaryStr  = "--\(boundary)\r\n"
                    let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
                    result.appendData(boundaryData)
                }
                //[self appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]]

                autoreleasepool {
                    let contentDisposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                    let contentDispositionData = contentDisposition.dataUsingEncoding(NSUTF8StringEncoding)!
                    result.appendData(contentDispositionData)
                }
                //[self appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]]

                autoreleasepool {
                    let valueData = "\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
                    result.appendData(valueData)
                }
                //[self appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]]
            }
        }

        autoreleasepool {
            let boundaryStr  = "--\(boundary)\(ending)"
            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
            result.appendData(boundaryData)
        }
        //[self appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]]

        return result.copy() as! NSData
    }

    public static func tmpFileForUploadStreamWithDataForFilePath(
        dataFilePath: String,
        boundary    : String,
        name        : String,
        fileName    : String,
        contentType : String?,
        params      : [String:String]?) throws -> String {

        var filePath = NSUUID().UUIDString

        filePath = String.cachesPathByAppendingPathComponent(filePath)

        NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)

        guard let file = NSFileHandle(forWritingAtPath: filePath) else {

            throw UtilsError(description: "can not create NSFileHandle with path: \(filePath)")
        }

        autoreleasepool {

            let boundaryStr  = "--\(boundary)\r\n"
            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
            file.writeData(boundaryData)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]

        autoreleasepool {

            let contentDisposition = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
            let contentDispositionData = contentDisposition.dataUsingEncoding(NSUTF8StringEncoding)!
            file.writeData(contentDispositionData)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]]

        autoreleasepool {
            let contentTypeStr  = contentType ?? "application/octet-stream"
            let contentTypeSrv  = "Content-Type: \(contentTypeStr)\r\n\r\n"
            let contentTypeData = contentTypeSrv.dataUsingEncoding(NSUTF8StringEncoding)!
            file.writeData(contentTypeData)
        }
        //[result appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]]

        autoreleasepool {

            let uploadDataFile = NSFileHandle(forReadingAtPath: dataFilePath)!

            let chunkSize = 10*1024

            var readBytes = uploadDataFile.readDataOfLength(chunkSize)

            while readBytes.length != 0 {

                file.writeData(readBytes)
                readBytes = uploadDataFile.readDataOfLength(chunkSize)
            }

            uploadDataFile.closeFile()
        }
        //[result appendData:data]

        autoreleasepool {

            let boundaryStr  = "\r\n--\(boundary)--\r\n"
            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
            file.writeData(boundaryData)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]

        if let params = params {

            autoreleasepool {

                let formData = self.formDataForParams(boundary, params: params, ending: "\r\n")
                file.writeData(formData)
            }
        }

        file.closeFile()

        return filePath
    }
}
