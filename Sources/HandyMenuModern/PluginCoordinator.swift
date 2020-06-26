//
//  PluginCoordinator.swift
//  HandyMenuModern
//
//  Created by Sergey Dmitriev on 26.06.2020.
//  Copyright © 2020 Sergey Dmitriev. All rights reserved.
//

import Foundation
import AppKit

class PluginCoordinator {
    
    let store = PluginStore()
    
    func showWindow(text: String) {
        let alert = NSAlert()
        alert.messageText = text
        if let window = NSApplication.shared.mainWindow {
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
    
}
