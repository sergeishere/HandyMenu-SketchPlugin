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
    @IBOutlet private weak var pluginImageView: NSImageView!
    
    public var title: String = "" {
        didSet {
            self.pluginNameTextField.stringValue = self.title
        }
    }
    
    public var image: NSImage? {
        didSet {
            self.pluginImageView.image = self.image
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
