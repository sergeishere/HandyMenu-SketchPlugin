//
//  NSInputAlert.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

class InputAlert: NSAlert {

    convenience init(_ title: String, input value:String) {
        self.init()
        self.messageText = title
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = value
        self.accessoryView = input
    }
}
