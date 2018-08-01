//
//  BorderedBackgroundView.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 01/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import AppKit

@IBDesignable
class ControlView: NSView {
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.wantsLayer = true
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = self.borderColor.cgColor
        self.layer?.backgroundColor = self.backgroundColor.cgColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
