//
//  UdacityNetworking.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/4/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


extension Udacity {
    
    
    func taskForGetMethod(method: String, completionHandlerForGet: (results: AnyObject!, error: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: self.udacityURLFromParameters(method))
        
        processRequest(request) { (result, error) in
            if error == nil {
                completionHandlerForGet(results: result, error: nil)
            } else {
                completionHandlerForGet(results: nil, error: error)
            }
        }
    }
    
    func taskForPostMethod(method: String, methodType: String, cookie: NSHTTPCookie?, jsonBody: String?, completionHandlerForPOST: (result: AnyObject!, error: String?) -> Void)   {
        
        let request = NSMutableURLRequest(URL: self.udacityURLFromParameters(method))
        
        request.HTTPMethod = methodType
        
        if let jsonBody = jsonBody {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
       if let cookie = cookie {
            request.setValue(cookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        processRequest(request) { (result, error) in

            if error == nil {
                completionHandlerForPOST(result: result, error: nil)
            } else {
                completionHandlerForPOST(result: nil, error: error)
            }
        }
    }
    
    
    func processRequest(request: AnyObject, completionHandlerForProcessing: (result: AnyObject!, error: String?) -> Void) {
        
        let task = session.dataTaskWithRequest(request as! NSURLRequest) { (data, response, error) in
            
            func sendError(error: AnyObject) {
                completionHandlerForProcessing(result: nil, error: error as! String)
            }

            guard (error == nil) else {
                sendError((error?.localizedDescription)!)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your Udacity post request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                sendError("parsing Udacity Post method failed")
            }
            completionHandlerForProcessing(result: parsedResult, error: nil)
        }
        task.resume()
    }
}