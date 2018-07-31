//
//  NSImage.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 01/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

extension NSImage {
    public func tinted(color: NSColor) -> NSImage {
        guard self.isTemplate else { return self }
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        let imageRect = NSRect(origin: NSPoint.zero, size: image.size)
        imageRect.fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
}
