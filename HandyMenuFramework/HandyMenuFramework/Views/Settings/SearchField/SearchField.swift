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
    
    @IBOutlet private weak var contentView: NSView!
    @IBOutlet private weak var textField: NSTextField!
    @IBOutlet private weak var clearButton: NSButton!
    
    public weak var delegate: SearchFieldDelegate?
    public var stringValue: String {
        set {
            self.textField.stringValue = newValue
            self.clearButton.isHidden = (newValue.count == 0)
            self.delegate?.searchField(self, didChanged: newValue)
        }
        get {
             return self.textField.stringValue
        }
    }
    
    // MARK: - Lifecycle
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        let nibName = type(of: self).className().components(separatedBy: ".").last!
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: nibName), bundle: Bundle(for: type(of: self))) {
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
    
    @IBAction func clear(_ sender: Any) {
        self.stringValue = ""
    }
}
