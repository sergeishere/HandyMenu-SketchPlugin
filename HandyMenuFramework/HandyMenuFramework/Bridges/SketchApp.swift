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
    
    // MARK: - Public Properties
    public var installedPlugins:[String: NSObject] {
        get {
            return AppController?.value(forKeyPath: "sharedInstance.pluginManager.plugins") as? [String : NSObject] ?? [:]
        }
    }
    
}
