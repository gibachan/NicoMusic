//
//  SearchViewController.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/30.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class SearchViewController: NicoDownloadViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    private let kCellIdentifier = "SearchCell"
    
    // MARK: Property
    // --------------------------------------------------
    private var search: NicoNicoSearch!
    
    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: UIViewController
    // --------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search = NicoNicoSearch(type: NicoNicoSearchType.Keyword)
        
        // SearchBar
        searchBar.placeholder = "検索キーワードを入力して下さい"
        searchBar.delegate = self
        
        // TableView
        let nib = UINib(nibName:"SearchTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: Method
    // --------------------------------------------------
    func getCellByVideoId(videoId: String) -> SearchTableViewCell? {
        var cell: SearchTableViewCell?
        
        var row = -1
        for i in 0 ..< search.result.count {
            let item = search.result[i]
            if item.videoId == videoId {
                row = i
                break
            }
        }
        if row != -1 {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            cell = tableView.cellForRowAtIndexPath(indexPath) as? SearchTableViewCell
        }
        
        return cell
    }

    // MARK: UISearchBarDelegate
    // --------------------------------------------------
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let keyword = searchBar.text
        
        // Initialize
        tableView.reloadData()
        
        // Hide keyboard
        searchBar.resignFirstResponder()
        
        // Login
        let defaults = NSUserDefaults.standardUserDefaults()
        let email = defaults.stringForKey("email")
        let password = defaults.stringForKey("password")
        
        if email == nil || countElements(email!) == 0 ||
            password == nil || countElements(password!) == 0 {
                alertOK("ダウンロード", message: "ログインが必要です。「設定」からログインしてから実行して下さい。", callback: nil)
                return
        }
        
        let login = NicoNicoLogin.getInstance()
        login.login(email!, password: password!, success: { () -> Void in
            // Indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            var keyword = "歌ってみた " + keyword
            self.search.search(keyword, callback: { () -> Void in
                // indicator
                if self.nico.donwloadingCount == 0 {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                self.tableView.reloadData()
                
                // Scroll to top
                if self.search.result.count > 0 {
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
                }
            })
            }, failure: nil)
        
    }
    
    
    // MARK: UITableViewDelegate
    // --------------------------------------------------
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 115
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect for updating cell view
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        // Get search result
        let item = search.result[indexPath.row]
        
        // Get ThumbnailInfo
        let info = NicoNicoThumbInfo(videoId: item.videoId)
        info.loadInfo()
        
        // Download
        download(info)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if search.result.count > 0 {
            if indexPath.row == search.result.count - 1 {
                let lastCount = search.result.count
                search.searchNext({ () -> Void in
                    if self.search.result.count > lastCount {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    
    // MARK: UITableViewDataSource
    // --------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return search.result.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as SearchTableViewCell
        
        let niconico = NicoNico.getInstance()
        
        let result = search.result[indexPath.row]
        cell.setInfo(result)
        if niconico.isDownloading(result.videoId) {
            cell.showCurtain()
        }
        
        return cell
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
                
                // Alert
                alertOK("ダウンロード", message: "ダウンロードに失敗しました。", callback: nil)
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
}
