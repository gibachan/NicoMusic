//
//  AlertUtil.swift
//  NicoMusic
//
//  Created by gibachan on 2014/12/17.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertOK(title: String, message: String, callback: (() -> Void)? ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in
            // callback?() -> Compile error
            if let callback = callback {
                callback()
            }
        }
        
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func alertYesNo(title: String, message: String, yesCallback: (() -> Void)?, noCallback: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { action in
            if let callback = yesCallback {
                callback()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .Cancel) { action in
            if let callback = noCallback {
                callback()
            }
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
