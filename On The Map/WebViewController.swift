//
//  WebViewController.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/8/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var failedMessage: UITextView!
    
    @IBAction func doneWithWebView(sender: AnyObject) {
        cancelWebView()
    }
    
    var urlRequest: String? = nil
    var webViewDidLoadCompletionHandler: ((success: Bool, errorString: String?) -> Void)? = nil
    
    func cancelWebView() {
        failedMessage.hidden = true
        failedMessage.text = ""
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        failedMessage.hidden = false
        failedMessage.text = "Could not find the page you are looking for: \(self.urlRequest!)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.delegate = self
        self.failedMessage.hidden = true
        if let url = NSURL(string: urlRequest!) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        } 
    }
}