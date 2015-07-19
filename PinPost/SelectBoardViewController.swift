//
//  SelectBoardViewController.swift
//  PinPost
//
//  Created by Jason Cheng on 7/15/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit
import CoreData

class SelectBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var blurEffectView: UIVisualEffectView!
    var boards:[Board] = []
    var pinPost: Pin?
    
    // Delegate function to be set by the parent that calls this modal view
    // Will handle the logic when this modal view has been dismissed
    var onDismiss:((sender:UIViewController, returnObject:AnyObject?) -> Void)?
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addBoard(sender: AnyObject) {
        var boardNameTextField:UITextField!
        
        let actionSheetController = UIAlertController(title: "New Board", message: "Name your new board", preferredStyle: .Alert)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let okAction:UIAlertAction = UIAlertAction(title: "Create", style: .Default, handler: {action -> Void in
            
            var newBoardName = boardNameTextField.text
            
            self.addPinToBoardWithoutEntity(newBoardName, completion: {() -> Void in
                actionSheetController.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        // Add action
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(okAction)
        
        // Add text field
        actionSheetController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            boardNameTextField = textField
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    // Add pin to a board
    // Requires board entity. Completion is called to execute any action that needs to
    // happen after the managedObjectContext is saved
    func addPinToBoard(board:Board, completion: (() -> Void)?){
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
            AppDelegate).managedObjectContext {
                
                pinPost?.board = board
                
                // Save new pin to core data
                var error: NSError?
                if managedObjectContext.save(&error) != true {
                    NSLog(error!.localizedDescription)
                }
                else {
                    completion?()
                    self.onDismiss?(sender: self, returnObject: nil)
                }
        }
    }
    
    // Board entity needs to be created first before saving the pin
    func addPinToBoardWithoutEntity(boardName:String, completion: (() -> Void)?){
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as!
            AppDelegate).managedObjectContext {

            let board = NSEntityDescription.insertNewObjectForEntityForName("Board", inManagedObjectContext: managedObjectContext) as! Board
            board.type = boardName
                
            addPinToBoard(board, completion: completion)
        }
    }
    override func viewDidAppear(animated: Bool) {
        println(blurEffectView.userInteractionEnabled)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView(frame:
            CGRectZero)
        
        self.view.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        // Important to disable user interaction otherwise it conflicts with
        // the select event for the table view
        blurEffectView.userInteractionEnabled = false
        
        // Insert the blur view underneath the table view so the blue doesn't
        // block the table
        self.view.insertSubview(blurEffectView, belowSubview: self.tableView)
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return boards.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("boardCell", forIndexPath: indexPath) as! BoardTableViewCell
        
        cell.boardTypeLabel.text = boards[indexPath.row].type
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedBoard = boards[indexPath.row]
        
        addPinToBoard(selectedBoard, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! UITableViewCell
        
        return cell
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
