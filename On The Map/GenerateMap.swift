//
//  GenerateMap.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/12/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation




func generateMap() {
    
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.pinColor = .Red
        pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)

    
}