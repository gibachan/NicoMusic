//
//  MusicTableViewCell.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/15.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    // MARK: Property
    // --------------------------------------------------
    var curtainView: UIView?
    var progressView: UIProgressView?
    var progress: Float = 0

    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbImage: UIImageView!
    
    
    // MARK: NSObject
    // --------------------------------------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbImage.image = nil
        hideCurtain()
    }
    
    // MARK: UITableViewCell
    // --------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = ""
    }

    // MARK: Method
    // --------------------------------------------------
    func setInfo(music: NicoMusic) {
        titleLabel.text = music.title
        thumbImage.image = UIImage(data: music.thumbnail)
    }
    
    func showCurtain() {
        if curtainView != nil {
            return
        }
        
        // progress
        let frame = self.contentView.bounds
        curtainView = UIView(frame: frame)
        curtainView!.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        
        progressView = UIProgressView(frame: CGRectMake(0, 0, frame.width * 0.8, 10))
        progressView!.transform = CGAffineTransformMakeScale(1.0, 2.0)
        progressView!.progressTintColor = UIColor(red: 135 / 255, green: 135 / 255, blue: 1.0, alpha: 1.0)
        progressView!.trackTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        progressView!.layer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        progressView!.setProgress(progress, animated: false)
        
        curtainView!.addSubview(progressView!)
        self.contentView.addSubview(curtainView!)
    }
    
    
    func setProgress(progress: Float) {
        self.progress = progress
        progressView?.setProgress(self.progress, animated: false)
    }
    
    func hideCurtain() {
        progress = 0
        progressView?.removeFromSuperview()
        progressView = nil
        curtainView?.removeFromSuperview()
        curtainView = nil
    }
}