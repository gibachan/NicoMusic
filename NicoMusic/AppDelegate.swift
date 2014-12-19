//
//  AppDelegate.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/03.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Tab bar color
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, forState: .Normal)
        
        // Delete all files in temporary directory
        let fileMgr = NSFileManager.defaultManager()
        let tmpDirStr = NSTemporaryDirectory()
        if let tmpUrl = NSURL(fileURLWithPath: tmpDirStr, isDirectory: true) {
            if let enumerator = fileMgr.enumeratorAtURL(tmpUrl, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles, errorHandler: nil) {
                while let elem = enumerator.nextObject() as? NSURL {
                    fileMgr.removeItemAtURL(elem, error: nil)
                }
            }
        }
        
        // Flush invalid data
        let musicMgr = NicoMusicManager.getInstance()
        musicMgr.flushInvalidData()

        // Create directory which stores audio files
        let musicDirPath = musicMgr.musicDirPath
        var isDir: ObjCBool = false
        if !fileMgr.fileExistsAtPath(musicDirPath, isDirectory:&isDir) {
            fileMgr.createDirectoryAtPath(musicDirPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        // Play background
        let audioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &error)
        audioSession.setActive(true, error: &error)

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        // Default setting
        let defaults = NSUserDefaults.standardUserDefaults()
        var termValue = defaults.integerForKey("rankingterm")
        if termValue == 0 {
            termValue = NicoNicoRankingTerm.Daily.rawValue
            defaults.setObject(termValue, forKey: "rankingterm")
        }
        
        return true
    }

}

