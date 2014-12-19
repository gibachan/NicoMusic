//
//  NicoMusicExt.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/16.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation

extension NicoMusic {
    
    // MARK: Property
    // --------------------------------------------------
    var fileStored: Bool {
        get {
            if let fileName = self.valueForKey("fileName") as? String {
                if countElements(fileName) > 0 {
                    let musicMgr = NicoMusicManager.getInstance()
                    let musicDirPath = musicMgr.musicDirPath
                    let musicPath = musicDirPath + "/" + fileName
                    
                    let fileMng = NSFileManager.defaultManager()
                    if fileMng.fileExistsAtPath(musicPath) {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
}