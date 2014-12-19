//
//  Nickname.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/15.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import CoreData

class Nickname: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var nickname: String
    @NSManaged var musics: NSSet

}
