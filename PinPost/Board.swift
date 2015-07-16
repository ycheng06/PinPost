//
//  Board.swift
//  PinPost
//
//  Created by Jason Cheng on 7/14/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import Foundation
import CoreData

class Board:NSManagedObject {
    @NSManaged var type:String
    @NSManaged var pins:Array<Pin>
}
