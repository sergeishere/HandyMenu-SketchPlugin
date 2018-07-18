//
//  SketchApp.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public class SketchApp {
    
    // MARK: - Singletone
    static let bridge = SketchApp()
    private init() {}
    
    // MARK: - Private Properties
    private let AppController:AnyClass? = NSClassFromString("AppController")
    private let MSDocument: AnyClass? = NSClassFromString("MSDocument")
    
    // MARK: - Public Properties
    public var installedPlugins:[String: NSObject] {
        get {
            return AppController?.value(forKeyPath: "sharedInstance.pluginManager.plugins") as? [String : NSObject] ?? [:]
        }
    }
    
    func runPluginCommand(with data:PluginCommandData) {
        let selector = NSSelectorFromString("runPluginCommand:fromMenu:")
        guard let pluginCommand = self.installedPlugins[data.pluginID]?.value(forKey: data.commandID),
            let delegate = NSApp.delegate,
            delegate.responds(to: selector) else { return }
        delegate.perform(selector, with: pluginCommand, with: false)
    }
    
}
