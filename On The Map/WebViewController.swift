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
    
    @IBAction func doneWithWebView(_ sender: AnyObject) {
        cancelWebView()
    }
    
    var urlRequest: String? = nil
    var webViewDidLoadCompletionHandler: ((_ success: Bool, _ errorString: String?) -> Void)? = nil
    
    func cancelWebView() {
        failedMessage.isHidden = true
        failedMessage.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        failedMessage.isHidden = false
        failedMessage.text = "Could not find the page you are looking for: \(self.urlRequest!)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.delegate = self
        self.failedMessage.isHidden = true
        if let url = URL(string: urlRequest!) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        } 
    }
}
