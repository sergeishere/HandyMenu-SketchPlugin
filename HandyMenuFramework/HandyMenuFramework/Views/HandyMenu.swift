//
//  HandyMenu.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

class HandyMenu: NSMenu {
    
    static func configure(for data: MenuData) -> NSMenu {
        let menu = NSMenu()
        for item in data.items {
            
            var newMenuItem:NSMenuItem
            
            switch item {
            case .separator:
                newMenuItem = NSMenuItem.separator()
            case .command(let commandData):
                newMenuItem = NSMenuItem(title: commandData.name, action: #selector(runPluginCommand(sender:)), keyEquivalent: "")
                newMenuItem.representedObject = commandData
            }
            
            menu.addItem(newMenuItem)
        }
        return menu
    }
    
    @objc private func runPluginCommand(sender: NSMenuItem) {
        guard let itemData = sender.representedObject as? PluginCommandData else { return }
        SketchApp.bridge.runPluginCommand(with: itemData)
    }
}
