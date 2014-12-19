//
//  MusicViewControll.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/03.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class MusicViewController: NicoDownloadViewController, UITableViewDelegate, UITableViewDataSource {
    private let kCellIdentifier = "MusicCell"
 
    // MARK: Property
    // --------------------------------------------------
    var nicknames: [Nickname] = []
    
    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    // MARK: IBAction
    // --------------------------------------------------
    @IBAction func onPlay(sender: UIBarButtonItem) {
        performSegueWithIdentifier("player", sender: self)
    }

    // MARK: UIViewController
    // --------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view
        let nib = UINib(nibName:"MusicTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateMusicData()
        updatePlayButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Method
    // --------------------------------------------------
    func updatePlayButton() {
        let player = MusicPlayer.getInstance()
        if player.playing {
            playButton.title = "再生中 >"
            playButton.enabled = true
        } else {
            playButton.title = ""
            playButton.enabled = false
        }
    }
    
    func updateMusicData() {
        let musicMgr = NicoMusicManager.getInstance()
        nicknames = musicMgr.getAllNickname()
        self.tableView.reloadData()
    }
    
    func deleteMusic(music: NicoMusic) {
        let nickname = music.nickname as Nickname
        let musicMgt = NicoMusicManager.getInstance()
        
        if nickname.musics.allObjects.count == 1 {
            musicMgt.removeNickname(nickname)
        } else {
            musicMgt.removeMusic(music)
        }

        musicMgt.save()
    }
    
    func getCellByVideoId(videoId: String) -> MusicTableViewCell? {
        for i in 0 ..< nicknames.count {
            let nickname = nicknames[i]
            let musics = nickname.musics.allObjects
            for j in 0 ..< musics.count {
                if let music = musics[j] as? NicoMusic {
                    if music.videoId == videoId {
                        let indexPath = NSIndexPath(forRow: j, inSection: i)
                        let cell = tableView.cellForRowAtIndexPath(indexPath) as? MusicTableViewCell
                        return cell
                    }
                }
                
            }
        }
        return nil
    }
    
    // MARK: Download notification
    // --------------------------------------------------
    override func downloadStarted(notification: NSNotification?) {
        super.downloadStarted(notification)
        
        if let userInfo = notification?.userInfo {
            let videoId = userInfo["videoId"] as? String
            if let videoId = videoId {
                if let cell = getCellByVideoId(videoId) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.showCurtain()
                    })
                }
            }
        }
    }
    
    override func downloadSucceeded(notification: NSNotification?) {
        super.downloadSucceeded(notification)
        
        if let userInfo = notification?.userInfo {
            let videoId = userInfo["videoId"] as? String
            if let videoId = videoId {
                if let cell = getCellByVideoId(videoId) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.updateMusicData()
                    })
                }
            }
        }
    }
    
    override func downloadFailed(notification: NSNotification?) {
        super.downloadFailed(notification)
        
        if let userInfo = notification?.userInfo {
            let videoId = userInfo["videoId"] as? String
            if let videoId = videoId {
                // Remove music
                let musicMgr = NicoMusicManager.getInstance()
                if let music = musicMgr.getMusicByVideoId(videoId) {
                    deleteMusic(music)
                }
                
                // Upate cell
                updateMusicData()
            }
        }
    }
    
    override func downloadProgressed(notification: NSNotification?) {
        super.downloadProgressed(notification)
        
        if let userInfo = notification?.userInfo {
            if let videoId = userInfo["videoId"] as? String {
                if let progress = userInfo["progress"] as? Float {
                    if let cell = self.getCellByVideoId(videoId) {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.setProgress(progress)
                        })
                    }
                }
            }
        }
    }
    
    override func downloadCanceled(notification: NSNotification?) {
        super.downloadCanceled(notification)
        
        if let userInfo = notification?.userInfo {
            if let videoId = userInfo["videoId"] as? String {
                // Remove music
                let musicMgr = NicoMusicManager.getInstance()
                if let music = musicMgr.getMusicByVideoId(videoId) {
                    deleteMusic(music)
                    updateMusicData()
                }
            }
        }
        
    }
    
    // MARK: NicoMusicManager notification
    // --------------------------------------------------
    func musicUpdated(notification: NSNotification?) {
        updateMusicData()
    }
    
    // MARK: MusicPlayer notification
    // --------------------------------------------------
    func playMusic(notification: NSNotification?) {
        updatePlayButton()
    }
    
    func stopMusic(notification: NSNotification?) {
        updatePlayButton()
    }
    
    // MARK: UITableViewDelegate
    // --------------------------------------------------
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect for updating cell view
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let section = indexPath.section
        let row = indexPath.row
        let selectedNickname = nicknames[section]
        let selectedMusic = selectedNickname.musics.allObjects[row] as NicoMusic
        
        // Cancel downloading
        let selectedVideoId = selectedMusic.valueForKey("videoId") as? String
        if selectedVideoId == nil {
            return
        }
        
        if nico.isDownloading(selectedVideoId!) {
            alertYesNo("ダウンロード", message: "ダウンロード中です。\nキャンセルしますか？", yesCallback: { () -> Void in
                // Cancel downloading
                self.nico.cancelDownloading(selectedVideoId!)
                
                // Remove music
                let musicMgr = NicoMusicManager.getInstance()
                if let music = musicMgr.getMusicByVideoId(selectedVideoId!) {
                    musicMgr.removeMusic(music)
                    musicMgr.save()
                }
            }, noCallback: { () -> Void in
                
            })
            return
        }

        // Check file
        if !selectedMusic.fileStored {
            return
        }
        
        // Collect music data to play
        var playlist: [NicoMusic] = []
        var current = 0
        
        for nickname in nicknames {
            let musics = nickname.musics.allObjects as [NicoMusic]
            for music in musics {
                if music.fileStored {
                    playlist.append(music)
                    if let videoId = music.valueForKey("videoId") as? String {
                        if videoId == selectedVideoId! {
                            current = playlist.count - 1
                        }
                    }
                }
            }
        }
        
        // Play
        let player = MusicPlayer.getInstance()
        player.play(playlist, current: current)
        
        performSegueWithIdentifier("player", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section >= nicknames.count {
            return
        }
        let nickname = nicknames[section]
        
        if row >= nickname.musics.allObjects.count {
            return
        }
        let music = nickname.musics.allObjects[row] as NicoMusic
        
        if editingStyle == .Delete {
            // Is the music playing right now?
            let player = MusicPlayer.getInstance()
            if player.playing {
                if let currentMusic = player.currentMusic {
                    if currentMusic.videoId == music.videoId {
                        alertOK("削除", message: "現在再生中のデータは削除できません。", callback: nil)
                        return
                    }
                }
            }
            
            // Delete
            deleteMusic(music)
            updateMusicData()
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "削除"
    }
    
    // MARK: UITableViewDataSource
    // --------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return nicknames.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let nickname = nicknames[section]
        return nickname.nickname
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nickname = nicknames[section]
        let musics = nickname.musics
        return musics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as MusicTableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        let nickname = nicknames[section]
        let music = nickname.musics.allObjects[row] as NicoMusic
        
        cell.setInfo(music)
        if nico.isDownloading(music.videoId) || !music.fileStored {
            cell.showCurtain()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        let nickname = nicknames[section]
        let music = nickname.musics.allObjects[row] as NicoMusic
        let nico = NicoNico.getInstance()
        
        if nico.isDownloading(music.videoId) {
            return false
        } else {
            return true
        }
    }
}
