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
    
    public func configure(for data: Collection) {
        
        let titleItem = NSMenuItem(title: data.title, action: nil, keyEquivalent: "")
        self.addItem(titleItem)
        self.addItem(NSMenuItem.separator())

        for (index, item) in data.items.enumerated() {
            switch item {
            case .separator:
                if data.autoGrouping { break }
                self.addItem(NSMenuItem.separator())
            case .command(let commandData):
                if data.autoGrouping, index > 0, case let CollectionItem.command(previousCommand) = data.items[index-1], previousCommand.pluginID != commandData.pluginID {
                    self.addItem(NSMenuItem.separator())
                }
                let newMenuItem = NSMenuItem(title: commandData.name, action: #selector(runPluginCommand(sender:)), keyEquivalent: "")
                newMenuItem.target = self
                newMenuItem.representedObject = commandData
                self.addItem(newMenuItem)
            }
        }
        
        
    }
    
    @objc private func runPluginCommand(sender: NSMenuItem) {
        guard let itemData = sender.representedObject as? Command else { return }
        SketchAppBridge.sharedInstance().runSketchPluginCommand(itemData.commandID, from: itemData.pluginID)
    }
}
