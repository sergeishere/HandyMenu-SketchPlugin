//
//  HMDataProvider.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public protocol HMDataProviderDelegate {
    func dataProvider(_ dataProvider: HMDataProvider, didUpdate commandSchemes:Any)
}

public class HMDataProvider {
    
    // MARK : - Handling all keys
    private struct Keys {
        static let suiteName = "com.sergeishere.plugins.handymenu"
    }
    
    // MARK: - Properties
    private var userDefaults = UserDefaults(suiteName: Keys.suiteName)
    private var allPlugins = [String:Any]()
    private var userCommandsSchemes = [HMCommandScheme]()
    
    public var delegate: HMDataProviderDelegate?
    
    // MARK: - Object Lifecycle
    public init() {}
    
    func loadData(){
        
    }
    
}
