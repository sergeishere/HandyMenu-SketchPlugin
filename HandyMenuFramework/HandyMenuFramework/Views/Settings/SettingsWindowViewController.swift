//
//  SettingsWindowViewController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 27/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

protocol SettingsWindowViewControllerDelegate: class {
    func viewWillLayout()
}

class SettingsWindowViewController: NSViewController {
   
    public weak var delegate: SettingsWindowViewControllerDelegate?
    
    override func viewWillLayout() {
        self.delegate?.viewWillLayout()
    }
}
