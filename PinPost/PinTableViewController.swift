//
//  PinTableViewController.swift
//  PinPost
//
//  Created by Jason Cheng on 7/17/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit
import CoreData

class PinTableViewController: UITableViewController {
    var boards:[Board] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
            AppDelegate).managedObjectContext {
                
                let fetchRequest = NSFetchRequest(entityName: "Board")
                
                var error: NSError?
                var fetchedBoards = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [Board]
                
                if error != nil {
                    NSLog(error!.localizedDescription)
                }
                    // No error with fetch request so continue on with logic
                else {
                    self.boards = fetchedBoards
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
        return self.boards.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinCell", forIndexPath: indexPath) as! PinTableViewCell

        // Configure the cell...
        cell.boardTypeLabel.text = self.boards[indexPath.row].type
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showBoard" {
            println("what is going on")
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as! PinFeedTableViewController
                destinationViewController.boardType = self.boards[indexPath.row].type
            }
        }
    }
}
