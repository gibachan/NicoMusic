//
//  NicoMusic.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/15.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import CoreData

class NicoMusic: NSManagedObject {

    @NSManaged var fileName: String
    @NSManaged var identifier: String
    @NSManaged var thumbnail: NSData
    @NSManaged var title: String
    @NSManaged var videoId: String
    @NSManaged var nickname: NSManagedObject

}
