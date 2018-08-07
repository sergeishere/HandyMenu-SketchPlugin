//
//  ShortcutField.swift
//  ShortcutFieldTest
//
//  Created by Sergey Dmitriev on 30/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

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
    private var shortcutController: ShortcutController = ShortcutController()
    private var mouseDownMonitor: Any?
    
    private let stoppingKeyCodes:Set<UInt16> = [36, 53, 76] // Enter, Esc, Return keys codes
    private let deleteKeyCode:UInt16 = 51 // Delete key code
    
    // MARK: - Public Variables
    public weak var delegate: ShortcutFieldDelegate?
    
    public var shortcut: Shortcut = .empty {
        didSet(newShortcut) {
            shortcutText.stringValue = "Shortcut: " + shortcut.stringRepresentation
        }
    }
    
    // MARK: - Lifecycle
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if let nib = NSNib(nibNamed: .shortcutField, bundle: Bundle(for: type(of: self))) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            self.prepare()
        }
    }
    
    // MARK: - Instance Methods
    private func prepare() {
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.width,.height]
        
        self.shortcutController.delegate = self
        
        self.configureForState(.inactive)
    }
    
    override func awakeFromNib() {
        self.contentView.wantsLayer = true
        self.contentView.layer?.cornerRadius = self.bounds.height / 2
    }
    
    private func configureForState(_ state: State) {
        switch state {
        case .active:
            self.contentView.layer?.backgroundColor = NSColor.highlightColor.cgColor
            self.contentView.layer?.borderColor = NSColor.alternateSelectedControlColor.cgColor
            self.contentView.layer?.borderWidth = 2.0
            self.shortcutText.stringValue = ""
            self.shortcutText.placeholderString = "Type shortcut or press ESC"
        case .inactive:
            self.contentView.layer?.backgroundColor = NSColor.controlColor.cgColor
            self.contentView.layer?.borderColor = NSColor.gridColor.cgColor
            self.contentView.layer?.borderWidth = 1
            self.shortcutText.placeholderString = "Type shortcut"
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.shortcutController.start()
        self.configureForState(.active)
    }
    
    public func finish(with shortcut:Shortcut?) {
        self.shortcutController.stop()
        self.configureForState(.inactive)
        if let shortcut = shortcut {
            self.shortcut = shortcut
        }
    }
    
}

extension ShortcutField: ShortcutControllerDelegate {
    func shortcutController(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent? {
        let newShortcut: Shortcut
        switch event.keyCode {
        case self.deleteKeyCode:
            newShortcut = .empty
        case let code where stoppingKeyCodes.contains(code):
            newShortcut = self.shortcut
        default:
            newShortcut = shortcut
        }
        self.finish(with: newShortcut)
        self.delegate?.shortcutField(self, didChange: newShortcut)
        return nil
    }
}
