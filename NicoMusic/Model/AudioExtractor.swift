//
//  AudioExtractor.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/03.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import AVFoundation

class AudioExtractor {
    // MARK: Property
    // --------------------------------------------------
    var videoURL: NSURL?
    
    // MARK: Method
    // --------------------------------------------------
    init(videoURL: NSURL) {
        self.videoURL = videoURL
    }

    func extract(audioURL: NSURL, success: (() -> Void)?, failure: (() -> Void)?) {
        let asset = AVURLAsset(URL: self.videoURL, options: nil)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        
        // Export
        exportSession.outputURL = audioURL
        exportSession.outputFileType = AVFileTypeAppleM4A
        exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
            // Delete video file
            if let videoFilePath = self.videoURL?.path {
                let fileMgr = NSFileManager.defaultManager()
                if fileMgr.fileExistsAtPath(videoFilePath) {
                    fileMgr.removeItemAtPath(videoFilePath, error: nil)
                }
            }
            
            if exportSession.status == AVAssetExportSessionStatus.Completed {
                success?()
            } else {
                failure?()
            }
        }

    }
}