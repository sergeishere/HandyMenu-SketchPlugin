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
    
    // MARK: - Public Properties
    public weak var delegate: SettingsWindowControllerDelegate?

    // MARK: - Lifecycle
    override public func windowDidLoad() {
        super.windowDidLoad()

    }
}


// MARK: - Actions Handling
extension SettingsWindowController {
    
    @IBAction func save(_ sender: Any) {
        self.delegate?.settingsWindowController(self, didUpdate: [])
        self.window?.close()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.window?.close()
    }
    
}
