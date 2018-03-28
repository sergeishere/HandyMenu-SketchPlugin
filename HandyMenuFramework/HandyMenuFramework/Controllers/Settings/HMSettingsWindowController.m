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
NSMutableArray *commandsSchemes;

id shortcutHandlingEventMonitor;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setLevel:NSModalPanelWindowLevel];
    [self.window setBackgroundColor:NSColor.whiteColor];
    
    [[self window] center];
    
    [_allCommandsOutlineView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
    [_allCommandsOutlineView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_allCommandsOutlineView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
    
    [_userCommandsTableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
    [_userCommandsTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_userCommandsTableView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
}

-(void)updatePlugins:(NSArray *)schemes{
    pluginsSchemes = schemes;
    [_allCommandsOutlineView reloadData];
    [_allCommandsOutlineView expandItem:nil expandChildren:YES];
    
}

-(void)updateUserCommands:(NSArray *)schemes{
    commandsSchemes = [NSMutableArray arrayWithArray:schemes];
    [_userCommandsTableView reloadData];
}

#pragma mark - NSOutlineView Delegate and DataSource

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if ([item isKindOfClass: [HMPluginScheme class]]){
        NSArray *commands = [(HMPluginScheme*)item commands];
        return commands.count;
    }
    
    return pluginsSchemes.count;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if ([item isKindOfClass:[HMPluginScheme class]]){
        NSArray *commands = [(HMPluginScheme*)item commands];
        return commands[index];
    }
    return pluginsSchemes[index];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[HMPluginScheme class]]){
        return YES;
    }
    return NO;
}


-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    if ([item isKindOfClass:[HMPluginScheme class]]){
        return NO;
    }
    return YES;
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    NSTableCellView *tableCellView;
    
    if ([item isKindOfClass:[HMPluginScheme class]]){
        tableCellView = [_allCommandsOutlineView makeViewWithIdentifier:@"PluginCell" owner:self];
        tableCellView.textField.stringValue = [(NSString *)[item valueForKey:@"name"] uppercaseString];
    } else {
        tableCellView = [_allCommandsOutlineView makeViewWithIdentifier:@"CommandCell" owner:self];
        tableCellView.textField.stringValue = (NSString *)[item valueForKey:@"name"];
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
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pasteboard setData:data forType:NSStringPboardType];
    return YES;
}

-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pboard setData:data forType:NSStringPboardType];
    return YES;
}

-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    return NSDragOperationEvery;
}

-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation{
    
    NSData *data = [[info draggingPasteboard] dataForType:NSPasteboardTypeString];
    NSArray *selectedItems;

    //REORDERING IN THE SAME TABLE VIEW BY DRAG & DROP
    if (([info draggingSource] == _userCommandsTableView) & (tableView == _userCommandsTableView))
    {
        NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        selectedItems = [commandsSchemes objectsAtIndexes:rowIndexes];
        [commandsSchemes removeObjectsAtIndexes:rowIndexes];
    }
    
    //DRAG AND DROP ACROSS THE TABLES
    else if (([info draggingSource] == _allCommandsOutlineView) & (tableView == _userCommandsTableView))
    {
        selectedItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    }
    
    if (row > commandsSchemes.count)
    {
        [commandsSchemes insertObject:[selectedItems objectAtIndex:0] atIndex:row-1];
    }
    else
    {
        [commandsSchemes insertObject:[selectedItems objectAtIndex:0] atIndex:row];
    }
    
    [_allCommandsOutlineView deselectAll:nil];
    [_userCommandsTableView deselectAll:nil];
    [_userCommandsTableView reloadData];
    
    HMLog(@"%@", commandsSchemes);
    
    return YES;
}

#pragma mark - Mouse Events
//-(void)mouseDown:(NSEvent *)event {
//    [[self window] makeFirstResponder:nil];
//    [super mouseDown:event];
//}
//
//-(void)keyDown:(NSEvent *)event {
//
//    HMLog(@"%d", event.keyCode);
//    if (event.keyCode == 23) {
//        [[self window] makeFirstResponder:nil];
//    }
//    [super keyDown:event];
//}

-(void)showWindow:(id)sender {
    [super showWindow:sender];

}

-(BOOL)windowShouldClose:(NSWindow *)sender {
    HMLog(@"Settings window should be closed");
    [[self window] makeFirstResponder:nil];
    return YES;
}

#pragma mark - IBActions

-(IBAction)cancel:(id)sender{
    [self close];
}

-(IBAction)save:(id)sender {
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMSettingsWindowControllerDelegate)]){
        [_delegate settingsWindowController:self didUpdateCommandsSchemes:commandsSchemes];
    }
    [self close];
}



@end
