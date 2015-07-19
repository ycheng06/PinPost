//
//  BoardTableViewController.swift
//  PinPost
//
//  Created by Jason Cheng on 7/19/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit
import CoreData

class BoardTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var boards:[Board] = []
    
    // This controller will help listen to changes in the fetch result in managedObjectContext
    var fetchResultController:NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
            AppDelegate).managedObjectContext {
                
                let fetchRequest = NSFetchRequest(entityName: "Board")
                let sortDescriptor = NSSortDescriptor(key:"type", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchResultController.delegate = self
                
                var error: NSError?
                var fetchedBoards = fetchResultController.performFetch(&error)
                
                if error != nil {
                    NSLog(error!.localizedDescription)
                }
                // No error with fetch request so continue on with logic
                else {
                    self.boards = fetchResultController.fetchedObjects as! [Board]
                }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NSFetchedResultsControllerDelegate 
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        
        default:
            tableView.reloadData()
        }
        
        self.boards = fetchResultController.fetchedObjects as! [Board]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("pinBoardCell", forIndexPath: indexPath) as! PinBoardTableViewCell
        
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
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as! PinFeedTableViewController
            
                destinationViewController.boardType = self.boards[indexPath.row].type
            }
        }
    }

}
