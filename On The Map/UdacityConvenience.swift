//
//  Networking.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/4/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


extension Udacity {
    
    
    func loginPostSession(_ userName:String, password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ error: String?) -> Void) {

        let method = Udacity.Constants.AuthenticatePost
        let methodType = "POST"
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        self.taskForPostMethod(method, methodType: methodType, cookie: nil, jsonBody: jsonBody) { (result, error)  in
            
            func failedLogin (_ errors: String)  {
                completionHandlerForLogin(false, errors)
            }
            guard (error == nil) else {
                failedLogin(error!)
                return 
            }
            guard let parsedDictionary = result?["account"] as? [String:AnyObject] else {
                failedLogin("Could not find acount")
                return
            }
            guard let key = parsedDictionary["key"] as? String else {
                failedLogin("no key")
                return
            }
            guard let registeredAccount = parsedDictionary["registered"] as? Int else {
                failedLogin("no registration")
                return
            }
            if registeredAccount != 1 {
                failedLogin("Incorrect username/password")
            } else {
                theStudent.accountInfo = result as! [String : AnyObject]
                let method = Udacity.Constants.GetData + String(key)
                self.taskForGetMethod(method) { (results, error) in

                    guard (error == nil) else {
                        failedLogin(error!)
                        return
                    }
                    guard let udInfo = results?["user"] as? [String:AnyObject] else {
                        failedLogin("Could not find user key")
                        return
                    }
                    theStudent.udacityInfo = udInfo
                    completionHandlerForLogin(true, nil)
                }
            }
        }
    }
    
    func logoutDeleteSession(_ completionHandlerForLogout: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let method = Udacity.Constants.AuthenticatePost
        let methodType = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        self.taskForPostMethod(method, methodType: methodType, cookie: xsrfCookie, jsonBody: nil) { (result, error)  in
        
            guard (error == nil) else {
                completionHandlerForLogout(false, error!)
                return
            }
            completionHandlerForLogout(true, nil)
        }
    }
}
