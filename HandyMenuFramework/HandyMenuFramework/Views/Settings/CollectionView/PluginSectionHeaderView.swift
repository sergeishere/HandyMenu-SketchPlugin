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
    
    public var searchingString: String = "" {
        didSet {
            guard !self.searchingString.isEmpty else { return }
            let range = (self.pluginNameTextField.stringValue as NSString).range(of: self.searchingString, options: .caseInsensitive)
            let attributedString = NSMutableAttributedString(string: self.pluginNameTextField.stringValue)
            attributedString.setAttributes([.backgroundColor : NSColor.selectedTextBackgroundColor], range: range)
            self.pluginNameTextField.attributedStringValue = attributedString
        }
    }
    
}
