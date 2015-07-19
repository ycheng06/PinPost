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
    var boardPins:Array<Pin> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
        
            let fetchRequest = NSFetchRequest(entityName: "Board")
            fetchRequest.predicate = NSPredicate(format:"(type = %@)", self.boardType)
            
            var error: NSError?
            var boards = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [Board]
            
            if error == nil {
                let currentBoard:Board = boards[0]
                self.boardPins = currentBoard.pins
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
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedTableViewCell

        // Configure the cell...
        cell.profilePictureImageView.image = nil
        cell.postImageView.image = nil
        
        let pin:Pin = boardPins[indexPath.row]
        
        cell.userNameLabel.text = pin.username
        cell.profilePictureImageView.imageFromUrl(pin.profilePicture)
        cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.frame.size.width / 2
        cell.profilePictureImageView.clipsToBounds = true
        
        if let locationName:String = pin.locationName {
            cell.locationLabel.text = locationName
        }
        
        cell.postImageView.imageFromUrl(pin.thumbnail)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
