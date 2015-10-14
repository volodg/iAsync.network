//
//  FormDataBuilder.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

final public class FormDataBuilder : NSObject {
    
    public static func formDataForParams(boundary: String, dictWithParam: [String:String], ending: String = "--") -> NSData
    {
        let result = NSMutableData()
        
        for (key, value) in dictWithParam {
            
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
        dataFilePath : String,
        boundary     : String,
        name         : String,
        fileName     : String,
        contentType  : String?,
        dictWithParam: [String:String]?) -> String
    {
        var filePath = NSUUID().UUIDString
        
        filePath = String.cachesPathByAppendingPathComponent(filePath)
        let filePathPtr = filePath.cStringUsingEncoding(NSUTF8StringEncoding)
        
        let file = fopen(filePathPtr!, "w+")
        
        autoreleasepool {
            
            let boundaryStr  = "--\(boundary)\r\n"
            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
            fwrite(boundaryData.bytes, 1, boundaryData.length, file)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]
        
        autoreleasepool {
            
            let contentDisposition = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
            let contentDispositionData = contentDisposition.dataUsingEncoding(NSUTF8StringEncoding)!
            fwrite(contentDispositionData.bytes, 1, contentDispositionData.length, file)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]]
        
        autoreleasepool {
            let contentTypeStr  = contentType ?? "application/octet-stream"
            let contentTypeSrv  = "Content-Type: \(contentTypeStr)\r\n\r\n"
            let contentTypeData = contentTypeSrv.dataUsingEncoding(NSUTF8StringEncoding)!
            fwrite(contentTypeData.bytes, 1, contentTypeData.length, file)
        }
        //[result appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]]
        
        autoreleasepool {
            
            let uploadDataFile = fopen(dataFilePath.cStringUsingEncoding(NSUTF8StringEncoding)!, "r")
            
            let bufferLength = 10*1024
            var array = Array<UInt8>(count: Int(bufferLength), repeatedValue: 0)
            
            array.withUnsafeMutableBufferPointer({ (inout cArray: UnsafeMutableBufferPointer<UInt8>) -> () in
                
                let readFileChunk = { () -> Int in
                    return fread(cArray.baseAddress, 1, bufferLength, uploadDataFile)
                }
                var readBytes = readFileChunk()
                while readBytes != 0 {
                    
                    fwrite(cArray.baseAddress, 1, readBytes, file)
                    readBytes = readFileChunk()
                }
            })
            
            fclose(uploadDataFile)
        }
        //[result appendData:data]
        
        autoreleasepool {
            
            let boundaryStr  = "\r\n--\(boundary)\r\n"
            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
            fwrite(boundaryData.bytes, 1, boundaryData.length, file)
        }
        //[result appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]
        
        if let dictWithParam = dictWithParam {
        
            autoreleasepool {
            
                let formData = self.formDataForParams(boundary, dictWithParam: dictWithParam, ending: "\r\n")
                fwrite(formData.bytes, 1, formData.length, file)
            }
        }
        
        fclose(file)
        
        return filePath
    }
}
