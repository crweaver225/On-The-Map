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
    
    @IBAction func refresh(_ sender: AnyObject) {
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
    
    @IBAction func postLocation(_ sender: AnyObject) {
        let postLocationController = self.storyboard!.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
        self.present(postLocationController, animated: true, completion: nil)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let webDetailController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webDetailController.urlRequest = view.annotation?.subtitle!
            self.present(webDetailController, animated: true, completion: nil)
        }
    }
    
    func displayAlert() {
        let downloadAlert = UIAlertController(title: "Warning", message: "We were unable to retrieve information from the server at this time", preferredStyle: UIAlertControllerStyle.alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        self.present(downloadAlert, animated: true, completion: nil)
    }

    @IBAction func logOut(_ sender: AnyObject) {
        theStudent.studentInformation.removeAll()
        theStudent.accountInfo.removeAll()
        theStudent.udacityInfo.removeAll()
        var controller: LoginViewController
        controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(controller, animated: true, completion: nil)
    }
    
     override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        self.theData.removeAll()
        self.annotations.removeAll()
        self.theData = theStudent.studentInformation
        mapView.delegate = self
        generateMap()
    }
}
