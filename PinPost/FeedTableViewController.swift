//
//  FeedTableViewController.swift
//  PinPost
//
//  Created by Jason Cheng on 7/10/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class FeedTableViewController: UITableViewController, InstagramAPIDelegate {
    
    private var userFeeds: Array<JSON> = [] // json array containing feed data
    private var paginationNextMaxId: String = "" // maxId used to get more feed
    private var indexPathToReturnTo: NSIndexPath? // the index the table list should return to 
                                                    // after loading more feeds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull To Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.whiteColor()
        refreshControl?.tintColor = UIColor.grayColor()
        refreshControl?.addTarget(self, action: "getFeed", forControlEvents:
            UIControlEvents.ValueChanged)
    }
    
    // Protocal for InstagramAPI when you try to get user feed
    func didReceiveFeed(result: AnyObject) {
        var json:JSON = JSON(result)

        // Set the result JSON data to userFeeds
        userFeeds = json["data"].arrayValue
        if let maxId = json["pagination"]["next_max_id"].string {
            paginationNextMaxId = maxId
        }

        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // Protocal for InstagramAPI when you get user feed with pagination info
    func didReceivePaginatedFeed(result: AnyObject) {
        var json:JSON = JSON(result)
    
        // Add the paginated data to the existing array data
        let earlierFeeds: Array<JSON> = json["data"].arrayValue
        userFeeds += earlierFeeds
    
        if let maxId = json["pagination"]["next_max_id"].string {
            paginationNextMaxId = maxId
        }
    
        // Reload the table view but need to scroll it back to the previous position
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(indexPathToReturnTo!,
            atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    func getFeed() {
        InstagramAPI.sharedInstance.getUserFeed(self)
    }
    
    func getFeedWithPagination() {
        InstagramAPI.sharedInstance.getUserFeed(self, nextMaxId: paginationNextMaxId)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        
        if InstagramAPI.sharedInstance.isTokenValid () {
            if userFeeds.count == 0 {
                getFeed()
            }
        }
        else {
            // Spawn WebViewController to make user's authentication from instagram
            let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("authentication") as! WebViewController
            
            self.presentViewController(webViewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.userFeeds.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
        
        // Clear ImageView of reused cell so old images won't show up
        cell.profilePictureImageView.image = nil
        cell.postImageView.image = nil
        
        // Get the correct feed corresponding to the List
        let feed:JSON = userFeeds[indexPath.row]

        // UserName
        let user: Dictionary<String, JSON> = feed["user"].dictionaryValue
        let userName: String = user["username"]!.stringValue
        cell.userNameLabel.text = userName
        
        // Profile Picture
        let profilePictureURL: String = user["profile_picture"]!.stringValue
        cell.profilePictureImageView.imageFromUrl(profilePictureURL)
        cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.frame.size.width / 2
        cell.profilePictureImageView.clipsToBounds = true
        
        // Location
        if let name:String = feed["location"]["name"].string {
            cell.locationLabel.text = name
            cell.locationLabel.hidden = false
        }
        else {
            cell.locationLabel.hidden = true
        }
        
        // Images
        if let imageURL:String = feed["images"]["standard_resolution"]["url"].string {
            cell.postImageView.imageFromUrl(imageURL)
        }
        
        // Need to check of this media/post has been pinned already. Disable the pin button
        // if the post has been pinned already
        if let mediaId:String = feed["id"].string{
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
                AppDelegate).managedObjectContext {
                    
                
                let fetchRequest = NSFetchRequest(entityName: "Pin")
                fetchRequest.predicate = NSPredicate(format: "(mediaId = %@)", mediaId)
                
                var error: NSError?
                var pins = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [Pin]
                
                if error == nil {
                    if pins.count > 0 {
                        cell.pinButton.enabled = false
                    }
                    else {
                        cell.pinButton.enabled = true
                    }
                }
                else {
                    NSLog(error!.localizedDescription)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Check if the will display indexPath is the last. If last make request for next page feed
        if indexPath.row == self.userFeeds.count - 1 {
            self.indexPathToReturnTo = indexPath
        
            getFeedWithPagination()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showAllBoards" {
            let viewController = segue.destinationViewController as! SelectBoardViewController
    
            // This setting will make the modal apear over the current view without removing
            // the current view
            viewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            
            // Hide tab bar controller when pinning new post to board
            self.tabBarController?.tabBar.hidden = true
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
                AppDelegate).managedObjectContext {
                    
                // Create entity for Pin
                let pin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: managedObjectContext) as! Pin
                
                // figure which button was clicked
                let buttonPosition = sender!.convertPoint(CGPointZero, toView: self.tableView)
                let currentIndexPath = tableView.indexPathForRowAtPoint(buttonPosition)
                
                // Get the correct feed corresponding to the List
                let feed:JSON = userFeeds[currentIndexPath!.row]
                
                // Set data to FeedTableView Cell
                if let mediaId:String = feed["id"].string{
                    pin.mediaId = mediaId
                }

                if let userName: String = feed["user"]["username"].string {
                    pin.username = userName
                }
                
                if let profilePictureURL: String = feed["user"]["profile_picture"].string {
                    pin.profilePicture = profilePictureURL
                }
                
                if let locationName:String = feed["location"]["name"].string {
                    pin.locationName = locationName
                }
                
                if let imageURL:String = feed["images"]["standard_resolution"]["url"].string {
                    pin.standardImage = imageURL
                }
                    
                if let thumbnailURL:String = feed["images"]["thumbnail"]["url"].string {
                    pin.thumbnail = thumbnailURL
                }
                    
                viewController.pinPost = pin
                
                // What to do after the modal view has been dismissed
                viewController.onDismiss = { (sender:UIViewController, returnObject:AnyObject?) -> Void in
                    
                    sender.dismissViewControllerAnimated(true, completion: nil)
                        
                    self.tabBarController?.tabBar.hidden = false
                    var indexPaths:[NSIndexPath] = []
                    indexPaths.append(currentIndexPath!)

                    // Only reload one cell where the pin button is at
                    self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                    
                }
            }
        }
    }
}
