//
//  RankingController.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/02.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class RankingViewController: NicoDownloadViewController, UITableViewDelegate, UITableViewDataSource {
    private let kCellIdentifier = "RankingCell"
    
    // MARK: Property
    // --------------------------------------------------
    private var ranking: NicoNicoRanking!
    private var formatter: NSDateFormatter!
    private var refreshControl:UIRefreshControl!

    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController
    // --------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ranking = NicoNicoRanking()
        
        // NSDateFormatter
        formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        
        // Table view
        let nib = UINib(nibName:"RankingTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshRanking", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Method
    // --------------------------------------------------
    func refreshRanking() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.updateRanking()
        })
    }
    
    func updateRanking() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let termValue = defaults.integerForKey("rankingterm")
        var term: NicoNicoRankingTerm?
        
        if termValue == 0 {
            return
        } else {
            term = NicoNicoRankingTerm(rawValue: termValue)
        }
        
        ranking.updateRanking(term!, callback: { () -> Void in
            dispatch_sync(dispatch_get_main_queue(), {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
                // Last updated date
                let dateStr =  self.formatter.stringFromDate(NSDate())
                self.refreshControl.attributedTitle = NSAttributedString(string: "Last update: " + dateStr)
                
                // Indicator
                if self.nico.donwloadingCount == 0 {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            })
        })
    }
    
    func getCellByVideoId(videoId: String) -> RankingTableViewCell? {
        var cell: RankingTableViewCell?
        
        var row = -1
        for i in 0 ..< ranking.count {
            let info = ranking.objectAtIndex(i)
            if let info = info {
                if info.videoId == videoId {
                    row = i
                    break
                }
            }
        }
        if row != -1 {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            cell = tableView.cellForRowAtIndexPath(indexPath) as? RankingTableViewCell
        }
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    // --------------------------------------------------
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect for updating cell view
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        // Get ranking data
        if let info = ranking.objectAtIndex(indexPath.row) {
            download(info)
        }
        
    }
    
    // MARK: Download notification
    // --------------------------------------------------
    override func downloadStarted(notification: NSNotification?) {
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
        if let userInfo = notification?.userInfo {
            let videoId = userInfo["videoId"] as? String
            if let videoId = videoId {
                // tableview cell
                if let cell = getCellByVideoId(videoId) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.hideCurtain()
                    })
                }
            }
        }
    }
    
    override func downloadFailed(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            let videoId = userInfo["videoId"] as? String
            if let videoId = videoId {
                // Update Cell
                if let cell = getCellByVideoId(videoId) {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cell = self.getCellByVideoId(videoId) {
                            cell.hideCurtain()
                        }
                    })
                }
                
            }
        }
    }
    
    override func downloadProgressed(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            if let videoId = userInfo["videoId"] as? String {
                if let progress = userInfo["progress"] as? Float {
                    if let cell = self.getCellByVideoId(videoId) {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cell = self.getCellByVideoId(videoId) {
                                cell.setProgress(progress)
                            }
                        })
                    }
                }
            }
        }
    }
    
    override func downloadCanceled(notification: NSNotification?) {
        if let userInfo = notification?.userInfo {
            if let videoId = userInfo["videoId"] as? String {
                if let cell = getCellByVideoId(videoId) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.hideCurtain()
                    })
                }
            }
        }
    }
    
    
    // MARK: UITableViewDataSource
    // --------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ranking.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as RankingTableViewCell
        
        if let info = ranking.objectAtIndex(indexPath.row) {
            cell.setInfo(indexPath.row + 1, info: info)
            if nico.isDownloading(info.videoId) {
                cell.showCurtain()
            }
        }
        
        return cell
    }
}
