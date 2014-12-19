//
//  NicoNicoRanking.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/01.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation

enum NicoNicoRankingTerm: Int {
    case Hourly = 1, Daily, Weekly, Monthly, Total
}

class NicoNicoRanking: NSObject, NSXMLParserDelegate {
    let urlHourlyStr = "http://www.nicovideo.jp/ranking/view/hourly/sing?rss=2.0"
    let urlDailyStr = "http://www.nicovideo.jp/ranking/view/daily/sing?rss=2.0"
    let urlWeeklyStr = "http://www.nicovideo.jp/ranking/view/weekly/sing?rss=2.0"
    let urlMonthlyStr = "http://www.nicovideo.jp/ranking/view/monthly/sing?rss=2.0"
    let urlTotalStr = "http://www.nicovideo.jp/ranking/view/total/sing?rss=2.0"
    
    // MARK: Property
    // --------------------------------------------------
    var count: Int {
        get {
            return ranking.count
        }
    }
    
    // Ranking data
    private var ranking: [NicoNicoThumbInfo] = []

    // XML parse
    private var isItem = false
    private var isLink = false
    
    // MARK: Method
    // --------------------------------------------------
    override init() {
    }
    
    func objectAtIndex(index : Int) -> NicoNicoThumbInfo? {
        if index >= 0 && index < ranking.count {
            return ranking[index]
        } else {
            return nil
        }
    }
   
    func updateRanking(term: NicoNicoRankingTerm, callback: (() -> Void)?) {
        ranking = []
        
        var url: NSURL?
        switch (term) {
        case .Hourly:
            url = NSURL(string: urlHourlyStr)
        case .Daily:
            url = NSURL(string: urlDailyStr)
        case .Weekly:
            url = NSURL(string: urlWeeklyStr)
        case .Monthly:
            url = NSURL(string: urlMonthlyStr)
        case .Total:
            url = NSURL(string: urlTotalStr)
            
        }
        
        let parser = NSXMLParser(contentsOfURL: url)
        parser?.delegate = self
        parser?.parse()
        
        for item in ranking {
            item.loadInfo()
        }
        
        callback?()
    }
    
    internal func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        
        if elementName == "item" {
            isItem = true
        } else {
            if isItem {
                switch (elementName) {
                    case "link":
                        isLink = true
                    default:
                        break
                }
            }
        }
    }
    
    internal func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        if elementName == "item" {
            isItem = false
        } else {
            if isItem {
                switch (elementName) {
                    case "link":
                        isLink = false
                    default:
                        break
                }
            }
        }
    }
    
    internal func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if isLink {
            let videoId = getVideoId(string)
            let thumb = NicoNicoThumbInfo(videoId: videoId)
            ranking.append(thumb)
        }
        
    }
    
    internal func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("failure error: %@", parseError)
    }
    
    
    private func getVideoId(link: String) -> String {
        var error: NSError?
        
        let regex = NSRegularExpression(pattern: "/(s.*)", options: .CaseInsensitive, error: &error)
        if error != nil {
            return ""
        }
        let range = NSRange(location: 0, length: countElements(link))
        let match = regex?.firstMatchInString(link, options: nil, range: range)
        if match == nil || match!.numberOfRanges != 2 {
            return ""
        }
        let resultRange = match!.rangeAtIndex(1)
        let videoId = link.substringWithRange(Range<String.Index>(start: advance(link.startIndex, resultRange.location), end: advance(link.startIndex, resultRange.location + resultRange.length)))
        return videoId
    }
}