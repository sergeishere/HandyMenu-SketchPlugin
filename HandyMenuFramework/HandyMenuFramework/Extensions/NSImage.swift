//
//  NSImage.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 05/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

extension NSImage.Name {
    static let settingsIcon = NSImage.Name("icon_settings")
    static let settingsIconPressed = NSImage.Name("icon_settings_pressed")
    static let pluginIconPlaceholderImage = NSImage.Name("image_placeholder")
}

extension NSImage {
    static let pluginIconPlaceholderImage = Bundle(for: PluginController.self).image(forResource: .pluginIconPlaceholderImage)
}
