//
//  CommandCollectionViewItem.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 26/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa
import CoreGraphics

class CommandCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet private weak var contentView: NSView!
    @IBOutlet private weak var checkmarkImageView: NSImageView! {
        didSet {
            self.checkmarkImageView.image = self.checkmarkImageView.image?.tinted(color: NSColor.green)
        }
    }
    
    public var isUsed: Bool = false {
        didSet {
            self.checkmarkImageView.isHidden = !self.isUsed
            self.textField?.textColor = self.isUsed ? NSColor.controlTextColor.withAlphaComponent(0.3) : NSColor.controlTextColor
        }
    }
    
    public var commandName:String = "" {
        didSet {
            self.textField?.stringValue = self.commandName
        }
    }
    
    public func configure(_ commandName: String, isUsed:Bool) {
        plugin_log("%@ isUsed: %@", commandName, isUsed)
        self.commandName = commandName
        self.isUsed = isUsed
    }
    
    override func prepareForReuse() {
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        self.textField?.textColor = NSColor.controlTextColor
        self.isUsed = false
    }
    
    func setHighlight(_ selected: Bool) {
        self.view.layer?.backgroundColor = selected ? NSColor.alternateSelectedControlColor.cgColor : NSColor.clear.cgColor
        self.textField?.textColor = selected ? NSColor.white : NSColor.controlTextColor
    }
}
