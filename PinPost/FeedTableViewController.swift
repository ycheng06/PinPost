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
    
    @IBAction func pinToBoard(sender: AnyObject) {
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
            AppDelegate).managedObjectContext {
            
            let fetchRequest = NSFetchRequest(entityName: "Board")
            fetchRequest.predicate = NSPredicate(format: "(type = %@)", "Food")
            
            var error: NSError?
            var foodBoards = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [Board]
            
            if error != nil {
                NSLog(error!.localizedDescription)
            }
            // No error with fetch request so continue on with logic
            else {
                
                var foodBoard:Board!
                
                // food board doesn't exist so create one first
                if foodBoards.count == 0 {

                    // Create entity for Board
                    let board = NSEntityDescription.insertNewObjectForEntityForName("Board", inManagedObjectContext: managedObjectContext) as! Board
                    board.type = "Food"
                    foodBoard = board
                }
                else {
                    foodBoard = foodBoards[0] as Board
                }
                
                // Create entity for Pin
                let pin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: managedObjectContext) as! Pin
                
                // figure which button was clicked
                let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
                let indexPath = tableView.indexPathForRowAtPoint(buttonPosition)
                
                // Get the correct feed corresponding to the List
                let feed:JSON = userFeeds[indexPath!.row]
                
                // Set data to FeedTableView Cell
                if let mediaId:String = feed["id"].string{
                    pin.mediaId = mediaId
                }
                
                // Set relationship. Because they are inverse relationship so setting the to-one
                // relationship will automatically set the to-many relationship
                pin.board = foodBoard
            }
            
            var e: NSError?
            if managedObjectContext.save(&e) != true {
                println("insert error: \(e!.localizedDescription)")
                return
            }
            else {
                let button:UIButton = sender as! UIButton
                button.enabled = false
                button.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
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

        // Set data to FeedTableView Cell
//        if let mediaId:String = feed["id"].string{
//            cell.mediaId = mediaId
//        }

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
//                        cell.pinButton.backgroundColor = UIColor.blackColor()
                    }
                    else {
                        cell.pinButton.enabled = true
//                        cell.pinButton.backgroundColor = UIColor.orangeColor()
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
        
        // Check if the will display indexPath is the last 
        if indexPath.row == self.userFeeds.count - 1 {
            self.indexPathToReturnTo = indexPath
        
            getFeedWithPagination()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            // Get the new view controller using [segue destinationViewController].
            // Pass the selected object to the new view controller.

        if segue.identifier == "showAllBoards" {
            let viewController = segue.destinationViewController as! SelectBoardViewController
    
            viewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            self.tabBarController?.tabBar.hidden = true
            
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
                AppDelegate).managedObjectContext {
                    
                // Create entity for Pin
                let pin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: managedObjectContext) as! Pin
                
                // figure which button was clicked
                let buttonPosition = sender!.convertPoint(CGPointZero, toView: self.tableView)
                let indexPath = tableView.indexPathForRowAtPoint(buttonPosition)
                
                // Get the correct feed corresponding to the List
                let feed:JSON = userFeeds[indexPath!.row]
                
                // Set data to FeedTableView Cell
                if let mediaId:String = feed["id"].string{
                    pin.mediaId = mediaId
                }
                
                viewController.pinPost = pin

            }
        }
    }
}