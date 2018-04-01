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

NSTimer *searchDelayTimer;

BOOL groupCommands = YES;

id shortcutHandlingEventMonitor;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_allCommandsOutlineView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
    [_allCommandsOutlineView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_allCommandsOutlineView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
    
    [_allCommandsOutlineView setDoubleAction:@selector(doubleClickInOutlineView)];
    
    [_userCommandsTableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
    [_userCommandsTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_userCommandsTableView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
    
    [_userCommandsTableView setDoubleAction:@selector(doubleClickInTableView)];
    
}

-(void)updatePlugins:(NSArray *)schemes{
    pluginsSchemes = schemes;
    filteredPluginsSchemes = [pluginsSchemes mutableCopy];
    
    [_allCommandsOutlineView reloadData];
}

-(void)updateUserCommands:(NSArray *)schemes{
    commandsSchemes = [NSMutableArray arrayWithArray:schemes];
    [_userCommandsTableView reloadData];
}

static BOOL itemHasAlreadyAdded(id  _Nonnull item) {
    return [commandsSchemes containsObject:item];
}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
    [_allCommandsOutlineView reloadData];
}



-(void)doubleClickInOutlineView {
    NSInteger clickedRow = [_allCommandsOutlineView clickedRow];
    id clickedObject = [_allCommandsOutlineView itemAtRow:clickedRow];
    if ([clickedObject isKindOfClass:[HMCommandScheme class]] && !itemHasAlreadyAdded(clickedObject)) {
        NSUInteger index = [commandsSchemes count];
        [commandsSchemes insertObject:clickedObject atIndex:index];
        [_userCommandsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectFade];
        [_allCommandsOutlineView reloadData];
    }
}

-(void)doubleClickInTableView {
    NSInteger clickedRow = [_userCommandsTableView clickedRow];
    [commandsSchemes removeObjectAtIndex:clickedRow];
    [_userCommandsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:clickedRow] withAnimation:NSTableViewAnimationEffectFade];
    [_allCommandsOutlineView reloadData];
}

#pragma mark - NSOutlineView Delegate and DataSource

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if ([item isKindOfClass: [HMPluginScheme class]]){
        NSArray *commands = [(HMPluginScheme*)item pluginCommands];
        return commands.count;
    }
    
    return filteredPluginsSchemes.count;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if ([item isKindOfClass:[HMPluginScheme class]]){
        NSArray *commands = [(HMPluginScheme*)item pluginCommands];
        return commands[index];
    }
    return filteredPluginsSchemes[index];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[HMPluginScheme class]]){
        return YES;
    }
    return NO;
}


-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{

    if ([item isKindOfClass:[HMPluginScheme class]]){
        if([_allCommandsOutlineView isItemExpanded:item]) {
            if ([NSEvent modifierFlags] & NSEventModifierFlagCommand) {
                [[_allCommandsOutlineView animator] collapseItem:nil collapseChildren:YES];
            } else {
                [[_allCommandsOutlineView animator] collapseItem:item];
            }
        } else {
            if ([NSEvent modifierFlags] & NSEventModifierFlagCommand) {
                [[_allCommandsOutlineView animator] expandItem:nil expandChildren:YES];
            } else {
                [[_allCommandsOutlineView animator] expandItem:item];
            }
        }
        return NO;
    }
    
    return !itemHasAlreadyAdded(item);
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    NSTableCellView *tableCellView;
    
    if ([item isKindOfClass:[HMPluginScheme class]]){
        tableCellView = [_allCommandsOutlineView makeViewWithIdentifier:@"PluginCell" owner:self];
        tableCellView.textField.stringValue = [(NSString *)[item valueForKey:@"name"] uppercaseString];
        
        if([[NSSet setWithArray:[item pluginCommands]] intersectsSet:[NSSet setWithArray:commandsSchemes]]){
            [tableCellView.textField setTextColor:[NSColor colorWithRed:0.16 green:0.73 blue:0.96 alpha:1.0]];
        } else {
            [tableCellView.textField setTextColor:[NSColor disabledControlTextColor]];
        }
        
    } else {
        tableCellView = [_allCommandsOutlineView makeViewWithIdentifier:@"CommandCell" owner:self];
        tableCellView.textField.stringValue = (NSString *)[item valueForKey:@"name"];
        
        if (itemHasAlreadyAdded(item)) {
            tableCellView.textField.stringValue = [NSString stringWithFormat:@"✓ %@",tableCellView.textField.stringValue];
            [tableCellView.textField setTextColor:[NSColor colorWithWhite:0 alpha:0.2]];
        } else {
            [tableCellView.textField setTextColor:[NSColor controlTextColor]];
        }
    }
    
    return tableCellView;
}

#pragma mark - NSTableView Delegate and DataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [commandsSchemes count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *tableCellView;
    
    HMCommandScheme *command = commandsSchemes[row];
    
    tableCellView = [_userCommandsTableView makeViewWithIdentifier:@"CommandCell" owner:self];
    tableCellView.textField.stringValue = [command valueForKey:@"name"];
    
    return tableCellView;
}

#pragma mark - Drag & Drop Delegates

-(BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard{
    if(!itemHasAlreadyAdded([items objectAtIndex:0])) {
        NSIndexSet* indexSets = [NSIndexSet indexSetWithIndex:[_allCommandsOutlineView rowForItem:[items objectAtIndex:0]]];
        [_allCommandsOutlineView selectRowIndexes:indexSets byExtendingSelection:NO];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
        [pasteboard setData:data forType:NSStringPboardType];
        return YES;
    }
    return NO;
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

    if([info draggingSource] == _userCommandsTableView || [info draggingSource] == _allCommandsOutlineView) {
        
        NSData *data = [[info draggingPasteboard] dataForType:NSPasteboardTypeString];
        NSArray *selectedItems;
        BOOL itemFromAllCommandsList = NO;
        NSInteger fromIndex = 0;
        NSInteger toIndex = 0;
        
        //REORDERING IN THE SAME TABLE VIEW BY DRAG & DROP
        if (([info draggingSource] == _userCommandsTableView) && (tableView == _userCommandsTableView))
        {
            NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            fromIndex = [rowIndexes firstIndex];
            selectedItems = [commandsSchemes objectsAtIndexes:rowIndexes];
            [commandsSchemes removeObjectsAtIndexes:rowIndexes];
        }
        
        //DRAG AND DROP ACROSS THE TABLES
        else if (([info draggingSource] == _allCommandsOutlineView) && (tableView == _userCommandsTableView))
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
        
        if(itemFromAllCommandsList) {
            [_allCommandsOutlineView reloadData];
            [_userCommandsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:toIndex] withAnimation:NSTableViewAnimationEffectFade];
        } else {
            [_userCommandsTableView beginUpdates];
            [_userCommandsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] withAnimation:NSTableViewAnimationEffectFade];
            [_userCommandsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:toIndex] withAnimation:NSTableViewAnimationEffectFade];
            [_userCommandsTableView endUpdates];
        }
        
        [_allCommandsOutlineView deselectAll:nil];
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
        [commandsSchemes removeObjectsAtIndexes:rowIndexes];
        [_userCommandsTableView reloadData];
        [_allCommandsOutlineView reloadData];
    }
}

//#pragma mark - Mouse Events

//-(void)mouseDown:(NSEvent *)event {
//    [self.window makeFirstResponder:nil];
//    [super mouseDown:event];
//}
//
//-(void)keyDown:(NSEvent *)event {
//
//    HMLog(@"%d", event.keyCode);
//    if (event.keyCode == 23) {
//        [self.window makeFirstResponder:nil];
//    }
//    [super keyDown:event];
//}
//
//-(BOOL)windowShouldClose:(NSWindow *)sender {
//    HMLog(@"Settings window should be closed");
//    [self.window makeFirstResponder:nil];
//    return YES;
//}

#pragma mark - HMTableView Delegate

-(void)deleteIsPressedInTableView:(id)tableView{
    [commandsSchemes removeObjectAtIndex:[_userCommandsTableView selectedRow]];
    [_userCommandsTableView reloadData];
    [_allCommandsOutlineView reloadData];
}

#pragma mark - IBActions

-(IBAction)cancel:(id)sender{
    [self close];
}

-(IBAction)save:(id)sender {
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMSettingsWindowControllerDelegate)]){
        [_delegate settingsWindowController:self didUpdateCommandsSchemes:commandsSchemes andGroupOption:groupCommands];
    }
    [self close];
}

-(IBAction)changedSearchText:(id)sender {
    // Debouncing
    [searchDelayTimer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(filterAllCommandsList) userInfo:nil repeats:NO];
}

// Debouncing method
-(void)filterAllCommandsList {

    NSString *stringValue = [_searchField stringValue];
    NSMutableArray *temporaryArray = [[NSMutableArray alloc] initWithArray:pluginsSchemes copyItems:YES];

    if ([stringValue length] >= 2) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@ OR SUBQUERY(commands, $command, $command.name CONTAINS[c] %@).@count > 0", stringValue, stringValue];
        NSPredicate *commandPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", stringValue];

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

    [_allCommandsOutlineView reloadData];
    [_allCommandsOutlineView expandItem:nil expandChildren:YES];

}



@end
