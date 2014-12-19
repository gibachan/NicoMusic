//
//  PlayerViewController.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/16.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController, AVAudioPlayerDelegate {

    // MARK: Property
    // --------------------------------------------------
    private var mpVolumeView: MPVolumeView!
    private var player: MusicPlayer!
    private var timeFormatter: NSDateFormatter!
    
    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var advanceButton: UIButton!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var gotoNicoNicoButton: UIButton!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    // MARK: IBAction
    // --------------------------------------------------
    @IBAction func onPlayOrPause(sender: UIButton) {
        if player.playing {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func onRewind(sender: UIButton) {
        player.rewind()
        updateMusicData()
    }
    
    @IBAction func onAdvance(sender: UIButton) {
        player.advance()
        updateMusicData()
    }
    
    @IBAction func onSeek(sender: UISlider) {
        player.currentTime = NSTimeInterval(seekSlider.value)
    }
    
    @IBAction func onGoToNicoNico(sender: UIButton) {
        if let music = player.currentMusic {
            let urlStr = "http://www.nicovideo.jp/watch/" + music.videoId
            let url = NSURL(string: urlStr)
            if let url = url {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
    }
    
    @IBAction func onRepeat(sender: UIButton) {
        switch (player.repeat) {
        case .NoRepeat:
            player.repeat = .RepeatOne
        case .RepeatOne:
            player.repeat = .RepeatAll
        case .RepeatAll:
            player.repeat = .NoRepeat
        }
        
        updateRepeatButton()
    }
    
    // MARK: UIViewController
    // --------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Player
        player = MusicPlayer.getInstance()
        
        // NSDateFormatter
        timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "mm:ss"
        timeFormatter.timeZone = NSTimeZone(name: "UTC")
        
        // Seek Slider
        seekSlider.value = 0
        seekSlider.setThumbImage(UIImage(named: "slider_bar"), forState: .Normal)
        
        // Button
        rewindButton.setImage(UIImage(named: "rewind_deactive"), forState: .Highlighted)
        advanceButton.setImage(UIImage(named: "advance_deactive"), forState: .Highlighted)
        
        // Volume
        mpVolumeView = MPVolumeView(frame: volumeView.bounds)
        volumeView.addSubview(mpVolumeView)
        volumeView.backgroundColor = UIColor.clearColor()
        
        // Notification
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "playMusic:", name: kMusicPlayerPlayNotification, object: nil)
        center.addObserver(self, selector: "progressMusic:", name: kMusicPlayerProgressNotification, object: nil)
        center.addObserver(self, selector: "stopMusic:", name: kMusicPlayerStopNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Volume
        mpVolumeView.frame = volumeView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateMusicData()
        updatePlayButton()
        updateRepeatButton()
        
        // FirstResponder
        self.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // FirstResponder
        self.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: FirstResponderDelegate
    // --------------------------------------------------
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        println("remoteControlReceivedWithEvent")
        
        switch (event.subtype) {
        case .RemoteControlPlay, .RemoteControlPause, .RemoteControlTogglePlayPause:
            if player.playing {
                pause()
            } else {
                play()
            }
        case .RemoteControlPreviousTrack:
            player.rewind()
            updateMusicData()
        case .RemoteControlNextTrack:
            player.advance()
            updateMusicData()
        case .RemoteControlStop:
            pause()
        default:
            break
        }
        
    }
    
    
    // MARK: Method
    // --------------------------------------------------
    func play() {
        player.play()
        updatePlayButton()
    }
    
    func pause() {
        player.pause()
        updatePlayButton()
    }
    
    func updateMusicData() {
        if let music = player.currentMusic {
            let nickname = music.nickname as Nickname
            let totalTime = NSDate(timeIntervalSince1970: player.duration)
            let totalTimeStr = timeFormatter.stringFromDate(totalTime)
            let curentTime = NSDate(timeIntervalSince1970: player.currentTime)
            let curentTimeStr = timeFormatter.stringFromDate(curentTime)
            
            nicknameLabel.text = nickname.nickname
            titleLabel.text = music.title
            totalTimeLabel.text = totalTimeStr
            currentTimeLabel.text = curentTimeStr
            
            seekSlider.value = Float(player.currentTime)
            seekSlider.maximumValue = Float(player.duration)
            thumbnailImage.image = UIImage(data: music.thumbnail)
            
            let playingInfo = [MPMediaItemPropertyArtist: nickname.nickname,
                MPMediaItemPropertyAlbumTitle: "歌ってみた",
                MPMediaItemPropertyTitle: music.title]
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingInfo

        }
    }

    func updatePlayButton() {
        var imageName = "play"
        var highlightedImageName = "play_deactive"
        
        if player.playing {
            imageName = "pause"
            highlightedImageName = "pause_deactive"
        }
        
        playButton.setImage(UIImage(named: imageName), forState: .Normal)
        playButton.setImage(UIImage(named: highlightedImageName), forState: .Highlighted)
    }
    
    func updateRepeatButton() {
        switch (player.repeat) {
        case .NoRepeat:
            repeatButton.setTitle("リピートなし", forState: UIControlState.Normal)
        case .RepeatOne:
            repeatButton.setTitle("１曲リピート", forState: UIControlState.Normal)
        case .RepeatAll:
            repeatButton.setTitle("全曲リピート", forState: UIControlState.Normal)
        }
    }
    
    func updateSeekbar() {
        let currentTime = player.currentTime
        
        // Slider
        seekSlider.value = Float(currentTime)
        
        // Time label
        let time = NSDate(timeIntervalSince1970: currentTime)
        let timeStr = timeFormatter.stringFromDate(time)
        currentTimeLabel.text = timeStr
    }
    
    
    // MARK: MusicPlayer notification
    // --------------------------------------------------
    func playMusic(notification: NSNotification?) {
        updateMusicData()
    }
    
    func progressMusic(notification: NSNotification?) {
        updateSeekbar()
    }
    
    func stopMusic(notification: NSNotification?) {
        updateSeekbar()
        updatePlayButton()
    }

}