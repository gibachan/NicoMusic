//
//  NicoNicoLogin.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/14.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import Alamofire

private let singleton = NicoNicoLogin()

class NicoNicoLogin {
    // MARK: Method
    // --------------------------------------------------
    private init() {
    }
    
    class func getInstance() -> NicoNicoLogin {
        return singleton
    }
    
    func login(mail: String, password: String, success: (() -> Void)?, failure: ((NSError?) -> Void)?) {
        let url = "https://secure.nicovideo.jp/secure/login?site=niconico"
        let parameters = ["mail": mail, "password": password, "as3": "1"]
        
        Alamofire.request(.POST, url, parameters: parameters)
            .response { (request, response, data, error) in
                if error != nil {
                    failure?(error)
                    return
                }
                
                if self.isLoggedIn() {
                    success?()
                } else {
                    failure?(nil)
                }
        }
        
    }
    
    func logout(callback: (() -> Void)?) {
        let url = "https://secure.nicovideo.jp/secure/logout"
        
        Alamofire.request(.POST, url, parameters: nil)
            .response { (request, response, data, error) in
                if error != nil {
                    println("logout error: \(error)")
                }
                
                callback?()
        }
    }
    
    func isLoggedIn() -> Bool {
        var isLoggedIn = false
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookies as NSArray?
        if cookies != nil {
            for cookie in cookies! {
                if let c = cookie as? NSHTTPCookie {
                    if c.name == "user_session" && c.domain == ".nicovideo.jp" {
                        isLoggedIn = true
                        break
                    }
                    
                }
            }
        }
        return isLoggedIn
    }

    
}