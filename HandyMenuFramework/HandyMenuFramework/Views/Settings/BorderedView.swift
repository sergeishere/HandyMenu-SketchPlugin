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
        self.render()
    }
    
    override func layout() {
        super.layout()
        self.render()
        self.needsDisplay = true
    }
    
    private func render() {
        self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor.borderColor.cgColor
    }
    
}
