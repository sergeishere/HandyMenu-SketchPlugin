//
//  SettingsWindowController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa
import os.log

public protocol SettingsWindowControllerDelegate: class {
    func settingsWindowController(_ settingsWindowController: SettingsWindowController, didUpdate menuData:[MenuData])
}

public class SettingsWindowController: NSWindowController, SettingsWindowViewControllerDelegate {
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var installedPluginsCollectionView: NSCollectionView!
    
    private let windowViewController = SettingsWindowViewController()
    
    private let commandHeight:CGFloat = 24.0
    private let headerHeight:CGFloat = 48.0
    private let footerHeight: CGFloat = 20.0    
    
    // MARK: - Public Properties
    public weak var delegate: SettingsWindowControllerDelegate?
    public var installedPlugins: [InstalledPluginData] = []
    
    // MARK: - Lifecycle
    override public func windowDidLoad() {
        super.windowDidLoad()
        self.installedPluginsCollectionView.delegate = self
        self.installedPluginsCollectionView.dataSource = self
        
        self.windowViewController.delegate = self
        self.windowViewController.view = self.window!.contentView!
        self.window?.contentViewController = self.windowViewController
    }
    
    func viewWillLayout() {
        os_log("[Handy Menu] ...Resizing...")
        self.installedPluginsCollectionView.collectionViewLayout?.invalidateLayout()
    }
}

// MARK: - NSCollectionViewDataSource
extension SettingsWindowController: NSCollectionViewDataSource {
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return installedPlugins.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return installedPlugins[section].commands.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let collectionViewItem = installedPluginsCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandCollectionViewItem"), for: indexPath)
        let command = installedPlugins[indexPath.section].commands[indexPath.item]
        collectionViewItem.textField?.stringValue = "\(command.name)"
        return collectionViewItem
    }
    
    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        
        switch kind {
        case .sectionHeader:
            let suppementaryHeaderView = self.installedPluginsCollectionView.makeSupplementaryView(ofKind: .sectionHeader,
                                                                                                   withIdentifier: NSUserInterfaceItemIdentifier("PluginSectionHeaderView"),
                                                                                                   for: indexPath) as! PluginSectionHeaderView
            suppementaryHeaderView.pluginNameTextField.stringValue = installedPlugins[indexPath.section].title
            return suppementaryHeaderView
        case .sectionFooter:
            return self.installedPluginsCollectionView.makeSupplementaryView(ofKind: .sectionFooter,
                                                                             withIdentifier: NSUserInterfaceItemIdentifier("PluginSectionFooterView"),
                                                                             for: indexPath)
        default:
            return NSView()
        }
        
    }
}

// MARK: - NSCollectionViewDelegate
extension SettingsWindowController: NSCollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: self.commandHeight)
    }
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: self.headerHeight)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: self.footerHeight)
    }
}

// MARK: - Actions Handling
extension SettingsWindowController {
    
    @IBAction func save(_ sender: Any) {
        self.delegate?.settingsWindowController(self, didUpdate: [])
        self.window?.close()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.window?.close()
    }
    
    @IBAction func github(_ sender: Any) {
        guard let githubPageUrl = URL(string: "https://github.com/sergeishere/HandyMenu-SketchPlugin") else { return }
        NSWorkspace.shared.open(githubPageUrl)
    }
    
}
