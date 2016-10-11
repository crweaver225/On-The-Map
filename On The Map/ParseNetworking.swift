//
//  ParseNetworking.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


extension Parse {
    
    func taskForPostMethod(_ jsonBody: String, requestType: String, url: String, completionHandlerForPost: @escaping (_ results: AnyObject?, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = requestType
        request.addValue(Parse.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parse.Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        processRequest(request) { (result, error) in
            if error == nil {
                completionHandlerForPost(result, nil)
            } else {
                completionHandlerForPost(nil, error)
            }
        }
    }
    
    func taskForGetMethod(_ method: String, completionHandlerForGet: @escaping (_ results: AnyObject?, _ error: String?) -> Void) {
               
        let request = NSMutableURLRequest(url: URL(string: method)!)
        
        request.addValue(Parse.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parse.Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        processRequest(request) { (result, error) in
            if error == nil {
                completionHandlerForGet(result, nil)
            } else {
                completionHandlerForGet(nil, error)
            }
        }
    }
    
    func processRequest(_ request: AnyObject, completionHandlerForProcessing: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        
        let task = session.dataTask(with: request as! URLRequest, completionHandler: { (data, response, error) in
            
            func sendError(_ error: String) {
                completionHandlerForProcessing(nil, error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your Udacity post request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
            } catch {
                sendError("parsing Udacity Post method failed")
            }
            completionHandlerForProcessing(parsedResult, nil)
        }) 
        task.resume()
    }
}
