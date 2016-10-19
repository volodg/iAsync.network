//
//  FormDataBuilder.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import iAsync_utils

final public class FormDataBuilder {

    public static func formDataFor(boundary: String, params: [String:String], ending: String = "--") -> Data {

        let result = NSMutableData()

        for (key, value) in params {

            autoreleasepool {

                autoreleasepool {
                    let boundaryStr  = "--\(boundary)\r\n"
                    let boundaryData = boundaryStr.data(using: String.Encoding.utf8)!
                    result.append(boundaryData)
                }
                //[self appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]]

                autoreleasepool {
                    let contentDisposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                    let contentDispositionData = contentDisposition.data(using: String.Encoding.utf8)!
                    result.append(contentDispositionData)
                }
                //[self appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]]

                autoreleasepool {
                    let valueData = "\(value)\r\n".data(using: String.Encoding.utf8)!
                    result.append(valueData)
                }
                //[self appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]]
            }
        }

        autoreleasepool {
            let boundaryStr  = "--\(boundary)\(ending)"
            let boundaryData = boundaryStr.data(using: String.Encoding.utf8)!
            result.append(boundaryData)
        }
        //[self appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]]

        return result.copy() as! Data
    }

    public static func tmpFileForUploadStreamWithDataForFilePath(
        _ dataFilePath: FilePath,
        boundary    : String,
        name        : String,
        fileName    : String,
        contentType : String?,
        params      : [String:String]?) throws -> URL {

        var fileName = UUID().uuidString

        let filePath = URL.cachesPathByAppending(pathComponent: fileName)

        FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)

        guard let file = try? FileHandle(forWritingTo: filePath) else {

            throw UtilsError(description: "can not create NSFileHandle with path: \(filePath)")
        }

        autoreleasepool {

            let boundaryStr  = "--\(boundary)\r\n"
            let boundaryData = boundaryStr.data(using: String.Encoding.utf8)!
            file.write(boundaryData)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]

        autoreleasepool {

            let contentDisposition = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
            let contentDispositionData = contentDisposition.data(using: String.Encoding.utf8)!
            file.write(contentDispositionData)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]]

        autoreleasepool {
            let contentTypeStr  = contentType ?? "application/octet-stream"
            let contentTypeSrv  = "Content-Type: \(contentTypeStr)\r\n\r\n"
            let contentTypeData = contentTypeSrv.data(using: String.Encoding.utf8)!
            file.write(contentTypeData)
        }
        //[result appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]]

        try autoreleasepool {

            guard let uploadDataFile = try? FileHandle(forReadingFrom: dataFilePath.filePath) else {

                throw UtilsError(description: "can not create NSFileHandle with path: \(dataFilePath)")
            }

            let chunkSize = 10*1024

            var readBytes = uploadDataFile.readData(ofLength: chunkSize)

            while readBytes.count != 0 {

                file.write(readBytes)
                readBytes = uploadDataFile.readData(ofLength: chunkSize)
            }

            uploadDataFile.closeFile()
        }
        //[result appendData:data]

        autoreleasepool {

            let boundaryStr  = "\r\n--\(boundary)--\r\n"
            let boundaryData = boundaryStr.data(using: String.Encoding.utf8)!
            file.write(boundaryData)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]

        if let params = params {

            autoreleasepool {

                let formData = self.formDataFor(boundary: boundary, params: params, ending: "\r\n")
                file.write(formData)
            }
        }

        file.closeFile()

        return filePath
    }
}
