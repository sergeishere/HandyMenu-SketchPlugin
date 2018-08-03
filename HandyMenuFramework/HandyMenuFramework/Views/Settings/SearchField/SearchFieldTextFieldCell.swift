//
//  SearchFieldTextFieldCell.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

class SearchFieldTextFieldCell: NSTextFieldCell {
    
    public var leftPadding: CGFloat = 0.0
    public var rightPadding: CGFloat = 0.0
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        
        guard let controlView = controlView,
        let font = self.font else { return super.drawingRect(forBounds: rect) }
        
        let layoutManager = NSLayoutManager()
        let height = layoutManager.defaultLineHeight(for: font)

        let fieldRect = NSRect(x: leftPadding,
                               y: (controlView.bounds.height - height)/2 - 1,
                               width: controlView.bounds.width - leftPadding - rightPadding,
                               height: height + 1)
        
        return fieldRect
    }
    
    override func resetCursorRect(_ cellFrame: NSRect, in controlView: NSView) {
        var newRect = cellFrame
        newRect.size.width -= rightPadding
        super.resetCursorRect(newRect, in: controlView)
    }
}
