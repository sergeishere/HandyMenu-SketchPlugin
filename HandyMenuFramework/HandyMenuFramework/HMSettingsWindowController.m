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


- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setLevel:NSModalPanelWindowLevel];
    [self.window setBackgroundColor:NSColor.whiteColor];
    [_shortcutTextField setDelegate:self];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

-(void)showWindow:(id)sender{
    
    [super showWindow:sender];
}

-(void)mouseDown:(NSEvent *)event {
    [[self window] makeFirstResponder:nil];
    [super mouseDown:event];
}

-(void)keyDown:(NSEvent *)event {
    
    HMLog(@"%d", event.keyCode);
    if (event.keyCode == 23) {
        [[self window] makeFirstResponder:nil];
    }
    [super keyDown:event];
}

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
