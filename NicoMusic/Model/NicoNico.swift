//
//  NicoNico.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/01.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import Alamofire

let kNicoDownloadStartNotification = "NicoDownloadStartNotification"
let kNicoDownloadSuccessNotification = "NicoDownloadSuccessNotification"
let kNicoDownloadFailureNotification = "NicoDownloadFailureNotification"
let kNicoDownloadProgressNotification = "NicoDownloadProgressNotification"
let kNicoDownloadCancelNotification = "NicoDownloadCancelNotification"

private let singleton = NicoNico()

class NicoNico: NSObject, NSURLSessionDownloadDelegate {
    
    // MARK: Property
    // --------------------------------------------------
    private var sharedSession: NSURLSession!
    private var center: NSNotificationCenter!
    
    private var waits: [String] = []
    private var downloads: Dictionary<String, NSURLSessionDownloadTask> = [:]
    
    var donwloadingCount: Int {
        get {
            return downloads.count
        }
    }
    
    
    // MARK: Method
    // --------------------------------------------------
    class func getInstance() -> NicoNico {
        return singleton
    }
    
    func isDownloading(videoId: String) ->  Bool {
        for id in waits {
            if id == videoId {
                return true
            }
        }
        let keys = downloads.keys
        for key in keys {
            if key == videoId {
                return true
            }
        }
        return false
    }
    
    
    private override init() {
        center = NSNotificationCenter.defaultCenter()
    }
    
    
    private func videoIdByTask(task: NSURLSessionTask) -> String {
        var videoId = ""
        let req = task.originalRequest
        for (videoId2, task2) in downloads {
            if task.originalRequest.URL == task2.originalRequest.URL {
                videoId = videoId2
                break
            }
        }
        
        return videoId
    }
    
    private var session: NSURLSession {
        get {
            if sharedSession == nil {
                let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.childhoodend.tk.nicosinger")
                sharedSession = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
            }
            return sharedSession
        }
    }
    
    
    
    
    // Get video URL
    private func getVideoURL(videoId: String, success: ((String) -> Void)?, failure: ((NSError?) -> Void)?) {
        
        let url = "http://www.nicovideo.jp/api/getflv/" + videoId
        Alamofire.request(.GET, url, parameters: nil)
            .responseString { (request, response, string, error) in
                if error != nil {
                    failure?(error)
                    return
                }
                
                if string == nil {
                    failure?(nil)
                    return
                }
                
                var error: NSError?
                let regex = NSRegularExpression(pattern: "&url=(.*?)&", options: .CaseInsensitive, error: &error)
                if error != nil {
                    failure?(error)
                    return
                }
                
                let range = NSRange(location: 0, length: countElements(string!))
                let match = regex?.firstMatchInString(string!, options: nil, range: range)
                if match == nil || match!.numberOfRanges != 2 {
                    failure?(nil)
                    return
                }
                
                let resultRange = match!.rangeAtIndex(1)
                var encodedURL = string!.substringWithRange(Range<String.Index>(start: advance(string!.startIndex, resultRange.location), end: advance(string!.startIndex, resultRange.location + resultRange.length)))
                var decodedURL = encodedURL.stringByRemovingPercentEncoding
                if let decodedURL = decodedURL {
                    success?(decodedURL)
                } else {
                    failure?(nil)
                }
        }
    }
    
    // Visit
    private func visitPage(videoId: String, success: (() -> Void)?, failure: ((NSError?) -> Void)?) {
        let url = "http://www.nicovideo.jp/watch/" + videoId
        Alamofire.request(.HEAD, url, parameters: nil)
            .responseString { (request, response, string, error) in
                if error != nil {
                    failure?(error)
                } else {
                    success?()
                }
        }
    }
    
    
    func cancelDownloading(videoId: String) {
        removeFromWait(videoId)
        
        if let task = downloads[videoId] {
            task.cancel()
            downloads.removeValueForKey(videoId)
        }
        
        center.postNotificationName(kNicoDownloadCancelNotification, object: nil, userInfo: ["videoId": videoId])
    }
    
    // Download video file
    func download(videoId: String, email: String, password: String) {
        if isDownloading(videoId) {
            println("Already it has been downloading: \(videoId)")
            center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
            return
        }
        
        waits.append(videoId)
        
        let login = NicoNicoLogin.getInstance()
        login.login(email, password: password, success: { () -> Void in
            self.getVideoURL(videoId, success: { (videoURLStr) -> Void in
                self.visitPage(videoId, success: { () -> Void in
                    let videoURL = NSURL(string: videoURLStr)
                    if let videoURL = videoURL {
                        // Start downloading
                        let task: NSURLSessionDownloadTask = self.session.downloadTaskWithURL(videoURL)
                        
                        self.removeFromWait(videoId)
                        
                        self.downloads[videoId] = task
                        task.resume()
                        self.center.postNotificationName(kNicoDownloadStartNotification, object: nil, userInfo: ["videoId": videoId])
                        
                    } else {
                        self.removeFromWait(videoId)
                        self.center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
                    }
                    
                    }, failure: { (error) -> Void in
                        println("Visit URL error: \(error)")
                        self.removeFromWait(videoId)
                        self.center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
                })
                }, failure: { (error) -> Void in
                    println("get Video URL error: \(error)")
                    self.removeFromWait(videoId)
                    self.center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
            })
            
            }, failure: { (error) -> Void in
                println("login error: \(error)")
                self.removeFromWait(videoId)
                self.center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
        })
        
    }
    
    private func removeFromWait(videoId: String) {
        for (index, videoId2) in enumerate(self.waits) {
            if videoId == videoId2 {
                self.waits.removeAtIndex(index)
                break
            }
        }
    }
    
    // MARK: NSURLSessionDownloadDelegate
    // --------------------------------------------------
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let videoId = videoIdByTask(downloadTask)
        if videoId == "" {
            center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
            return
        }
        
        let response = downloadTask.response
        
        let originalName = response?.suggestedFilename
        if originalName == nil {
            center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
            return
        }
        
        let fileMgr = NSFileManager.defaultManager()
        let tmpDirStr = NSTemporaryDirectory()
        let ext = originalName!.pathExtension
        let fileName = videoId + "." + ext
        let filePath = tmpDirStr + fileName
        let fileURL = NSURL.fileURLWithPath(filePath)
        
        if let fileURL = fileURL {
            if let path = fileURL.path {
                if fileMgr.fileExistsAtPath(path) {
                    fileMgr.removeItemAtPath(path, error: nil)
                    println("delete \(path)")
                }
            }
            
            // Move file into temporary directory
            var error: NSError?
            fileMgr.moveItemAtURL(location, toURL: fileURL, error: &error)
            if let error = error {
                println("Move error \(error)")
                center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
                return
            }
            
            // Extract music file from video file
            let musicMng = NicoMusicManager.getInstance()
            if let music = musicMng.getMusicByVideoId(videoId) {
                if let filePath = fileURL.path {
                    let fileMng = NSFileManager.defaultManager()
                    if fileMng.fileExistsAtPath(filePath) {
                        let musicMgr = NicoMusicManager.getInstance()
                        let musicDirPath = musicMgr.musicDirPath
                        
                        let extVideo = "." + filePath.pathExtension
                        let extAudio = ".m4a"
                        let audioFileName = filePath.lastPathComponent.stringByReplacingOccurrencesOfString(extVideo, withString: extAudio, options: nil, range: nil)
                        
                        let audioFilePath = musicDirPath + "/" + audioFileName
                        let audioURL = NSURL.fileURLWithPath(audioFilePath)
                        
                        let extractor = AudioExtractor(videoURL: fileURL)
                        extractor.extract(audioURL!, success: { () -> Void in
                            
                            music.setValue(audioFileName, forKey:"fileName")
                            println("saved file name: " + audioFilePath)
                            
                            musicMng.save()
                            
                            self.center.postNotificationName(kNicoDownloadSuccessNotification, object: nil, userInfo: ["videoId": videoId])
                            
                            
                            }, failure: { () -> Void in
                                println("Extract error")
                                self.center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
                        })
                        
                    } else {
                        println("Couldn't get music data")
                        center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
                    }
                } else {
                    println("Couldn't get music data")
                    center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
                }
            } else {
                println("Couldn't get music data")
                center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
            }
            
        }
    }
    

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let videoId = videoIdByTask(downloadTask)
        if videoId == "" {
            println("Coludn't get videoId in didWriteData")
            return
        }
        
        var progress = Float(downloadTask.countOfBytesReceived) / Float(downloadTask.countOfBytesExpectedToReceive)
        center.postNotificationName(kNicoDownloadProgressNotification, object: nil, userInfo: ["videoId": videoId, "progress": progress])
    }
    
    // MARK: NSURLSessionTaskDelegate
    // --------------------------------------------------
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let videoId = videoIdByTask(task)
        if videoId == "" {
            println("Coludn't get videoId in didCompleteWithError")
            return
        }
        
        downloads.removeValueForKey(videoId)
        
        if error != nil {
            println("Error occured in didCompleteWithError: \(error)")
            center.postNotificationName(kNicoDownloadFailureNotification, object: nil, userInfo: ["videoId": videoId])
        }

    }
    
}