//
//  MenuController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//
public class MenuController {
    
    // MARK: - Private Variables
    private var menus: [Int:NSMenu] = [:]
    
    public func configure(for collections:[Collection]) {
        self.menus = [:]
        for collectionData in collections {
            let newMenu = HandyMenu()
            newMenu.configure(for: collectionData)
            menus[collectionData.shortcut.hashValue] = newMenu
        }
    }
    
    public func show(for shortcut: Shortcut) {
        if let menu = self.menus[shortcut.hashValue] {
            menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        }
    }
    
    
}
