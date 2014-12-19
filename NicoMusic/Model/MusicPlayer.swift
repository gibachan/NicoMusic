//
//  MusicPlayer.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/14.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import AVFoundation

let kMusicPlayerPlayNotification = "MusicPlayerPlayNotification"
let kMusicPlayerProgressNotification = "MusicPlayerProgressNotification"
let kMusicPlayerStopNotification = "MusicPlayerStopNotification"

private let singleton = MusicPlayer()

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    enum MusimPlayerRepeat {
        case NoRepeat, RepeatOne, RepeatAll
    }
    
    // MARK: Property
    // --------------------------------------------------
    private var musics: [NicoMusic]
    private var current: Int
    private var audioPlayer: AVAudioPlayer?
    private var audioTimer: NSTimer?
    private var center: NSNotificationCenter!
    private var pausing: Bool
    
    var repeat: MusimPlayerRepeat
    
    var currentMusic: NicoMusic? {
        get {
            if current >= 0 && current < musics.count {
                return musics[current]
            } else {
                return nil
            }
        }
    }
    
    var playing: Bool {
        get {
            if let player = audioPlayer {
                return player.playing
            } else {
                return false
            }
        }
    }
    
    var duration: NSTimeInterval {
        get {
            if let player = audioPlayer {
                return player.duration
            } else {
                return 0
            }
        }
    }
    
    
    var currentTime: NSTimeInterval {
        get {
            if let player = audioPlayer {
                return player.currentTime
            } else {
                return 0
            }
        }
        
        set(newValue) {
            audioPlayer?.currentTime = newValue
        }
    }

    // MARK: Method
    // --------------------------------------------------
    class func getInstance() -> MusicPlayer {
        return singleton
    }
    
    private override init() {
        musics = []
        current = -1
        repeat = .NoRepeat
        center = NSNotificationCenter.defaultCenter()
        pausing = false
        
        super.init()
        
        // Notification
        center.addObserver(self, selector: "routeChange:", name: AVAudioSessionRouteChangeNotification, object: nil)

    }
    
    func routeChange(notification: NSNotification?) {
        // Check if the head-set is plugged or unplugged?
        var isPrevPlugged = false
        if let userInfo = notification?.userInfo {
            if let prevDesc = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for desc in prevDesc.outputs {
                    if let desc = desc as? AVAudioSessionPortDescription {
                        if desc.portType == AVAudioSessionPortHeadphones {
                            isPrevPlugged = true
                            break
                        }
                    }
                }
                
            }
        }
        
        if isPrevPlugged {
            pause()
        }
    }
    
    
    func play(musics: [NicoMusic], current: Int = 0) {
        // Data check
        var isValid = false
        for music in musics {
            if music.fileStored {
                isValid = true
                break
            }
        }
        if !isValid {
            println("No valid music data")
            return
        }
        
        self.musics = musics
        self.current = current
        pausing = false
        play()
    }
    
    func play() {
        if pausing {
            pausing = false
            audioPlayer?.play()
            return
        }
        
        if current < 0 || current >= musics.count {
            println("Current position is invalid")
            stop()
            return
        }

        let music = musics[current]
        let musicMgr = NicoMusicManager.getInstance()
        let musicDirPath = musicMgr.musicDirPath
        let fileName = music.valueForKey("fileName") as? String
        
        if fileName == nil {
            var title = music.valueForKey("title") as? String
            println("\(title) file is not found")
            // Next music
            musics.removeAtIndex(current)
            if musics.count > 0 {
                play()
            } else {
                stop()
            }
            return
        }
        
        let musicPath = musicDirPath + "/" + fileName!
        
        let fileMgr = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        if fileMgr.fileExistsAtPath(musicPath, isDirectory: &isDir) && !isDir {
            let fileURL = NSURL.fileURLWithPath(musicPath)
            
            audioPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
            
            if let player = audioPlayer {
                player.delegate = self

                // play
                player.play()
                
                // timer
                audioTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "onTimer:", userInfo: nil, repeats: true)
                
                // notification
                center.postNotificationName(kMusicPlayerPlayNotification, object: nil, userInfo: nil)
                
                return
            }
        }
        
        var title = music.valueForKey("title") as? String
        println("\(title) file is not found")
        
        // Next music
        musics.removeAtIndex(current)
        if musics.count > 0 {
            play()
        } else {
            stop()
        }
        
    }
    
    func pause() {
        pausing = true
        audioPlayer?.pause()
    }
    
    func stop() {
        if let player = audioPlayer {
            player.currentTime = 0
            player.stop()
        }
        audioPlayer = nil
        
        // notification
        center.postNotificationName(kMusicPlayerStopNotification, object: nil, userInfo: nil)
    }
    
    func rewind() {
        pausing = false
        if let player = audioPlayer {
            current--
            if current < 0 {
                current = musics.count - 1
            }
            
            if player.playing {
                play()
            } else {
                play()
                pause()
            }
        }
    }
    
    func advance() {
        pausing = false
        if let player = audioPlayer {
            current++
            if current >= musics.count {
                current = 0
            }
            
            if player.playing {
                play()
            } else {
                play()
                pause()
            }
        }
        
    }
    
    func onTimer(sender: AnyObject) {
        if let player = audioPlayer {
            let currentTime = player.currentTime
            center.postNotificationName(kMusicPlayerProgressNotification, object: nil, userInfo: nil)
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    // --------------------------------------------------
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        switch (repeat) {
        case .NoRepeat:
            stop()
        case .RepeatOne:
            play()
        case .RepeatAll:
            current++
            if current >= musics.count {
                current = 0
            }
            
            play()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("Audio player Error: \(error)")
        stop()
    }

}
