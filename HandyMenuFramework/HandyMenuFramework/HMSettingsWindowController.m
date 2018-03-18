//
//  HMSettingsWindowController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMSettingsWindowController.h"

@interface HMSettingsWindowController ()


@end

@implementation HMSettingsWindowController

id shortcutHandlingEventMonitor;
NSArray *allPlugins;


- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setLevel:NSModalPanelWindowLevel];
    [self.window setBackgroundColor:NSColor.whiteColor];
    
    [_shortcutTextField setDelegate:self];
    
    [_allCommandsList setDataSource:self];
    [_allCommandsList setDelegate:self];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if ([item isKindOfClass:NSClassFromString(@"MSPluginBundle")]){
        NSDictionary *children = [item valueForKey:@"commands"];
        return children.count;
    }
    
    return allPlugins.count;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if ([item isKindOfClass:NSClassFromString(@"MSPluginBundle")]){
        NSArray *children = [[item valueForKey:@"commands"] allValues];
        return children[index];
    }
    return allPlugins[index];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:NSClassFromString(@"MSPluginBundle")]){
        return YES;
    }
    return NO;
}


-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    if ([item isKindOfClass:NSClassFromString(@"MSPluginBundle")]){
        return NO;
    }
    return YES;
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    NSTableCellView *tableCellView;
    
    HMLog(@"Adding item");
    if ([item isKindOfClass:NSClassFromString(@"MSPluginBundle")]){
        tableCellView = [_allCommandsList makeViewWithIdentifier:@"PluginCell" owner:self];
    } else {
        tableCellView = [_allCommandsList makeViewWithIdentifier:@"CommandCell" owner:self];
    }
    tableCellView.textField.stringValue = (NSString *)[item valueForKey:@"name"];
    HMLog(@"%@", (NSString *)[item valueForKey:@"name"]);
    
    return tableCellView;
}

-(void)showWindow:(id)sender{
    [super showWindow:sender];
    allPlugins = [HMPluginsDataController getSortedListOfPlugins];
    [_allCommandsList reloadData];
    [_allCommandsList expandItem:nil expandChildren:YES];
}

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

-(BOOL)windowShouldClose:(NSWindow *)sender {
    HMLog(@"Settings window should be closed");
    [[self window] makeFirstResponder:nil];
    return YES;
}

-(IBAction)cancel:(id)sender{
    [self close];
}

-(IBAction)save:(id)sender {
    [self close];
}



@end
