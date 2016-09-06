//
//  Constants.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/4/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

final class Udacity {
    
    var session = NSURLSession.sharedSession()
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let AuthenticatePost = "/session"
        static let GetData = "/users/"
    }

    class func sharedInstance() -> Udacity {
        struct Singleton {
            static var sharedInstance = Udacity()
        }
        return Singleton.sharedInstance
    }
}