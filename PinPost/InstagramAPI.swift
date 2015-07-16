//
//  InstagramAPI.swift
//  PinPost
//
//  Created by Jason Cheng on 7/10/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class InstagramAPI {
    static let sharedInstance = InstagramAPI()
    
    public let authBaseURL:String = "https://instagram.com/oauth/authorize/"
    public let clientId:String = "f00fa0e772dc400e85c5debc5c063891"
    public let redirectUrl:String = "http://www.google.com"
    public var accessToken:String?
    
    private let baseURL:String = "https://api.instagram.com/v1/"
    
    // Check if access token is valid
    public func isAccessTokenValid(returnURL:String) -> Bool {
        var retVal = false
        
        if let range = returnURL.rangeOfString("#access_token="){
            println("getting access token")
            var index = range.endIndex
            self.accessToken = returnURL.substringFromIndex(index)
            println(self.accessToken)
            retVal = true
        }

        return retVal
    }
    
    // Check if access token is valid. If not controller class will need to 
    // ask for user authentication again through the webview
    public func isTokenValid() -> Bool {
        var retVal = false
        
        if let token = self.accessToken {
            retVal = true
        }
        
        return retVal
    }
    
    // /users/self/feed
    // either with our without next_max_id
    public func getUserFeed(delegate: InstagramAPIDelegate, nextMaxId: String? = ""){
        var parameters:[String: String] = ["access_token": accessToken!]
        if nextMaxId != "" {
            parameters["max_id"] = nextMaxId
        }
        
        get("users/self/feed", parameters: parameters, callBack: {
            (result:AnyObject) -> Void in
            
            if nextMaxId != "" {
                delegate.didReceivePaginatedFeed?(result)
            }
            else {
                delegate.didReceiveFeed?(result)
            }
        })
    }
    
    // /media/media-id
    // Get specific media with mediaId
    public func getMedia(delegate: InstagramAPIDelegate, mediaId: String){
        
        get("media/\(mediaId)", parameters: ["access_token": accessToken!], callBack: {
            (result:AnyObject) -> Void in
            
            delegate.didReceiveMediaWithMediaId?(result)
        })
    }
    
    private func get(path: String, parameters: [String: String]? = nil, callBack: ((AnyObject) -> Void)?){
        let url = "\(baseURL)\(path)"
        NSLog("Preparing for GET request to \(url)")
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseString{ (req, res, data, error) in
                
                         }
            .responseJSON{ (req, res, json, error) in
                // Check for return error. Log it if that's the case
                if error != nil {
                    NSLog("GET Error: \(error)")
                }
                else {
                    
                    // Call the call back handler and return the returned data
                    if let handler = callBack {
                        handler(json!)
                    }
                }
            }
    }
}

@objc public protocol InstagramAPIDelegate {
    // users/self/feed
    optional func didReceiveFeed(result: AnyObject) //result: JSON string
    
    // users/self/feed w max_id
    optional func didReceivePaginatedFeed(result: AnyObject) //result: JSON string
    
    // media/media-id
    optional func didReceiveMediaWithMediaId(result: AnyObject) //result: JSON string
}