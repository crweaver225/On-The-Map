//
//  UdacityNetworking.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/4/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


extension Udacity {
    
    
    func taskForGetMethod(_ method: String, completionHandlerForGet: @escaping (_ results: AnyObject?, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: self.udacityURLFromParameters(method))
        
        processRequest(request) { (result, error) in
            if error == nil {
                completionHandlerForGet(result, nil)
            } else {
                completionHandlerForGet(nil, error)
            }
        }
    }
    
    func taskForPostMethod(_ method: String, methodType: String, cookie: HTTPCookie?, jsonBody: String?, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: String?) -> Void)   {
        
        let request = NSMutableURLRequest(url: self.udacityURLFromParameters(method))
        
        request.httpMethod = methodType
        
        if let jsonBody = jsonBody {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        }
        
       if let cookie = cookie {
            request.setValue(cookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        processRequest(request) { (result, error) in

            if error == nil {
                completionHandlerForPOST(result, nil)
            } else {
                completionHandlerForPOST(nil, error)
            }
        }
    }
    
    
    func processRequest(_ request: AnyObject, completionHandlerForProcessing: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        
        let task = session.dataTask(with: request as! URLRequest, completionHandler: { (data, response, error) in
            
            func sendError(_ error: AnyObject) {
                completionHandlerForProcessing(nil, error as! String)
            }

            guard (error == nil) else {
                sendError((error?.localizedDescription)! as AnyObject)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your Udacity post request returned a status code other than 2xx!" as AnyObject)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!" as AnyObject)
                return
            }
            
            let myNSRange = NSRange(location: 5, length: data.count - 5)

          //  let newData = data.subdata(in: NSMakeRange(5, data.count - 5))
            
            let newData = data.subdata(in: myNSRange.toRange()!)
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject!
            } catch {
                sendError("parsing Udacity Post method failed" as AnyObject)
            }
            completionHandlerForProcessing(parsedResult, nil)
        }) 
        task.resume()
    }
}
