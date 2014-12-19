//
//  RankingTableViewCell.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/02.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {
    
    // MARK: Property
    // --------------------------------------------------
    var curtainView: UIView?
    var progressView: UIProgressView?
    var progress: Float = 0
    
    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var mylistLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var thumbImage: UIImageView!
    
    // MARK: NSObject
    // --------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()

            }

    // MARK: UITableViewCell
    // --------------------------------------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbImage.image = nil
        hideCurtain()
    }
    
    // MARK: Method
    // --------------------------------------------------
    func setInfo(rank: Int, info: NicoNicoThumbInfo) {
        rankLabel.text = "\(rank)"
        titleLabel.text = info.title
        pubDateLabel.text = info.getFirstRetrieve()
        viewLabel.text = info.viewCounter
        commentLabel.text = info.commentNum
        mylistLabel.text = info.mylistCounter
        nicknameLabel.text = info.userNickname
        lengthLabel.text = info.length
        
        // thumbnail
        let url = NSURL(string: info.thumbnailUrl)
        if let url = url {
            let req = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) { (res, data, err) in
                if err != nil || data == nil {
                    return
                } 
                
                let image = UIImage(data: data)
                self.thumbImage.image = UIImage(data: data)
            }
        }
        
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
