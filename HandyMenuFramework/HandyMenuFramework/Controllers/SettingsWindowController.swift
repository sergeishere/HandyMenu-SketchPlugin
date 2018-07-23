//
//  SettingsWindowController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

public protocol SettingsWindowControllerDelegate: class {
    func settingsWindowController(_ settingsWindowController: SettingsWindowController, didUpdate menuData:[MenuData])
}

public class SettingsWindowController: NSWindowController {
    
    public weak var delegate: SettingsWindowControllerDelegate?

    override public func windowDidLoad() {
        super.windowDidLoad()

    }
    
}
