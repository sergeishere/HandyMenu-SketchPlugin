//
//  ShortcutField.swift
//  ShortcutFieldTest
//
//  Created by Sergey Dmitriev on 30/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import AppKit
import os.log

protocol ShortcutFieldDelegate:class {
    func shortcutField(_ shortcutField: ShortcutField, didChange shortcut:Shortcut)
}

class ShortcutField: NSView {
    
    // MARK: - View States
    private enum State {
        case active, inactive
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var contentView:NSView!
    @IBOutlet private weak var shortcutText:NSTextField!
    
    // MARK: - Private Variables
    private var shortcutController: ShortcutController?
    private let stoppingKeyCodes:Set<UInt16> = [36, 51, 53, 76] // enter, delete, esc, return
    
    // MARK: - Public Variables
    public weak var delegate: ShortcutFieldDelegate?
    
    public var shortcut: Shortcut {
        set(newShortcut) {
            shortcutText.stringValue = newShortcut.stringRepresentation
        }
        get {
            return self.shortcut
        }
    }
    
    // MARK: - Instance Lifecycle
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.prepare()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        let nibName = type(of: self).className().components(separatedBy: ".").last!
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: nibName), bundle: Bundle(for: type(of: self))) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            self.prepare()
        }
        
        
    }
    
    private func prepare() {
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.width,.height]
        
        self.shortcut = .empty
        
        self.wantsLayer = true
        self.layer?.cornerRadius = self.bounds.height / 2
        self.configureForState(.inactive)
        
        self.shortcutController = ShortcutController()
        self.shortcutController?.delegate = self
    }
    
    override func awakeFromNib() {
        self.prepare()
    }
    
    private func configureForState(_ state: State) {
        switch state {
        case .active:
            self.layer?.backgroundColor = NSColor.highlightColor.cgColor
            self.layer?.borderColor = NSColor.alternateSelectedControlColor.cgColor
            self.layer?.borderWidth = 2.0
        case .inactive:
            self.layer?.backgroundColor = NSColor.controlColor.cgColor
            self.layer?.borderColor = NSColor.gridColor.cgColor
            self.layer?.borderWidth = 1
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.shortcutController?.start()
        self.configureForState(.active)
    }
    
}

extension ShortcutField: ShortcutControllerDelegate {
    func shortcutController(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent? {
        shortcutController.stop()
        self.configureForState(.inactive)
        self.shortcut = stoppingKeyCodes.contains(event.keyCode) ?  .empty : shortcut
        self.delegate?.shortcutField(self, didChange: shortcut)
        return nil
    }
}
