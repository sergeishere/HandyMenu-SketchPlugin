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
    func settingsWindowController(_ settingsWindowController: SettingsWindowController, didUpdate menuData:[Collection])
    func settingsWindowController(didClose settingsWindowController: SettingsWindowController)
}

public class SettingsWindowController: NSWindowController, SettingsWindowViewControllerDelegate {
    
    
    // MARK: - Outlets
    @IBOutlet private weak var installedPluginsCollectionView: NSCollectionView!
    @IBOutlet private weak var collectionsPopUpButton: NSPopUpButton!
    @IBOutlet private weak var collectionSettingsMenu: NSMenu!
    @IBOutlet private weak var removeMenuItem: NSMenuItem!
    @IBOutlet private weak var shortcutField: ShortcutField!
    @IBOutlet private weak var deleteItemButton: NSButton!
    @IBOutlet private weak var insertSeparatorButton: NSButton!
    @IBOutlet private weak var autoGroupingCheckboxButton: NSButton!
    @IBOutlet private weak var collectionsTableView: NSTableView! {
        didSet {
            // Fixing the first column width
            self.collectionsTableView.sizeToFit()
        }
    }
    
    // MARK: - Private Properties
    private let windowViewController = SettingsWindowViewController()
    
    private var currentCollectionIndex: Int = 0
    private var collections: [Collection] = []
    
    private var currentCollection: Collection {
        get {
            return self.collections[self.currentCollectionIndex]
        }
        set {
            self.collections[self.currentCollectionIndex] = newValue
        }
    }
    
    private let commandHeight:CGFloat = 24.0
    private let headerHeight:CGFloat = 48.0
    private let footerHeight: CGFloat = 20.0
    
    // MARK: - Public Properties
    public weak var delegate: SettingsWindowControllerDelegate?
    public var installedPlugins: [InstalledPluginData] = []
    
    // MARK: - Instance Lifecycle
    override public func windowDidLoad() {
        super.windowDidLoad()
        
        self.installedPluginsCollectionView.delegate = self
        self.installedPluginsCollectionView.dataSource = self
        self.installedPluginsCollectionView.registerForDraggedTypes([.string])
        self.installedPluginsCollectionView.setDraggingSourceOperationMask(.link, forLocal: false)
        
        self.collectionsTableView.delegate = self
        self.collectionsTableView.dataSource = self
        self.collectionsTableView.reloadData()
        self.collectionsTableView.registerForDraggedTypes([.string])
        self.collectionsTableView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.windowViewController.delegate = self
        self.windowViewController.view = self.window!.contentView!
        self.window?.contentViewController = self.windowViewController
        
        self.shortcutField.delegate = self
        
        self.configure(collections)
    }
    
    public override func close() {
        super.close()
        self.shortcutField.finish(with: nil)
        delegate?.settingsWindowController(didClose: self)
    }
    
    public func viewWillLayout() {
        self.installedPluginsCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    // Public Methods
    public func configure(_ collections:[Collection]) {
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
    
    // Private Methods
    private func configureCollectionsPopUpButton() {
        self.collectionsPopUpButton.removeAllItems()
        self.collectionsPopUpButton.addItems(withTitles: self.collections.map({$0.title}))
    }
    
    private func configureAutoGrouping(for autoGroupingOn: Bool) {
        self.currentCollection.autoGrouping = autoGroupingOn
        self.insertSeparatorButton.isEnabled = !autoGroupingOn
        self.autoGroupingCheckboxButton.state = autoGroupingOn ? .on : .off
        
        if autoGroupingOn, self.currentCollection.items.contains(.separator) {
            var separatorIndexes: IndexSet = []
            for (index, item) in self.currentCollection.items.enumerated() {
                if case CollectionItem.separator = item {
                    separatorIndexes.insert(index)
                }
            }
            self.currentCollection.items = self.currentCollection.items.filter{ $0 != .separator }
            plugin_log("Filtered array: %@", String(describing: self.currentCollection.items))
            self.collectionsTableView.removeRows(at: separatorIndexes, withAnimation: .effectFade)
        }
    }
    
    private func selectCollection(at index: Int) {
        self.currentCollectionIndex = index
        self.collectionsPopUpButton.selectItem(at: index)
        self.collectionsTableView.reloadData()
        self.shortcutField.shortcut = self.currentCollection.shortcut
        self.configureAutoGrouping(for: self.currentCollection.autoGrouping)
    }
    
    private func uniqueCollectionTitle() -> String {
        var newTitle = ""
        for freeIndex in 0...self.collections.endIndex {
            newTitle = "New Collection \(freeIndex + 1)"
            guard self.collectionsPopUpButton.itemTitles.contains(newTitle) else { break }
        }
        return newTitle
    }
    
    private func pluginCommandAtIndexPath(_ indexPath: IndexPath) -> Command {
        return self.installedPlugins[indexPath.section].commands[indexPath.item]
    }
}

// MARK: - NSTableViewDataSource
extension SettingsWindowController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.collections[currentCollectionIndex].items.count
    }
}

// MARK: - NSTableViewDelegate {
extension SettingsWindowController: NSTableViewDelegate {
    
    // Setting Height For Item
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self.commandHeight
    }
    
    // Cofiguring Item's View
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = collections[currentCollectionIndex].items[row]
        switch item {
        case .command(let commandData):
            guard let commandCell = collectionsTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandCell"), owner: self) as? CommandTableViewItem else { return nil }
            commandCell.title = commandData.name
            commandCell.toolTip = commandData.pluginName
            return commandCell
        case .separator:
            guard let separatorCell = collectionsTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SeparatorCell"), owner: self) else { return nil }
            return separatorCell
        }
    }
    
    // Handling Selection
    public func tableViewSelectionDidChange(_ notification: Notification) {
        self.deleteItemButton.isEnabled = self.collectionsTableView.selectedRowIndexes.count != 0
    }
    
    // Drag And Drop
    public func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return NSDragOperation.link
    }
    
    // Writing moving item index into pasteboard at the begining of the drag
    public func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([.string], owner: self)
        pboard.setData(data, forType: .string)
        return true
    }
    
    // Handling Drop
    public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard let data = info.draggingPasteboard().data(forType: .string) else { return false }
        
        if self.installedPluginsCollectionView.isEqual(info.draggingSource())  {
            guard let sourceIndexPath = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? IndexPath else { return false }
            let pluginCommandData = self.pluginCommandAtIndexPath(sourceIndexPath)
            let newCommand = CollectionItem.command(pluginCommandData)
            self.collections[currentCollectionIndex].items.insert(newCommand, at: row)
            self.collectionsTableView.insertRows(at: IndexSet(integer: row), withAnimation: .effectFade)
            self.installedPluginsCollectionView.reloadItems(at: [sourceIndexPath])
            return true
        } else if self.collectionsTableView.isEqual(info.draggingSource()) {
            guard let indexes = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? IndexSet,
                let fromRow = indexes.first else { return false }
            let toRow = (fromRow > row) ? row : row - 1
            let movingItem = self.currentCollection.items.remove(at: fromRow)
            self.currentCollection.items.insert(movingItem, at: toRow)
            self.collectionsTableView.moveRow(at: fromRow, to: toRow)
            return true
        }
        
        return false
    }
    
    // Preventing animation after deleting
    public func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        session.animatesToStartingPositionsOnCancelOrFail = false
    }
    
    // Deleting item if drop was outside tableView
    public func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        let rectInWindow = self.collectionsTableView.convert(self.collectionsTableView.bounds, to: nil)
        if  let tableViewRect = self.window?.convertToScreen(rectInWindow),
            !tableViewRect.contains(screenPoint),
            let data = session.draggingPasteboard.data(forType: .string),
            let indexes = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? IndexSet,
            let rowToDelete = indexes.first {
            self.currentCollection.items.remove(at: rowToDelete)
            self.collectionsTableView.removeRows(at: indexes, withAnimation: .effectFade)
        }
    }
}

// MARK: - NSCollectionViewDataSource
extension SettingsWindowController: NSCollectionViewDataSource {
    
    // Common DataSource Methods
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return self.installedPlugins.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.installedPlugins[section].commands.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let collectionViewItem = self.installedPluginsCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandCollectionViewItem"), for: indexPath) as? CommandCollectionViewItem else { return NSCollectionViewItem()}
        let commandData = self.pluginCommandAtIndexPath(indexPath)
        collectionViewItem.configure(commandData.name, isUsed: self.currentCollection.items.contains(.command(commandData)))
        return collectionViewItem
    }
    
    // Configuring Views For Headers And Footers
    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        
        switch kind {
        case .sectionHeader:
            let suppementaryHeaderView = self.installedPluginsCollectionView.makeSupplementaryView(ofKind: .sectionHeader,
                                                                                                   withIdentifier: NSUserInterfaceItemIdentifier("PluginSectionHeaderView"),
                                                                                                   for: indexPath) as! PluginSectionHeaderView
            suppementaryHeaderView.title = self.installedPlugins[indexPath.section].pluginName
            suppementaryHeaderView.image = self.installedPlugins[indexPath.section].image
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
    
    // Configuring Items, Headers and Footers sizes
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: self.commandHeight)
    }
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: self.headerHeight)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: self.footerHeight)
    }
    
    // Enable Dragging
    public func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
        return true
    }
    
    // Selections And Deselection
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        guard let indexPath = indexPaths.first,
            let item = self.installedPluginsCollectionView.item(at: indexPath) as? CommandCollectionViewItem,
            !item.isUsed else { return [] }
        return indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first,
            let item = collectionView.item(at: indexPath) as? CommandCollectionViewItem else { return }
        item.setHighlight(true)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first,
            let item = collectionView.item(at: indexPath) as? CommandCollectionViewItem else { return }
        item.setHighlight(false)
    }
    
    // Drag & Drop
    // Writing dragging item's indexPath to pasteboard
    public func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {
        guard let indexPath = indexPaths.first,
            let item = self.installedPluginsCollectionView.item(at: indexPath) as? CommandCollectionViewItem,
            !item.isUsed else { return false }
        let data = NSKeyedArchiver.archivedData(withRootObject: indexPath)
        pasteboard.declareTypes([.string], owner: self)
        pasteboard.setData(data, forType: .string)
        return true
    }
    
    // Preventing animation when cancel dragging
    public func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexes: IndexSet) {
        session.animatesToStartingPositionsOnCancelOrFail = false
    }
}

// MARK: - ShortcutFieldDelegate
extension SettingsWindowController: ShortcutFieldDelegate {
    func shortcutField(_ shortcutField: ShortcutField, didChange shortcut: Shortcut) {
        self.currentCollection.shortcut = shortcut
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
        // TODO: Implement this
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
        var newCollection = Collection.emptyCollection
        newCollection.title = uniqueCollectionTitle()
        self.collections.insert(newCollection, at: newIndex)
        self.configureCollectionsPopUpButton()
        self.selectCollection(at:newIndex)
    }
    
    @IBAction func popUpButtonDidChangeCollection(_ sender: Any) {
        self.selectCollection(at: self.collectionsPopUpButton.indexOfSelectedItem)
    }
    
    // Managing Collection's Items
    @IBAction func deleteSelectedItem(_ sender: Any) {
        let row = self.collectionsTableView.selectedRow
        self.currentCollection.items.remove(at: row)
        self.collectionsTableView.removeRows(at: [row], withAnimation: .effectFade)
    }
    
    @IBAction func insertSeparator(_ sender: Any) {
        let index = self.currentCollection.items.endIndex
        self.currentCollection.items.insert(.separator, at: index)
        self.collectionsTableView.insertRows(at: [index], withAnimation: .effectFade)
    }
    
    @IBAction func switchAutoGrouping(_ sender: Any) {
        let checkboxState = self.autoGroupingCheckboxButton.state == .on ? true : false
        self.configureAutoGrouping(for: checkboxState)
    }
    

    // Save/Cancel Buttons Actions
    @IBAction func save(_ sender: Any) {
        self.delegate?.settingsWindowController(self, didUpdate: collections)
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


