//
//  PinFeedTableViewController.swift
//  PinPost
//
//  Created by Jason Cheng on 7/17/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit
import CoreData

class PinFeedTableViewController: UITableViewController {
    
    var boardType:String!
    var boardPins:[Pin] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch Board and its Pins
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
        
            let fetchRequest = NSFetchRequest(entityName: "Board")
            fetchRequest.predicate = NSPredicate(format:"(type = %@)", self.boardType)
            
            var error: NSError?
            var boards = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [Board]
            
            if error == nil {
                let currentBoard:Board = boards[0]
                self.boardPins = currentBoard.pins.allObjects as! [Pin]
            }
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
        return self.boardPins.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinFeedCell", forIndexPath: indexPath) as! PinFeedTableViewCell
        
        // Reset image views so old images don't show up in reused cell
        cell.profilePictureImageView.image = nil
        cell.postImageView.image = nil
        
        if self.boardPins.count > 0 {
            let pin:Pin = self.boardPins[indexPath.row] as Pin
            
            // Set user name and user profile picture
            cell.userNameLabel.text = pin.username
            cell.profilePictureImageView.imageFromUrl(pin.profilePicture)
            cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.frame.size.width / 2
            cell.profilePictureImageView.clipsToBounds = true
            
            // Set lcoationLabel. Only show if location data is provided
            if let locationName:String = pin.locationName {
                cell.locationLabel.text = locationName
                cell.locationLabel.hidden = false
            }
            else {
                cell.locationLabel.hidden = true
            }
            
            // Load the post image asynchronously
            cell.postImageView.imageFromUrl(pin.standardImage)
        }
        
        return cell
    }

       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
