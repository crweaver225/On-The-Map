//
//  Constant.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


final class Parse {
    
    var session = URLSession.shared
    
    struct Constants {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    class func sharedInstance() -> Parse {
        struct Singleton {
            static var sharedInstance = Parse()
        }
        return Singleton.sharedInstance
    }
    
}
