//
//  Preference.swift
//  Sharpener
//
//  Created by Inti Guo on 2/18/16.
//  Copyright © 2016 Inti Guo. All rights reserved.
//

import Foundation

class Preference {
    static var vectorizeSize = CGSize(width: 750, height: 1000)
    
    class func versionString() -> String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
    }
}