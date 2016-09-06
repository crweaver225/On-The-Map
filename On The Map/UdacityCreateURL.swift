//
//  CreateURL.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/4/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

extension Udacity {
    
 func udacityURLFromParameters(parameters: String) -> NSURL {
    
    let components = NSURLComponents()
    components.scheme = Udacity.Constants.ApiScheme
    components.host = Udacity.Constants.ApiHost
    components.path = Udacity.Constants.ApiPath + parameters
    return components.URL!
    }
}