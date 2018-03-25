//
//  HandyMenu.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 13/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HandyMenu.h"


@implementation HandyMenu

HMSettingsWindowController *settingsWindowController;
HMMenuManager *menuManager;

unsigned short shortcutKeyCode = 21;
unsigned long shortcutModifierFlag = NSEventModifierFlagCommand; // + NSEventModifierFlagOption;



+ (void) initializePlugin {
    menuManager = [[HMMenuManager alloc] init];
    [HMUserPluginsDataController loadPlugins];
    [menuManager initializeMenu];
    
    NSEvent * (^handleKeyDown)(NSEvent*) = ^(NSEvent *event){
        
        if ((event.keyCode == shortcutKeyCode) &&
            ([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == shortcutModifierFlag) {
            
            [HandyMenu showMenu];
            
            return (NSEvent *)nil;
        }
        return event;
    };
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:handleKeyDown];
    
    [HandyMenu initSettingsWindowController];
    
}

+ (void) showMenu {
    [menuManager showMenu];
}



+ (void) showSettings {
    [[settingsWindowController window] center];
    [settingsWindowController showWindow:nil];
    HMLog(@"Settings is launched");
}

+ (void) initSettingsWindowController {
    settingsWindowController = [[HMSettingsWindowController alloc] initWithWindowNibName:@"HMSettingsWindowController"];
}


@end
