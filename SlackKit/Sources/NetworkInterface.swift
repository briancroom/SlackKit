//
// NetworkInterface.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import HTTPSClient
import Jay

internal struct NetworkInterface {
    
    private let apiUrl = "https://slack.com/api/"
    private let client: HTTPSClient.Client?
    
    init() {
        do {
            self.client = try Client(uri: URI("https://slack.com"))
        } catch {
            self.client = nil
        }
    }
    
    internal func request(endpoint: SlackAPIEndpoint, token: String, parameters: [String: Any]?, successClosure: ([String: Any])->Void, errorClosure: (SlackError)->Void) {
        var requestString = "\(apiUrl)\(endpoint.rawValue)?token=\(token)"
        if let params = parameters {
            requestString += requestStringFromParameters(parameters: params)
        }

        print("** In request. String: \(requestString)")
        
        do {
            var response: Response?
            print("** Trying client")
            response = try client?.get(requestString)
            print("** Loading data")
            let data = try response?.body.becomeBuffer()
            print("** Got data: \(data)")
            if let data = data {
                let json = try Jay().jsonFromData(data.bytes)
                if let result = json as? [String: Any] {
                    if (result["ok"] as? Bool == true) {
                        successClosure(result)
                    } else {
                        if let errorString = result["error"] as? String {
                            throw ErrorDispatcher.dispatch(error: errorString)
                        } else {
                            throw SlackError.UnknownError
                        }
                    }
                }
            }
        } catch let error {
            print("** Caught request error \(error)")
            if let slackError = error as? SlackError {
                errorClosure(slackError)
            } else {
                errorClosure(SlackError.UnknownError)
            }
        }
    }
    
    //TODO: Currently Unsupported
    /*internal func uploadRequest(token: String, data: NSData, parameters: [String: Any]?, successClosure: ([String: Any])->Void, errorClosure: (SlackError)->Void) {
        var requestString = "\(apiUrl)\(SlackAPIEndpoint.FilesUpload.rawValue)?token=\(token)"
        if let params = parameters {
            requestString = requestString + requestStringFromParameters(parameters: params)
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: requestString)!)
        request.httpMethod = "POST"
        let boundaryConstant = randomBoundary()
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        let boundaryStart = "--\(boundaryConstant)\r\n"
        let boundaryEnd = "--\(boundaryConstant)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"\(parameters!["filename"])\"\r\n"
        let contentTypeString = "Content-Type: \(parameters!["filetype"])\r\n\r\n"

        let requestBodyData : NSMutableData = NSMutableData()
        requestBodyData.append(boundaryStart.data(using: NSUTF8StringEncoding)!)
        requestBodyData.append(contentDispositionString.data(using: NSUTF8StringEncoding)!)
        requestBodyData.append(contentTypeString.data(using: NSUTF8StringEncoding)!)
        requestBodyData.append(data)
        requestBodyData.append("\r\n".data(using: NSUTF8StringEncoding)!)
        requestBodyData.append(boundaryEnd.data(using: NSUTF8StringEncoding)!)
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBodyData

        NSURLSession.shared().dataTask(with: request) {
            (data, response, internalError) -> Void in
            guard let data = data else {
                return
            }
            do {
                let result = try NSJSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if (result["ok"] as! Bool == true) {
                    successClosure(result)
                } else {
                    if let errorString = result["error"] as? String {
                        throw ErrorDispatcher.dispatch(error: errorString)
                    } else {
                        throw SlackError.UnknownError
                    }
                }
            } catch let error {
                if let slackError = error as? SlackError {
                    errorClosure(slackError)
                } else {
                    errorClosure(SlackError.UnknownError)
                }
            }
            }.resume()
    }
    
    private func randomBoundary() -> String {
        return String(format: "slackkit.boundary.%08x%08x", arc4random(), arc4random())
    }*/
    
    private func requestStringFromParameters(parameters: [String: Any]) -> String {
        var requestString = ""
        for key in parameters.keys {
            if let value = parameters[key] as? String {
                do {
                    let encodedValue = try value.percentEncoded(allowing: .uriQueryAllowed)
                    requestString += "&\(key)=\(encodedValue)"
                } catch _ {
                    print("Error encoding parameters.")
                }
            } else if let value = parameters[key] as? Int {
                requestString += "&\(key)=\(value)"
            } else if let value = parameters[key] as? Bool {
                requestString += "&\(key)=\(value)"
            }
        }
        
        return requestString
    }
    
}
