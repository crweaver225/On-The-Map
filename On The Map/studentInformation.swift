//
//  studentInformation.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/12/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

class theStudent {
    
    static var studentInformation = [Student]()
    static var accountInfo: [String: AnyObject] = [:]
    static var udacityInfo: [String:AnyObject] = [:]
    
    struct Student {
        var firstName: String
        var lastName: String
        var mediaURL: String
        var latitude: Double
        var longitude: Double
        
        init(dictionary:[String: AnyObject]) {
            self.firstName = (dictionary["firstName"] as? String)!
            self.lastName = (dictionary["lastName"] as? String)!
            self.mediaURL = (dictionary["mediaURL"] as? String)!
            self.latitude = (dictionary["latitude"] as? Double)!
            self.longitude = (dictionary["longitude"] as? Double)!
        }
    }
    
}
