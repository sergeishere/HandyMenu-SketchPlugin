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
    @IBOutlet private var contentView: NSBox!
    @IBOutlet private weak var shortcutText: NSTextField!
    @IBOutlet private weak var returnButton: NSButton!
    
    // MARK: - Private Variables
    private var shortcutController: ShortcutController = ShortcutController()
    private var mouseDownMonitor: Any?
    
    private let stoppingKeyCodes:Set<UInt16> = [36, 53, 76] // Enter, Esc, Return keys codes
    private let deleteKeyCode:UInt16 = 51 // Delete key code
    
    private var state: State = .inactive
    
    // MARK: - Public Variables
    public weak var delegate: ShortcutFieldDelegate?
    
    public var shortcut: Shortcut = .empty {
        didSet {
            shortcutText.stringValue = shortcut.stringRepresentation.isEmpty ? "" : shortcut.stringRepresentation
        }
    }
    
    // MARK: - Lifecycle
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if let nib = NSNib(nibNamed: .shortcutField, bundle: Bundle(for: type(of: self))) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            prepare()
        }
    }
    
    // MARK: - Instance Methods
    private func prepare() {
        addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.width,.height]
        shortcutController.delegate = self
        
        configureForState(.inactive)
    }
    
    override func layout() {
        super.layout()
        switch self.state {
        case .active:
            if #available(OSX 10.14, *) {
                contentView.borderColor = NSColor.controlAccentColor
            } else {
                contentView.borderColor = NSColor.alternateSelectedControlColor
            }
        case .inactive:
            contentView.borderColor = NSColor.gridColor
        }
        self.needsDisplay = true
    }
    
    private func configureForState(_ state: State) {
        self.state = state
        switch state {
        case .active:
            if #available(OSX 10.14, *) {
                contentView.borderColor = NSColor.controlAccentColor
            } else {
                contentView.borderColor = NSColor.alternateSelectedControlTextColor
            }
            returnButton.isHidden = false
            shortcutText.stringValue = ""
        case .inactive:
            contentView.borderColor = NSColor.borderColor
            returnButton.isHidden = true
        }
        self.needsDisplay = true
    }
    
    override func mouseDown(with event: NSEvent) {
        shortcutController.start()
        configureForState(.active)
    }
    
    public func finish(with shortcut:Shortcut?) {
        shortcutController.stop()
        configureForState(.inactive)
        self.shortcut = shortcut ?? self.shortcut
    }
    
    @IBAction func returnInactiveState(_ sender: Any) {
        finish(with: nil)
    }
    
}

extension ShortcutField: ShortcutControllerDelegate {
    func shortcutController(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent? {
        let newShortcut: Shortcut
        switch event.keyCode {
        case deleteKeyCode:
            newShortcut = .empty
        case let code where stoppingKeyCodes.contains(code):
            newShortcut = self.shortcut
        default:
            newShortcut = shortcut
        }
        finish(with: newShortcut)
        delegate?.shortcutField(self, didChange: newShortcut)
        return nil
    }
}
