//
//  HandyMenu.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

class HandyMenu: NSMenu {
    
    private var collectionName: String = ""
    
    public func configure(for data: Collection) {
        
        self.collectionName = data.title
        self.addItem(NSMenuItem.separator())

        for (index, item) in data.items.enumerated() {
            switch item {
            case .separator:
                if data.autoGrouping { break }
                self.addItem(NSMenuItem.separator())
            case .command(let commandData):
                if data.autoGrouping, index > 0, case let CollectionItem.command(previousCommand) = data.items[index-1], previousCommand.pluginID != commandData.pluginID {
                    self.addItem(NSMenuItem.separator())
                }
                let newMenuItem = NSMenuItem(title: commandData.name, action: #selector(runPluginCommand(sender:)), keyEquivalent: "")
                newMenuItem.target = self
                newMenuItem.representedObject = commandData
                self.addItem(newMenuItem)
            }
        }
        
        let titleItem = NSMenuItem(title: data.title, action: nil, keyEquivalent: "")
        titleItem.view = generateTitleView(with: data.title)
        self.insertItem(titleItem, at: 0)
        
        
    }
    
    private func generateTitleView(with title: String) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: self.size.width, height: 24))
        
        let titleLabel = NSTextField(labelWithAttributedString: NSAttributedString(string: title,
                                                                                   attributes: [.font : NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .medium)]))
        
        let actionButton = NSButton()
        actionButton.frame = NSRect(x: 0, y: 0, width: 16, height: 16)
        actionButton.bezelStyle = NSButton.BezelStyle.regularSquare
        actionButton.isBordered = false
        actionButton.target = self
        actionButton.action = #selector(openSettings)
        
        let bundle = Bundle(for: HandyMenu.self)
        if let settingsImage = bundle.image(forResource: .settingsIcon),
            let settingsPressedImage = bundle.image(forResource: .settingsIconPressed) {
            actionButton.image = settingsImage
            actionButton.alternateImage = settingsPressedImage
        }
        
        let stack = NSStackView(views: [titleLabel, actionButton])
        stack.alignment = .centerY
        stack.distribution = .fill
        stack.orientation = .horizontal
        view.addSubview(stack)
        
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    @objc private func openSettings(_ sender: Any) {
        self.cancelTrackingWithoutAnimation()
        PluginController.shared.show(self.collectionName)
    }
    
    @objc private func runPluginCommand(sender: NSMenuItem) {
        guard let itemData = sender.representedObject as? Command else { return }
        SketchAppBridge.sharedInstance().runSketchPluginCommand(itemData.commandID, from: itemData.pluginID)
    }
}
