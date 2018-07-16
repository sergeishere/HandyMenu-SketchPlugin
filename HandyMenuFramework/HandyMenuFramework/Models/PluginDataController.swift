//
//  DataProvider.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation
import AppKit
import os.log

public protocol PluginDataControllerDelegate: class {
    func dataController(_ dataController: PluginDataController, didUpdate data:PluginData)
}

public class PluginDataController {
    
    // MARK: - Private Properties
    private var pluginData: PluginData!
    private var dataCaretaker = PluginDataCaretaker()
    
    // MARK: - Public Properties
    public weak var delegate: PluginDataControllerDelegate?
    
    // MARK: - Object Lifecycle
    public init() {}
    
    // MARK: - Instance Methods
    public func loadData(){
        pluginData = dataCaretaker.retrieve()
        delegate?.dataController(self, didUpdate: pluginData)
    }
}
