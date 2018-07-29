//
//  PluginSectionHeaderView.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 27/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

class PluginSectionHeaderView: NSView {
    
    @IBOutlet private weak var pluginNameTextField: NSTextField!
    
    public var title: String {
        set {
            self.pluginNameTextField.stringValue = newValue
        }
        get {
            return self.title
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
