//
//  WebViewController.swift
//  PinPost
//
//  Created by Jason Cheng on 7/10/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let baseURL = InstagramAPI.sharedInstance.authBaseURL
        let clientId = InstagramAPI.sharedInstance.clientId
        let redirectUrl = InstagramAPI.sharedInstance.redirectUrl
        
        // Build the request string
        var requestString:String = "\(baseURL)?client_id=\(clientId)&redirect_uri=\(redirectUrl)&response_type=token"
        
        // Set delegate of UIWebViewDelegate
        webView.delegate = self
        
        // Load the authentication page for instagram
        if let url = NSURL(string: requestString) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
            // Check for #access_token in the request.url
            // If access token is there dismiss the controller view
        if let returnURL = request.URL?.absoluteString{
            if InstagramAPI.sharedInstance.isAccessTokenValid(returnURL){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
