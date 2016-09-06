//
//  MapViewController.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/8/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func refresh(sender: AnyObject) {
        mapView.removeAnnotations(self.annotations)
        self.theData.removeAll()
        self.annotations.removeAll()
        Parse.sharedInstance().getStudentLocations() { (success, error) in
            self.theData = theStudent.studentInformation
            performUIUpdatesOnMain {
                guard (error == nil) else {
                    self.displayAlert()
                    return
                }
                self.viewWillAppear(true)
            }
        }
    }
    
    @IBAction func postLocation(sender: AnyObject) {
        let postLocationController = self.storyboard!.instantiateViewControllerWithIdentifier("PostLocationViewController") as! PostLocationViewController
        self.presentViewController(postLocationController, animated: true, completion: nil)
    }
    
    var theData: [theStudent.Student] = []
    var annotations = [MKPointAnnotation]()
    
    func generateMap() {
        for location in theData {
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let webDetailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            webDetailController.urlRequest = view.annotation?.subtitle!
            self.presentViewController(webDetailController, animated: true, completion: nil)
        }
    }
    
    func displayAlert() {
        let downloadAlert = UIAlertController(title: "Warning", message: "We were unable to retrieve information from the server at this time", preferredStyle: UIAlertControllerStyle.Alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        self.presentViewController(downloadAlert, animated: true, completion: nil)
    }

    @IBAction func logOut(sender: AnyObject) {
        theStudent.studentInformation.removeAll()
        theStudent.accountInfo.removeAll()
        theStudent.udacityInfo.removeAll()
        var controller: LoginViewController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
     override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.theData.removeAll()
        self.annotations.removeAll()
        self.theData = theStudent.studentInformation
        mapView.delegate = self
        generateMap()
    }
}