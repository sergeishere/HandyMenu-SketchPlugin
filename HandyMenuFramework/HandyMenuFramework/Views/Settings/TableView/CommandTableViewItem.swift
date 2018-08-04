//
//  CommandView.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 29/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

class CommandTableViewItem: NSTableCellView {
    
    @IBOutlet private weak var titleTextField: NSTextField!
    
    public var title: String = "" {
        didSet {
            self.titleTextField.stringValue = self.title
        }
    }
    
}
