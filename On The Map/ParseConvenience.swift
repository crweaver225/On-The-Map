//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

var parseObjectID = ""


extension Parse {

    func overridePost(_ mapString: String, long: Double, lat: Double, mediaURL: String, completionHandlerForPost: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let uniqueKeys = theStudent.udacityInfo
        
        guard let lastName = uniqueKeys["last_name"] as? String else {
            print("No last name found")
            return
        }
        
        guard let uniqueKey = uniqueKeys["key"] as? String else {
            print("no unique key found")
            return
        }
        
        guard let firstName = uniqueKeys["nickname"] as? String else {
            print("no first name found")
            return
        }
        
        let url = "https://parse.udacity.com/parse/classes/StudentLocation/\(parseObjectID)"
        let requestType = "PUT"
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}"
        
        taskForPostMethod(jsonBody, requestType: requestType, url: url) { (result, error) in
            
            guard (error == nil) else {
                completionHandlerForPost(false, "could not find website")
                return
            }
            
            completionHandlerForPost(true, nil)
        }
    }
    
    func searchPost(_ completionHandlerForCheck: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let uniqueKeys = theStudent.udacityInfo
        guard let uniqueKey = uniqueKeys["key"] as? String else {
            print("no unique key found")
            return
        }
        
       let method = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        
         taskForGetMethod(method) { (result, error) in
            
            guard let result = result else {
                completionHandlerForCheck(false, "Could not find website")
                return
            }
            
            guard let options = result["results"] as? [[String: AnyObject]] else {
                print("try again")
                completionHandlerForCheck(false, nil)
                return
            }

            for items in options {
                guard let objectID = items["objectId"] as? String else {
                    completionHandlerForCheck(false, nil)
                    return
                }
                parseObjectID = objectID
            }
            
            if options.count > 0 {
                completionHandlerForCheck(true,  nil)
            } else {
                completionHandlerForCheck(false, nil)
            }
        }
    }
    
    func postStudentLocation(_ mapString: String, long: Double, lat: Double, mediaURL: String, completionHandlerForPost: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let requestType = "POST"
        let studentInfo = theStudent.udacityInfo
        
        guard let lastName = studentInfo["last_name"] as? String else {
            print("No last name found")
            return
        }
        
        guard let uniqueKey = studentInfo["key"] as? String else {
            print("no unique key found")
            return
        }
        
        guard let firstName = studentInfo["nickname"] as? String else {
            print("no first name")
            return
        }
        
        let url = "https://parse.udacity.com/parse/classes/StudentLocation"
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}"
        
        taskForPostMethod(jsonBody, requestType: requestType, url: url) { (result, error) in
            
                completionHandlerForPost(true, nil)
        }
    }

    func getStudentLocations(_ completionHandlerForLogin: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        theStudent.studentInformation.removeAll()
        
        let method = "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt"
        taskForGetMethod(method) { (result, error) in
            
            guard (error == nil) else {
                completionHandlerForLogin(false, error)
                return
            }
            
            guard let parsedResult = result?["results"] as? [[String:AnyObject]] else {
                print("parsed results show no key value of results")
                return
            }
            
            for entries in parsedResult {
                if let firstName = entries["firstName"] as? String {
                    if let lastName = entries["lastName"] as? String {
                        if let latCheck = entries["latitude"] as? Double {
                            if let longCheck = entries["longitude"] as? Double {
                                let entriess = theStudent.Student(dictionary: entries)
                                theStudent.studentInformation.append(entriess)
                            }
                        }
                    }
                }
            }
            
            completionHandlerForLogin(true, nil)
        }
    }
}
