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
   
    @IBAction func Post(sender: AnyObject) {
        let postLocationController = self.storyboard!.instantiateViewControllerWithIdentifier("PostLocationViewController") as! PostLocationViewController
        self.presentViewController(postLocationController, animated: true, completion: nil)
    }
    
    @IBAction func refresh(sender: AnyObject) {
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("individual")!
        let row = theData[indexPath.row]
        cell.textLabel!.text = "\(row.firstName) \(row.lastName)"
        cell.imageView?.image = chat
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = theData[indexPath.row]
        let webDetailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        webDetailController.urlRequest = row.mediaURL
        self.presentViewController(webDetailController, animated: true, completion: nil)
    }
    
    func displayAlert() {
        let downloadAlert = UIAlertController(title: "Warning", message: "We were unable to retrieve information from the server at this time", preferredStyle: UIAlertControllerStyle.Alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        self.presentViewController(downloadAlert, animated: true, completion: nil)
        alreadyDisplayed = true
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.theData.removeAll()
        self.theData = theStudent.studentInformation
        self.tableView.reloadData()
        if self.theData.count == 0 && alreadyDisplayed == false {
            displayAlert()
        }
    }
    
    @IBAction func logOut(sender: AnyObject) {
        theStudent.studentInformation.removeAll()
        theStudent.accountInfo.removeAll()
        theStudent.udacityInfo.removeAll()
        var controller: LoginViewController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}