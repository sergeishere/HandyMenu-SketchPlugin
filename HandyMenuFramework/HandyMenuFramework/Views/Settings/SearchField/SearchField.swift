//
//  SearchField.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

protocol SearchFieldDelegate: class {
    func searchField(_ searchField: SearchField, didChanged value: String)
}

class SearchField: NSView, NSTextFieldDelegate {
    
    @IBOutlet private var contentView: NSView!
    @IBOutlet private weak var textField: NSTextField!
    @IBOutlet private weak var clearButton: NSButton!
    @IBOutlet private weak var searchIcon: NSImageView!
    
    public weak var delegate: SearchFieldDelegate?
    public var stringValue: String {
        set {
            self.textField.stringValue = newValue
            let isEmpty = (newValue.count == 0)
            self.clearButton.isHidden = isEmpty
            self.delegate?.searchField(self, didChanged: newValue)
            if #available(OSX 10.14, *) {
                self.searchIcon.contentTintColor = isEmpty ? NSColor.controlColor
                    : NSColor.controlAccentColor
            }
        }
        get {
             return self.textField.stringValue
        }
    }
    
    // MARK: - Lifecycle
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if let nib = NSNib(nibNamed: .searchField, bundle: Bundle(for: type(of: self))) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            self.prepare()
        }
    }
    
    // MARK: - Instance Methods
    private func prepare() {
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.width,.height]
        self.textField.delegate = self
        if let cell = self.textField.cell as? SearchFieldTextFieldCell {
            cell.leftPadding = 32.0
            cell.rightPadding = 32.0
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        self.stringValue = self.textField.stringValue
    }
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        if #available(OSX 10.14, *) {
            self.searchIcon.contentTintColor = NSColor.controlAccentColor
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if #available(OSX 10.14, *) {
            
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        self.stringValue = ""
    }
}
