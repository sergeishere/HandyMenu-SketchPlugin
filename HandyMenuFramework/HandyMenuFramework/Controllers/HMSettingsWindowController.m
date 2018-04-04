//
//  HMSettingsWindowController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMSettingsWindowController.h"

@implementation HMSettingsWindowController

NSArray *pluginsSchemes;
NSMutableArray *filteredPluginsSchemes;
NSMutableArray *commandsSchemes;
HMSettingsWindowViewController *windowViewController;

NSTimer *searchDelayTimer;

BOOL groupCommands = YES;

NSString *searchString = @"";

id shortcutHandlingEventMonitor;


- (void)windowDidLoad {
    [super windowDidLoad];
    
    windowViewController = [[HMSettingsWindowViewController alloc] init];
    windowViewController.delegate = self;
    windowViewController.view = self.window.contentView;
    [self.window setContentViewController:windowViewController];
    
    [_allCommandsCollectionView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
    [_allCommandsCollectionView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_allCommandsCollectionView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
    
    
    [_userCommandsTableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
    [_userCommandsTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_userCommandsTableView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
    
    [_userCommandsTableView setDoubleAction:@selector(doubleClickInTableView)];
    
    _noCommandsNotificationLabel.alphaValue = (commandsSchemes.count > 0) ? 0.0 : 1.0;
    _noPluginsNotificationLabel.alphaValue = (filteredPluginsSchemes.count > 0) ? 0.0 : 1.0;
    
    [_clearButton setEnabled:NO];
    [_clearButton setHidden:YES];
}

-(void)settingsWindowViewController:(id)settingsWindowViewController viewWillLayout:(NSView *)view{
    [_allCommandsCollectionView.collectionViewLayout invalidateLayout];
}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
    [_allCommandsCollectionView reloadData];
}

#pragma mark - Plugins updating methods

-(void)updatePlugins:(NSArray *)schemes{
    pluginsSchemes = schemes;
    filteredPluginsSchemes = [pluginsSchemes mutableCopy];
    
    [_allCommandsCollectionView reloadData];
}

-(void)updateUserCommands:(NSArray *)schemes{
    commandsSchemes = [NSMutableArray arrayWithArray:schemes];
    
    [_userCommandsTableView reloadData];
    
}

static BOOL itemHasAlreadyAdded(id  _Nonnull item) {
    return [commandsSchemes containsObject:item];
}

- (void)addCommand:(id)command atIndex:(NSUInteger)index {
    [commandsSchemes insertObject:command atIndex:index];
    [_userCommandsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectFade];
    [self toggleNoCommandsLabel];
    [_allCommandsCollectionView reloadData];
}

- (void)removeCommandsAt:(NSIndexSet *)rowIndexes {
    [commandsSchemes removeObjectsAtIndexes:rowIndexes];
    [_userCommandsTableView removeRowsAtIndexes:rowIndexes withAnimation:NSTableViewAnimationEffectFade];
    [self toggleNoCommandsLabel];
    [_allCommandsCollectionView reloadData];
}

- (void)toggleNoCommandsLabel {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.3;
        self.noCommandsNotificationLabel.animator.alphaValue = (commandsSchemes.count > 0) ? 0.0 : 1.0;
    } completionHandler:nil];
    
}

- (void)toggleNoPluginsLabel {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.3;
        self.noPluginsNotificationLabel.animator.alphaValue = (filteredPluginsSchemes.count > 0) ? 0.0 : 1.0;
    } completionHandler:nil];
    
}



#pragma mark - NSCollectionView Delegate and DataSource

-(NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    [self toggleNoPluginsLabel];
    return filteredPluginsSchemes.count;
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[(HMPluginScheme *)filteredPluginsSchemes[section] pluginCommands] count];
}

-(NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
    HMCommandCollectionViewItem *collectionViewItem = [_allCommandsCollectionView makeItemWithIdentifier:@"HMCommandCollectionViewItem" forIndexPath:indexPath];
    HMPluginScheme *pluginScheme = filteredPluginsSchemes[indexPath.section];
    HMCommandScheme *commandScheme = [[pluginScheme pluginCommands] objectAtIndex:indexPath.item];

    collectionViewItem.representedObject = commandScheme;
    collectionViewItem.textField.stringValue = commandScheme.name;

    if (itemHasAlreadyAdded(commandScheme)) {
        collectionViewItem.textField.stringValue = [NSString stringWithFormat:@"✓ %@",collectionViewItem.textField.stringValue];
        [collectionViewItem.textField setTextColor:[NSColor colorWithCalibratedRed:0.55 green:0.6 blue:0.65 alpha:1.0]];
    } else {
        [collectionViewItem.textField setTextColor:[NSColor controlTextColor]];

        
    }

    if (searchString.length > 1) {
        NSRange searchRange = [collectionViewItem.textField.stringValue rangeOfString:searchString options:NSCaseInsensitiveSearch];
        if (searchRange.location != NSNotFound) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:collectionViewItem.textField.stringValue];
            [attributedString addAttribute:NSBackgroundColorAttributeName value:[NSColor selectedTextBackgroundColor] range:searchRange];
            [collectionViewItem.textField setAttributedStringValue:attributedString];
        }
    }
    
    return collectionViewItem;
}

-(NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.bounds.size.width, 24.0);
}

-(NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(collectionView.bounds.size.width, 40.0);
}

-(NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath{
    
    HMPluginSectionHeaderView *headerView = [_allCommandsCollectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"HMPluginSectionHeaderView" forIndexPath:indexPath];
    headerView.pluginNameTextField.stringValue = [filteredPluginsSchemes[indexPath.section] valueForKey:@"name"];
    if (indexPath.section == 0) {
        [headerView.horizontalLine setHidden:YES];
    }
    
    if (searchString.length > 1) {
        NSRange searchRange = [headerView.pluginNameTextField.stringValue rangeOfString:searchString options:NSCaseInsensitiveSearch];
        if (searchRange.location != NSNotFound) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:headerView.pluginNameTextField.stringValue];
            [attributedString addAttribute:NSBackgroundColorAttributeName value:[NSColor selectedTextBackgroundColor] range:searchRange];
            [headerView.pluginNameTextField setAttributedStringValue:attributedString];
        }
    }
    
    return headerView;
}

-(NSSet<NSIndexPath *> *)collectionView:(NSCollectionView *)collectionView shouldSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    
    NSMutableSet *newSet = [NSMutableSet setWithSet:indexPaths];

    for (NSIndexPath *indexPath in indexPaths) {
        HMLog(@"checking an item");
        if(itemHasAlreadyAdded([[_allCommandsCollectionView itemAtIndexPath:indexPath] representedObject])) {
            [newSet removeObject:indexPath];
        }
    }
    
    return [newSet copy];
}

#pragma mark - NSTableView Delegate and DataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [commandsSchemes count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    HMTableCellView *tableCellView;
    
    HMCommandScheme *command = commandsSchemes[row];
    
    tableCellView = [_userCommandsTableView makeViewWithIdentifier:@"CommandCell" owner:self];
    tableCellView.commandName.stringValue = command.name;
    tableCellView.pluginName.stringValue =  [[[pluginsSchemes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier = %@", command.pluginID]] objectAtIndex:0] valueForKey:@"name"];
    
    return tableCellView;
}

#pragma mark - Drag & Drop Delegates


-(BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toPasteboard:(NSPasteboard *)pasteboard{
    NSMutableArray *arrayOfItems = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        HMCommandScheme *scheme = [[collectionView itemAtIndexPath:indexPath] representedObject];
        [arrayOfItems addObject:scheme];
        
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayOfItems];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pasteboard setData:data forType:NSStringPboardType];
    return YES;
}

-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    [_userCommandsTableView selectRowIndexes:rowIndexes byExtendingSelection:NO];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pboard setData:data forType:NSStringPboardType];
    return YES;
}

-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    return NSDragOperationEvery;
}


-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation{

    if([info draggingSource] == _userCommandsTableView || [info draggingSource] == _allCommandsCollectionView) {
        
        NSData *data = [[info draggingPasteboard] dataForType:NSPasteboardTypeString];
        NSArray *selectedItems;
        BOOL itemFromAllCommandsList = NO;
        NSInteger fromIndex = 0;
        NSInteger toIndex = 0;
        
        //Reordering In The Same Table View By Drag & Drop
        if (([info draggingSource] == _userCommandsTableView) && (tableView == _userCommandsTableView))
        {
            NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            fromIndex = [rowIndexes firstIndex];
            selectedItems = [commandsSchemes objectsAtIndexes:rowIndexes];
            [commandsSchemes removeObjectsAtIndexes:rowIndexes];
        }
        
        //Drag And Drop Across The Tables
        else if (([info draggingSource] == _allCommandsCollectionView) && (tableView == _userCommandsTableView))
        {
            selectedItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            fromIndex = [commandsSchemes count];
            itemFromAllCommandsList = YES;
        }
        
        if (row > [commandsSchemes count] || fromIndex < row) {
            toIndex = row - 1;

        } else {
            toIndex = row;
        }
        
        [commandsSchemes insertObject:[selectedItems objectAtIndex:0] atIndex:toIndex];
        [_noCommandsNotificationLabel setHidden:(commandsSchemes.count > 0)];
        
        if(itemFromAllCommandsList) {
            [_allCommandsCollectionView reloadData];
            [_userCommandsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:toIndex] withAnimation:NSTableViewAnimationEffectFade];
        } else {
            [_userCommandsTableView beginUpdates];
            [_userCommandsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] withAnimation:NSTableViewAnimationEffectFade];
            [_userCommandsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:toIndex] withAnimation:NSTableViewAnimationEffectFade];
            [_userCommandsTableView endUpdates];
        }
        
        [_allCommandsCollectionView deselectAll:nil];
        [_userCommandsTableView deselectAll:nil];
        
        return YES;
    }
    
    return NO;
}


-(void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes {
    [session setAnimatesToStartingPositionsOnCancelOrFail:NO];
}



-(void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    
    NSRect rectInWindow =  NSInsetRect([_userCommandsTableView convertRect:[_userCommandsTableView bounds] toView:nil], -10.0, -10.0);
    NSRect screenRect = [self.window convertRectToScreen:rectInWindow];
    
    if(!NSPointInRect(screenPoint, screenRect) && operation == NSDragOperationNone) {
        NSData *data = [[session draggingPasteboard] dataForType:NSPasteboardTypeString];
        NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self removeCommandsAt:rowIndexes];
    }
}

#pragma mark - Mouse Events

-(void)mouseDown:(NSEvent *)event{
    [self.window makeFirstResponder:nil];
    [_allCommandsCollectionView deselectAll:nil];
    [_userCommandsTableView deselectAll:nil];
    [super mouseDown:event];
}

- (void)cancelOperation:(id)sender{
    [[self window] makeFirstResponder:nil];
}

-(void)doubleClickInCollectionView:(id)sender {
    id clickedObject = [sender representedObject];
    HMLog(@"%@", clickedObject);
    if ([clickedObject isKindOfClass:[HMCommandScheme class]] && !itemHasAlreadyAdded(clickedObject)) {
        NSUInteger index = [commandsSchemes count];
        [self addCommand:clickedObject atIndex:index];
    }
}

-(void)doubleClickInTableView {
    NSInteger clickedRow = [_userCommandsTableView clickedRow];
    if (clickedRow >= 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(NSUInteger)clickedRow];
        [self removeCommandsAt:indexSet];
    }
}

#pragma mark - HMTableView Delegate

-(void)deleteIsPressedInTableView:(id)tableView{
    [self removeCommandsAt:[NSIndexSet indexSetWithIndex:[_userCommandsTableView selectedRow]]];
    [_allCommandsCollectionView reloadData];
}

#pragma mark - IBActions

-(IBAction)cancelAction:(id)sender{
    [self close];
}

-(IBAction)save:(id)sender {
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMSettingsWindowControllerDelegate)]){
        [_delegate settingsWindowController:self didUpdateCommandsSchemes:commandsSchemes andGroupOption:groupCommands];
    }
    [self close];
}


#pragma mark - Searching & TextField Delegate


-(IBAction)clearSearchField:(id)sender{
    [_searchField setStringValue:@""];
    [self filterAllCommandsList];
    [self checkClearButton];
}


- (void)checkClearButton {
    BOOL hasText = ![_searchField.stringValue isEqualToString:@""];
    [_clearButton setEnabled:hasText];
    [_clearButton setHidden:!hasText];
}

-(void)controlTextDidBeginEditing:(NSNotification *)obj{
    [self checkClearButton];
}

-(void)controlTextDidEndEditing:(NSNotification *)obj{
    [self checkClearButton];
}

- (void)controlTextDidChange:(NSNotification *)obj{
    [self checkClearButton];
    [self filterAllCommandsList];
    
   
}

// Debouncing method
-(void)filterAllCommandsList {
    
    // Debouncing
    [searchDelayTimer invalidate];
    searchDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            searchString = [self->_searchField stringValue];
            
            NSMutableArray *temporaryArray = [[NSMutableArray alloc] initWithArray:pluginsSchemes copyItems:YES];
            
            if ([searchString length] > 1) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@ OR ANY SELF.pluginCommands.name CONTAINS[c] %@", searchString, searchString];
                NSPredicate *commandPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchString];
                
                [temporaryArray filterUsingPredicate:predicate];
                
                for (HMPluginScheme *pluginScheme in temporaryArray) {
                    NSMutableArray *temporaryCommands = [[pluginScheme pluginCommands] mutableCopy];
                    [temporaryCommands filterUsingPredicate:commandPredicate];
                    if([temporaryCommands count] != 0) {
                        [pluginScheme setPluginCommands:temporaryCommands];
                    }
                }
                
            }
            filteredPluginsSchemes = [temporaryArray mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_allCommandsCollectionView reloadData];
            });
            
        });
        
    }];
}



@end
