//
//  CommandCollectionViewItem.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 26/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

protocol CommandCollectionViewItemDelegate: class {
    func doubleClick(on item: CommandCollectionViewItem)
}

class CommandCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet private weak var contentView: NSView!
    
    public weak var delegate: CommandCollectionViewItemDelegate?
    
    public var isUsed: Bool = false {
        didSet {
            self.textField?.stringValue = self.isUsed ? "✓ " + commandName : commandName
            self.textField?.textColor = self.isUsed ? NSColor.controlTextColor.withAlphaComponent(0.3) : .controlTextColor
        }
    }
    
    public var commandName:String = "" {
        didSet {
            self.textField?.stringValue = self.commandName
        }
    }
    
    public var searchingString: String = "" {
        didSet {
            guard !self.searchingString.isEmpty,
            let textField = self.textField else { return }
            let range = (textField.stringValue as NSString).range(of: self.searchingString, options: .caseInsensitive)
            let attributedString = NSMutableAttributedString(string: textField.stringValue)
            attributedString.setAttributes([.backgroundColor : NSColor.selectedTextBackgroundColor], range: range)
            self.textField?.attributedStringValue = attributedString
        }
    }
    
    
    public func configure(_ commandName: String, isUsed:Bool) {
        self.commandName = commandName
        self.isUsed = isUsed
    }
    
    override func prepareForReuse() {
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        self.textField?.textColor = .controlTextColor
        self.isUsed = false
    }
    
    func setHighlight(_ selected: Bool) {
        self.view.layer?.backgroundColor = selected ? NSColor.alternateSelectedControlColor.cgColor : NSColor.clear.cgColor
        self.textField?.textColor = selected ? .white : .controlTextColor
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if (event.clickCount == 2),
            !self.isUsed {
            delegate?.doubleClick(on: self)
        }
    }
}
