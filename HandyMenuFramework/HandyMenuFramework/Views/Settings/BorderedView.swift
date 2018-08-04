//
//  BorderedBackgroundView.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 01/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

class BorderedView: NSView {
    
    @IBInspectable public var isHighlighted: Bool = false {
        didSet {
            self.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
        }
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.wantsLayer = true
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor.gridColor.cgColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
