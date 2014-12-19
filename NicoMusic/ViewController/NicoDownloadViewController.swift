//
//  NicoDownloadViewController.swift
//  NicoMusic
//
//  Created by gibachan on 2014/12/13.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class NicoDownloadViewController: UIViewController {
    
    // MARK: Property
    // --------------------------------------------------
    internal var nico: NicoNico!

    // MARK: UIViewController
    // --------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nico = NicoNico.getInstance()

        // Notification
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "downloadStarted:", name: kNicoDownloadStartNotification, object: nil)
        center.addObserver(self, selector: "downloadSucceeded:", name: kNicoDownloadSuccessNotification, object: nil)
        center.addObserver(self, selector: "downloadFailed:", name: kNicoDownloadFailureNotification, object: nil)
        center.addObserver(self, selector: "downloadProgressed:", name: kNicoDownloadProgressNotification, object: nil)
        center.addObserver(self, selector: "downloadCanceled:", name: kNicoDownloadCancelNotification, object: nil)

    }
    
    // MARK: Method
    // --------------------------------------------------
    internal func download(info: NicoNicoThumbInfo) {
        // Get login data
        let defaults = NSUserDefaults.standardUserDefaults()
        let email = defaults.stringForKey("email")
        let password = defaults.stringForKey("password")
        
        if email == nil || countElements(email!) == 0 ||
            password == nil || countElements(password!) == 0 {
                alertOK("ダウンロード", message: "ログインが必要です。\n「設定」からログインしてから実行して下さい。", callback: nil)
                return
        }
        

        // Cancel downloading
        if nico.isDownloading(info.videoId) {
            alertYesNo("ダウンロード", message: "ダウンロード中です。\nキャンセルしますか？", yesCallback: { Void in
                self.nico.cancelDownloading(info.videoId)
                
                // Remove music
                let musicMgr = NicoMusicManager.getInstance()
                if let music = musicMgr.getMusicByVideoId(info.videoId) {
                    musicMgr.removeMusic(music)
                    musicMgr.save()
                }
                }, noCallback: nil)
            
            return
        }
        
        // Check if it has already downloaded
        let musicMgr = NicoMusicManager.getInstance()
        var music: NicoMusic! = musicMgr.getMusicByVideoId(info.videoId)
        if let music = music {
            if music.fileStored {
                alertOK("ダウンロード", message: "既にダウンロード済みです。", callback: nil)
                return
            }
        }

        
        // Max donwload count
        if nico.donwloadingCount >= 2 {
            alertOK("ダウンロード", message: "同時にダウンロードできるのは２つまでです。", callback: nil)
            return
        }
        
        // Check network condition
        switch (Reachability.isConnectedToNetworkOfType()) {
        case ReachabilityType.NotConnected:
            alertOK("ネットワーク", message: "ネットワークに接続されていません。", callback: nil)
            return
        case ReachabilityType.WWAN:
            alertYesNo("ネットワーク", message: "大容量のデータをダウンロードするため、Wifiに接続することを推奨します。\nダウンロードを開始しますか？", yesCallback: { Void in
                self.startDownload(info, email: email!, password: password!)
                }, noCallback: nil)
        case ReachabilityType.WiFi:
            startDownload(info, email: email!, password: password!)
        }
    }
    
    private func startDownload(info: NicoNicoThumbInfo, email: String, password: String) {
        let musicMgr = NicoMusicManager.getInstance()
        
        
        // Save nickname
        var nickname: Nickname! = musicMgr.getNicknameByName(info.userNickname)
        if nickname == nil {
            nickname = musicMgr.insertNickname(info.userNickname)
        }
        
        // Save music
        let music = musicMgr.insertMusic(info.videoId)
        
        let thumbnailUrl = NSURL(string: info.thumbnailUrl)
        var thumbnail: NSData?
        if let url = thumbnailUrl {
            thumbnail = NSData(contentsOfURL: url)
        }
        
        music.setValue(info.title, forKey:"title")
        music.setValue(thumbnail, forKey:"thumbnail")
        music.setValue(nickname, forKey:"nickname")
        music.setValue("", forKey:"fileName")
        
        musicMgr.save()
        
        // download
        nico.download(music.videoId, email: email, password: password)
    }
    
    

    // Mark: Download notification
    // --------------------------------------------------
    func downloadStarted(notification: NSNotification?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func downloadSucceeded(notification: NSNotification?) {
        // Indicator
        if nico.donwloadingCount == 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func downloadFailed(notification: NSNotification?) {
        // Indicator
        if nico.donwloadingCount == 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func downloadProgressed(notification: NSNotification?) {
    }
    
    func downloadCanceled(notification: NSNotification?) {
        // Indicator
        if nico.donwloadingCount == 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }


}
