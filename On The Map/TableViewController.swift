//
//  TableViewController.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/5/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit



class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var alreadyDisplayed: Bool = false
   
    @IBOutlet weak var tableView: UITableView!
    var theData: [theStudent.Student] = []
    let chat = UIImage(named: "mapBalloon")
   
    @IBAction func Post(_ sender: AnyObject) {
        let postLocationController = self.storyboard!.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
        self.present(postLocationController, animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
         Parse.sharedInstance().getStudentLocations() { (success, error) in
            performUIUpdatesOnMain {
                guard (error == nil) else {
                    self.displayAlert()
                    self.viewWillAppear(false)
                    return
                }
                self.viewWillAppear(false)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "individual")!
        let row = theData[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = "\(row.firstName) \(row.lastName)"
        cell.imageView?.image = chat
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = theData[(indexPath as NSIndexPath).row]
        let webDetailController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webDetailController.urlRequest = row.mediaURL
        self.present(webDetailController, animated: true, completion: nil)
    }
    
    func displayAlert() {
        let downloadAlert = UIAlertController(title: "Warning", message: "We were unable to retrieve information from the server at this time", preferredStyle: UIAlertControllerStyle.alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        self.present(downloadAlert, animated: true, completion: nil)
        alreadyDisplayed = true
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        self.theData.removeAll()
        self.theData = theStudent.studentInformation
        self.tableView.reloadData()
        if self.theData.count == 0 && alreadyDisplayed == false {
            displayAlert()
        }
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        theStudent.studentInformation.removeAll()
        theStudent.accountInfo.removeAll()
        theStudent.udacityInfo.removeAll()
        var controller: LoginViewController
        controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(controller, animated: true, completion: nil)
    }
}
