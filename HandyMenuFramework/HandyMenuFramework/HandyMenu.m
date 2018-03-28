//
//  HandyMenu.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 13/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HandyMenu.h"
#import "HMLog.h"

@implementation HandyMenu

HMPluginController *pluginController;

unsigned short shortcutKeyCode = 21;
unsigned long shortcutModifierFlag = NSEventModifierFlagCommand; // + NSEventModifierFlagOption;

+ (void) initializePlugin {
    pluginController = [[HMPluginController alloc] init];
    
    NSEvent * (^handleKeyDown)(NSEvent*) = ^(NSEvent *event){
        
        if ((event.keyCode == shortcutKeyCode) &&
            ([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == shortcutModifierFlag) {
            
            [pluginController showMenu];
            
            return (NSEvent *)nil;
        }
        return event;
    };
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:handleKeyDown];
    
}

+ (void) showMenu {
    [pluginController showMenu];
}


+ (void) showSettings {
    [pluginController showSettings];
}


@end
