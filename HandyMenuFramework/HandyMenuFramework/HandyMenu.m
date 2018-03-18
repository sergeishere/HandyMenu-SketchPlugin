//
//  HandyMenu.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 13/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HandyMenu.h"


@implementation HandyMenu

NSMenu *menu;
HMSettingsWindowController *settingsWindowController;

unsigned short shortcutKeyCode = 21;
unsigned long shortcutModifierFlag = NSEventModifierFlagCommand; // + NSEventModifierFlagOption;



+ (void) initializePlugin {
    
    menu = [[NSMenu alloc] init];
    
    id AppController = NSClassFromString(@"AppController");
    NSDictionary *plugins = [AppController valueForKeyPath:@"sharedInstance.pluginManager.plugins"];

    NSArray * pluginsArray = [plugins allValues];
    NSArray * sortedPlugins = [pluginsArray sortedArrayUsingComparator:^(id first, id second) {
        
                NSString *firstName = [first valueForKey:@"name"];
                NSString *secondName = [second valueForKey:@"name"];
        
                return [firstName compare:secondName];
        
    }];
    
//    for(NSString *key in plugins) {
//        id plugin = [plugins objectForKey:key];
    
    for (id plugin in sortedPlugins)
    {
        NSString *pluginName = [plugin valueForKey:@"name"];
        
        if ([pluginName isEqualToString:@"SwiftPlugin"]) {
            continue;
        }
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:pluginName action:nil keyEquivalent:@""];
        NSMenu *subMenu = [[NSMenu alloc] init];
        menuItem.submenu = subMenu;
        [menu addItem:menuItem];
        
        NSDictionary *commands = [plugin valueForKey:@"commands"];
        
        for(NSString *commandKey in commands){
            
            id command = [commands objectForKey:commandKey];
            
            if ((BOOL)objc_msgSend(command, NSSelectorFromString(@"hasRunHandler")) == YES) {
                
                NSString *commandName = [command valueForKey:@"name"];
                
                NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:commandName action:@selector(runCommand:) keyEquivalent:@""];
                subMenuItem.target = self;
                subMenuItem.representedObject = command;
                //                [menu addItem:menuItem];
                
                [subMenu addItem:subMenuItem];
            }

        }
    }
    
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
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

+ (void) runCommand:(NSMenuItem *)sender {
    
    id MSDocument = NSClassFromString(@"MSDocument");
    id pluginContext = [MSDocument valueForKeyPath:@"currentDocument.pluginContext"];
    
    id runningCommand = [sender representedObject];
    SEL a_selector = NSSelectorFromString(@"runPluginCommand:fromMenu:context:");
    id delegate = [NSApp delegate];
    
    objc_msgSend(delegate, a_selector, runningCommand, NO, pluginContext);
    
    //  Alternative way:
    //      typedef void (*MethodType)(id, SEL, id, BOOL, id);
    //      MethodType methodToCall;
    //      methodToCall = (MethodType)[delegate methodForSelector:a_selector];
    //      methodToCall(delegate, a_selector, command, YES, context);
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
