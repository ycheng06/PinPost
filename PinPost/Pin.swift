//
//  Pin.swift
//  PinPost
//
//  Created by Jason Cheng on 7/14/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import Foundation
import CoreData

class Pin:NSManagedObject{
    @NSManaged var username:String
    @NSManaged var profilePicture:String
    @NSManaged var standardImage:String
    @NSManaged var thumbnail:String
    @NSManaged var locationName:String?
    @NSManaged var mediaId:String
    @NSManaged var board:Board
}