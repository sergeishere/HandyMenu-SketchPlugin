//
//  MenuController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation
import os.log

public class MenuController {
    
    // MARK: - Private Variables
    private var menuGroups: [Int:NSMenu] = [:]
    
    
    public func configure(for groups:[MenuGroup]) {
        
    }
    
    public func show(for shortcut: Shortcut) {
        if let menu = self.menuGroups[shortcut.hashValue] {
            menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        }
    }
    
    
}
