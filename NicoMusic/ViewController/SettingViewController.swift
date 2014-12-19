//
//  SettingViewController.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/03.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let kCellIdentifier = "Cell"
    
    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController
    // --------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    // --------------------------------------------------
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect for updating cell view
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        switch (indexPath.section) {
        case 1:
            performSegueWithIdentifier("login", sender: self)
        case 2:
            let defaults = NSUserDefaults.standardUserDefaults()
            var term: NicoNicoRankingTerm?
            
            switch (indexPath.row) {
            case 0:
                term = NicoNicoRankingTerm.Hourly
            case 1:
                term = NicoNicoRankingTerm.Daily
            case 2:
                term = NicoNicoRankingTerm.Weekly
            case 3:
                term = NicoNicoRankingTerm.Monthly
            case 4:
                term = NicoNicoRankingTerm.Total
            default:
                break
            }
            
            let termValue = term?.rawValue
            defaults.setObject(termValue, forKey: "rankingterm")
            
            tableView.reloadData()
            
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch (indexPath.section) {
        case 1, 2:
            return indexPath
        default:
            return nil
        }
    }
    
    // MARK: UITableViewDataSource
    // --------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "アプリ"
        case 1:
            return "ニコニコ動画"
        case 2:
            return "歌ってみたランキング"
        default:
            return ""
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 2:
            return 5
        default:
            return 1
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:kCellIdentifier)
        }
        
        switch (indexPath.section) {
        case 0:
            cell.textLabel?.text = "バージョン"
            if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
                cell.detailTextLabel?.text = version
            }
        case 1:
            cell.textLabel?.text = "ログイン"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        case 2:
            let defaults = NSUserDefaults.standardUserDefaults()
            let termValue = defaults.integerForKey("rankingterm")
            var term = NicoNicoRankingTerm(rawValue: termValue)
            
            cell.accessoryType = .None
            
            switch (indexPath.row) {
            case 0:
                cell.textLabel?.text = "毎時"
                if term == NicoNicoRankingTerm.Hourly {
                    cell.accessoryType = .Checkmark
                }
            case 1:
                cell.textLabel?.text = "２４時間"
                if term == NicoNicoRankingTerm.Daily {
                    cell.accessoryType = .Checkmark
                }
                
            case 2:
                cell.textLabel?.text = "週間"
                if term == NicoNicoRankingTerm.Weekly {
                    cell.accessoryType = .Checkmark
                }
            case 3:
                cell.textLabel?.text = "月間"
                if term == NicoNicoRankingTerm.Monthly {
                    cell.accessoryType = .Checkmark
                }
            case 4:
                cell.textLabel?.text = "合計"
                if term == NicoNicoRankingTerm.Total {
                    cell.accessoryType = .Checkmark
                }
            default:
                break
            }
            
        default:
            cell.textLabel?.text = "not implemented"
        }
        
        return cell
    }
}

