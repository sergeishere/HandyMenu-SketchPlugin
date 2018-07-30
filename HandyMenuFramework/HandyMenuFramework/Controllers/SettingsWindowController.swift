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
    func settingsWindowController(didClose settingsWindowController: SettingsWindowController)
}

public class SettingsWindowController: NSWindowController, SettingsWindowViewControllerDelegate {
    
    
    // MARK: - Outlets
    @IBOutlet private weak var installedPluginsCollectionView: NSCollectionView!
    @IBOutlet private weak var collectionsTableView: NSTableView!
    @IBOutlet private weak var collectionsPopUpButton: NSPopUpButton!
    @IBOutlet private weak var collectionSettingsMenu: NSMenu!
    @IBOutlet private weak var removeMenuItem: NSMenuItem!
    @IBOutlet private weak var shortcutField: ShortcutField!
    
    // MARK: - Private Properties
    private let windowViewController = SettingsWindowViewController()
    
    private var currentCollectionIndex: Int = 0
    private var collections: [MenuData] = []
    
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
        
        self.collectionsTableView.delegate = self
        self.collectionsTableView.dataSource = self
        self.collectionsTableView.reloadData()
        
        self.windowViewController.delegate = self
        self.windowViewController.view = self.window!.contentView!
        self.window?.contentViewController = self.windowViewController
        
        self.shortcutField.delegate = self
        
        self.configure(collections)
    }
    
    public override func close() {
        super.close()
        delegate?.settingsWindowController(didClose: self)
    }
    
    public func viewWillLayout() {
        self.installedPluginsCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    public func configure(_ collections:[MenuData]) {
        self.collections = collections
        
        if self.collections.count == 0 {
            self.collections.append(.emptyCollection)
        }
        
        if self.isWindowLoaded {
            self.collectionsTableView.reloadData()
            self.configureCollectionsPopUpButton()
            self.selectCollection(at: self.collections.startIndex)
        }
    }
    
    private func configureCollectionsPopUpButton() {
        self.collectionsPopUpButton.removeAllItems()
        self.collectionsPopUpButton.addItems(withTitles: self.collections.map({$0.title}))
    }
    
    private func selectCollection(at index: Int) {
        self.currentCollectionIndex = index
        self.collectionsPopUpButton.selectItem(at: index)
        self.collectionsTableView.reloadData()
        self.shortcutField.shortcut = self.collections[self.currentCollectionIndex].shortcut
    }
    
    private func uniqueCollectionTitle() -> String {
        var newTitle = ""
        for freeIndex in 0...self.collections.endIndex {
            newTitle = "New Collection \(freeIndex + 1)"
            guard self.collectionsPopUpButton.itemTitles.contains(newTitle) else { break }
        }
        return newTitle
    }
}

// MARK: - NSTableViewDataSource & NSTableViewDelegate
extension SettingsWindowController: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.collections[currentCollectionIndex].items.count
    }
    
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self.commandHeight
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = collections[currentCollectionIndex].items[row]
        switch item {
        case .command(let commandData):
            guard let commandCell = collectionsTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandCell"), owner: self) as? CommandTableViewItem else { return nil }
            commandCell.title = commandData.name
            return commandCell
        default:
            break
        }
        
        return nil
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
            suppementaryHeaderView.title = installedPlugins[indexPath.section].title
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
    
    // Managing Selected Collection
    @IBAction func openCollectionSettings(_ sender: Any) {
        self.removeMenuItem.isEnabled = self.collections.count > 1 ? true : false
        if let sender = sender as? NSButton {
            let point = NSPoint(x: 0, y: sender.bounds.height)
            self.collectionSettingsMenu.popUp(positioning: nil, at: point, in: sender)
        }
    }
    
    @IBAction func renameCollection(_ sender: Any) {
        
    }
    
    @IBAction func removeCollection(_ sender: Any) {
        self.collections.remove(at: self.currentCollectionIndex)
        let lastIndex = self.collections.index(before: self.collections.endIndex)
        let newIndex = (self.currentCollectionIndex > lastIndex) ? lastIndex : currentCollectionIndex
        self.configureCollectionsPopUpButton()
        self.selectCollection(at: newIndex)
    }
    
    @IBAction func addNewCollection(_ sender: Any) {
        let newIndex = self.collections.endIndex
        var newCollection = MenuData.emptyCollection
        newCollection.title = uniqueCollectionTitle()
        self.collections.insert(newCollection, at: newIndex)
        self.configureCollectionsPopUpButton()
        self.selectCollection(at:newIndex)
    }
    
    @IBAction func popUpButtonDidChangeCollection(_ sender: Any) {
        self.selectCollection(at: self.collectionsPopUpButton.indexOfSelectedItem)
    }
    
    @IBAction func save(_ sender: Any) {
        self.delegate?.settingsWindowController(self, didUpdate: [])
        self.close()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.close()
    }
    
    @IBAction func github(_ sender: Any) {
        guard let githubPageUrl = URL(string: "https://github.com/sergeishere/HandyMenu-SketchPlugin") else { return }
        NSWorkspace.shared.open(githubPageUrl)
    }
    
}

// MARK: - ShortcutFieldDelegate
extension SettingsWindowController: ShortcutFieldDelegate {
    func shortcutField(_ shortcutField: ShortcutField, didChange shortcut: Shortcut) {
        self.collections[self.currentCollectionIndex].shortcut = shortcut
    }
}
