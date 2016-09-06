//
//  ParseNetworking.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


extension Parse {
    
    func taskForPostMethod(jsonBody: String, requestType: String, url: String, completionHandlerForPost: (results: AnyObject!, error: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = requestType
        request.addValue(Parse.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parse.Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        processRequest(request) { (result, error) in
            if error == nil {
                completionHandlerForPost(results: result, error: nil)
            } else {
                completionHandlerForPost(results: nil, error: error)
            }
        }
    }
    
    func taskForGetMethod(method: String, completionHandlerForGet: (results: AnyObject!, error: String?) -> Void) {
               
        let request = NSMutableURLRequest(URL: NSURL(string: method)!)
        
        request.addValue(Parse.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parse.Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        processRequest(request) { (result, error) in
            if error == nil {
                completionHandlerForGet(results: result, error: nil)
            } else {
                completionHandlerForGet(results: nil, error: error)
            }
        }
    }
    
    func processRequest(request: AnyObject, completionHandlerForProcessing: (result: AnyObject!, error: String?) -> Void) {
        
        let task = session.dataTaskWithRequest(request as! NSURLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                completionHandlerForProcessing(result: nil, error: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
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
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("parsing Udacity Post method failed")
            }
            completionHandlerForProcessing(result: parsedResult, error: nil)
        }
        task.resume()
    }
}