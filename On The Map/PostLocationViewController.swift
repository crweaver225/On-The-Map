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
    
    @IBAction func returnButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func post(_ sender: AnyObject) {
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
                var overrideAlert = UIAlertController(title: "Warning", message: "You have already posted your location. Do you wish to override?", preferredStyle: UIAlertControllerStyle.alert)
                overrideAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    Parse.sharedInstance().overridePost(self.locationTextField.text!, long: self.longitude, lat: self.latitude, mediaURL: self.mediaTextField.text!) { (success, error) in
                        performUIUpdatesOnMain {
                            guard (error == nil) else {
                                let postAlert = UIAlertController(title: "Warning", message: "We were unable to post your location to the server at this time", preferredStyle: UIAlertControllerStyle.alert)
                                postAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                                }))
                                self.present(postAlert, animated: true, completion: nil)
                                return

                            }
                        }
                        Parse.sharedInstance().getStudentLocations() { (success, error) in
                            performUIUpdatesOnMain {
                                var controller: UITabBarController
                                controller = self.storyboard!.instantiateViewController(withIdentifier: "UITabBarController") as! UITabBarController
                                self.present(controller, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                overrideAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                self.present(overrideAlert, animated: true, completion: nil)
            } else {
                Parse.sharedInstance().postStudentLocation(self.locationTextField.text!, long: self.longitude, lat: self.latitude, mediaURL: self.mediaTextField.text!) { (success, error) in
                    performUIUpdatesOnMain {
                        guard (error == nil) else {
                            self.displayAlert("We were unable to post your location to the server at this time")
                            return
                        }
                        var controller: UITabBarController
                        controller = self.storyboard!.instantiateViewController(withIdentifier: "UITabBarController") as! UITabBarController
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

    @IBAction func findButton(_ sender: AnyObject) {
        activityIndicator.isHidden = false
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
                self.activityIndicator.isHidden = true
                self.locationTextField.isHidden = true
                self.topView.isHidden = true
                self.findOnMapButton.isHidden = true
                self.mediaTextField.isHidden = false
                self.postButton.isHidden = false
                let geoLocation: [CLPlacemark] = coordinates!
                self.latitude = (geoLocation[0].location?.coordinate.latitude)!
                self.longitude = (geoLocation[0].location?.coordinate.longitude)!
                self.generateMap(self.latitude, longitude: self.longitude)
                }
            }
        }

    func generateMap(_ latitude: Double, longitude: Double) {
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func displayAlert(_ text: String) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        let downloadAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        self.present(downloadAlert, animated: true, completion: nil)
    }

    
    override var shouldAutorotate : Bool{
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationTextField.delegate = self
        self.mediaTextField.delegate = self
        mapView.delegate = self
        self.postButton.isHidden = true
        self.mediaTextField.isHidden = true
        self.activityIndicator.isHidden = true
    }
}
