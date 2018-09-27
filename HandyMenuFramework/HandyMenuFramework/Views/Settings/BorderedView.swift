//
//  BorderedBackgroundView.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 01/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

class BorderedView: NSView {
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
        self.layer?.borderWidth = 1.0
        if #available(OSX 10.14, *) {
            self.layer?.borderColor = NSColor.separatorColor.cgColor
        } else {
            self.layer?.borderColor = NSColor.controlColor.cgColor
        }
        
    }
    
    override func layout() {
        super.layout()
        self.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
        if #available(OSX 10.14, *) {
            self.layer?.borderColor = NSColor.separatorColor.cgColor
        } else {
            self.layer?.borderColor = NSColor.controlColor.cgColor
        }
        self.needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
