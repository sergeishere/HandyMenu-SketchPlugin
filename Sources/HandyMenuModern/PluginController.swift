//
//  PluginController.swift
//  HandyMenuModern
//
//  Created by Sergey Dmitriev on 26.06.2020.
//  Copyright © 2020 Sergey Dmitriev. All rights reserved.
//

import Foundation

@objc(HandyMenuPlugin) class PluginController:NSObject {
    
    // MARK: - Singleton
    
    @objc public static let shared = PluginController()
    private override init() {
        super.init()
    }
    
    // MARK: - Private Variables
    
    private let coordinator = PluginCoordinator()
    
    // MARK: - Public Methods
    
    @objc public func configure() {
        coordinator.showWindow(text: "Configuration")
    }
    
    @objc public func showSettings() {
        coordinator.showWindow(text: "Settings")
    }
    
    @objc public func exportSettings() {
        coordinator.showWindow(text: "Exporting")
    }
    
    @objc public func importSettings() {
        coordinator.showWindow(text: "Importing")
    }
    
}
