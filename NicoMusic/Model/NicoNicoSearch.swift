//
//  NicoNicoSearch.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/30.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import Alamofire

enum NicoNicoSearchType {
    case Tag, Keyword
}

class NicoNicoSearch: NSObject {
    
    // MARK: Property
    // --------------------------------------------------
    var result: [NicoNicoSearchResult] = []
    var lastKeyword: String = ""
    var lastPage: Int = 0
    var tagOrKeyword: String = ""
    
    // MARK: Method
    // --------------------------------------------------
    private override init() {
        super.init()
    }
    
    init(type: NicoNicoSearchType) {
        super.init()
        
        switch (type) {
        case .Tag:
            tagOrKeyword = "tag"
        case .Keyword:
            tagOrKeyword = "search"
        }
    }
    
    private func login(email: String, password: String, success: (() -> Void)?, failure: ((NSError?) -> Void)?) {
        let url = "https://secure.nicovideo.jp/secure/login?site=niconico"
        let parameters = ["mail": email, "password": password, "as3": "1"]
        
        Alamofire.request(.POST, url, parameters: parameters)
            .response { (request, response, data, error) in
                if error != nil {
                    failure?(error)
                    return
                }
                
                success?()
        }
        
    }
    
    func search(keyword: String, callback: (() -> Void)?) {
        // http://ext.nicovideo.jp/api/search/${検索タイプ}/${検索文字列}${パラメータ}

        // Initialize
        result = []
        lastKeyword = ""
        lastPage = 0
        
        var encodedKeyword = keyword.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        if encodedKeyword == nil {
            encodedKeyword = keyword
        }
        
        let url = "http://ext.nicovideo.jp/api/search/" + tagOrKeyword + "/" + encodedKeyword!
        let parameters = ["mode": "watch", "page": "1", "sort": "v", "order": "d"]
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseString { (_, _, string, _) in
                
                self.lastKeyword = encodedKeyword!
                self.lastPage = 1
                
                if let string = string {
                    let json = JSON(string: string)

                    for (i, v) in json["list"] {
                        let result = NicoNicoSearchResult(json: v)
                        self.result.append(result)
                    }
                    
                    callback?()
                }
                
                
            }

    }
    
    func searchNext(callback: (() -> Void)?) {
        let url = "http://ext.nicovideo.jp/api/search/" + tagOrKeyword + "/" + lastKeyword
        let parameters = ["mode": "watch", "page": "\(lastPage + 1)", "sort": "v", "order": "d"]
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseString { (_, _, string, _) in
                
                self.lastPage++
                
                if let string = string {
                    let json = JSON(string: string)
                    
                    for (i, v) in json["list"] {
                        let result = NicoNicoSearchResult(json: v)
                        self.result.append(result)
                    }
                    
                    callback?()
                }
        }
    }
    
    
}
