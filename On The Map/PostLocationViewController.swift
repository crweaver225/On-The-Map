//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/8/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class locateLocation: CLGeocoder {
    var location: CLLocation?
}

class PostLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var mediaTextField: UITextField!
    @IBOutlet weak var topView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var annotations = [MKPointAnnotation]()
    
    @IBAction func returnButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func post(sender: AnyObject) {
        if self.mediaTextField.text!.isEmpty {
            displayAlert("You have not entered a media URL. YOu cannot make a post until you do so")
        } else {
            newfunc()
        }
    }
    
    func newfunc() {
        Parse.sharedInstance().searchPost() { (success, error) in performUIUpdatesOnMain {
            guard (error == nil) else {
                self.displayAlert("We were unable to post your location to the server at this time")
                return
            }
            if success {
                var overrideAlert = UIAlertController(title: "Warning", message: "You have already posted your location. Do you wish to override?", preferredStyle: UIAlertControllerStyle.Alert)
                overrideAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    Parse.sharedInstance().overridePost(self.locationTextField.text!, long: self.longitude, lat: self.latitude, mediaURL: self.mediaTextField.text!) { (success, error) in
                        performUIUpdatesOnMain {
                            guard (error == nil) else {
                                let postAlert = UIAlertController(title: "Warning", message: "We were unable to post your location to the server at this time", preferredStyle: UIAlertControllerStyle.Alert)
                                postAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
                                }))
                                self.presentViewController(postAlert, animated: true, completion: nil)
                                return

                            }
                        }
                        Parse.sharedInstance().getStudentLocations() { (success, error) in
                            performUIUpdatesOnMain {
                                var controller: UITabBarController
                                controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
                                self.presentViewController(controller, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                overrideAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
                }))
                self.presentViewController(overrideAlert, animated: true, completion: nil)
            } else {
                Parse.sharedInstance().postStudentLocation(self.locationTextField.text!, long: self.longitude, lat: self.latitude, mediaURL: self.mediaTextField.text!) { (success, error) in
                    performUIUpdatesOnMain {
                        guard (error == nil) else {
                            self.displayAlert("We were unable to post your location to the server at this time")
                            return
                        }
                        var controller: UITabBarController
                        controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

    @IBAction func findButton(sender: AnyObject) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        let addressString = locationTextField.text!
        let findLocation = locateLocation()
        findLocation.geocodeAddressString(addressString) { (coordinates, error) in
            performUIUpdatesOnMain {
                guard (error == nil) else {
                    self.displayAlert("We were unable to find the entered address")
                    return
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.locationTextField.hidden = true
                self.topView.hidden = true
                self.findOnMapButton.hidden = true
                self.mediaTextField.hidden = false
                self.postButton.hidden = false
                let geoLocation: [CLPlacemark] = coordinates!
                self.latitude = (geoLocation[0].location?.coordinate.latitude)!
                self.longitude = (geoLocation[0].location?.coordinate.longitude)!
                self.generateMap(self.latitude, longitude: self.longitude)
                }
            }
        }

    func generateMap(latitude: Double, longitude: Double) {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        self.mapView.addAnnotations(annotations)
        let latDelta:CLLocationDegrees = 0.10
        let lonDelta:CLLocationDegrees = 0.10
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)
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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func displayAlert(text: String) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        let downloadAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        self.presentViewController(downloadAlert, animated: true, completion: nil)
    }

    
    override func shouldAutorotate() -> Bool{
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.locationTextField.delegate = self
        self.mediaTextField.delegate = self
        mapView.delegate = self
        self.postButton.hidden = true
        self.mediaTextField.hidden = true
        self.activityIndicator.hidden = true
    }
}