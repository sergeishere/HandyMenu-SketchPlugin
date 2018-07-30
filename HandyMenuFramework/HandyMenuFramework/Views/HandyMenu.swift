//
//  HandyMenu.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa
import os.log

class HandyMenu: NSMenu {
    
    public func configure(for data: MenuData) {
        
        let titleItem = NSMenuItem(title: data.title, action: nil, keyEquivalent: "")
        self.addItem(titleItem)

        for item in data.items {
            var newMenuItem:NSMenuItem
            switch item {
            case .separator:
                newMenuItem = NSMenuItem.separator()
            case .command(let commandData):
                newMenuItem = NSMenuItem(title: commandData.name, action: #selector(runPluginCommand(sender:)), keyEquivalent: "")
                newMenuItem.target = self
                newMenuItem.representedObject = commandData
            }
            
            self.addItem(newMenuItem)
        }
        
        
    }
    
    @objc private func runPluginCommand(sender: NSMenuItem) {
        guard let itemData = sender.representedObject as? PluginCommandData else { return }
        SketchAppBridge.sharedInstance().runSketchPluginCommand(itemData.commandID, from: itemData.pluginID)
    }
}
