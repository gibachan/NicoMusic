//
//  NicoThumbInfo.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/03.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation

class NicoNicoThumbInfo: NSObject, NSXMLParserDelegate {
    
    // MARK: Property
    // --------------------------------------------------
    var videoId: String = ""
    var title: String = ""
    var videoDescription: String = ""
    var thumbnailUrl: String = ""
    var firstRetrieve: String = ""
    var length: String = ""
    var movieType: String = ""
    var sizeHigh: String = ""
    var sizeLow: String = ""
    var viewCounter: String = ""
    var commentNum: String = ""
    var mylistCounter: String = ""
    var lastResBody: String = ""
    var watchUrl: String = ""
    var thumbType: String = ""
    var embeddable: String = ""
    var noLivePlay: String = ""
    var userId: String = ""
    var userNickname: String = ""
    var userIconUrl: String = ""

    // XML parse
    private var tag: String = ""
    
    // MARK: Method
    // --------------------------------------------------
    init(videoId: String) {
        super.init()
        
        self.videoId = videoId
    }
    
    func loadInfo() {
        let urlStr = "http://ext.nicovideo.jp/api/getthumbinfo/" + self.videoId
        let url = NSURL(string: urlStr)
        
        let parser = NSXMLParser(contentsOfURL: url)
        parser?.delegate = self
        parser?.parse()
    }
    
    func getFirstRetrieve() -> String {
        var formattedFirstRetrieve = ""
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.dateFromString(firstRetrieve) {
            let dateFormatter2 = NSDateFormatter()
            dateFormatter2.dateFormat = "yyyy/MM/dd HH:mm"
            formattedFirstRetrieve = dateFormatter2.stringFromDate(date)
        }
        
        return formattedFirstRetrieve
    }
    
    internal func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        self.tag = elementName
    }
    
    internal func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        self.tag = ""
    }
    
    internal func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        switch (self.tag) {
            case "title":
                self.title = string
            case "description":
                self.videoDescription = string
            case "thumbnail_url":
                self.thumbnailUrl = string
            case "first_retrieve":
                self.firstRetrieve = string
            case "length":
                self.length = string
            case "movie_type":
                self.movieType = string
            case "size_high":
                self.sizeHigh = string
            case "size_low":
                self.sizeLow = string
            case "view_counter":
                self.viewCounter = string
            case "comment_num":
                self.commentNum = string
            case "mylist_counter":
                self.mylistCounter = string
            case "last_res_body":
                self.lastResBody = string
            case "watch_url":
                self.watchUrl = string
            case "thumb_type":
                self.thumbType = string
            case "embeddable":
                self.embeddable = string
            case "no_live_play":
                self.noLivePlay = string
            case "user_id":
                self.userId = string
            case "user_nickname":
                self.userNickname = string
            case "user_icon_url":
                self.userIconUrl = string
            default:
                break
            
        }
    }
    
    internal func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("failure error: %@", parseError)
    }
}