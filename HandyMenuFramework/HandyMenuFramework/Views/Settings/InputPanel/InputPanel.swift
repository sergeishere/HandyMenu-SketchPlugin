//
//  InputPanel.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 04/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

class InputPanel: NSPanel {
    
    @IBOutlet private weak var inputTextField: NSTextField!
    
    public var value:String {
        set {
            self.inputTextField.stringValue = newValue
        }
        get {
            return self.inputTextField.stringValue
        }
    }
    
    public func beginSheet(for window: NSWindow, completionHandler handler:((NSApplication.ModalResponse) -> Void)? = nil) {
        window.beginSheet(self, completionHandler: handler)
    }
    
    @IBAction func done(_ sender: Any) {
        self.sheetParent?.endSheet(self, returnCode: .OK)
    }
}
