//
//  NicoNicoSearchResult.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/30.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class NicoNicoSearchResult: NSObject {
    
    // MARK: Property
    // --------------------------------------------------
    var videoId: String = ""
    var title: String = ""
    var firstRetrieve: String = ""
    var viewCounter: String = ""
    var mylistCounter: String = ""
    var thumbnailUrl: String = ""
    var numRes: String = ""
    var length: String = ""
    
    // MARK: Method
    // --------------------------------------------------
    init(json: JSON) {
        if let videoId = json["id"].asString {
            self.videoId = videoId
        }
        if let title = json["title"].asString {
            self.title = title
        }
        if let firstRetrieve = json["first_retrieve"].asString {
            self.firstRetrieve = firstRetrieve
        }
        if let viewCounter = json["view_counter"].asInt {
            self.viewCounter = String(viewCounter)
        }
        if let mylistCounter = json["mylist_counter"].asInt {
            self.mylistCounter = String(mylistCounter)
        }
        if let thumbnailUrl = json["thumbnail_url"].asString {
            self.thumbnailUrl = thumbnailUrl
        }

        if let commentNum = json["num_res"].asInt {
            self.numRes = String(commentNum)
        }
        if let length = json["length"].asString {
            self.length = length
        }
    }
    
}
