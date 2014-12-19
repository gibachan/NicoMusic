//
//  NicoMusicManager.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/03.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import Foundation
import CoreData

private let singleton = NicoMusicManager()

let kNicoMusicUpdateNotification = "MusicDeleteNotification"

class NicoMusicManager: NSObject {
    let kDBFileName = "nicomusic.sqlite"
    let kMusicModel = "NicoMusic"
    let kNicknameModel = "Nickname"
    let kPlaylistModel = "Playlist"
    
    
    // MARK: Property
    // --------------------------------------------------
    var musicDirPath: String {
        get {
            let documentsDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let musicDirPath = documentsDirPath + "/music"
            return musicDirPath
        }
    }
    
    private var context: NSManagedObjectContext!
    
    // MARK: Method
    // --------------------------------------------------
    private override init() {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        let pathes = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        var dbURL = NSURL()
        if pathes.count > 0 {
            if let path = pathes.first as? String {
                let fullpath = path.stringByAppendingPathComponent(kDBFileName)
                if let fileURL = NSURL(fileURLWithPath: fullpath) {
                    dbURL = fileURL
                }
            }
        }
        
        var error: NSError? = nil
        let persistentStore = persistentStoreCoordinator.addPersistentStoreWithType(
            NSSQLiteStoreType,
            configuration: nil,
            URL: dbURL,
            options: nil,
            error: &error)
        if let error = error {
            NSLog("Failed to add persistent store: %@", error)
        }
        
        self.context = NSManagedObjectContext()
        self.context.persistentStoreCoordinator = persistentStoreCoordinator
        
        super.init()
    }
    
    class func getInstance() -> NicoMusicManager {
        return singleton
    }
    
    // MARK: NicoMusic
    // --------------------------------------------------
    func insertMusic(videoId: String) -> NicoMusic {
        let music = NSEntityDescription.insertNewObjectForEntityForName(kMusicModel, inManagedObjectContext: self.context) as NicoMusic
        
        // Set properties
        let uuid = CFUUIDCreate(nil)
        let identifier = CFUUIDCreateString(nil, uuid) as String
        music.setValue(identifier, forKey: "identifier")
        music.setValue(videoId, forKey: "videoId")
        
        return music
    }
    
    func getMusicByVideoId(videoId: String) -> NicoMusic? {
        var ret: NicoMusic?
        
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName(kMusicModel, inManagedObjectContext: self.context)
        var err: NSError?
        let musics = self.context.executeFetchRequest(request, error: &err)
        if err != nil {
            println("NicoMusic fetch error: \(err)")
        } else {
            if let musics = musics {
                for music in musics {
                    if let music = music as? NicoMusic {
                        if music.videoId == videoId {
                            ret = music
                            break
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    func getAllMusic() -> [NicoMusic] {
        var ret: [NicoMusic] = []
        
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName(kMusicModel, inManagedObjectContext: self.context)
        var err: NSError?
        let musics = self.context.executeFetchRequest(request, error: &err)
        if err != nil {
            println("NicoMusic fetch error: \(err)")
        } else {
            if let musics = musics {
                for music in musics {
                    if let music = music as? NicoMusic {
                        ret.append(music)
                    }
                }
            }
        }
        
        return ret
    }
    
    func removeMusic(music: NicoMusic) {
        let videoId = music.videoId
        
        // Delete file
        let fileMgr = NSFileManager.defaultManager()
        let musicDirPath = self.musicDirPath
        if let fileName = music.valueForKey("fileName") as? String {
            let musicPath = musicDirPath + "/" + fileName
            var isDir: ObjCBool = false
            if fileMgr.fileExistsAtPath(musicPath, isDirectory:&isDir) {
                if !isDir {
                    fileMgr.removeItemAtPath(musicPath, error: nil)
                }
            }
        }
        
        self.context.deleteObject(music)
    }
    
    func removeAllMusic() {
        let musics = getAllMusic()
        for music in musics {
            removeMusic(music)
        }
    }
    
    
    // MARK: Nickname
    // --------------------------------------------------
    func insertNickname(name: String) -> Nickname {
        var nickname = NSEntityDescription.insertNewObjectForEntityForName(kNicknameModel, inManagedObjectContext: self.context) as Nickname
        
        // Set properties
        let uuid = CFUUIDCreate(nil)
        let identifier = CFUUIDCreateString(nil, uuid) as String
        nickname.setValue(identifier, forKey: "identifier")
        nickname.setValue(name, forKey: "nickname")
        
        return nickname
    }
    
    func getNicknameByName(name: String) -> Nickname? {
        var ret: Nickname?
        
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName(kNicknameModel, inManagedObjectContext: self.context)
        var err: NSError?
        let nicknames = self.context.executeFetchRequest(request, error: &err)
        if err != nil {
            println("Nickname fetch error: \(err)")
        } else {
            if let nicknames = nicknames {
                for nickname in nicknames {
                    if let nickname = nickname as? Nickname {
                        if nickname.nickname == name {
                            ret = nickname
                            break
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    func getAllNickname() -> [Nickname] {
        var ret: [Nickname] = []
        
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName(kNicknameModel, inManagedObjectContext: self.context)
        request.sortDescriptors = [NSSortDescriptor(key:"nickname", ascending: true)]
        var err: NSError?
        let nicknames = self.context.executeFetchRequest(request, error: &err)
        if err != nil {
            println("Nickname fetch error: \(err)")
        } else {
            if let nicknames = nicknames {
                for nickname in nicknames {
                    if let nickname = nickname as? Nickname {
                        ret.append(nickname)
                    }
                }
            }
        }
        
        return ret
    }
    
    func removeNickname(nickname: Nickname) {
        // remove all musics for delete file
        let musics = nickname.musics.allObjects
        for music in musics {
            if let music = music as? NicoMusic {
                removeMusic(music)
            }
        }
        
        self.context.deleteObject(nickname)
    }
    
    func removeAllNickname() {
        let nicknames = getAllNickname()
        for nickname in nicknames {
            removeNickname(nickname)
        }
    }
    
    func save() {
        var err: NSError?
        if !self.context.save(&err) {
            println(err)
        }
        
        // Notification
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(kNicoMusicUpdateNotification, object: nil, userInfo: nil)
    }
    
    func flushInvalidData() {
        let musics = getAllMusic()
        for music in musics {
            if !music.fileStored {
                let videoId = music.valueForKey("videoId") as? String
                let title = music.valueForKey("title") as? String
                println("Delete Music: \(videoId) - \(title)")
                removeMusic(music)
            }
        }
        
        let nicknames = getAllNickname()
        for nickname in nicknames {
            let musics = nickname.musics
            if musics.count == 0 {
                let n = nickname.valueForKey("nickname") as? String
                println("Delete Nickname: \(n)")
                removeNickname(nickname)
            }
        }
    }
    
}